import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/task_manager/modal/task_manager.dart';
import 'package:schoolsgo_web/src/task_manager/views/new_task_card.dart';
import 'package:schoolsgo_web/src/task_manager/views/task_card.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/task_management";

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  bool _isLoading = true;
  List<TaskBean> tasks = [];
  List<SchoolWiseEmployeeBean> employees = [];

  bool isAddNew = false;
  late TaskBean newTaskBean;

  final ItemScrollController tasksListLandscapeController = ItemScrollController();
  final ItemScrollController tasksListPortraitController = ItemScrollController();
  bool showStats = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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
    GetTasksResponse getTasksResponse = await getTasks(GetTasksRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getTasksResponse.httpStatus == "OK" && getTasksResponse.responseStatus == "success") {
      setState(() {
        tasks = (getTasksResponse.tasks ?? []).map((e) => e!).toList().reversed.toList();
      });
    }
    resetNewTaskBean();
    setState(() => _isLoading = false);
  }

  void resetNewTaskBean() => setState(() => newTaskBean = TaskBean(
        assigneeId: null,
        assigneeName: null,
        assigneeRoles: null,
        assignerId: employees.where((e) => e.employeeId == widget.adminProfile.userId).firstOrNull?.employeeId,
        assignerName: employees.where((e) => e.employeeId == widget.adminProfile.userId).firstOrNull?.employeeName,
        assignerRoles: (employees.where((e) => e.employeeId == widget.adminProfile.userId).firstOrNull?.roles ?? []).join(", "),
        description: null,
        dueDate: convertDateTimeToYYYYMMDDFormat(DateTime.now().add(const Duration(days: 1))),
        schoolId: widget.adminProfile.schoolId,
        startDate: convertDateTimeToYYYYMMDDFormat(DateTime.now()),
        taskCommentBeanList: [],
        taskId: null,
        taskStatus: null,
        title: null,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks Management"),
        actions: [
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            IconButton(
              onPressed: () => setState(() => showStats = !showStats),
              icon: showStats ? const Icon(Icons.splitscreen) : const Icon(Icons.info),
            )
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : isAddNew
              ? Container(
                  margin: MediaQuery.of(context).orientation == Orientation.portrait
                      ? const EdgeInsets.all(10)
                      : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
                  child: NewTaskCard(
                    adminProfile: widget.adminProfile,
                    newTaskBean: newTaskBean,
                    employees: employees,
                    superSetState: setState,
                  ),
                )
              : tasks.isEmpty
                  ? const Center(
                      child: Text("No tasks available"),
                    )
                  : MediaQuery.of(context).orientation == Orientation.landscape
                      ? Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: statsWidget(),
                            ),
                            Expanded(
                              flex: 5,
                              child: ScrollablePositionedList.builder(
                                itemScrollController: tasksListLandscapeController,
                                itemCount: tasks.length,
                                itemBuilder: (context, index) => TaskCard(
                                  task: tasks[index],
                                  employees: employees,
                                  adminProfile: widget.adminProfile,
                                  superSetState: setState,
                                ),
                              ),
                            ),
                          ],
                        )
                      : showStats
                          ? statsWidget()
                          : ScrollablePositionedList.builder(
                              itemScrollController: tasksListPortraitController,
                              itemCount: tasks.length,
                              itemBuilder: (context, index) => TaskCard(
                                task: tasks[index],
                                employees: employees,
                                adminProfile: widget.adminProfile,
                                superSetState: setState,
                              ),
                            ),
      floatingActionButton: _isLoading || tasks.map((e) => e.isEditMode).contains(true)
          ? null
          : isAddNew
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    addNewButton(),
                    const SizedBox(
                      height: 10,
                    ),
                    saveNewTaskButton(),
                  ],
                )
              : addNewButton(),
    );
  }

  Column statsWidget() {
    return Column(
      children: [
        taskStats(),
        Expanded(child: tasksDueForToday()),
      ],
    );
  }

  Widget saveNewTaskButton() {
    return GestureDetector(
      onTap: () async {
        if ((newTaskBean.title?.trim() ?? "").isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Title of the task cannot be empty"),
            ),
          );
          return;
        }
        if ((newTaskBean.description?.trim() ?? "").isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Description of the task cannot be empty"),
            ),
          );
          return;
        }
        if (newTaskBean.assigneeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Assignee of the task cannot be empty"),
            ),
          );
          return;
        }
        setState(() => _isLoading = true);
        CreateOrUpdateTaskResponse createOrUpdateTaskResponse = await createOrUpdateTask(CreateOrUpdateTaskRequest(
          agent: widget.adminProfile.userId,
          assignedBy: newTaskBean.assignerId,
          assignedTo: newTaskBean.assigneeId,
          description: newTaskBean.description,
          dueDate: newTaskBean.dueDate,
          schoolId: widget.adminProfile.schoolId,
          startDate: newTaskBean.startDate,
          status: 'active',
          taskId: newTaskBean.taskId,
          taskStatus: newTaskBean.taskStatus,
          title: newTaskBean.title,
        ));
        if (createOrUpdateTaskResponse.httpStatus != "OK" || createOrUpdateTaskResponse.responseStatus != "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Please try again later.."),
            ),
          );
        } else {
          setState(() {
            newTaskBean.taskId = createOrUpdateTaskResponse.taskId;
            tasks = [newTaskBean, ...tasks];
            isAddNew = false;
          });
          resetNewTaskBean();
        }
        setState(() => _isLoading = false);
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.check),
        ),
      ),
    );
  }

  Widget addNewButton() {
    return GestureDetector(
      onTap: () => setState(() => isAddNew = !isAddNew),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: isAddNew ? const Icon(Icons.clear) : const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget taskStats() {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              taskStatRow("Tasks Assigned:", tasks.where((e) => e.taskStatus == "ASSIGNED").length),
              const SizedBox(height: 10),
              taskStatRow("Tasks In Progress:", tasks.where((e) => e.taskStatus == "IN_PROGRESS").length),
              const SizedBox(height: 10),
              taskStatRow("Tasks Completed:", tasks.where((e) => e.taskStatus == "COMPLETED").length),
              const SizedBox(height: 10),
              taskStatRow("Total Tasks:", tasks.length),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget tasksDueForToday() {
    return Container(
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
            children: [
              const Text(
                "Tasks due today",
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 10),
              const Divider(height: 2),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    if (tasks.where((e) => e.dueDate == convertDateTimeToYYYYMMDDFormat(DateTime.now())).isEmpty)
                      const Center(
                        child: Text("Currently, there are no tasks with a due date set for today."),
                      ),
                    ...tasks.where((e) => e.dueDate == convertDateTimeToYYYYMMDDFormat(DateTime.now())).map(
                          (e) => Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: GestureDetector(
                              onTap: () {
                                if (MediaQuery.of(context).orientation == Orientation.portrait) {
                                  setState(() => showStats = false);
                                  setState(() => tasksListPortraitController.scrollTo(
                                        index: tasks.indexWhere((e1) => e1.taskId == e.taskId) == -1
                                            ? 0
                                            : tasks.indexWhere((e1) => e1.taskId == e.taskId),
                                        duration: const Duration(milliseconds: 100),
                                        curve: Curves.bounceInOut,
                                      ));
                                } else {
                                  setState(() => tasksListLandscapeController.scrollTo(
                                        index: tasks.indexWhere((e1) => e1.taskId == e.taskId) == -1
                                            ? 0
                                            : tasks.indexWhere((e1) => e1.taskId == e.taskId),
                                        duration: const Duration(milliseconds: 100),
                                        curve: Curves.bounceInOut,
                                      ));
                                }
                              },
                              child: miniTaskCardWidget(e),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
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

  Row taskStatRow(String heading, int value) {
    return Row(
      children: [Expanded(child: Text(heading)), const SizedBox(width: 10), Text(value.toString())],
    );
  }
}
