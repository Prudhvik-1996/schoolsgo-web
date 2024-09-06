import 'dart:typed_data';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/stats/date_wise_receipts_stats.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class DateWiseReceiptStats extends StatefulWidget {
  const DateWiseReceiptStats({
    Key? key,
    required this.adminProfile,
    required this.studentFeeReceipts,
    required this.routeStopWiseStudents,
    required this.isDefaultGraphView,
    required this.showAllDates,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentFeeReceipt>? studentFeeReceipts;
  final List<RouteStopWiseStudent>? routeStopWiseStudents;
  final bool isDefaultGraphView;
  final bool showAllDates;

  @override
  State<DateWiseReceiptStats> createState() => _DateWiseReceiptStatsState();
}

class _DateWiseReceiptStatsState extends State<DateWiseReceiptStats> {
  bool _isLoading = true;

  List<StudentFeeReceipt> studentFeeReceipts = [];
  List<RouteStopWiseStudent> routeStopWiseStudents = [];

  bool _isGraphView = false;
  bool _showOnlyNonZero = true;
  final ScrollController _mainBodyController = ScrollController();

  List<FeeType> feeTypes = [];

  Map<DateTime, List<StudentFeeReceipt>> dateWiseReceiptStatsMap = {};
  List<DateWiseAmountCollected> actualDateWiseAmountsCollected = [];
  List<DateWiseAmountCollected> dateWiseAmountsCollected = [];

  final ScrollController _graphViewController = ScrollController();

  late DateTime selectedDate;
  double? selectedAmount;

  late DateTime fromDate;
  late DateTime toDate;

  List<StudentProfile> studentProfiles = [];
  Map<String, int> feeTypePaymentMap = {};
  Map<String, Map<String, int>> customFeeTypePaymentMap = {};

  @override
  void initState() {
    super.initState();
    _isGraphView = widget.isDefaultGraphView;
    if (_isGraphView) {
      _showOnlyNonZero = true;
    }
    if (widget.showAllDates) {
      _showOnlyNonZero = false;
    }
    _loadData();
    if (studentFeeReceipts.isEmpty) return;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.studentFeeReceipts != null) {
      studentFeeReceipts = widget.studentFeeReceipts!;
    } else {
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
    }

    if (widget.routeStopWiseStudents != null) {
      routeStopWiseStudents = widget.routeStopWiseStudents!;
    } else {
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
      setState(() {
        feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
      });
    }

    for (final receipt in studentFeeReceipts) {
      if (receipt.transactionDate != null) {
        final dateString = receipt.transactionDate!;
        dateWiseReceiptStatsMap[convertYYYYMMDDFormatToDateTime(dateString)] ??= <StudentFeeReceipt>[];
        dateWiseReceiptStatsMap[convertYYYYMMDDFormatToDateTime(dateString)]!.add(receipt);
      }
    }
    DateTime startDate = studentFeeReceipts.map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).min;
    DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 1));
    final populatedDates = populateDates(startDate, endDate);
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
    handleVisibilityOfNonZero();
    feeTypePaymentMap = <String, int>{};
    for (FeeType feeType in feeTypes) {
      if ((feeType.customFeeTypesList ?? []).isEmpty) {
        feeTypePaymentMap["${feeType.feeType}"] = studentFeeReceipts
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
      customFeeTypePaymentMap["${customFeeType.feeType}"]!["${customFeeType.customFeeType}"] = studentFeeReceipts
          .map((e) => e.feeTypes ?? [])
          .expand((i) => i)
          .where((e) => e?.feeTypeId == customFeeType.feeTypeId)
          .map((e) => e?.customFeeTypes ?? [])
          .expand((i) => i)
          .where((e) => e?.customFeeTypeId == customFeeType.customFeeTypeId)
          .map((e) => e?.amountPaidForTheReceipt ?? 0)
          .fold(0, (a, b) => a + b);
    }
    fromDate = studentFeeReceipts.map((e) => e.transactionDate).whereNotNull().map((e) => convertYYYYMMDDFormatToDateTime(e)).min;
    toDate = studentFeeReceipts.map((e) => e.transactionDate).whereNotNull().map((e) => convertYYYYMMDDFormatToDateTime(e)).max;
    setState(() {
      _isLoading = false;
    });
    if (widget.isDefaultGraphView) {
      await Future.delayed(const Duration(milliseconds: 500));
      scrollToBody();
    }
  }

  void handleVisibilityOfNonZero() {
    setState(() {
      dateWiseAmountsCollected = actualDateWiseAmountsCollected.where((e) => _showOnlyNonZero ? e.amount != 0 : true).toList();
      selectedDate = dateWiseAmountsCollected[0].date;
      selectedAmount = dateWiseAmountsCollected[0].amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Date wise Fee Stats"),
        actions: [
          const SizedBox(width: 10),
          Tooltip(
            message: _showOnlyNonZero ? "Show all dates" : "Show only dates with transactions",
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showOnlyNonZero = !_showOnlyNonZero;
                });
                handleVisibilityOfNonZero();
              },
              icon: Icon(_showOnlyNonZero ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: _isGraphView ? "Switch to Grid View" : "Switch to Graph View",
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isGraphView = !_isGraphView;
                });
                if (_isGraphView) {
                  scrollToBody();
                }
              },
              icon: Icon(_isGraphView ? Icons.grid_view : Icons.auto_graph_sharp),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : studentFeeReceipts.isEmpty
              ? const Center(child: Text("No transactions to display"))
              : ListView(
                  controller: _mainBodyController,
                  children: [
                    _fromDateToDateStatsWidget(),
                    _isGraphView
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              selectedDateWidget(),
                              SizedBox(
                                height: MediaQuery.of(context).size.height - 250,
                                width: MediaQuery.of(context).size.width,
                                child: graphWidget(context),
                              ),
                            ],
                          )
                        : gridWidget(context),
                  ],
                ),
    );
  }

  void scrollToBody() {
    _mainBodyController.animateTo(
      _mainBodyController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget selectedDateWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 200,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "Amount Collected for ${convertDateToDDMMMYYYEEEE(convertDateTimeToYYYYMMDDFormat(selectedDate))}: ",
                children: [
                  TextSpan(
                    text: "$INR_SYMBOL ${doubleToStringAsFixedForINR(selectedAmount)} /-",
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ],
                style: const TextStyle(
                  color: Colors.blue,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget gridWidget(BuildContext context) {
    List<DateWiseAmountCollected> selectedDateWiseAmountCollected = dateWiseAmountsCollected
        .where(
            (e) => e.date.millisecondsSinceEpoch >= fromDate.millisecondsSinceEpoch && e.date.millisecondsSinceEpoch <= toDate.millisecondsSinceEpoch)
        .toList();
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: selectedDateWiseAmountCollected.length,
      itemBuilder: (context, index) {
        final date = selectedDateWiseAmountCollected[index].date;
        final amount = selectedDateWiseAmountCollected[index].amount;
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DateWiseReceiptsStatsWidget(
                adminProfile: widget.adminProfile,
                studentFeeReceipts: studentFeeReceipts.where((e) => e.transactionDate == convertDateTimeToYYYYMMDDFormat(date)).toList(),
                selectedDate: date,
                routeStopWiseStudents: routeStopWiseStudents,
                feeTypes: feeTypes,
              );
            }));
          },
          child: ClayButton(
            depth: 40,
            spread: 2,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            borderRadius: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: selectedDate == date ? Colors.blue : Colors.black,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Center(
                      child: Text(
                        convertDateTimeToDDMMYYYYFormat(date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$INR_SYMBOL ${doubleToStringAsFixedForINR(amount)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget graphWidget(BuildContext context) {
    List<DateWiseAmountCollected> selectedDateWiseAmountCollected = dateWiseAmountsCollected
        .where(
            (e) => e.date.millisecondsSinceEpoch >= fromDate.millisecondsSinceEpoch && e.date.millisecondsSinceEpoch <= toDate.millisecondsSinceEpoch)
        .toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _graphViewController,
        child: ListView(
          scrollDirection: Axis.horizontal,
          controller: _graphViewController,
          physics: const ClampingScrollPhysics(),
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: selectedDateWiseAmountCollected.length * 100,
                child: charts.BarChart(
                  [
                    charts.Series<DateWiseAmountCollected, String>(
                      id: 'Receipts',
                      domainFn: (DateWiseAmountCollected data, _) => convertDateTimeToDDMMYYYYFormat(data.date),
                      measureFn: (DateWiseAmountCollected data, _) => data.amount,
                      colorFn: (_, __) => charts.Color.fromHex(code: '#61c5dc'),
                      data: selectedDateWiseAmountCollected,
                    ),
                  ],
                  animate: false,
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                      (num? value) {
                        if (value == null) return "0";
                        final formatter = NumberFormat('#,##,###');
                        return formatter.format(value);
                      },
                    ),
                    renderSpec: charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 12,
                        color: isDarkTheme(context) ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                      ),
                    ),
                  ),
                  domainAxis: charts.OrdinalAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 12,
                        color: isDarkTheme(context) ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                      ),
                    ),
                  ),
                  selectionModels: [
                    charts.SelectionModelConfig(
                      type: charts.SelectionModelType.info,
                      changedListener: (charts.SelectionModel<String>? model) {
                        final selectedDatum = model?.selectedDatum;
                        setState(() {
                          if (selectedDatum != null && selectedDatum.isNotEmpty) {
                            selectedDate = selectedDatum.first.datum.date;
                            selectedAmount = selectedDatum.first.datum.amount;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fromDateToDateStatsWidget() {
    List<StudentFeeReceipt> receiptsToBeAccounted = studentFeeReceipts
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
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Summary",
                        style: GoogleFonts.archivoBlack(
                          textStyle: TextStyle(
                            fontSize: 36,
                            color: clayContainerTextColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  downloadReportButton(),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: datePickerWidget(
                      toolTip: "Pick From Date",
                      dateString: "From Date: ${convertDateTimeToDDMMYYYYFormat(fromDate)}",
                      pickDateAction: () async {
                        DateTime? _newDate = await showDatePicker(
                          context: context,
                          initialDate: fromDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: toDate,
                          helpText: "Pick from date",
                        );
                        if (_newDate == null || _newDate.millisecondsSinceEpoch == fromDate.millisecondsSinceEpoch) return;
                        setState(() {
                          fromDate = _newDate;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: datePickerWidget(
                      toolTip: "Pick To Date",
                      dateString: "To Date: ${convertDateTimeToDDMMYYYYFormat(toDate)}",
                      pickDateAction: () async {
                        DateTime? _newDate = await showDatePicker(
                          context: context,
                          initialDate: toDate,
                          firstDate: fromDate,
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                          helpText: "Pick to date",
                        );
                        if (_newDate == null || _newDate.millisecondsSinceEpoch == toDate.millisecondsSinceEpoch) return;
                        setState(() {
                          toDate = _newDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
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
                    Expanded(flex: 2, child: modeOfPaymentPieChartWidget(receiptsToBeAccounted)),
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
                  child: modeOfPaymentPieChartWidget(receiptsToBeAccounted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget downloadReportButton() {
    return Tooltip(
      message: getReportName(),
      textAlign: TextAlign.center,
      child: GestureDetector(
        onTap: () async => _downloadReport(studentFeeReceipts.where((e) {
          var transactionDate = convertYYYYMMDDFormatToDateTime(e.transactionDate);
          return transactionDate.isAfter(fromDate.subtract(const Duration(days: 1))) && transactionDate.isBefore(toDate.add(const Duration(days: 1)));
        }).toList()),
        child: ClayButton(
          depth: 40,
          spread: 2,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 100,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(Icons.download),
            ),
          ),
        ),
      ),
    );
  }

  String getReportName() => "Download report\nfrom ${convertDateTimeToDDMMYYYYFormat(fromDate)}\nto ${convertDateTimeToDDMMYYYYFormat(toDate)}";

  Future<void> _loadStudentProfiles() async {
    setState(() => _isLoading = true);
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
    }
    setState(() => _isLoading = false);
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
                  "$INR_SYMBOL ${doubleToStringAsFixedForINR(receiptsToBeAccounted.map((e) => e.getTotalAmountForReceipt() ?? 0).fold(0, (int a, b) => a + b) / 100.0)} /-",
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          // TODO
        ],
      ),
    );
  }

  Widget modeOfPaymentPieChartWidget(List<StudentFeeReceipt> studentFeeReceipts) {
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

  Future<void> _downloadReport(List<StudentFeeReceipt> studentFeeReceipts) async {
    if (studentProfiles.isEmpty) {
      await _loadStudentProfiles();
    }
    setState(() => _isLoading = true);
    // Create an Excel workbook
    var excel = Excel.createExcel();

    // Add a sheet to the workbook
    Sheet sheet = excel['Report'];

    int rowIndex = 0;

    // Append the school name
    sheet.appendRow(["${widget.adminProfile.schoolName}"]);

    // Define the headers for the columns
    var columns = [
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
      'Comments'
    ];

    // Apply formatting to the school name cell
    CellStyle schoolNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = schoolNameStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
        CellIndex.indexByColumnRow(columnIndex: columns.length - 1, rowIndex: rowIndex));
    rowIndex++;
    sheet.appendRow(columns);
    for (int i = 0; i <= columns.length - 1; i++) {
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
        sheet.appendRow([key.description, value / 100]);
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

    sheet.appendRow(["Downloaded: ${convertEpochToDDMMYYYYEEEEHHMMAA(DateTime.now().millisecondsSinceEpoch)}"]);
    CellStyle downloadTimeStyle = CellStyle(
      bold: true,
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = downloadTimeStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex), CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex));

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
      FileSaver.instance.saveFile(bytes: excelUint8List, name: '${getReportName().replaceAll("\n", " ")}.xlsx');
    }
    setState(() => _isLoading = false);
  }
}

class DateWiseAmountCollected {
  final DateTime date;
  final double amount;

  DateWiseAmountCollected(this.date, this.amount);
}
