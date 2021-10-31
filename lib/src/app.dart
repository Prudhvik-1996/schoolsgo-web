import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_attendance_options_screen.dart';
import 'package:schoolsgo_web/src/attendance/teacher/teacher_attendance_time_slots_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_fee_options_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_dashboard/admin_dashboard.dart';
import 'attendance/student/student_attendance_view_screen.dart';
import 'common_components/dashboard_widgets.dart';
import 'common_components/default_splash_screen.dart';
import 'common_components/not_found_screen.dart';
import 'diary/admin/admin_diary_screen.dart';
import 'diary/student/student_diary_screen.dart';
import 'events/admin/admin_each_event_screen.dart';
import 'events/admin/admin_events_screen.dart';
import 'events/model/events.dart';
import 'events/student/student_each_event_view.dart';
import 'events/student/student_events_view.dart';
import 'events/teacher/teacher_each_event_view.dart';
import 'events/teacher/teacher_events_view.dart';
import 'logbook/logbook_screen.dart';
import 'login/login_screen.dart';
import 'model/user_roles_response.dart';
import 'notice_board/admin/admin_notice_board_screen.dart';
import 'notice_board/student/student_notice_board_view.dart';
import 'notice_board/teacher/teacher_notice_board_view.dart';
import 'profile/admin/admin_profile_screen.dart';
import 'profile/student/student_profile_screen.dart';
import 'profile/teacher/teacher_profile_screen.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'splash_screen/splash_screen.dart';
import 'student_dashboard/student_dashboard.dart';
import 'study_material/admin/admin_study_material_tds_screen.dart';
import 'study_material/student/student_study_material_tds_screen.dart';
import 'study_material/teacher/teacher_study_material_tds_screen.dart';
import 'suggestion_box/admin/admin_suggestion_box.dart';
import 'suggestion_box/student/student_suggestion_box.dart';
import 'teacher_dashboard/teacher_dashboard.dart';
import 'time_table/admin/admin_all_teachers_preview_time_table_screens.dart';
import 'time_table/admin/admin_edit_timetable_screen.dart';
import 'time_table/admin/admin_teacher_dealing_sections_screen.dart';
import 'time_table/admin/admin_time_table_randomizer_screen.dart';
import 'time_table/admin/admin_timetable_options_screen.dart';
import 'time_table/student/student_time_table_view.dart';
import 'time_table/teacher/teacher_time_table_view.dart';
import 'user_dashboard/user_dashboard.dart';

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
                  case TeacherDashboard.routeName:
                    if (routeSettings.arguments == null) {
                      return const SplashScreen();
                    }
                    var argument = (routeSettings.arguments as TeacherProfile);
                    return TeacherDashboard(
                      teacherProfile: argument,
                    );
                  case AdminDashboard.routeName:
                    if (routeSettings.arguments == null) {
                      return const SplashScreen();
                    }
                    var argument = (routeSettings.arguments as AdminProfile);
                    return AdminDashboard(
                      adminProfile: argument,
                    );
                  case StudentProfileScreen.routeName:
                    try {
                      if (routeSettings.arguments is TeacherProfile) {
                        var teacherProfile =
                            routeSettings.arguments as TeacherProfile;
                        return TeacherProfileScreen(
                          teacherProfile: teacherProfile,
                        );
                      } else if (routeSettings.arguments is AdminProfile) {
                        var adminProfile =
                            routeSettings.arguments as AdminProfile;
                        return AdminProfileScreen(
                          adminProfile: adminProfile,
                        );
                      } else {
                        var argument =
                            (routeSettings.arguments as StudentProfile);
                        return StudentProfileScreen(
                          studentProfile: argument,
                        );
                      }
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case LogbookScreen.routeName:
                    try {
                      if (routeSettings.arguments is TeacherProfile) {
                        var teacherProfile =
                            routeSettings.arguments as TeacherProfile;
                        return LogbookScreen(
                          teacherProfile: teacherProfile,
                          adminProfile: null,
                        );
                      } else if (routeSettings.arguments is AdminProfile) {
                        var adminProfile =
                            routeSettings.arguments as AdminProfile;
                        return LogbookScreen(
                          teacherProfile: null,
                          adminProfile: adminProfile,
                        );
                      } else {
                        return const E404NotFoundScreen();
                      }
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case DiaryEditScreen.routeName:
                    try {
                      if (routeSettings.arguments is StudentProfile) {
                        var studentProfile =
                            routeSettings.arguments as StudentProfile;
                        return StudentDiaryScreen(
                          studentProfile: studentProfile,
                        );
                      } else if (routeSettings.arguments is TeacherProfile) {
                        var teacherProfile =
                            routeSettings.arguments as TeacherProfile;
                        return DiaryEditScreen(
                          teacherProfile: teacherProfile,
                          adminProfile: null,
                        );
                      } else if (routeSettings.arguments is AdminProfile) {
                        var adminProfile =
                            routeSettings.arguments as AdminProfile;
                        return DiaryEditScreen(
                          teacherProfile: null,
                          adminProfile: adminProfile,
                        );
                      } else {
                        return const E404NotFoundScreen();
                      }
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case AdminSuggestionBox.routeName:
                    try {
                      if (routeSettings.arguments is StudentProfile) {
                        var studentProfile =
                            routeSettings.arguments as StudentProfile;
                        return StudentSuggestionBoxView(
                          studentProfile: studentProfile,
                        );
                      } else if (routeSettings.arguments is AdminProfile) {
                        var adminProfile =
                            routeSettings.arguments as AdminProfile;
                        return AdminSuggestionBox(
                          adminProfile: adminProfile,
                        );
                      } else {
                        return const E404NotFoundScreen();
                      }
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case StudentAttendanceViewScreen.routeName:
                    try {
                      if (routeSettings.arguments is StudentProfile) {
                        var argument =
                            (routeSettings.arguments as StudentProfile);
                        return StudentAttendanceViewScreen(
                          studentProfile: argument,
                        );
                      }
                      if (routeSettings.arguments is TeacherProfile) {
                        var argument =
                            (routeSettings.arguments as TeacherProfile);
                        return TeacherAttendanceTimeslots(
                          teacherProfile: argument,
                        );
                      } else {
                        var argument =
                            (routeSettings.arguments as AdminProfile);
                        return AdminAttendanceOptionsScreen(
                          adminProfile: argument,
                        );
                      }
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case StudentNoticeBoardView.routeName:
                    if (routeSettings.arguments is StudentProfile) {
                      try {
                        var argument =
                            (routeSettings.arguments as StudentProfile);
                        return StudentNoticeBoardView(
                          studentProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    } else if (routeSettings.arguments is TeacherProfile) {
                      try {
                        var argument =
                            (routeSettings.arguments as TeacherProfile);
                        return TeacherNoticeBoardView(
                          teacherProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    } else {
                      try {
                        var argument =
                            (routeSettings.arguments as AdminProfile);
                        return AdminNoticeBoardScreen(
                          adminProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    }
                  case StudentStudyMaterialTDSScreen.routeName:
                    try {
                      if (routeSettings.arguments is StudentProfile) {
                        var argument =
                            (routeSettings.arguments as StudentProfile);
                        return StudentStudyMaterialTDSScreen(
                          studentProfile: argument,
                        );
                      } else if (routeSettings.arguments is AdminProfile) {
                        var argument =
                            (routeSettings.arguments as AdminProfile);
                        return AdminStudyMaterialTDSScreen(
                          adminProfile: argument,
                        );
                      } else if (routeSettings.arguments is TeacherProfile) {
                        var argument =
                            (routeSettings.arguments as TeacherProfile);
                        return TeacherStudyMaterialTDSScreen(
                          teacherProfile: argument,
                        );
                      } else {
                        return const E404NotFoundScreen();
                      }
                    } catch (e) {
                      return const E404NotFoundScreen();
                    }
                  case StudentTimeTableView.routeName:
                    if (routeSettings.arguments is StudentProfile) {
                      try {
                        var argument =
                            (routeSettings.arguments as StudentProfile);
                        return StudentTimeTableView(
                          studentProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    } else if (routeSettings.arguments is TeacherProfile) {
                      try {
                        var argument =
                            (routeSettings.arguments as TeacherProfile);
                        return TeacherTimeTableView(
                          teacherProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    } else if (routeSettings.arguments
                        is AdminRouteWithParams<String>) {
                      var routeArgument = (routeSettings.arguments!
                          as AdminRouteWithParams<String>);
                      switch (routeArgument.params![0]) {
                        case "Teacher Dealing Sections":
                          return AdminTeacherDealingSectionsScreen(
                            adminProfile: routeArgument.adminProfile,
                          );
                        case "Section Wise Time Slots Management":
                          return AdminEditTimeTable(
                            adminProfile: routeArgument.adminProfile,
                          );
                        case "Automatic Time Table Generation":
                          return AdminTimeTableRandomizer(
                              adminProfile: routeArgument.adminProfile);
                        case "All Teachers' Time Table Preview":
                          return TeacherTimeTablePreviewScreen(
                            adminProfile: routeArgument.adminProfile,
                            teacherProfile: null,
                          );
                        default:
                          return AdminTimeTableOptions(
                            adminProfile: routeArgument.adminProfile,
                          );
                      }
                    } else {
                      try {
                        var argument =
                            (routeSettings.arguments as AdminProfile);
                        return AdminTimeTableOptions(
                          adminProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    }
                  case StudentEventsView.routeName:
                    if (routeSettings.arguments is StudentProfile) {
                      try {
                        var argument =
                            (routeSettings.arguments as StudentProfile);
                        return StudentEventsView(
                          studentProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    }
                    if (routeSettings.arguments is TeacherProfile) {
                      try {
                        var argument =
                            (routeSettings.arguments as TeacherProfile);
                        return TeacherEventsView(
                          teacherProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    } else {
                      try {
                        var argument =
                            (routeSettings.arguments as AdminProfile);
                        return AdminEventsScreen(
                          adminProfile: argument,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    }
                  case StudentEachEventView.routeName:
                    if ((routeSettings.arguments! as List<Object>)[0]
                        is StudentProfile) {
                      try {
                        var arguments =
                            (routeSettings.arguments! as List<Object>);
                        var studentProfile = arguments[0] as StudentProfile;
                        var event = arguments[1] as Event;
                        return StudentEachEventView(
                          schoolId: studentProfile,
                          event: event,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    } else if ((routeSettings.arguments! as List<Object>)[0]
                        is TeacherProfile) {
                      try {
                        var arguments =
                            (routeSettings.arguments! as List<Object>);
                        var teacherProfile = arguments[0] as TeacherProfile;
                        var event = arguments[1] as Event;
                        return TeacherEachEventView(
                          teacherProfile: teacherProfile,
                          event: event,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    } else {
                      try {
                        var arguments =
                            (routeSettings.arguments! as List<Object>);
                        var adminProfile = arguments[0] as AdminProfile;
                        var event = arguments[1] as Event;
                        return AdminEachEventScreen(
                          adminProfile: adminProfile,
                          event: event,
                        );
                      } catch (e) {
                        return const E404NotFoundScreen();
                      }
                    }
                  case AdminFeeOptionsScreen.routeName:
                    try {
                      var adminProfile =
                          routeSettings.arguments! as AdminProfile;
                      return AdminFeeOptionsScreen(
                        adminProfile: adminProfile,
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
