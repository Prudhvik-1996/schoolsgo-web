import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazy_data_table/lazy_data_table.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/common_components/date_range_picker.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  bool _isLoading = true;
  int widgetToDisplayIndex = 0;
  bool showOptions = true;
  List<String> widgetsToDisplay = ["Fee Stats", "Admin Expenses Stats"];
  bool showStats = false;

  List<StudentFeeReceipt> studentFeeReceipts = [];
  List<StudentFeeReceipt> studentFeeReceiptsToDisplay = [];
  List<RouteStopWiseStudent> routeStopWiseStudents = [];

  List<FeeType> feeTypes = [];

  Map<DateTime, List<StudentFeeReceipt>> dateWiseReceiptStatsMap = {};
  List<DateWiseAmountCollected> actualDateWiseAmountsCollected = [];
  List<DateWiseAmountCollected> dateWiseAmountsCollected = [];

  late DateTime maximumStartDate;
  late DateTime maximumEndDate;
  late DateTime fromDate;
  late DateTime toDate;

  List<StudentProfile> studentProfiles = [];
  Map<String, int> feeTypePaymentMap = {};
  Map<String, Map<String, int>> customFeeTypePaymentMap = {};

  List<AdminExpenseBean> adminExpenses = [];
  List<AdminExpenseBean> adminExpensesToDisplay = [];
  Map<String, int> expenseTypePaymentMap = {};
  List<DateWiseAmountSpent> dateWiseAmountsSpent = [];
  List<DateWiseAmountSpent> dateWiseAmountsSpentToShow = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await loadFeeData();
    await loadAdminExpenses();
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
      studentProfiles.sort((a, b) {
        int aSectionSeqOder = a.sectionSeqOrder ?? 0;
        int bSectionSeqOder = b.sectionSeqOrder ?? 0;
        int aRollNumber = int.tryParse(a.rollNumber ?? "") ?? 0;
        int bRollNumber = int.tryParse(b.rollNumber ?? "") ?? 0;
        return aSectionSeqOder != bSectionSeqOder ? aSectionSeqOder.compareTo(bSectionSeqOder) : aRollNumber.compareTo(bRollNumber);
      });
    }
    maximumStartDate = DateTime.fromMillisecondsSinceEpoch([
      if (studentFeeReceipts.isNotEmpty) studentFeeReceipts.map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).min.millisecondsSinceEpoch,
      if (adminExpenses.isNotEmpty) adminExpenses.map((e) => DateTime.fromMillisecondsSinceEpoch(e.transactionTime!)).min.millisecondsSinceEpoch,
      if (studentFeeReceipts.isEmpty && adminExpenses.isEmpty) DateTime.now().millisecondsSinceEpoch,
    ].min);
    maximumEndDate = DateTime.fromMillisecondsSinceEpoch([
      if (studentFeeReceipts.isNotEmpty) studentFeeReceipts.map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).max.millisecondsSinceEpoch,
      if (adminExpenses.isNotEmpty) adminExpenses.map((e) => DateTime.fromMillisecondsSinceEpoch(e.transactionTime!)).max.millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
    ].max);
    fromDate = convertYYYYMMDDFormatToDateTime(convertDateTimeToYYYYMMDDFormat(DateTime.now()));
    toDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 23, 59, 59, 0, 0);
    filterStudentReceipts();
    filterAdminExpenses();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadFeeData() async {
    GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).where((e) => e.status == 'active').toList();
      studentFeeReceipts.sort((b, a) {
        int dateCom = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
        return (dateCom == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateCom;
      });
    }

    GetBusRouteDetailsResponse getBusRouteDetailsResponse = await getBusRouteDetails(GetBusRouteDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getBusRouteDetailsResponse.httpStatus != "OK" || getBusRouteDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      routeStopWiseStudents = (getBusRouteDetailsResponse.busRouteInfoBeanList?.map((e) => e!).toList() ?? [])
          .map((e) => (e.busRouteStopsList ?? []).whereNotNull())
          .expand((i) => i)
          .map((e) => (e.students ?? []).whereNotNull())
          .expand((i) => i)
          .toList();
    }

    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getFeeTypesResponse.httpStatus != "OK" || getFeeTypesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
    }
  }

  Future<void> loadAdminExpenses() async {
    GetAdminExpensesResponse getAdminExpensesResponse = await getAdminExpenses(GetAdminExpensesRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
    ));
    if (getAdminExpensesResponse.httpStatus != "OK" || getAdminExpensesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      adminExpenses = getAdminExpensesResponse.adminExpenseBeanList!.map((e) => e!).where((e) => e.status == "active").toList()
        ..sort((b, a) {
          if (a.transactionTime != null && b.transactionTime != null) {
            return a.transactionTime!.compareTo(b.transactionTime!);
          }
          if (a.adminExpenseId != null && b.adminExpenseId != null) {
            return a.adminExpenseId!.compareTo(b.adminExpenseId!);
          }
          return 0;
        });
    }
  }

  void filterStudentReceipts() {
    studentFeeReceiptsToDisplay = studentFeeReceipts.map((e) => StudentFeeReceipt.fromJson(e.toJson())).where((e) {
      DateTime transactionDate = convertYYYYMMDDFormatToDateTime(e.transactionDate).add(const Duration(minutes: 1));
      return transactionDate.isAfter(fromDate) && toDate.isAfter(transactionDate);
    }).toList();
    for (final receipt in studentFeeReceiptsToDisplay) {
      if (receipt.transactionDate != null) {
        final dateString = receipt.transactionDate!;
        dateWiseReceiptStatsMap[convertYYYYMMDDFormatToDateTime(dateString)] ??= <StudentFeeReceipt>[];
        dateWiseReceiptStatsMap[convertYYYYMMDDFormatToDateTime(dateString)]!.add(receipt);
      }
    }
    DateTime? startDate =
        studentFeeReceiptsToDisplay.isEmpty ? null : studentFeeReceiptsToDisplay.map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).min;
    DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 1));
    final populatedDates = startDate == null ? [] : populateDates(startDate, endDate);
    actualDateWiseAmountsCollected = populatedDates.map((date) {
      final receipts = dateWiseReceiptStatsMap[date] ?? [];
      final totalAmountCollected = receipts
          .map((receipt) =>
              ((receipt.busFeePaid ?? 0) +
                  (receipt.feeTypes ?? []).fold<int>(
                      0,
                      (sum, feeType) =>
                          sum +
                          (feeType?.amountPaidForTheReceipt ?? 0) +
                          (feeType?.customFeeTypes ?? [])
                              .fold<int>(0, (sum, customFeeType) => sum + (customFeeType?.amountPaidForTheReceipt ?? 0)))) /
              100.0)
          .fold<double>(0, (sum, amount) => sum + amount);
      return DateWiseAmountCollected(date, totalAmountCollected);
    }).toList();
    actualDateWiseAmountsCollected.sort((a, b) => b.date.compareTo(a.date));
    feeTypePaymentMap = <String, int>{};
    for (FeeType feeType in feeTypes) {
      if ((feeType.customFeeTypesList ?? []).isEmpty) {
        feeTypePaymentMap["${feeType.feeType}"] = studentFeeReceiptsToDisplay
            .map((e) => e.feeTypes ?? [])
            .expand((i) => i)
            .where((e) => e?.feeTypeId == feeType.feeTypeId && (feeType.customFeeTypesList ?? []).isEmpty)
            .map((e) => e?.amountPaidForTheReceipt ?? 0)
            .fold(0, (a, b) => a + b);
      }
    }
    customFeeTypePaymentMap = <String, Map<String, int>>{};
    for (CustomFeeType customFeeType in feeTypes.map((e) => e.customFeeTypesList ?? []).expand((i) => i).whereNotNull()) {
      customFeeTypePaymentMap["${customFeeType.feeType}"] ??= {};
      customFeeTypePaymentMap["${customFeeType.feeType}"]!["${customFeeType.customFeeType}"] ??= 0;
      customFeeTypePaymentMap["${customFeeType.feeType}"]!["${customFeeType.customFeeType}"] = studentFeeReceiptsToDisplay
          .map((e) => e.feeTypes ?? [])
          .expand((i) => i)
          .where((e) => e?.feeTypeId == customFeeType.feeTypeId)
          .map((e) => e?.customFeeTypes ?? [])
          .expand((i) => i)
          .where((e) => e?.customFeeTypeId == customFeeType.customFeeTypeId)
          .map((e) => e?.amountPaidForTheReceipt ?? 0)
          .fold(0, (a, b) => a + b);
    }
  }

  void filterAdminExpenses() {
    adminExpensesToDisplay = adminExpenses.map((e) => AdminExpenseBean.fromJson(e.toJson())).where((e) {
      DateTime transactionDate = DateTime.fromMillisecondsSinceEpoch(e.transactionTime!).add(const Duration(minutes: 1));
      return transactionDate.isAfter(fromDate) && toDate.isAfter(transactionDate);
    }).toList();
    if (adminExpensesToDisplay.isEmpty) {
      dateWiseAmountsSpentToShow = [];
      expenseTypePaymentMap = {};
      return;
    }
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(adminExpensesToDisplay.map((e) => e.transactionTime).whereNotNull().min);
    DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 2));
    List<DateTime> populatedDates = populateDates(startDate, endDate);
    dateWiseAmountsSpent = populatedDates.reversed
        .map((eachDate) => DateWiseAmountSpent(
            eachDate,
            adminExpensesToDisplay
                .where((e) =>
                    e.transactionTime != null &&
                    convertDateTimeToYYYYMMDDFormat(DateTime.fromMillisecondsSinceEpoch(e.transactionTime!)) ==
                        convertDateTimeToYYYYMMDDFormat(eachDate))
                .map((e) => (e.amount ?? 0) / 100.0)
                .fold<double>(0, (sum, amount) => sum + amount)))
        .toList();
    dateWiseAmountsSpentToShow = dateWiseAmountsSpent.toList();

    for (String expenseType in adminExpensesToDisplay.map((e) => e.expenseType).whereNotNull().toSet()) {
      expenseTypePaymentMap[expenseType] =
          adminExpensesToDisplay.where((e) => e.expenseType == expenseType).map((e) => e.amount ?? 0).fold(0, (a, b) => a + b);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Financial Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => setState(() => showOptions = !showOptions),
          ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              children: [
                if (showOptions)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: buildDatePickerWidget(),
                        ),
                        buildDownloadButton(context),
                      ],
                    ),
                  ),
                if (showOptions) statsSwitcherWidget(),
                if (widgetToDisplayIndex == 0 && showStats) Expanded(child: SingleChildScrollView(child: feeStatsWidget())),
                if (widgetToDisplayIndex == 0 && !showStats) Expanded(child: feeStatsTable()),
                if (widgetToDisplayIndex == 1 && showStats) Expanded(child: SingleChildScrollView(child: adminExpensesStatsWidget())),
                if (widgetToDisplayIndex == 1 && !showStats) Expanded(child: adminExpensesStatsTable()),
              ],
            ),
    );
  }

  Widget buildDatePickerWidget() {
    return Row(
      children: [
        if (_isSingleDate)
          GestureDetector(
            onTap: () {
              if (fromDate.millisecondsSinceEpoch > maximumStartDate.millisecondsSinceEpoch) {
                setState(() {
                  fromDate = fromDate.subtract(const Duration(days: 1));
                  toDate = toDate.subtract(const Duration(days: 1));
                  filterStudentReceipts();
                  filterAdminExpenses();
                });
              }
            },
            child: ClayButton(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 100,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Icon(Icons.arrow_left),
                  ),
                ),
              ),
            ),
          ),
        if (_isSingleDate) const SizedBox(width: 10),
        Expanded(
          child: TextButton(
            onPressed: _showDatePickerDialog,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _buttonText,
                  style: GoogleFonts.archivoBlack(
                    textStyle: const TextStyle(
                      fontSize: 36,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isSingleDate) const SizedBox(width: 10),
        if (_isSingleDate)
          GestureDetector(
            onTap: () {
              if (maximumEndDate.millisecondsSinceEpoch > fromDate.millisecondsSinceEpoch) {
                setState(() {
                  fromDate = fromDate.add(const Duration(days: 1));
                  toDate = toDate.add(const Duration(days: 1));
                  filterStudentReceipts();
                  filterAdminExpenses();
                });
              }
            },
            child: ClayButton(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 100,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Icon(Icons.arrow_right),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Padding buildDownloadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Tooltip(
        message: "Download report",
        child: GestureDetector(
          onTap: () => _downloadReport(studentFeeReceiptsToDisplay, adminExpensesToDisplay),
          child: ClayButton(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 100,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Icon(Icons.download),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _downloadReport(List<StudentFeeReceipt> studentFeeReceipts, List<AdminExpenseBean> adminExpenses) {
    setState(() => _isLoading = true);
    // Create an Excel workbook
    var excel = Excel.createExcel();

    populateFeeDataInExcel(excel, studentFeeReceipts);
    populateAdminExpensesDataInExcel(excel, adminExpenses);

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
      FileSaver.instance.saveFile(bytes: excelUint8List, name: 'Financial Report.xlsx');
    }
    setState(() => _isLoading = false);
  }

  void populateFeeDataInExcel(Excel excel, List<StudentFeeReceipt> studentFeeReceipts) {
    // Add a sheet to the workbook
    Sheet sheet = excel['Fee'];

    // Define the headers
    var headers = [
      'Date',
      'Receipt No.',
      'Admission No.',
      'Class',
      'Roll No.',
      'Student Name',
      'Accommodation Type',
      'Amount Paid',
      'Mode Of Payment',
      'Details',
      'Comments',
    ];

    int rowIndex = 0;

    // Append the school name
    sheet.appendRow(["${widget.adminProfile.schoolName}"]);

    sheet.appendRow([_buttonText]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = dateStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 1));
    rowIndex++;

    // Apply formatting to the school name cell
    CellStyle schoolNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = schoolNameStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0));
    rowIndex++;

    sheet.appendRow(headers);
    for (int i = 0; i <= headers.length - 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;

    // Add the data rows to the sheet
    for (StudentFeeReceipt receipt in studentFeeReceipts) {
      sheet.appendRow([
        convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(receipt.transactionDate)),
        receipt.receiptNumber ?? "-",
        studentProfiles.where((e) => e.studentId == receipt.studentId).firstOrNull?.admissionNo ?? "-",
        receipt.sectionName,
        studentProfiles.where((e) => e.studentId == receipt.studentId).firstOrNull?.rollNumber ?? "-",
        receipt.studentName,
        studentProfiles.where((e) => e.studentId == receipt.studentId).firstOrNull?.getAccommodationType(e: "D") ?? "-",
        receipt.getTotalAmountForReceipt() / 100,
        ModeOfPaymentExt.fromString(receipt.modeOfPayment).description,
        getReceiptDescription(receipt).replaceAll("\n\n", "\r\n"),
        receipt.comments ?? "",
      ]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).cellStyle = CellStyle(textWrapping: TextWrapping.WrapText);
      rowIndex++;
    }

    // Deleting default sheet
    if (excel.getDefaultSheet() != null) {
      excel.delete(excel.getDefaultSheet()!);
    }

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["Fee Type", "Amount"]);
    for (int i = 0; i <= 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;
    for (var e in feeTypePaymentMap.entries) {
      sheet.appendRow([
        e.key,
        e.value / 100,
      ]);
      rowIndex++;
    }
    for (var feeTypeMap in customFeeTypePaymentMap.entries) {
      for (var customFeeTypeMap in feeTypeMap.value.entries) {
        sheet.appendRow([
          feeTypeMap.key + ": " + customFeeTypeMap.key,
          customFeeTypeMap.value / 100,
        ]);
        rowIndex++;
      }
    }
    sheet.appendRow([
      "Bus",
      (studentFeeReceipts.map((e) => e.busFeePaid ?? 0).fold(0, (int a, int b) => a + b)) / 100,
    ]);
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["Mode Of Payment", "Amount"]);
    for (int i = 0; i <= 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;
    final paymentMap = <ModeOfPayment, int>{};
    for (final receipt in studentFeeReceipts) {
      final modeOfPayment = ModeOfPaymentExt.fromString(receipt.modeOfPayment);
      final totalAmount = receipt.getTotalAmountForReceipt();
      paymentMap[modeOfPayment] = (paymentMap[modeOfPayment] ?? 0) + totalAmount;
    }
    paymentMap.forEach((key, value) {
      if (value != 0) {
        sheet.appendRow([key.description, value / 100.0]);
        rowIndex++;
      }
    });

    sheet.appendRow([
      "Total",
      paymentMap.values.sum / 100.0,
    ]);
    for (int i = 0; i <= 1; i++) {
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
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: rowIndex));

    // Auto fit the headers
    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }
  }

  void populateAdminExpensesDataInExcel(Excel excel, List<AdminExpenseBean> adminExpenses) {
    Sheet sheet = excel['Admin Expenses'];
    var headers = [
      'Date',
      'Expense Type',
      'Expense Description',
      'Amount',
      'Admin',
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

    sheet.appendRow([_buttonText]);
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = dateStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 1));
    rowIndex++;

    sheet.appendRow(headers);
    for (int i = 0; i <= headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;

    for (AdminExpenseBean expense in adminExpenses) {
      sheet.appendRow([
        convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(expense.transactionTime!)),
        expense.expenseType,
        expense.description,
        (expense.amount ?? 0) / 100.0,
        expense.adminName,
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
    for (var e in expenseTypePaymentMap.entries) {
      sheet.appendRow([
        e.key,
        e.value / 100,
      ]);
      rowIndex++;
    }

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["Mode Of Payment", "Amount"]);
    for (int i = 0; i <= 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;
    final paymentMap = <ModeOfPayment, int>{};
    for (final expense in adminExpenses) {
      final modeOfPayment = ModeOfPaymentExt.fromString(expense.modeOfPayment);
      final totalAmount = expense.amount ?? 0;
      paymentMap[modeOfPayment] = (paymentMap[modeOfPayment] ?? 0) + totalAmount;
    }
    paymentMap.forEach((key, value) {
      if (value != 0) {
        sheet.appendRow([key.description, value / 100.0]);
        rowIndex++;
      }
    });

    sheet.appendRow([
      "Total",
      paymentMap.values.sum / 100.0,
    ]);
    for (int i = 0; i <= 1; i++) {
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
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: rowIndex));

    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }
  }

  // Default text on the button
  String get _buttonText {
    if (_isSingleDate) {
      return convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(fromDate)).replaceAll("\n", " ");
    }
    return '${convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(fromDate)).replaceAll("\n", " ")} - ${convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(toDate)).replaceAll("\n", " ")}';
  }

  bool get _isSingleDate => convertDateTimeToYYYYMMDDFormat(fromDate) == convertDateTimeToYYYYMMDDFormat(toDate);

  // Method to show the DatePicker dialog
  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectionMode1;
        DateTime? startDate1;
        DateTime? endDate1;
        return AlertDialog(
          title: const Text('Select Date Range'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: SingleChildScrollView(
              child: DatePickerWidget(
                thresholdStartDate: maximumStartDate,
                thresholdEndDate: maximumEndDate,
                onDateSelected: (String selectionMode, DateTime? startDate, DateTime? endDate) {
                  setState(() {
                    selectionMode1 = selectionMode;
                    startDate1 = startDate;
                    endDate1 = endDate;
                  });
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog and apply the selection
                if (selectionMode1 != null) {
                  updateAsPerDateSelection(selectionMode1!, startDate1, endDate1);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void updateAsPerDateSelection(String selectionMode, DateTime? startDate, DateTime? endDate) {
    if (selectionMode == "Single Date" && startDate != null && endDate == null) {
      DateTime selectedDate = startDate;
      selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0, 0, 0);
      setState(() {
        fromDate = selectedDate;
        toDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59, 0, 0);
        filterStudentReceipts();
        filterAdminExpenses();
      });
    }
    if (startDate != null && endDate != null) {
      setState(() {
        fromDate = startDate;
        toDate = endDate;
        filterStudentReceipts();
        filterAdminExpenses();
      });
    }
  }

  Widget feeStatsTable() {
    if (studentFeeReceiptsToDisplay.isEmpty) return const Center(child: Text("No receipts to display"));
    double dateCellWidth = 100;
    double defaultCellWidth = 150;
    double defaultCellHeight = 40;
    List<LazyColumn> columns = [
      LazyColumn("Receipt No.", true, 100),
      LazyColumn("Admission No.", true, 120),
      LazyColumn("Class", true, 90),
      LazyColumn("Roll No.", true, 90),
      LazyColumn("Student Name", true, 200),
      LazyColumn("Accommodation", true, 130),
      LazyColumn("Amount Paid", true, 120),
      LazyColumn("Mode Of Payment", true, defaultCellWidth),
      LazyColumn("Details", true, 300),
      LazyColumn("Comments", true, 300),
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LazyDataTable(
        tableTheme: const LazyDataTableTheme(
          alternateCellColor: Colors.transparent,
          alternateColumnHeaderColor: Colors.transparent,
          alternateRowHeaderColor: Colors.transparent,
          cellColor: Colors.transparent,
          columnHeaderColor: Colors.transparent,
          cornerColor: Colors.transparent,
          rowHeaderColor: Colors.transparent,
          alternateColumn: true,
          alternateRow: true,
          alternateCellBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          alternateColumnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          alternateRowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          cellBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          columnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          cornerBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          rowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
        ),
        columns: columns.length,
        rows: studentFeeReceiptsToDisplay.length,
        tableDimensions: LazyDataTableDimensions(
          cellHeight: defaultCellHeight,
          cellWidth: defaultCellWidth,
          topHeaderHeight: defaultCellHeight,
          leftHeaderWidth: dateCellWidth,
          customCellWidth: Map<int, double>.fromEntries(columns.where((e) => e.isVisible).mapIndexed((i, e) => MapEntry(i, e.width))),
        ),
        topHeaderBuilder: (i) => clayCell(
          alignment: Alignment.center,
          child: Text(
            columns[i].columnName,
            style: const TextStyle(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          emboss: true,
        ),
        leftHeaderBuilder: (i) {
          StudentFeeReceipt receipt = studentFeeReceiptsToDisplay[i];
          return clayCell(
            alignment: Alignment.center,
            child: Text(
              convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(receipt.transactionDate)),
              textAlign: TextAlign.center,
            ),
            emboss: true,
          );
        },
        dataCellBuilder: (int rowIndex, int columnIndex) {
          StudentFeeReceipt receipt = studentFeeReceiptsToDisplay[rowIndex];
          StudentProfile? student = studentProfiles.firstWhereOrNull((e) => e.studentId == receipt.studentId);
          String cellText = "";
          LazyColumn column = columns.where((e) => e.isVisible).toList()[columnIndex];
          switch (column.columnName) {
            case "Receipt No.":
              cellText = "${receipt.receiptNumber ?? ""}";
              break;
            case "Admission No.":
              cellText = student?.admissionNo ?? "-";
              break;
            case "Class":
              cellText = receipt.sectionName ?? "-";
              break;
            case "Roll No.":
              cellText = student?.rollNumber ?? "-";
              break;
            case "Student Name":
              cellText = receipt.studentName ?? "-";
              break;
            case "Accommodation":
              cellText = student?.getAccommodationType() ?? "-";
              break;
            case "Amount Paid":
              cellText = "$INR_SYMBOL ${receipt.getTotalAmountForReceipt() / 100} /-";
              break;
            case "Mode Of Payment":
              cellText = ModeOfPaymentExt.fromString(receipt.modeOfPayment ?? "-").description;
              break;
            case "Details":
              cellText = getReceiptDescription(receipt).split("\n\n").join(", ");
              break;
            case "Comments":
              cellText = receipt.comments ?? "-";
              break;
            default:
              cellText = "-";
          }
          return Tooltip(
            message: cellText,
            child: clayCell(
              alignment: column.columnName == "Amount Paid" ? Alignment.centerRight : Alignment.centerLeft,
              child: AutoSizeText(
                cellText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                minFontSize: 7,
                maxFontSize: 12,
                softWrap: true,
              ),
              emboss: true,
            ),
          );
        },
        topLeftCornerWidget: clayCell(
          alignment: Alignment.center,
          child: const Text(
            "Date",
            style: TextStyle(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          emboss: true,
        ),
      ),
    );
  }

  Widget adminExpensesStatsTable() {
    if (adminExpensesToDisplay.isEmpty) return const Center(child: Text("No expenses to display"));
    double dateCellWidth = 100;
    double defaultCellWidth = 150;
    double defaultCellHeight = 40;
    List<LazyColumn> columns = [
      LazyColumn("Expense Type", true, 200),
      LazyColumn("Expense Description", true, 300),
      LazyColumn("Amount", true, 100),
      LazyColumn("Mode Of Payment", true, defaultCellWidth),
      LazyColumn("Admin Name", true, 200),
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LazyDataTable(
        tableTheme: const LazyDataTableTheme(
          alternateCellColor: Colors.transparent,
          alternateColumnHeaderColor: Colors.transparent,
          alternateRowHeaderColor: Colors.transparent,
          cellColor: Colors.transparent,
          columnHeaderColor: Colors.transparent,
          cornerColor: Colors.transparent,
          rowHeaderColor: Colors.transparent,
          alternateColumn: true,
          alternateRow: true,
          alternateCellBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          alternateColumnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          alternateRowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          cellBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          columnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          cornerBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          rowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
        ),
        columns: columns.length,
        rows: adminExpensesToDisplay.length,
        tableDimensions: LazyDataTableDimensions(
          cellHeight: defaultCellHeight,
          cellWidth: defaultCellWidth,
          topHeaderHeight: defaultCellHeight,
          leftHeaderWidth: dateCellWidth,
          customCellWidth: Map<int, double>.fromEntries(columns.where((e) => e.isVisible).mapIndexed((i, e) => MapEntry(i, e.width))),
        ),
        topHeaderBuilder: (i) => clayCell(
          alignment: Alignment.center,
          child: Text(
            columns[i].columnName,
            style: const TextStyle(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          emboss: true,
        ),
        leftHeaderBuilder: (i) {
          AdminExpenseBean expense = adminExpensesToDisplay[i];
          return clayCell(
            alignment: Alignment.center,
            child: Text(
              convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(expense.transactionTime!)),
              textAlign: TextAlign.center,
            ),
            emboss: true,
          );
        },
        dataCellBuilder: (int rowIndex, int columnIndex) {
          AdminExpenseBean expense = adminExpensesToDisplay[rowIndex];
          String cellText = "";
          LazyColumn column = columns.where((e) => e.isVisible).toList()[columnIndex];
          switch (column.columnName) {
            case "Expense Type":
              cellText = expense.expenseType ?? "-";
              break;
            case "Expense Description":
              cellText = expense.description ?? "-";
              break;
            case "Amount":
              cellText = "$INR_SYMBOL ${(expense.amount ?? 0) / 100} /-";
              break;
            case "Mode Of Payment":
              cellText = ModeOfPaymentExt.fromString(expense.modeOfPayment ?? "-").description;
              break;
            case "Admin":
              cellText = expense.adminName ?? "-";
              break;
            default:
              cellText = "-";
          }
          return Tooltip(
            message: cellText,
            child: clayCell(
              alignment: column.columnName == "Amount" ? Alignment.centerRight : Alignment.centerLeft,
              child: AutoSizeText(
                cellText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                minFontSize: 7,
                maxFontSize: 12,
                softWrap: true,
              ),
              emboss: true,
            ),
          );
        },
        topLeftCornerWidget: clayCell(
          alignment: Alignment.center,
          child: const Text(
            "Date",
            style: TextStyle(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          emboss: true,
        ),
      ),
    );
  }

  String getReceiptDescription(StudentFeeReceipt receipt) {
    List<String> feeTypeWiseDescriptions = [];
    List<String> customFeeTypeWiseDescriptions = [];
    List<String> busFeeTypeWiseDescriptions = [];

    for (FeeTypeOfReceipt eachFeeType in (receipt.feeTypes ?? []).whereNotNull()) {
      if ((eachFeeType.customFeeTypes ?? []).whereNotNull().isEmpty && (eachFeeType.amountPaidForTheReceipt ?? 0) != 0) {
        feeTypeWiseDescriptions.add("${eachFeeType.feeType ?? " - "}: ${(eachFeeType.amountPaidForTheReceipt ?? 0) / 100}");
      } else {
        for (CustomFeeTypeOfReceipt eachCustomFeeType in (eachFeeType.customFeeTypes ?? []).whereNotNull()) {
          if ((eachCustomFeeType.amountPaidForTheReceipt ?? 0) != 0) {
            customFeeTypeWiseDescriptions.add(
                "${eachFeeType.feeType ?? " - "} - ${eachCustomFeeType.customFeeType ?? " - "}: ${(eachCustomFeeType.amountPaidForTheReceipt ?? 0) / 100}");
          }
        }
      }
    }
    if ((receipt.busFeePaid ?? 0) != 0) {
      busFeeTypeWiseDescriptions.add("Bus Fee: ${(receipt.busFeePaid ?? 0) / 100}");
    }

    return [...feeTypeWiseDescriptions, ...customFeeTypeWiseDescriptions, ...busFeeTypeWiseDescriptions].join("\n\n");
  }

  Padding statsSwitcherWidget() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...widgetsToDisplay
              .mapIndexed(
                (int index, String e) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index == widgetToDisplayIndex ? Colors.blue : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: index == widgetToDisplayIndex ? Colors.blue : Colors.grey,
                    ),
                    child: InkWell(
                      onTap: () => setState(() => widgetToDisplayIndex = index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            e,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: showStats ? "Hide Stats" : "Show Stats",
              child: GestureDetector(
                onTap: () => setState(() => showStats = !showStats),
                child: ClayButton(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: showStats ? const Icon(Icons.table_rows) : const Icon(Icons.info_outline),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget feeStatsWidget() {
    if (studentFeeReceiptsToDisplay.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text("No receipts in the selected date range..")),
      );
    }
    List<StudentFeeReceipt> receiptsToBeAccounted = studentFeeReceiptsToDisplay
        .where((e) => e.transactionDate != null)
        .where((e) =>
            convertYYYYMMDDFormatToDateTime(e.transactionDate!).millisecondsSinceEpoch >= fromDate.millisecondsSinceEpoch &&
            convertYYYYMMDDFormatToDateTime(e.transactionDate!).millisecondsSinceEpoch <= toDate.millisecondsSinceEpoch)
        .toList();
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        emboss: true,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: feeTypeWiseStats(receiptsToBeAccounted)),
                  if (MediaQuery.of(context).orientation == Orientation.landscape) const SizedBox(width: 20),
                  if (MediaQuery.of(context).orientation == Orientation.landscape)
                    CustomVerticalDivider(
                      height: 300,
                      width: 1,
                      color: clayContainerTextColor(context),
                    ),
                  if (MediaQuery.of(context).orientation == Orientation.landscape) const SizedBox(width: 20),
                  if (MediaQuery.of(context).orientation == Orientation.landscape)
                    Expanded(flex: 2, child: _modeOfPaymentPieChartForFeeWidget(receiptsToBeAccounted)),
                ],
              ),
              if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 10),
              if (MediaQuery.of(context).orientation == Orientation.portrait)
                Divider(
                  thickness: 2,
                  color: clayContainerTextColor(context),
                ),
              if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 10),
              if (MediaQuery.of(context).orientation == Orientation.portrait)
                Center(
                  child: _modeOfPaymentPieChartForFeeWidget(receiptsToBeAccounted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget feeTypeWiseStats(List<StudentFeeReceipt> receiptsToBeAccounted) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...feeTypes.map(
            (eachFeeType) {
              double feeTypeAmount = (receiptsToBeAccounted
                      .map((e) => (e.feeTypes ?? []))
                      .expand((i) => i)
                      .where((e) => (e?.customFeeTypes ?? []).isEmpty)
                      .where((e) => e?.feeTypeId == eachFeeType.feeTypeId)
                      .map((e) => e?.amountPaidForTheReceipt ?? 0)
                      .fold(0, (int a, b) => a + b)) /
                  100.0;
              return ((eachFeeType.customFeeTypesList ?? []).isEmpty)
                  ? [
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(child: Text(eachFeeType.feeType ?? "-")),
                            Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(feeTypeAmount)} /-"),
                          ],
                        ),
                      ),
                    ]
                  : [
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(eachFeeType.feeType ?? "-"),
                            ...(eachFeeType.customFeeTypesList ?? []).map(
                              (eachCustomFeeType) {
                                double customFeeTypeAmount = (receiptsToBeAccounted
                                        .map((e) => (e.feeTypes ?? []))
                                        .expand((i) => i)
                                        .where((e) => (e?.customFeeTypes ?? []).isNotEmpty)
                                        .map((e) => e?.customFeeTypes ?? [])
                                        .expand((i) => i)
                                        .where((e) => e?.customFeeTypeId == eachCustomFeeType?.customFeeTypeId)
                                        .map((e) => e?.amountPaidForTheReceipt ?? 0)
                                        .fold(0, (int a, b) => a + b)) /
                                    100.0;
                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      const CustomVerticalDivider(),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(eachCustomFeeType?.customFeeType ?? "-")),
                                      Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(customFeeTypeAmount)} /-"),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ];
            },
          ).expand((i) => i),
          Container(
            margin: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Expanded(child: Text("Bus Fee")),
                Text(
                  "$INR_SYMBOL ${doubleToStringAsFixedForINR(receiptsToBeAccounted.map((e) => e.busFeePaid ?? 0).fold(0, (int a, b) => a + b) / 100.0)} /-",
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Container(
            margin: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Expanded(child: Text("Total", style: TextStyle(color: Colors.blue))),
                Text(
                  "$INR_SYMBOL ${doubleToStringAsFixedForINR(receiptsToBeAccounted.map((e) => e.getTotalAmountForReceipt()).fold(0, (int a, b) => a + b) / 100.0)} /-",
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeOfPaymentPieChartForFeeWidget(List<StudentFeeReceipt> studentFeeReceipts) {
    final modeOfPaymentMap = <ModeOfPayment, int>{};
    for (final receipt in studentFeeReceipts) {
      final modeOfPayment = ModeOfPaymentExt.fromString(receipt.modeOfPayment);
      final totalAmount = receipt.getTotalAmountForReceipt();
      modeOfPaymentMap[modeOfPayment] = (modeOfPaymentMap[modeOfPayment] ?? 0) + totalAmount;
    }
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: charts.PieChart<String>(
                    generatePieChartDataForFee(studentFeeReceipts),
                    animate: true,
                    defaultRenderer: charts.ArcRendererConfig(
                      arcRendererDecorators: [
                        charts.ArcLabelDecorator(
                          labelPosition: charts.ArcLabelPosition.inside,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ModeOfPayment.values.map((e) => ModeOfPaymentExt.getChartLedgerRow(e)).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: MediaQuery.of(context).orientation == Orientation.landscape ? 2 : 1,
            color: clayContainerTextColor(context),
          ),
          const SizedBox(height: 10),
          ...modeOfPaymentWiseWidgets(modeOfPaymentMap),
        ],
      ),
    );
  }

  Widget _modeOfPaymentPieChartForAdminExpensesWidget(List<AdminExpenseBean> adminExpenses) {
    final modeOfPaymentMap = <ModeOfPayment, int>{};
    for (final expense in adminExpenses) {
      final modeOfPayment = ModeOfPaymentExt.fromString(expense.modeOfPayment);
      modeOfPaymentMap[modeOfPayment] = (modeOfPaymentMap[modeOfPayment] ?? 0) + (expense.amount ?? 0);
    }
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: charts.PieChart<String>(
                    generatePieChartDataForAdminExpenses(adminExpenses),
                    animate: true,
                    defaultRenderer: charts.ArcRendererConfig(
                      arcRendererDecorators: [
                        charts.ArcLabelDecorator(
                          labelPosition: charts.ArcLabelPosition.inside,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ModeOfPayment.values.map((e) => ModeOfPaymentExt.getChartLedgerRow(e)).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: MediaQuery.of(context).orientation == Orientation.landscape ? 2 : 1,
            color: clayContainerTextColor(context),
          ),
          const SizedBox(height: 10),
          ...modeOfPaymentWiseWidgets(modeOfPaymentMap),
        ],
      ),
    );
  }

  Iterable<Widget> modeOfPaymentWiseWidgets(Map<ModeOfPayment, int> paymentMap) => paymentMap.entries.map((e) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "${e.key.description}:",
              ),
            ),
            Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(e.value / 100)} /-"),
          ],
        ),
      ));

  Widget datePickerWidget({
    String? toolTip,
    String dateString = "-",
    Future<void> Function()? pickDateAction,
  }) {
    return Tooltip(
      message: toolTip,
      child: GestureDetector(
        onTap: () async {
          if (pickDateAction != null) await pickDateAction();
        },
        child: ClayButton(
          depth: 40,
          spread: 2,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(dateString),
            ),
          ),
        ),
      ),
    );
  }

  Widget adminExpensesStatsWidget() {
    if (adminExpensesToDisplay.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: Text("No Admin Expenses in the selected date range..")),
      );
    }
    Set<String> uniqueExpenseTypes = adminExpensesToDisplay.map((e) => e.expenseType).whereNotNull().toSet();
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        emboss: true,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: expenseWiseStats(uniqueExpenseTypes, adminExpensesToDisplay)),
                  if (MediaQuery.of(context).orientation == Orientation.landscape) const SizedBox(width: 20),
                  if (MediaQuery.of(context).orientation == Orientation.landscape)
                    CustomVerticalDivider(
                      height: 300,
                      width: 1,
                      color: clayContainerTextColor(context),
                    ),
                  const SizedBox(width: 10),
                  if (MediaQuery.of(context).orientation == Orientation.landscape)
                    _modeOfPaymentPieChartForAdminExpensesWidget(adminExpensesToDisplay),
                ],
              ),
              if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 10),
              if (MediaQuery.of(context).orientation == Orientation.portrait)
                Divider(
                  thickness: 2,
                  color: clayContainerTextColor(context),
                ),
              if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 10),
              if (MediaQuery.of(context).orientation == Orientation.portrait) _modeOfPaymentPieChartForAdminExpensesWidget(adminExpensesToDisplay),
            ],
          ),
        ),
      ),
    );
  }

  Widget expenseWiseStats(Set<String> uniqueExpenseTypes, List<AdminExpenseBean> adminExpensesToBeConsidered) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ...uniqueExpenseTypes.map((eachExpenseType) {
            double amount = adminExpensesToDisplay
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
                  "$INR_SYMBOL ${doubleToStringAsFixedForINR(adminExpensesToBeConsidered.map((e) => e.amount ?? 0).fold(0, (int a, b) => a + b) / 100.0)} /-",
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget clayCell({
    Widget? child,
    EdgeInsetsGeometry? margin = const EdgeInsets.all(2),
    EdgeInsetsGeometry? padding = const EdgeInsets.all(8),
    bool emboss = false,
    double height = double.infinity,
    double width = double.infinity,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      margin: margin,
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 4,
        emboss: emboss,
        child: alignment == null
            ? Container(
                padding: padding,
                height: height,
                width: width,
                child: child,
              )
            : Align(
                alignment: alignment,
                child: Container(
                  padding: padding,
                  height: height,
                  width: width,
                  child: child,
                ),
              ),
      ),
    );
  }

  List<charts.Series<PaymentSummary, String>> generatePieChartDataForFee(List<StudentFeeReceipt> studentFeeReceipts) {
    // Create a map to store the total amounts for each mode of payment
    final paymentMap = <ModeOfPayment, int>{};

    for (ModeOfPayment eachPaymentMethod in ModeOfPayment.values) {
      paymentMap[eachPaymentMethod] = 0;
    }

    // Calculate the total amounts for each mode of payment
    for (final receipt in studentFeeReceipts) {
      final modeOfPayment = ModeOfPaymentExt.fromString(receipt.modeOfPayment);
      final totalAmount = receipt.getTotalAmountForReceipt();
      paymentMap[modeOfPayment] = (paymentMap[modeOfPayment] ?? 0) + totalAmount;
    }

    // Create a list of PaymentSummary objects from the map
    final data = paymentMap.entries.map((entry) {
      final modeOfPayment = entry.key;
      final totalAmount = entry.value;

      return PaymentSummary(
        modeOfPayment.description, // Use the modeOfPayment as the category label
        totalAmount / 100.0, ModeOfPaymentExt.getChartColorForModeOfPayment(modeOfPayment), // Assign a color to each modeOfPayment
      );
    }).toList();

    // Create a series for the pie chart
    return [
      charts.Series<PaymentSummary, String>(
        id: 'PaymentSummary',
        domainFn: (PaymentSummary summary, _) => summary.modeOfPayment,
        measureFn: (PaymentSummary summary, _) => summary.totalAmount,
        colorFn: (PaymentSummary summary, _) => summary.color,
        data: data,
        labelAccessorFn: (PaymentSummary summary, _) => '$INR_SYMBOL ${doubleToStringAsFixedForINR(summary.totalAmount)}',
      ),
    ];
  }

  List<charts.Series<PaymentSummary, String>> generatePieChartDataForAdminExpenses(List<AdminExpenseBean> adminExpenses) {
    // Create a map to store the total amounts for each mode of payment
    final paymentMap = <ModeOfPayment, int>{};

    for (ModeOfPayment eachPaymentMethod in ModeOfPayment.values) {
      paymentMap[eachPaymentMethod] = 0;
    }

    // Calculate the total amounts for each mode of payment
    for (final expense in adminExpenses) {
      final modeOfPayment = ModeOfPaymentExt.fromString(expense.modeOfPayment);
      paymentMap[modeOfPayment] = (paymentMap[modeOfPayment] ?? 0) + (expense.amount ?? 0);
    }

    // Create a list of PaymentSummary objects from the map
    final data = paymentMap.entries.map((entry) {
      final modeOfPayment = entry.key;
      final totalAmount = entry.value;

      return PaymentSummary(
        modeOfPayment.description, // Use the modeOfPayment as the category label
        totalAmount / 100.0, ModeOfPaymentExt.getChartColorForModeOfPayment(modeOfPayment), // Assign a color to each modeOfPayment
      );
    }).toList();

    // Create a series for the pie chart
    return [
      charts.Series<PaymentSummary, String>(
        id: 'PaymentSummary',
        domainFn: (PaymentSummary summary, _) => summary.modeOfPayment,
        measureFn: (PaymentSummary summary, _) => summary.totalAmount,
        colorFn: (PaymentSummary summary, _) => summary.color,
        data: data,
        labelAccessorFn: (PaymentSummary summary, _) => '$INR_SYMBOL ${doubleToStringAsFixedForINR(summary.totalAmount)}',
      ),
    ];
  }
}

class DateWiseAmountCollected {
  final DateTime date;
  final double amount;

  DateWiseAmountCollected(this.date, this.amount);
}

class DateWiseAmountSpent {
  DateTime date;
  double amount;

  DateWiseAmountSpent(this.date, this.amount);
}

class LazyColumn {
  String columnName;
  bool isVisible;
  double width;

  LazyColumn(this.columnName, this.isVisible, this.width);
}

class PaymentSummary {
  final String modeOfPayment;
  final double totalAmount;
  final charts.Color color;

  PaymentSummary(this.modeOfPayment, this.totalAmount, this.color);
}
