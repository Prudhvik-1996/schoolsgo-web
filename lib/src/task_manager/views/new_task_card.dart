import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/task_manager/modal/task_manager.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class NewTaskCard extends StatefulWidget {
  final AdminProfile adminProfile;
  final TaskBean newTaskBean;
  final List<SchoolWiseEmployeeBean> employees;
  final Function superSetState;

  const NewTaskCard({
    Key? key,
    required this.adminProfile,
    required this.newTaskBean,
    required this.employees,
    required this.superSetState,
  }) : super(key: key);

  @override
  State<NewTaskCard> createState() => _NewTaskCardState();
}

class _NewTaskCardState extends State<NewTaskCard> {
  late DateTime startDate;
  late DateTime dueDate;

  @override
  void initState() {
    super.initState();
    startDate = convertYYYYMMDDFormatToDateTime(widget.newTaskBean.startDate!);
    dueDate = convertYYYYMMDDFormatToDateTime(widget.newTaskBean.dueDate!);
  }

  Widget startDateWidget() {
    return GestureDetector(
      onTap: () {
        selectStartDate();
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            'Start Date:$bringOutEscapeSequence${convertDateToDDMMMYYY(convertDateTimeToYYYYMMDDFormat(startDate).replaceAll("\n", " "))}',
            style: const TextStyle(fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context, initialDate: startDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), // TODO
      lastDate: dueDate.subtract(const Duration(days: 1)), // TODO
    );
    if (selectedDate != null) {
      setState(() {
        startDate = selectedDate;
      });
      setSuperState();
    }
  }

  Widget dueDateWidget() {
    return GestureDetector(
      onTap: () {
        selectDueDate();
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            'Due Date:$bringOutEscapeSequence${convertDateToDDMMMYYY(convertDateTimeToYYYYMMDDFormat(dueDate).replaceAll("\n", " "))}',
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context, initialDate: dueDate, firstDate: startDate, lastDate: DateTime.now().add(const Duration(days: 365)), // TODO
    );
    if (selectedDate != null) {
      setState(() {
        dueDate = selectedDate;
      });
      setSuperState();
    }
  }

  Widget buildTaskStatusDropdown() {
    final List<String?> taskStatuses = [null, 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED'];
    return DropdownButton<String?>(
      hint: const Text("Status"),
      value: widget.newTaskBean.taskStatus,
      onChanged: (String? newTaskStatus) {
        setState(() => widget.newTaskBean.taskStatus = newTaskStatus);
        setSuperState();
      },
      items: taskStatuses.map((String? status) {
        return DropdownMenuItem<String?>(
          value: status,
          child: Text(status ?? "-"),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: MediaQuery.of(context).orientation == Orientation.portrait
      //     ? const EdgeInsets.all(10)
      //     : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigner:$bringOutEscapeSequence${widget.newTaskBean.assignerName}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 10),
                          buildAssigneeDropdown(),
                          const SizedBox(height: 10),
                          startDateWidget(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        dueDateWidget(),
                        const SizedBox(height: 10),
                        buildTaskStatusDropdown(),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  onChanged: (String newTitle) {
                    setState(() => widget.newTaskBean.title = newTitle);
                    setSuperState();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  onChanged: (String newDescription) {
                    setState(() => widget.newTaskBean.description = newDescription);
                    setSuperState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAssigneeDropdown() {
    var employees = [null, ...widget.employees];
    return DropdownButton<SchoolWiseEmployeeBean?>(
      hint: const Text("Assignee"),
      value: employees.where((e) => e?.employeeId == widget.newTaskBean.assigneeId).firstOrNull,
      onChanged: (SchoolWiseEmployeeBean? newValue) {
        setState(() {
          widget.newTaskBean.assigneeName = newValue?.employeeName;
          widget.newTaskBean.assigneeId = newValue?.employeeId;
          widget.newTaskBean.assigneeRoles = (newValue?.roles ?? []).join(", ");
        });
      },
      items: employees
          .map((e) => DropdownMenuItem<SchoolWiseEmployeeBean?>(
                child: Text(e?.employeeName ?? "-"),
                value: e,
              ))
          .toList(),
    );
  }

  String get bringOutEscapeSequence => MediaQuery.of(context).orientation == Orientation.portrait ? "\n" : " ";

  void setSuperState() => widget.superSetState(() {});
}
