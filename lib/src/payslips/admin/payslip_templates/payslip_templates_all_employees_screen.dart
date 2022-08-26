import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/payslips/admin/payslip_templates/payslips_templates_screen.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class PayslipTemplatesAllEmployeeScreen extends StatefulWidget {
  const PayslipTemplatesAllEmployeeScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<PayslipTemplatesAllEmployeeScreen> createState() => _PayslipTemplatesAllEmployeeScreenState();
}

class _PayslipTemplatesAllEmployeeScreenState extends State<PayslipTemplatesAllEmployeeScreen> {
  bool _isLoading = true;

  List<SchoolWiseEmployeeBean> employees = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolWiseEmployeesResponse.httpStatus != "OK" || getSchoolWiseEmployeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employees = (getSchoolWiseEmployeesResponse.employees ?? []).map((e) => e!).toList();
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
        title: const Text("Payslips"),
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
              children: employees.map((e) => _employeeWidget(e)).toList(),
            ),
    );
  }

  Widget _employeeWidget(SchoolWiseEmployeeBean employee) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PayslipTemplatesScreen(
              adminProfile: widget.adminProfile,
              employeeBean: employee,
            );
          }));
        },
        child: ClayButton(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text((employee.employeeName ?? "-").capitalize()),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  (employee.roles ?? []).map((e) => e?.toLowerCase().capitalize()).join(", "),
                ),
                const SizedBox(
                  width: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
