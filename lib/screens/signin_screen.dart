import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/user_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  static const routeName = '/signin-screen';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;
  String? _errorMessage = null;
  TextEditingController? _phoneController;

  final GlobalKey<FormFieldState> _phoneKey = GlobalKey<FormFieldState>();

  // sends otp after validation
  void _sendOTP() async {
    if (_phoneKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      final message = await Provider.of<UserProvider>(
        context,
        listen: false,
      ).sendOTP(_phoneController!.text, context);
      setState(() {
        _loading = false;
      });
      if (message != null) {
        _errorMessage = message;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController?.dispose();
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
        body: SingleChildScrollView(
          child: SizedBox(
            height: h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // login with otp text
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Login with OTP',
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TextFormField(
                    key: _phoneKey,
                    controller: _phoneController,
                    autofocus: true,
                    obscureText: false,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a phone number.';
                      } else if (value.length != 10) {
                        return 'Enter a 10-digit number.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String? val) {
                      _sendOTP();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),
                ),
                // error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _errorMessage.toString(),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                // send otp button
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: (_loading)
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            _sendOTP();
                          },
                          child: const Text(
                            'Send OTP',
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
    );
  }
}
