import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/task_manager/modal/task_manager.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class TaskCommentWidget extends StatefulWidget {
  final TaskCommentBean? commentBean;
  final AdminProfile adminProfile;
  final Function superSetState;
  final Function deleteComment;

  const TaskCommentWidget({
    Key? key,
    this.commentBean,
    required this.adminProfile,
    required this.superSetState,
    required this.deleteComment,
  }) : super(key: key);

  @override
  _TaskCommentWidgetState createState() => _TaskCommentWidgetState();
}

class _TaskCommentWidgetState extends State<TaskCommentWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.commentBean == null) return Container();
    return Container(
      margin: const EdgeInsets.all(8),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: (widget.commentBean!.agent == null || widget.commentBean!.agent == "SYSTEM")
            ? systemCommentWidget(widget.commentBean!)
            : widget.commentBean?.commentId == null
                ? newCommentWidget(widget.commentBean!)
                : commenterCommentWidget(widget.commentBean!),
      ),
    );
  }

  Widget newCommentWidget(TaskCommentBean commentBean) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  autofocus: true,
                  initialValue: widget.commentBean?.comment,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  onChanged: (String newComment) {
                    setState(() {
                      widget.commentBean?.comment = newComment;
                    });
                    widget.superSetState();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: ClayButton(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : (widget.commentBean!.comment ?? "") == ""
                            ? const FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Icon(Icons.clear, color: Colors.red),
                              )
                            : const FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Icon(Icons.save),
                              ),
                  ),
                ),
                onPressed: () async {
                  if (isLoading) return;
                  await saveComment();
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (commentBean.createdTime != null) commentCreatedTimeWidget(commentBean),
        ],
      ),
    );
  }

  Future<void> saveComment() async {
    if ((widget.commentBean?.comment ?? "") == "") {
      widget.deleteComment();
    }
    setState(() => isLoading = true);
    CreateOrUpdateTaskCommentResponse createOrUpdateTaskCommentResponse = await createOrUpdateTaskComment(CreateOrUpdateTaskCommentRequest(
      agent: widget.adminProfile.userId,
      comment: widget.commentBean?.comment,
      commentId: widget.commentBean?.commentId,
      commentedBy: widget.adminProfile.userId,
      status: 'active',
      taskId: widget.commentBean?.taskId,
    ));
    if (createOrUpdateTaskCommentResponse.httpStatus != "OK" || createOrUpdateTaskCommentResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
    } else {
      setState(() => widget.commentBean?.commentId = createOrUpdateTaskCommentResponse.commentId);
    }
    setState(() => isLoading = false);
    widget.superSetState();
  }

  Padding commenterCommentWidget(TaskCommentBean commentBean) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  commentBean.commenterName ?? "-",
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(commentBean.comment?.capitalize() ?? "-"),
          ),
          if (commentBean.createdTime != null) commentCreatedTimeWidget(commentBean),
        ],
      ),
    );
  }

  Padding systemCommentWidget(TaskCommentBean commentBean) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const CustomVerticalDivider(),
              const SizedBox(width: 10),
              Expanded(child: Text(commentBean.comment ?? "-")),
            ],
          ),
          if (commentBean.createdTime != null) commentCreatedTimeWidget(commentBean),
        ],
      ),
    );
  }

  Row commentCreatedTimeWidget(TaskCommentBean commentBean) {
    return Row(
      children: [
        Expanded(
          child: Text(
            convertEpochToDDMMYYYYEEEEHHMMAA(commentBean.createdTime!),
            style: const TextStyle(fontSize: 9),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
