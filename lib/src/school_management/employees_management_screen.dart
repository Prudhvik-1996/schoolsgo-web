import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/employee_card_widget.dart';

class EmployeesManagementScreen extends StatefulWidget {
  const EmployeesManagementScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<EmployeesManagementScreen> createState() => _EmployeesManagementScreenState();
}

class _EmployeesManagementScreenState extends State<EmployeesManagementScreen> {
  bool _isLoading = true;

  List<SchoolWiseEmployeeBean> employees = [];
  int? selectedEmployeeId;

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

  void onEmployeeSelected(int? employeeId) {
    setState(() => selectedEmployeeId = employeeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees Management"),
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
        children: employees.map((e) => EmployeeCardWidget(
          adminProfile: widget.adminProfile,
          employeeProfile: e,
          isEmployeeSelected: selectedEmployeeId == e.employeeId,
          onEmployeeSelected: onEmployeeSelected,
        )).toList(),
      ),
    );
  }
}
