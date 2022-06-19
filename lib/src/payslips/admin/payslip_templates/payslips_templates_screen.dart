import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/payslips/modal/payslips.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

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
  bool _isLoading = true;

  PayslipTemplateForEmployeeBean? template;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetPayslipTemplateForEmployeeResponse getPayslipTemplateForEmployeeResponse =
        await getPayslipTemplateForEmployee(GetPayslipTemplateForEmployeeRequest(
      schoolId: widget.employeeBean.schoolId,
      franchiseId: widget.employeeBean.franchiseId,
      employeeId: widget.employeeBean.employeeId,
    ));
    if (getPayslipTemplateForEmployeeResponse.httpStatus != "OK" || getPayslipTemplateForEmployeeResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        template = getPayslipTemplateForEmployeeResponse.payslipTemplateForEmployeeBean;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.employeeBean.employeeName ?? "-").capitalize()),
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
                    "Net Pay: ${doubleToStringAsFixedForINR((template?.payslipTemplateComponentBeans?.map((e) => (e?.payslipComponentType == "EARNINGS" ? 1 : -1) * (e?.amount ?? 0)).toList().sum ?? 0) / 100.0)}",
                  ),
                ),
              ],
            ),
    );
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
                          (e) => Container(
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
                          (e) => Container(
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
                          ),
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
}
