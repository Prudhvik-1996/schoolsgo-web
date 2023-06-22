import 'dart:async';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/admin/attendance_qr_widget.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/admin/employee_wise_attendance_detail_widget.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/model/employee_attendance.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class EmployeeAttendanceQRScreen extends StatefulWidget {
  const EmployeeAttendanceQRScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _EmployeeAttendanceQRScreenState createState() => _EmployeeAttendanceQRScreenState();
}

class _EmployeeAttendanceQRScreenState extends State<EmployeeAttendanceQRScreen> {
  bool isLoading = true;
  Timer? _timer;
  final int _refreshInterval = 10;

  bool showEmployees = false;
  bool showOnlyAbsentees = false;
  List<EmployeeAttendanceBean> employeeAttendanceBeanList = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: _refreshInterval), (_) => _loadData());
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (employeeAttendanceBeanList.isEmpty) {
      setState(() => isLoading = true);
    }
    GetEmployeeAttendanceResponse getEmployeeAttendanceResponse = await getEmployeeAttendance(GetEmployeeAttendanceRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getEmployeeAttendanceResponse.httpStatus != "OK" || getEmployeeAttendanceResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employeeAttendanceBeanList = (getEmployeeAttendanceResponse.employeeAttendanceBeanList ?? []).map((e) => e!).toList();
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          Tooltip(
            message: showEmployees ? "Hide employees" : "Show employees",
            child: IconButton(
              onPressed: () => setState(() => showEmployees = !showEmployees),
              icon: !showEmployees ? const Icon(Icons.person) : const Icon(Icons.person_off),
            ),
          ),
          if (showEmployees)
            Tooltip(
              message: showOnlyAbsentees ? "Show all" : "Show only absentees",
              child: IconButton(
                onPressed: () => setState(() => showOnlyAbsentees = !showOnlyAbsentees),
                icon: !showOnlyAbsentees ? const Icon(Icons.filter_alt) : const Icon(Icons.filter_alt_off),
              ),
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : !showEmployees
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      AttendanceQRWidget(adminProfile: widget.adminProfile),
                      const SizedBox(height: 20),
                      descriptionWidget(),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              : MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        AttendanceQRWidget(adminProfile: widget.adminProfile),
                        const SizedBox(height: 20),
                        descriptionWidget(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: employeeAttendanceListWidget(),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const SizedBox(width: 20),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Expanded(child: AttendanceQRWidget(adminProfile: widget.adminProfile)),
                            const SizedBox(height: 20),
                            descriptionWidget(),
                            const SizedBox(height: 20),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: employeeAttendanceListWidget(),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
    );
  }

  ListView employeeAttendanceListWidget() {
    return ListView(
      children: [
        ...employeeAttendanceBeanList
            .where((e) =>
                (showOnlyAbsentees &&
                    (e.dateWiseEmployeeAttendanceBeanList ?? []).where((e) => e?.date == convertDateTimeToYYYYMMDDFormat(DateTime.now())).isEmpty) ||
                !showOnlyAbsentees)
            .map(
              (e) => EmployeeWiseAttendanceDetailWidget(
                employeeAttendanceBean: e,
                selectedDate: DateTime.now(),
                loadData: () => _loadData(),
              ),
            ),
      ],
    );
  }

  Widget descriptionWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / (MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Expanded(
            child: Text(
              'Request employees to scan the above QR to clock the attendance',
              style: TextStyle(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
