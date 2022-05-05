import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AdminExpenseScreenAdminView extends StatefulWidget {
  const AdminExpenseScreenAdminView({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  static const String routeName = "/admin_expenses";

  @override
  State<AdminExpenseScreenAdminView> createState() => _AdminExpenseScreenAdminViewState();
}

class _AdminExpenseScreenAdminViewState extends State<AdminExpenseScreenAdminView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  List<AdminExpenseBean> adminExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
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
      setState(() {
        adminExpenses = getAdminExpensesResponse.adminExpenseBeanList!.map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Admin Expenses"),
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
                    const SizedBox(
                      height: 10,
                    ),
                    _adminExpenseReadModeHeaderWidget(),
                  ] +
                  adminExpenses.map((e) => e.isEditMode ? _adminExpenseEditModeWidget(e) : _adminExpenseReadModeWidget(e)).toList(),
            ),
    );
  }

  Widget _adminExpenseReadModeHeaderWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Date",
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: AutoSizeText(
                  "Expense Type",
                  maxLines: 2,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 3,
                child: Text("Description"),
              ),
              SizedBox(
                width: 10,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text("Amount"),
              ),
              SizedBox(
                width: 60,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            thickness: 1,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _adminExpenseReadModeWidget(AdminExpenseBean adminExpense, {bool canEdit = true}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    adminExpense.transactionTime == null
                        ? "-"
                        : MediaQuery.of(context).orientation == Orientation.landscape
                            ? convertEpochToDDMMYYYYEEEEHHMMAA(adminExpense.transactionTime!)
                            : convertEpochToDDMMYYYYNHHMMAA(adminExpense.transactionTime!),
                    textAlign: MediaQuery.of(context).orientation == Orientation.landscape ? TextAlign.start : TextAlign.center,
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
                  alignment: Alignment.centerLeft,
                  child: Text(
                    adminExpense.expenseType == null ? "-" : adminExpense.expenseType!,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 3,
                child: Text(adminExpense.description == null ? "-" : adminExpense.description!),
              ),
              const SizedBox(
                width: 10,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(adminExpense.amount == null ? "$INR_SYMBOL -" : "$INR_SYMBOL ${(adminExpense.amount! / 100).toStringAsFixed(2)}"),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 30,
                child: InkWell(
                  onTap: () {
                    if (adminExpense.isEditMode) {
                      // TODO
                      // _saveChanges(adminExpense);
                    }
                    setState(() {
                      adminExpense.isEditMode = !adminExpense.isEditMode;
                    });
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: adminExpense.isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            thickness: 1,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _adminExpenseEditModeWidget(AdminExpenseBean adminExpense) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: MediaQuery.of(context).orientation == Orientation.landscape
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          )
                        : Column()),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    adminExpense.expenseType == null ? "-" : adminExpense.expenseType!,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 3,
                child: Text(adminExpense.description == null ? "-" : adminExpense.description!),
              ),
              const SizedBox(
                width: 10,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(adminExpense.amount == null ? "$INR_SYMBOL -" : "$INR_SYMBOL ${(adminExpense.amount! / 100).toStringAsFixed(2)}"),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 30,
                child: InkWell(
                  onTap: () {
                    if (adminExpense.isEditMode) {
                      // TODO
                      // _saveChanges(adminExpense);
                    }
                    setState(() {
                      adminExpense.isEditMode = !adminExpense.isEditMode;
                    });
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: adminExpense.isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            thickness: 1,
            height: 1,
          ),
        ],
      ),
    );
  }
}
