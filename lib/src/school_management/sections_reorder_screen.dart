import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class SectionsReorderScreen extends StatefulWidget {
  const SectionsReorderScreen({
    Key? key,
    required this.adminProfile,
    required this.sections,
    required this.teachers,
    required this.students,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<Section> sections;
  final List<Teacher> teachers;
  final List<StudentProfile> students;

  @override
  State<SectionsReorderScreen> createState() => _SectionsReorderScreenState();
}

class _SectionsReorderScreenState extends State<SectionsReorderScreen> {
  bool _isLoading = false;

  List<Section> sectionsList = [];
  List<Teacher> teachersList = [];
  List<StudentProfile> studentsList = [];

  @override
  void initState() {
    super.initState();
    sectionsList = widget.sections;
    teachersList = widget.teachers;
    studentsList = widget.students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reorder Sections"),
        actions: [
          IconButton(
            onPressed: () async {
              List<Section> reOrderedSectionsList = sectionsList.where((es) => Section.fromJson(es.origJson()).seqOrder != es.seqOrder).toList();
              if (reOrderedSectionsList.isEmpty) return;
              setState(() => _isLoading = true);
              CreateOrUpdateSectionsResponse createOrUpdateSectionsResponse = await createOrUpdateSections(CreateOrUpdateSectionsRequest(
                schoolId: widget.adminProfile.schoolId,
                agentId: widget.adminProfile.userId,
                sectionsList: reOrderedSectionsList,
              ));
              if (createOrUpdateSectionsResponse.httpStatus != "OK" || createOrUpdateSectionsResponse.responseStatus != "success") {
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
                Section reorderedSection = sectionsList.removeAt(oldIndex);
                setState(() {
                  sectionsList.insert(newIndex, reorderedSection);
                  for (int index = 0; index < sectionsList.length; index++) {
                    sectionsList[index].seqOrder = index + 1;
                  }
                });
              },
              children: [
                for (int index = 0; index < sectionsList.length; index++)
                  ReorderableDragStartListener(
                    key: ValueKey(sectionsList[index].sectionId),
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
                                child: Text(sectionsList[index].sectionName ?? " "),
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
