import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentFeeScreen extends StatefulWidget {
  const StudentFeeScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  @override
  State<StudentFeeScreen> createState() => _StudentFeeScreenState();
}

class _StudentFeeScreenState extends State<StudentFeeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fee"),
        actions: [
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: ListView(
        children: [],
      ),
    );
  }
}
