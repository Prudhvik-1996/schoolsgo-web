import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class EachStudentMemoView extends StatefulWidget {
  const EachStudentMemoView({
    Key? key,
    required this.schoolInfo,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.markingAlgorithm,
    required this.faExam,
    required this.studentProfile,
    required this.selectedSection,
    required this.examMemoHeader,
  }) : super(key: key);

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final MarkingAlgorithmBean? markingAlgorithm;
  final FAExam faExam;
  final StudentProfile studentProfile;
  final Section selectedSection;
  final String? examMemoHeader;

  @override
  State<EachStudentMemoView> createState() => _EachStudentMemoViewState();
}

class _EachStudentMemoViewState extends State<EachStudentMemoView> {
  bool _isLoading = true;

  late FAExam faExamForStudent;

  late double totalMaxMarks;
  late double? totalMarksObtained;
  late double? totalPercentage;
  ImageProvider? studentImage;
  late bool isAbsentForAtLeastForOneSubject;
  late bool isFailInAtLeastForOneSubject;

  @override
  void initState() {
    super.initState();
    faExamForStudent = FAExam.fromJson(widget.faExam.toJson());
    faExamForStudent.faInternalExams ??= [];
    for (FaInternalExam? ei in faExamForStudent.faInternalExams!) {
      ei!.examSectionSubjectMapList ??= [];
      ei.examSectionSubjectMapList!.removeWhere((essm) => essm?.sectionId != widget.selectedSection.sectionId);
      for (ExamSectionSubjectMap? essm in ei.examSectionSubjectMapList!) {
        essm!.studentExamMarksList ??= [];
        essm.studentExamMarksList!.removeWhere((esm) => esm?.studentId != widget.studentProfile.studentId);
      }
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      studentImage = widget.studentProfile.studentPhotoUrl == null ? null : NetworkImage(widget.studentProfile.studentPhotoUrl!);
    });
    totalMaxMarks = (faExamForStudent.faInternalExams ?? [])
        .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
        .expand((i) => i)
        .map((e) => e.maxMarks ?? 0.0)
        .fold<double>(0.0, (double a, double b) => a + b);
    totalMarksObtained = (faExamForStudent.faInternalExams ?? [])
        .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
        .expand((i) => i)
        .map((e) => (e.studentExamMarksList ?? []).firstOrNull)
        .where((e) => e?.isAbsent != "N")
        .map((e) => e?.marksObtained)
        .whereNotNull()
        .fold<double>(0.0, (double a, double b) => a + b);
    totalPercentage = totalMarksObtained == null ? null : (totalMarksObtained! * 100.0 / totalMaxMarks);
    isAbsentForAtLeastForOneSubject = (faExamForStudent.faInternalExams ?? [])
        .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
        .expand((i) => i)
        .map((e) => (e.studentExamMarksList ?? []).firstOrNull)
        .where((e) => e?.isAbsent == "N")
        .isNotEmpty;
    if ([100].contains(widget.schoolInfo.schoolId)) {
      List<double?> subjectWisePercentages = [];
      for (Subject eachSubject in widget.subjectsList.where((es) =>
          faExamForStudent.faInternalExams
              ?.map((ei) => (ei?.examSectionSubjectMapList ?? []).map((essm) => essm?.subjectId))
              .expand((i) => i)
              .contains(es.subjectId) ??
          false)) {
        double marksObtainedPerSubject = 0.0;
        double maxMarksPerSubject = 0.0;
        (faExamForStudent.faInternalExams ?? [])
            .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
            .expand((i) => i)
            .where((ExamSectionSubjectMap? e) => e?.subjectId == eachSubject.subjectId)
            .map((ExamSectionSubjectMap? e) => (e?.studentExamMarksList ?? []))
            .expand((i) => i)
            .where((StudentExamMarks? e) => e?.isAbsent != "N")
            .forEach((StudentExamMarks? e) {
          marksObtainedPerSubject += (e?.marksObtained ?? 0);
          maxMarksPerSubject += (((faExamForStudent.faInternalExams ?? [])
                  .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
                  .expand((i) => i)).where((essm) => e?.examSectionSubjectMapId == essm.examSectionSubjectMapId).first.maxMarks ??
              1);
        });
        if (maxMarksPerSubject != 0) {
          subjectWisePercentages.add(marksObtainedPerSubject * 100 / maxMarksPerSubject);
        } else {
          subjectWisePercentages.add(null);
        }
      }
      isFailInAtLeastForOneSubject = subjectWisePercentages.contains(null) ||
          subjectWisePercentages.map((percentage) => widget.markingAlgorithm?.rangeBeanForPercentage(percentage!)?.isFailure == "Y").contains(true);
    } else {
      isFailInAtLeastForOneSubject = (faExamForStudent.faInternalExams ?? [])
          .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
          .expand((i) => i)
          .map((ExamSectionSubjectMap? e) => (e?.studentExamMarksList ?? []))
          .expand((i) => i)
          .where((StudentExamMarks? e) => e?.isAbsent != "N")
          .map((StudentExamMarks? e) {
            double percentage = (e?.marksObtained ?? 0) /
                (((faExamForStudent.faInternalExams ?? []).map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull()).expand((i) => i))
                        .where((essm) => e?.examSectionSubjectMapId == essm.examSectionSubjectMapId)
                        .first
                        .maxMarks ??
                    1) *
                100;
            MarkingAlgorithmRangeBean? rangeBeanForPercentage = widget.markingAlgorithm?.rangeBeanForPercentage(percentage);
            return rangeBeanForPercentage;
          })
          .map((MarkingAlgorithmRangeBean? e) => e?.isFailure == "Y")
          .contains(true);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.studentProfile.studentFirstName ?? "-"),
        ),
        body: _isLoading
            ? const EpsilonDiaryLoadingWidget()
            : ListView(
                children: [
                  Padding(
                    padding: MediaQuery.of(context).orientation == Orientation.portrait
                        ? const EdgeInsets.fromLTRB(0, 10, 0, 10)
                        : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          if (widget.examMemoHeader != null)
                            Image(
                              image: MemoryImage(
                                const Base64Decoder().convert(widget.examMemoHeader!),
                              ),
                              fit: BoxFit.scaleDown,
                            ),
                          if (widget.examMemoHeader != null) const SizedBox(height: 10),
                          if (widget.examMemoHeader != null) const Divider(color: Colors.grey, thickness: 1.0),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        const Text("Student Name: "),
                                        Expanded(child: Text(widget.studentProfile.studentFirstName ?? "-")),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text("Class: "),
                                              Expanded(child: Text(widget.studentProfile.sectionName ?? "-")),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text("Roll No.: "),
                                              Expanded(child: Text(widget.studentProfile.rollNumber ?? "-")),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text("Admission No.: "),
                                        Expanded(child: Text(widget.studentProfile.admissionNo ?? "-")),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (studentImage != null) const SizedBox(width: 10),
                              if (studentImage != null) Image(image: studentImage!, height: 100, width: 75, fit: BoxFit.scaleDown),
                            ],
                          ),
                          if (widget.studentProfile.fatherName != null) const SizedBox(height: 10),
                          if (widget.studentProfile.fatherName != null)
                            Row(
                              children: [
                                const Text("Father Name: "),
                                Expanded(child: Text(widget.studentProfile.fatherName ?? "-")),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Report of ${faExamForStudent.faExamName ?? "-"}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                ),
                                children: [
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: paddedText("Subject"),
                                  ),
                                  ...(faExamForStudent.faInternalExams ?? []).map(
                                    (e) {
                                      return TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: paddedText(e?.faInternalExamName ?? " - ", textAlign: TextAlign.center),
                                      );
                                    },
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: paddedText("Total", textAlign: TextAlign.center),
                                  ),
                                  if (widget.markingAlgorithm != null && (widget.markingAlgorithm?.isGpaAllowed ?? false))
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: paddedText("GPA", textAlign: TextAlign.center),
                                    ),
                                  if (widget.markingAlgorithm != null && (widget.markingAlgorithm?.isGradeAllowed ?? false))
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: paddedText("Grade", textAlign: TextAlign.center),
                                    ),
                                ],
                              ),
                              ...(faExamForStudent.faInternalExams ?? [])
                                  .map((e) => (e?.examSectionSubjectMapList ?? []))
                                  .expand((i) => i)
                                  .map((e) => e?.subjectId)
                                  .toSet()
                                  .map((esid) => widget.subjectsList.where((es) => es.subjectId == esid).firstOrNull)
                                  .whereNotNull()
                                  .sorted((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0))
                                  .map((eachSubject) {
                                print("293: ${eachSubject.subjectName}");
                                List<ExamSectionSubjectMap> internalsEssms = (faExamForStudent.faInternalExams ?? [])
                                    .map((e) => e?.examSectionSubjectMapList ?? [])
                                    .expand((i) => i)
                                    .whereNotNull()
                                    .where((essm) => essm.subjectId == eachSubject.subjectId)
                                    .toList();
                                List<StudentExamMarks?> examMarksForSubject = [];
                                for (FaInternalExam? eachInternal in faExamForStudent.faInternalExams ?? []) {
                                  ExamSectionSubjectMap? essmForSubject =
                                      eachInternal?.examSectionSubjectMapList?.where((essm) => essm?.subjectId == eachSubject.subjectId).firstOrNull;
                                  print("303: $essmForSubject");
                                  if (essmForSubject == null) {
                                    examMarksForSubject.add(null);
                                  } else {
                                    StudentExamMarks? esm = (essmForSubject.studentExamMarksList ?? [])
                                        .where((esm) => esm?.studentId == widget.studentProfile.studentId)
                                        .firstOrNull;
                                    print("309: $esm");
                                    examMarksForSubject.add(esm);
                                  }
                                }
                                print("311: ${examMarksForSubject.length}");
                                double? totalMarksObtained = examMarksForSubject.contains(null) ||
                                        examMarksForSubject.where((esm) => esm?.marksObtained == null || esm?.isAbsent == "N").isNotEmpty
                                    ? null
                                    : examMarksForSubject
                                        .whereNotNull()
                                        .map((e) => e.marksObtained)
                                        .whereNotNull()
                                        .fold(0.0, (double? a, b) => (a ?? 0.0) + b);
                                // double? totalMaxMarks = internalsEssms
                                //     .map((e) => e.maxMarks)
                                //     .whereNotNull()
                                //     .fold(0.0, (double? a, b) => (a ?? 0.0) + b);
                                double totalMaxMarks = 0;
                                for (ExamSectionSubjectMap essm in internalsEssms) {
                                  totalMaxMarks += (essm.maxMarks ?? 0);
                                  print("330: $totalMaxMarks");
                                }
                                print("311: ${internalsEssms.length} $totalMarksObtained / $totalMaxMarks");

                                return TableRow(
                                  children: [
                                    TableCell(
                                      child: Row(
                                        children: [
                                          Expanded(child: paddedText(eachSubject.subjectName ?? "-")),
                                        ],
                                      ),
                                    ),
                                    ...examMarksForSubject.map((esm) {
                                      double? maxMarks =
                                          internalsEssms.where((e) => (e.studentExamMarksList ?? []).contains(esm)).firstOrNull?.maxMarks;
                                      return paddedTextForMarksObtained(esm, maxMarks);
                                    }),
                                    TableCell(
                                      child: paddedText(
                                        (totalMarksObtained == null || (totalMaxMarks) == 0) ? "-" : "$totalMarksObtained",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    if (widget.markingAlgorithm != null && (widget.markingAlgorithm?.isGpaAllowed ?? false))
                                      TableCell(
                                        child: paddedText(
                                          (totalMarksObtained == null || (totalMaxMarks) == 0)
                                              ? "-"
                                              : "${widget.markingAlgorithm?.gpaForPercentage(totalMarksObtained * 100 / totalMaxMarks!) ?? "-"}",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    if (widget.markingAlgorithm != null && (widget.markingAlgorithm?.isGradeAllowed ?? false))
                                      TableCell(
                                        child: paddedText(
                                          (totalMarksObtained == null || (totalMaxMarks) == 0)
                                              ? "-"
                                              : widget.markingAlgorithm?.gradeForPercentage(totalMarksObtained * 100 / totalMaxMarks!) ?? "-",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                ),
                                children: [
                                  "Max. Marks",
                                  "Marks Obtained",
                                  "Percentage",
                                  if (widget.markingAlgorithm?.isGpaAllowed ?? false) "GPA",
                                  if (widget.markingAlgorithm?.isGradeAllowed ?? false) "Grade"
                                ]
                                    .map(
                                      (e) => TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.middle,
                                        child: paddedText(e, textAlign: TextAlign.center),
                                      ),
                                    )
                                    .toList(),
                              ),
                              TableRow(
                                children: [
                                  "$totalMaxMarks",
                                  "$totalMarksObtained",
                                  widget.schoolInfo.schoolId == 100 && (isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject)
                                      ? "-"
                                      : "${doubleToStringAsFixed(totalPercentage)} %",
                                  if (widget.markingAlgorithm?.isGpaAllowed ?? false)
                                    widget.schoolInfo.schoolId == 100 && (isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject)
                                        ? "-"
                                        : totalPercentage == null
                                            ? "-"
                                            : "${widget.markingAlgorithm?.gpaForPercentage(totalPercentage!) ?? "-"}",
                                  if (widget.markingAlgorithm?.isGradeAllowed ?? false)
                                    widget.schoolInfo.schoolId == 100 && (isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject)
                                        ? "-"
                                        : totalPercentage == null
                                            ? "-"
                                            : widget.markingAlgorithm?.gradeForPercentage(totalPercentage!) ?? "-",
                                ]
                                    .map(
                                      (e) => TableCell(
                                        child: paddedText(e, textAlign: TextAlign.center),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget paddedTextForMarksObtained(StudentExamMarks? esm, double? maxMarks) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: esm?.isAbsent == "N"
          ? const Text(
              "Absent",
              textAlign: TextAlign.center,
            )
          : esm?.marksObtained == null
              ? const Text(
                  "-",
                  textAlign: TextAlign.center,
                )
              : maxMarks == null
                  ? Text(
                      "${esm?.marksObtained}",
                      textAlign: TextAlign.center,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${esm?.marksObtained}",
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          " / $maxMarks",
                          style: const TextStyle(fontSize: 9),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ), // "${esm?.isAbsent == "N" ? "Absent" : esm?.marksObtained ?? "-"}",
    );
  }

  Widget paddedText(String text, {TextAlign textAlign = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: textAlign,
      ),
    );
  }
}
