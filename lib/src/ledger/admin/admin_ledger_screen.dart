import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/ledger/modal/ledger.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

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
        filteredTransactions = getTransactionsResponse.transactionList!.map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 0,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Ledger"),
          actions: [
            buildRoleButtonForAppBar(context, widget.adminProfile),
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                          child: _getStartDatePicker(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                          child: _getEndDatePicker(),
                        ),
                      ),
                    ],
                  ),
                  _buildOverAllStats(),
                  for (TransactionBean transaction in filteredTransactions) _buildTransactionWidget(transaction),
                  // _buildTransactionsTable(),
                ],
              ),
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
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
      padding: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text("Total Number of credit transactions:"),
                  ),
                  Text("${filteredTransactions.where((e) => e.transactionKind == "CR").length}"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text("Total credit amount:"),
                  ),
                  Text(
                      "$INR_SYMBOL ${((filteredTransactions.where((e) => e.transactionKind == "CR").map((e) => e.amount ?? 0).toList().sum) / 100).toStringAsFixed(2)}"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text("Total Number of debit transactions:"),
                  ),
                  Text("${filteredTransactions.where((e) => e.transactionKind == "DB").length}"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text("Total debit amount:"),
                  ),
                  Text(
                      "$INR_SYMBOL ${((filteredTransactions.where((e) => e.transactionKind == "DB").map((e) => e.amount ?? 0).toList().sum) / 100).toStringAsFixed(2)}"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text("Total Number of transactions:"),
                  ),
                  Text("${filteredTransactions.length}"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text("Net amount:"),
                  ),
                  Text(
                      "$INR_SYMBOL ${((filteredTransactions.map((e) => (e.transactionKind == "CR" ? 1 : -1) * (e.amount ?? 0)).toList().sum) / 100).toStringAsFixed(2)}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStartDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: startTime == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(startTime!),
            firstDate: DateTime(2021),
            lastDate: DateTime.now(),
            helpText: "Pick start date",
          );
          if (_newDate == null || _newDate.millisecondsSinceEpoch == startTime) return;
          setState(() {
            startTime = _newDate.millisecondsSinceEpoch;
            filteredTransactions = transactions
                .where((e) => (startTime == null || startTime! < e.transactionTime!) && (endTime == null || endTime! > e.transactionTime!))
                .toList();
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                startTime == null ? "Start Date" : "Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(startTime!))}",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getEndDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
            filteredTransactions = transactions
                .where((e) => (startTime == null || startTime! < e.transactionTime!) && (endTime == null || endTime! > e.transactionTime!))
                .toList();
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                endTime == null ? "End Date" : "Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(endTime!))}",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
