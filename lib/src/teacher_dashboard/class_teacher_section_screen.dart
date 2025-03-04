import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/stats/fees/due_reports_screen.dart';
import 'package:schoolsgo_web/src/student_information_center/student_information_center_students_list_screen.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/class_teacher_exams_options_screen.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/class_techer_attendance_options_screen.dart';

class ClassTeacherSectionScreen extends StatefulWidget {
  const ClassTeacherSectionScreen({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.section,
    required this.selectedAcademicYearId,
    this.studentsList,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final Section section;
  final int selectedAcademicYearId;
  final List<StudentProfile>? studentsList;

  @override
  State<ClassTeacherSectionScreen> createState() => _ClassTeacherSectionScreenState();
}

class _ClassTeacherSectionScreenState extends State<ClassTeacherSectionScreen> {
  bool _isLoading = true;
  List<StudentProfile> studentsList = [];

  @override
  void initState() {
    super.initState();
    studentsList = widget.studentsList ?? [];
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    if (studentsList.isEmpty) {
      GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
        sectionId: widget.section.sectionId,
      ));
      if (getStudentProfileResponse.httpStatus != "OK") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        return;
      } else {
        setState(() {
          studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
          studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Widget _getClassOption(String title, String? description, StatefulWidget nextWidget) {
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
        elevation: 0,
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : widget.adminProfile != null
              ? AdminAppDrawer(adminProfile: widget.adminProfile!)
              : widget.teacherProfile != null
                  ? TeacherAppDrawer(teacherProfile: widget.teacherProfile!)
                  : null,
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                EisStandardHeader(
                  title: ClayText(
                    widget.section.sectionName ?? " - ",
                    size: 32,
                    textColor: Colors.blueGrey,
                    spread: 2,
                  ),
                ),
                _getClassOption(
                  "Attendance",
                  null,
                  ClassTeacherAttendanceOptionsScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    section: widget.section,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                  ),
                ),
                _getClassOption(
                  "Fee Dues",
                  null,
                  DueReportsScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    defaultSelectedSection: widget.section,
                  ),
                ),
                if (widget.teacherProfile != null)
                  _getClassOption(
                    "Exams",
                    null,
                    ClassTeacherExamsOptionScreen(
                      teacherProfile: widget.teacherProfile!,
                      section: widget.section,
                      selectedAcademicYearId: widget.selectedAcademicYearId,
                    ),
                  ),
                _getClassOption(
                  "Student Information Center",
                  null,
                  StudentInformationCenterStudentsListScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    defaultSection: widget.section,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }
}
