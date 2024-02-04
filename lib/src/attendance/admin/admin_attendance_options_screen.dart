import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_attendance_stats_screen.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/admin/admin_employee_attendance_management_screen.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_mark_student_attendance_screen.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_student_absentees_screen.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

import 'admin_attendance_management_screen.dart';

class AdminAttendanceOptionsScreen extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminAttendanceOptionsScreen({Key? key, required this.adminProfile}) : super(key: key);

  @override
  _AdminAttendanceOptionsScreenState createState() => _AdminAttendanceOptionsScreenState();
}

class _AdminAttendanceOptionsScreenState extends State<AdminAttendanceOptionsScreen> {
  Widget _getAttendanceOption(String title, String? description, StatefulWidget nextWidget) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return nextWidget;
        }));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(10), // margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: const Icon(
                    Icons.adjust,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        description ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.zero,
            primary: false,
            children: <Widget>[
              _getAttendanceOption(
                "Attendance Management",
                null,
                AdminAttendanceManagementScreen(
                  adminProfile: widget.adminProfile,
                ),
              ),
              _getAttendanceOption(
                "Mark Attendance",
                null,
                AdminMarkStudentAttendanceScreen(
                  adminProfile: widget.adminProfile,
                  teacherProfile: null,
                  selectedSection: null,
                  selectedDateTime: DateTime.now(),
                ),
              ),
              _getAttendanceOption(
                "Absentees",
                null,
                AdminStudentAbsenteesScreen(
                  adminProfile: widget.adminProfile,
                  teacherProfile: null,
                  defaultSelectedSection: null,
                ),
              ),
              _getAttendanceOption(
                "Attendance Stats",
                null,
                AdminStudentAttendanceStatsScreen(
                  adminProfile: widget.adminProfile,
                  teacherProfile: null,
                  defaultSelectedSection: null,
                ),
              ),
              _getAttendanceOption(
                "Employees Attendance Management",
                null,
                AdminEmployeeAttendanceManagementScreen(
                  adminProfile: widget.adminProfile,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
