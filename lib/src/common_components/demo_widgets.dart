import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class DemoWidget<T> {
  DemoWidget({
    this.image,
    this.title,
    this.argument,
    this.subWidgets,
    this.demoFile,
    this.description,
  });

  Widget? image;
  String? title;
  T? argument;
  List<DemoWidget<dynamic>>? subWidgets;
  String? demoFile;
  String? description;
}

List<DemoWidget<StudentProfile>> studentDemoWidgets(StudentProfile studentProfile) {
  print("HERE HERE");
  return [
      DemoWidget(
        image: SvgPicture.asset("assets/images/profile.svg"),
        title: "Profile",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/notice_board.svg"),
        title: "Notice Board",
        argument: studentProfile,
        demoFile: "assets/demo/student/notice_board/notice_board.pdf",
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/diary.svg"),
        title: "Diary",
        argument: studentProfile,
        demoFile: "assets/demo/student/diary/diary.pdf",
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/timetable.svg"),
        title: "Time Table",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/attendance.svg"),
        title: "Attendance",
        argument: studentProfile,
        description: "Student Attendance",
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/exams.svg"),
        title: "Exam",
        argument: studentProfile,
        subWidgets: [
          DemoWidget(
            title: "Exam Time Table",
            argument: studentProfile,
          ),
          DemoWidget(
            title: "Exam Marks",
            argument: studentProfile,
          ),
        ],
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/study_material.svg"),
        title: "Study Material",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/events.svg"),
        title: "Events",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/onlineclassroom.svg"),
        title: "Online Class Room",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/feedback.svg"),
        title: "Feedback",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/complainbox.svg"),
        title: "Suggestion Box",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/chat_room.svg"),
        title: "Chat Room",
        argument: studentProfile,
      ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/fee.svg"),
        title: "Fee",
        argument: studentProfile,
      ),
      if (((studentProfile.isAssignedToBusStop ?? false) || 1 != 1))
        DemoWidget(
          image: SvgPicture.asset("assets/images/bus.svg"),
          title: "Bus",
          argument: studentProfile,
        ),
      DemoWidget(
        image: SvgPicture.asset("assets/images/demo.svg"),
        title: "Demo",
        argument: studentProfile,
      ),
    ];
}
