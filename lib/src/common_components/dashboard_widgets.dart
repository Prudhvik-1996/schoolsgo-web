import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolsgo_web/src/attendance/student/student_attendance_view_screen.dart';
import 'package:schoolsgo_web/src/circulars/admin/admin_circulars_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/admin_exams_options_screen.dart';
import 'package:schoolsgo_web/src/exams/teacher/teacher_exams_options_screen.dart';
import 'package:schoolsgo_web/src/logbook/logbook_screen.dart';
import 'package:schoolsgo_web/src/mega_admin/mega_admin_all_schools_page.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/notice_board/student/student_notice_board_view.dart';
import 'package:schoolsgo_web/src/online_class_room/admin/admin_manage_online_class_rooms_screen.dart';
import 'package:schoolsgo_web/src/suggestion_box/admin/admin_suggestion_box.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/class_teacher_screen.dart';
import 'package:schoolsgo_web/src/time_table/student/student_time_table_view.dart';

class DashboardWidget<T> {
  DashboardWidget({
    this.image,
    this.title,
    this.routeName,
    this.argument,
    this.subWidgets,
    this.description,
  });

  Widget? image;
  String? title;
  String? routeName;
  T? argument;
  List<DashboardWidget<dynamic>>? subWidgets;
  String? description;
}

class AdminRouteWithParams<T> {
  AdminProfile adminProfile;
  String? routeName;
  List<T>? params;

  AdminRouteWithParams({
    required this.adminProfile,
    this.routeName,
    this.params,
  });
}

List<DashboardWidget<StudentProfile>> studentDashBoardWidgets(StudentProfile studentProfile) => [
      DashboardWidget(
        image: SvgPicture.asset("assets/images/profile.svg"),
        title: "Profile",
        routeName: "/profile",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/notice_board.svg"),
        title: "Notice Board",
        routeName: StudentNoticeBoardView.routeName,
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/diary.svg"),
        title: "Diary",
        routeName: "/diary",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/timetable.svg"),
        title: "Time Table",
        routeName: StudentTimeTableView.routeName,
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/attendance.svg"),
        title: "Attendance",
        routeName: StudentAttendanceViewScreen.routeName,
        argument: studentProfile,
        description: "Student Attendance",
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/study_material.svg"),
        title: "Study Material",
        routeName: "/study_material",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/exams.svg"),
        title: "Exams",
        routeName: "/exams",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/events.svg"),
        title: "Events",
        routeName: "/events",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/onlineclassroom.svg"),
        title: "Online Class Room",
        routeName: "/onlineclassroom",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/feedback.svg"),
        title: "Feedback",
        routeName: "/feedback",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/complainbox.svg"),
        title: "Suggestion Box",
        routeName: "/suggestion_box",
        argument: studentProfile,
      ),
      // DashboardWidget(
      //   image: SvgPicture.asset("assets/images/chat_room.svg"),
      //   title: "Chat Room",
      //   routeName: StudentChatRoom.routeName,
      //   argument: studentProfile,
      // ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/fee.svg"),
        title: "Fee",
        routeName: "/fee",
        argument: studentProfile,
      ),
      if (((studentProfile.isAssignedToBusStop ?? false) || 1 != 1))
        DashboardWidget(
          image: SvgPicture.asset("assets/images/bus.svg"),
          title: "Bus",
          routeName: "/bus",
          argument: studentProfile,
        ),
      // DashboardWidget(
      //   image: SvgPicture.asset("assets/images/student_management.svg"),
      //   title: "Stats",
      //   routeName: "/student_information_center",
      //   argument: studentProfile,
      // ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/demo.svg"),
        title: "Demo",
        routeName: "/demo",
        argument: studentProfile,
      ),
    ];

