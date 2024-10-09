import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/generate_memos/generate_memos.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class GenerateMemosScreen extends StatefulWidget {
  const GenerateMemosScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<GenerateMemosScreen> createState() => _GenerateMemosScreenState();
}

class _GenerateMemosScreenState extends State<GenerateMemosScreen> {
  bool _isLoading = true;
  bool _isReportDownlading = false;

  List<Section> sectionsList = [];
  Section? selectedSection;
  bool isSectionPickerOpen = false;

  List<CustomExam> exams = [];

  int? mainExamId;
  List<int> cumulativeExams = [];

  bool showAttendanceTable = true;
  bool showBlankAttendance = false;
  bool showGraph = false;
  bool showHeader = true;
  bool showCumulativeExams = false;
  bool showOnlyCumulativeExams = false;
  bool showRemarks = true;
  List<StudentProfile> selectedStudents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
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

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    mainExamId = null;
    cumulativeExams = [];
    GetCustomExamsResponse getCustomExamsResponse = await getAllExams(GetCustomExamsRequest(
      schoolId: widget.adminProfile.schoolId,
      sectionId: selectedSection?.sectionId,
    ));
    if (getCustomExamsResponse.httpStatus == "OK" && getCustomExamsResponse.responseStatus == "success") {
      exams = getCustomExamsResponse.customExamsList!.map((e) => e!).toList();
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

  get fetchGenerateStudentMemosRequest => GenerateStudentMemosRequest(
        mainExamId: mainExamId,
        otherExamIds: cumulativeExams,
        schoolId: widget.adminProfile.schoolId,
        sectionId: selectedSection?.sectionId,
        showAttendanceTable: showAttendanceTable,
        showBlankAttendance: showBlankAttendance,
        showGraph: showGraph,
        showHeader: showHeader,
        showOnlyCumulativeExams: showOnlyCumulativeExams,
        showRemarks: showRemarks,
        studentIds: selectedStudents.map((e) => e.studentId).toList(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memos"),
      ),
      body: _isReportDownlading
          ? const EpsilonDiaryLoadingWidget(
              defaultLoadingText: "Downloading Memos",
            )
          : _isLoading
              ? const EpsilonDiaryLoadingWidget()
              : ListView(
                  children: [
                    sectionPicker(),
                    if (selectedSection == null)
                      const Center(
                        child: Text("Select a section to continue"),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClayContainer(
                              depth: 20,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              spread: 2,
                              borderRadius: 10,
                              emboss: true,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: selectMainExamWidget(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (mainExamId == null) const Center(child: Text("Select main exam to explore more options")),
                            const SizedBox(height: 10),
                            if (mainExamId != null)
                              CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                value: showRemarks,
                                onChanged: (bool? change) {
                                  if (change != null) {
                                    setState(() => showRemarks = !showRemarks);
                                  }
                                },
                                title: const Text("Show Remarks"),
                              ),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null)
                              ClayContainer(
                                depth: 20,
                                surfaceColor: clayContainerColor(context),
                                parentColor: clayContainerColor(context),
                                spread: 2,
                                borderRadius: 10,
                                emboss: true,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        value: showCumulativeExams,
                                        onChanged: (bool? change) {
                                          if (change != null) {
                                            setState(() => showCumulativeExams = !showCumulativeExams);
                                          }
                                        },
                                        title: const Text("Pick other exams for Cumulative report"),
                                      ),
                                      if (showCumulativeExams) const SizedBox(height: 10),
                                      if (showCumulativeExams) buildCumulativeExamPicker(),
                                    ],
                                  ),
                                ),
                              ),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null)
                              ClayContainer(
                                depth: 20,
                                surfaceColor: clayContainerColor(context),
                                parentColor: clayContainerColor(context),
                                spread: 2,
                                borderRadius: 10,
                                emboss: true,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        value: showAttendanceTable,
                                        onChanged: (bool? change) {
                                          if (change != null) {
                                            setState(() => showAttendanceTable = !showAttendanceTable);
                                          }
                                        },
                                        title: const Text("Show Attendance table"),
                                      ),
                                      if (mainExamId != null && showAttendanceTable)
                                        ...[true, false].map(
                                          (e) => RadioListTile<bool?>(
                                            value: e,
                                            groupValue: showBlankAttendance,
                                            onChanged: (newValue) {
                                              if (newValue == null) return;
                                              setState(() {
                                                showBlankAttendance = newValue;
                                              });
                                            },
                                            title: Text(e ? "Show Blank Attendance" : "Show Populated Attendance"),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) buildGenerateMemoButton(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget buildGenerateMemoButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () async {
          setState(() => _isReportDownlading = true);
          CustomExam? mainExam = exams.firstWhereOrNull((e) => e.customExamId == mainExamId);
          bool isMainExamFA = mainExam?.examType == "FA";
          GenerateStudentMemosRequest generateStudentMemosRequest = fetchGenerateStudentMemosRequest;
          List<int>? bytes;
          if (isMainExamFA) {
            bytes = await downloadMemosForMainExamWithInternals(generateStudentMemosRequest);
          } else {
            bytes = await downloadMemosForMainExamWithoutInternals(generateStudentMemosRequest);
          }
          html.AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
            ..setAttribute("download", "${selectedSection?.sectionName}_${mainExam?.customExamName}_Memos.pdf")
            ..click();
          setState(() => _isReportDownlading = false);
        },
        child: ClayButton(
          surfaceColor: Colors.green,
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.check),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCumulativeExamPicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text("Select Exam"),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownSearch<CustomExam?>(
                  mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                  selectedItem: null,
                  items: examsAvailableForCumulation,
                  itemAsString: (CustomExam? exam) {
                    return exam?.customExamName ?? "-";
                  },
                  showSearchBox: true,
                  dropdownBuilder: (BuildContext context, CustomExam? exam) {
                    return eachExamBaseWidget(exam);
                  },
                  onChanged: (CustomExam? exam) {
                    if (exam?.customExamId == null) return;
                    setState(() => cumulativeExams.add(exam!.customExamId!));
                  },
                  compareFn: (item, selectedItem) => item?.customExamId == selectedItem?.customExamId,
                  dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                  filterFn: (CustomExam? exam, String? key) {
                    return (exam?.customExamName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (cumulativeExams.isEmpty)
            const Text("Select exams to continue")
          else
            ...cumulativeExams.map(
              (eId) => eachExamWidget(
                exams.firstWhereOrNull((e) => e.customExamId == eId),
                showClear: true,
              ),
            ),
        ],
      ),
    );
  }

  List<CustomExam> get examsAvailableForCumulation =>
      exams.where((e) => e.customExamId != mainExamId && !cumulativeExams.contains(e.customExamId)).toList();

  Widget selectMainExamWidget() {
    return Row(
      children: [
        const Text("Select Main Exam"),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownSearch<CustomExam?>(
            mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
            selectedItem: exams.firstWhereOrNull((e) => e.customExamId == mainExamId),
            items: exams,
            itemAsString: (CustomExam? exam) {
              return exam?.customExamName ?? "-";
            },
            showSearchBox: true,
            dropdownBuilder: (BuildContext context, CustomExam? exam) {
              return eachExamWidget(exam);
            },
            onChanged: (CustomExam? exam) {
              if (exam == null) return;
              setState(() => mainExamId = exam.customExamId);
            },
            compareFn: (item, selectedItem) => item?.customExamId == selectedItem?.customExamId,
            dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
            filterFn: (CustomExam? exam, String? key) {
              return (exam?.customExamName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
            },
          ),
        ),
      ],
    );
  }

  Widget eachExamWidget(
    CustomExam? e, {
    bool showClear = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: eachExamBaseWidget(e, showClear: showClear),
        ),
      ),
    );
  }

  Widget eachExamBaseWidget(CustomExam? e, {bool showClear = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(e?.customExamName ?? "-")),
            const SizedBox(width: 10),
            Chip(label: Text(e?.examType ?? "-")),
            if (showClear) const SizedBox(width: 10),
            if (showClear)
              IconButton(
                onPressed: () => setState(() => cumulativeExams.remove(e?.customExamId)),
                icon: const Icon(Icons.clear),
              ),
          ],
        ),
      ],
    );
  }

  Widget sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: selectSectionExpanded(),
                ),
              )
            : selectSectionCollapsed(),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() async {
            if (selectedSection != null && selectedSection!.sectionId == section.sectionId) {
              isSectionPickerOpen = false;
            } else {
              selectedSection = section;
              isSectionPickerOpen = false;
              await _loadExams();
            }
          });
        },
        child: ClayButton(
          depth: 40,
          spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
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
  }

  Widget selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                isSectionPickerOpen = !isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            shrinkWrap: true,
            children: sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            isSectionPickerOpen = !isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
