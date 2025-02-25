import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/installment_plan_widgets.dart';

// Your custom imports
import 'package:schoolsgo_web/src/admin_expenses/admin/installment_progress_bar.dart';
import 'package:schoolsgo_web/src/admin_expenses/modal/admin_expenses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminInstallmentsPlanScreen extends StatefulWidget {
  const AdminInstallmentsPlanScreen({
    Key? key,
    this.adminProfile,
    this.receptionistProfile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final OtherUserRoleProfile? receptionistProfile;

  @override
  State<AdminInstallmentsPlanScreen> createState() => _AdminInstallmentsPlanScreenState();
}

class _AdminInstallmentsPlanScreenState extends State<AdminInstallmentsPlanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isAddNew = false;
  List<ExpenseInstallmentPlanBean> expenseInstallmentPlans = [];
  late ExpenseInstallmentPlanBean newPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetExpenseInstallmentPlansResponse response = await getExpenseInstallmentPlans(
      GetExpenseInstallmentPlansRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
      ),
    );
    if (response.httpStatus != "OK" || response.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      expenseInstallmentPlans = (response.expenseInstallmentPlans ?? []).whereNotNull().toList();
    }
    setState(() => _isLoading = false);
  }

  /// Checks if any plan is in edit mode.
  bool checkIfAnyPlanIsInEditMode() => _isAddNew ? false : expenseInstallmentPlans.any((plan) => plan.isEditMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Expense Installment Plans"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : expenseInstallmentPlans.isEmpty
              ? const Center(child: Text("No plans created yet.."))
              : _isAddNew
                  ? ListView(
                      children: [
                        Container(
                          margin: MediaQuery.of(context).orientation == Orientation.landscape
                              ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
                              : const EdgeInsets.all(10),
                          child: buildInstallmentPlanCard(newPlan),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: expenseInstallmentPlans.length,
                      itemBuilder: (ctx, index) {
                        return Container(
                          margin: MediaQuery.of(context).orientation == Orientation.landscape
                              ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
                              : const EdgeInsets.all(10),
                          child: buildInstallmentPlanCard(expenseInstallmentPlans[index]),
                        );
                      },
                    ),
      floatingActionButton: _isAddNew
          ? null
          : fab(
              const Icon(Icons.add),
              "Add new",
              () => setAddNewMode(),
              color: Colors.green,
            ),
    );
  }

  void setAddNewMode() {
    newPlan = newExpenseInstallmentPlanBean();
    setState(() => _isAddNew = true);
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

  InstallmentPlanCard buildInstallmentPlanCard(ExpenseInstallmentPlanBean expenseInstallmentPlan) {
    return InstallmentPlanCard(
      plan: expenseInstallmentPlan,
      canToggleEditMode: true,
      isAnotherPlanInEditMode: checkIfAnyPlanIsInEditMode(),
      onEditToggled: () {
        setState(() {
          // Toggle edit mode for this plan
          expenseInstallmentPlan.isEditMode = !expenseInstallmentPlan.isEditMode;
        });
      },
      onChangesSubmitted: () async {
        setState(() => _isLoading = true);
        await showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Expense Installment Plan'),
              content: const Text("Are you sure to save changes?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("YES"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() => _isLoading = true);
                    CreateOrUpdateExpenseInstallmentPlanResponse createOrUpdateExpenseInstallmentPlanResponse =
                        await createOrUpdateExpenseInstallmentPlan(CreateOrUpdateExpenseInstallmentPlanRequest()
                          ..agent = expenseInstallmentPlan.agent
                          ..amount = expenseInstallmentPlan.amount
                          ..createTime = expenseInstallmentPlan.createTime
                          ..expenseBeans = expenseInstallmentPlan.expenseBeans
                          ..expenseInstallments = expenseInstallmentPlan.expenseInstallments
                          ..lastUpdated = expenseInstallmentPlan.lastUpdated
                          ..planDescription = expenseInstallmentPlan.planDescription
                          ..planId = expenseInstallmentPlan.planId
                          ..planTitle = expenseInstallmentPlan.planTitle
                          ..schoolId = expenseInstallmentPlan.schoolId
                          ..status = expenseInstallmentPlan.status);
                    if (createOrUpdateExpenseInstallmentPlanResponse.httpStatus != "OK" ||
                        createOrUpdateExpenseInstallmentPlanResponse.responseStatus != "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong! Try again later.."),
                        ),
                      );
                      setState(() => _isLoading = false);
                    } else {
                      await _loadData();
                    }
                  },
                ),
                TextButton(
                  child: const Text("No"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        setState(() {
          _isAddNew = false;
          _isLoading = false;
        });
      },
      onPlanTitleChanged: (newTitle) {
        setState(() {
          expenseInstallmentPlan.planTitle = newTitle;
        });
      },
      onPlanDescriptionChanged: (newDesc) {
        setState(() {
          expenseInstallmentPlan.planDescription = newDesc;
        });
      },
      onPlanAmountChanged: (newAmount) {
        setState(() {
          // newAmount is in double, store in paise
          expenseInstallmentPlan.amount = (newAmount * 100).round();
        });
      },
      onAddInstallment: () {
        setState(() {
          expenseInstallmentPlan.expenseInstallments ??= [];
          expenseInstallmentPlan.expenseInstallments!.add(newExpenseInstallmentBean(expenseInstallmentPlan));
        });
      },
    );
  }

  /// Creates a new installment bean with the remaining amount (if desired).
  ExpenseInstallmentBean newExpenseInstallmentBean(ExpenseInstallmentPlanBean plan) {
    return ExpenseInstallmentBean(
      planId: plan.planId,
      status: 'active',
      // By default, add the leftover amount or 0
      amount: (plan.amount ?? 0) - plan.installmentsTotal,
      dueDate: null,
      agent: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
      schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
    );
  }

  /// Creates a new installment plan bean.
  ExpenseInstallmentPlanBean newExpenseInstallmentPlanBean() {
    return ExpenseInstallmentPlanBean(
      planTitle: "",
      planDescription: "",
      amount: 0,
      expenseInstallments: [],
      expenseBeans: [],
      status: 'active',
      agent: widget.adminProfile?.userId ?? widget.receptionistProfile?.userId,
      schoolId: widget.adminProfile?.schoolId ?? widget.receptionistProfile?.schoolId,
    )..isEditMode = true;
  }
}
