import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/model/month_wise_attendance.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class StudentMonthWiseAttendanceCreationInBulk {
  final List<StudentProfile> studentsList;
  final Section section;
  final List<StudentMonthWiseAttendance> studentMonthWiseAttendance;
  final List<String> mmmYYYYStrings;

  StudentMonthWiseAttendanceCreationInBulk(this.studentsList, this.section, this.studentMonthWiseAttendance, this.mmmYYYYStrings);

  String get templateSheetName => 'Student Month Wise Attendance ${section.sectionName ?? "-"}';

  List<String> get headerStrings => [
        "Roll No.",
        "Student Name",
        ...mmmYYYYStrings.map((e) => ["$e\nPresent Days", "$e\nWorking Days"]).expand((i) => i)
      ];

  Future<void> downloadTemplate() async {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel[templateSheetName];

    int rowIndex = 0;
    sheet.appendRow([(templateSheetName)]);
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
        """Guidelines for Adding Students in the Excel Template\n\nThank you for your dedication to maintaining the integrity of the data within the Excel template. To ensure consistent and accurate data management, please adhere to the following guidelines when adding new admin expenses.\n\nPreserve Template Structure:\n\nKindly refrain from altering the template's file name or sheet name. This ensures seamless data synchronization and validation.\n\nMaintain Core Data:\n\nPlease refrain from modifying the sequence and content of essential elements such as Expense Type, Amount, Mode Of Payment, etc. These details are crucial for proper identification and tracking.\n\nExisting Expenses Data:\n\nThe existing expenses data will not be modified in any case.\nValid Input Characters:\n\nThe valid format or the Date is "DD-MM-YYYY" and for amount, only use Whole Numbers. Please refrain from using any other characters, as they will be considered invalid.\nOne can only use the following as mode of payment:\n\tCASH, PHONEPE, GPAY, PAYTM, NETBANKING, CHEQUE, CARD, ACCOUNTTRANSFER, OTHER\nAnything else will be considered invalid\n\nYour attention to these guidelines contributes significantly to data consistency and reliability. If you have any questions or require assistance, do not hesitate to reach out to the support team.\n\nThank you for your cooperation.""";
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
      List<String> cells = [];
      for (String eachHeader in headerStrings) {
        if (eachHeader == "Roll No.") {
          cells.add(eachStudent.rollNumber ?? "-");
        } else if (eachHeader == "Student Name") {
          cells.add(eachStudent.studentFirstName ?? "-");
        } else {
          String mmmYYYYString = eachHeader.split("\n")[0];
          String detailType = eachHeader.split("\n")[1];
          StudentMonthWiseAttendance? attendanceBean = studentMonthWiseAttendance
              .where((e) => e.studentId == eachStudent.studentId)
              .firstWhereOrNull((e) => e.mmmYYYYString.toLowerCase() == mmmYYYYString.toLowerCase());
          if (detailType == "Present Days") {
            cells.add("${attendanceBean?.present ?? ""}");
          } else {
            cells.add("${attendanceBean == null ? "" : attendanceBean.totalWorkingDays == 0 ? "" : attendanceBean.totalWorkingDays}");
          }
        }
      }
      sheet.appendRow(cells);
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
    saveFile(excelUint8List, '$templateSheetName.xlsx');
  }

  Future<List<StudentMonthWiseAttendance>?> readAndValidateExcel(BuildContext context) async {
    List<StudentMonthWiseAttendance> updatedAttendance = [];
    Uint8List? bytes = await pickFile();
    if (bytes == null) return null;
    Excel excel = Excel.decodeBytes(bytes);
    Sheet sheet = excel[templateSheetName];
    for (String table in excel.tables.keys) {
      for (int rowIndex = 4; rowIndex <= 1000; rowIndex++) {
        bool isValid = false;
        for (int i = 0; i < headerStrings.length; i++) {
          if (excel.tables[table]?.row(rowIndex).tryGet<Data?>(i)?.value.toString() != null) {
            isValid = true;
          }
        }
        if (!isValid) break;
        for (int i = 2; i < headerStrings.length; i += 2) {
          StudentMonthWiseAttendance newAttendance = StudentMonthWiseAttendance();
          var studentId = studentsList[rowIndex - 4].studentId;
          newAttendance.studentId = studentId;
          int monthIndex = MONTHS.indexWhere((e) => e.toLowerCase().startsWith(headerStrings[i].split("\n")[0].split("-")[0].toLowerCase()));
          newAttendance.month = monthIndex == -1 ? null : monthIndex + 1;
          newAttendance.year = int.tryParse(headerStrings[i].split("\n")[0].split("-")[1]);
          double parsedPresentDays = double.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(i)?.value.toString() ?? "") ?? 0;
          double parsedTotalDays = double.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(i + 1)?.value.toString() ?? "") ?? 0;
          // print("\t> $parsedPresentDays/$parsedTotalDays");
          newAttendance.present = parsedPresentDays;
          newAttendance.absent = parsedTotalDays - parsedPresentDays;
          updatedAttendance.add(newAttendance);
        }
      }
    }
    print("172: ${updatedAttendance.map((e) => e.toJson()).join(",")}");
    return updatedAttendance;
  }
}
