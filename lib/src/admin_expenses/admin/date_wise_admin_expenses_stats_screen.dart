import 'dart:math' as math;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/admin_expenses_for_selected_date_screen.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DateWiseAdminExpensesStatsScreen extends StatefulWidget {
  const DateWiseAdminExpensesStatsScreen({
    super.key,
    required this.adminProfile,
    required this.adminExpenses,
  });

  final AdminProfile adminProfile;
  final List<AdminExpenseBean> adminExpenses;

  @override
  State<DateWiseAdminExpensesStatsScreen> createState() => _DateWiseAdminExpensesStatsScreenState();
}

class _DateWiseAdminExpensesStatsScreenState extends State<DateWiseAdminExpensesStatsScreen> {
  bool _isLoading = true;

  List<AdminExpenseBean> adminExpenses = [];
  List<DateWiseAmountSpent> dateWiseAmountsSpent = [];
  List<DateWiseAmountSpent> dateWiseAmountsSpentToShow = [];

  late DateTime selectedDate;
  late DateTime fromDate;
  late DateTime toDate;

  bool _showOnlyNonZero = true;

  @override
  void initState() {
    super.initState();
    adminExpenses = widget.adminExpenses;
    if (adminExpenses.isEmpty) return;
    selectedDate = DateTime.now();
    fromDate = DateTime.fromMillisecondsSinceEpoch(adminExpenses.map((e) => e.transactionTime).whereNotNull().min);
    var currentMillis = DateTime.now().millisecondsSinceEpoch;
    var maxDateAsPerExpenses = adminExpenses.map((e) => e.transactionTime).whereNotNull().max;
    toDate = DateTime.fromMillisecondsSinceEpoch(math.max(currentMillis, maxDateAsPerExpenses));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(adminExpenses.map((e) => e.transactionTime).whereNotNull().min);
    DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 2));
    List<DateTime> populatedDates = populateDates(startDate, endDate);
    dateWiseAmountsSpent = populatedDates.reversed
        .map((eachDate) => DateWiseAmountSpent(
            eachDate,
            adminExpenses
                .where((e) =>
                    e.transactionTime != null &&
                    convertDateTimeToYYYYMMDDFormat(DateTime.fromMillisecondsSinceEpoch(e.transactionTime!)) ==
                        convertDateTimeToYYYYMMDDFormat(eachDate))
                .map((e) => (e.amount ?? 0) / 100.0)
                .fold<double>(0, (sum, amount) => sum + amount)))
        .toList();
    dateWiseAmountsSpentToShow = dateWiseAmountsSpent.toList();
    handleVisibilityOfNonZero();
    setState(() => _isLoading = false);
  }

  void handleVisibilityOfNonZero() {
    if (_showOnlyNonZero) {
      setState(() => dateWiseAmountsSpentToShow = dateWiseAmountsSpent.where((e) => e.amount != 0).toList());
    } else {
      setState(() => dateWiseAmountsSpentToShow = dateWiseAmountsSpent.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Expenses"),
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
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                summaryWidget(),
                gridWidget(context),
              ],
            ),
    );
  }

  Widget summaryWidget() {
    List<AdminExpenseBean> adminExpensesToBeConsidered = adminExpenses
        .where((e) => e.transactionTime != null)
        .where((e) =>
            DateTime.fromMillisecondsSinceEpoch(e.transactionTime!).isAfter(fromDate) &&
            toDate.add(const Duration(days: 1)).isAfter(DateTime.fromMillisecondsSinceEpoch(e.transactionTime!)))
        .toList();
    Set<String> uniqueExpenseTypes = adminExpensesToBeConsidered.map((e) => e.expenseType).whereNotNull().toSet();
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
                    children: [
                      ...uniqueExpenseTypes.map((eachExpenseType) {
                        double amount = adminExpenses
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

  Widget gridWidget(BuildContext context) {
    List<DateWiseAmountSpent> selectedDateWiseAmountCollected = dateWiseAmountsSpentToShow
        .where((e) =>
            convertYYYYMMDDFormatToDateTime(convertDateTimeToYYYYMMDDFormat(e.date)).isAfter(fromDate) &&
            toDate.add(const Duration(days: 1)).isAfter(convertYYYYMMDDFormatToDateTime(convertDateTimeToYYYYMMDDFormat(e.date))))
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
              return AdminExpensesForSelectedDateScreen(
                adminProfile: widget.adminProfile,
                adminExpenses: adminExpenses
                    .where((e) => e.transactionTime != null)
                    .where((e) =>
                        convertDateTimeToYYYYMMDDFormat(DateTime.fromMillisecondsSinceEpoch(e.transactionTime!)) ==
                        convertDateTimeToYYYYMMDDFormat(date))
                    .toList(),
                selectedDate: date,
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
}

class DateWiseAmountSpent {
  DateTime date;
  double amount;

  DateWiseAmountSpent(this.date, this.amount);
}

List<charts.Series<PaymentSummary, String>> generatePieChartDataForAdminExpenses(List<AdminExpenseBean> adminExpenses) {
  // Create a map to store the total amounts for each mode of payment
  final paymentMap = <ModeOfPayment, int>{};

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

class PaymentSummary {
  final String modeOfPayment;
  final double totalAmount;
  final charts.Color color;

  PaymentSummary(this.modeOfPayment, this.totalAmount, this.color);
}
