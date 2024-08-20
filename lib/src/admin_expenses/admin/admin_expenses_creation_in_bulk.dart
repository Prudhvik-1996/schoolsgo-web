import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class AdminExpensesCreationInBulk {
  final List<AdminExpenseBean> adminExpenses;
  final AdminProfile adminProfile;
  int startIndexOfNewExpenses = 0;

  AdminExpensesCreationInBulk(this.adminExpenses, this.adminProfile) {
    startIndexOfNewExpenses = 4 + adminExpenses.length;
  }

  String templateSheetName = 'Admin Expenses';

  List<String> headerStrings = [
    "Date",
    "Admin Name",
    "Expense Type",
    "Description",
    "Amount",
    "Mode Of Payment",
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

    for (AdminExpenseBean eachExpense in adminExpenses) {
      sheet.appendRow([
        convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(eachExpense.transactionTime ?? DateTime.now().millisecondsSinceEpoch)),
        eachExpense.adminName,
        eachExpense.expenseType,
        eachExpense.description,
        (eachExpense.amount ?? 0) / 100,
        eachExpense.modeOfPayment,
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
    saveFile(excelUint8List, '$templateSheetName.xlsx');
  }

  Future<List<AdminExpenseBean>?> readAndValidateExcel(BuildContext context) async {
    List<AdminExpenseBean> newExpensesList = [];
    Uint8List? bytes = await pickFile();
    if (bytes == null) return null;
    Excel excel = Excel.decodeBytes(bytes);
    Sheet sheet = excel[templateSheetName];
    for (String table in excel.tables.keys) {
      print("162: ${table} :: ${startIndexOfNewExpenses} :: ${sheet.maxCols + 4}");
      for (int rowIndex = startIndexOfNewExpenses; rowIndex <= 1000; rowIndex++) {
        print("163: ${excel.tables[table]?.row(rowIndex).tryGet<Data?>(2)?.value.toString()}");
        bool isValid = false;
        for (int i = 0; i < headerStrings.length; i++) {
          if (excel.tables[table]?.row(rowIndex).tryGet<Data?>(i)?.value.toString() != null) {
            isValid = true;
          }
        }
        if (!isValid) break;
        AdminExpenseBean newAdminExpense = AdminExpenseBean();
        int colIndex = 0;
        // ["Date", "Admin Name", "Expense Type", "Amount", "Mode Of Payment"]
        newAdminExpense.transactionTime =
            convertDDMMYYYYFormatToDateTime(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString()).millisecondsSinceEpoch;
        newAdminExpense.adminName = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newAdminExpense.expenseType = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newAdminExpense.description = excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString();
        newAdminExpense.amount = (int.tryParse(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString() ?? "") ?? 0) * 100;
        newAdminExpense.modeOfPayment =
            ModeOfPaymentExt.fromString(excel.tables[table]?.row(rowIndex).tryGet<Data?>(colIndex++)?.value.toString()).name;
        newAdminExpense.schoolId = adminProfile.schoolId;
        newAdminExpense.schoolName = adminProfile.schoolName;
        newAdminExpense.agent = adminProfile.userId;
        newAdminExpense.adminId = adminProfile.userId;
        newAdminExpense.adminPhotoUrl = adminProfile.adminPhotoUrl;
        newAdminExpense.branchCode = adminProfile.branchCode;
        newAdminExpense.franchiseId = adminProfile.franchiseId;
        newAdminExpense.franchiseName = adminProfile.franchiseName;
        newAdminExpense.status = 'active';
        newAdminExpense.adminExpenseReceiptsList = [];
        newExpensesList.add(newAdminExpense);
      }
    }
    return newExpensesList;
  }
}
