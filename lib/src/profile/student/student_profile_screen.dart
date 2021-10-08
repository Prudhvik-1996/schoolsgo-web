import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key, required this.studentProfile})
      : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/profile";

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        controller: ScrollController(),
        children: const [Text("Profile")],
      ),
    );
  }
}
