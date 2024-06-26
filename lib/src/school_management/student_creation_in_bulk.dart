import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class CreateStudentsInBulkExcel {
  final List<StudentProfile> studentsList;
  final Section section;
  final int? agentId;
  final int? schoolId;
  int startIndexOfNewStudents = 0;

  CreateStudentsInBulkExcel(
    this.studentsList,
    this.section, {
    this.agentId,
    this.schoolId,
  }) {
    startIndexOfNewStudents = 4 + studentsList.length;
  }

  List<String> headerStrings = [
    "Roll  No.",
    "Admission  No.",
    "Student Name",
    "Parent Name",
    "Mobile Number",
    "Email Id",
    "Date Of Birth\r\n(DD-MM-YYYY)",
    "Gender\r\n(male/female)",
    "Nationality",
    "Religion",
    "Caste",
    "Category"
  ];

  Future<void> downloadTemplate() async {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Students Data for ${section.sectionName ?? ""}'];

    int rowIndex = 0;
    sheet.appendRow([(section.sectionName ?? "")]);
    CellStyle sectionNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = sectionNameStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: headerStrings.length - 1, rowIndex: 0));
    rowIndex++; // 1

    sheet.appendRow(["Date: ${(convertDateTimeToDDMMYYYYFormat(DateTime.now()))}"]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = dateStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: headerStrings.length - 1, rowIndex: 1));
    rowIndex++; // 2

    String rules =
        """Guidelines for Adding Students in the Excel Template\n\nThank you for your dedication to maintaining the integrity of the data within the Excel template. To ensure consistent and accurate data management, please adhere to the following guidelines when updating student marks.\n\nPreserve Template Structure:\n\nKindly refrain from altering the template's file name or sheet name. This ensures seamless data synchronization and validation.\n\nMaintain Core Data:\n\nPlease refrain from modifying the sequence and content of essential elements such as Student Names, Roll Numbers, etc. These details are crucial for proper identification and tracking.\n\nExisting Student Data:\n\nThe existing student data will not be modified in any case.\nValid Input Characters:\n\nThe valid format or the Date Of Birth is "DD-MM-YYYY" and for gender, "male"/"female". Please refrain from using any other characters, as they will be considered invalid.\n\nYour attention to these guidelines contributes significantly to data consistency and reliability. If you have any questions or require assistance, do not hesitate to reach out to the support team.\n\nThank you for your cooperation.""";
    rules += "\n\n\n\n\n";
    sheet.appendRow([rules.replaceAll("\n\n", "\r\n")]);
    CellStyle rulesDataStyle = CellStyle(
      bold: false,
      fontSize: 10,
      textWrapping: TextWrapping.WrapText,
      backgroundColorHex: "#FF0000",
      fontColorHex: "#FFFFFF",
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).cellStyle = rulesDataStyle;
    sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2), CellIndex.indexByColumnRow(columnIndex: headerStrings.length - 1, rowIndex: 2));
    rowIndex++; // 3

    sheet.appendRow(headerStrings);
    for (int j = 0; j < sheet.maxCols; j++) {
      CellStyle headerDataCellStyle = CellStyle(
        bold: false,
        fontSize: 10,
        textWrapping: TextWrapping.WrapText,
        backgroundColorHex: "#000000",
        fontColorHex: "#FFFFFF",
      );
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 3)).cellStyle = headerDataCellStyle;
    }
    rowIndex++; // 4

    for (StudentProfile eachStudent in studentsList) {
      sheet.appendRow([
        eachStudent.rollNumber ?? "",
        eachStudent.admissionNo ?? "",
        eachStudent.studentFirstName ?? "",
        eachStudent.gaurdianFirstName ?? "",
        eachStudent.gaurdianMobile ?? "",
        eachStudent.gaurdianMailId ?? "",
        eachStudent.studentDob == null ? "" : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(eachStudent.studentDob)),
        eachStudent.sex ?? "",
        eachStudent.nationality ?? "Indian",
        eachStudent.religion ?? "",
        eachStudent.caste ?? "",
        eachStudent.category ?? "",
      ]);
      rowIndex++;
    }

    for (int i = 4; i < rowIndex; i++) {
      for (int j = 0; j < sheet.maxCols; j++) {
        CellStyle studentDataCellStyle = CellStyle(
          bold: false,
          fontSize: 10,
          textWrapping: TextWrapping.WrapText,
          backgroundColorHex: "#F0FF00",
          fontColorHex: "#000000",
        );
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i)).cellStyle = studentDataCellStyle;
      }
    }

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
    saveFile(excelUint8List, 'Student data bulk create ${section.sectionName}.xlsx');
  }

  Future<List<StudentProfile>?> readAndValidateExcel(BuildContext context) async {
    List<StudentProfile> newStudentsList = [];
    Uint8List? bytes = await pickFile();
    if (bytes == null) return null;
    Excel excel = Excel.decodeBytes(bytes);
    Sheet sheet = excel['Students Data for ${section.sectionName ?? ""}'];
    for (String table in excel.tables.keys) {
      print("162: ${table} :: ${startIndexOfNewStudents} :: ${sheet.maxCols + 4}");
      for (int rowIndex = startIndexOfNewStudents; rowIndex <= 1000; rowIndex++) {
        print("163: ${excel.tables[table]?.row(rowIndex).tryGet<Data?>(2)?.value.toString()}");
        bool isValid = false;
        for (int i = 0; i < headerStrings.length; i++) {
          if (excel.tables[table]?.row(rowIndex).tryGet<Data?>(i)?.value.toString() != null) {
            isValid = true;
          }
        }
        if (!isValid) break;
        StudentProfile newStudentProfile = StudentProfile();
        int colIndex = 0;
        // ["Roll  No.", "Admission  No.", "Student Name", "Parent Name", "Mobile Number", "Email Id", "Date Of Birth", "Gender", "Nationality", "Religion", "Caste", "Category"]
        newStudentProfile.rollNumber = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newStudentProfile.admissionNo = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        String? studentFirstName = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        if ((studentFirstName ?? "").trim() == "") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Student Name at row ${rowIndex + 1} cannot be empty"),
            ),
          );
          return null;
        } else {
          newStudentProfile.studentFirstName = studentFirstName;
        }
        newStudentProfile.gaurdianFirstName = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newStudentProfile.gaurdianMobile = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newStudentProfile.gaurdianMailId = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        String? dateString = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        try {
          // Check if the dateString is a number and convert it to DateTime if necessary
          if (dateString != null && double.tryParse(dateString) != null) {
            int daysSinceEpoch = int.parse(dateString);
            DateTime baseDate = DateTime(1899, 12, 30);
            DateTime dateOfBirth = baseDate.add(Duration(days: daysSinceEpoch));
            newStudentProfile.studentDob = convertDateTimeToYYYYMMDDFormat(dateOfBirth);
          } else {
            newStudentProfile.studentDob = convertDateTimeToYYYYMMDDFormat(convertDDMMYYYYFormatToDateTime(dateString));
          }
        } catch (e) {
          debugPrint("Unable to parse Date Of Birth: $dateString, Error: $e");
        }
        String? genderString = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newStudentProfile.sex = ['male', 'female'].contains(genderString) ? genderString : null;
        newStudentProfile.nationality = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? "Indian";
        newStudentProfile.religion = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newStudentProfile.caste = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newStudentProfile.category = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newStudentProfile.sectionId = section.sectionId;
        newStudentProfile.schoolId = schoolId;
        newStudentProfile.agentId = agentId;
        newStudentsList.add(newStudentProfile);
      }
    }
    return newStudentsList;
  }
}
