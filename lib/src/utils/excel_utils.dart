import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

Future<void> downloadHallTickets(
  BuildContext context,
  AdminProfile adminProfile,
  FAExam faExam,
  FaInternalExam eachInternal,
  List<StudentProfile> selectedStudentsForHallTickets,
  List<Subject> subjects,
) async {
  var excel = Excel.createExcel();

  // Add a sheet to the workbook
  Sheet sheet = excel['Hall Tickets'];
  CellStyle schoolNameStyle = CellStyle(
    bold: true,
    fontSize: 24,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );
  CellStyle examNameStyle = CellStyle(
    bold: true,
    fontSize: 18,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  int rowIndex = 0;
  List<int> schoolNameRowIndices = [];
  List<int> examNameRowIndices = [];

  for (StudentProfile eachStudent in selectedStudentsForHallTickets) {
    List<ExamSectionSubjectMap> examSectionSubjectMapList =
        (eachInternal.examSectionSubjectMapList ?? []).map((e) => e!).where((e) => e.sectionId == eachStudent.sectionId).toList();
    int maxColLength = examSectionSubjectMapList.length;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["${adminProfile.schoolName}"]);
    schoolNameRowIndices.add(rowIndex);
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), CellIndex.indexByColumnRow(columnIndex: maxColLength, rowIndex: rowIndex));
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow([
      "Student Name:",
      (eachStudent.studentFirstName ?? "-"),
      ...List<String>.generate(maxColLength - 4, (_) => ""),
      "Class:",
      eachStudent.sectionName ?? "-"
    ]);
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex), CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));
    Data studentNameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
    studentNameCell.value = (eachStudent.studentFirstName ?? "-");
    rowIndex++;

    sheet.appendRow(["Father Name:", (eachStudent.gaurdianFirstName ?? "-")]);
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex), CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));
    Data fatherNameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
    fatherNameCell.value = (eachStudent.gaurdianFirstName ?? "-");
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["${faExam.faExamName} - ${eachInternal.faInternalExamName}"]);
    examNameRowIndices.add(rowIndex);
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), CellIndex.indexByColumnRow(columnIndex: maxColLength, rowIndex: rowIndex));
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow([
      "Subjects",
      ...examSectionSubjectMapList
          .map((essm) => subjects.where((eachSubject) => eachSubject.subjectId == essm.subjectId).firstOrNull?.subjectName ?? "-")
    ]);
    rowIndex++;

    sheet.appendRow(["Date", ...examSectionSubjectMapList.map((essm) => essm.examDate)]);
    rowIndex++;

    sheet.appendRow(["Time", ...examSectionSubjectMapList.map((essm) => "${essm.startTimeSlot}\n${essm.endTimeSlot}")]);
    rowIndex++;

    sheet.appendRow(["Invigilator's\nSignature", ...examSectionSubjectMapList.map((_) => "")]);
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;
  }

  for (int i = 0; i < rowIndex; i++) {
    for (int j = 0; j < 100; j++) {
      if (schoolNameRowIndices.contains(i)) {
        Data cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
        cell.cellStyle = schoolNameStyle;
        cell.value = adminProfile.schoolName ?? "-";
      } else if (examNameRowIndices.contains(i)) {
        Data cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
        cell.cellStyle = examNameStyle;
        cell.value = "${faExam.faExamName ?? " - "} - ${eachInternal.faInternalExamName ?? " - "}";
      } else {
        Data cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i));
        cell.cellStyle = CellStyle(textWrapping: TextWrapping.WrapText);
      }
    }
  }

  // Deleting default sheet
  if (excel.getDefaultSheet() != null) {
    excel.delete(excel.getDefaultSheet()!);
  }

  sheet.appendRow([""]);
  rowIndex++;

  // Auto fit the columns
  for (var i = 1; i < sheet.maxCols; i++) {
    sheet.setColAutoFit(i);
  }

  // Generate the Excel file as bytes
  var excelBytes = excel.encode();
  if (excelBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Something went wrong! Try again later.."),
      ),
    );
  } else {
    Uint8List excelUint8List = Uint8List.fromList(excelBytes);

    // Save the Excel file
    FileSaver.instance.saveFile(bytes: excelUint8List, name: 'Hall Tickets for ${faExam.faExamName} - ${eachInternal.faInternalExamName}.xlsx');
  }
}
