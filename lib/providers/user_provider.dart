import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_app_otp/screens/home_screen.dart';
import 'package:google_maps_app_otp/screens/verify_code_screen.dart';

class UserProvider with ChangeNotifier {
  // Data
  String? _name;
  String? _address;
  String? _phone;

  // getters
  String? get name => _name;
  String? get address => _address;
  String? get phone => _phone;

  // setters
  void setData({
    required String name,
    required String address,
    required String phone,
  }) {
    _name = name;
    _address = address;
    _phone = phone;
    print('Values set: $_name  $_address  $_phone');
  }

  void setPhone({required String phone}) {
    _phone = phone;
    print('Phone set: $_phone');
  }

  // create entry in the database
  Future<void> dataEntry({
    required String name,
    required String address,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final users = FirebaseFirestore.instance.collection('UserData');
    return users.doc(uid).set(
      {
        'name': name,
        'address': address,
        'phoneNumber': _phone,
      },
    ).then((value) {
      _name = name;
      _address = address;
      print("User Created");
    }).catchError(
      (error) => print("Failed to create user: $error"),
    );
  }

  // sending OTP
  Future<String?> sendOTP(String phoneNumber, BuildContext context) async {
    final auth = FirebaseAuth.instance;

    String? message = null;
    await auth.verifyPhoneNumber(
      phoneNumber: '+91 ${phoneNumber}',
      verificationCompleted: (_) {},
      verificationFailed: (_) {
        message = 'Verification Failed!';
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCodeScreen(
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (e) {
        message = 'OTP was Timed Out';
      },
    );
    _phone = phoneNumber;
    return message;
  }

  // sign in
  Future<String?> signInUsingOTP(
    String otp,
    String verificationId,
    BuildContext context,
  ) async {
    final auth = FirebaseAuth.instance;
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      await auth.signInWithCredential(credential);
      return null;
    } catch (e) {
      return 'Error Occured!';
    }
  }

  // sign out
  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
