import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class EmployeeEnrollmentFormScreen extends StatefulWidget {
  const EmployeeEnrollmentFormScreen({
    super.key,
    required this.employeeProfile,
    required this.adminProfile,
    required this.isEditMode,
  });

  final SchoolWiseEmployeeBean employeeProfile;
  final AdminProfile adminProfile;
  final bool isEditMode;

  @override
  State<EmployeeEnrollmentFormScreen> createState() => _EmployeeEnrollmentFormScreenState();
}

class _EmployeeEnrollmentFormScreenState extends State<EmployeeEnrollmentFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.employeeProfile.employeeId == null
            ? const Text(
                "New Employee",
              )
            : Text(
                widget.employeeProfile.employeeName?.capitalize() ?? "-",
              ),
      ),
      body: ListView(
        children: [],
      ),
    );
  }
}
