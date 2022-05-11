import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class StudentAttendanceDemoScreen extends StatefulWidget {
  const StudentAttendanceDemoScreen({Key? key}) : super(key: key);

  @override
  State<StudentAttendanceDemoScreen> createState() => _StudentAttendanceDemoScreenState();
}

class _StudentAttendanceDemoScreenState extends State<StudentAttendanceDemoScreen> {
  String viewID = "student-attendance-demo";

  @override
  Widget build(BuildContext context) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewID,
      (int id) => html.IFrameElement()
        ..src = 'assets/html/student_attendance_demo_v2.html'
        ..style.border = 'none'
        ..allowFullscreen = true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance Demo"),
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: HtmlElementView(
            viewType: viewID,
          ),
        ),
      ),
    );
  }
}
