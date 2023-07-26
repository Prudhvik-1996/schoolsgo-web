import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/student/model/student_exams.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class StudentExamsScreen extends StatefulWidget {
  const StudentExamsScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;
  static const routeName = "/exams";

  @override
  State<StudentExamsScreen> createState() => _StudentExamsScreenState();
}

class _StudentExamsScreenState extends State<StudentExamsScreen> {
  bool _isLoading = true;

  late int selectedAcademicYearId;

  List<CustomExam> customExams = [];
  List<TopicWiseExam> topicWiseExams = [];

  List<int> examIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID')!;

    GetStudentWiseExamsResponse getStudentWiseExamsResponse = await getStudentWiseExams(GetStudentWiseExamsRequest(
      schoolId: widget.studentProfile.schoolId,
      academicYearId: selectedAcademicYearId,
      studentIds: [widget.studentProfile.studentId],
    ));
    if (getStudentWiseExamsResponse.httpStatus != "OK" || getStudentWiseExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      customExams = (getStudentWiseExamsResponse.customExams ?? []).map((e) => e!).toList();
      topicWiseExams = (getStudentWiseExamsResponse.topicWiseExams ?? []).map((e) => e!).toList();
      examIds = [...topicWiseExams.map((e) => e.examId), ...customExams.map((e) => e.customExamId)].where((e) => e != null).map((e) => e!).toList()
        ..sort()
        ..reversed;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Exams",
        ),
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
        children: [
          ...examIds.map((int eachExamId) {
            CustomExam? customExam = customExams.where((e) => e.customExamId == eachExamId).firstOrNull;
            TopicWiseExam? topicWiseExam = topicWiseExams.where((e) => e.examId == eachExamId).firstOrNull;
            if (customExam != null) {
              return getCustomExamView(customExam);
            }
            if (topicWiseExam != null) {
              return getTopicWiseExamView(topicWiseExam);
            }
            return const Text("--");
          }),
        ],
      ),
    );
  }

  Widget getCustomExamView(CustomExam eachCustomExam) {
    return Text(eachCustomExam.customExamName ?? "-");
  }

  Widget getTopicWiseExamView(TopicWiseExam eachTopicWiseExam) {
    return Text(eachTopicWiseExam.examName ?? "-");
  }
}
