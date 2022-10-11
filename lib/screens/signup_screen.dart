import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../location/location.dart';
import '../screens/home_screen.dart';
import '../providers/user_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  static const routeName = '/signup-screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController? _nameController;
  TextEditingController? _addressController;
  String? _errorMessage = null;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _nameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _addressKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _addressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final h = mediaQuery.height;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // sign up text
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Sign Up',
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
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // name
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5),
                          child: TextFormField(
                            key: _nameKey,
                            controller: _nameController,
                            autofocus: true,
                            obscureText: false,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter a name.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (String? val) {
                              _nameKey.currentState!.validate();
                            },
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                          ),
                        ),
                        // address
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5),
                          child: TextFormField(
                            key: _addressKey,
                            controller: _addressController,
                            autofocus: true,
                            obscureText: false,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter an address.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (String? val) {
                              _addressKey.currentState!.validate();
                            },
                            decoration: const InputDecoration(
                              labelText: 'Address',
                            ),
                          ),
                        ),
                        // enter button
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).dataEntry(
                                    name: _nameController!.text,
                                    address: _addressController!.text);
                                Navigator.of(context)
                                    .popUntil(ModalRoute.withName('/'));
                                Navigator.of(context)
                                    .pushReplacementNamed(HomeScreen.routeName);
                              }
                            },
                            child: const Text(
                              'Enter',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
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
