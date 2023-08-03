import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/stats/date_wise_receipts_stats.dart';
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
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentFeeReceipt> studentFeeReceipts;
  final List<RouteStopWiseStudent> routeStopWiseStudents;

  @override
  State<DateWiseReceiptStats> createState() => _DateWiseReceiptStatsState();
}

class _DateWiseReceiptStatsState extends State<DateWiseReceiptStats> {
  bool _isLoading = true;
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

  @override
  void initState() {
    super.initState();
    if (widget.studentFeeReceipts.isEmpty) return;
    fromDate = widget.studentFeeReceipts.map((e) => e.transactionDate).whereNotNull().map((e) => convertYYYYMMDDFormatToDateTime(e)).min;
    toDate = widget.studentFeeReceipts.map((e) => e.transactionDate).whereNotNull().map((e) => convertYYYYMMDDFormatToDateTime(e)).max;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

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

    for (final receipt in widget.studentFeeReceipts) {
      if (receipt.transactionDate != null) {
        final dateString = receipt.transactionDate!;
        dateWiseReceiptStatsMap[convertYYYYMMDDFormatToDateTime(dateString)] ??= <StudentFeeReceipt>[];
        dateWiseReceiptStatsMap[convertYYYYMMDDFormatToDateTime(dateString)]!.add(receipt);
      }
    }
    DateTime startDate = widget.studentFeeReceipts.map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).min;
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
    setState(() {
      _isLoading = false;
    });
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
                  _mainBodyController.animateTo(
                    _mainBodyController.position.maxScrollExtent,
                    duration: const Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn,
                  );
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
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : widget.studentFeeReceipts.isEmpty
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
                                height: MediaQuery.of(context).size.height - 200,
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
                studentFeeReceipts: widget.studentFeeReceipts.where((e) => e.transactionDate == convertDateTimeToYYYYMMDDFormat(date)).toList(),
                selectedDate: date,
                routeStopWiseStudents: widget.routeStopWiseStudents,
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
    List<StudentFeeReceipt> receiptsToBeAccounted = widget.studentFeeReceipts
        .where((e) => e.transactionDate != null)
        .where((e) =>
            convertYYYYMMDDFormatToDateTime(e.transactionDate!).millisecondsSinceEpoch >= fromDate.millisecondsSinceEpoch &&
            convertYYYYMMDDFormatToDateTime(e.transactionDate!).millisecondsSinceEpoch <= toDate.millisecondsSinceEpoch)
        .toList();
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(10, 20, 10, 20)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20),
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
              FittedBox(
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
              ClayContainer(
                emboss: false,
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: Padding(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}

class DateWiseAmountCollected {
  final DateTime date;
  final double amount;

  DateWiseAmountCollected(this.date, this.amount);
}
