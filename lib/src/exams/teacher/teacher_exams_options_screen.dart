import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/topic_wise_exams_tds_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherExamOptionsScreen extends StatefulWidget {
  const TeacherExamOptionsScreen({
    Key? key,
    required this.teacherProfile,
  }) : super(key: key);

  final TeacherProfile teacherProfile;
  static const routeName = "/exams";

  @override
  State<TeacherExamOptionsScreen> createState() => _TeacherExamOptionsScreenState();
}

class _TeacherExamOptionsScreenState extends State<TeacherExamOptionsScreen> {
  late int selectedAcademicYearId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID')!;
    setState(() => _isLoading = false);
  }

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
        title: const Text("Exams"),
      ),
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
      ),
      body: _isLoading
          ? Center(
        child: Image.asset(
          'assets/images/eis_loader.gif',
          height: 500,
          width: 500,
        ),
      )
          : ListView(
        padding: EdgeInsets.zero,
        primary: false,
        children: <Widget>[
          _getExamsOption(
            "Topic Wise Exams",
            null,
            TopicWiseExamsTdsScreen(
              adminProfile: null,
              teacherProfile: widget.teacherProfile,
              selectedAcademicYearId: selectedAcademicYearId,
            ),
          ),
          _getExamsOption(
            "Exams Without Internals",
            null,
            CustomExamsScreen(
              adminProfile: null,
              teacherProfile: widget.teacherProfile,
              selectedAcademicYearId: selectedAcademicYearId,
            ),
          ),
          _getExamsOption(
            "Exams With Internals",
            null,
            FAExamsScreen(
              adminProfile: null,
              teacherProfile: widget.teacherProfile,
              selectedAcademicYearId: selectedAcademicYearId,
            ),
          ),
        ],
      ),
    );
  }
}
