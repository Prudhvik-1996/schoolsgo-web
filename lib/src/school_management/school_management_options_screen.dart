import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/admin_employee_attendance_management_screen.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/employee_login_credentials.dart';
import 'package:schoolsgo_web/src/school_management/employees_management_screen.dart';
import 'package:schoolsgo_web/src/school_management/section_info_screen.dart';
import 'package:schoolsgo_web/src/school_management/student_login_credentials.dart';
import 'package:schoolsgo_web/src/school_management/student_management_screen.dart';
import 'package:schoolsgo_web/src/school_management/student_promotion_screen.dart';
import 'package:schoolsgo_web/src/school_management/student_section_migration_screen.dart';
import 'package:schoolsgo_web/src/school_management/subjects_info_screen.dart';

class SchoolManagementOptionsScreen extends StatefulWidget {
  const SchoolManagementOptionsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/school_management";

  @override
  State<SchoolManagementOptionsScreen> createState() => _SchoolManagementOptionsScreenState();
}

class _SchoolManagementOptionsScreenState extends State<SchoolManagementOptionsScreen> {
  bool _isLoading = true;
  late SchoolInfoBean schoolInfoBean;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfoBean = getSchoolsResponse.schoolInfo!;
    }
    setState(() => _isLoading = false);
  }

  Widget _getStudentManagementOption(String title, String? description, StatefulWidget nextWidget) {
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
        title: const Text("School Management"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              padding: EdgeInsets.zero,
              primary: false,
              children: <Widget>[
                _getStudentManagementOption(
                  "Student Management",
                  null,
                  StudentManagementScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
                _getStudentManagementOption(
                  "Student Section Migration",
                  null,
                  StudentSectionMigrationScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
                if (schoolInfoBean.promotedSchoolId != null)
                  _getStudentManagementOption(
                    "Student Promotion",
                    null,
                    StudentPromotionScreen(
                      adminProfile: widget.adminProfile,
                    ),
                  ),
                _getStudentManagementOption(
                  "Sections Info",
                  null,
                  SectionInfoScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
                _getStudentManagementOption(
                  "Subjects Info",
                  null,
                  SubjectInfoScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
                _getStudentManagementOption(
                  "Employees Management",
                  null,
                  EmployeesManagementScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
                _getStudentManagementOption(
                  "Employees Attendance Management",
                  null,
                  AdminEmployeeAttendanceManagementScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
                _getStudentManagementOption(
                  "Student Login Credentials",
                  null,
                  StudentLoginCredentials(
                    adminProfile: widget.adminProfile,
                  ),
                ),
                _getStudentManagementOption(
                  "Employees Login Credentials",
                  null,
                  EmployeesLoginCredentialsScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
              ],
            ),
    );
  }
}
