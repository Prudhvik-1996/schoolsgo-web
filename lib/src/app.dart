import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/admin_expenses_screen_admin_view.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_attendance_options_screen.dart';
import 'package:schoolsgo_web/src/attendance/teacher/teacher_attendance_time_slots_screen.dart';
import 'package:schoolsgo_web/src/bus/admin/admin_bus_options_screen.dart';
import 'package:schoolsgo_web/src/bus/student/student_bus_screen.dart';
import 'package:schoolsgo_web/src/chat_room/student/student_chat_room.dart';
import 'package:schoolsgo_web/src/chat_room/teacher/teacher_chat_room.dart';
import 'package:schoolsgo_web/src/circulars/admin/admin_circulars_screen.dart';
import 'package:schoolsgo_web/src/circulars/mega_admin/mega_admin_circulars_screen.dart';
import 'package:schoolsgo_web/src/circulars/teachers/teacher_circular_screen.dart';
import 'package:schoolsgo_web/src/common_components/network_status/constants/network_status.dart';
import 'package:schoolsgo_web/src/common_components/network_status/no_internet_screen.dart';
import 'package:schoolsgo_web/src/common_components/network_status/service/network_status_service.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/demo/student/student_demo_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/admin_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/grading_algorithms/admin_grading_algorithms_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/manage_exams/admin_create_or_manage_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/publish_results/admin_publish_results_screen.dart';
import 'package:schoolsgo_web/src/exams/student/student_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/teacher/teacher_exam_tds_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_fee_options_screen.dart';
import 'package:schoolsgo_web/src/fee/student/student_fee_screen.dart';
import 'package:schoolsgo_web/src/feedback/admin/admin_feedback_screen.dart';
import 'package:schoolsgo_web/src/ledger/admin/admin_ledger_screen.dart';
import 'package:schoolsgo_web/src/mega_admin/mega_admin_all_schools_page.dart';
import 'package:schoolsgo_web/src/mega_admin/mega_admin_home_page.dart';
import 'package:schoolsgo_web/src/notice_board/mega_admin/mega_admin_notice_board_screen.dart';
import 'package:schoolsgo_web/src/online_class_room/admin/admin_ocr_options_screen.dart';
import 'package:schoolsgo_web/src/payslips/admin/payslips_options_screen.dart';
import 'package:schoolsgo_web/src/profile/mega_admin/mega_admin_profile_screen.dart';
import 'package:schoolsgo_web/src/suggestion_box/mega_admin/mega_admin_suggestion_box.dart';
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
import 'feedback/student/student_feedback_screen.dart';
import 'feedback/teacher/feedback_screen.dart';
import 'logbook/logbook_screen.dart';
import 'login/login_screen.dart';
import 'model/user_roles_response.dart';
import 'notice_board/admin/admin_notice_board_screen.dart';
import 'notice_board/student/student_notice_board_view.dart';
import 'notice_board/teacher/teacher_notice_board_view.dart';
import 'online_class_room/admin/admin_manage_online_class_rooms_screen.dart';
import 'online_class_room/admin/admin_monitor_online_class_rooms_screen.dart';
import 'online_class_room/student/student_online_class_room.dart';
import 'online_class_room/teacher/teacher_online_class_room.dart';
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

  NetworkStatus networkStatus = NetworkStatus.Offline;

  @override
  void initState() {
    _loadLoggedInUserId();
    super.initState();
  }

  Future<void> _loadLoggedInUserId() async {
    setState(() {
      _isLoading = true;
    });
    networkStatus = await NetworkStatusService().getInitialStatus();
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
        SplashScreen.routeName,
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
        return StreamProvider<NetworkStatus>(
          initialData: networkStatus,
          create: (context) => NetworkStatusService().networkStatusController.stream,
          child: MaterialApp(
            title: "Epsilon Diary",
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'app',
            theme: ThemeData(
              textTheme: textThemesMap[widget.settingsController.textTheme]!.apply(
                bodyColor: Colors.black,
                displayColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              textTheme: textThemesMap[widget.settingsController.textTheme]!.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
            themeMode: widget.settingsController.themeMode,
            onUnknownRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) {
                    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
                    if (networkStatus == NetworkStatus.Offline) {
                      return const NoInternetScreen();
                    }
                    return const E404NotFoundScreen();
                  });
            },
            onGenerateRoute: (RouteSettings routeSettings) {
              print(routeSettings.name);
              return buildCustomMaterialPageRoute(routeSettings);
            },
          ),
        );
      },
      child: _isLoading ? defaultSplashScreen(context) : Container(),
    );
  }

  MaterialPageRoute<void> buildCustomMaterialPageRoute(RouteSettings routeSettings) {
    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (BuildContext context) {
        // if (loggedInUserId == null) return const SplashScreen();
        NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
        if (networkStatus == NetworkStatus.Offline) {
          return const NoInternetScreen();
        }
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
                loggedInUserId: loggedInUserId ?? (routeSettings.arguments as int),
              );
            } catch (e) {
              return const SplashScreen();
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
          case MegaAdminHomePage.routeName:
            if (routeSettings.arguments == null) {
              return const SplashScreen();
            }
            var megaAdminProfile = routeSettings.arguments as MegaAdminProfile;
            return MegaAdminHomePage(
              megaAdminProfile: megaAdminProfile,
            );
          case MegaAdminAllSchoolsPage.routeName:
            if (routeSettings.arguments == null) {
              return const SplashScreen();
            }
            var megaAdminProfile = routeSettings.arguments as MegaAdminProfile;
            return MegaAdminAllSchoolsPage(
              megaAdminProfile: megaAdminProfile,
            );
          case StudentProfileScreen.routeName:
            try {
              if (routeSettings.arguments is TeacherProfile) {
                var teacherProfile = routeSettings.arguments as TeacherProfile;
                return TeacherProfileScreen(
                  teacherProfile: teacherProfile,
                );
              } else if (routeSettings.arguments is AdminProfile) {
                var adminProfile = routeSettings.arguments as AdminProfile;
                return AdminProfileScreen(
                  adminProfile: adminProfile,
                );
              } else if (routeSettings.arguments is MegaAdminProfile) {
                try {
                  var argument = (routeSettings.arguments as MegaAdminProfile);
                  return MegaAdminProfileScreen(
                    megaAdminProfile: argument,
                  );
                } catch (e) {
                  return const E404NotFoundScreen();
                }
              } else {
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentProfileScreen(
                  studentProfile: argument,
                );
              }
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case AdminBusOptionsScreen.routeName:
            try {
              if (routeSettings.arguments is TeacherProfile) {
                var teacherProfile = routeSettings.arguments as TeacherProfile;
                return const E404NotFoundScreen();
              } else if (routeSettings.arguments is AdminProfile) {
                var adminProfile = routeSettings.arguments as AdminProfile;
                return AdminBusOptionsScreen(
                  adminProfile: adminProfile,
                );
              } else if (routeSettings.arguments is StudentProfile) {
                var studentProfile = routeSettings.arguments as StudentProfile;
                return StudentBusScreen(
                  studentProfile: studentProfile,
                );
              } else {
                var argument = (routeSettings.arguments as StudentProfile);
                return const E404NotFoundScreen();
              }
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case PayslipsOptionsScreen.routeName:
            try {
              if (routeSettings.arguments is TeacherProfile) {
                var teacherProfile = routeSettings.arguments as TeacherProfile;
                return const E404NotFoundScreen();
              } else if (routeSettings.arguments is AdminProfile) {
                var adminProfile = routeSettings.arguments as AdminProfile;
                return PayslipsOptionsScreen(
                  adminProfile: adminProfile,
                );
              } else if (routeSettings.arguments is StudentProfile) {
                var argument = (routeSettings.arguments as StudentProfile);
                return const E404NotFoundScreen();
              } else {
                return const E404NotFoundScreen();
              }
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case LogbookScreen.routeName:
            try {
              if (routeSettings.arguments is TeacherProfile) {
                var teacherProfile = routeSettings.arguments as TeacherProfile;
                return LogbookScreen(
                  teacherProfile: teacherProfile,
                  adminProfile: null,
                );
              } else if (routeSettings.arguments is AdminProfile) {
                var adminProfile = routeSettings.arguments as AdminProfile;
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
                var studentProfile = routeSettings.arguments as StudentProfile;
                return StudentDiaryScreen(
                  studentProfile: studentProfile,
                );
              } else if (routeSettings.arguments is TeacherProfile) {
                var teacherProfile = routeSettings.arguments as TeacherProfile;
                return DiaryEditScreen(
                  teacherProfile: teacherProfile,
                  adminProfile: null,
                );
              } else if (routeSettings.arguments is AdminProfile) {
                var adminProfile = routeSettings.arguments as AdminProfile;
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
          case TeacherFeedbackScreen.routeName:
            try {
              if (routeSettings.arguments is StudentProfile) {
                var studentProfile = routeSettings.arguments as StudentProfile;
                return StudentFeedbackScreen(
                  studentProfile: studentProfile,
                );
              } else if (routeSettings.arguments is TeacherProfile) {
                var teacherProfile = routeSettings.arguments as TeacherProfile;
                return TeacherFeedbackScreen(
                  teacherProfile: teacherProfile,
                );
              } else if (routeSettings.arguments is AdminProfile) {
                var adminProfile = routeSettings.arguments as AdminProfile;
                return AdminFeedbackScreen(
                  adminProfile: adminProfile,
                );
              } else {
                return const E404NotFoundScreen();
              }
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case AdminManageOnlineClassRoomsScreen.routeName:
            try {
              if (routeSettings.arguments is StudentProfile) {
                var studentProfile = routeSettings.arguments as StudentProfile;
                return StudentOnlineClassroomScreen(
                  studentProfile: studentProfile,
                );
              } else if (routeSettings.arguments is TeacherProfile) {
                var teacherProfile = routeSettings.arguments as TeacherProfile;
                return TeacherOnlineClassroomScreen(
                  teacherProfile: teacherProfile,
                );
              } else if (routeSettings.arguments is AdminRouteWithParams<String>) {
                var routeArgument = (routeSettings.arguments! as AdminRouteWithParams<String>);
                switch (routeArgument.params![0]) {
                  case "Manage Online Class Rooms":
                    return AdminManageOnlineClassRoomsScreen(
                      adminProfile: routeArgument.adminProfile,
                    );
                  case "Monitor Online Class Rooms":
                    return AdminMonitorOnlineClassRoomsScreen(
                      adminProfile: routeArgument.adminProfile,
                    );
                  default:
                    const E404NotFoundScreen();
                }
              } else if (routeSettings.arguments is AdminProfile) {
                AdminProfile adminProfile = routeSettings.arguments as AdminProfile;
                return AdminOnlineClassRoomsOptionsScreen(
                  adminProfile: adminProfile,
                );
              }
              return const E404NotFoundScreen();
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case AdminSuggestionBox.routeName:
            try {
              if (routeSettings.arguments is StudentProfile) {
                var studentProfile = routeSettings.arguments as StudentProfile;
                return StudentSuggestionBoxView(
                  studentProfile: studentProfile,
                );
              } else if (routeSettings.arguments is AdminProfile) {
                var adminProfile = routeSettings.arguments as AdminProfile;
                return AdminSuggestionBox(
                  adminProfile: adminProfile,
                );
              } else if (routeSettings.arguments is MegaAdminProfile) {
                var megaAdminProfile = routeSettings.arguments as MegaAdminProfile;
                return MegaAdminSuggestionBox(
                  megaAdminProfile: megaAdminProfile,
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
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentAttendanceViewScreen(
                  studentProfile: argument,
                );
              }
              if (routeSettings.arguments is TeacherProfile) {
                var argument = (routeSettings.arguments as TeacherProfile);
                return TeacherAttendanceTimeslots(
                  teacherProfile: argument,
                );
              } else {
                var argument = (routeSettings.arguments as AdminProfile);
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
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentNoticeBoardView(
                  studentProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if (routeSettings.arguments is TeacherProfile) {
              try {
                var argument = (routeSettings.arguments as TeacherProfile);
                return TeacherNoticeBoardView(
                  teacherProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if (routeSettings.arguments is MegaAdminProfile) {
              try {
                var argument = (routeSettings.arguments as MegaAdminProfile);
                return MegaAdminNoticeBoardScreen(
                  megaAdminProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else {
              try {
                var argument = (routeSettings.arguments as AdminProfile);
                return AdminNoticeBoardScreen(
                  adminProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            }
          case AdminCircularsScreen.routeName:
            if (routeSettings.arguments is TeacherProfile) {
              try {
                var argument = (routeSettings.arguments as TeacherProfile);
                return TeacherCircularsScreen(
                  teacherProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if (routeSettings.arguments is MegaAdminProfile) {
              try {
                var argument = (routeSettings.arguments as MegaAdminProfile);
                return MegaAdminCircularsScreen(
                  megaAdminProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else {
              try {
                var argument = (routeSettings.arguments as AdminProfile);
                return AdminCircularsScreen(
                  adminProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            }
          case AdminLedgerScreen.routeName:
            // if (routeSettings.arguments is MegaAdminProfile) {
            //   try {
            //     var argument = (routeSettings.arguments as MegaAdminProfile);
            //     return MegaAdminCircularsScreen(
            //       megaAdminProfile: argument,
            //     );
            //   } catch (e) {
            //     return const E404NotFoundScreen();
            //   }
            // } else {
            try {
              var argument = (routeSettings.arguments as AdminProfile);
              return AdminLedgerScreen(
                adminProfile: argument,
              );
            } catch (e) {
              return const E404NotFoundScreen();
            }
          // }

          case AdminExpenseScreenAdminView.routeName:
            // if (routeSettings.arguments is MegaAdminProfile) {
            //   try {
            //     var argument = (routeSettings.arguments as MegaAdminProfile);
            //     return MegaAdminCircularsScreen(
            //       megaAdminProfile: argument,
            //     );
            //   } catch (e) {
            //     return const E404NotFoundScreen();
            //   }
            // } else {
            try {
              var argument = (routeSettings.arguments as AdminProfile);
              return AdminExpenseScreenAdminView(
                adminProfile: argument,
              );
            } catch (e) {
              return const E404NotFoundScreen();
            }
          // }
          case StudentStudyMaterialTDSScreen.routeName:
            try {
              if (routeSettings.arguments is StudentProfile) {
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentStudyMaterialTDSScreen(
                  studentProfile: argument,
                );
              } else if (routeSettings.arguments is AdminProfile) {
                var argument = (routeSettings.arguments as AdminProfile);
                return AdminStudyMaterialTDSScreen(
                  adminProfile: argument,
                );
              } else if (routeSettings.arguments is TeacherProfile) {
                var argument = (routeSettings.arguments as TeacherProfile);
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
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentTimeTableView(
                  studentProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if (routeSettings.arguments is TeacherProfile) {
              try {
                var argument = (routeSettings.arguments as TeacherProfile);
                return TeacherTimeTableView(
                  teacherProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if (routeSettings.arguments is AdminRouteWithParams<String>) {
              var routeArgument = (routeSettings.arguments! as AdminRouteWithParams<String>);
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
                  return AdminTimeTableRandomizer(adminProfile: routeArgument.adminProfile);
                case "All Teachers' Time Table Preview":
                  return TeacherTimeTablePreviewScreen(
                    adminProfile: routeArgument.adminProfile,
                    teacherProfile: null,
                    isOcr: false,
                  );
                default:
                  return AdminTimeTableOptions(
                    adminProfile: routeArgument.adminProfile,
                  );
              }
            } else {
              try {
                var argument = (routeSettings.arguments as AdminProfile);
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
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentEventsView(
                  studentProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            }
            if (routeSettings.arguments is TeacherProfile) {
              try {
                var argument = (routeSettings.arguments as TeacherProfile);
                return TeacherEventsView(
                  teacherProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else {
              try {
                var argument = (routeSettings.arguments as AdminProfile);
                return AdminEventsScreen(
                  adminProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            }
          case StudentEachEventView.routeName:
            if ((routeSettings.arguments! as List<Object>)[0] is StudentProfile) {
              try {
                var arguments = (routeSettings.arguments! as List<Object>);
                var studentProfile = arguments[0] as StudentProfile;
                var event = arguments[1] as Event;
                return StudentEachEventView(
                  studentProfile: studentProfile,
                  event: event,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if ((routeSettings.arguments! as List<Object>)[0] is TeacherProfile) {
              try {
                var arguments = (routeSettings.arguments! as List<Object>);
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
                var arguments = (routeSettings.arguments! as List<Object>);
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
              if (routeSettings.arguments is StudentProfile) {
                try {
                  var argument = (routeSettings.arguments as StudentProfile);
                  return StudentFeeScreen(
                    studentProfile: argument,
                  );
                } catch (e) {
                  return const E404NotFoundScreen();
                }
              } else {
                var adminProfile = routeSettings.arguments! as AdminProfile;
                return AdminFeeOptionsScreen(
                  adminProfile: adminProfile,
                );
              }
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case AdminExamsScreen.routeName:
            if (routeSettings.arguments is StudentProfile) {
              try {
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentExamsScreen(
                  studentProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if (routeSettings.arguments is TeacherProfile) {
              var argument = routeSettings.arguments as TeacherProfile;
              return TeacherExamTdsScreen(
                teacherProfile: argument,
              );
            } else {
              try {
                var adminProfile = routeSettings.arguments! as AdminProfile;
                return AdminExamsScreen(
                  adminProfile: adminProfile,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            }
          case AdminCreateOrManageExamsScreen.routeName:
            try {
              var adminProfile = routeSettings.arguments! as AdminProfile;
              return AdminCreateOrManageExamsScreen(
                adminProfile: adminProfile,
              );
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case AdminPublishResultsScreen.routeName:
            try {
              var adminProfile = routeSettings.arguments! as AdminProfile;
              return AdminPublishResultsScreen(
                adminProfile: adminProfile,
              );
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case AdminGradingAlgorithmsScreen.routeName:
            try {
              var adminProfile = routeSettings.arguments! as AdminProfile;
              return AdminGradingAlgorithmsScreen(
                adminProfile: adminProfile,
              );
            } catch (e) {
              return const E404NotFoundScreen();
            }
          case StudentDemoScreen.routeName:
            if (routeSettings.arguments is StudentProfile) {
              try {
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentDemoScreen(
                  studentProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else {
              return const E404NotFoundScreen();
            }
          case StudentChatRoom.routeName:
            if (routeSettings.arguments is StudentProfile) {
              try {
                var argument = (routeSettings.arguments as StudentProfile);
                return StudentChatRoom(
                  studentProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else if (routeSettings.arguments is TeacherProfile) {
              try {
                var argument = (routeSettings.arguments as TeacherProfile);
                return TeacherChatRoom(
                  teacherProfile: argument,
                );
              } catch (e) {
                return const E404NotFoundScreen();
              }
            } else {
              return const E404NotFoundScreen();
            }
          default:
            return const E404NotFoundScreen();
        }
      },
    );
  }
}
