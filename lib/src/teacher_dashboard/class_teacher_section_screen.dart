import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
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
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final Section section;
  final int selectedAcademicYearId;

  @override
  State<ClassTeacherSectionScreen> createState() => _ClassTeacherSectionScreenState();
}

class _ClassTeacherSectionScreenState extends State<ClassTeacherSectionScreen> {
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
      body: ListView(
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
