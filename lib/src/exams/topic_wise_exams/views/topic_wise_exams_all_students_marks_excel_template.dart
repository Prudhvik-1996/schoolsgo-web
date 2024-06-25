import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/exam_topics.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';

class TopicWiseExamsAllStudentMarksUpdateTemplate {
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final TeacherDealingSection tds;
  final int selectedAcademicYearId;
  final List<StudentProfile> studentsList;
  final ExamTopic examTopic;
  final List<TopicWiseExam> topicWiseExams;
  final List<StudentExamMarks> examMarks;

  late List<String> headerStrings;

  TopicWiseExamsAllStudentMarksUpdateTemplate({
    required this.adminProfile,
    required this.teacherProfile,
    required this.tds,
    required this.selectedAcademicYearId,
    required this.studentsList,
    required this.examTopic,
    required this.topicWiseExams,
    required this.examMarks,
  }) {
    headerStrings = topicWiseExams.map((e) => e.examName ?? "-").toList();
  }

  Future<void> downloadTemplate() async {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['${examTopic.topicName}'];

    generateSheetForExam(sheet, excel);

    // Generate the Excel file as bytes
    List<int>? excelBytes = excel.encode();
    if (excelBytes == null) return;
    Uint8List excelUint8List = Uint8List.fromList(excelBytes);

    // Save the Excel file
    saveFile(excelUint8List, 'Template for ${examTopic.topicName}.xlsx');
  }

