import 'dart:convert';
import 'dart:html' as html;

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
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
  final List<StudentProfile> studentProfiles;
  final Section selectedSection;

  late double totalMaxMarks;
  late double? totalMarksObtained;
  late double? totalPercentage;

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
    required this.studentProfiles,
    required this.selectedSection,
  });

  Future<void> downloadMemo() async {
    final pdf = Document();

    final font = await PdfGoogleFonts.merriweatherRegular();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();

    for (StudentProfile studentProfile in studentProfiles) {
      print("57: Writing memo for ${studentProfile.rollNumber}. ${studentProfile.studentFirstName}");
      CustomExam customExamForStudent = CustomExam.fromJson(customExam.toJson());
      customExamForStudent.examSectionSubjectMapList?.removeWhere((e) => e?.sectionId != selectedSection.sectionId);
      customExamForStudent.examSectionSubjectMapList?.forEach((essm) {
        essm?.studentExamMarksList?.removeWhere((esm) => esm?.studentId != studentProfile.studentId);
      });
      totalMaxMarks =
          customExamForStudent.examSectionSubjectMapList?.map((e) => e?.maxMarks ?? 0.0).fold<double>(0.0, (double a, double b) => a + b) ?? 0.0;
      totalMarksObtained = customExamForStudent.examSectionSubjectMapList
          ?.map((e) => (e?.studentExamMarksList ?? []).firstOrNull)
          .where((e) => e?.isAbsent != "Y")
          .map((e) => e?.marksObtained)
          .whereNotNull()
          .fold<double>(0.0, (double a, double b) => a + b);
      totalPercentage = totalMarksObtained == null ? null : (totalMarksObtained! * 100.0 / totalMaxMarks);

      List<String> attendanceHeaders = ["Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "Total"];

      pdf.addPage(
        MultiPage(
          pageTheme: PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const EdgeInsets.all(32),
            buildBackground: (_) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: PdfColors.grey), // Set your preferred border color here
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          header: (_) => schoolInfo.examMemoHeader != null
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image(
                    MemoryImage(
                      const Base64Decoder().convert(schoolInfo.examMemoHeader!),
                    ),
                    fit: BoxFit.scaleDown,
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            schoolInfo.schoolDisplayName ?? "-",
                            style: TextStyle(font: schoolNameFont, fontSize: 30, color: PdfColors.blue),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            schoolInfo.detailedAddress ?? "-",
                            style: TextStyle(font: font, fontSize: 14, color: PdfColors.grey900),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          build: (context) {
            return [
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(color: PdfColors.grey),
                //   borderRadius: BorderRadius.circular(5),
                // ),
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Student Name: "),
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
                              Text("Class: "),
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
                              Text("Roll No.: "),
                              Expanded(child: Text(studentProfile.rollNumber ?? "-")),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Admission No.: "),
                        Expanded(child: Text(studentProfile.admissionNo ?? "-")),
                      ],
                    ),
                    if (studentProfile.fatherName != null) SizedBox(height: 10),
                    if (studentProfile.fatherName != null)
                      Row(
                        children: [
                          Text("Father Name: "),
                          Expanded(child: Text(studentProfile.fatherName ?? "-")),
                        ],
                      ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Report of ${customExam.customExamName ?? "-"}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
                            if (markingAlgorithm != null && (markingAlgorithm?.isGradeAllowed ?? false))
                              paddedText("Grade", textAlign: TextAlign.center),
                          ],
                        ),
                        ...?(customExamForStudent.examSectionSubjectMapList?.whereNotNull().toList()
                              ?..sort((a, b) {
                                Subject? aSubject = subjectsList.where((es) => es.subjectId == a.subjectId).firstOrNull;
                                Subject? bSubject = subjectsList.where((es) => es.subjectId == b.subjectId).firstOrNull;
                                return (aSubject?.seqOrder ?? 0).compareTo(bSubject?.seqOrder ?? 0);
                              }))
                            ?.map((essm) {
                          StudentExamMarks? marks = essm.studentExamMarksList
                              ?.whereNotNull()
                              .where(
                                  (esm) => esm.examSectionSubjectMapId == essm.examSectionSubjectMapId && esm.studentId == studentProfile.studentId)
                              .firstOrNull;
                          double? percentage = marks == null || marks.marksObtained == null || marks.isAbsent == "Y"
                              ? null
                              : (((marks.marksObtained!) / (essm.maxMarks ?? 0)) * 100);
                          return TableRow(
                            children: [
                              paddedText(subjectsList.where((es) => essm.subjectId == es.subjectId).firstOrNull?.subjectName ?? "-"),
                              paddedText("${essm.maxMarks ?? "-"}", textAlign: TextAlign.center),
                              paddedText("${marks?.isAbsent == "Y" ? "Absent" : marks?.marksObtained ?? "-"}", textAlign: TextAlign.center),
                              if (markingAlgorithm != null && (markingAlgorithm?.isGpaAllowed ?? false))
                                paddedText(
                                  percentage == null ? "-" : "${markingAlgorithm?.gpaForPercentage(percentage) ?? "-"}",
                                  textAlign: TextAlign.center,
                                ),
                              if (markingAlgorithm != null && (markingAlgorithm?.isGradeAllowed ?? false))
                                paddedText(
                                  percentage == null ? "-" : markingAlgorithm?.gradeForPercentage(percentage) ?? "-",
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          );
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
                            if (markingAlgorithm?.isGpaAllowed ?? false)
                              totalPercentage == null ? "-" : "${markingAlgorithm?.gpaForPercentage(totalPercentage!) ?? "-"}",
                            if (markingAlgorithm?.isGradeAllowed ?? false)
                              totalPercentage == null ? "-" : markingAlgorithm?.gradeForPercentage(totalPercentage!) ?? "-"
                          ]
                              .map(
                                (e) => paddedText(e, textAlign: TextAlign.center),
                              )
                              .toList(),
                        ),
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
                          children: ["Month", ...attendanceHeaders].map((e) => paddedText(e, fontSize: 9, textAlign: TextAlign.center)).toList(),
                        ),
                        TableRow(
                          decoration: const BoxDecoration(
                            color: PdfColors.white,
                          ),
                          children: [paddedText("Working\ndays", fontSize: 9), ...attendanceHeaders.map((e) => paddedText("", fontSize: 9))],
                        ),
                        TableRow(
                          decoration: const BoxDecoration(
                            color: PdfColors.white,
                          ),
                          children: [paddedText("Present\ndays", fontSize: 9), ...attendanceHeaders.map((e) => paddedText("", fontSize: 9))],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          },
          footer: (_) => Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Class Teacher"),
                Expanded(
                  child: Center(child: Text("Parent Signature", textAlign: TextAlign.center)),
                ),
                Column(
                  children: [
                    if (schoolInfo.principalSignature != null)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image(
                          height: 50,
                          width: 60,
                          MemoryImage(
                            const Base64Decoder().convert(schoolInfo.principalSignature!),
                          ),
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    Text("Principal", textAlign: TextAlign.right),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    var x = await pdf.save();
    final blob = html.Blob([x], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.target = '_blank';
    anchorElement.download = studentProfiles.length == 1
        ? "${studentProfiles[0].sectionName} ${studentProfiles[0].rollNumber ?? ""} ${studentProfiles[0].studentFirstName}.pdf"
        : "${customExam.customExamName} Memos.pdf";
    anchorElement.click();
  }

  Widget paddedText(String text, {double fontSize = 12, TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}
