import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/exams/admin/generate_memos/generate_memos.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentMemoScreen extends StatefulWidget {
  const StudentMemoScreen({
    Key? key,
    required this.adminProfile,
    required this.studentProfile,
    required this.exam,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final StudentProfile studentProfile;
  final CustomExam exam;

  @override
  State<StudentMemoScreen> createState() => _StudentMemoScreenState();
}

class _StudentMemoScreenState extends State<StudentMemoScreen> {
  bool _isLoading = true;
  Uint8List? memo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    List<int> memoBytes = await downloadMemosForMainExamWithInternals(GenerateStudentMemosRequest(
        schoolId: widget.studentProfile.schoolId,
        studentIds: [widget.studentProfile.studentId],
        sectionId: widget.studentProfile.sectionId,
        studentPhotoSize: "S",
        mainExamId: widget.exam.customExamId,
        showAttendanceTable: false,
        showGraph: true,
        showRemarks: true,
        showHeader: true,
        otherExamIds: [],
        otherSubjectIds: []));
    memo = Uint8List.fromList(memoBytes);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.exam.customExamName ?? " - "} Memo"),
      ),
      body: bildMemoChildWidget(context),
    );
  }

  Widget bildMemoChildWidget(BuildContext context) {
    if (_isLoading) {
      return const EpsilonDiaryLoadingWidget(
        defaultLoadingText: "Loading memo",
      );
    }
    if (memo == null) {
      return const Center(child: Text("Memo not found!"));
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: PdfPreview(
        build: (format) => memo!,
        pdfFileName: "Exams Memo - ${widget.exam.customExamName ?? " - "}",
        canDebug: false,
        actions: [],
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        loadingWidget: const EpsilonDiaryLoadingWidget(),
        padding: const EdgeInsets.all(0),
      ),
    );
  }
}
