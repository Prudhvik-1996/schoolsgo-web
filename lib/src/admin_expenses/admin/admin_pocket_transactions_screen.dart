import 'dart:typed_data';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/pocket_balances.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminPocketTransactionsScreen extends StatefulWidget {
  const AdminPocketTransactionsScreen({
    Key? key,
    required this.employeeBean,
    required this.pocketBalanceBean,
    required this.pocketTransactionsList,
  }) : super(key: key);

  final SchoolWiseEmployeeBean employeeBean;
  final PocketBalanceBean? pocketBalanceBean;
  final List<PocketTransactionBean>? pocketTransactionsList;

  @override
  State<AdminPocketTransactionsScreen> createState() => _AdminPocketTransactionsScreenState();
}

class _AdminPocketTransactionsScreenState extends State<AdminPocketTransactionsScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isEditMode = false;
  List<PocketTransactionBean> pocketTransactionsList = [];
  late PocketBalanceBean pocketBalanceBean;
  bool? _showOnlyDeletedTransactions = false;

  ScrollController stockHorizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool doForceReload = false}) async {
    setState(() => _isLoading = true);
    if (widget.pocketTransactionsList != null && !doForceReload) {
      pocketTransactionsList = widget.pocketTransactionsList ?? [];
    } else {
      GetPocketTransactionsResponse getPocketTransactionsResponse = await getPocketTransactions(GetPocketTransactionsRequest(
        schoolId: widget.employeeBean.schoolId,
        employeeId: widget.employeeBean.employeeId,
      ));
      if (getPocketTransactionsResponse.httpStatus != "OK" || getPocketTransactionsResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        pocketTransactionsList = getPocketTransactionsResponse.pocketTransactionsList?.whereNotNull().toList() ?? [];
      }
    }
    if (widget.pocketBalanceBean != null && !doForceReload) {
      pocketBalanceBean = widget.pocketBalanceBean!;
    } else {
      GetPocketBalancesResponse getPocketBalancesResponse = await getPocketBalances(GetPocketBalancesRequest(
        schoolId: widget.employeeBean.schoolId,
        employeeId: widget.employeeBean.employeeId,
      ));
      if (getPocketBalancesResponse.httpStatus != "OK" || getPocketBalancesResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        pocketBalanceBean = getPocketBalancesResponse.pocketBalanceBeanList?.firstOrNull ??
            PocketBalanceBean(
              employeeId: widget.employeeBean.employeeId,
              schoolId: widget.employeeBean.schoolId,
              employeeName: widget.employeeBean.employeeName,
              balanceAmount: 0,
              lastTransactionDate: null,
            );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _downloadReport(List<PocketTransactionBean> pocketTransactionsList) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Wallet Transactions'];
    var headers = [
      'Date',
      'Voucher No.',
      'Amount',
      'Transaction Kind',
      'Expense Type',
      'Expense Description',
      'Mode Of Payment',
      'Comments',
    ];

    int rowIndex = 0;

    sheet.appendRow(["${widget.employeeBean.schoolDisplayName}"]);
    CellStyle schoolNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = schoolNameStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0));
    rowIndex++;

    sheet.appendRow(headers);
    for (int i = 0; i <= headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;

    for (PocketTransactionBean transaction in pocketTransactionsList) {
      sheet.appendRow([
        convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(transaction.date ?? DateTime.now().millisecondsSinceEpoch)),
        "${transaction.receiptId ?? " - "}",
        (transaction.amount ?? 0) / 100.0,
        transaction.pocketTransactionType == "LOAD" ? "Credit" : "Debit",
        transaction.getExpenseType().capitalize(),
        (transaction.description ?? "").capitalize(),
        ModeOfPaymentExt.fromString(transaction.modeOfPayment).description,
        (transaction.comments ?? "").capitalize(),
      ]);
      rowIndex++;
    }

    if (excel.getDefaultSheet() != null) {
      excel.delete(excel.getDefaultSheet()!);
    }

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["Expense Type", "Amount"]);
    for (int i = 0; i <= 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;
    Map<String, int> expenseTypePaymentMap = {};
    for (PocketTransactionBean eachTransaction in pocketTransactionsList) {
      expenseTypePaymentMap[eachTransaction.getExpenseType()] ??= 0;
      expenseTypePaymentMap[eachTransaction.getExpenseType()] =
          expenseTypePaymentMap[eachTransaction.getExpenseType()]! + (eachTransaction.amount ?? 0);
    }
    for (var e in expenseTypePaymentMap.entries) {
      sheet.appendRow([
        e.key,
        e.value / 100,
      ]);
      rowIndex++;
    }

    sheet.appendRow([""]);
    rowIndex++;

    // sheet.appendRow(["Mode Of Payment", "Amount"]);
    // for (int i = 0; i <= 1; i++) {
    //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
    //     backgroundColorHex: 'FF000000',
    //     fontColorHex: 'FFFFFFFF',
    //   );
    // }
    // rowIndex++;
    // final paymentMap = <ModeOfPayment, int>{};
    // for (final expense in pocketTransactionsList) {
    //   final modeOfPayment = ModeOfPaymentExt.fromString(expense.modeOfPayment);
    //   final totalAmount = expense.amount ?? 0;
    //   paymentMap[modeOfPayment] = (paymentMap[modeOfPayment] ?? 0) + totalAmount;
    // }
    // paymentMap.forEach((key, value) {
    //   if (value != 0) {
    //     sheet.appendRow([key.description, value / 100.0]);
    //     rowIndex++;
    //   }
    // });
    //
    // sheet.appendRow([
    //   "Total",
    //   paymentMap.values.sum / 100.0,
    // ]);
    // for (int i = 0; i <= 1; i++) {
    //   sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
    //     backgroundColorHex: 'FFFFFF00',
    //     fontColorHex: 'FF000000',
    //   );
    // }
    // rowIndex++;

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
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: rowIndex));

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
      FileSaver.instance.saveFile(bytes: excelUint8List, name: 'Wallet Transactions ${convertDateTimeToDDMMYYYYFormat(DateTime.now())}.xlsx');
    }
    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Show only deleted transactions") {
      setState(() => _showOnlyDeletedTransactions = true);
    } else if (choice == "Show all transactions") {
      setState(() => _showOnlyDeletedTransactions = null);
    } else if (choice == "Hide deleted transactions") {
      setState(() => _showOnlyDeletedTransactions = false);
    } else if (choice == "Download Report") {
      setState(() => _isLoading = true);
      await _downloadReport(pocketTransactionsList.where((e) => e.status == 'active').toList());
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Pocket Transactions"),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: () => setState(() => _isEditMode = !_isEditMode),
              icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            ),
          if (!_isLoading && !_isEditMode)
            PopupMenuButton<String>(
              onSelected: (String choice) async => await handleClick(choice),
              itemBuilder: (BuildContext context) {
                return {
                  if (_showOnlyDeletedTransactions != null) "Show all transactions",
                  if (_showOnlyDeletedTransactions == null || !_showOnlyDeletedTransactions!) "Show only deleted transactions",
                  if (_showOnlyDeletedTransactions == null || _showOnlyDeletedTransactions!) "Hide deleted transactions",
                  "Download Report",
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              children: [
                buildEmployeePocketBalanceWidget(context),
                Expanded(child: pocketTransactionsTableWidget(pocketTransactionsList)),
              ],
            ),
    );
  }

  Padding buildEmployeePocketBalanceWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.employeeBean.employeeName ?? "-",
                      style: GoogleFonts.archivoBlack(
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: clayContainerTextColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Current Balance: "),
                  Text(
                    INR_SYMBOL +
                        " " +
                        (pocketBalanceBean.balanceAmount == null
                            ? "-"
                            : doubleToStringAsFixed(pocketBalanceBean.balanceAmount! / 100, decimalPlaces: 2)) +
                        " /-",
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pocketTransactionsTableWidget(List<PocketTransactionBean> pocketTransactionsList) {
    return ClayTable2DWidgetV2(
      context: context,
      horizontalScrollController: stockHorizontalScrollController,
      columns: [
        // const DataColumn(label: Text('Employee Name')),
        if (_isEditMode) const DataColumn(label: Text('Actions')),
        const DataColumn(label: Text('Date')),
        const DataColumn(label: Text('Amount')),
        const DataColumn(label: Text('Voucher No.')),
        const DataColumn(label: Text('Expense Type')),
        const DataColumn(label: Text('Expense Description')),
        const DataColumn(label: Text('Mode Of Payment')),
        const DataColumn(label: Text('Comments')),
      ],
      rows: pocketTransactionsList
          .where((e) => !_isEditMode ? true : e.isAdminExpense == "N")
          .where((e) => _showOnlyDeletedTransactions == null
              ? true
              : _showOnlyDeletedTransactions!
                  ? e.status != 'active'
                  : e.status == 'active')
          .map(
            (transaction) => DataRow(
              cells: [
                // DataCell(employeeNameWidget()),
                if (_isEditMode)
                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () async => await _showDeleteTransactionDialogue(transaction),
                    ),
                  ),
                DataCell(transactionTimeWidget(transaction)),
                DataCell(transactionAmountWidget(transaction)),
                DataCell(transactionVoucherWidget(transaction)),
                DataCell(transactionExpenseTypeWidget(transaction)),
                DataCell(transactionExpenseDescriptionWidget(transaction)),
                DataCell(transactionExpenseModeOfPaymentWidget(transaction)),
                DataCell(transactionCommentsWidget(transaction)),
              ],
            ),
          )
          .toList(),
    );
  }

  Text transactionCommentsWidget(PocketTransactionBean transaction) => Text(
        transaction.comments ?? "-",
        style: getTextStyle(transaction),
      );

  Text transactionExpenseModeOfPaymentWidget(PocketTransactionBean transaction) => Text(
        ModeOfPaymentExt.fromString(transaction.modeOfPayment ?? "-").description,
        style: getTextStyle(transaction),
      );

  Text transactionExpenseDescriptionWidget(PocketTransactionBean transaction) => Text(
        transaction.description ?? "-",
        style: getTextStyle(transaction),
      );

  Text transactionExpenseTypeWidget(PocketTransactionBean transaction) => Text(
        transaction.getExpenseType(),
        style: getTextStyle(transaction),
      );

  Text transactionVoucherWidget(PocketTransactionBean transaction) => Text(
        "${transaction.receiptId ?? " - "}",
        style: getTextStyle(transaction),
      );

  Row transactionAmountWidget(PocketTransactionBean transaction) {
    return Row(
      children: [
        Text(
          INR_SYMBOL + " " + (transaction.amount == null ? "-" : doubleToStringAsFixed(transaction.amount! / 100, decimalPlaces: 2)),
        ),
        const SizedBox(width: 5),
        transaction.pocketTransactionType == "LOAD"
            ? const Icon(
                Icons.arrow_drop_up_outlined,
                color: Colors.green,
              )
            : const Icon(
                Icons.arrow_drop_down_outlined,
                color: Colors.red,
              ),
      ],
    );
  }

  Text transactionTimeWidget(PocketTransactionBean transaction) => Text(
        convertEpochToDDMMYYYYEEEEHHMMAA(transaction.date ?? DateTime.now().millisecondsSinceEpoch),
        style: getTextStyle(transaction),
      );

  Text employeeNameWidget() => Text(widget.employeeBean.employeeName ?? '');

  TextStyle? getTextStyle(PocketTransactionBean transaction) {
    if (transaction.status != 'active') return const TextStyle(color: Colors.red);
    return null;
  }

  Future<void> _showDeleteTransactionDialogue(PocketTransactionBean transaction) async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: const Text("New Fund Transfer"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  border: UnderlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  labelText: 'Comments',
                  hintText: 'Comments',
                ),
                style: const TextStyle(
                  fontSize: 12,
                ),
                autofocus: false,
                onChanged: (String e) {
                  setState(() => transaction.comments = e);
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Proceed"),
              onPressed: () async {
                if ((transaction.comments ?? "").trim().isEmpty) return;
                Navigator.of(context).pop();
                _deleteTransaction(transaction);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransaction(PocketTransactionBean pocketTransaction) async {
    setState(() => _isLoading = true);
    CreateOrUpdatePocketTransactionResponse createOrUpdatePocketTransactionResponse =
        await createOrUpdatePocketTransaction(CreateOrUpdatePocketTransactionRequest(
      agent: widget.employeeBean.employeeId,
      amount: pocketTransaction.amount,
      comments: pocketTransaction.comments,
      date: pocketTransaction.date,
      employeeId: pocketTransaction.employeeId,
      modeOfPayment: pocketTransaction.modeOfPayment,
      pocketTransactionId: pocketTransaction.pocketTransactionId,
      pocketTransactionType: pocketTransaction.pocketTransactionType,
      receiptId: pocketTransaction.receiptId,
      schoolId: pocketTransaction.schoolId,
      status: "inactive",
      transactionId: pocketTransaction.transactionId,
    ));
    if (createOrUpdatePocketTransactionResponse.httpStatus != "OK" || createOrUpdatePocketTransactionResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated successfully"),
        ),
      );
      _loadData(doForceReload: true);
    }
    setState(() => _isLoading = false);
  }
}
