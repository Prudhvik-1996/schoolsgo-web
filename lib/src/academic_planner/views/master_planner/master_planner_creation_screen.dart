import 'dart:convert';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class MasterPlannerCreationScreen extends StatefulWidget {
  const MasterPlannerCreationScreen({
    Key? key,
    required this.adminProfile,
    required this.sections,
    required this.tdsList,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<Section> sections;
  final List<TeacherDealingSection> tdsList;

  @override
  State<MasterPlannerCreationScreen> createState() => _MasterPlannerCreationScreenState();
}

class _MasterPlannerCreationScreenState extends State<MasterPlannerCreationScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<int?> selectedSectionIds = [];
  int? selectedSubjectId;

  int currentStep = 0;
  bool showStepper = true;

  Map<int, List<PlannedBeanForTds>> tdsWisePlannerBeans = {};
  List<PlannedBeanForTds> newPlannerBeans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetPlannerResponse getPlannerResponse = await getPlanner(GetPlannerRequest(
      schoolId: widget.adminProfile.schoolId,
      // academicYearId: TODO
    ));
    if (getPlannerResponse.httpStatus == "OK" && getPlannerResponse.responseStatus == "success") {
      setState(() {
        getPlannerResponse.plannerBeans!.map((e) => e!).map((e) {
          int? tdsId = e.tdsId;
          String rawJsonListString = e.plannerBeanJsonString ?? "[]";
          rawJsonListString = rawJsonListString.replaceAll('"[', '[').replaceAll(']"', ']').replaceAll('\\', '');
          List<dynamic> rawJsonList = jsonDecode(rawJsonListString);
          List<PlannedBeanForTds> x = [];
          for (var json in rawJsonList) {
            x.add(PlannedBeanForTds.fromJson(json));
          }
          return MapEntry(tdsId, x);
        }).forEach((entry) {
          int? tdsId = entry.key;
          List<PlannedBeanForTds> list = entry.value;
          if (tdsId != null) {
            tdsWisePlannerBeans[tdsId] = list.whereNotNull().toList();
          }
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    setState(() => _isLoading = false);
  }

  List<TeacherDealingSection> get filteredTdsList =>
      widget.tdsList.where((e) => selectedSectionIds.contains(e.sectionId) && e.subjectId == selectedSubjectId).toList();

  List<Subject> get filteredSubjects {
    List<int> uniqueSubjectIds = widget.tdsList.map((tds) => tds.subjectId!).toSet().toList();
    return uniqueSubjectIds
        .map((e) => Subject(subjectId: e, subjectName: widget.tdsList.firstWhere((tds) => e == tds.subjectId).subjectName))
        .toList();
  }

  List<Section> get sections => widget.sections
      .where((eachSection) => widget.tdsList.where((e) => e.subjectId == selectedSubjectId).map((e) => e.sectionId).contains(eachSection.sectionId))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Master Planner"),
        actions: [
          if (!showStepper)
            IconButton(
              icon: const Icon(Icons.filter_alt_sharp),
              onPressed: () {
                setState(() {
                  showStepper = true;
                  currentStep = 0;
                });
              },
            )
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : showStepper
              ? ListView(
                  children: [
                    const SizedBox(height: 20),
                    stepper(),
                    const SizedBox(height: 20),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    selectedFilter(),
                    Expanded(
                      child: ListView(
                        children: [
                          ...newPlannerBeans.map((e) => newPlannerBeanWidget(e)).toList(),
                          const SizedBox(height: 200),
                        ],
                      ),
                    )
                  ],
                ),
      floatingActionButton: _isLoading || showStepper
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showAddNewButton(newPlannerBeans.lastOrNull))
                  fab(
                    const Icon(Icons.add),
                    "Add",
                    () => setState(
                      () => newPlannerBeans.add(
                        PlannedBeanForTds(
                          title: "",
                          description: "",
                          noOfSlots: 0,
                          approvalStatus: "Approved",
                        ),
                      ),
                    ),
                    color: Colors.blue,
                  ),
                if (showAddNewButton(newPlannerBeans.lastOrNull)) const SizedBox(height: 10),
                if (showSubmitButton())
                  fab(
                    const Icon(Icons.check),
                    "Submit",
                    saveChanges,
                    color: Colors.green,
                  ),
              ],
            ),
    );
  }

  Widget selectedFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Sections: ${widget.sections.where((e) => selectedSectionIds.contains(e.sectionId)).map((e) => e.sectionName).join(", ")}",
            ),
          ),
          const SizedBox(width: 20),
          Text(filteredSubjects.where((e) => e.subjectId == selectedSubjectId).firstOrNull?.subjectName ?? "-"),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  bool showSubmitButton() {
    if (newPlannerBeans.isEmpty) return false;
    for (PlannedBeanForTds eachPlannerBean in newPlannerBeans) {
      if (!showAddNewButton(eachPlannerBean)) {
        return false;
      }
    }
    return true;
  }

  Future<void> saveChanges() async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Academic Planner'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                for (PlannedBeanForTds eachPlannerBean in newPlannerBeans) {
                  if (!showAddNewButton(eachPlannerBean)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("All fields in planner are mandatory"),
                      ),
                    );
                    return;
                  }
                }
                for (TeacherDealingSection tds in filteredTdsList) {
                  CreateOrUpdatePlannerResponse createOrUpdatePlannerResponse = await createOrUpdatePlanner(CreateOrUpdatePlannerRequest(
                    tdsId: tds.tdsId,
                    teacherId: tds.teacherId,
                    subjectId: tds.subjectId,
                    sectionId: tds.sectionId,
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId,
                    plannerBeanJsonString: jsonEncode(
                        "[" + ((tdsWisePlannerBeans[tds.tdsId!] ?? []) + newPlannerBeans).map((e) => jsonEncode(e.toJson())).join(",") + "]"),
                  ));
                  if (createOrUpdatePlannerResponse.httpStatus != "OK" || createOrUpdatePlannerResponse.responseStatus != "success") {
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
                }
                setState(() => _isLoading = false);
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool showAddNewButton(PlannedBeanForTds? plannerBean) =>
      plannerBean == null ||
      (((plannerBean.title?.trim() ?? "") != "") && ((plannerBean.description?.trim() ?? "") != "") && ((plannerBean.noOfSlots ?? 0) != 0));

  Widget newPlannerBeanWidget(PlannedBeanForTds plannerBean) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: fieldForNewPlanner(
                    plannerBean,
                    (value) {
                      setState(() {
                        plannerBean.title = value;
                      });
                    },
                    initialValue: plannerBean.title,
                    labelText: 'Title',
                    hintText: 'Enter title',
                  ),
                ),
                const SizedBox(width: 10),
                fab(
                  const Icon(Icons.delete, color: Colors.red),
                  "Delete",
                  () => setState(() => newPlannerBeans.remove(plannerBean)),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            fieldForNewPlanner(
              plannerBean,
              (value) {
                setState(() {
                  plannerBean.description = value;
                });
              },
              maxLines: null,
              initialValue: plannerBean.description,
              labelText: 'Description',
              hintText: 'Enter description',
            ),
            const SizedBox(height: 10),
            fieldForNewPlanner(
              plannerBean,
              (value) {
                final newSlots = int.tryParse(value);
                if (newSlots != null) {
                  setState(() {
                    plannerBean.noOfSlots = newSlots;
                  });
                } else {
                  setState(() {
                    plannerBean.noOfSlots = 0;
                  });
                }
              },
              initialValue: plannerBean.noOfSlots?.toString(),
              labelText: 'No. of Slots',
              hintText: 'Enter number of slots',
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget fieldForNewPlanner(
    PlannedBeanForTds plannerBean,
    Function onChanged, {
    int? maxLines = 1,
    String? initialValue,
    String? labelText,
    String? hintText,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        maxLines: maxLines,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
        onChanged: (String? newValue) => onChanged(newValue),
      ),
    );
  }

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectSectionExpanded() => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
        padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.25,
          crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
          shrinkWrap: true,
          children: sections.map((e) => buildSectionCheckBox(e)).toList(),
        ),
      );

  Widget buildSectionCheckBox(Section section) => Container(
        margin: const EdgeInsets.all(5),
        child: GestureDetector(
          onTap: () {
            if (_isLoading) return;
            if (selectedSectionIds.contains(section.sectionId)) {
              setState(() {
                selectedSectionIds.remove(section.sectionId);
              });
            } else {
              setState(() {
                selectedSectionIds.add(section.sectionId);
              });
            }
          },
          child: ClayButton(
            depth: 40,
            color: selectedSectionIds.contains(section.sectionId) ? Colors.blue[200] : clayContainerColor(context),
            spread: selectedSectionIds.contains(section.sectionId) ? 0 : 2,
            borderRadius: 10,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                section.sectionName!,
              ),
            ),
          ),
        ),
      );

  Widget _subjectsDropdown() => DropdownButton<Subject?>(
        isExpanded: true,
        items: filteredSubjects
            .map((Subject eachSubject) => DropdownMenuItem<Subject>(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(eachSubject.subjectName ?? "-"),
                  ),
                  value: eachSubject,
                ))
            .toList(),
        value: filteredSubjects.where((e) => e.subjectId == selectedSubjectId).firstOrNull,
        onChanged: (Subject? newSubject) => setState(() => selectedSubjectId = newSubject?.subjectId),
      );

  Widget stepper() => Stepper(
        currentStep: currentStep,
        onStepContinue: continued,
        onStepCancel: cancel,
        steps: <Step>[
          Step(
            title: const Text("Select subject"),
            content: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                    child: ClayContainer(
                      depth: 40,
                      parentColor: clayContainerColor(context),
                      surfaceColor: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _subjectsDropdown(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            isActive: currentStep >= 0,
            state: currentStep >= 0 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: const Text("Select section"),
            subtitle: Text(
              "Sections: ${widget.sections.where((e) => selectedSectionIds.contains(e.sectionId)).map((e) => e.sectionName).join(", ")}",
            ),
            content: Container(
              margin: const EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              ),
            ),
            isActive: currentStep >= 0,
            state: currentStep >= 1 ? StepState.complete : StepState.disabled,
          ),
        ],
      );

  continued() {
    currentStep < 1 ? setState(() => currentStep += 1) : setState(() => showStepper = false);
  }

  cancel() {
    currentStep > 0 ? setState(() => currentStep -= 1) : null;
  }
}