  void generateSheetForExam(Sheet sheet, Excel excel, {bool showRules = true}) {
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

    sheet.appendRow([(examTopic.topicName ?? "")]);
    CellStyle topicNameStyle = CellStyle(
      bold: true,
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = topicNameStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(columnIndex: 1 + headerStrings.length, rowIndex: rowIndex));
    rowIndex++; // 2

    sheet.appendRow(["Date: ${(convertDateTimeToDDMMYYYYFormat(DateTime.now()))}"]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = dateStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(columnIndex: 1 + headerStrings.length, rowIndex: rowIndex));
    rowIndex++; // 3

    if (topicWiseExams.isEmpty) {
      rowIndex = catchException(sheet, rowIndex); // 4
    } else {
      try {
        sheet.appendRow(["Roll No.", "Student Name", ...headerStrings]);
        rowIndex++; // 4

        for (StudentProfile eachStudent in studentsList) {
          sheet.appendRow([
            eachStudent.rollNumber ?? "",
            eachStudent.studentFirstName ?? "",
            ...List.generate(headerStrings.length, (int columnIndex) {
              int? studentId = eachStudent.studentId;
              StudentExamMarks eachStudentExamMarks =
                  examMarks.where((e) => e.studentId == studentId && e.examId == topicWiseExams[columnIndex].examId).first;
              return eachStudentExamMarks.isAbsent == 'N' ? "A" : "${eachStudentExamMarks.marksObtained ?? ""}";
            }),
          ]);
          rowIndex++;
        }
      } catch (_) {
        catchException(sheet, rowIndex);
      }
    }
    if (showRules) {
      String rules =
          """Guidelines for Updating Marks in the Excel Template\n\nThank you for your dedication to maintaining the integrity of the data within the Excel template. To ensure consistent and accurate data management, please adhere to the following guidelines when updating student marks.\n\nPreserve Template Structure:\n\nKindly refrain from altering the template's file name or sheet name. This ensures seamless data synchronization and validation.\n\nMaintain Core Data:\n\nPlease refrain from modifying the sequence and content of essential elements such as Student Names, Roll Numbers, and Subject Names. These details are crucial for proper identification and tracking.\n\nMark Updates and Validation:\n\nYou are encouraged to update marks within the designated cells. Notably, these updates will be instantly reflected on-screen, allowing you to verify the accuracy before final submission.\n\nAbsence Marking:\n\nTo signify a student's absence, kindly mark the corresponding cell with "A." This assists in accurate attendance tracking.\n\nValid Input Characters:\n\nOnly utilize the following characters when updating marks: "0," "1," "2," "3," "4," "5," "6," "7," "8," "9," ".", and "A." Please refrain from using any other characters, as they will be considered invalid.\n\nMax Marks Validation:\n\nIt is essential to ensure that entered marks do not surpass the maximum marks allocated for the assessment. Any marks exceeding the specified maximum will be regarded as invalid.\n\nYour attention to these guidelines contributes significantly to data consistency and reliability. If you have any questions or require assistance, do not hesitate to reach out to the support team.\n\nThank you for your cooperation.""";
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2 + headerStrings.length, rowIndex: rowIndex))
        ..value = rules.replaceAll("\n\n", "\r\n")
        ..cellStyle = CellStyle(textWrapping: TextWrapping.WrapText);
      rowIndex++;
    }

    // Auto fit the columns
    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }

    // Deleting default sheet
    if (excel.getDefaultSheet() != null) {
      excel.delete(excel.getDefaultSheet()!);
    }
  }

  int catchException(Sheet sheet, int rowIndex) {
    sheet.appendRow(["NO EXAMS CREATED"]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = dateStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(columnIndex: 1 + headerStrings.length, rowIndex: rowIndex));
    rowIndex++; // 4
    return rowIndex;
  }

  Future<Excel?> readAndValidateExcel() async {
    Uint8List? bytes = await pickFile();
    if (bytes == null) return null;
    List<StudentValidationCellsData> expectedStudentsOrder =
        studentsList.map((e) => StudentValidationCellsData(e.rollNumber, e.studentFirstName)).toList();
    List<String> expectedHeaders = ["Roll No.", "Student Name", ...headerStrings];

    List<StudentValidationCellsData> actualStudentsOrder = [];
    List<String> actualHeaders = [];
    Excel excel = Excel.decodeBytes(bytes);
    for (String table in excel.tables.keys) {
      actualHeaders = excel.tables[table]?.row(3).map((e) => e?.value?.toString() ?? "").where((e) => e != "").toList() ?? [];
      for (int rowIndex = 4; rowIndex <= 2 + studentsList.length; rowIndex++) {
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
      for (int rowIndex = 4; rowIndex <= 2 + studentsList.length; rowIndex++) {
        for (int examIndex = 0; examIndex < headerStrings.length; examIndex++) {
          int? studentId = studentsList[rowIndex - 4].studentId;
          TopicWiseExam? topicWiseExam = topicWiseExams[examIndex];
          StudentExamMarks? eachStudentExamMarks = examMarks.where((e) => e.studentId == studentId && e.examId == topicWiseExam.examId).first;
          int columnIndex = examIndex + 2;
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
      for (int rowIndex = 4; rowIndex <= 2 + studentsList.length; rowIndex++) {
        for (int examIndex = 0; examIndex < headerStrings.length; examIndex++) {
          int? studentId = studentsList[rowIndex - 4].studentId;
          TopicWiseExam? topicWiseExam = topicWiseExams[examIndex];
          StudentExamMarks eachStudentExamMarks = examMarks.where((e) => e.studentId == studentId && e.examId == topicWiseExam.examId).first;
          int columnIndex = examIndex + 2;
          String? cellValue = excel.tables[table]?.row(rowIndex).tryGet<Data?>(columnIndex)?.value.toString();
          if (cellValue == null) {
            eachStudentExamMarks.marksObtained = null;
            eachStudentExamMarks.isAbsent = null;
          } else if (cellValue == "A") {
            eachStudentExamMarks.isAbsent = "N";
          } else if (double.tryParse(cellValue) != null) {
            eachStudentExamMarks.marksObtained = double.tryParse(cellValue);
            eachStudentExamMarks.isAbsent = "P";
          } else {
            debugPrint("No action needed for $rowIndex:$columnIndex with value $cellValue");
          }
        }
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
