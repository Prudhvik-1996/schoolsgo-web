import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/default_splash_screen.dart';
import 'package:schoolsgo_web/src/login/login_screen.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/user_dashboard/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static const routeName = "/";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool isUserLoggedIn = false;
  late int loggedInUserId;

  int splashScreenDelay = 1;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "480997552358-t9ir5mnb6t91gcemhdmdivh3a1uo3208.apps.googleusercontent.com",
  );

  @override
  void initState() {
    super.initState();
    hasUserBeenLoggedIn();
  }

  Future<void> hasUserBeenLoggedIn() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool('IS_USER_LOGGED_IN') ?? false;
    setState(() {
      isUserLoggedIn = boolValue;
    });
    if (isUserLoggedIn) {
      int id = prefs.getInt('LOGGED_IN_USER_ID') ?? 0;
      setState(() {
        loggedInUserId = id;
      });
      GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(
        UserDetails(
          userId: id,
        ),
      );
      if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
        await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
      }
    } else {
      print("64");
      try {
        await FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      } catch (e) {
        print(e);
      }
    }

    print("57:");
    if (isUserLoggedIn) {
      Navigator.restorablePushNamed(
        context,
        UserDashboard.routeName,
        arguments: loggedInUserId,
      );
    } else {
      Navigator.restorablePushNamed(
        context,
        LoginScreen.routeName,
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return defaultSplashScreen(context);
  }
}
