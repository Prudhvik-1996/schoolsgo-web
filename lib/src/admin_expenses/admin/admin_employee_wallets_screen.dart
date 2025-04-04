import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/admin_pocket_transactions_screen.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/pocket_balances.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminEmployeeWalletsScreen extends StatefulWidget {
  const AdminEmployeeWalletsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminEmployeeWalletsScreen> createState() => _AdminEmployeeWalletsScreenState();
}

class _AdminEmployeeWalletsScreenState extends State<AdminEmployeeWalletsScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SchoolWiseEmployeeBean> employeesList = [];
  List<PocketBalanceBean> pocketBalancesList = [];

  List<PocketTransactionBean> pocketTransactionsList = [];
  late PocketTransactionBean newPocketTransactionBean;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      newPocketTransactionBean = PocketTransactionBean(
        schoolId: widget.adminProfile.schoolId,
        employeeId: null,
        agent: widget.adminProfile.userId,
        status: 'active',
        transactionId: null,
        date: null,
        modeOfPayment: ModeOfPayment.CASH.name,
        amount: null,
        comments: null,
        pocketTransactionId: null,
        pocketTransactionType: "LOAD",
        receiptId: null,
      );
    });
    GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolWiseEmployeesResponse.httpStatus != "OK" || getSchoolWiseEmployeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employeesList = (getSchoolWiseEmployeesResponse.employees ?? []).map((e) => e!).toList();
      });
    }
    GetPocketBalancesResponse getPocketBalancesResponse = await getPocketBalances(GetPocketBalancesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getPocketBalancesResponse.httpStatus != "OK" || getPocketBalancesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      pocketBalancesList = getPocketBalancesResponse.pocketBalanceBeanList?.whereNotNull().toList() ?? [];
    }
    GetPocketTransactionsResponse getPocketTransactionsResponse = await getPocketTransactions(GetPocketTransactionsRequest(
      schoolId: widget.adminProfile.schoolId,
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
    setState(() => _isLoading = false);
  }

  Future<void> _downloadReport(List<PocketTransactionBean> pocketTransactionsList) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Wallet Transactions'];
    var headers = [
      'Date',
      'Employee Name',
      'Voucher No.',
      'Amount',
      'Transaction Kind',
      'Expense Type',
      'Expense Description',
      'Mode Of Payment',
      'Comments',
    ];

    int rowIndex = 0;

    sheet.appendRow(["${widget.adminProfile.schoolName}"]);
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
      SchoolWiseEmployeeBean employeeBean = employeesList.firstWhere((e) => e.employeeId == transaction.employeeId);
      sheet.appendRow([
        convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(transaction.date ?? DateTime.now().millisecondsSinceEpoch)),
        (employeeBean.employeeName ?? "-").capitalize(),
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
    if (choice == "Download Report") {
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
        title: const Text("Employee Wallets"),
        actions: [
          if (!_isLoading)
            PopupMenuButton<String>(
              onSelected: (String choice) async => await handleClick(choice),
              itemBuilder: (BuildContext context) {
                return {
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
          : ListView(
              children: [
                _pocketBalancesTable(pocketBalancesList),
              ],
            ),
      floatingActionButton: _isLoading
          ? null
          : fab(
              const Icon(Icons.payments_outlined),
              "Fund Transfer",
              () async => addNewTransaction(newPocketTransactionBean),
              color: Colors.green,
            ),
    );
  }

  Future<void> addNewTransaction(PocketTransactionBean pocketTransaction) async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: const Text("New Fund Transfer"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView(
                  children: [
                    if (MediaQuery.of(context).orientation == Orientation.landscape)
                      Row(
                        children: [
                          Expanded(child: employeePickerForPocketTransaction(pocketTransaction, setState)),
                          const SizedBox(width: 10),
                          SizedBox(width: 120, child: amountTextFieldForPocketTransaction(pocketTransaction, setState)),
                          // Amount
                        ],
                      ),
                    if (MediaQuery.of(context).orientation != Orientation.landscape) ...[
                      employeePickerForPocketTransaction(pocketTransaction, setState),
                      const SizedBox(height: 10),
                      amountTextFieldForPocketTransaction(pocketTransaction, setState),
                    ],
                    const SizedBox(height: 10),
                    commentsForPocketTransaction(pocketTransaction, setState),
                    const SizedBox(height: 10),
                    radioButtonsForCrOrDbForPocketTransaction(pocketTransaction, setState),
                    const SizedBox(height: 10),
                    if (MediaQuery.of(context).orientation == Orientation.landscape)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildModeOfPaymentDropdown(pocketTransaction, setState),
                          dateTimePicker(pocketTransaction, setState),
                        ],
                      ),
                    if (MediaQuery.of(context).orientation != Orientation.landscape) ...[
                      buildModeOfPaymentDropdown(pocketTransaction, setState),
                      const SizedBox(height: 10),
                      dateTimePicker(pocketTransaction, setState),
                    ]
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Proceed"),
              onPressed: () async {
                if ((pocketTransaction.amount ?? 0) == 0 || pocketTransaction.employeeId == null) return;
                Navigator.of(context).pop();
                _saveChanges(pocketTransaction);
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

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 5),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pocketBalancesTable(List<PocketBalanceBean> pocketBalances) {
    return Container(
      margin: const EdgeInsets.all(10),
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
                  DataColumn(label: Text('Employee Name')),
                  DataColumn(label: Text('Balance')),
                  DataColumn(label: Text('Last Transaction Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: pocketBalances.sorted((a, b) => (a.balanceAmount ?? 0).compareTo(b.balanceAmount ?? 0)).map((pocketBalanceBean) {
                  SchoolWiseEmployeeBean employeeBean = employeesList.firstWhere((e) => e.employeeId == pocketBalanceBean.employeeId);
                  return DataRow(
                    cells: [
                      DataCell(Text(pocketBalanceBean.employeeName ?? "-")),
                      DataCell(Text("$INR_SYMBOL ${(pocketBalanceBean.balanceAmount ?? 0) / 100} /-")),
                      DataCell(Text(pocketBalanceBean.lastTransactionDate == null
                          ? "-"
                          : convertEpochToDDMMYYYYEEEEHHMMAA(pocketBalanceBean.lastTransactionDate!))),
                      DataCell(
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AdminPocketTransactionsScreen(
                                  employeeBean: employeeBean,
                                  pocketTransactionsList: pocketTransactionsList.where((e) => e.employeeId == employeeBean.employeeId).toList(),
                                  pocketBalanceBean: pocketBalanceBean,
                                );
                              },
                            ),
                          ).then((_) => _loadData()),
                          child: ClayButton(
                            depth: 40,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 100,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.wallet,
                                size: 9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget employeePickerForPocketTransaction(PocketTransactionBean pocketTransaction, StateSetter localStateSetter) {
    return InputDecorator(
      decoration: InputDecoration(
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Employee',
        hintText: 'Employee',
        prefix: Text(
          INR_SYMBOL,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: DropdownSearch<SchoolWiseEmployeeBean>(
        mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
        selectedItem: employeesList.firstWhereOrNull((e) => e.employeeId == pocketTransaction.employeeId),
        items: employeesList,
        itemAsString: (SchoolWiseEmployeeBean? employee) {
          return employee?.employeeName ?? "-";
        },
        showSearchBox: true,
        dropdownBuilder: (BuildContext context, SchoolWiseEmployeeBean? employeeBean) {
          return _buildEmployeeBeanWidget(employeeBean ?? SchoolWiseEmployeeBean());
        },
        onChanged: (SchoolWiseEmployeeBean? employee) {
          setState(() => localStateSetter(() => pocketTransaction.employeeId = employee?.employeeId));
        },
        showClearButton: true,
        compareFn: (item, selectedItem) => item?.employeeId == selectedItem?.employeeId,
        dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
        filterFn: (SchoolWiseEmployeeBean? employee, String? key) {
          return (employee?.employeeName?.toLowerCase() ?? "").contains(key!.toLowerCase());
        },
      ),
    );
  }

  Widget _buildEmployeeBeanWidget(SchoolWiseEmployeeBean e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.all(5),
            child: e.photoUrl == null
                ? Image.asset(
                    "assets/images/avatar.png",
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    e.photoUrl!,
                    fit: BoxFit.contain,
                  ),
          ),
          Expanded(
            child: Text(e.employeeName ?? "-"),
          ),
        ],
      ),
    );
  }

  Widget amountTextFieldForPocketTransaction(PocketTransactionBean pocketTransaction, StateSetter localStateSetter) {
    return TextField(
      controller: pocketTransaction.amountController,
      keyboardType: TextInputType.number,
      maxLines: 1,
      decoration: InputDecoration(
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        border: const UnderlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'Amount',
        hintText: 'Amount',
        prefix: Text(
          INR_SYMBOL,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            if (double.parse(text) > 0) {
              return newValue;
            } else {
              return oldValue;
            }
          } catch (e) {
            return oldValue;
          }
        }),
      ],
      autofocus: false,
      onChanged: (String e) {
        setState(() => localStateSetter(() => pocketTransaction.amount = ((double.tryParse(e) ?? 0) * 100).round()));
      },
    );
  }

  Widget commentsForPocketTransaction(PocketTransactionBean pocketTransaction, StateSetter localStateSetter) {
    return TextField(
      controller: pocketTransaction.commentsController,
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
        setState(() => localStateSetter(() => pocketTransaction.comments = e));
      },
    );
  }

  Widget radioButtonsForCrOrDbForPocketTransaction(PocketTransactionBean pocketTransaction, StateSetter localStateSetter) {
    String employeeName = employeesList.firstWhereOrNull((e) => e.employeeId == pocketTransaction.employeeId)?.employeeName ?? "Employee";
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String?>(
          value: "LOAD",
          groupValue: pocketTransaction.pocketTransactionType,
          onChanged: (value) => setState(() => localStateSetter(() => pocketTransaction.pocketTransactionType = value)),
          title: Text("Add funds to $employeeName Wallet"),
        ),
        RadioListTile<String?>(
          value: "SPENT",
          groupValue: pocketTransaction.pocketTransactionType,
          onChanged: (value) => setState(() => localStateSetter(() => pocketTransaction.pocketTransactionType = value)),
          title: const Text("Transfer funds to School"),
        ),
      ],
    );
  }

  Widget buildModeOfPaymentDropdown(PocketTransactionBean pocketTransactionBean, StateSetter localStateSetter) {
    return ClayContainer(
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      depth: 40,
      emboss: false,
      child: DropdownButton<String>(
        value: pocketTransactionBean.modeOfPayment,
        items: ModeOfPayment.values
            .map((e) => DropdownMenuItem<String>(
                  value: e.name,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(e.description),
                  ),
                  onTap: () {
                    setState(() => localStateSetter(() => pocketTransactionBean.modeOfPayment = e.name));
                  },
                ))
            .toList(),
        onChanged: (String? e) {
          setState(() => localStateSetter(() => pocketTransactionBean.modeOfPayment = e ?? ModeOfPayment.CASH.name));
        },
      ),
    );
  }

  Widget dateTimePicker(PocketTransactionBean pocketTransaction, StateSetter localStateSetter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildPocketTransactionDatePicker(pocketTransaction, localStateSetter),
        const SizedBox(width: 10),
        buildPocketTransactionTimePicker(pocketTransaction, localStateSetter),
      ],
    );
  }

  Widget buildPocketTransactionDatePicker(PocketTransactionBean eachPocketTransaction, StateSetter localStateSetter) {
    String txnDate = eachPocketTransaction.date == null
        ? convertDateTimeToDDMMYYYYFormat(DateTime.now())
        : convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(DateTime.fromMillisecondsSinceEpoch(eachPocketTransaction.date!)))
            .replaceAll("\n", " ");
    return InkWell(
      onTap: () async {
        DateTime? _newDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 364)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          helpText: "Select a date",
        );
        if (_newDate == null) return;
        int existingMillis = eachPocketTransaction.date ?? DateTime.now().millisecondsSinceEpoch;
        TimeOfDay existingTime = convertDateTimeToTimeOfDay(DateTime.fromMillisecondsSinceEpoch(existingMillis));
        _newDate = DateTime(_newDate.year, _newDate.month, _newDate.day, existingTime.hour, existingTime.minute);
        setState(() => localStateSetter(() => eachPocketTransaction.date = _newDate!.millisecondsSinceEpoch));
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        spread: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(txnDate),
        ),
      ),
    );
  }

  Widget buildPocketTransactionTimePicker(PocketTransactionBean eachPocketTransaction, StateSetter localStateSetter) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.vibrate();
        TimeOfDay? expenseTimePicker = await showTimePicker(
          context: context,
          initialTime:
              convertDateTimeToTimeOfDay(DateTime.fromMillisecondsSinceEpoch(eachPocketTransaction.date ?? DateTime.now().millisecondsSinceEpoch)),
        );
        if (expenseTimePicker == null) return;
        DateTime existingDate = DateTime.fromMillisecondsSinceEpoch(eachPocketTransaction.date ?? DateTime.now().millisecondsSinceEpoch);
        DateTime newDateTime = DateTime(existingDate.year, existingDate.month, existingDate.day, expenseTimePicker.hour, expenseTimePicker.minute);
        setState(() => localStateSetter(() => eachPocketTransaction.date = newDateTime.millisecondsSinceEpoch));
      },
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        spread: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            convertDateTimeToHHMMA(DateTime.fromMillisecondsSinceEpoch(eachPocketTransaction.date ?? DateTime.now().millisecondsSinceEpoch)),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges(PocketTransactionBean pocketTransaction) async {
    if (mapEquals(pocketTransaction.toJson(), pocketTransaction.origJson())) {
      return;
    }
    setState(() => _isLoading = true);
    CreateOrUpdatePocketTransactionResponse createOrUpdatePocketTransactionResponse =
        await createOrUpdatePocketTransaction(CreateOrUpdatePocketTransactionRequest(
      agent: widget.adminProfile.userId,
      amount: pocketTransaction.amount,
      comments: pocketTransaction.comments,
      date: pocketTransaction.date,
      employeeId: pocketTransaction.employeeId,
      modeOfPayment: pocketTransaction.modeOfPayment,
      pocketTransactionId: pocketTransaction.pocketTransactionId,
      pocketTransactionType: pocketTransaction.pocketTransactionType,
      receiptId: pocketTransaction.receiptId,
      schoolId: pocketTransaction.schoolId,
      status: pocketTransaction.status,
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
      _loadData();
    }
    setState(() => _isLoading = false);
  }
}
