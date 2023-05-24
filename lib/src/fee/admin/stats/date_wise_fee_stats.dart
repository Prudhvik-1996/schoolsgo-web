import 'package:charts_flutter/flutter.dart' as charts;

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class DateWiseReceiptStats extends StatefulWidget {
  const DateWiseReceiptStats({
    Key? key,
    required this.adminProfile,
    required this.studentFeeReceipts,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentFeeReceipt> studentFeeReceipts;

  @override
  State<DateWiseReceiptStats> createState() => _DateWiseReceiptStatsState();
}

class _DateWiseReceiptStatsState extends State<DateWiseReceiptStats> {
  bool _isLoading = true;
  bool _isGraphView = false;
  bool _showOnlyNonZero = true;
  Map<DateTime, List<StudentFeeReceipt>> dateWiseReceiptStatsMap = {};
  List<DateWiseAmountCollected> actualDateWiseAmountsCollected = [];
  List<DateWiseAmountCollected> dateWiseAmountsCollected = [];

  final ScrollController _controller = ScrollController();

  late DateTime selectedDate;
  double? selectedAmount;

  @override
  void initState() {
    super.initState();
    if (widget.studentFeeReceipts.isEmpty) return;
    _loadData();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });
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
      body: widget.studentFeeReceipts.isEmpty
          ? const Center(child: Text("No transactions to display"))
          : _isLoading
              ? Center(
                  child: Image.asset(
                    'assets/images/eis_loader.gif',
                    height: 500,
                    width: 500,
                  ),
                )
              : _isGraphView
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        selectedDateWidget(),
                        Expanded(
                          child: graphWidget(context),
                        ),
                      ],
                    )
                  : gridWidget(context),
    );
  }

  Widget selectedDateWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: dateWiseAmountsCollected.length,
      itemBuilder: (context, index) {
        final date = dateWiseAmountsCollected[index].date;
        final amount = dateWiseAmountsCollected[index].amount;
        return Card(
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _controller,
        child: ListView(
          scrollDirection: Axis.horizontal,
          controller: _controller,
          physics: const ClampingScrollPhysics(),
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: dateWiseAmountsCollected.length * 100,
                child: charts.BarChart(
                  [
                    charts.Series<DateWiseAmountCollected, String>(
                      id: 'Receipts',
                      domainFn: (DateWiseAmountCollected data, _) => convertDateTimeToDDMMYYYYFormat(data.date),
                      measureFn: (DateWiseAmountCollected data, _) => data.amount,
                      colorFn: (_, __) => charts.Color.fromHex(code: '#61c5dc'),
                      data: dateWiseAmountsCollected,
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
}

class DateWiseAmountCollected {
  final DateTime date;
  final double amount;

  DateWiseAmountCollected(this.date, this.amount);
}
