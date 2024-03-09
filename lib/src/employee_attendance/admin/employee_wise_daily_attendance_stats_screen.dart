import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/employee_attendance/model/employee_attendance.dart';
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
  late DateTime selectedDate;

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    setNewDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Date wise stats"),
        actions: [
          IconButton(onPressed: () => setState(() => isEditMode = !isEditMode), icon: isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit)),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(width: 20),
          datePickerRow(),
          const SizedBox(width: 20),
          if (isEditMode) const SizedBox(width: 20),
          if (isEditMode) editModeInstructionsWidget(),
          EmployeeWiseStatsForDateTable(
            selectedDate: selectedDate,
            employees: widget.employees,
            context: context,
            isEditMode: isEditMode,
            attendanceMarkerWidget: attendanceMarkerWidget,
          ),
        ],
      ),
    );
  }

  Widget attendanceMarkerWidget(String attendanceStatus, DateWiseEmployeeAttendanceBean employeeAttendanceBean) {
    return GestureDetector(
      onTap: () {
        print("59: ${employeeAttendanceBean.isPresent} == $attendanceStatus");
        if (employeeAttendanceBean.isPresent == attendanceStatus) {
          employeeAttendanceBean.isPresent = "-";
        }
        switch (attendanceStatus) {
          case "P":
            setState(() => employeeAttendanceBean.isPresent = "P");
            return;
          case "A":
            setState(() => employeeAttendanceBean.isPresent = "A");
            return;
          case "H":
            setState(() => employeeAttendanceBean.isPresent = "H");
            return;
          case "L":
            setState(() => employeeAttendanceBean.isPresent = "L");
            return;
          default:
            setState(() => employeeAttendanceBean.isPresent = "-");
            return;
        }
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: employeeAttendanceBean.isPresent == attendanceStatus ? Colors.grey : clayContainerColor(context),
        parentColor: employeeAttendanceBean.isPresent == attendanceStatus ? Colors.grey : clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(3),
          child: SizedBox(
            height: 12,
            width: 12,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: attendanceStatusIconWidget(attendanceStatus),
            ),
          ),
        ),
      ),
    );
  }

  Widget editModeInstructionsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        attendanceStatusWidget("P"),
        const SizedBox(width: 10),
        attendanceStatusWidget("A"),
        const SizedBox(width: 10),
        attendanceStatusWidget("H"),
        const SizedBox(width: 10),
        attendanceStatusWidget("L"),
        const SizedBox(width: 10),
        attendanceStatusWidget("-"),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget attendanceStatusWidget(String attendanceStatus) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 5),
        attendanceStatusIconWidget(attendanceStatus),
        const SizedBox(height: 5),
        attendanceStatusDescription(attendanceStatus),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget attendanceStatusIconWidget(String? status) {
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
        return const Center(child: Text("-"));
    }
  }

  Widget attendanceStatusDescription(String? status) {
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
        return paddedText("Not Marked");
    }
  }

  Widget paddedText(String? value) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Text(value ?? "-", style: const TextStyle(fontSize: 9)),
      );

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

  void setNewDate(DateTime _newDate) {
    setState(() {
      selectedDate = _newDate;
    });
    widget.employees.forEach((employee) {
      if (employee.dateWiseEmployeeAttendanceBeanList?.where((e) => e?.date == convertDateTimeToYYYYMMDDFormat(selectedDate)).firstOrNull != null) {
        return;
      } else {
        setState(() {
          employee.dateWiseEmployeeAttendanceBeanList ??= [];
          employee.dateWiseEmployeeAttendanceBeanList!.add(DateWiseEmployeeAttendanceBean(
            employeeId: employee.employeeId,
            date: convertDateTimeToYYYYMMDDFormat(selectedDate),
            isPresent: "-",
          ));
        });
      }
    });
  }

  Widget getDatePickerWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: GestureDetector(
        onTap: () async {
          if (isEditMode) return;
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now(),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setNewDate(_newDate);
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
            if (isEditMode) return;
            if (selectedDate.millisecondsSinceEpoch == DateTime.now().subtract(const Duration(days: 364)).millisecondsSinceEpoch) return;
            setNewDate(selectedDate.subtract(const Duration(days: 1)));
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
            if (isEditMode) return;
            if (convertDateTimeToYYYYMMDDFormat(selectedDate) == convertDateTimeToYYYYMMDDFormat(null)) return;
            setNewDate(selectedDate.add(const Duration(days: 1)));
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
  const EmployeeWiseStatsForDateTable(
      {Key? key,
      required this.employees,
      required this.selectedDate,
      required this.context,
      required this.isEditMode,
      required this.attendanceMarkerWidget})
      : super(key: key);

  final List<EmployeeAttendanceBean> employees;
  final DateTime selectedDate;
  final BuildContext context;
  final bool isEditMode;
  final Function attendanceMarkerWidget;

  Widget attendanceControls(DateWiseEmployeeAttendanceBean dateWiseEmployeeAttendanceBean) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              attendanceMarkerWidget("P", dateWiseEmployeeAttendanceBean),
              attendanceMarkerWidget("A", dateWiseEmployeeAttendanceBean),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              attendanceMarkerWidget("H", dateWiseEmployeeAttendanceBean),
              attendanceMarkerWidget("L", dateWiseEmployeeAttendanceBean),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          attendanceMarkerWidget("P", dateWiseEmployeeAttendanceBean),
          attendanceMarkerWidget("A", dateWiseEmployeeAttendanceBean),
          attendanceMarkerWidget("H", dateWiseEmployeeAttendanceBean),
          attendanceMarkerWidget("L", dateWiseEmployeeAttendanceBean),
        ],
      );
    }
  }

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
              flex: 2,
              child: MediaQuery.of(context).orientation == Orientation.landscape
                  ? paddedText("Attendance")
                  : const Center(child: Icon(Icons.paste_rounded)),
            ),
            verticalDivider(),
            Expanded(
              flex: 5,
              child: paddedText("Clocks"),
            ),
            verticalDivider(),
          ],
        ),
        divider(),
        ...employees.map((employee) {
          ScrollController clocksController = ScrollController();
          DateWiseEmployeeAttendanceBean dateWiseBean = employee.dateWiseEmployeeAttendanceBeanList
                  ?.where((e) => e?.date == convertDateTimeToYYYYMMDDFormat(selectedDate))
                  .firstOrNull ??
              DateWiseEmployeeAttendanceBean(employeeId: employee.employeeId, date: convertDateTimeToYYYYMMDDFormat(selectedDate), isPresent: "-");
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
                    flex: 2,
                    child: isEditMode ? attendanceControls(dateWiseBean) : attendanceStatus(dateWiseBean.isPresent),
                  ),
                  verticalDivider(),
                  Expanded(
                    flex: 5,
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 8.0,
                      controller: clocksController,
                      child: SingleChildScrollView(
                        controller: clocksController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int index = 0; index < (dateWiseBean.dateWiseEmployeeAttendanceDetailsBeans?.length ?? 0); index++)
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
