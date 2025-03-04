import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/payslips/modal/payslips.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class PayMonthWiseSalariesScreen extends StatefulWidget {
  const PayMonthWiseSalariesScreen({Key? key, required this.adminProfile, required this.monthAndYearForSchoolBean}) : super(key: key);

  final AdminProfile adminProfile;
  final MonthAndYearForSchoolBean monthAndYearForSchoolBean;

  @override
  State<PayMonthWiseSalariesScreen> createState() => _PayMonthWiseSalariesScreenState();
}

class _PayMonthWiseSalariesScreenState extends State<PayMonthWiseSalariesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;

  List<PayslipTemplateForEmployeeBean> payslipTemplates = [];

  List<EmployeePayslipBean> actualEmployeePayslips = [];
  List<EmployeePayslipBean> employeePayslips = [];
  List<EmployeeLopBean> newLOPsBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetPayslipTemplateForEmployeeResponse getPayslipTemplateForEmployeeResponse = await getPayslipTemplateForEmployee(
      GetPayslipTemplateForEmployeeRequest(
        schoolId: widget.adminProfile.schoolId,
        franchiseId: widget.adminProfile.franchiseId,
      ),
    );
    if (getPayslipTemplateForEmployeeResponse.httpStatus != "OK" || getPayslipTemplateForEmployeeResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        payslipTemplates =
            (getPayslipTemplateForEmployeeResponse.payslipTemplateForEmployeeBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      });
    }
    GetEmployeePayslipsResponse getEmployeePayslipsResponse = await getEmployeePayslips(
      GetEmployeePayslipsRequest(
        schoolId: widget.adminProfile.schoolId,
        franchiseId: widget.adminProfile.franchiseId,
        monthYearId: widget.monthAndYearForSchoolBean.monthAndYearForSchoolId,
      ),
    );
    if (getEmployeePayslipsResponse.httpStatus != "OK" || getEmployeePayslipsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        actualEmployeePayslips = (getEmployeePayslipsResponse.employeePayslipBeans ?? []).where((e) => e != null).map((e) => e!).toList();
        actualEmployeePayslips.sort((a, b) => (a.employeeBean?.employeeName ?? "").compareTo(b.employeeBean?.employeeName ?? ""));
        actualEmployeePayslips
            .where(
                (e) => (e.monthlyEmployeePayslipBeans ?? []).map((e) => e?.monthWiseEmployeePayslipComponentBeans ?? []).expand((i) => i).length <= 1)
            .forEach((eachEmployee) {
          newLOPsBeans.add(EmployeeLopBean(
            monthYearId: widget.monthAndYearForSchoolBean.monthAndYearForSchoolId,
            agent: widget.adminProfile.userId,
            employeeId: eachEmployee.employeeBean?.employeeId,
            employeeName: eachEmployee.employeeBean?.employeeName,
            franchiseId: widget.adminProfile.franchiseId,
            franchiseName: widget.adminProfile.franchiseName,
            lopAmount: null,
            lopDays: null,
            lopId: null,
            month: widget.monthAndYearForSchoolBean.month,
            noOfWorkingDays: widget.monthAndYearForSchoolBean.noOfWorkingDays,
          ));
        });
      });
    }
    setState(() => _isLoading = false);
    await _syncSearchKey("");
  }

  Future<void> _syncSearchKey(String searchKey) async {
    setState(() {
      _isLoading = true;
    });
    if (searchKey.trim() == "") {
      setState(() {
        employeePayslips = actualEmployeePayslips;
      });
    } else {
      employeePayslips = actualEmployeePayslips.where((e) => (e.employeeBean?.employeeName ?? "").toLowerCase().contains(searchKey)).toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget searchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: TextField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.1,
                        style: BorderStyle.none,
                      ),
                    ),
                    labelText: '',
                    hintText: 'Search',
                    contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  ),
                  onChanged: (String e) async {
                    await _syncSearchKey(e);
                  },
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  autofocus: false,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            const Icon(Icons.search),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget earningsForPaidBean(MonthWiseEmployeePayslipComponentBean e) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(e.componentName ?? ""),
          ),
          const SizedBox(
            width: 5,
          ),
          Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((e.amount ?? 0) / 100.0)}"),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget earningsForPendingBean(PayslipTemplateComponentBean e) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(e.componentName ?? ""),
          ),
          const SizedBox(
            width: 5,
          ),
          Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((e.amount ?? 0) / 100.0)}"),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget deductionsForPaidBean(MonthWiseEmployeePayslipComponentBean e) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(e.componentType == "LOP" ? "Loss Of Pay (${e.noOfLopDays})" : e.componentName ?? ""),
          ),
          const SizedBox(
            width: 5,
          ),
          Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((e.amount ?? 0) / 100.0)}"),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget deductionsForPendingBean(PayslipTemplateComponentBean e) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(e.payslipComponentType == "LOP" ? "Loss Of Pay (-)" : e.componentName ?? ""),
          ),
          Text(e.payslipComponentType == "LOP" ? "-" : "$INR_SYMBOL ${doubleToStringAsFixedForINR((e.amount ?? 0) / 100.0)}"),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget pendingLopBean(EmployeeLopBean e) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text("Loss Of Pay (${e.lopDays ?? "-"})"),
          ),
          Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((e.lopAmount ?? 0) / 100.0)}"),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget eachEmployeeCheckboxWidget(EmployeePayslipBean employeePayslipBean) {
    var simpleHorizontalDivider = const Divider(
      color: Colors.cyan,
      thickness: 1,
      endIndent: 0,
      indent: 0,
      height: 0,
    );
    var simpleVerticalDivider = const VerticalDivider(
      color: Colors.cyan,
      thickness: 1,
      endIndent: 0,
      indent: 0,
      width: 0,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: [
          if (!employeePayslipBean.isPaid())
            Checkbox(
                value: employeePayslipBean.isSelected,
                onChanged: (bool? newValue) {
                  if (employeePayslipBean.netPay(payslipTemplates) == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fill the employee payslip component template first.."),
                      ),
                    );
                    return;
                  }
                  setState(() => employeePayslipBean.isSelected = newValue ?? false);
                }),
          if (!employeePayslipBean.isPaid())
            const SizedBox(
              width: 10,
            ),
          Expanded(
            child: ClayContainer(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              child: employeePayslipBean.isTapped
                  ? ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsets.all(5),
                                child: employeePayslipBean.employeeBean?.photoUrl == null
                                    ? Image.asset(
                                        "assets/images/avatar.png",
                                        fit: BoxFit.contain,
                                      )
                                    : Image.network(
                                        employeePayslipBean.employeeBean!.photoUrl!,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Text(
                                    employeePayslipBean.employeeBean?.employeeName ?? "-",
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (employeePayslipBean.employeeBean?.roles ?? []).join("\n").replaceAll("_", " ").replaceAll(",", "\n"),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    employeePayslipBean.isTapped = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: const Icon(Icons.arrow_drop_up),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.cyan,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
                                  child: const Center(
                                    child: Text("Earnings"),
                                  ),
                                ),
                              ),
                              simpleVerticalDivider,
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
                                  child: const Center(
                                    child: Text("Deductions"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: employeePayslipBean.isPaid()
                                      ? (employeePayslipBean.monthlyEmployeePayslipBeans ?? [])
                                          .map((e) => e?.monthWiseEmployeePayslipComponentBeans ?? [])
                                          .expand((i) => i)
                                          .where((e) => e != null)
                                          .map((e) => e!)
                                          .where((e) => (e.componentType ?? "") == "EARNINGS")
                                          .map((e) => earningsForPaidBean(e))
                                          .toList()
                                      : payslipTemplates
                                          .where((e) => e.employeeId == employeePayslipBean.employeeBean?.employeeId)
                                          .map((e) => e.payslipTemplateComponentBeans ?? [])
                                          .expand((i) => i)
                                          .where((e) => e != null)
                                          .map((e) => e!)
                                          .where((e) => (e.payslipComponentType ?? "") == "EARNINGS")
                                          .map((e) => earningsForPendingBean(e))
                                          .toList(),
                                ),
                              ),
                              simpleVerticalDivider,
                              Expanded(
                                child: Column(
                                  children: employeePayslipBean.isPaid()
                                      ? (employeePayslipBean.monthlyEmployeePayslipBeans ?? [])
                                          .map((e) => e?.monthWiseEmployeePayslipComponentBeans ?? [])
                                          .expand((i) => i)
                                          .where((e) => e != null)
                                          .map((e) => e!)
                                          .where((e) => (e.componentType ?? "") != "EARNINGS")
                                          .map((e) => deductionsForPaidBean(e))
                                          .toList()
                                      : payslipTemplates
                                              .where((e) => e.employeeId == employeePayslipBean.employeeBean?.employeeId)
                                              .map((e) => e.payslipTemplateComponentBeans ?? [])
                                              .expand((i) => i)
                                              .where((e) => e != null)
                                              .map((e) => e!)
                                              .where((e) => (e.payslipComponentType ?? "") != "EARNINGS")
                                              .map((e) => deductionsForPendingBean(e))
                                              .toList() +
                                          newLOPsBeans
                                              .where((e) => e.employeeId == employeePayslipBean.employeeBean?.employeeId)
                                              .map((e) => pendingLopBean(e))
                                              .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        simpleHorizontalDivider,
                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 15),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "Net Pay: $INR_SYMBOL ${employeePayslipBean.isPaid() ? doubleToStringAsFixedForINR((employeePayslipBean.monthlyEmployeePayslipBeans ?? []).map((e) => e?.monthWiseEmployeePayslipComponentBeans ?? []).expand((i) => i).map((e) => (e == null ? 0 : e.componentType == "EARNINGS" ? 1 : -1) * (e?.amount ?? 0)).reduce((a1, a2) => a1 + a2) / 100.0) : doubleToStringAsFixedForINR(payslipTemplates.where((e1) => e1.employeeId == employeePayslipBean.employeeBean?.employeeId).map((e) => e.payslipTemplateComponentBeans ?? []).expand((i) => i).map((e) => (e == null ? 0 : e.payslipComponentType == "EARNINGS" ? 1 : -1) * (e?.amount ?? 0)).reduce((a1, a2) => a1 + a2) / 100.0)}",
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                child: employeePayslipBean.isPaid()
                                    ? const Text(
                                        "PAID",
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      )
                                    : const Text(
                                        "PENDING",
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsets.all(5),
                                child: employeePayslipBean.employeeBean?.photoUrl == null
                                    ? Image.asset(
                                        "assets/images/avatar.png",
                                        fit: BoxFit.contain,
                                      )
                                    : Image.network(
                                        employeePayslipBean.employeeBean!.photoUrl!,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Text(
                                    employeePayslipBean.employeeBean?.employeeName ?? "-",
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (employeePayslipBean.employeeBean?.roles ?? []).join("\n").replaceAll("_", " "),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Net Pay: $INR_SYMBOL ${employeePayslipBean.isPaid() ? doubleToStringAsFixedForINR((employeePayslipBean.monthlyEmployeePayslipBeans ?? []).map((e) => e?.monthWiseEmployeePayslipComponentBeans ?? []).expand((i) => i).map((e) => (e == null ? 0 : e.componentType == "EARNINGS" ? 1 : -1) * (e?.amount ?? 0)).reduce((a1, a2) => a1 + a2) / 100.0) : doubleToStringAsFixedForINR(payslipTemplates.where((e1) => e1.employeeId == employeePayslipBean.employeeBean?.employeeId).map((e) => e.payslipTemplateComponentBeans ?? []).expand((i) => i).map((e) => (e == null ? 0 : e.payslipComponentType == "EARNINGS" ? 1 : -1) * (e?.amount ?? 0)).reduce((a1, a2) => a1 + a2) / 100.0)}",
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    employeePayslipBean.isTapped = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: const Icon(Icons.arrow_drop_down),
                                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(("Payslips for month of ${widget.monthAndYearForSchoolBean.month} - ${widget.monthAndYearForSchoolBean.year}").capitalize()),
      ),
      key: _scaffoldKey,
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                searchBar(),
                if (employeePayslips.map((e) => e.isPaid()).contains(false))
                  const SizedBox(
                    height: 10,
                  ),
                if (employeePayslips.map((e) => e.isPaid()).contains(false))
                  const Center(
                    child: Text("Pay salaries to"),
                  ),
                if (employeePayslips.map((e) => e.isPaid()).contains(false))
                  const SizedBox(
                    height: 10,
                  ),
                if (employeePayslips.map((e) => e.isPaid()).contains(false))
                  ...employeePayslips.where((e) => !e.isPaid()).map((e) => eachEmployeeCheckboxWidget(e)),
                if (employeePayslips.map((e) => e.isPaid()).contains(false) && employeePayslips.map((e) => e.isPaid()).contains(true))
                  const Divider(),
                if (employeePayslips.map((e) => e.isPaid()).contains(true))
                  const SizedBox(
                    height: 10,
                  ),
                if (employeePayslips.map((e) => e.isPaid()).contains(true))
                  const Center(
                    child: Text("Salaries already paid to"),
                  ),
                if (employeePayslips.map((e) => e.isPaid()).contains(true))
                  const SizedBox(
                    height: 10,
                  ),
                if (employeePayslips.map((e) => e.isPaid()).contains(true))
                  ...employeePayslips.where((e) => e.isPaid()).map((e) => eachEmployeeCheckboxWidget(e)),
                const SizedBox(height: 150),
              ],
            ),
      floatingActionButton: _isLoading || !employeePayslips.map((e) => e.isSelected).contains(true)
          ? null
          : GestureDetector(
              onTap: () {
                showDialog(
                  context: _scaffoldKey.currentContext!,
                  builder: (dialogueContext) {
                    return AlertDialog(
                      title: const Text('Pay salaries'),
                      content: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: ListView(
                          children: [
                            const Text("Are you sure to pay salaries?"),
                            ...actualEmployeePayslips
                                .where((e) => e.isSelected)
                                .map((employeePayslipBean) => Container(
                                      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              employeePayslipBean.employeeBean?.employeeName ?? "",
                                              style: const TextStyle(color: Colors.cyan),
                                            ),
                                          ),
                                          Text(
                                            "$INR_SYMBOL ${doubleToStringAsFixedForINR(employeePayslipBean.netPay(payslipTemplates))}",
                                            style: const TextStyle(color: Colors.cyan),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList()
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Proceed to pay"),
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() => _isLoading = true);
                            PayEmployeeSalariesResponse payEmployeeSalariesResponse = await payEmployeeSalaries(PayEmployeeSalariesRequest(
                              franchiseId: widget.adminProfile.franchiseId,
                              agent: widget.adminProfile.userId,
                              monthYearId: widget.monthAndYearForSchoolBean.monthAndYearForSchoolId,
                              schoolId: widget.adminProfile.schoolId,
                              employeeIds: employeePayslips.where((e) => e.isSelected).map((e) => e.employeeBean!.employeeId!).toList(),
                            ));
                            setState(() => _isLoading = false);
                            if (payEmployeeSalariesResponse.httpStatus != "OK" || payEmployeeSalariesResponse.responseStatus != "success") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Something went wrong! Try again later.."),
                                ),
                              );
                            } else {
                              _loadData();
                            }
                          },
                        ),
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: ClayButton(
                  surfaceColor: Colors.cyan,
                  parentColor: clayContainerColor(context),
                  height: 50,
                  width: 150,
                  borderRadius: 100,
                  spread: 4,
                  child: const Center(
                    child: Text("Pay now"),
                  ),
                ),
              ),
            ),
    );
  }
}
