import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/employee/employee_attendance_screen.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({
    Key? key,
    required this.teacherProfile,
  }) : super(key: key);

  final TeacherProfile teacherProfile;

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  bool isLoading = true;
  late SchoolWiseEmployeeBean employeeBean;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest(
      schoolId: widget.teacherProfile.schoolId,
      employeeId: widget.teacherProfile.teacherId,
    ));
    if (getSchoolWiseEmployeesResponse.httpStatus != "OK" || getSchoolWiseEmployeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employeeBean = (getSchoolWiseEmployeesResponse.employees ?? []).map((e) => e!).toList().first;
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: Image.asset(
              'assets/images/eis_loader.gif',
              height: 500,
              width: 500,
            ),
          )
        : EmployeeAttendanceScreen(
            employeeBean: employeeBean,
          );
  }
}
