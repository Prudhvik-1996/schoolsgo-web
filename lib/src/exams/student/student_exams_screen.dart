import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/student/student_exam_summary_widget.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentExamsScreen extends StatefulWidget {
  const StudentExamsScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;
  static const routeName = "/exams";

  @override
  State<StudentExamsScreen> createState() => _StudentExamsScreenState();
}

class _StudentExamsScreenState extends State<StudentExamsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Exams",
        ),
      ),
      body: StudentExamSummaryWidget(
        adminProfile: null,
        studentProfile: widget.studentProfile,
      ),
    );
  }
}
