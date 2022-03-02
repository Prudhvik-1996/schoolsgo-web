import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminGradingAlgorithmsScreen extends StatefulWidget {
  const AdminGradingAlgorithmsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/grading_algorithms";

  @override
  _AdminGradingAlgorithmsScreenState createState() =>
      _AdminGradingAlgorithmsScreenState();
}

class _AdminGradingAlgorithmsScreenState
    extends State<AdminGradingAlgorithmsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grading Algorithms"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
    );
  }
}
