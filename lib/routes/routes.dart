import 'package:flutter/widgets.dart';
import 'package:google_maps_app_otp/screens/verify_code_screen.dart';
import 'package:google_maps_app_otp/wrapper.dart';

import '../screens/home_screen.dart';
import '../tabs/location_tab.dart';
import '../tabs/profile_tab.dart';
import '../screens/signup_screen.dart';
import '../screens/signin_screen.dart';

Map<String, Widget Function(BuildContext)> routes = {
  // signin screen
  SignInScreen.routeName: (BuildContext ctx) => const SignInScreen(),
  // home screen
  HomeScreen.routeName: (BuildContext ctx) => HomeScreen(),
  // profile screen
  ProfileTab.routeName: (BuildContext ctx) => const ProfileTab(),
  // location screen
  LocationTab.routeName: (BuildContext ctx) => const LocationTab(),
  // signup screen
  SignUpScreen.routeName: (BuildContext ctx) => const SignUpScreen(),
  // wrapper
  Wrapper.routeName: (BuildContext ctx) => const Wrapper(),
};
