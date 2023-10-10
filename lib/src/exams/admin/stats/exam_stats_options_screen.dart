import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/stats/section_wise_exams_stats_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class ExamStatsOptionsScreen extends StatefulWidget {
  const ExamStatsOptionsScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    this.defaultSelectedSection,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final Section? defaultSelectedSection;

  @override
  State<ExamStatsOptionsScreen> createState() => _AdminExamStatsOptionsScreenState();
}

class _AdminExamStatsOptionsScreenState extends State<ExamStatsOptionsScreen> {
  bool _isLoading = false;

  List<Section> sectionsList = [];
  List<Teacher> teachersList = [];
  List<Subject> subjectsList = [];

  List<CustomExam> customExams = [];
  List<FAExam> faExams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    GetSectionsResponse getSectionsResponse = await getSections(GetSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sectionsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
    }

    GetTeachersResponse getTeachersResponse = await getTeachers(
      GetTeachersRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      ),
    );
    if (getTeachersResponse.httpStatus != "OK" || getTeachersResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      teachersList = getTeachersResponse.teachers!;
    }

    GetSubjectsRequest getSubjectsRequest = GetSubjectsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    );
    GetSubjectsResponse getSubjectsResponse = await getSubjects(getSubjectsRequest);

    if (getSubjectsResponse.httpStatus != "OK" || getSubjectsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
    }

    GetCustomExamsResponse getCustomExamsResponse = await getCustomExams(GetCustomExamsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      academicYearId: widget.selectedAcademicYearId,
      teacherId: widget.defaultSelectedSection != null ? null : widget.teacherProfile?.teacherId,
    ));
    if (getCustomExamsResponse.httpStatus != "OK" || getCustomExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      customExams = (getCustomExamsResponse.customExamsList ?? []).map((e) => e!).toList();
    }

    GetFAExamsResponse getFAExamsResponse = await getFAExams(GetFAExamsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      academicYearId: widget.selectedAcademicYearId,
    ));
    if (getFAExamsResponse.httpStatus != "OK" || getFAExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      faExams = (getFAExamsResponse.exams ?? []).map((e) => e!).toList();
    }

    setState(() => _isLoading = false);
  }

  Widget _getExamStatsOption(String title, String? description, StatefulWidget nextWidget) {
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
        title: const Text("Exam Stats"),
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
                _getExamStatsOption(
                  "Class Wise Statistics",
                  null,
                  SectionWiseExamsStatsScreen(
                    sectionsList: sectionsList,
                    teachersList: teachersList,
                    subjectsList: subjectsList,
                    customExams: customExams,
                    faExams: faExams,
                  ),
                ),
              ],
            ),
    );
  }
}
