import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/exams/admin/exams_v2/fa_exam_v2_widget.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

import '../../../model/subjects.dart';

class DeletedExamsScreen extends StatefulWidget {
  const DeletedExamsScreen({
    super.key,
    required this.schoolInfo,
    required this.adminProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.studentsList,
    required this.markingAlgorithms,
    required this.examMemoHeader,
  });

  final SchoolInfoBean schoolInfo;
  final AdminProfile adminProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final List<StudentProfile> studentsList;
  final List<MarkingAlgorithmBean> markingAlgorithms;
  final String? examMemoHeader;

  @override
  State<DeletedExamsScreen> createState() => _DeletedExamsScreenState();
}

class _DeletedExamsScreenState extends State<DeletedExamsScreen> {
  bool _isLoading = true;
  List<FAExam> deletedExams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetFAExamsResponse getFAExamsResponse = await getFAExamsWithStats(GetFAExamsRequest(
      schoolId: widget.adminProfile.schoolId,
      status: 'inactive',
    ));
    if (getFAExamsResponse.httpStatus != "OK" || getFAExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      deletedExams = (getFAExamsResponse.exams ?? []).map((e) => e!).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deleted Exams"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : deletedExams.isEmpty
              ? const Center(child: Text("No deleted exams here.."))
              : ListView(
                  children: [
                    ...deletedExams.map(
                      (faExam) => faExamWidget(faExam),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
    );
  }

  Widget faExamWidget(FAExam faExam) {
    return FaExamV2Widget(
      schoolInfo: widget.schoolInfo,
      adminProfile: widget.adminProfile,
      sectionsList: widget.sectionsList,
      teachersList: widget.teachersList,
      subjectsList: widget.subjectsList,
      tdsList: widget.tdsList,
      exam: faExam,
      studentsList: widget.studentsList,
      editingEnabled: false,
      selectedSection: null,
      markingAlgorithms: widget.markingAlgorithms,
      showMoreOptions: false,
      examMemoHeader: widget.examMemoHeader,
    );
  }
}
