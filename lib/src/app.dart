import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/student_attendance_view_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/profile/student/student_profile_screen.dart';
import 'package:schoolsgo_web/src/splash_screen/splash_screen.dart';
import 'package:schoolsgo_web/src/student_dashboard/student_dashboard.dart';
import 'package:schoolsgo_web/src/time_table/student/student_time_table_view.dart';
import 'package:schoolsgo_web/src/user_dashboard/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common_components/default_splash_screen.dart';
import 'common_components/not_found_screen.dart';
import 'login/login_screen.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);
  final SettingsController settingsController;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  late bool isUserLoggedIn;
  int? loggedInUserId;

  @override
  void initState() {
    _loadLoggedInUserId();
    super.initState();
  }

  Future<void> _loadLoggedInUserId() async {
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

    if (isUserLoggedIn) {
      Navigator.restorablePushNamed(
        context,
        UserDashboard.routeName,
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
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: "Epsilon Diary",
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          onUnknownRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  return const E404NotFoundScreen();
                });
          },
          onGenerateRoute: (RouteSettings routeSettings) {
            print(routeSettings.name);
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                // if (loggedInUserId == null) return const SplashScreen();
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case SplashScreen.routeName:
                    return const SplashScreen();
                  case LoginScreen.routeName:
                    return const LoginScreen();
                  case UserDashboard.routeName:
                    try {
                      return UserDashboard(
                        loggedInUserId:
                            loggedInUserId ?? (routeSettings.arguments as int),
                      );
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case StudentDashBoard.routeName:
                    if (routeSettings.arguments == null) {
                      return const SplashScreen();
                    }
                    var argument = (routeSettings.arguments as StudentProfile);
                    return StudentDashBoard(
                      studentProfile: argument,
                    );
                  case StudentProfileScreen.routeName:
                    try {
                      var argument =
                          (routeSettings.arguments as StudentProfile);
                      return StudentProfileScreen(
                        studentProfile: argument,
                      );
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case StudentAttendanceViewScreen.routeName:
                    try {
                      var argument =
                          (routeSettings.arguments as StudentProfile);
                      return StudentAttendanceViewScreen(
                        studentProfile: argument,
                      );
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case StudentTimeTableView.routeName:
                    try {
                      var argument =
                          (routeSettings.arguments as StudentProfile);
                      return StudentTimeTableView(
                        studentProfile: argument,
                      );
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  default:
                    return const E404NotFoundScreen();
                }
              },
            );
          },
        );
      },
      child: _isLoading ? defaultSplashScreen(context) : Container(),
    );
  }
}
