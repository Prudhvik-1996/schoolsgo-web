import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:schoolsgo_web/src/api_calls/api_calls.dart';
import 'package:schoolsgo_web/src/common_components/default_splash_screen.dart';
import 'package:schoolsgo_web/src/common_components/route_observer_service.dart';
import 'package:schoolsgo_web/src/login/login_screen.dart';
import 'package:schoolsgo_web/src/model/user_details.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as user_details;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';
import 'package:schoolsgo_web/src/user_dashboard/user_dashboard.dart';
import 'package:schoolsgo_web/src/user_dashboard/user_dashboard_v2.dart';
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
  late String loggedInMobile;
  late int loggedInStudentId;

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
    if (RouteObserverService.shouldSkipSplashScreen()) {
      print("Skipping navigation");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool('IS_USER_LOGGED_IN') ?? false;
    loggedInStudentId = prefs.getInt('LOGGED_IN_STUDENT_ID') ?? 0;
    setState(() {
      isUserLoggedIn = boolValue;
    });
    String? storedMobile = prefs.getString('LOGGED_IN_MOBILE');
    if (storedMobile != null) {
      setState(() {
        loggedInMobile = storedMobile;
      });
      Navigator.restorablePushNamed(
        context,
        UserDashboardV2.routeName,
        arguments: "m$loggedInMobile",
      );
      return;
    }
    if (isUserLoggedIn) {
      int id = prefs.getInt('LOGGED_IN_USER_ID') ?? 0;
      setState(() {
        loggedInUserId = id;
      });
      GetUserDetailsResponse getUserDetailsResponse = await getUserDetails(
        user_details.UserDetails(
          userId: id,
        ),
      );
      if (getUserDetailsResponse.userDetails!.first.fourDigitPin != null) {
        await prefs.setString('USER_FOUR_DIGIT_PIN', getUserDetailsResponse.userDetails!.first.fourDigitPin!);
      }
    } else {
      debugPrint("64");
      try {
        await FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    debugPrint("57:");
    if (isUserLoggedIn) {
      if (loggedInUserId != 0) {
        Navigator.restorablePushNamed(
          context,
          UserDashboard.routeName,
          arguments: loggedInUserId,
        );
      } else if (loggedInStudentId != 0) {
        GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
          studentId: loggedInStudentId,
        ));
        Navigator.restorablePushNamed(
          context,
          StudentDashBoard.routeName,
          arguments: getStudentProfileResponse.studentProfiles!.first!,
        );
      }
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
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container(); //,defaultSplashScreen(context);
  }
}
