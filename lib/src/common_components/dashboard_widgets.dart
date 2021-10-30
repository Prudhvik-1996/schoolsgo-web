import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolsgo_web/src/attendance/student/student_attendance_view_screen.dart';
import 'package:schoolsgo_web/src/logbook/logbook_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/notice_board/student/student_notice_board_view.dart';
import 'package:schoolsgo_web/src/time_table/student/student_time_table_view.dart';

class DashboardWidget<T> {
  DashboardWidget({
    this.image,
    this.title,
    this.routeName,
    this.argument,
    this.subWidgets,
  });
  Widget? image;
  String? title;
  String? routeName;
  T? argument;
  List<DashboardWidget<dynamic>>? subWidgets;
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

List<DashboardWidget<StudentProfile>> studentDashBoardWidgets(
        StudentProfile studentProfile) =>
    [
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
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/exams.svg"),
        title: "Exam",
        routeName: "/exam",
        argument: studentProfile,
        subWidgets: [
          DashboardWidget(
            title: "Exam Time Table",
            routeName: "/exam_time_table",
            argument: studentProfile,
          ),
          DashboardWidget(
            title: "Exam Marks",
            routeName: "/exam_marks",
            argument: studentProfile,
          ),
        ],
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/study_material.svg"),
        title: "Study Material",
        routeName: "/study_material",
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
      DashboardWidget(
        image: SvgPicture.asset("assets/images/fee.svg"),
        title: "Fee",
        routeName: "/fee",
        argument: studentProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/demo.svg"),
        title: "Demo",
        routeName: "/demo",
        argument: studentProfile,
      ),
    ];

List<DashboardWidget<TeacherProfile>> teacherDashBoardWidgets(
        TeacherProfile teacherProfile) =>
    [
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
        image: SvgPicture.asset("assets/images/diary.svg"),
        title: "Diary",
        routeName: "/diary",
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
        title: "Exam",
        routeName: "/exam",
        argument: teacherProfile,
        subWidgets: [
          DashboardWidget(
            title: "Exam Time Table",
            routeName: "/exam_time_table",
            argument: teacherProfile,
          ),
          DashboardWidget(
            title: "Exam Marks",
            routeName: "/exam_marks",
            argument: teacherProfile,
          ),
        ],
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
      DashboardWidget(
        image: SvgPicture.asset("assets/images/feedback.svg"),
        title: "Feedback",
        routeName: "/feedback",
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/complainbox.svg"),
        title: "Suggestion Box",
        routeName: "/suggestion_box",
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/fee.svg"),
        title: "Fee",
        routeName: "/fee",
        argument: teacherProfile,
      ),
      DashboardWidget(
        image: SvgPicture.asset("assets/images/demo.svg"),
        title: "Demo",
        routeName: "/demo",
        argument: teacherProfile,
      ),
    ];

List<DashboardWidget<AdminProfile>> adminDashBoardWidgets(
        AdminProfile adminProfile) =>
    [
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
            title: "Section Wise Time Slots Management",
            routeName: StudentTimeTableView.routeName,
            argument: AdminRouteWithParams<String>(
              adminProfile: adminProfile,
              routeName: StudentTimeTableView.routeName,
              params: ["Section Wise Time Slots Management"],
            ),
          ),
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
      DashboardWidget(
        image: SvgPicture.asset("assets/images/exams.svg"),
        title: "Exam",
        routeName: "/exam",
        argument: adminProfile,
        subWidgets: [
          DashboardWidget(
            title: "Exam Time Table",
            routeName: "/exam_time_table",
            argument: adminProfile,
          ),
          DashboardWidget(
            title: "Exam Marks",
            routeName: "/exam_marks",
            argument: adminProfile,
          ),
        ],
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
        image: SvgPicture.asset("assets/images/demo.svg"),
        title: "Demo",
        routeName: "/demo",
        argument: adminProfile,
      ),
    ];

// Profile, Notice Board, Diary, Time table, Attendance, Exam, Study Material, Events, Online Class Room, Feedback, Suggestion Box, Fee, Demo
