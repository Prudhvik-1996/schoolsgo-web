import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolsgo_web/src/attendance/student_attendance_view_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/notice_board/notice_board_view.dart';
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
  List<DashboardWidget<T>>? subWidgets;
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
        routeName: NoticeBoardView.routeName,
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
        image: SvgPicture.asset("assets/images/notice_board.svg"),
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
        title: "Complain Box",
        routeName: "/complainbox",
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

// Profile, Notice Board, Diary, Time table, Attendance, Exam, Study Material, Events, Online Class Room, Feedback, Complain Box, Fee, Demo
