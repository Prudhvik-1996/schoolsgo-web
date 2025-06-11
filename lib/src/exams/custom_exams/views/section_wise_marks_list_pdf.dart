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
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';

class SectionWiseMarkListPdf {
  SchoolInfoBean schoolInfo;
  AdminProfile? adminProfile;
  TeacherProfile? teacherProfile;
  int selectedAcademicYearId;
  List<Section> sectionsList;
  List<Teacher> teachersList;
  List<Subject> subjectsList;
  List<TeacherDealingSection> tdsList;
  MarkingAlgorithmBean? markingAlgorithm;
  CustomExam customExam;
  List<StudentProfile> studentsList;
  Section selectedSection;
  String? examMemoHeader;

  Map<int, List<StudentExamMarks>> examMarks = {};

  SectionWiseMarkListPdf({
    required this.schoolInfo,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.markingAlgorithm,
    required this.customExam,
    required this.studentsList,
    required this.selectedSection,
    required this.examMemoHeader,
  }) {
    studentsList = <StudentProfile>{
      ...studentsList.where((e) => e.sectionId == selectedSection.sectionId),
      ...studentsList.where((e) => (customExam.examSectionSubjectMapList ?? [])
          .whereNotNull()
          .map((e) => e.studentExamMarksList ?? [])
          .expand((i) => i)
          .whereNotNull()
          .map((e) => e.studentId)
          .contains(e.studentId))
    }.toList();
    studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
    for (StudentProfile eachStudent in studentsList) {
      for (ExamSectionSubjectMap examSectionSubjectMap in (customExam.examSectionSubjectMapList ?? []).whereNotNull()) {
        examMarks[examSectionSubjectMap.examSectionSubjectMapId!] ??= [];
        if ((examSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.studentId == eachStudent.studentId).isNotEmpty) {
          examMarks[examSectionSubjectMap.examSectionSubjectMapId!]!
              .add((examSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.studentId == eachStudent.studentId).first!);
        } else {
          examMarks[examSectionSubjectMap.examSectionSubjectMapId!]!.add(StudentExamMarks(
            examSectionSubjectMapId: examSectionSubjectMap.examSectionSubjectMapId,
            examId: examSectionSubjectMap.examId,
            agent: adminProfile?.userId ?? teacherProfile?.teacherId,
            comment: null,
            studentId: eachStudent.studentId,
            marksObtained: null,
            marksId: null,
            studentExamMediaBeans: [],
          ));
        }
      }
    }
  }

