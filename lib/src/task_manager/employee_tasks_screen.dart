import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/task_manager/modal/task_manager.dart';
import 'package:schoolsgo_web/src/task_manager/views/task_card.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class EmployeeTasksScreen extends StatefulWidget {
  const EmployeeTasksScreen({
    super.key,
    required this.userId,
    required this.schoolId,
  });

  final int userId;
  final int schoolId;

  @override
  State<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends State<EmployeeTasksScreen> {
  bool _isLoading = true;
  List<TaskBean> tasks = [];
  List<SchoolWiseEmployeeBean> employees = [];

  final ItemScrollController tasksListLandscapeController = ItemScrollController();
  final ItemScrollController tasksListPortraitController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest(
      schoolId: widget.schoolId,
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
    GetTasksResponse getTasksResponse = await getTasks(GetTasksRequest(
      schoolId: widget.schoolId,
      assigneeId: widget.userId,
    ));
    if (getTasksResponse.httpStatus == "OK" && getTasksResponse.responseStatus == "success") {
      setState(() {
        tasks = (getTasksResponse.tasks ?? []).map((e) => e!).toList().reversed.toList();
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks Management"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : tasks.isEmpty
              ? const Center(
                  child: Text("No tasks available"),
                )
              : ScrollablePositionedList.builder(
                  itemScrollController: tasksListPortraitController,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => TaskCard(
                    task: tasks[index],
                    employees: employees,
                    adminProfile: AdminProfile(userId: widget.userId, schoolId: widget.schoolId, isMegaAdmin: false),
                    superSetState: setState,
                    isNotAdmin: true,
                  ),
                ),
    );
  }

  Card miniTaskCardWidget(TaskBean e) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    e.title ?? "-",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text(e.description ?? "-")),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    e.assigneeName ?? "-",
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
