import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/model/employee_attendance.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class EmployeeWiseDailyAttendanceStatsScreen extends StatefulWidget {
  const EmployeeWiseDailyAttendanceStatsScreen({
    Key? key,
    required this.adminProfile,
    required this.employees,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<EmployeeAttendanceBean> employees;

  @override
  State<EmployeeWiseDailyAttendanceStatsScreen> createState() => _EmployeeWiseDailyAttendanceStatsScreenState();
}

class _EmployeeWiseDailyAttendanceStatsScreenState extends State<EmployeeWiseDailyAttendanceStatsScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Date wise stats"),
      ),
      body: ListView(
        children: [
          const SizedBox(width: 20),
          datePickerRow(),
          const SizedBox(width: 20),
          EmployeeWiseStatsForDateTable(
            selectedDate: selectedDate,
            employees: widget.employees,
            context: context,
          ),
        ],
      ),
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

class EmployeeWiseStatsForDateTable extends StatelessWidget {
  const EmployeeWiseStatsForDateTable({
    Key? key,
    required this.employees,
    required this.selectedDate,
    required this.context,
  }) : super(key: key);

  final List<EmployeeAttendanceBean> employees;
  final DateTime selectedDate;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        divider(),
        Row(
          children: [
            verticalDivider(),
            Expanded(
              flex: 4,
              child: paddedText("Name"),
            ),
            verticalDivider(),
            Expanded(
              flex: 1,
              child: MediaQuery.of(context).orientation == Orientation.landscape
                  ? paddedText("Attendance")
                  : const Center(child: Icon(Icons.paste_rounded)),
            ),
            verticalDivider(),
            Expanded(
              flex: 6,
              child: paddedText("Clocks"),
            ),
            verticalDivider(),
          ],
        ),
        divider(),
        ...employees.map((employee) {
          ScrollController clocksController = ScrollController();
          DateWiseEmployeeAttendanceBean? dateWiseBean =
              employee.dateWiseEmployeeAttendanceBeanList?.where((e) => e?.date == convertDateTimeToYYYYMMDDFormat(selectedDate)).firstOrNull;
          return Column(
            children: [
              Row(
                children: [
                  verticalDivider(),
                  Expanded(
                    flex: 4,
                    child: paddedText(employee.employeeName ?? ''),
                  ),
                  verticalDivider(),
                  Expanded(
                    flex: 1,
                    child: attendanceStatus(dateWiseBean?.isPresent),
                  ),
                  verticalDivider(),
                  Expanded(
                    flex: 6,
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 8.0,
                      controller: clocksController,
                      child: SingleChildScrollView(
                        controller: clocksController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int index = 0; index < (dateWiseBean?.dateWiseEmployeeAttendanceDetailsBeans?.length ?? 0); index++)
                              clockedWidget(dateWiseBean, index),
                          ],
                        ),
                      ),
                    ),
                  ),
                  verticalDivider(),
                ],
              ),
              divider(),
            ],
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget attendanceStatus(String? status) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      switch (status) {
        case "P":
          return const Icon(Icons.check, color: Colors.green);
        case "A":
          return const Icon(Icons.clear, color: Colors.red);
        case "H":
          return const Icon(Icons.check, color: Colors.blue);
        case "L":
          return const Icon(Icons.clear, color: Colors.blue);
        default:
          return Center(child: paddedText("-"));
      }
    } else {
      switch (status) {
        case "P":
          return paddedText("Present");
        case "A":
          return paddedText("Absent");
        case "H":
          return paddedText("Half day");
        case "L":
          return paddedText("Leave");
        default:
          return paddedText("-");
      }
    }
  }

  Container verticalDivider() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      width: 1,
      height: 50,
    );
  }

  Widget paddedText(String? value) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Text(value ?? "-"),
      );

  Divider divider() {
    return const Divider(
      thickness: 1,
      color: Colors.grey,
      indent: 0,
      endIndent: 0,
      height: 1,
    );
  }

  Widget clockedWidget(DateWiseEmployeeAttendanceBean? dateWiseBean, int index) {
    final clockedTime = dateWiseBean?.dateWiseEmployeeAttendanceDetailsBeans?[index]?.clockedTime;
    final isClockedIn = dateWiseBean?.dateWiseEmployeeAttendanceDetailsBeans?[index]?.clockedIn ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Card(
        color: isClockedIn ? Colors.green : Colors.red,
        child: SizedBox(
          width: 210,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      isClockedIn ? Icons.alarm_on_outlined : Icons.alarm_off_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 160,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      clockedTime == null ? "-" : convertEpochToDDMMYYYYEEEEHHMMAA(clockedTime),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
