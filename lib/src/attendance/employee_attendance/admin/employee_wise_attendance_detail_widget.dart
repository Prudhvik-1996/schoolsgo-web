import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/model/employee_attendance.dart';
import 'package:schoolsgo_web/src/attendance/employee_attendance/qr_scanner/qr_scanner_widget.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class EmployeeWiseAttendanceDetailWidget extends StatefulWidget {
  const EmployeeWiseAttendanceDetailWidget({
    Key? key,
    required this.employeeAttendanceBean,
    required this.selectedDate,
    required this.loadData,
  }) : super(key: key);

  final EmployeeAttendanceBean employeeAttendanceBean;
  final DateTime selectedDate;
  final Function loadData;

  @override
  State<EmployeeWiseAttendanceDetailWidget> createState() => _EmployeeWiseAttendanceDetailWidgetState();
}

class _EmployeeWiseAttendanceDetailWidgetState extends State<EmployeeWiseAttendanceDetailWidget> {
  bool isLoading = false;
  bool isExpanded = false;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 10),
                  const Text('Name: '),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.employeeAttendanceBean.employeeName ?? "-")),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: "Scan QR to mark attendance",
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return QrScannerWidget(
                          employeeAttendanceBean: widget.employeeAttendanceBean,
                        );
                      })).then(widget.loadData()),
                      child: ClayButton(
                        color: clayContainerColor(context),
                        height: 30,
                        width: 30,
                        borderRadius: 50,
                        surfaceColor: clayContainerColor(context),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(Icons.qr_code_scanner),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: isExpanded ? "Collapse" : "Expand",
                    child: GestureDetector(
                      onTap: () => setState(() => isExpanded = !isExpanded),
                      child: ClayButton(
                        color: clayContainerColor(context),
                        height: 30,
                        width: 30,
                        borderRadius: 50,
                        surfaceColor: clayContainerColor(context),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: isExpanded ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              if (isExpanded && (widget.employeeAttendanceBean.franchiseName?.trim() ?? "") != "") const SizedBox(height: 10),
              if (isExpanded && (widget.employeeAttendanceBean.franchiseName?.trim() ?? "") != "")
                rowWidget(
                  const Icon(Icons.school),
                  const Text('Franchise: '),
                  Expanded(child: Text(widget.employeeAttendanceBean.franchiseName ?? "-")),
                ),
              if (isExpanded) const SizedBox(height: 10),
              if (isExpanded)
                rowWidget(
                  const Icon(Icons.account_box),
                  const Text('Roles: '),
                  Expanded(child: Text(widget.employeeAttendanceBean.roles?.join(", ") ?? "-")),
                ),
              if (isExpanded) const SizedBox(height: 10),
              if (isExpanded)
                rowWidget(
                  const Icon(Icons.email),
                  const Text('Email: '),
                  Expanded(child: Text(widget.employeeAttendanceBean.emailId ?? "-")),
                ),
              if (isExpanded) const SizedBox(height: 10),
              if (isExpanded)
                rowWidget(
                  const Icon(Icons.phone),
                  const Text('Mobile: '),
                  Expanded(child: Text(widget.employeeAttendanceBean.mobile ?? "-")),
                ),
              if (isExpanded) const SizedBox(height: 10),
              if (isExpanded) datePickerRow(),
              if (isExpanded) const SizedBox(height: 10),
              attendanceForDateWidget(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget attendanceForDateWidget() {
    List<DateWiseEmployeeAttendanceDetailsBean> dateWiseEmployeeAttendanceBeanList =
        (widget.employeeAttendanceBean.dateWiseEmployeeAttendanceBeanList ?? [])
            .where((e) => e?.date == convertDateTimeToYYYYMMDDFormat(isExpanded ? selectedDate : DateTime.now()))
            .map((e) => e?.dateWiseEmployeeAttendanceDetailsBeans ?? [])
            .expand((i) => i)
            .where((e) => e != null)
            .map((e) => e!)
            .toList();
    if (dateWiseEmployeeAttendanceBeanList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: rowWidget(
          const Icon(Icons.timer_sharp),
          const Text('Marked at: '),
          const Text("-", style: TextStyle(color: Colors.red)),
        ),
      );
    }
    return Column(
      children: [
        ...dateWiseEmployeeAttendanceBeanList.where((e) => e.clockedTime != null).map(
          (e) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: rowWidget(
                const Icon(Icons.timer_sharp),
                const Text('Marked at: '),
                Text(convertEpochToDDMMYYYYEEEEHHMMAA(e.clockedTime!)),
              ),
            );
          },
        )
      ],
    );
  }

  Row rowWidget(Widget iconWidget, Widget headerWidget, Widget descriptionWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(width: 10),
        headerWidget,
        const SizedBox(width: 10),
        Expanded(child: descriptionWidget),
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
