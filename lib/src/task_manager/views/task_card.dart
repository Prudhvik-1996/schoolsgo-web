import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/task_manager/modal/task_manager.dart';
import 'package:schoolsgo_web/src/task_manager/views/task_comment_card.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class TaskCard extends StatefulWidget {
  final TaskBean task;
  final List<SchoolWiseEmployeeBean> employees;
  final AdminProfile adminProfile;
  final Function superSetState;

  const TaskCard({
    Key? key,
    required this.task,
    required this.employees,
    required this.adminProfile,
    required this.superSetState,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool isLoading = false;
  bool showComments = false;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime startDate;
  late DateTime dueDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    startDate = convertYYYYMMDDFormatToDateTime(widget.task.startDate!);
    dueDate = convertYYYYMMDDFormatToDateTime(widget.task.dueDate!);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void toggleEditMode() {
    if (widget.task.isEditMode) {
      saveChanges();
    }
    setState(() {
      widget.task.isEditMode = !widget.task.isEditMode;
    });
    setSuperState();
  }

  bool get isNewCommentInAction => (widget.task.taskCommentBeanList ?? []).where((e) => e?.commentId == null).isNotEmpty;

  Future<void> saveChanges() async {
    setState(() => isLoading = true);
    widget.task.title = titleController.text.trim();
    widget.task.description = descriptionController.text.trim();
    widget.task.startDate = convertDateTimeToYYYYMMDDFormat(startDate);
    widget.task.dueDate = convertDateTimeToYYYYMMDDFormat(dueDate);
    CreateOrUpdateTaskResponse createOrUpdateTaskResponse = await createOrUpdateTask(CreateOrUpdateTaskRequest(
      agent: widget.adminProfile.userId,
      assignedBy: widget.task.assignerId,
      assignedTo: widget.task.assigneeId,
      description: widget.task.description,
      dueDate: widget.task.dueDate,
      schoolId: widget.adminProfile.schoolId,
      startDate: widget.task.startDate,
      status: 'active',
      taskId: widget.task.taskId,
      taskStatus: widget.task.taskStatus,
      title: widget.task.title,
    ));
    if (createOrUpdateTaskResponse.httpStatus != "OK" || createOrUpdateTaskResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
    } else {
      setState(() => widget.task.taskId = createOrUpdateTaskResponse.taskId);
      setSuperState();
    }
    setState(() => isLoading = false);
  }

  void toggleShowComments() {
    setState(() {
      showComments = !showComments;
    });
    setSuperState();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: ClayContainer(
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 10,
            depth: 40,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: MediaQuery.of(context).orientation == Orientation.landscape ? landscapeView() : portraitView(),
            ),
          ),
        ),
        if (isLoading)
          const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }

  Column portraitView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  assignerNameWidget(),
                  const SizedBox(height: 10),
                  if (widget.task.isEditMode && !isNewCommentInAction) assigneeDropdown() else assigneeNameWidget(),
                  const SizedBox(height: 10),
                  startDateWidget(),
                  const SizedBox(height: 10),
                  dueDateWidget(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Task Status"),
                      const SizedBox(width: 10),
                      Expanded(
                          child: widget.task.isEditMode && !isNewCommentInAction ? buildTaskStatusDropdown() : Text(widget.task.taskStatus ?? "-")),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            editButton(),
          ],
        ),
        titleWidget(),
        const SizedBox(height: 10),
        descriptionWidget(),
        const SizedBox(height: 10),
        if (showComments) commentsWidget(),
        const SizedBox(height: 10),
        toggleCommentsWidget()
      ],
    );
  }

  Column landscapeView() {
    return Column(
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
                    assignerNameWidget(),
                    const SizedBox(height: 10),
                    if (widget.task.isEditMode && !isNewCommentInAction) assigneeDropdown() else assigneeNameWidget(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widget.task.isEditMode && !isNewCommentInAction ? buildTaskStatusDropdown() : Text(widget.task.taskStatus ?? "-"),
                      const SizedBox(height: 10),
                      editButton(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        titleWidget(),
        descriptionWidget(),
        if (showComments) commentsWidget(),
        toggleCommentsWidget()
      ],
    );
  }

  Padding descriptionWidget() {
    return Padding(
      padding: (MediaQuery.of(context).orientation == Orientation.landscape)
          ? const EdgeInsets.fromLTRB(16, 0, 16, 0)
          : const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: widget.task.isEditMode && !isNewCommentInAction
          ? TextFormField(
              controller: descriptionController,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            )
          : Text(
              widget.task.description!,
              style: const TextStyle(fontSize: 16.0),
            ),
    );
  }

  Padding titleWidget() {
    return Padding(
      padding: (MediaQuery.of(context).orientation == Orientation.landscape)
          ? const EdgeInsets.fromLTRB(16, 0, 16, 0)
          : const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: widget.task.isEditMode && !isNewCommentInAction
          ? TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            )
          : Text(
              widget.task.title!,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
    );
  }

  Text assigneeNameWidget() {
    return Text(
      'Assignee:$bringOutEscapeSequence${widget.task.assigneeName}',
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue),
    );
  }

  Text assignerNameWidget() {
    return Text(
      'Assigner:$bringOutEscapeSequence${widget.task.assignerName}',
      style: const TextStyle(fontSize: 16.0),
    );
  }

  Widget assigneeDropdown() {
    var employees = [null, ...widget.employees];
    return DropdownButton<SchoolWiseEmployeeBean?>(
      hint: const Text("Assignee"),
      value: employees.where((e) => e?.employeeId == widget.task.assigneeId).firstOrNull,
      onChanged: (SchoolWiseEmployeeBean? newValue) {
        setState(() {
          widget.task.assigneeName = newValue?.employeeName;
          widget.task.assigneeId = newValue?.employeeId;
          widget.task.assigneeRoles = (newValue?.roles ?? []).join(", ");
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

  Widget toggleCommentsWidget() {
    return TextButton(
      onPressed: toggleShowComments,
      child: showComments
          ? Row(children: const [Icon(Icons.arrow_drop_up), Text("Hide Comments")])
          : Row(children: const [Icon(Icons.arrow_drop_down), Text("Show Comments")]),
    );
  }

  Widget editButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: toggleEditMode,
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 100,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: widget.task.isEditMode && !isNewCommentInAction ? const Icon(Icons.save) : const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }

  Padding commentsWidget() {
    return Padding(
      padding: (MediaQuery.of(context).orientation == Orientation.landscape)
          ? const EdgeInsets.fromLTRB(16, 0, 16, 0)
          : const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Comments",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          ...(widget.task.taskCommentBeanList ?? []).reversed.map((e) => TaskCommentWidget(
                commentBean: e,
                adminProfile: widget.adminProfile,
                superSetState: setSuperState,
                deleteComment: deleteNewCommentAction,
              )),
          const SizedBox(height: 10),
          if (widget.task.isEditMode && !isNewCommentInAction) addNewCommentButton(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void deleteNewCommentAction() {
    setState(() {
      (widget.task.taskCommentBeanList ?? []).removeWhere((e) => e?.commentId == null);
    });
    setSuperState();
  }

  void addNewCommentAction() {
    setState(() {
      widget.task.taskCommentBeanList ??= [];
      widget.task.taskCommentBeanList!.add(TaskCommentBean(
        agent: widget.adminProfile.userId?.toString(),
        comment: "",
        commentId: null,
        commentedDate: convertDateTimeToYYYYMMDDFormat(DateTime.now()),
        commenterId: widget.adminProfile.userId,
        commenterName: widget.adminProfile.firstName,
        commenterRoles: (widget.employees.where((e) => e.employeeId == widget.adminProfile.userId).firstOrNull?.roles ?? []).join(", "),
        taskId: widget.task.taskId,
        createdTime: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    setSuperState();
  }

  void setSuperState() => widget.superSetState(() {});

  Widget addNewCommentButton() => GestureDetector(
        onTap: addNewCommentAction,
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: const Text(
              'Add comment',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  String get bringOutEscapeSequence => " ";

  Widget dueDateWidget() {
    if (widget.task.isEditMode && !isNewCommentInAction) {
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Due Date:$bringOutEscapeSequence${convertDateToDDMMMYYY(convertDateTimeToYYYYMMDDFormat(dueDate).replaceAll("\n", " "))}',
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
      );
    }
    return Text(
      'Due Date:$bringOutEscapeSequence${convertDateToDDMMMYYY(convertDateTimeToYYYYMMDDFormat(dueDate).replaceAll("\n", " "))}',
      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.red),
      textAlign: TextAlign.start,
    );
  }

  Widget startDateWidget() {
    if (widget.task.isEditMode && !isNewCommentInAction) {
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Start Date:$bringOutEscapeSequence${convertDateToDDMMMYYY(convertDateTimeToYYYYMMDDFormat(startDate).replaceAll("\n", " "))}',
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
      );
    }
    return Text(
      'Start Date:$bringOutEscapeSequence${convertDateToDDMMMYYY(convertDateTimeToYYYYMMDDFormat(startDate).replaceAll("\n", " "))}',
      style: const TextStyle(fontSize: 16.0),
      textAlign: TextAlign.start,
    );
  }

  Widget buildTaskStatusDropdown() {
    final List<String?> taskStatuses = [null, 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED'];
    return DropdownButton<String?>(
      hint: const Text("Status"),
      value: widget.task.taskStatus,
      onChanged: (String? newTaskStatus) {
        setState(() => widget.task.taskStatus = newTaskStatus);
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
}
