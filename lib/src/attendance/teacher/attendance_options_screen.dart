import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/teacher/teacher_attendance_time_slots_screen.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/employee_attendance/employee/employee_mark_attendance_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class TeacherAttendanceOptionsScreen extends StatefulWidget {
  const TeacherAttendanceOptionsScreen({
    Key? key,
    required this.teacherProfile,
  }) : super(key: key);

  final TeacherProfile teacherProfile;

  @override
  State<TeacherAttendanceOptionsScreen> createState() => _TeacherAttendanceOptionsScreenState();
}

class _TeacherAttendanceOptionsScreenState extends State<TeacherAttendanceOptionsScreen> {
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
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : TeacherAppDrawer(
              teacherProfile: widget.teacherProfile,
            ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.zero,
            primary: false,
            children: <Widget>[
              _getAttendanceOption(
                "Student Attendance",
                null,
                TeacherAttendanceTimeslots(
                  teacherProfile: widget.teacherProfile,
                ),
              ),
              _getAttendanceOption(
                "Employee Attendance",
                null,
                EmployeeMarkAttendanceScreen(
                  employeeId: widget.teacherProfile.teacherId!,
                  schoolId: widget.teacherProfile.schoolId!,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
