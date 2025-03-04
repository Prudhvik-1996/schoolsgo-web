import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class CustomExamPdfView extends StatefulWidget {
  const CustomExamPdfView({
    super.key,
    required this.studentProfile,
    required this.customExam,
    required this.subjects,
    required this.schoolInfo,
  });

  final StudentProfile studentProfile;
  final CustomExam customExam;
  final List<Subject> subjects;
  final SchoolInfoBean schoolInfo;

  @override
  State<CustomExamPdfView> createState() => _CustomExamPdfViewState();
}

class _CustomExamPdfViewState extends State<CustomExamPdfView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customExam.customExamName ?? "-"),
      ),
      body: ListView(
        children: [
          Container(
            margin: MediaQuery.of(context).orientation == Orientation.landscape
                ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 20, MediaQuery.of(context).size.width / 5, 20)
                : const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              children: [
                schoolHeaderWidget(),
                const SizedBox(height: 5),
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(height: 5),
                studentNameWidget(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: rollNumberWidget()),
                    Expanded(child: sectionWidget()),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: totalMarksObtainedWidget()), Expanded(child: percentageWidget()), // Expanded(child: gradeWidget()),
                  ],
                ),
                const SizedBox(height: 10),
                marksTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget schoolHeaderWidget() {
    return Image.memory(
      const Base64Decoder().convert(widget.schoolInfo.receiptHeader!),
      fit: BoxFit.scaleDown,
    );
  }

  Widget studentNameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Name",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            widget.studentProfile.studentFirstName ?? "-",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget rollNumberWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Roll No.",
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            widget.studentProfile.rollNumber ?? "-",
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget sectionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Class",
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            widget.studentProfile.sectionName ?? "-",
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget totalMarksObtainedWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Marks",
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            "${((widget.customExam.examSectionSubjectMapList ?? []).map((e) => e?.studentExamMarksList ?? [])).expand((i) => i).map((e) => e?.marksObtained ?? 0).fold<double>(0.0, (double a, double b) => a + b)} / ${(widget.customExam.examSectionSubjectMapList ?? []).map((e) => e?.maxMarks ?? 0).fold<double>(0.0, (double a, double b) => a + b)}",
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget percentageWidget() {
    double? percentage = widget.customExam.getPercentage(widget.studentProfile.studentId!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Percentage",
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            percentage == null ? "-" : "$percentage%",
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget marksTable() {
    return Column(
      children: [
        const Divider(
          color: Colors.grey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Expanded(
              flex: 3,
              child: Text(
                "Subject",
                style: TextStyle(color: Colors.black),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  "Max Marks",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  "Marks Obtained",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
        ),
        ...[
          for (ExamSectionSubjectMap eachExamSectionSubjectMap in (widget.customExam.examSectionSubjectMapList ?? []).map((e) => e!)) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.subjects.where((e) => e.subjectId == eachExamSectionSubjectMap.subjectId).firstOrNull?.subjectName ?? "-",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "${eachExamSectionSubjectMap.maxMarks ?? " - "}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "${(eachExamSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.studentId == widget.studentProfile.studentId).firstOrNull?.marksObtained ?? " - "}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
          ]
        ],
      ],
    );
  }
}
