import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/payslips/modal/payslips.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class PayslipTemplatesScreen extends StatefulWidget {
  const PayslipTemplatesScreen({
    Key? key,
    required this.adminProfile,
    required this.employeeBean,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final SchoolWiseEmployeeBean employeeBean;

  @override
  State<PayslipTemplatesScreen> createState() => _PayslipTemplatesScreenState();
}

class _PayslipTemplatesScreenState extends State<PayslipTemplatesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  bool _isEditMode = false;

  PayslipTemplateForEmployeeBean? template;

  List<EmployeePayslipBean> employeePayslips = [];

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
        schoolId: widget.employeeBean.schoolId,
        franchiseId: widget.employeeBean.franchiseId,
        employeeId: widget.employeeBean.employeeId,
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
        template = getPayslipTemplateForEmployeeResponse.payslipTemplateForEmployeeBeans?.firstOrNull;
      });
    }
    GetEmployeePayslipsResponse getEmployeePayslipsResponse = await getEmployeePayslips(
      GetEmployeePayslipsRequest(
        schoolId: widget.employeeBean.schoolId,
        franchiseId: widget.employeeBean.franchiseId,
        employeeId: widget.employeeBean.employeeId,
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
        employeePayslips = (getEmployeePayslipsResponse.employeePayslipBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _employeePayslipTemplateWidget() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        buildEmployeeBasicDetails(),
        buildComponentsTable(),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: clayContainerColor(context),
              ),
              bottom: BorderSide(
                color: clayContainerColor(context),
              ),
              right: BorderSide(
                color: clayContainerColor(context),
              ),
            ),
          ),
          child: Text(
            "Net Pay: $INR_SYMBOL ${doubleToStringAsFixedForINR((template?.payslipTemplateComponentBeans?.map((e) => (e?.payslipComponentType == "EARNINGS" ? 1 : -1) * (e?.amount ?? 0)).toList().sum ?? 0) / 100.0)}",
          ),
        ),
      ],
    );
  }

  // Widget _getMonthDetailsForMonthlyPayslipWidget(MonthAndYearForSchoolBean monthAndYearBean) {
  //   return Center(
  //     child: Text(
  //       "${(monthAndYearBean.month ?? " ").capitalize()} - ${monthAndYearBean.year}",
  //       style: const TextStyle(
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _monthWiseEmployeePayslipComponentWidget(MonthWiseEmployeePayslipComponentBean monthWiseEmployeePayslipComponentBean) {
  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           flex: 1,
  //           child: Text((monthWiseEmployeePayslipComponentBean.componentName ?? "").capitalize()),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: Text((monthWiseEmployeePayslipComponentBean.componentType ?? "").capitalize()),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: Text("${monthWiseEmployeePayslipComponentBean.amount}"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  Widget _employeeMonthlyPayslipWidget(MonthlyEmployeePayslipBean monthlyEmployeePayslipBean) {
    if (monthlyEmployeePayslipBean.monthAndYearBean == null) return Container();
    List<MonthWiseEmployeePayslipComponentBean> earningBeans = (monthlyEmployeePayslipBean.monthWiseEmployeePayslipComponentBeans ?? [])
        .where((e) => e != null)
        .map((e) => e!)
        .where((e) => e.componentType == "EARNINGS")
        .toList();
    List<MonthWiseEmployeePayslipComponentBean> deductionBeans = (monthlyEmployeePayslipBean.monthWiseEmployeePayslipComponentBeans ?? [])
        .where((e) => e != null)
        .map((e) => e!)
        .where((e) => e.componentType == "DEDUCTIONS")
        .toList();
    MonthWiseEmployeePayslipComponentBean lopBean = (monthlyEmployeePayslipBean.monthWiseEmployeePayslipComponentBeans ?? [])
        .where((e) => e != null)
        .map((e) => e!)
        .where((e) => e.componentType == "LOP")
        .toList()
        .first;
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // _getMonthDetailsForMonthlyPayslipWidget(monthlyEmployeePayslipBean.monthAndYearBean!),
              // for (MonthWiseEmployeePayslipComponentBean monthWiseEmployeePayslipComponentBean
              //     in (monthlyEmployeePayslipBean.monthWiseEmployeePayslipComponentBeans ?? []).where((e) => e != null).map((e) => e!))
              //   _monthWiseEmployeePayslipComponentWidget(monthWiseEmployeePayslipComponentBean)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${(monthlyEmployeePayslipBean.monthAndYearBean!.month ?? " ").capitalize()} - ${monthlyEmployeePayslipBean.monthAndYearBean!.year}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text("LOP Days: ${lopBean.noOfLopDays}")
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: clayContainerColor(context),
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            const Text("Earnings"),
                            const SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 1,
                              color: clayContainerColor(context),
                            ),
                            Column(
                              children: earningBeans
                                  .map(
                                    (e) => Container(
                                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text((e.componentName ?? "").capitalize()),
                                          ),
                                          Text("$INR_SYMBOL ${doubleToStringAsFixed((e.amount ?? 0) / 100.0)}")
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        thickness: 1,
                        color: clayContainerColor(context),
                        endIndent: 0,
                        indent: 0,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            const Text("Deductions"),
                            const SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 1,
                              color: clayContainerColor(context),
                            ),
                            Column(
                              children: deductionBeans
                                      .map(
                                        (e) => Container(
                                          margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text((e.componentName ?? "").capitalize()),
                                              ),
                                              Text("$INR_SYMBOL ${doubleToStringAsFixed((e.amount ?? 0) / 100.0)}")
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList() +
                                  [
                                    lopBean.noOfLopDays == 0
                                        ? Container()
                                        : Container(
                                            child: Row(
                                              children: [
                                                const Expanded(
                                                  child: Text("Loss Of Pay"),
                                                ),
                                                Text("$INR_SYMBOL ${doubleToStringAsFixed((lopBean.amount ?? 0) / 100.0)}")
                                              ],
                                            ),
                                          )
                                  ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: clayContainerColor(context),
                    ),
                    bottom: BorderSide(
                      color: clayContainerColor(context),
                    ),
                    right: BorderSide(
                      color: clayContainerColor(context),
                    ),
                  ),
                ),
                child: Text(
                  "Net Pay: $INR_SYMBOL ${doubleToStringAsFixedForINR(((earningBeans.isEmpty ? 0 : earningBeans.map((e) => e.amount ?? 0).reduce((e1, e2) => (e1) + (e2))) - (deductionBeans.isEmpty ? 0 : deductionBeans.map((e) => e.amount ?? 0).reduce((e1, e2) => (e1) + (e2))) - (lopBean.amount ?? 0)) / 100.0)}",
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 0.1,
          color: isDarkTheme(context) ? Colors.white : Colors.black,
        ),
      ],
    );
  }

  Widget _employeePayslipsWidget(EmployeePayslipBean payslipBean) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Divider(
            thickness: 0.1,
            color: isDarkTheme(context) ? Colors.white : Colors.black,
          ),
          for (MonthlyEmployeePayslipBean monthlyEmployeePayslipBean
              in (payslipBean.monthlyEmployeePayslipBeans ?? []).where((e) => e != null).map((e) => e!))
            _employeeMonthlyPayslipWidget(monthlyEmployeePayslipBean),
        ],
      ),
    );
  }

  Widget _getPreviousPayslips() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
              const Center(
                child: Text(
                  "Payslips",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ] +
            employeePayslips.map((e) => _employeePayslipsWidget(e)).toList(),
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context) async {
    PayslipTemplateForEmployeeBean editingTemplate = PayslipTemplateForEmployeeBean.fromJson(template!.origJson())
      ..payslipTemplateComponentBeans = (template!.payslipTemplateComponentBeans ?? [])
          .where((eachComponent) =>
              eachComponent != null && ((eachComponent.amount ?? 0) != (PayslipTemplateComponentBean.fromJson(eachComponent.origJson()).amount ?? 0)))
          .map((e) => e!)
          .toList();
    if (editingTemplate.payslipTemplateComponentBeans?.isNotEmpty ?? false) {
      CreateOrUpdatePayslipTemplateForEmployeeBeanRequest request = CreateOrUpdatePayslipTemplateForEmployeeBeanRequest(
        agent: widget.adminProfile.userId,
        schoolId: widget.adminProfile.schoolId,
        payslipTemplateForEmployeeBean: editingTemplate,
      );
      CreateOrUpdatePayslipTemplateForEmployeeBeanResponse response = await createOrUpdatePayslipTemplateForEmployeeBean(request);
      if (response.httpStatus != 'OK' || response.responseStatus != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong while trying to process your request..\nPlease try again later"),
          ),
        );
      } else {
        await _loadData();
        setState(() => _isEditMode = false);
      }
    }
  }

  Widget buildEmployeeBasicDetails() {
    return Container(
      margin: const EdgeInsets.all(25),
      child: Row(
        children: [
          Expanded(
            child: Text("Employee Name: ${(widget.employeeBean.employeeName ?? "-").capitalize()}"),
          )
        ],
      ),
    );
  }

  Widget buildComponentsTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: clayContainerColor(context),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("Earnings"),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1,
                    color: clayContainerColor(context),
                  ),
                  Column(
                    children: (template?.payslipTemplateComponentBeans ?? [])
                        .where((e) => e?.payslipComponentType == "EARNINGS")
                        .map(
                          (e) => _isEditMode ? buildPayslipComponentEditModeWidget(e) : buildPayslipComponentReadModeWidget(e),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              thickness: 1,
              color: clayContainerColor(context),
              endIndent: 0,
              indent: 0,
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("Deductions"),
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1,
                    color: clayContainerColor(context),
                  ),
                  Column(
                    children: (template?.payslipTemplateComponentBeans ?? [])
                        .where((e) => e?.payslipComponentType == "DEDUCTIONS")
                        .map(
                          (e) => _isEditMode ? buildPayslipComponentEditModeWidget(e) : buildPayslipComponentReadModeWidget(e),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildPayslipComponentReadModeWidget(PayslipTemplateComponentBean? e) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              (e?.componentName ?? "-").toLowerCase().capitalize(),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(e?.amount == null ? "-" : "$INR_SYMBOL ${doubleToStringAsFixedForINR(e!.amount! / 100)} /-"),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  Container buildPayslipComponentEditModeWidget(PayslipTemplateComponentBean? payslipComponent) {
    if (payslipComponent == null) return Container();
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              (payslipComponent.componentName ?? "-").toLowerCase().capitalize(),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 40,
            child: TextField(
              controller: payslipComponent.amountController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelText: MediaQuery.of(context).orientation == Orientation.landscape ? 'Amount ($INR_SYMBOL)' : INR_SYMBOL,
                hintText: MediaQuery.of(context).orientation == Orientation.landscape ? 'Amount' : INR_SYMBOL,
                contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                errorText: payslipComponent.amountController.text == "" ? "Amount is a mandatory field" : null,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    if (newValue.text.split(".").length > 2) return oldValue;
                    if (newValue.text.contains(".") && newValue.text.split(".")[1].length > 2) return oldValue;
                    return newValue;
                  } catch (e) {
                    return oldValue;
                  }
                }),
              ],
              onChanged: (String e) {
                double? triedAmount = double.tryParse(e);
                if (triedAmount == null) return;
                setState(() => payslipComponent.amount = (triedAmount * 100).toInt());
              },
              style: const TextStyle(
                fontSize: 12,
              ),
              autofocus: true,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.employeeBean.employeeName ?? "-").capitalize()),
      ),
      key: _scaffoldKey,
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                _employeePayslipTemplateWidget(),
                _getPreviousPayslips(),
              ],
            ),
      floatingActionButton: template == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                if (!_isEditMode) {
                  setState(() => _isEditMode = true);
                } else {
                  if (template == null) return;
                  showDialog(
                    context: _scaffoldKey.currentContext!,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text('Payslip Template for ${widget.employeeBean.employeeName}'),
                        content: const Text("Are you sure to save changes?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("YES"),
                            onPressed: () async {
                              Navigator.pop(context);
                              await _saveChanges(context);
                            },
                          ),
                          TextButton(
                            child: const Text("No"),
                            onPressed: () async {
                              Navigator.pop(context);
                              await _loadData();
                            },
                          ),
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () async {
                              Navigator.pop(context);
                              if (template == null) return;
                              setState(() => _isLoading = true);
                              setState(() => template = PayslipTemplateForEmployeeBean.fromJson(template!.origJson()));
                              setState(() => _isLoading = false);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
                setState(() => _isLoading = false);
              },
              child: _isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
            ),
    );
  }
}
