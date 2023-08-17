import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/each_student_memo_pdf_download.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

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
    required this.customExam,
    required this.studentProfile,
    required this.selectedSection,
  }) : super(key: key);

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final MarkingAlgorithmBean? markingAlgorithm;
  final CustomExam customExam;
  final StudentProfile studentProfile;
  final Section selectedSection;

  @override
  State<EachStudentMemoView> createState() => _EachStudentMemoViewState();
}

class _EachStudentMemoViewState extends State<EachStudentMemoView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  late CustomExam customExam;

  late double totalMaxMarks;
  late double? totalMarksObtained;
  late double? totalPercentage;
  ImageProvider? studentImage;
  late bool isAbsentForAtLeastForOneSubject;
  late bool isFailInAtLeastForOneSubject;

  @override
  void initState() {
    super.initState();
    customExam = CustomExam.fromJson(widget.customExam.toJson());
    customExam.examSectionSubjectMapList?.removeWhere((e) => e?.sectionId != widget.selectedSection.sectionId);
    customExam.examSectionSubjectMapList?.forEach((essm) {
      essm?.studentExamMarksList?.removeWhere((esm) => esm?.studentId != widget.studentProfile.studentId);
    });
    totalMaxMarks = customExam.examSectionSubjectMapList?.map((e) => e?.maxMarks ?? 0.0).fold<double>(0.0, (double a, double b) => a + b) ?? 0.0;
    totalMarksObtained = customExam.examSectionSubjectMapList
        ?.map((e) => (e?.studentExamMarksList ?? []).firstOrNull)
        .where((e) => e?.isAbsent != "Y")
        .map((e) => e?.marksObtained)
        .whereNotNull()
        .fold<double>(0.0, (double a, double b) => a + b);
    totalPercentage = totalMarksObtained == null ? null : (totalMarksObtained! * 100.0 / totalMaxMarks);
    isAbsentForAtLeastForOneSubject =
        customExam.examSectionSubjectMapList?.map((e) => (e?.studentExamMarksList ?? []).firstOrNull).where((e) => e?.isAbsent == "N").isNotEmpty ??
            true;
    isFailInAtLeastForOneSubject = customExam.examSectionSubjectMapList
            ?.map((ExamSectionSubjectMap? e) => (e?.studentExamMarksList ?? []))
            .expand((i) => i)
            .where((StudentExamMarks? e) => e?.isAbsent != "N")
            .map((StudentExamMarks? e) => widget.markingAlgorithm?.rangeBeanForPercentage((e?.marksObtained ?? 0) /
                ((customExam.examSectionSubjectMapList ?? [])
                        .where((essm) => e?.examSectionSubjectMapId == essm?.examSectionSubjectMapId)
                        .first
                        ?.maxMarks ??
                    1)))
            .map((MarkingAlgorithmRangeBean? e) => e?.isFailure == "Y")
            .contains(true) ??
        false;
    studentImage = widget.studentProfile.studentPhotoUrl == null ? null : NetworkImage(widget.studentProfile.studentPhotoUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.studentProfile.studentFirstName ?? "-"),
          actions: [
            IconButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                await EachStudentMemoPdfDownload(
                  schoolInfo: widget.schoolInfo,
                  adminProfile: widget.adminProfile,
                  teacherProfile: widget.teacherProfile,
                  selectedAcademicYearId: widget.selectedAcademicYearId,
                  teachersList: widget.teachersList,
                  subjectsList: widget.subjectsList,
                  tdsList: widget.tdsList,
                  markingAlgorithm: widget.markingAlgorithm,
                  customExam: customExam,
                  studentProfiles: [widget.studentProfile],
                  selectedSection: widget.selectedSection,
                  updateMessage: (String? e) => debugPrint(e),
                ).downloadMemo();
                setState(() => _isLoading = false);
              },
              icon: const Icon(Icons.download),
            ),
          ],
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
                          if (widget.schoolInfo.examMemoHeader != null)
                            Image(
                              image: MemoryImage(
                                const Base64Decoder().convert(widget.schoolInfo.examMemoHeader!),
                              ),
                              fit: BoxFit.scaleDown,
                            ),
                          if (widget.schoolInfo.examMemoHeader != null) const SizedBox(height: 10),
                          if (widget.schoolInfo.examMemoHeader != null) const Divider(color: Colors.grey, thickness: 1.0),
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
                                "Report of ${customExam.customExamName ?? "-"}",
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
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: paddedText("Max Marks", textAlign: TextAlign.center),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: paddedText("Marks Obtained", textAlign: TextAlign.center),
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
                              ...?(customExam.examSectionSubjectMapList?.whereNotNull().toList()
                                    ?..sort((a, b) {
                                      Subject? aSubject = widget.subjectsList.where((es) => es.subjectId == a.subjectId).firstOrNull;
                                      Subject? bSubject = widget.subjectsList.where((es) => es.subjectId == b.subjectId).firstOrNull;
                                      return (aSubject?.seqOrder ?? 0).compareTo(bSubject?.seqOrder ?? 0);
                                    }))
                                  ?.map((essm) {
                                Subject? eachSubject = widget.subjectsList.where((es) => essm.subjectId == es.subjectId).firstOrNull;
                                StudentExamMarks? marks = essm.studentExamMarksList
                                    ?.whereNotNull()
                                    .where((esm) =>
                                        esm.examSectionSubjectMapId == essm.examSectionSubjectMapId &&
                                        esm.studentId == widget.studentProfile.studentId)
                                    .firstOrNull;
                                double? percentage = marks == null || marks.marksObtained == null || marks.isAbsent == "N"
                                    ? null
                                    : (((marks.marksObtained!) / (essm.maxMarks ?? 0)) * 100);
                                return TableRow(
                                  children: [
                                    TableCell(
                                      child: Row(
                                        children: [
                                          Expanded(child: paddedText(eachSubject?.subjectName ?? "-")),
                                        ],
                                      ),
                                    ),
                                    TableCell(child: paddedText("${essm.maxMarks ?? "-"}", textAlign: TextAlign.center)),
                                    TableCell(
                                        child: paddedText("${marks?.isAbsent == "N" ? "Absent" : marks?.marksObtained ?? "-"}",
                                            textAlign: TextAlign.center)),
                                    if (widget.markingAlgorithm != null && (widget.markingAlgorithm?.isGpaAllowed ?? false))
                                      TableCell(
                                        child: paddedText(
                                          percentage == null ? "-" : "${widget.markingAlgorithm?.gpaForPercentage(percentage) ?? "-"}",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    if (widget.markingAlgorithm != null && (widget.markingAlgorithm?.isGradeAllowed ?? false))
                                      TableCell(
                                        child: paddedText(
                                          percentage == null ? "-" : widget.markingAlgorithm?.gradeForPercentage(percentage) ?? "-",
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
                                  "${doubleToStringAsFixed(totalPercentage)} %",
                                  if (widget.markingAlgorithm?.isGpaAllowed ?? false)
                                    isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject
                                        ? "-"
                                        : totalPercentage == null
                                            ? "-"
                                            : "${widget.markingAlgorithm?.gpaForPercentage(totalPercentage!) ?? "-"}",
                                  if (widget.markingAlgorithm?.isGradeAllowed ?? false)
                                    isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject
                                        ? "-"
                                        : totalPercentage == null
                                            ? "-"
                                            : widget.markingAlgorithm?.gradeForPercentage(totalPercentage!) ?? "-"
                                ]
                                    .map(
                                      (e) => TableCell(
                                        child: paddedText(e, textAlign: TextAlign.center),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
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
