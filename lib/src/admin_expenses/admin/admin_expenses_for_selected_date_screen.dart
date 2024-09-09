import 'dart:typed_data';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminExpensesForSelectedDateScreen extends StatefulWidget {
  const AdminExpensesForSelectedDateScreen({
    super.key,
    required this.adminProfile,
    required this.adminExpenses,
    required this.selectedDate,
  });

  final AdminProfile adminProfile;
  final List<AdminExpenseBean> adminExpenses;
  final DateTime selectedDate;

  @override
  State<AdminExpensesForSelectedDateScreen> createState() => _AdminExpensesForSelectedDateScreenState();
}

class _AdminExpensesForSelectedDateScreenState extends State<AdminExpensesForSelectedDateScreen> {
  bool _isLoading = true;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  Future<void> _downloadReport(List<AdminExpenseBean> adminExpenses) async {
    setState(() => _isLoading = true);
    var excel = Excel.createExcel();

    Sheet sheet = excel['Admin Expenses'];

    int rowIndex = 0;

    sheet.appendRow(["${widget.adminProfile.schoolName}"]);
    CellStyle schoolNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = schoolNameStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0));
    rowIndex++;

    sheet.appendRow(["Date: ${(convertDateTimeToDDMMYYYYFormat(widget.selectedDate))}"]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = dateStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1));
    rowIndex++;

    sheet.appendRow([
      'Voucher No.',
      'Expense Type',
      'Expense Description',
      'Amount',
      'Admin',
      'Transacted from',
    ]);
    for (int i = 0; i <= 5; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;

    for (AdminExpenseBean expense in widget.adminExpenses) {
      sheet.appendRow([
        "${expense.receiptId ?? ""}",
        expense.expenseType,
        expense.description,
        (expense.amount ?? 0) / 100.0,
        expense.adminName,
        expense.getIsPocketTransaction() ? "Wallet" : "School Account",
      ]);
      rowIndex++;
    }

    if (excel.getDefaultSheet() != null) {
      excel.delete(excel.getDefaultSheet()!);
    }

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow([
      "Total",
      "",
      widget.adminExpenses.map((e) => e.amount ?? 0).fold(0, (int a, b) => a + b) / 100.0,
      "",
    ]);

    for (int i = 0; i <= 3; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FFFFFF00',
        fontColorHex: 'FF000000',
      );
    }
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["Downloaded: ${convertEpochToDDMMYYYYEEEEHHMMAA(DateTime.now().millisecondsSinceEpoch)}"]);
    CellStyle downloadTimeStyle = CellStyle(
      bold: true,
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = downloadTimeStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));

    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }

    var excelBytes = excel.encode();
    if (excelBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      Uint8List excelUint8List = Uint8List.fromList(excelBytes);

      FileSaver.instance.saveFile(bytes: excelUint8List, name: 'Admin Expenses for ${convertDateTimeToDDMMYYYYFormat(widget.selectedDate)}.xlsx');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Expenses"),
        actions: _isLoading || widget.adminExpenses.isEmpty
            ? []
            : [
                const SizedBox(width: 10),
                Tooltip(
                  message: "Download Report",
                  child: IconButton(
                    onPressed: () {
                      _downloadReport(widget.adminExpenses);
                    },
                    icon: const Icon(Icons.download),
                  ),
                ),
                const SizedBox(width: 10),
              ],
      ),
      body: ListView(
        children: [
          headerWidget(),
          dataTable(),
        ],
      ),
    );
  }

  Widget dataTable() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Scrollbar(
            thumbVisibility: true,
            controller: _controller,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Voucher No.', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Expense Type', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Expense Description', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Transacted from', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  ...widget.adminExpenses.map(
                    (eachExpense) => DataRow(
                      cells: [
                        DataCell(Text("${eachExpense.receiptId ?? "-"}")),
                        DataCell(Text(eachExpense.expenseType ?? "-")),
                        DataCell(Text(eachExpense.description ?? "-")),
                        DataCell(Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachExpense.amount ?? 0) / 100)} /-")),
                        DataCell(Text(eachExpense.adminName ?? "-")),
                        DataCell(Text(eachExpense.getIsPocketTransaction() ? "Wallet" : "School Account")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerWidget() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(10, 20, 10, 20)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(widget.selectedDate)).replaceAll("\n", " "),
                  style: GoogleFonts.archivoBlack(
                    textStyle: const TextStyle(
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...widget.adminExpenses.map((e) => e.expenseType).whereNotNull().toSet().map((eachExpenseType) {
                double amount = widget.adminExpenses
                    .where((e) => e.expenseType == eachExpenseType)
                    .map((e) => e.amount ?? 0)
                    .fold<double>(0, (sum, amount) => sum + amount);
                return Container(
                  margin: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(child: Text(eachExpenseType)),
                      Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(amount / 100.0)} /-"),
                    ],
                  ),
                );
              }),
              const Divider(thickness: 1, color: Colors.grey),
              Container(
                margin: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Expanded(child: Text("Total", style: TextStyle(color: Colors.blue))),
                    Text(
                      "$INR_SYMBOL ${doubleToStringAsFixedForINR(widget.adminExpenses.map((e) => e.amount ?? 0).fold(0, (int a, b) => a + b) / 100.0)} /-",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
