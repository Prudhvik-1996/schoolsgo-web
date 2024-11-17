import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

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
  FAExam faExam;
  List<StudentProfile> studentsList;
  Section selectedSection;

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
    required this.faExam,
    required this.studentsList,
    required this.selectedSection,
  }) {
    studentsList = <StudentProfile>{
      ...studentsList.where((e) => e.sectionId == selectedSection.sectionId),
      ...studentsList.where((e) => ((faExam.faInternalExams ?? []).map((e) => e?.examSectionSubjectMapList ?? []))
          .expand((i) => i)
          .whereNotNull()
          .map((ExamSectionSubjectMap e) => e.studentExamMarksList ?? [])
          .expand((i) => i)
          .whereNotNull()
          .map((e) => e.studentId)
          .contains(e.studentId))
    }.toList();
    studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
    for (StudentProfile eachStudent in studentsList) {
      for (ExamSectionSubjectMap examSectionSubjectMap
          in (((faExam.faInternalExams ?? []).map((e) => e?.examSectionSubjectMapList ?? [])).expand((i) => i)).whereNotNull()) {
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

    List<Subject> tempSubjectsList = ((faExam.faInternalExams ?? []).map((e) => e?.examSectionSubjectMapList ?? []))
        .expand((i) => i)
        .where((essm) => essm?.sectionId == selectedSection.sectionId)
        .map((e) => e?.subjectId)
        .toSet()
        .map((eachSubjectId) => subjectsList.where((e) => e.subjectId == eachSubjectId).firstOrNull)
        .whereNotNull()
        .sorted((a, b) {
      int? aSeqOrder = a.seqOrder;
      int? bSeqOrder = b.seqOrder;
      return (aSeqOrder ?? 0).compareTo(bSeqOrder ?? 0);
    }).toList();
    List<ExamSectionSubjectMap?> essmList = [];
    for (Subject es in tempSubjectsList) {
      for (FaInternalExam eachInternal in (faExam.faInternalExams ?? []).whereNotNull()) {
        essmList.add(
            (eachInternal.examSectionSubjectMapList ?? []).firstWhereOrNull((essm) => essm?.status == 'active' && essm?.subjectId == es.subjectId));
      }
    }
    List<String> headerStrings = [];
    List<Subject> subjectsForExam = [];
    double totalMaxMarks = 0;
    for (Subject es in tempSubjectsList) {
      for (FaInternalExam eachInternal in (faExam.faInternalExams ?? []).whereNotNull()) {
        ExamSectionSubjectMap? essm =
            essmList.where((essm) => essm?.examId == eachInternal.faInternalExamId && essm?.subjectId == es.subjectId).firstOrNull;
        if (essm != null) {
          subjectsForExam.add(es);
          headerStrings.add("${eachInternal.faInternalExamName?.trim() ?? "-"}\n${es.subjectName?.trim() ?? "-"} (${essm.maxMarks})");
          totalMaxMarks += essm.maxMarks ?? 0;
        }
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
          orientation: PageOrientation.landscape,
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
        header: (_) => schoolInfo.examMemoHeader != null
            ? Padding(
                padding: const EdgeInsets.all(4),
                child: Center(
                  child: Image(
                    MemoryImage(
                      const Base64Decoder().convert(schoolInfo.examMemoHeader!),
                    ),
                    fit: BoxFit.scaleDown,
                    width: 300,
                    height: 150,
                    alignment: Alignment.topCenter,
                  ),
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
            SizedBox(height: 5),
            Center(
              child: Text(
                faExam.faExamName ?? "-",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 1),
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
                      headerCellText("R.No.", fontSize: 6, isBold: true, isCenter: false),
                      headerCellText("Student Name", fontSize: 6, isBold: true, isCenter: false),
                      ...headerStrings.map((e) => headerCellText(e, fontSize: 6, isBold: true, isVertical: true)),
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
                            bool isAbsentForAtLeastForOneSubject = computeIsAbsentForAtLeastOneSubject(studentId);
                            bool isFailInAtLeastForOneSubject = computeIsFailInAtLeastOneSubject(studentId);

                            FAExam faExamForStudent = getFaExamForStudent(studentsList.where((e) => e.studentId == studentId).firstOrNull);
                            totalMaxMarks = (faExamForStudent.faInternalExams ?? [])
                                .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
                                .expand((i) => i)
                                .map((e) => e.maxMarks ?? 0.0)
                                .fold<double>(0.0, (double a, double b) => a + b);
                            double totalMarksObtained = (faExamForStudent.faInternalExams ?? [])
                                .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
                                .expand((i) => i)
                                .map((e) => (e.studentExamMarksList ?? []).firstOrNull)
                                .where((e) => e?.isAbsent != "N")
                                .map((e) => e?.marksObtained)
                                .whereNotNull()
                                .fold<double>(0.0, (double a, double b) => a + b);
                            double? totalPercentage = (totalMarksObtained * 100.0 / totalMaxMarks);

                            if (headerStrings[columnIndex].contains("(%)")) {
                              return Center(
                                child: cellText(
                                  isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject
                                      ? "-"
                                      : "${doubleToStringAsFixed(totalPercentage)} %",
                                ),
                              );
                            } else if (headerStrings[columnIndex].contains("GPA")) {
                              return Center(
                                child: cellText(
                                  isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject
                                      ? "-"
                                      : "${markingAlgorithm?.gpaForPercentage(totalPercentage) ?? "-"}",
                                ),
                              );
                            } else if (headerStrings[columnIndex].contains("Grade")) {
                              return Center(
                                child: cellText(
                                  isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject
                                      ? "-"
                                      : markingAlgorithm?.gradeForPercentage(totalPercentage) ?? "-",
                                ),
                              );
                            } else {
                              return Center(
                                child: cellText("$totalMarksObtained"),
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
                                      int? eachMarksSubjectId = ((faExam.faInternalExams ?? []).map((e) => e?.examSectionSubjectMapList ?? []))
                                          .expand((i) => i)
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
                              child: cellText(eachStudentExamMarks?.isAbsent == 'N' ? "A" : "${eachStudentExamMarks?.marksObtained ?? ""}"),
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
        : "${faExam.faExamName} ${selectedSection.sectionName ?? ""} Marks List.pdf";
    anchorElement.click();
  }

  bool computeIsAbsentForAtLeastOneSubject(int? studentId) {
    FAExam faExamForStudent = getFaExamForStudent(studentsList.where((e) => e.studentId == studentId).firstOrNull);
    bool isAbsentForAtLeastForOneSubject = (faExamForStudent.faInternalExams ?? [])
        .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
        .expand((i) => i)
        .map((e) => (e.studentExamMarksList ?? []).firstOrNull)
        .where((e) => e?.isAbsent == "N")
        .isNotEmpty;
    return isAbsentForAtLeastForOneSubject;
  }

  bool computeIsFailInAtLeastOneSubject(int? studentId) {
    late bool isFailInAtLeastForOneSubject;
    FAExam faExamForStudent = getFaExamForStudent(studentsList.where((e) => e.studentId == studentId).firstOrNull);
    if ([100].contains(schoolInfo.schoolId)) {
      List<double?> subjectWisePercentages = [];
      for (Subject eachSubject in subjectsList.where((es) =>
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
          subjectWisePercentages.map((percentage) => markingAlgorithm?.rangeBeanForPercentage(percentage!)?.isFailure == "Y").contains(true);
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
            MarkingAlgorithmRangeBean? rangeBeanForPercentage = markingAlgorithm?.rangeBeanForPercentage(percentage);
            return rangeBeanForPercentage;
          })
          .map((MarkingAlgorithmRangeBean? e) => e?.isFailure == "Y")
          .contains(true);
    }
    return isFailInAtLeastForOneSubject;
  }

  FAExam getFaExamForStudent(StudentProfile? studentProfile) {
    FAExam faExamForStudent = FAExam.fromJson(faExam.toJson());
    faExamForStudent.faInternalExams ??= [];
    for (FaInternalExam? ei in faExamForStudent.faInternalExams!) {
      ei!.examSectionSubjectMapList ??= [];
      ei.examSectionSubjectMapList!.removeWhere((essm) => essm?.sectionId != selectedSection.sectionId);
      for (ExamSectionSubjectMap? essm in ei.examSectionSubjectMapList!) {
        essm!.studentExamMarksList ??= [];
        essm.studentExamMarksList!.removeWhere((esm) => esm?.studentId != studentProfile?.studentId);
      }
    }
    return faExamForStudent;
  }

  Widget headerCellText(
    String e, {
    bool isCenter = true,
    double fontSize = 8,
    bool isVertical = false,
    bool isBold = false,
  }) {
    final textWidget = Text(
      e,
      style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : null),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );

    return Padding(
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        height: 50,
        child: isVertical
            ? FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Transform.rotateBox(angle: pi / 2, child: textWidget),
              )
            : isCenter
                ? Center(child: textWidget)
                : Align(alignment: Alignment.bottomLeft, child: textWidget),
      ),
    );
  }

  Widget cellText(
    String e, {
    bool isCenter = true,
    double fontSize = 8,
    bool isVertical = false,
    bool isBold = false,
  }) {
    final textWidget = Text(
      e,
      style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : null),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );

    return Padding(
      padding: const EdgeInsets.all(3),
      child: isVertical
          ? Center(child: Transform.rotateBox(angle: pi / 2, child: textWidget))
          : isCenter
              ? Center(child: textWidget)
              : textWidget,
    );
  }
}
