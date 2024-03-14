import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/stats/exam_stats_options_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/grading_algorithms/admin_grading_algorithms_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/topic_wise_exams_tds_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class AdminExamOptionsScreen extends StatefulWidget {
  const AdminExamOptionsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/exams";

  @override
  State<AdminExamOptionsScreen> createState() => _AdminExamOptionsScreenState();
}

class _AdminExamOptionsScreenState extends State<AdminExamOptionsScreen> {
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
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              padding: EdgeInsets.zero,
              primary: false,
              children: <Widget>[
                _getExamsOption(
                  "Topic Wise Exams",
                  null,
                  TopicWiseExamsTdsScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: null,
                    selectedAcademicYearId: selectedAcademicYearId,
                  ),
                ),
                _getExamsOption(
                  "Exams Without Internals",
                  null,
                  CustomExamsScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: null,
                    selectedAcademicYearId: selectedAcademicYearId,
                  ),
                ),
                _getExamsOption(
                  "Exams With Internals",
                  null,
                  FAExamsScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: null,
                    selectedAcademicYearId: selectedAcademicYearId,
                  ),
                ),
                _getExamsOption(
                  "Exam Stats",
                  null,
                  ExamStatsOptionsScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: null,
                    selectedAcademicYearId: selectedAcademicYearId,
                  ),
                ),
                _getExamsOption(
                  "Manage Marking Algorithm",
                  null,
                  AdminGradingAlgorithmsScreen(
                    adminProfile: widget.adminProfile,
                  ),
                ),
              ],
            ),
    );
  }
}