List<DashboardWidget<TeacherProfile>> teacherDashBoardWidgets(TeacherProfile teacherProfile) => [
      DashboardWidget(
        image: SvgPicture.asset("assets/images/profile.svg"),
        title: "Profile",
        routeName: "/profile",
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/notice_board.svg"),
        title: "Notice Board",
        routeName: StudentNoticeBoardView.routeName,
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/circulars.svg"),
        title: "Circulars",
        routeName: AdminCircularsScreen.routeName,
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/diary.svg"),
        title: "Diary",
        routeName: "/diary",
        argument: teacherProfile,
      ),
      if ((teacherProfile.classTeacherFor ?? []).isNotEmpty)
        DashboardWidget(
          image: SvgPicture.asset("assets/images/logbook.svg"),
          title: "Class Teacher",
          routeName: ClassTeacherScreen.routeName,
          argument: teacherProfile,
        ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/logbook.svg"),
        title: "Log Book",
        routeName: LogbookScreen.routeName,
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/timetable.svg"),
        title: "Time Table",
        routeName: StudentTimeTableView.routeName,
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/attendance.svg"),
        title: "Attendance",
        routeName: StudentAttendanceViewScreen.routeName,
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/exams.svg"),
        title: "Exams",
        routeName: TeacherExamOptionsScreen.routeName,
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/study_material.svg"),
        title: "Study Material",
        routeName: "/study_material",
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/events.svg"),
        title: "Events",
        routeName: "/events",
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/onlineclassroom.svg"),
        title: "Online Class Room",
        routeName: "/onlineclassroom",
        argument: teacherProfile,
      ),
      // DashboardWidget(
      //   image: SvgPicture.asset("assets/images/chat_room.svg"),
      //   title: "Chat Room",
      //   routeName: StudentChatRoom.routeName,
      //   argument: teacherProfile,
      // ),
      // TODO We shall implement based on suggestions
      // DashboardWidget(
      //   image: SvgPicture.asset("assets/images/feedback.svg"),
      //   title: "Feedback",
      //   routeName: "/feedback",
      //   argument: teacherProfile,
      // ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/academic_planner.svg"),
        title: "Academic Planner",
        routeName: "/academic_planner",
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/demo.svg"),
        title: "Demo",
        routeName: "/demo",
        argument: teacherProfile,
      ),
    ];

List<DashboardWidget<OtherUserRoleProfile>> receptionistDashBoardWidgets(OtherUserRoleProfile receptionistProfile) => [
      DashboardWidget(
        image: SvgPicture.asset("assets/images/admin_expenses.svg"),
        title: "Admin Expenses",
        routeName: "/admin_expenses",
        argument: receptionistProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/fee.svg"),
        title: "Fee",
        routeName: "/fee",
        argument: receptionistProfile,
      ),
    ];

