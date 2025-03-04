import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/attendance_qr_widget.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class EmployeeAttendanceQRScreen extends StatefulWidget {
  const EmployeeAttendanceQRScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _EmployeeAttendanceQRScreenState createState() => _EmployeeAttendanceQRScreenState();
}

class _EmployeeAttendanceQRScreenState extends State<EmployeeAttendanceQRScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Center(
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  AttendanceQRWidget(
                    adminProfile: widget.adminProfile,
                    isStatic: false,
                  ),
                  const SizedBox(height: 20),
                  descriptionWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget descriptionWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / (MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Expanded(
            child: Text(
              'Request employees to scan the above QR to clock the attendance',
              style: TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
