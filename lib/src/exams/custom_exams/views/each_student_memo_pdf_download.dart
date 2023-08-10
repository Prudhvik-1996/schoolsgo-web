import 'dart:convert';
import 'dart:html' as html;

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class EachStudentMemoPdfDownload {
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

  late double totalMaxMarks;
  late double totalMarksObtained;
  late double totalPercentage;

  EachStudentMemoPdfDownload({
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
  }) {
    customExam.examSectionSubjectMapList?.removeWhere((e) => e?.sectionId != selectedSection.sectionId);
    customExam.examSectionSubjectMapList?.sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return (subjectsList.where((es) => es.subjectId == a.subjectId).firstOrNull?.seqOrder ?? 0)
          .compareTo((subjectsList.where((es) => es.subjectId == b.subjectId).firstOrNull?.seqOrder ?? 0));
    });
    customExam.examSectionSubjectMapList?.forEach((essm) {
      essm?.studentExamMarksList?.removeWhere((esm) => esm?.studentId != studentProfile.studentId);
    });
    totalMaxMarks = customExam.examSectionSubjectMapList?.map((e) => e?.maxMarks ?? 0.0).fold<double>(0.0, (double a, double b) => a + b) ?? 0.0;
    totalMarksObtained = customExam.examSectionSubjectMapList
            ?.map((e) => (e?.studentExamMarksList ?? []).firstOrNull?.marksObtained ?? 0.0)
            .fold<double>(0.0, (double a, double b) => a + b) ??
        0.0;
    totalPercentage = totalMarksObtained * 100.0 / totalMaxMarks;
  }

  Future<void> downloadMemo() async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const EdgeInsets.all(32),
      build: (context) {
        return [
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(color: PdfColors.grey),
            //   borderRadius: BorderRadius.circular(5),
            // ),
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                if (schoolInfo.examMemoHeader != null)
                  Image(
                    MemoryImage(
                      const Base64Decoder().convert(schoolInfo.examMemoHeader!),
                    ),
                    fit: BoxFit.scaleDown,
                  ),
                if (schoolInfo.examMemoHeader != null) SizedBox(height: 10),
                if (schoolInfo.examMemoHeader != null) Divider(color: PdfColors.grey, thickness: 1.0),
                Row(
                  children: [
                    Text("Student Name:"),
                    Expanded(child: Text(studentProfile.studentFirstName ?? "-")),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Class:"),
                          Expanded(child: Text(studentProfile.sectionName ?? "-")),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Roll No.:"),
                          Expanded(child: Text(studentProfile.rollNumber ?? "-")),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Admission No.:"),
                    Expanded(child: Text(studentProfile.admissionNo ?? "-")),
                  ],
                ),
                if (studentProfile.fatherName != null) SizedBox(height: 10),
                if (studentProfile.fatherName != null)
                  Row(
                    children: [
                      Text("Father Name:"),
                      Expanded(child: Text(studentProfile.fatherName ?? "-")),
                    ],
                  ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Exam Name:"),
                    Expanded(child: Text(customExam.customExamName ?? "-")),
                  ],
                ),
                SizedBox(height: 10),
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        paddedText("Subject"),
                        paddedText("Max Marks", textAlign: TextAlign.center),
                        paddedText("Marks Obtained", textAlign: TextAlign.center),
                        if (markingAlgorithm != null && (markingAlgorithm?.isGpaAllowed ?? false)) paddedText("GPA", textAlign: TextAlign.center),
                        if (markingAlgorithm != null && (markingAlgorithm?.isGradeAllowed ?? false)) paddedText("Grade", textAlign: TextAlign.center),
                      ],
                    ),
                    ...?customExam.examSectionSubjectMapList?.whereNotNull().map((essm) {
                      StudentExamMarks? marks = essm.studentExamMarksList
                          ?.whereNotNull()
                          .where((esm) => esm.examSectionSubjectMapId == essm.examSectionSubjectMapId)
                          .firstOrNull;
                      double percentage = (((marks?.marksObtained ?? 0) / (essm.maxMarks ?? 0)) * 100);
                      return TableRow(children: [
                        paddedText(subjectsList.where((es) => essm.subjectId == es.subjectId).firstOrNull?.subjectName ?? "-"),
                        paddedText("${essm.maxMarks ?? "-"}", textAlign: TextAlign.center),
                        paddedText("${marks?.marksObtained ?? "-"}", textAlign: TextAlign.center),
                        if (markingAlgorithm != null && (markingAlgorithm?.isGpaAllowed ?? false))
                          paddedText("${markingAlgorithm?.gpaForPercentage(percentage) ?? "-"}", textAlign: TextAlign.center),
                        if (markingAlgorithm != null && (markingAlgorithm?.isGradeAllowed ?? false))
                          paddedText(markingAlgorithm?.gradeForPercentage(percentage) ?? "-", textAlign: TextAlign.center),
                      ]);
                    })
                  ],
                ),
                SizedBox(height: 10),
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        "Max. Marks",
                        "Marks Obtained",
                        "Percentage",
                        if (markingAlgorithm?.isGpaAllowed ?? false) "GPA",
                        if (markingAlgorithm?.isGradeAllowed ?? false) "Grade"
                      ]
                          .map(
                            (e) => paddedText(e, textAlign: TextAlign.center),
                          )
                          .toList(),
                    ),
                    TableRow(
                      children: [
                        "$totalMaxMarks",
                        "$totalMarksObtained",
                        "${doubleToStringAsFixed(totalPercentage)} %",
                        if (markingAlgorithm?.isGpaAllowed ?? false) "${markingAlgorithm?.gpaForPercentage(totalPercentage) ?? "-"}",
                        if (markingAlgorithm?.isGradeAllowed ?? false) markingAlgorithm?.gradeForPercentage(totalPercentage) ?? "-"
                      ]
                          .map(
                            (e) => paddedText(e, textAlign: TextAlign.center),
                          )
                          .toList(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Table(
                //   border: TableBorder.all(),
                //   children: [
                //     TableRow(
                //       decoration: const BoxDecoration(
                //         color: PdfColors.grey100,
                //       ),
                //       children: [
                //         "Jun\n23",
                //         "Jul\n23",
                //         "Aug\n23",
                //         "Sep\n23",
                //         "Oct\n23",
                //         "Nov\n23",
                //         "Dec\n23",
                //         "Jan\n24",
                //         "Feb\n24",
                //         "Mar\n24",
                //         "Apr\n24",
                //         "May\n24"
                //       ].map((e) => paddedText(e, textAlign: TextAlign.center)).toList(),
                //     ),
                //     TableRow(
                //       decoration: const BoxDecoration(
                //         color: PdfColors.white,
                //       ),
                //       children: [
                //         "Jun\n23",
                //         "Jul\n23",
                //         "Aug\n23",
                //         "Sep\n23",
                //         "Oct\n23",
                //         "Nov\n23",
                //         "Dec\n23",
                //         "Jan\n24",
                //         "Feb\n24",
                //         "Mar\n24",
                //         "Apr\n24",
                //         "May\n24"
                //       ].map((e) => paddedText("\n\n")).toList(),
                //     ),
                //   ],
                // ),
                SizedBox(height: 150),
                Row(
                  children: [
                    Text("Class Teacher"),
                    Expanded(
                      child: Center(child: Text("Principal", textAlign: TextAlign.center)),
                    ),
                    Text("Parent", textAlign: TextAlign.right),
                  ],
                ),
              ],
            ),
          ),
        ];
      },
    ));

    var x = await pdf.save();
    final blob = html.Blob([x], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.target = '_blank';
    anchorElement.download = "${studentProfile.sectionName} ${studentProfile.rollNumber ?? ""} ${studentProfile.studentFirstName}.pdf";
    anchorElement.click();
  }

  Widget paddedText(String text, {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: textAlign,
      ),
    );
  }
}
