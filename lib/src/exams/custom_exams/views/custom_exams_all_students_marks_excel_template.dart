import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class CustomExamsAllStudentsMarksExcel {
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
  Map<int, List<StudentExamMarks>> examMarks;

  List<String> headerStrings = [];
  List<Subject> subjectsForExam = [];
  List<ExamSectionSubjectMap?> essmList = [];
  double totalMaxMarks = 0;

  CustomExamsAllStudentsMarksExcel({
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
    required this.examMarks,
  }) {
    (customExam.examSectionSubjectMapList ?? []).removeWhere((e) => e?.sectionId != selectedSection.sectionId);
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
    List<Subject> tempSubjectsList = (customExam.examSectionSubjectMapList ?? [])
        .where((essm) => essm?.sectionId == selectedSection.sectionId)
        .map((e) => e?.subjectId)
        .map((eachSubjectId) => subjectsList.where((e) => e.subjectId == eachSubjectId).firstOrNull)
        .whereNotNull()
        .toList();
    essmList = customExam.examSectionSubjectMapList ?? [];
    for (Subject es in tempSubjectsList) {
      ExamSectionSubjectMap? essm = essmList.where((essm) => essm?.subjectId == es.subjectId).firstOrNull;
      if (essm != null) {
        subjectsForExam.add(es);
        headerStrings.add("${es.subjectName?.split(" ").join("\n") ?? " - "}\n(${essm.maxMarks})");
        totalMaxMarks += essm.maxMarks ?? 0;
      }
    }
    // headerStrings.add("Total\n($totalMaxMarks)");
  }

  Future<void> downloadTemplate() async {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Marks Data for ${selectedSection.sectionName ?? ""}'];

    int rowIndex = 0;
    sheet.appendRow([(adminProfile?.schoolName ?? "")]);
    CellStyle schoolNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = schoolNameStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 1 + headerStrings.length, rowIndex: 0));
    rowIndex++; // 1

    sheet.appendRow(["Date: ${(convertDateTimeToDDMMYYYYFormat(DateTime.now()))}"]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = dateStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: 1 + headerStrings.length, rowIndex: 1));
    rowIndex++; // 2

    sheet.appendRow(["Roll No.", "Student Name", ...headerStrings]);
    rowIndex++; // 3

    for (StudentProfile eachStudent in studentsList) {
      sheet.appendRow([
        eachStudent.rollNumber ?? "",
        eachStudent.studentFirstName ?? "",
        ...List.generate(headerStrings.length, (int columnIndex) {
          int? studentId = eachStudent.studentId;
          if (columnIndex >= essmList.length || headerStrings[columnIndex].contains("Total")) {
            double studentWiseTotalMarks = essmList.map((essm) {
              StudentExamMarks? marks = (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
              return marks == null
                  ? 0.0
                  : marks.isAbsent == "N"
                      ? 0.0
                      : marks.marksObtained;
            }).fold<double>(0.0, (double a, double? b) => a + (b ?? 0));
            double percentage = ((studentWiseTotalMarks / totalMaxMarks) * 100);
            if (headerStrings[columnIndex].contains("Percentage")) {
              return doubleToStringAsFixed(percentage);
            } else {
              return "$studentWiseTotalMarks";
            }
          }
          ExamSectionSubjectMap? essm = essmList[columnIndex];
          StudentExamMarks? eachStudentExamMarks =
              (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
          if (essm == null) {
            return "";
          } else if (essm.examSectionSubjectMapId == null) {
            int? marksSubjectId = essm.subjectId;
            return examMarks.values
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
                .toStringAsFixed(2);
          } else {
            return eachStudentExamMarks?.isAbsent == 'N' ? "A" : "${eachStudentExamMarks?.marksObtained ?? ""}";
          }
        })
      ]);
      rowIndex++;
    }
    String rules =
        """Guidelines for Updating Marks in the Excel Template\n\nThank you for your dedication to maintaining the integrity of the data within the Excel template. To ensure consistent and accurate data management, please adhere to the following guidelines when updating student marks.\n\nPreserve Template Structure:\n\nKindly refrain from altering the template's file name or sheet name. This ensures seamless data synchronization and validation.\n\nMaintain Core Data:\n\nPlease refrain from modifying the sequence and content of essential elements such as Student Names, Roll Numbers, and Subject Names. These details are crucial for proper identification and tracking.\n\nMark Updates and Validation:\n\nYou are encouraged to update marks within the designated cells. Notably, these updates will be instantly reflected on-screen, allowing you to verify the accuracy before final submission.\n\nAbsence Marking:\n\nTo signify a student's absence, kindly mark the corresponding cell with "A." This assists in accurate attendance tracking.\n\nValid Input Characters:\n\nOnly utilize the following characters when updating marks: "0," "1," "2," "3," "4," "5," "6," "7," "8," "9," ".", and "A." Please refrain from using any other characters, as they will be considered invalid.\n\nMax Marks Validation:\n\nIt is essential to ensure that entered marks do not surpass the maximum marks allocated for the assessment. Any marks exceeding the specified maximum will be regarded as invalid.\n\nYour attention to these guidelines contributes significantly to data consistency and reliability. If you have any questions or require assistance, do not hesitate to reach out to the support team.\n\nThank you for your cooperation.""";
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2 + headerStrings.length, rowIndex: rowIndex))
      ..value = rules.replaceAll("\n\n", "\r\n")
      ..cellStyle = CellStyle(textWrapping: TextWrapping.WrapText);
    rowIndex++;

    // Auto fit the columns
    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }

    // Deleting default sheet
    if (excel.getDefaultSheet() != null) {
      excel.delete(excel.getDefaultSheet()!);
    }

    // Generate the Excel file as bytes
    List<int>? excelBytes = excel.encode();
    if (excelBytes == null) return;
    Uint8List excelUint8List = Uint8List.fromList(excelBytes);

    // Save the Excel file
    FileSaver.instance.saveFile(bytes: excelUint8List, name: 'Template for ${customExam.customExamName}.xlsx');
  }

  Future<Excel?> readAndValidateExcel() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile == null) return null;
    Uint8List? bytes = pickedFile.files.single.bytes;
    if (bytes == null) return null;
    List<StudentValidationCellsData> expectedStudentsOrder =
        studentsList.map((e) => StudentValidationCellsData(e.rollNumber, e.studentFirstName)).toList();
    List<String> expectedHeaders = ["Roll No.", "Student Name", ...headerStrings];

    List<StudentValidationCellsData> actualStudentsOrder = [];
    List<String> actualHeaders = [];
    Excel excel = Excel.decodeBytes(bytes);
    for (String table in excel.tables.keys) {
      actualHeaders = excel.tables[table]?.row(2).map((e) => e?.value?.toString() ?? "").where((e) => e != "").toList() ?? [];
      for (int rowIndex = 3; rowIndex <= 2 + studentsList.length; rowIndex++) {
        String? rollNumberString = excel.tables[table]?.row(rowIndex).tryGet<Data?>(0)?.value.toString();
        String? nameString = excel.tables[table]?.row(rowIndex).tryGet<Data?>(1)?.value.toString();
        actualStudentsOrder.add(StudentValidationCellsData(rollNumberString, nameString));
      }
    }
    debugPrint("expectedStudentsOrder: $expectedStudentsOrder");
    debugPrint("actualStudentsOrder: $actualStudentsOrder");
    debugPrint("expectedHeaders: $expectedHeaders");
    debugPrint("actualHeaders: $actualHeaders");

    if (expectedStudentsOrder.length != expectedStudentsOrder.length ||
        List.generate(actualStudentsOrder.length, (index) => actualStudentsOrder[index] == expectedStudentsOrder[index]).contains(false) ||
        actualHeaders.length != expectedHeaders.length ||
        List.generate(expectedHeaders.length, (index) => expectedHeaders[index] == actualHeaders[index]).contains(false)) {
      debugPrint("Invalid format");
      return null;
    }

    for (String table in excel.tables.keys) {
      for (int rowIndex = 3; rowIndex <= 2 + studentsList.length; rowIndex++) {
        for (int subjectIndex = 0; subjectIndex < headerStrings.length; subjectIndex++) {
          int? studentId = studentsList[rowIndex - 3].studentId;
          ExamSectionSubjectMap? essm = essmList[subjectIndex];
          StudentExamMarks? eachStudentExamMarks =
              (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
          int columnIndex = subjectIndex + 2;
          String? cellValue = excel.tables[table]?.row(rowIndex).tryGet<Data?>(columnIndex)?.value.toString();
          if (cellValue == null || cellValue == "" || cellValue == "A" || double.tryParse(cellValue) != null) continue;
          debugPrint("Invalid value found $cellValue");
          return null;
        }
      }
    }
    return excel;
  }

  Future<void> readExamMarks(Excel excel) async {
    for (String table in excel.tables.keys) {
      for (int rowIndex = 3; rowIndex <= 2 + studentsList.length; rowIndex++) {
        List.generate(headerStrings.length, (int subjectIndex) {
          int? studentId = studentsList[rowIndex - 3].studentId;
          ExamSectionSubjectMap? essm = essmList[subjectIndex];
          StudentExamMarks? eachStudentExamMarks =
              (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
          int columnIndex = subjectIndex + 2;
          if (excel.tables[table]?.row(rowIndex).tryGet<Data?>(columnIndex)?.value.toString() == "A") {
            eachStudentExamMarks?.isAbsent = "N";
          } else {
            eachStudentExamMarks?.marksObtained =
                double.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(columnIndex)?.value.toString() ?? "");
          }
        });
      }
    }
  }
}

class StudentValidationCellsData {
  String? rollNumber;
  String? studentName;

  StudentValidationCellsData(this.rollNumber, this.studentName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentValidationCellsData && runtimeType == other.runtimeType && rollNumber == other.rollNumber && studentName == other.studentName;

  @override
  int get hashCode => rollNumber.hashCode ^ studentName.hashCode;

  @override
  String toString() {
    return 'StudentValidationCellsData{rollNumber: $rollNumber, studentName: $studentName}';
  }
}
