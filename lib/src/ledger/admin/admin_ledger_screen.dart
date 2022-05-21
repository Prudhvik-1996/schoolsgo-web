import 'dart:math' as math;
import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/pie_chart/data/pie_data.dart';
import 'package:schoolsgo_web/src/common_components/pie_chart/widget/pie_chart_sections.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/ledger/modal/ledger.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminLedgerScreen extends StatefulWidget {
  const AdminLedgerScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/ledger";

  @override
  State<AdminLedgerScreen> createState() => _AdminLedgerScreenState();
}

class _AdminLedgerScreenState extends State<AdminLedgerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  List<TransactionBean> transactions = [];
  List<TransactionBean> filteredTransactions = [];

  int? startTime;
  int? endTime;

  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetTransactionsResponse getTransactionsResponse = await getTransactions(GetTransactionsRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
    ));
    if (getTransactionsResponse.httpStatus != "OK" || getTransactionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        transactions = getTransactionsResponse.transactionList!.map((e) => e!).toList();
        filterTransactionData();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  bool showDateFilter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Ledger"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
          InkWell(
            onTap: () {
              //  TODO download report
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
              child: const Tooltip(
                message: "Download",
                child: Icon(Icons.download),
              ),
            ),
          ),
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
          : ListView(
              children: [
                if (showDateFilter)
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: _getStartDatePicker(),
                      ),
                      Expanded(
                        child: _getEndDatePicker(),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                _buildOverAllStats(),
                // for (TransactionBean transaction in filteredTransactions) _buildTransactionWidget(transaction),
                for (TransactionBean transaction in filteredTransactions) buildEachMasterTransaction(transaction),
                const SizedBox(
                  height: 100,
                ),
                // _buildTransactionsTable(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showDateFilter = !showDateFilter;
          });
        },
        child: showDateFilter ? const Icon(Icons.clear) : const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildTransactionWidget(TransactionBean transaction) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  // gradient: transaction.transactionKind == "CR"
                  //     ? LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         stops: const [0.001, 0.5, 0.999],
                  //         colors: [
                  //           clayContainerColor(context),
                  //           Colors.green,
                  //           clayContainerColor(context),
                  //         ],
                  //       )
                  //     : LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         stops: const [0.01, 0.5, 0.99],
                  //         colors: [
                  //           clayContainerColor(context),
                  //           Colors.amber,
                  //           clayContainerColor(context),
                  //         ],
                  //       ),
                  color: transaction.transactionKind == "CR" ? Colors.green.shade300 : Colors.amber.shade300,
                ),
                child: _parentTransactionRow(transaction),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                thickness: 1,
                height: 1,
              ),
            ] +
            [
              transaction.isExpanded
                  ? const SizedBox(
                      height: 10,
                    )
                  : Container()
            ] +
            (transaction.isExpanded
                ? (transaction.childTransactions ?? [])
                    .map((e) => e!)
                    .map(
                      (childTransaction) => [
                        _childTransactionRow(childTransaction),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                    .toList()
                    .expand((i) => i)
                    .toList()
                : []) +
            (transaction.isExpanded
                ? [
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 1,
                      height: 1,
                    ),
                  ]
                : [Container()]),
      ),
    );
  }

  Row _childTransactionRow(TransactionBean childTransaction) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              convertEpochToDDMMYYYYEEEEHHMMAA(childTransaction.transactionTime!),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              childTransaction.transactionId ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              childTransaction.transactionType ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              childTransaction.transactionStatus ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 4,
          child: Text(childTransaction.description ?? "-"),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              childTransaction.transactionKind ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              childTransaction.amount == null ? "-" : "$INR_SYMBOL ${(childTransaction.amount! / 100).toStringAsFixed(2)}",
            ),
          ),
        ),
        const SizedBox(
          width: 40,
        ),
      ],
    );
  }

  Row _parentTransactionRow(TransactionBean transaction) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              convertEpochToDDMMYYYYEEEEHHMMAA(transaction.transactionTime!),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              transaction.transactionId ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              transaction.transactionType ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              transaction.transactionStatus ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 4,
          child: Text(transaction.description ?? "-"),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              transaction.transactionKind ?? "-",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              transaction.amount == null ? "-" : "$INR_SYMBOL ${(transaction.amount! / 100).toStringAsFixed(2)}",
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 20,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                if (transaction.childTransactions?.isEmpty ?? false) {
                  return;
                }
                setState(() {
                  transaction.isExpanded = !transaction.isExpanded;
                });
              },
              child: transaction.isExpanded ? const Icon(Icons.keyboard_arrow_up) : const Icon(Icons.keyboard_arrow_down),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget _buildTransactionsTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Transaction Time')),
        DataColumn(label: Text('Transaction Id')),
        DataColumn(label: Text('Transaction Type')),
        DataColumn(label: Text('Transaction Status')),
        DataColumn(label: Text('Transaction Description')),
        DataColumn(label: Text('Transaction Kind')),
        DataColumn(label: Text('Transaction Amount')),
      ],
      rows: filteredTransactions
          .map(
            (transaction) => DataRow(
              cells: [
                DataCell(
                  Text(
                    convertEpochToDDMMYYYYEEEEHHMMAA(transaction.transactionTime!),
                  ),
                ),
                DataCell(
                  Text(
                    transaction.transactionId ?? "-",
                  ),
                ),
                DataCell(
                  Text(
                    transaction.transactionType ?? "-",
                  ),
                ),
                DataCell(
                  Text(
                    transaction.transactionStatus ?? "-",
                  ),
                ),
                DataCell(
                  Text(transaction.description ?? "-"),
                ),
                DataCell(
                  Text(
                    transaction.transactionKind ?? "-",
                  ),
                ),
                DataCell(
                  Text(
                    transaction.amount == null ? "-" : "$INR_SYMBOL ${(transaction.amount! / 100).toStringAsFixed(2)}",
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildOverAllStats() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: buildStatsWidget(),
        ),
      ),
    );
  }

  Container buildPieChart() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
      padding: const EdgeInsets.all(20),
      height: 250,
      width: 250,
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 0,
              pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              }),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              sections: getSections(touchedIndex),
            ),
          ),
        ),
      ),
    );
  }

  bool showMoreStats = false;

  Column buildStatsWidget() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.adminProfile.schoolName ?? "-",
                textAlign: TextAlign.center,
                style: GoogleFonts.archivoBlack(
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.adminProfile.branchCode ?? "-",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            const Expanded(
              child: Text("Net amount:"),
            ),
            Text(
              "$INR_SYMBOL ${(doubleToStringAsFixedForINR((filteredTransactions.map((e) => (e.transactionKind == "CR" ? 1 : -1) * (e.amount ?? 0)).toList().sum) / 100)).replaceAll("-", "")}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: filteredTransactions.map((e) => (e.transactionKind == "CR" ? 1 : -1) * (e.amount ?? 0)).toList().sum >= 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        if (showMoreStats)
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Text("Total credit amount:"),
              ),
              Text(
                "$INR_SYMBOL ${doubleToStringAsFixedForINR((filteredTransactions.where((e) => e.transactionKind == "CR").map((e) => e.amount ?? 0).toList().sum) / 100)}",
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        if (showMoreStats)
          const SizedBox(
            height: 10,
          ),
        if (showMoreStats)
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Text("Total debit amount:"),
              ),
              Text(
                "$INR_SYMBOL ${doubleToStringAsFixedForINR((filteredTransactions.where((e) => e.transactionKind == "DB").map((e) => e.amount ?? 0).toList().sum) / 100)}",
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        if (showMoreStats)
          const SizedBox(
            height: 10,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(
              child: Text(""),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  showMoreStats = !showMoreStats;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showMoreStats ? "Show less details" : "Show more details",
                        style: const TextStyle(
                          color: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        showMoreStats ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getStartDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: startTime == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(startTime!),
            firstDate: DateTime.fromMillisecondsSinceEpoch(transactions.map((e) => e.transactionTime ?? 0).reduce(min)),
            lastDate: DateTime.now(),
            helpText: "Pick start date",
          );
          if (_newDate == null || _newDate.millisecondsSinceEpoch == startTime) return;
          setState(() {
            startTime = _newDate.millisecondsSinceEpoch;
          });
          filterTransactionData();
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                startTime == null
                    ? "Start Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(transactions.map((e) => e.transactionTime ?? 0).reduce(min)))}"
                    : "Start Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(startTime!))}",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getEndDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          if (startTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("First pick start date.."),
              ),
            );
            return;
          }
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: endTime == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(endTime!),
            firstDate: DateTime.fromMillisecondsSinceEpoch(startTime!),
            lastDate: DateTime.now(),
            helpText: "Pick end date",
          );
          if (_newDate == null || _newDate.millisecondsSinceEpoch == endTime) return;
          if (_newDate.millisecondsSinceEpoch < startTime!) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("End date cannot be before start date.."),
              ),
            );
            return;
          }
          setState(() {
            endTime = _newDate.millisecondsSinceEpoch;
          });
          filterTransactionData();
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                endTime == null
                    ? "End Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.now())}"
                    : "End Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(endTime!))}",
              ),
            ),
          ),
        ),
      ),
    );
  }

  void filterTransactionData() {
    setState(() {
      filteredTransactions = transactions
          .where((e) => (startTime == null || startTime! < e.transactionTime!) && (endTime == null || endTime! > e.transactionTime!))
          .toList()
        ..sort(
          (b, a) => (a.transactionTime ?? 0).compareTo(b.transactionTime ?? 0),
        );
      PieData.data = filteredTransactions
          .map((e) => e.transactionType ?? "-")
          .toSet()
          .map((eachType) => Data(
                type: eachType,
                color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                amount:
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR(filteredTransactions.where((e) => e.transactionType == eachType).map((e) => e.amount ?? 0).sum / 100, decimalPlaces: 2)}",
                percentage: (filteredTransactions.where((e) => e.transactionType == eachType).length / filteredTransactions.length) * 100,
              ))
          .toList();
    });
  }

  Widget buildEachMasterTransaction(TransactionBean eachTxn) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      (eachTxn.transactionType ?? "-").replaceAll("_", " "),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                eachTxn.description ?? "-",
                                style: const TextStyle(fontSize: 14),
                                textAlign: (eachTxn.description ?? "").length > 120 ? TextAlign.justify : TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  Text(
                    INR_SYMBOL + " " + (eachTxn.amount == null ? "-" : doubleToStringAsFixedForINR(eachTxn.amount! / 100, decimalPlaces: 2)),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  eachTxn.transactionKind == "CR"
                      ? const Icon(
                          Icons.arrow_drop_up_outlined,
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Colors.red,
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              getMoreDetailsWidget(eachTxn),
              if ((eachTxn.childTransactions ?? []).isEmpty)
                const SizedBox(
                  height: 15,
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Expanded(
                    child: Text(""),
                  ),
                  Text(
                    eachTxn.transactionTime == null ? "-" : convertEpochToDDMMYYYYHHMMAA(eachTxn.transactionTime!),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMoreDetailsWidget(TransactionBean eachTxn) {
    if ((eachTxn.childTransactions ?? []).isNotEmpty && !eachTxn.showMoreDetails) {
      return showLessDetailsWidget(eachTxn);
    } else if ((eachTxn.childTransactions ?? []).isNotEmpty && eachTxn.showMoreDetails) {
      return showMoreDetailsWidget(eachTxn);
    }
    return Container(
      child: ((eachTxn.childTransactions ?? []).isNotEmpty && !eachTxn.showMoreDetails)
          ? showLessDetailsWidget(eachTxn)
          : ((eachTxn.childTransactions ?? []).isNotEmpty && eachTxn.showMoreDetails)
              ? showMoreDetailsWidget(eachTxn)
              : null,
    );
  }

  Column showMoreDetailsWidget(TransactionBean eachTxn) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(
              child: Text(""),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  eachTxn.showMoreDetails = !eachTxn.showMoreDetails;
                });
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Hide details",
                        style: TextStyle(
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
        for (TransactionBean childTxn in (eachTxn.childTransactions ?? []).map((e) => e!))
          Container(
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Row(
              children: [
                const SizedBox(
                  width: 25,
                ),
                Expanded(
                  child: Text(
                    childTxn.description ?? "-",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                Text(
                  INR_SYMBOL + " " + (childTxn.amount == null ? "-" : doubleToStringAsFixedForINR(childTxn.amount! / 100, decimalPlaces: 2)),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                childTxn.transactionKind == "CR"
                    ? const Icon(
                        Icons.arrow_drop_up_outlined,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.arrow_drop_down_outlined,
                        color: Colors.red,
                      ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Column showLessDetailsWidget(TransactionBean eachTxn) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(
              child: Text(""),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  eachTxn.showMoreDetails = !eachTxn.showMoreDetails;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Show more details",
                        style: TextStyle(
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.lightBlue,
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
