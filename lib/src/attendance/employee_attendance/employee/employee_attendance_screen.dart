import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/model/employee_attendance.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/qr_scanner/qr_scanner_widget.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({
    Key? key,
    required this.employeeBean,
  }) : super(key: key);

  final SchoolWiseEmployeeBean employeeBean;

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  EmployeeAttendanceBean? employeeAttendanceBean;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    GetEmployeeAttendanceResponse getEmployeeAttendanceResponse = await getEmployeeAttendance(GetEmployeeAttendanceRequest(
      schoolId: widget.employeeBean.schoolId,
      employeeId: widget.employeeBean.employeeId,
    ));
    if (getEmployeeAttendanceResponse.httpStatus != "OK" || getEmployeeAttendanceResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employeeAttendanceBean = (getEmployeeAttendanceResponse.employeeAttendanceBeanList ?? []).map((e) => e!).toList().firstOrNull();
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Attendance"),
      ),
      body: isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  datePickerRow(),
                  const SizedBox(height: 20),
                  attendanceForDateWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton:
          employeeAttendanceBean == null || convertDateTimeToYYYYMMDDFormat(selectedDate) != convertDateTimeToYYYYMMDDFormat(DateTime.now())
              ? null
              : FloatingActionButton(
                  tooltip: "Scan QR",
                  child: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return QrScannerWidget(
                        employeeAttendanceBean: employeeAttendanceBean!,
                      );
                    })).then((_) => _loadData());
                  },
                ),
    );
  }

  Widget attendanceForDateWidget() {
    List<DateWiseEmployeeAttendanceDetailsBean> dateWiseEmployeeAttendanceBeanList =
        (employeeAttendanceBean?.dateWiseEmployeeAttendanceBeanList ?? [])
            .where((e) => e?.date == convertDateTimeToYYYYMMDDFormat(selectedDate))
            .map((e) => e?.dateWiseEmployeeAttendanceDetailsBeans ?? [])
            .expand((i) => i)
            .where((e) => e != null)
            .map((e) => e!)
            .where((e) => e.clockedTime != null)
            .toList();
    if (dateWiseEmployeeAttendanceBeanList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SizedBox(width: 10),
            Icon(Icons.timer_sharp),
            SizedBox(width: 10),
            Text('Marked at: '),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "-",
                style: TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      );
    }
    return Column(
      children: [
        ...List.generate(dateWiseEmployeeAttendanceBeanList.length, (index) {
          DateWiseEmployeeAttendanceDetailsBean e = dateWiseEmployeeAttendanceBeanList[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.timer_sharp),
                const SizedBox(width: 10),
                const Text('Marked at: '),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    convertEpochToDDMMYYYYEEEEHHMMAA(e.clockedTime!),
                    style: TextStyle(
                      color: index % 2 == 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget datePickerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        getLeftArrowWidget(),
        const SizedBox(width: 10),
        Expanded(child: getDatePickerWidget()),
        const SizedBox(width: 10),
        getRightArrowWidget(),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget getDatePickerWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now(),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            selectedDate = _newDate;
          });
        },
        child: ClayButton(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          height: 45,
          width: 45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, // mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    convertDateTimeToDDMMYYYYFormat(selectedDate),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLeftArrowWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Previous Day",
        child: GestureDetector(
          onTap: () {
            if (selectedDate.millisecondsSinceEpoch == DateTime.now().subtract(const Duration(days: 364)).millisecondsSinceEpoch) return;
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_left),
          ),
        ),
      ),
    );
  }

  Widget getRightArrowWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Next Day",
        child: GestureDetector(
          onTap: () {
            if (convertDateTimeToYYYYMMDDFormat(selectedDate) == convertDateTimeToYYYYMMDDFormat(null)) return;
            setState(() {
              selectedDate = selectedDate.add(const Duration(days: 1));
            });
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_right),
          ),
        ),
      ),
    );
  }
}
