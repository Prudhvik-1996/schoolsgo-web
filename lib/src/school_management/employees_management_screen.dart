import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/employee_card_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _tableView = true;

  List<SchoolWiseEmployeeBean> employees = [];
  int? selectedEmployeeId;

  ScrollController dataTableController = ScrollController();
  TextEditingController sNoSearchController = TextEditingController();
  TextEditingController nameSearchController = TextEditingController();
  TextEditingController mobileSearchController = TextEditingController();
  String? searchingWith;

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

  List<SchoolWiseEmployeeBean> get filteredEmployees => employees
      .where((e) => "${e.employeeId ?? " - "}".contains(sNoSearchController.text))
      .where((e) => (e.employeeName ?? " - ").toLowerCase().contains(nameSearchController.text.toLowerCase()))
      .where((e) => (e.mobile ?? " - ").toLowerCase().contains(mobileSearchController.text.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees Management"),
        actions: [
          IconButton(
            icon: _tableView ? const Icon(Icons.list) : const Icon(Icons.grid_view),
            onPressed: () => setState(() => _tableView = !_tableView),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : _tableView
              ? ListView(
                  children: [
                    credentialsTable(filteredEmployees),
                  ],
                )
              : ListView(
                  children: employees
                      .map((e) => EmployeeCardWidget(
                            adminProfile: widget.adminProfile,
                            employeeProfile: e,
                            isEmployeeSelected: selectedEmployeeId == e.employeeId,
                            onEmployeeSelected: onEmployeeSelected,
                          ))
                      .toList(),
                ),
    );
  }

  Widget credentialsTable(List<SchoolWiseEmployeeBean> employees) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 20,
      child: Scrollbar(
        thumbVisibility: true,
        controller: dataTableController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: dataTableController,
          child: DataTable(
            columns: [
              DataColumn(
                numeric: true,
                label: Row(
                  children: [
                    searchingWith == "S. No."
                        ? SizedBox(
                            width: 100,
                            child: TextField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'S. No.',
                                hintText: 'S. No.',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              controller: sNoSearchController,
                              autofocus: true,
                              onChanged: (_) => setState(() {}),
                            ),
                          )
                        : const Text(
                            "S. No.",
                            style: TextStyle(color: Colors.blue),
                          ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        editSearchingWith(searchingWith == "S. No." ? null : "S. No.");
                      },
                      icon: Icon(
                        searchingWith != "S. No." ? Icons.search : Icons.close,
                      ),
                    ),
                  ],
                ),
              ),
              DataColumn(
                numeric: false,
                label: Row(
                  children: [
                    searchingWith == "Name"
                        ? SizedBox(
                            width: 100,
                            child: TextField(
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Name',
                                hintText: 'Name',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              controller: nameSearchController,
                              autofocus: true,
                              onChanged: (_) => setState(() {}),
                            ),
                          )
                        : const Text(
                            "Name",
                            style: TextStyle(color: Colors.blue),
                          ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        editSearchingWith(searchingWith == "Name" ? null : "Name");
                      },
                      icon: Icon(
                        searchingWith != "Name" ? Icons.search : Icons.close,
                      ),
                    ),
                  ],
                ),
              ),
              const DataColumn(
                label: Text(
                  "Email",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              DataColumn(
                numeric: false,
                label: Row(
                  children: [
                    searchingWith == "Mobile"
                        ? SizedBox(
                      width: 100,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Mobile',
                          hintText: 'Mobile',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        controller: mobileSearchController,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    )
                        : const Text(
                      "Mobile",
                      style: TextStyle(color: Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        editSearchingWith(searchingWith == "Mobile" ? null : "Mobile");
                      },
                      icon: Icon(
                        searchingWith != "Mobile" ? Icons.search : Icons.close,
                      ),
                    ),
                  ],
                ),
              ),
              const DataColumn(
                label: Text(
                  "Login Id",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const DataColumn(
                label: Text(
                  "Roles",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
            rows: [
              ...employees.map(
                (eachEmployee) => DataRow(
                  cells: [
                    DataCell(Text("${employees.indexWhere((e) => e == eachEmployee) + 1}")),
                    DataCell(Text(eachEmployee.employeeName ?? " - ")),
                    DataCell(Text(eachEmployee.emailId ?? " - ")),
                    DataCell(
                      Row(
                        children: [
                          Text(eachEmployee.mobile ?? " - "),
                          if (eachEmployee.mobile != null)
                            IconButton(
                              onPressed: () => launch("tel://${eachEmployee.mobile}"),
                              icon: const Icon(Icons.phone),
                            ),
                        ],
                      ),
                    ),
                    DataCell(Text(eachEmployee.loginId ?? " - ")),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: (eachEmployee.roles ?? [])
                            .whereNotNull()
                            .sorted((a, b) => a.compareTo(b))
                            .map((e) => Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(e.replaceAll("_", " ")),
                                  ),
                                  // color: e == "ADMIN"
                                  //     ? Colors.red
                                  //     : e == "TEACHER"
                                  //         ? Colors.blue
                                  //         : null,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void editSearchingWith(String? newSearchingWith) => setState(() {
        sNoSearchController.text = "";
        nameSearchController.text = "";
        mobileSearchController.text = "";
        searchingWith = newSearchingWith;
      });
}
