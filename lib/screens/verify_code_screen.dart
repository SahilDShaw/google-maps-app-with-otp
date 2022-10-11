import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_app_otp/wrapper.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../location/location.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verificationId;
  const VerifyCodeScreen({Key? key, required this.verificationId})
      : super(key: key);

  static const routeName = '/verify-code-screen';

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  bool _loading = false;
  late bool _passwordVisibility = false;
  String? _errorMessage = null;
  TextEditingController? _otpController;

  final GlobalKey<FormFieldState> _otpKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final h = mediaQuery.height;

    // asking permission for location
    Future<bool> _handleLocationPermission() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
        return false;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
        return false;
      }
      return true;
    }

    // getting address from lat and lng
    Future<void> _getAddressFromLatLng(Position position) async {
      await placemarkFromCoordinates(MyLocation.currentPosition!.latitude,
              MyLocation.currentPosition!.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        setState(() {
          MyLocation.currentAddress =
              '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        });
      }).catchError((e) {
        debugPrint(e);
      });
    }

    // getting current position and address
    Future<void> _getCurrentPosition() async {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() => MyLocation.currentPosition = position);
      }).catchError((e) {
        debugPrint(e);
      });
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() => MyLocation.currentPosition = position);
        _getAddressFromLatLng(MyLocation.currentPosition!);
      }).catchError((e) {
        debugPrint(e);
      });
    }

    // verify otp
    void _verifyOTP() async {
      if (_otpKey.currentState!.validate()) {
        setState(() {
          _loading = true;
        });

        print(_otpController!.text);
        final message = await Provider.of<UserProvider>(
          context,
          listen: false,
        ).signInUsingOTP(_otpController!.text, widget.verificationId, context);

        setState(() {
          _loading = false;
        });
        if (message != null) {
          setState(() {
            _errorMessage = message;
          });
        } else {
          await _getCurrentPosition();
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
          Navigator.of(context).pushReplacementNamed(Wrapper.routeName);
        }
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Verify OTP',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        color: Color(0xff4C566A),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SourceSansPro',
                      ),
                    ),
                  ),
                  // otp text field
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    child: TextFormField(
                      key: _otpKey,
                      controller: _otpController,
                      autofocus: true,
                      obscureText: !_passwordVisibility,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: false,
                        decimal: false,
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter the OTP.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (String? val) {
                        _verifyOTP();
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              _passwordVisibility = !_passwordVisibility;
                            });
                          },
                          focusNode: FocusNode(skipTraversal: true),
                          child: Icon(
                            _passwordVisibility
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // verify otp button
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: (_loading)
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              _verifyOTP();
                            },
                            child: const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
