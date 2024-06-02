import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class SubjectsReorderScreen extends StatefulWidget {
  const SubjectsReorderScreen({
    Key? key,
    required this.adminProfile,
    required this.subjects,
    required this.teachers,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<Subject> subjects;
  final List<Teacher> teachers;

  @override
  State<SubjectsReorderScreen> createState() => _SubjectsReorderScreenState();
}

class _SubjectsReorderScreenState extends State<SubjectsReorderScreen> {
  bool _isLoading = false;

  List<Subject> subjectsList = [];
  List<Teacher> teachersList = [];

  @override
  void initState() {
    super.initState();
    subjectsList = widget.subjects;
    teachersList = widget.teachers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reorder Subjects"),
        actions: [
          IconButton(
            onPressed: () async {
              List<Subject> reOrderedSubjectsList = subjectsList.where((es) => Subject.fromJson(es.origJson()).seqOrder != es.seqOrder).toList();
              if (reOrderedSubjectsList.isEmpty) return;
              setState(() => _isLoading = true);
              CreateOrUpdateSubjectsResponse createOrUpdateSubjectsResponse = await createOrUpdateSubjects(CreateOrUpdateSubjectsRequest(
                schoolId: widget.adminProfile.schoolId,
                agentId: widget.adminProfile.userId,
                subjectsList: reOrderedSubjectsList,
              ));
              if (createOrUpdateSubjectsResponse.httpStatus != "OK" || createOrUpdateSubjectsResponse.responseStatus != "success") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Something went wrong! Try again later.."),
                  ),
                );
                setState(() {
                  _isLoading = false;
                });
                return;
              }
              setState(() => _isLoading = false);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ReorderableListView(
        buildDefaultDragHandles: false,
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          Subject reorderedSubject = subjectsList.removeAt(oldIndex);
          setState(() {
            subjectsList.insert(newIndex, reorderedSubject);
            for (int index = 0; index < subjectsList.length; index++) {
              subjectsList[index].seqOrder = index + 1;
            }
          });
        },
        children: [
          for (int index = 0; index < subjectsList.length; index++)
            ReorderableDragStartListener(
              key: ValueKey(subjectsList[index].subjectId),
              index: index,
              child: Padding(
                padding: MediaQuery.of(context).orientation == Orientation.landscape
                    ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 8, MediaQuery.of(context).size.width / 4, 8)
                    : const EdgeInsets.all(8),
                child: ClayButton(
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  borderRadius: 10,
                  spread: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("${index + 1}."),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(subjectsList[index].subjectName ?? " "),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
