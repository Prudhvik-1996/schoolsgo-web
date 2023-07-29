import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/student/model/student_exams.dart';
import 'package:schoolsgo_web/src/exams/student/views/custom_exam_view.dart';
import 'package:schoolsgo_web/src/exams/student/views/topic_wise_exam_view.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<Subject> subjectsList = [];

  late SchoolInfoBean schoolInfo;

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

    GetSubjectsRequest getSubjectsRequest = GetSubjectsRequest(schoolId: widget.studentProfile.schoolId);
    GetSubjectsResponse getSubjectsResponse = await getSubjects(getSubjectsRequest);

    if (getSubjectsResponse.httpStatus == "OK" && getSubjectsResponse.responseStatus == "success") {
      setState(() {
        subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
      });
    }

    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.studentProfile.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfo = getSchoolsResponse.schoolInfo!;
    }

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
    double? percentage = eachCustomExam.getPercentage(widget.studentProfile.studentId!);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CustomExamView(
          studentProfile: widget.studentProfile,
          customExam: eachCustomExam,
          subjects: subjectsList,
          schoolInfo: schoolInfo,
        );
      })),
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eachCustomExam.customExamName ?? "-",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),
                Text("Percentage: ${percentage == null ? "-" : "$percentage%"}"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getTopicWiseExamView(TopicWiseExam eachTopicWiseExam) {
    double? percentage = eachTopicWiseExam.percentage(widget.studentProfile.studentId!);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TopicWiseExamView(
          studentProfile: widget.studentProfile,
          topicWiseExam: eachTopicWiseExam,
          schoolInfo: schoolInfo,
        );
      })),
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        eachTopicWiseExam.examName ?? "-",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Topic"),
                      ),
                    ),
                  ],
                ),
                Text("Percentage: ${percentage == null ? "-" : "$percentage%"}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