  Future<void> downloadAsPdf() async {
    final pdf = Document();

    final font = await PdfGoogleFonts.merriweatherRegular();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();

    List<Subject> tempSubjectsList = (customExam.examSectionSubjectMapList ?? [])
        .where((essm) => essm?.sectionId == selectedSection.sectionId)
        .map((e) => e?.subjectId)
        .map((eachSubjectId) => subjectsList.where((e) => e.subjectId == eachSubjectId).firstOrNull)
        .whereNotNull()
        .toList();
    List<ExamSectionSubjectMap?> essmList = customExam.examSectionSubjectMapList ?? [];
    List<String> headerStrings = [];
    List<Subject> subjectsForExam = [];
    double totalMaxMarks = 0;
    for (Subject es in tempSubjectsList) {
      ExamSectionSubjectMap? essm = essmList.where((essm) => essm?.subjectId == es.subjectId).firstOrNull;
      if (essm != null) {
        subjectsForExam.add(es);
        headerStrings.add("${es.subjectName?.split(" ").join("\n") ?? " - "}\n(${essm.maxMarks})");
        totalMaxMarks += essm.maxMarks ?? 0;
      }
    }
    headerStrings.add("Total\n($totalMaxMarks)");
    headerStrings.add("Total\n(%)");
    if (markingAlgorithm?.isGpaAllowed ?? false) {
      headerStrings.add("GPA");
    }
    if (markingAlgorithm?.isGradeAllowed ?? false) {
      headerStrings.add("Grade");
    }

    pdf.addPage(
      MultiPage(
        pageTheme: PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.all(32),
          buildBackground: (_) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: PdfColors.grey),
              ),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
        ),
        header: (_) => examMemoHeader != null
            ? Padding(
                padding: const EdgeInsets.all(4),
                child: Image(
                  MemoryImage(
                    const Base64Decoder().convert(examMemoHeader!),
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
            SizedBox(height: 10),
            Center(
              child: Text(
                customExam.customExamName ?? "-",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.all(10),
              child: Table(
                border: TableBorder.all(
                  color: PdfColors.grey,
                ),
                children: [
                  TableRow(
                    repeat: true,
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      cellText("Roll No.", isCenter: false),
                      cellText("Student Name", isCenter: false),
                      ...headerStrings.map((e) => cellText(e, fontSize: 7)),
                    ].toList(),
                  ),
                  ...studentsList.map(
                    (StudentProfile eachStudent) => TableRow(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        cellText(eachStudent.rollNumber ?? "", isCenter: false),
                        cellText(eachStudent.studentFirstName ?? "", isCenter: false),
                        ...List.generate(headerStrings.length, (int columnIndex) {
                          int? studentId = eachStudent.studentId;
                          if (columnIndex >= essmList.length || headerStrings[columnIndex].contains("Total")) {
                            double studentWiseTotalMarks = essmList.map((essm) {
                              StudentExamMarks? marks =
                                  (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
                              return marks == null
                                  ? 0.0
                                  : marks.isAbsent == "N"
                                      ? 0.0
                                      : marks.marksObtained;
                            }).fold<double>(0.0, (double a, double? b) => a + (b ?? 0));
                            double percentage = ((studentWiseTotalMarks / totalMaxMarks) * 100);
                            bool isAbsentForAtLeastForOneSubject = customExam.examSectionSubjectMapList
                                    ?.map((ExamSectionSubjectMap? e) => (e?.studentExamMarksList ?? []).firstOrNull)
                                    .where((StudentExamMarks? e) => e?.studentId == studentId)
                                    .where((e) => e?.isAbsent == "N")
                                    .isNotEmpty ??
                                false;
                            bool isFailInAtLeastForOneSubject = customExam.examSectionSubjectMapList
                                    ?.map((ExamSectionSubjectMap? e) => (e?.studentExamMarksList ?? []))
                                    .expand((i) => i)
                                    .where((StudentExamMarks? e) => e?.studentId == studentId)
                                    .where((StudentExamMarks? e) => e?.isAbsent != "N")
                                    .map((StudentExamMarks? e) {
                                      double percentage = (e?.marksObtained ?? 0) /
                                          ((customExam.examSectionSubjectMapList ?? [])
                                                  .where((essm) => e?.examSectionSubjectMapId == essm?.examSectionSubjectMapId)
                                                  .first
                                                  ?.maxMarks ??
                                              1) *
                                          100;
                                      MarkingAlgorithmRangeBean? rangeBeanForPercentage = markingAlgorithm?.rangeBeanForPercentage(percentage);
                                      return rangeBeanForPercentage;
                                    })
                                    .map((MarkingAlgorithmRangeBean? e) => e?.isFailure == "Y")
                                    .contains(true) ??
                                false;
                            if (headerStrings[columnIndex].contains("Percentage")) {
                              return Center(
                                child: cellText(
                                  isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject ? "-" : "${doubleToStringAsFixed(percentage)} %",
                                ),
                              );
                            } else if (headerStrings[columnIndex].contains("GPA")) {
                              return Center(
                                child: cellText(
                                  isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject
                                      ? "-"
                                      : "${markingAlgorithm?.gpaForPercentage(percentage) ?? "-"}",
                                ),
                              );
                            } else if (headerStrings[columnIndex].contains("Grade")) {
                              return Center(
                                child: cellText(
                                  isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject
                                      ? "-"
                                      : markingAlgorithm?.gradeForPercentage(percentage) ?? "-",
                                ),
                              );
                            } else {
                              return Center(
                                child: cellText("$studentWiseTotalMarks"),
                              );
                            }
                          }
                          ExamSectionSubjectMap? essm = essmList[columnIndex];
                          StudentExamMarks? eachStudentExamMarks =
                              (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
                          if (essm == null) {
                            return Center(child: cellText("N/A"));
                          } else if (essm.examSectionSubjectMapId == null) {
                            int? marksSubjectId = essm.subjectId;
                            return Center(
                                child: cellText(examMarks.values
                                    .expand((i) => i)
                                    .where((e) => e.studentId == studentId)
                                    .where((eachMarks) {
                                      int? eachMarksSubjectId = (customExam.examSectionSubjectMapList ?? [])
                                          .where((e) => e?.examSectionSubjectMapId == eachMarks.examSectionSubjectMapId)
                                          .firstOrNull
                                          ?.subjectId;
                                      return eachMarksSubjectId == marksSubjectId;
                                    })
                                    .map((e) => e.isAbsent == 'N' ? 0.0 : e.marksObtained ?? 0.0)
                                    .fold<double>(0.0, (double a, double b) => a + b)
                                    .toStringAsFixed(2)));
                          } else {
                            return Center(
                              child: cellText(eachStudentExamMarks?.isAbsent == 'N' ? "Absent" : "${eachStudentExamMarks?.marksObtained ?? ""}"),
                            );
                          }
                        })
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    var x = await pdf.save();
    final blob = html.Blob([x], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.target = '_blank';
    anchorElement.download = studentsList.length == 1
        ? "${studentsList[0].sectionName} ${studentsList[0].rollNumber ?? ""} ${studentsList[0].studentFirstName}.pdf"
        : "${customExam.customExamName} ${selectedSection.sectionName ?? ""} Marks List.pdf";
    anchorElement.click();
  }

  Widget cellText(
    String e, {
    bool isCenter = true,
    double fontSize = 9,
  }) {
    final textWidget = Text(
      e,
      style: TextStyle(fontSize: fontSize),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: isCenter ? Center(child: textWidget) : textWidget,
    );
  }
}
