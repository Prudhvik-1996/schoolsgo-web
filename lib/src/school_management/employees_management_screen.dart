import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/user_roles.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<SchoolWiseEmployeeBean> employees = [];
  int? selectedEmployeeId;

  ScrollController dataTableHorizontalController = ScrollController();
  ScrollController dataTableVerticalController = ScrollController();
  TextEditingController sNoSearchController = TextEditingController();
  TextEditingController nameSearchController = TextEditingController();
  TextEditingController mobileSearchController = TextEditingController();
  String? searchingWith;

  bool isAddingNewEmployee = false;

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
      key: scaffoldKey,
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
          : SizedBox(
              width: MediaQuery.of(context).size.width - 10,
              height: MediaQuery.of(context).size.height - 10,
              child: employeesTable(filteredEmployees),
            ),
      floatingActionButton: !_isLoading && selectedEmployeeId == null && !isAddingNewEmployee
          ? fab(
              const Icon(Icons.add),
              "Add Employee",
              () async {
                setState(() {
                  employees.add(SchoolWiseEmployeeBean(
                    employeeId: -1,
                    schoolId: widget.adminProfile.schoolId,
                  ));
                  selectedEmployeeId = -1;
                });
                dataTableVerticalController.animateTo(
                  dataTableVerticalController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              color: Colors.green,
            )
          : null,
    );
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

  Widget employeesTable(List<SchoolWiseEmployeeBean> employees) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 20,
      child: Scrollbar(
        thumbVisibility: true,
        controller: dataTableHorizontalController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: dataTableHorizontalController,
          child: Scrollbar(
            thumbVisibility: true,
            controller: dataTableVerticalController,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: dataTableVerticalController,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: DataTable(
                  columns: extractDataTableColumns(),
                  rows: [
                    ...employees.mapIndexed(
                      (employeeIndex, eachEmployee) => selectedEmployeeId == eachEmployee.employeeId
                          ? eachEmployeeDataTableRowForEditMode(employeeIndex, employees)
                          : eachEmployeeDataTableRowForReadMode(employeeIndex, employees),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow eachEmployeeDataTableRowForEditMode(int employeeIndex, List<SchoolWiseEmployeeBean> employees) {
    SchoolWiseEmployeeBean eachEmployee = employees[employeeIndex];
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                onPressed: () async {
                  if (const DeepCollectionEquality().equals(eachEmployee.origJson()..removeWhere((key, value) => value == null),
                      eachEmployee.toJson()..removeWhere((key, value) => value == null))) {
                    onEmployeeSelected(null);
                    return;
                  }
                  await saveChanges(eachEmployee, employees, employeeIndex);
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => employees[employeeIndex] = SchoolWiseEmployeeBean.fromJson(eachEmployee.origJson()));
                  onEmployeeSelected(null);
                },
              ),
            ],
          ),
        ),
        DataCell(
          SizedBox(
            width: 300,
            child: TextFormField(
              enabled: true,
              initialValue: eachEmployee.employeeName,
              keyboardType: TextInputType.name,
              textAlign: TextAlign.left,
              onChanged: (String? value) {
                setState(() {
                  eachEmployee.employeeName = value ?? "";
                });
              },
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 300,
            child: TextFormField(
              enabled: true,
              initialValue: eachEmployee.emailId,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.left,
              onChanged: (String? value) {
                setState(() {
                  eachEmployee.emailId = value ?? "";
                });
              },
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 300,
            child: TextFormField(
              enabled: true,
              initialValue: eachEmployee.mobile,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.left,
              onChanged: (String? value) {
                setState(() {
                  eachEmployee.mobile = value ?? "";
                });
              },
            ),
          ),
        ),
        loginIdDataCell(eachEmployee),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: UserRole.values
                .sorted((a, b) => a.name.compareTo(b.name))
                .map((e) => InkWell(
                      onTap: () {
                        eachEmployee.roles ??= [];
                        if (eachEmployee.roles!.length == 1 && eachEmployee.roles!.firstOrNull == e.name) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Employee must be assigned to at least one role"),
                            ),
                          );
                          return;
                        }
                        if (eachEmployee.roles!.contains(e.name)) {
                          setState(() => eachEmployee.roles!.remove(e.name));
                        } else {
                          setState(() => eachEmployee.roles!.add(e.name));
                        }
                      },
                      child: Card(
                        color: (eachEmployee.roles ?? []).contains(e.name) ? Colors.blue : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(e.name.split("_").map((e) => e.capitalize()).join(" ")),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> saveChanges(SchoolWiseEmployeeBean eachEmployee, List<SchoolWiseEmployeeBean> employees, int employeeIndex) async {
    if ((eachEmployee.employeeName ?? "").isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Employee must be assigned to at least one role"),
        ),
      );
      return;
    }
    if ((eachEmployee.roles ?? []).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Employee must be assigned to at least one role"),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    List<String> previousRolesList = (SchoolWiseEmployeeBean.fromJson(eachEmployee.origJson()).roles ?? []).whereNotNull().toList();
    CreateUserAndAssignRolesRequest createUserAndAssignRolesRequest = CreateUserAndAssignRolesRequest(
      userId: eachEmployee.employeeId == -1 ? null : eachEmployee.employeeId,
      schoolId: eachEmployee.schoolId,
      firstName: eachEmployee.employeeName,
      mobile: eachEmployee.mobile,
      mailId: eachEmployee.emailId,
      isAdmin: (previousRolesList).contains(UserRole.ADMIN.name) && !(eachEmployee.roles ?? []).contains(UserRole.ADMIN.name)
          ? false
          : !(previousRolesList).contains(UserRole.ADMIN.name) && (eachEmployee.roles ?? []).contains(UserRole.ADMIN.name)
              ? true
              : null,
      isTeacher: (previousRolesList).contains(UserRole.TEACHER.name) && !(eachEmployee.roles ?? []).contains(UserRole.TEACHER.name)
          ? false
          : !(previousRolesList).contains(UserRole.TEACHER.name) && (eachEmployee.roles ?? []).contains(UserRole.TEACHER.name)
              ? true
              : null,
      isNonTeachingStaff: (previousRolesList).contains(UserRole.NON_TEACHING_STAFF.name) &&
              !(eachEmployee.roles ?? []).contains(UserRole.NON_TEACHING_STAFF.name)
          ? false
          : !(previousRolesList).contains(UserRole.NON_TEACHING_STAFF.name) && (eachEmployee.roles ?? []).contains(UserRole.NON_TEACHING_STAFF.name)
              ? true
              : null,
      isBusDriver: (previousRolesList).contains(UserRole.BUS_DRIVER.name) && !(eachEmployee.roles ?? []).contains(UserRole.BUS_DRIVER.name)
          ? false
          : !(previousRolesList).contains(UserRole.BUS_DRIVER.name) && (eachEmployee.roles ?? []).contains(UserRole.BUS_DRIVER.name)
              ? true
              : null,
      isReceptionist: (previousRolesList).contains(UserRole.RECEPTIONIST.name) && !(eachEmployee.roles ?? []).contains(UserRole.RECEPTIONIST.name)
          ? false
          : !(previousRolesList).contains(UserRole.RECEPTIONIST.name) && (eachEmployee.roles ?? []).contains(UserRole.RECEPTIONIST.name)
              ? true
              : null,
      status: "active",
      agent: widget.adminProfile.userId,
    );
    CreateUserAndAssignRolesResponse createUserAndAssignRolesResponse = await createUserAndAssignRoles(createUserAndAssignRolesRequest);
    if (createUserAndAssignRolesResponse.httpStatus != "OK" ||
        createUserAndAssignRolesResponse.responseStatus != "success" ||
        createUserAndAssignRolesResponse.employeeBean == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employees[employeeIndex] = createUserAndAssignRolesResponse.employeeBean!;
      });
      onEmployeeSelected(null);
    }
    setState(() => _isLoading = false);
  }

  DataRow eachEmployeeDataTableRowForReadMode(int employeeIndex, List<SchoolWiseEmployeeBean> employees) {
    SchoolWiseEmployeeBean eachEmployee = employees[employeeIndex];
    return DataRow(
      cells: [
        DataCell(
          showEditIcon: selectedEmployeeId == null,
          onTap: () {
            if (selectedEmployeeId == null) onEmployeeSelected(eachEmployee.employeeId);
          },
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text("${employees.indexWhere((e) => e == eachEmployee) + 1}"),
          ),
        ),
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
        loginIdDataCell(eachEmployee),
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
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  DataCell loginIdDataCell(SchoolWiseEmployeeBean eachEmployee) => DataCell(Text(eachEmployee.loginId ?? " - "));

  List<DataColumn> extractDataTableColumns() {
    return [
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
    ];
  }

  void editSearchingWith(String? newSearchingWith) => setState(() {
        sNoSearchController.text = "";
        nameSearchController.text = "";
        mobileSearchController.text = "";
        searchingWith = newSearchingWith;
      });
}
