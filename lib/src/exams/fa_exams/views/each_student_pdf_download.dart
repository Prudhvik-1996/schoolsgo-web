import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_information_center/modal/month_wise_attendance.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';

class EachStudentPdfDownloadForFaExam {
  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final MarkingAlgorithmBean? markingAlgorithm;
  final FAExam faExam;
  final FaInternalExam? selectedInternal;
  final List<StudentProfile> studentProfiles;
  final Section selectedSection;

  final void Function(String? e) updateMessage;

  late double totalMaxMarks;
  late double? totalMarksObtained;
  late double? totalPercentage;

  EachStudentPdfDownloadForFaExam({
    required this.schoolInfo,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.markingAlgorithm,
    required this.faExam,
    required this.selectedInternal,
    required this.studentProfiles,
    required this.selectedSection,
    required this.updateMessage,
  });

  Future<void> downloadMemo(List<StudentMonthWiseAttendance> studentMonthWiseAttendanceList) async {
    final pdf = Document();

    final font = await PdfGoogleFonts.merriweatherRegular();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();
    List<ImageProvider?> studentImages = [];
    for (StudentProfile studentProfile in studentProfiles) {
      updateMessage("Caching image for ${studentProfile.rollNumber}. ${studentProfile.studentFirstName}");
      ImageProvider? studentImage;
      try {
        studentImage =
            studentProfile.studentPhotoThumbnailUrl == null ? null : await networkImage(allowCORSEndPoint + studentProfile.studentPhotoThumbnailUrl!);
      } on Exception catch (e) {
        updateMessage("Something went wrong.. $e");
      }
      studentImages.add(studentImage);
    }

    for (int studentIndex = 0; studentIndex < studentProfiles.length; studentIndex++) {
      StudentProfile studentProfile = studentProfiles[studentIndex];

      updateMessage("Writing memo for ${studentProfile.rollNumber}. ${studentProfile.studentFirstName}");
      ImageProvider? studentImage = studentImages[studentIndex];

      faExam.faInternalExams ??= [];
      for (FaInternalExam? ei in faExam.faInternalExams!) {
        ei!.examSectionSubjectMapList ??= [];
        ei.examSectionSubjectMapList!.removeWhere((essm) => essm?.sectionId != selectedSection.sectionId);
        for (ExamSectionSubjectMap? essm in ei.examSectionSubjectMapList!) {
          essm!.studentExamMarksList ??= [];
          essm.studentExamMarksList!.removeWhere((esm) => esm?.studentId != studentProfile.studentId);
        }
      }
      FAExam faExamForStudent = FAExam.fromJson(faExam.toJson());

      late double totalMaxMarks;
      late double? totalMarksObtained;
      late double? totalPercentage;
      late bool isAbsentForAtLeastForOneSubject;
      late bool isFailInAtLeastForOneSubject;

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
      totalPercentage = (totalMarksObtained * 100.0 / totalMaxMarks);
      isAbsentForAtLeastForOneSubject = (faExamForStudent.faInternalExams ?? [])
          .map((e) => (e?.examSectionSubjectMapList ?? []).whereNotNull())
          .expand((i) => i)
          .map((e) => (e.studentExamMarksList ?? []).firstOrNull)
          .where((e) => e?.isAbsent == "N")
          .isNotEmpty;
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

      List<String> attendanceHeaders = ["Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "Total"];

      pdf.addPage(
        MultiPage(
          pageTheme: PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const EdgeInsets.all(2),
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
                                    Text(studentProfile.fatherName ?? "-"),
                                  ],
                                ),
                              if (studentProfile.schoolId == 100) SizedBox(height: 10),
                              if (studentProfile.schoolId == 100)
                                Row(
                                  children: [
                                    Text("Mobile: "),
                                    Expanded(
                                        child: Text(
                                            studentProfile.gaurdianMobile ?? studentProfile.studentMobile ?? studentProfile.alternateMobile ?? "-")),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (studentImage != null) SizedBox(width: 10),
                        if (studentImage != null) Image(studentImage, height: 100, width: 75, fit: BoxFit.scaleDown),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Report of ${faExamForStudent.faExamName ?? "-"}",
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
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          decoration: const BoxDecoration(
                            color: PdfColors.grey100,
                          ),
                          children: [
                            paddedText(
                              "Subject",
                            ),
                            ...(faExamForStudent.faInternalExams ?? []).map(
                              (e) {
                                return paddedText(
                                  e?.faInternalExamName ?? " - ",
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                            paddedText(
                              "Total",
                              textAlign: TextAlign.center,
                            ),
                            if (markingAlgorithm != null && (markingAlgorithm?.isGpaAllowed ?? false))
                              paddedText(
                                "GPA",
                                textAlign: TextAlign.center,
                              ),
                            if (markingAlgorithm != null && (markingAlgorithm?.isGradeAllowed ?? false))
                              paddedText(
                                "Grade",
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                        ...(faExamForStudent.faInternalExams ?? [])
                            .map((e) => (e?.examSectionSubjectMapList ?? []))
                            .expand((i) => i)
                            .map((e) => e?.subjectId)
                            .toSet()
                            .map((esid) => subjectsList.where((es) => es.subjectId == esid).firstOrNull)
                            .whereNotNull()
                            .sorted((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0))
                            .map((eachSubject) {
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
                            if (essmForSubject == null) {
                              examMarksForSubject.add(null);
                            } else {
                              StudentExamMarks? esm =
                                  (essmForSubject.studentExamMarksList ?? []).where((esm) => esm?.studentId == studentProfile.studentId).firstOrNull;
                              examMarksForSubject.add(esm);
                            }
                          }
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
                          }

                          return TableRow(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              paddedText(
                                eachSubject.subjectName ?? "-",
                              ),
                              ...examMarksForSubject.map((esm) {
                                double? maxMarks = internalsEssms.where((e) => (e.studentExamMarksList ?? []).contains(esm)).firstOrNull?.maxMarks;
                                return paddedTextForMarksObtained(
                                  esm,
                                  maxMarks,
                                );
                              }),
                              paddedText(
                                (totalMarksObtained == null || (totalMaxMarks) == 0) ? "-" : "$totalMarksObtained",
                                textAlign: TextAlign.center,
                              ),
                              if (markingAlgorithm != null && (markingAlgorithm?.isGpaAllowed ?? false))
                                paddedText(
                                  (totalMarksObtained == null || (totalMaxMarks) == 0)
                                      ? "-"
                                      : "${markingAlgorithm?.gpaForPercentage(totalMarksObtained * 100 / totalMaxMarks) ?? "-"}",
                                  textAlign: TextAlign.center,
                                ),
                              if (markingAlgorithm != null && (markingAlgorithm?.isGradeAllowed ?? false))
                                paddedText(
                                  (totalMarksObtained == null || (totalMaxMarks) == 0)
                                      ? "-"
                                      : markingAlgorithm?.gradeForPercentage(totalMarksObtained * 100 / totalMaxMarks) ?? "-",
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 10),
                    Table(
                      border: TableBorder.all(),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: PdfColors.grey300,
                          ),
                          children: [
                            "Max. Marks",
                            "Marks Obtained",
                            "Percentage",
                            if (markingAlgorithm?.isGpaAllowed ?? false) "GPA",
                            if (markingAlgorithm?.isGradeAllowed ?? false) "Grade"
                          ]
                              .map(
                                (e) => paddedText(
                                  e,
                                  textAlign: TextAlign.center,
                                ),
                              )
                              .toList(),
                        ),
                        TableRow(
                          children: [
                            "$totalMaxMarks",
                            "$totalMarksObtained",
                            schoolInfo.schoolId == 100 && (isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject)
                                ? "-"
                                : "${doubleToStringAsFixed(totalPercentage)} %",
                            if (markingAlgorithm?.isGpaAllowed ?? false)
                              schoolInfo.schoolId == 100 && (isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject)
                                  ? "-"
                                  : totalPercentage == null
                                      ? "-"
                                      : "${markingAlgorithm?.gpaForPercentage(totalPercentage) ?? "-"}",
                            if (markingAlgorithm?.isGradeAllowed ?? false)
                              schoolInfo.schoolId == 100 && (isAbsentForAtLeastForOneSubject || isFailInAtLeastForOneSubject)
                                  ? "-"
                                  : totalPercentage == null
                                      ? "-"
                                      : markingAlgorithm?.gradeForPercentage(totalPercentage) ?? "-",
                          ]
                              .map(
                                (e) => paddedText(
                                  e,
                                  textAlign: TextAlign.center,
                                ),
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
                          children: [
                            paddedText("Working\ndays", fontSize: 9),
                            ...attendanceHeaders.map((e) {
                              int month = getMonth(e);
                              if (month != 0) {
                                StudentMonthWiseAttendance? smwa = studentMonthWiseAttendanceList
                                    .where((smwa) => smwa.month == month && smwa.studentId == studentProfile.studentId)
                                    .firstOrNull;
                                return paddedText(
                                  doubleToStringAsFixed(
                                    (smwa?.present ?? 0) + (smwa?.absent ?? 0),
                                    decimalPlaces: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              } else {
                                return paddedText(
                                  doubleToStringAsFixed(
                                    (studentMonthWiseAttendanceList
                                            .where((smwa) => smwa.studentId == studentProfile.studentId)
                                            .map((e) => e.present ?? 0)).sum +
                                        (studentMonthWiseAttendanceList
                                            .where((smwa) => smwa.studentId == studentProfile.studentId)
                                            .map((e) => e.absent ?? 0)).sum,
                                    decimalPlaces: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }
                            })
                          ],
                        ),
                        TableRow(
                          decoration: const BoxDecoration(
                            color: PdfColors.white,
                          ),
                          children: [
                            paddedText("Present\ndays", fontSize: 9),
                            ...attendanceHeaders.map((e) {
                              int month = getMonth(e);
                              if (month != 0) {
                                StudentMonthWiseAttendance? smwa = studentMonthWiseAttendanceList
                                    .where((smwa) => smwa.month == month && smwa.studentId == studentProfile.studentId)
                                    .firstOrNull;
                                return paddedText(
                                  doubleToStringAsFixed(
                                    (smwa?.present ?? 0),
                                    decimalPlaces: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              } else {
                                return paddedText(
                                  doubleToStringAsFixed(
                                    (studentMonthWiseAttendanceList
                                        .where((smwa) => smwa.studentId == studentProfile.studentId)
                                        .map((e) => e.present ?? 0)).sum,
                                    decimalPlaces: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }
                            })
                          ],
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
      updateMessage("Completed writing memo for ${studentProfile.rollNumber}. ${studentProfile.studentFirstName}");
    }

    var x = await pdf.save();
    final blob = html.Blob([x], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.target = '_blank';
    anchorElement.download = studentProfiles.length == 1
        ? "${studentProfiles[0].sectionName} ${studentProfiles[0].rollNumber ?? ""} ${studentProfiles[0].studentFirstName}.pdf"
        : "${faExam.faExamName} Memos.pdf";
    anchorElement.click();
    updateMessage(null);
  }

  Future<void> downloadHallTickets() async {
    final pdf = Document();

    final font = await PdfGoogleFonts.merriweatherRegular();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();
    List<ImageProvider?> studentImages = [];
    for (StudentProfile studentProfile in studentProfiles) {
      updateMessage("Caching image for ${studentProfile.rollNumber}. ${studentProfile.studentFirstName}");
      ImageProvider? x;
      try {
        x = studentProfile.studentPhotoThumbnailUrl == null ? null : await networkImage(studentProfile.studentPhotoThumbnailUrl!);
      } on Exception catch (e) {
        updateMessage("Something went wrong.. $e");
      }
      studentImages.add(x);
    }

    FaInternalExam faInternalExam = FaInternalExam.fromJson(selectedInternal?.toJson() ?? {});
    for (int studentIndex = 0; studentIndex < studentProfiles.length; studentIndex++) {
      StudentProfile studentProfile = studentProfiles[studentIndex];
      updateMessage("Writing hall ticket for ${studentProfile.rollNumber}. ${studentProfile.studentFirstName}");
      ImageProvider? studentImage = studentImages[studentIndex];

      FaInternalExam faInternalExam = FaInternalExam.fromJson(selectedInternal?.toJson() ?? {});
      faInternalExam.examSectionSubjectMapList?.forEach((essm) {
        essm?.studentExamMarksList = [];
      });
      Set<ExamSectionSubjectMap> essmList =
          (faInternalExam.examSectionSubjectMapList ?? []).whereNotNull().where((e) => e.sectionId == selectedSection.sectionId).toSet();
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
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        schoolInfo.schoolId == 100
                            ? "Hall Ticket for ${faExam.faExamName ?? " - "}"
                            : "Hall Ticket for ${faExam.faExamName ?? " - "} : ${faInternalExam.faInternalExamName ?? " - "}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
                              if (studentProfile.schoolId == 100) SizedBox(height: 10),
                              if (studentProfile.schoolId == 100)
                                Row(
                                  children: [
                                    Text("Mobile: "),
                                    Expanded(
                                        child: Text(
                                            studentProfile.gaurdianMobile ?? studentProfile.studentMobile ?? studentProfile.alternateMobile ?? "-")),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (studentImage != null) SizedBox(width: 10),
                        if (studentImage != null) Image(studentImage, height: 100, width: 75, fit: BoxFit.scaleDown),
                      ],
                    ),
                    SizedBox(height: 30),
                    Table(
                      border: TableBorder.all(),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: PdfColors.grey100,
                          ),
                          children: [
                            paddedText("Date"),
                            paddedText("Time"),
                            paddedText("Subject", textAlign: TextAlign.center),
                            paddedText("Invigilator's Signature", textAlign: TextAlign.center),
                          ],
                        ),
                        ...(essmList.toList()
                              ..sort((a, b) {
                                if (a.date != null &&
                                    a.startTime != null &&
                                    a.endTime != null &&
                                    b.date != null &&
                                    b.startTime != null &&
                                    b.endTime != null) {
                                  return (convertYYYYMMDDFormatToDateTime(a.date!).millisecondsSinceEpoch +
                                          getSecondsEquivalentOfTimeFromWHHMMA(a.startTime!, 1))
                                      .compareTo(convertYYYYMMDDFormatToDateTime(b.date!).millisecondsSinceEpoch +
                                          getSecondsEquivalentOfTimeFromWHHMMA(b.startTime!, 1));
                                }
                                if (a.date != null && b.date != null) {
                                  return (convertYYYYMMDDFormatToDateTime(a.date!).millisecondsSinceEpoch)
                                      .compareTo(convertYYYYMMDDFormatToDateTime(b.date!).millisecondsSinceEpoch);
                                }
                                Subject? aSubject = subjectsList.where((es) => es.subjectId == a.subjectId).firstOrNull;
                                Subject? bSubject = subjectsList.where((es) => es.subjectId == b.subjectId).firstOrNull;
                                return (aSubject?.seqOrder ?? 0).compareTo(bSubject?.seqOrder ?? 0);
                              }))
                            .map((essm) {
                          return TableRow(
                            children: [
                              paddedText(essm.examDate, textAlign: TextAlign.center),
                              paddedText("${essm.startTimeSlot} - ${essm.endTimeSlot}", textAlign: TextAlign.center),
                              paddedText(
                                subjectsList.where((es) => essm.subjectId == es.subjectId).firstOrNull?.subjectName ?? " - ",
                                textAlign: TextAlign.left,
                              ),
                              paddedText(essmList.length <= 8 ? "\n\n" : "\n", textAlign: TextAlign.center),
                            ],
                          );
                        })
                      ],
                    ),
                    SizedBox(height: 10),
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
                  child: Center(child: Text("", textAlign: TextAlign.center)),
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
      updateMessage("Completed writing memo for ${studentProfile.rollNumber}. ${studentProfile.studentFirstName}");
    }

    var x = await pdf.save();
    final blob = html.Blob([x], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.target = '_blank';
    anchorElement.download = studentProfiles.length == 1
        ? "${studentProfiles[0].sectionName} ${studentProfiles[0].rollNumber ?? ""} ${studentProfiles[0].studentFirstName}.pdf"
        : "${faExam.faExamName ?? " - "} - ${selectedSection.sectionName} - ${faInternalExam.faInternalExamName ?? " - "} Hall Tickets.pdf";
    anchorElement.click();
    updateMessage(null);
  }

  Widget paddedText(String text, {double fontSize = 12, TextAlign textAlign = TextAlign.left, double padding = 8.0}) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget paddedTextForMarksObtained(StudentExamMarks? esm, double? maxMarks, {double padding = 8.0}) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: esm?.isAbsent == "N"
          ? Text(
              "Absent",
              textAlign: TextAlign.center,
            )
          : esm?.marksObtained == null
              ? Text(
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

  int getMonth(String month) {
    switch (month) {
      case "Jan":
        return 1;
      case "Feb":
        return 2;
      case "Mar":
        return 3;
      case "Apr":
        return 4;
      case "May":
        return 5;
      case "Jun":
        return 6;
      case "Jul":
        return 7;
      case "Aug":
        return 8;
      case "Sep":
        return 9;
      case "Oct":
        return 10;
      case "Nov":
        return 11;
      case "Dec":
        return 12;
      default:
        return 0;
    }
  }
}
