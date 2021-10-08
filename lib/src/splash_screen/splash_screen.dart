import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/default_splash_screen.dart';
import 'package:schoolsgo_web/src/login/login_screen.dart';
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
