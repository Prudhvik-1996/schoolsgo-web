import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_exams_screen.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class ClassTeacherExamsOptionScreen extends StatefulWidget {
  const ClassTeacherExamsOptionScreen({super.key,
    required this.teacherProfile,
    required this.section,
    required this.selectedAcademicYearId,
  });

  final TeacherProfile teacherProfile;
  final Section section;
  final int selectedAcademicYearId;

  @override
  State<ClassTeacherExamsOptionScreen> createState() => _ClassTeacherExamsOptionScreenState();
}

class _ClassTeacherExamsOptionScreenState extends State<ClassTeacherExamsOptionScreen> {
  Widget _getExamsOption(String title, String? description, StatefulWidget nextWidget) {
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
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
      ),
      body: ListView(
        children: [
          _getExamsOption(
            "Custom Exams",
            null,
            CustomExamsScreen(
              adminProfile: null,
              teacherProfile: widget.teacherProfile,
              selectedAcademicYearId: widget.selectedAcademicYearId,
              defaultSelectedSection: widget.section,
            ),
          ),
          _getExamsOption(
            "FA Exams",
            null,
            FAExamsScreen(
              adminProfile: null,
              teacherProfile: widget.teacherProfile,
              selectedAcademicYearId: widget.selectedAcademicYearId,
              defaultSelectedSection: widget.section,
            ),
          ),
        ],
      ),
    );
  }
}