List<DashboardWidget<AdminProfile>> adminDashBoardWidgets(AdminProfile adminProfile) => [
      DashboardWidget(
        image: SvgPicture.asset("assets/images/profile.svg"),
        title: "Profile",
        routeName: "/profile",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/notice_board.svg"),
        title: "Notice Board",
        routeName: StudentNoticeBoardView.routeName,
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/circulars.svg"),
        title: "Circulars",
        routeName: AdminCircularsScreen.routeName,
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/diary.svg"),
        title: "Diary",
        routeName: "/diary",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/logbook.svg"),
        title: "Log Book",
        routeName: LogbookScreen.routeName,
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/timetable.svg"),
        title: "Time Table",
        routeName: StudentTimeTableView.routeName,
        argument: adminProfile,
        subWidgets: [
          DashboardWidget<AdminRouteWithParams<String>>(
            title: "Teacher Dealing Sections",
            routeName: StudentTimeTableView.routeName,
            argument: AdminRouteWithParams<String>(
              adminProfile: adminProfile,
              routeName: StudentTimeTableView.routeName,
              params: ["Teacher Dealing Sections"],
            ),
          ),
          DashboardWidget<AdminRouteWithParams<String>>(
            title: "Time Table",
            routeName: StudentTimeTableView.routeName,
            argument: AdminRouteWithParams<String>(
              adminProfile: adminProfile,
              routeName: StudentTimeTableView.routeName,
              params: ["Time Table"],
            ),
          ),
          if (!adminProfile.isMegaAdmin)
            DashboardWidget<AdminRouteWithParams<String>>(
              title: "Automatic Time Table Generation",
              routeName: StudentTimeTableView.routeName,
              argument: AdminRouteWithParams<String>(
                adminProfile: adminProfile,
                routeName: StudentTimeTableView.routeName,
                params: ["Automatic Time Table Generation"],
              ),
            ),
          DashboardWidget<AdminRouteWithParams<String>>(
            title: "All Teachers' Time Table Preview",
            routeName: StudentTimeTableView.routeName,
            argument: AdminRouteWithParams<String>(
              adminProfile: adminProfile,
              routeName: StudentTimeTableView.routeName,
              params: ["All Teachers' Time Table Preview"],
            ),
          ),
        ],
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/attendance.svg"),
        title: "Attendance",
        routeName: StudentAttendanceViewScreen.routeName,
        argument: adminProfile,
      ),
      // DashboardWidget(
      //   image: SvgPicture.asset("assets/images/bell_notification.svg"),
      //   title: "Notifications",
      //   routeName: AdminNotificationsScreen.routeName,
      //   argument: adminProfile,
      // ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/exams.svg"),
        title: "Exams",
        routeName: AdminExamOptionsScreen.routeName,
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/study_material.svg"),
        title: "Study Material",
        routeName: "/study_material",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/events.svg"),
        title: "Events",
        routeName: "/events",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/onlineclassroom.svg"),
        title: "Online Class Room",
        routeName: "/onlineclassroom",
        argument: adminProfile,
        subWidgets: [
          DashboardWidget<AdminRouteWithParams<String>>(
            title: "Manage Online Class Rooms",
            routeName: AdminManageOnlineClassRoomsScreen.routeName,
            argument: AdminRouteWithParams<String>(
              adminProfile: adminProfile,
              routeName: AdminManageOnlineClassRoomsScreen.routeName,
              params: ["Manage Online Class Rooms"],
            ),
          ),
          DashboardWidget<AdminRouteWithParams<String>>(
            title: "Monitor Online Class Rooms",
            routeName: AdminManageOnlineClassRoomsScreen.routeName,
            argument: AdminRouteWithParams<String>(
              adminProfile: adminProfile,
              routeName: AdminManageOnlineClassRoomsScreen.routeName,
              params: ["Monitor Online Class Rooms"],
            ),
          ),
        ],
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/feedback.svg"),
        title: "Feedback",
        routeName: "/feedback",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/complainbox.svg"),
        title: "Suggestion Box",
        routeName: "/suggestion_box",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/fee.svg"),
        title: "Fee",
        routeName: "/fee",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/bus.svg"),
        title: "Bus",
        routeName: "/bus",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/ledger.svg"),
        title: "Ledger",
        routeName: "/ledger",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/admin_expenses.svg"),
        title: "Admin Expenses",
        routeName: "/admin_expenses",
        argument: adminProfile,
      ),
      if (adminProfile.schoolId == 91)
        DashboardWidget(
          image: SvgPicture.asset("assets/images/payslips.svg"),
          title: "Sms",
          routeName: "/sms",
          argument: adminProfile,
        ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/payslips.svg"),
        title: "Payslips",
        routeName: "/payslips",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/stats.svg"),
        title: "Stats",
        routeName: "/stats",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/student_management.svg"),
        title: "School Management",
        routeName: "/school_management",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/student_info.svg"),
        title: "Student Information Center",
        routeName: "/student_information_center",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/academic_planner.svg"),
        title: "Academic Planner",
        routeName: "/academic_planner",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/hostel_management.svg"),
        title: "Hostels",
        routeName: "/hostels",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/task_management.svg"),
        title: "Task Management",
        routeName: "/task_management",
        argument: adminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/demo.svg"),
        title: "Demo",
        routeName: "/demo",
        argument: adminProfile,
      ),
    ];
// Profile, Notice Board, Diary, Time table, Attendance, Exam, Study Material, Events, Online Class Room, Feedback, Suggestion Box, Fee, Demo

List<DashboardWidget<MegaAdminProfile>> megaAdminDashBoardWidgets(MegaAdminProfile megaAdminProfile) => [
      DashboardWidget(
        image: SvgPicture.asset("assets/images/profile.svg"),
        title: "Profile",
        routeName: "/profile",
        argument: megaAdminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/notice_board.svg"),
        title: "Notice Board",
        routeName: StudentNoticeBoardView.routeName,
        argument: megaAdminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/circulars.svg"),
        title: "Circulars",
        routeName: AdminCircularsScreen.routeName,
        argument: megaAdminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/complainbox.svg"),
        title: "Suggestion Box",
        routeName: AdminSuggestionBox.routeName,
        argument: megaAdminProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/school.svg"),
        title: "All schools",
        routeName: MegaAdminAllSchoolsPage.routeName,
        argument: megaAdminProfile,
      ),
    ];
