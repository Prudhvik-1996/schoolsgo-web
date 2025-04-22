import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:math';

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
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

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
  bool _isReportDownloading = false;

  List<Section> sectionsList = [];
  Section? selectedSection;
  List<Subject> allSubjectsList = [];
  bool isSectionPickerOpen = false;

  List<CustomExam> exams = [];

  int? mainExamId;
  List<int> cumulativeExams = [];

  bool showAttendanceTable = true;
  bool showBlankAttendance = false;
  bool showMoreAttendanceOptions = false;
  bool showTotalAttendancePercentage = false;
  bool showGraph = false;
  bool showHeader = true;
  bool showCumulativeExams = false;
  bool showOnlyCumulativeExams = false;
  bool showRemarks = true;
  String studentPhotoSize = "S";
  bool showAttendanceSummaryTable = false;
  bool showCommentsPerSubject = false;
  bool showGpaDenominator = false;
  bool showMarkingAlgorithmTable = false;
  AttendanceViewOption? attendanceViewOption = AttendanceViewOption.totalPercentage;

  List<String> monthYears = [];
  Set<String> selectedMonthYears = {};

  List<StudentProfile> studentsForSelectedSection = [];
  Map<int, bool> studentMemoMap = {};
  List<MergeSubjectsForMemoBean> mergeSubjectsForMemoBeans = [];
  bool isMergeSubjectsChecked = false;
  List<int?> otherSubjectIds = [];
  bool isOtherSubjectsChecked = false;

  final ScrollController _controller = ScrollController();
  final ScrollController _otherExamsScrollController = ScrollController();

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
    GetSubjectsRequest getSubjectsRequest = GetSubjectsRequest(schoolId: widget.adminProfile.schoolId);
    GetSubjectsResponse getSubjectsResponse = await getSubjects(getSubjectsRequest);
    if (getSubjectsResponse.httpStatus == "OK" && getSubjectsResponse.responseStatus == "success") {
      allSubjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
    }
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      Navigator.pop(context);
      return;
    } else {
      SchoolInfoBean schoolInfo = getSchoolsResponse.schoolInfo!;
      DateTime startDate = convertYYYYMMDDFormatToDateTime(schoolInfo.academicYearStartDate);
      DateTime endDate = convertYYYYMMDDFormatToDateTime(schoolInfo.academicYearEndDate);
      monthYears = generateMmmYYYYStrings(startDate, endDate);
      selectedMonthYears = generateMmmYYYYStrings(startDate, DateTime.now()).toSet();
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
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
      sectionId: selectedSection?.sectionId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentsForSelectedSection = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
      studentsForSelectedSection.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      studentMemoMap = {};
      for (StudentProfile es in studentsForSelectedSection) {
        studentMemoMap[es.studentId!] = true;
      }
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
        studentIds: studentsForSelectedSection.where((e) => studentMemoMap[e.studentId!] ?? false).map((e) => e.studentId).toList(),
        monthYearsForAttendance: selectedMonthYears.toList(),
        studentPhotoSize: studentPhotoSize,
        mergeSubjectsForMemoBeans: isMergeSubjectsChecked ? mergeSubjectsForMemoBeans : [],
        otherSubjectIds: isOtherSubjectsChecked ? otherSubjectIds : [],
        showTotalAttendancePercentage: showMoreAttendanceOptions
            ? showAttendanceSummaryTable
                ? false
                : showTotalAttendancePercentage
            : false,
        showAttendanceSummaryTable: showMoreAttendanceOptions ? showAttendanceSummaryTable : false,
        showCommentsPerSubject: showCommentsPerSubject,
        showGpaDenominator: showGpaDenominator,
        showMarkingAlgorithmTable: showMarkingAlgorithmTable,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memos"),
      ),
      body: _isReportDownloading
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
                                value: otherSubjectIds.isNotEmpty || showRemarks,
                                onChanged: (bool? change) {
                                  if (change != null) {
                                    setState(() => showRemarks = !showRemarks);
                                  }
                                },
                                title: const Text("Show Over all Remarks"),
                              ),
                            if (mainExamId != null)
                              CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                value: showCommentsPerSubject,
                                onChanged: (bool? change) {
                                  if (change != null) {
                                    setState(() => showCommentsPerSubject = !showCommentsPerSubject);
                                  }
                                },
                                title: const Text("Show subject wise remarks"),
                              ),
                            if (mainExamId != null)
                              CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                value: showMarkingAlgorithmTable,
                                onChanged: (bool? change) {
                                  if (change != null) {
                                    setState(() => showMarkingAlgorithmTable = !showMarkingAlgorithmTable);
                                  }
                                },
                                title: const Text("Show Grading System"),
                              ),
                            if (mainExamId != null)
                              Column(
                                children: [
                                  if (mainExamId != null) const SizedBox(height: 10),
                                  RadioListTile<bool>(
                                    value: false,
                                    groupValue: showGpaDenominator,
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        setState(() {
                                          showGpaDenominator = value;
                                        });
                                      }
                                    },
                                    title: const Text("Show GPA as 9.8"),
                                  ),
                                  if (mainExamId != null) const SizedBox(height: 10),
                                  RadioListTile<bool>(
                                    value: true,
                                    groupValue: showGpaDenominator,
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        setState(() {
                                          showGpaDenominator = value;
                                        });
                                      }
                                    },
                                    title: const Text("Show GPA as 9.8 / 10"),
                                  ),
                                ],
                              ),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) mergeSubjectsWidget(),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) otherSubjectsWidget(),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) pickCumulativeExamsWidget(context),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) showGraphCheckboxWidget(context),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) showAttendanceCheckboxWidget(context),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) buildStudentPhotoSizeBuilder(),
                            if (mainExamId != null) const SizedBox(height: 10),
                            if (mainExamId != null) buildStudentsSelectorWidget(),
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

  Widget otherSubjectsWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: isOtherSubjectsChecked,
                onChanged: (bool? change) {
                  if (change != null) {
                    setState(() => isOtherSubjectsChecked = !isOtherSubjectsChecked);
                  }
                },
                title: const Text("Mark Other Subjects"),
              ),
              if (isOtherSubjectsChecked) const SizedBox(height: 8),
              if (isOtherSubjectsChecked)
                Scrollbar(
                  thumbVisibility: true,
                  controller: _otherExamsScrollController,
                  child: SingleChildScrollView(
                    controller: _otherExamsScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...(otherSubjectIds).mapIndexed(
                          (i, eos) => (eos == null)
                              ? SizedBox(
                                  width: 150,
                                  height: 50,
                                  child: ClayButton(
                                    depth: 20,
                                    surfaceColor: clayContainerColor(context),
                                    parentColor: clayContainerColor(context),
                                    spread: 2,
                                    borderRadius: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: DropdownSearch<Subject?>(
                                          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                                          selectedItem: null,
                                          items: subjectsList
                                              .where((es) =>
                                                  !otherSubjectIds.contains(es.subjectId) &&
                                                  !mergeSubjectsForMemoBeans
                                                      .map((e) => [e.subjectId, ...e.childrenSubjectIds ?? []])
                                                      .expand((i) => i)
                                                      .contains(es.subjectId))
                                              .toList(),
                                          itemAsString: (Subject? subject) {
                                            return subject?.subjectName ?? "-";
                                          },
                                          showSearchBox: true,
                                          dropdownBuilder: (BuildContext context, Subject? subject) {
                                            return Text(subject?.subjectName ?? "-");
                                          },
                                          onChanged: (Subject? subject) {
                                            if (subject?.subjectId == null) return;
                                            setState(() {
                                              otherSubjectIds.add(subject?.subjectId);
                                              otherSubjectIds.remove(null);
                                            });
                                          },
                                          compareFn: (item, selectedItem) => item?.subjectId == selectedItem?.subjectId,
                                          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                                          filterFn: (Subject? subject, String? key) {
                                            return (subject?.subjectName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  child: Row(
                                    children: [
                                      ClayContainer(
                                        depth: 20,
                                        surfaceColor: clayContainerColor(context),
                                        parentColor: clayContainerColor(context),
                                        spread: 2,
                                        borderRadius: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Text(allSubjectsList.firstWhereOrNull((es) => es.subjectId == eos)?.subjectName ?? "-"),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.cancel,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    otherSubjectIds.removeAt(i);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              otherSubjectIds.add(null);
                            });
                          },
                          child: ClayButton(
                            depth: 20,
                            surfaceColor: clayContainerColor(context),
                            parentColor: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 10,
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                              child: Text("Add"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mergeSubjectsWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: isMergeSubjectsChecked,
                onChanged: (bool? change) {
                  if (change != null) {
                    setState(() => isMergeSubjectsChecked = !isMergeSubjectsChecked);
                  }
                },
                title: const Text("Merge Subjects"),
              ),
              if (isMergeSubjectsChecked) const SizedBox(height: 8),
              if (isMergeSubjectsChecked) ...mergeSubjectsForMemoBeans.mapIndexed((i, e) => mergeSubjectWidget(i)),
              if (isMergeSubjectsChecked) const SizedBox(height: 8),
              if (isMergeSubjectsChecked)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      mergeSubjectsForMemoBeans.add(MergeSubjectsForMemoBean());
                    });
                  },
                  child: ClayButton(
                    depth: 20,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 2,
                    borderRadius: 10,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text("Add"),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mergeSubjectWidget(int i) {
    MergeSubjectsForMemoBean e = mergeSubjectsForMemoBeans[i];
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Scrollbar(
        thumbVisibility: true,
        controller: e.scrollController,
        child: SingleChildScrollView(
          controller: e.scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    mergeSubjectsForMemoBeans.removeAt(i);
                    if (mergeSubjectsForMemoBeans.isEmpty) {
                      mergeSubjectsForMemoBeans.add(MergeSubjectsForMemoBean());
                    }
                  });
                },
              ),
              const SizedBox(width: 4),
              e.subjectId != null
                  ? ClayContainer(
                      depth: 20,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 2,
                      borderRadius: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(allSubjectsList.firstWhereOrNull((es) => es.subjectId == e.subjectId)?.subjectName ?? "-"),
                      ),
                    )
                  : SizedBox(
                      width: 150,
                      height: 50,
                      child: ClayButton(
                        depth: 20,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 2,
                        borderRadius: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: DropdownSearch<Subject?>(
                              mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                              selectedItem: subjectsList.firstWhereOrNull((es) => e.subjectId == es.subjectId),
                              items: allSubjectsList
                                  .where((es) =>
                                      !otherSubjectIds.contains(es.subjectId) &&
                                      !mergeSubjectsForMemoBeans
                                          .map((e) => [e.subjectId, ...e.childrenSubjectIds ?? []])
                                          .expand((i) => i)
                                          .contains(es.subjectId))
                                  .toList(),
                              itemAsString: (Subject? subject) {
                                return subject?.subjectName ?? "-";
                              },
                              showSearchBox: true,
                              dropdownBuilder: (BuildContext context, Subject? subject) {
                                return Text(subject?.subjectName ?? "-");
                              },
                              onChanged: (Subject? subject) {
                                if (subject?.subjectId == null) return;
                                setState(() => e.subjectId = subject?.subjectId);
                              },
                              compareFn: (item, selectedItem) => item?.subjectId == selectedItem?.subjectId,
                              dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                              filterFn: (Subject? subject, String? key) {
                                return (subject?.subjectName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 8),
              const Text("="),
              const SizedBox(width: 8),
              ...(e.childrenSubjectIds ?? []).mapIndexed(
                (i, ecs) => (ecs == null)
                    ? SizedBox(
                        width: 150,
                        height: 50,
                        child: ClayButton(
                          depth: 20,
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          spread: 2,
                          borderRadius: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: DropdownSearch<Subject?>(
                                mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                                selectedItem: null,
                                items: subjectsList
                                    .where((es) =>
                                        !otherSubjectIds.contains(es.subjectId) &&
                                        !mergeSubjectsForMemoBeans
                                            .map((e) => [e.subjectId, ...e.childrenSubjectIds ?? []])
                                            .expand((i) => i)
                                            .contains(es.subjectId))
                                    .toList(),
                                itemAsString: (Subject? subject) {
                                  return subject?.subjectName ?? "-";
                                },
                                showSearchBox: true,
                                dropdownBuilder: (BuildContext context, Subject? subject) {
                                  return Text(subject?.subjectName ?? "-");
                                },
                                onChanged: (Subject? subject) {
                                  if (subject?.subjectId == null) return;
                                  setState(() {
                                    e.childrenSubjectIds ??= [];
                                    e.childrenSubjectIds!.add(subject?.subjectId);
                                    e.childrenSubjectIds!.remove(null);
                                  });
                                },
                                compareFn: (item, selectedItem) => item?.subjectId == selectedItem?.subjectId,
                                dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                                filterFn: (Subject? subject, String? key) {
                                  return (subject?.subjectName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: Row(
                          children: [
                            ClayContainer(
                              depth: 20,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              spread: 2,
                              borderRadius: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(allSubjectsList.firstWhereOrNull((es) => es.subjectId == ecs)?.subjectName ?? "-"),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          (e.childrenSubjectIds ?? []).removeAt(i);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text("+"),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    e.childrenSubjectIds ??= [];
                    e.childrenSubjectIds!.add(null);
                  });
                },
                child: ClayButton(
                  depth: 20,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Text("Add"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ClayContainer pickCumulativeExamsWidget(BuildContext context) {
    return ClayContainer(
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
    );
  }

  ClayContainer showGraphCheckboxWidget(BuildContext context) {
    return ClayContainer(
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
              value: showGraph,
              onChanged: (bool? change) {
                if (change != null) {
                  setState(() => showGraph = !showGraph);
                }
              },
              title: const Text("Show graph for main exam"),
            ),
          ],
        ),
      ),
    );
  }

  ClayContainer showAttendanceCheckboxWidget(BuildContext context) {
    return ClayContainer(
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
                if (change == null) return;
                setState(() {
                  showAttendanceTable = !showAttendanceTable;
                  if (!showAttendanceTable) {
                    selectedMonthYears = {};
                  }
                });
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
            if (mainExamId != null && showAttendanceTable) const SizedBox(height: 10),
            if (showAttendanceTable) const Divider(),
            if (mainExamId != null && showAttendanceTable)
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: showMoreAttendanceOptions,
                onChanged: (bool? changed) => setState(() => showMoreAttendanceOptions = changed ?? false),
                title: const Text("Show More Attendance options"),
              ),
            if (mainExamId != null && showAttendanceTable && showMoreAttendanceOptions)
              Column(
                children: [
                  RadioListTile<AttendanceViewOption>(
                    value: AttendanceViewOption.totalPercentage,
                    groupValue: attendanceViewOption,
                    onChanged: (AttendanceViewOption? value) {
                      setState(() {
                        attendanceViewOption = value;
                        showTotalAttendancePercentage = value == AttendanceViewOption.totalPercentage;
                        showAttendanceSummaryTable = value == AttendanceViewOption.summaryTable;
                      });
                    },
                    title: const Text("Show Total Attendance Percentage"),
                  ),
                  RadioListTile<AttendanceViewOption>(
                    value: AttendanceViewOption.summaryTable,
                    groupValue: attendanceViewOption,
                    onChanged: (AttendanceViewOption? value) {
                      setState(() {
                        attendanceViewOption = value;
                        showTotalAttendancePercentage = value == AttendanceViewOption.totalPercentage;
                        showAttendanceSummaryTable = value == AttendanceViewOption.summaryTable;
                      });
                    },
                    title: const Text("Show Attendance Summary Table"),
                  ),
                ],
              ),
            if (mainExamId != null && showAttendanceTable) const SizedBox(height: 10),
            if (showAttendanceTable) const Divider(),
            if (mainExamId != null && showAttendanceTable) const SizedBox(height: 10),
            if (mainExamId != null && showAttendanceTable)
              Scrollbar(
                thumbVisibility: true,
                controller: _controller,
                child: SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...["Select All", ...monthYears].map(
                        (e) => SizedBox(
                          width: 150,
                          height: 60,
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: selectedMonthYears.contains(e),
                            onChanged: (bool? change) {
                              if (change == null) return;
                              setState(() {
                                if (e == "Select All") {
                                  selectedMonthYears.clear();
                                  selectedMonthYears = monthYears.toSet();
                                }
                                if (change) {
                                  selectedMonthYears.add(e);
                                } else {
                                  selectedMonthYears.remove(e);
                                }
                              });
                            },
                            title: Text(e, style: const TextStyle(fontSize: 14)), // Adjust font size if needed
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentPhotoSizeBuilder() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        children: [
          const Text("Student Photo Size"),
          ...["S", "M", "L"].map(
            (e) => Expanded(
              child: RadioListTile<String?>(
                value: e,
                groupValue: studentPhotoSize,
                onChanged: (newValue) {
                  if (newValue == null) return;
                  setState(() {
                    studentPhotoSize = newValue;
                  });
                },
                title: Text(e),
              ),
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
          if (isOtherSubjectsChecked && (otherSubjectIds.contains(null) || otherSubjectIds.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("When checked on \"Mark other subjects\" you must put in at least one subject"),
              ),
            );
            return;
          }
          if (isMergeSubjectsChecked && mergeSubjectsForMemoBeans.isNotEmpty) {
            if (mergeSubjectsForMemoBeans.map((e) => e.subjectId).contains(null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("When merge subjects is checks ou must check at least one subject."),
                ),
              );
              return;
            }
            for (MergeSubjectsForMemoBean eachMergeSubjectsForMemoBean in mergeSubjectsForMemoBeans) {
              if ((eachMergeSubjectsForMemoBean.childrenSubjectIds ?? []).isEmpty ||
                  (eachMergeSubjectsForMemoBean.childrenSubjectIds ?? []).contains(null)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Select all the children subjects for the subject ${subjectsList.firstWhereOrNull((es) => es.subjectId == eachMergeSubjectsForMemoBean.subjectId)?.subjectName ?? "-"} to continue",
                    ),
                  ),
                );
                return;
              }
            }
          }
          List<int> selectedSubjectsForMerge = !isMergeSubjectsChecked
              ? []
              : mergeSubjectsForMemoBeans.map((e) => (e.childrenSubjectIds ?? []).whereNotNull()).expand((i) => i).toList();
          List<int> selectedSubjectsForOther = !isOtherSubjectsChecked ? [] : otherSubjectIds.whereNotNull().toList();
          List<int> subjectsUnavailableForMerge =
              selectedSubjectsForMerge.map((e) => !subjectsList.map((es) => es.subjectId).contains(e) ? e : null).whereNotNull().toList();
          List<int> subjectsUnavailableForOther =
              selectedSubjectsForOther.map((e) => !subjectsList.map((es) => es.subjectId).contains(e) ? e : null).whereNotNull().toList();
          if (subjectsUnavailableForMerge.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${subjectsUnavailableForMerge.map((e) => allSubjectsList.firstWhereOrNull((es) => es.subjectId == e)?.subjectName).join(", ")} are not available for this exam to merge",
                ),
              ),
            );
            return;
          }
          if (subjectsUnavailableForOther.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${subjectsUnavailableForOther.map((e) => allSubjectsList.firstWhereOrNull((es) => es.subjectId == e)?.subjectName).join(", ")} are not available for this exam to mark as other exams",
                ),
              ),
            );
            return;
          }
          setState(() => _isReportDownloading = true);
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
          setState(() => _isReportDownloading = false);
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
                child: ClayButton(
                  depth: 20,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
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

  Widget buildStudentsSelectorWidget() {
    return GestureDetector(
      onTap: () async => await showStudentsPickerDialogue(),
      child: ClayButton(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        spread: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.check_box),
              SizedBox(width: 8),
              Text("Select Students"),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showStudentsPickerDialogue() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text("Students' Exam Marks"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              var horizontalScrollView = ScrollController();
              return SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width - 100,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: horizontalScrollView,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: horizontalScrollView,
                    child: SizedBox(
                      width: max(500, MediaQuery.of(context).size.width - 150),
                      child: ListView(
                        children: [
                          MediaQuery.of(context).orientation == Orientation.landscape
                              ? Row(
                                  children: selectAllCheckBoxes(setState).map((e) => Expanded(child: e)).toList(),
                                )
                              : Column(
                                  children: selectAllCheckBoxes(setState),
                                ),
                          ...studentMemoMap.entries.map((eachEntry) {
                            int eachStudentId = eachEntry.key;
                            StudentProfile eachStudentProfile = studentsForSelectedSection.firstWhere((e) => e.studentId == eachStudentId);
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Row(
                                children: [
                                  Text(
                                    eachStudentProfile.rollNumber ?? "-",
                                    style: TextStyle(color: clayContainerTextColor(context)),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      eachStudentProfile.studentFirstName ?? "-",
                                      style: TextStyle(color: clayContainerTextColor(context)),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Tooltip(
                                    message: eachStudentProfile.getAccommodationType(),
                                    child: ClayContainer(
                                      depth: 20,
                                      surfaceColor: clayContainerColor(context),
                                      parentColor: clayContainerColor(context),
                                      spread: 2,
                                      borderRadius: 2,
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.center,
                                            child: Text(eachStudentProfile.studentAccommodationType ?? "-"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              selected: studentMemoMap[eachStudentId] ?? false,
                              value: studentMemoMap[eachStudentId] ?? false,
                              onChanged: (bool? selectStatus) {
                                if (selectStatus == null) return;
                                setState(() => studentMemoMap[eachStudentId] = selectStatus);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            studentMemoMap.values.contains(true)
                ? TextButton(
                    child: const Text("Done"),
                    onPressed: () async {
                      if (studentMemoMap.values.contains(true)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : const Text("Select at least one student to continue"),
          ],
        );
      },
    );
  }

  List<CheckboxListTile> selectAllCheckBoxes(StateSetter setState) {
    return [
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Select All"),
        selected: !studentMemoMap.values.contains(false),
        value: !studentMemoMap.values.contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          setState(() {
            if (selectStatus) {
              for (var eachStudentProfile in studentMemoMap.keys) {
                studentMemoMap[eachStudentProfile] = true;
              }
            } else {
              for (var eachStudentProfile in studentMemoMap.keys) {
                studentMemoMap[eachStudentProfile] = false;
              }
            }
          });
        },
      ),
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Clear All"),
        selected: !studentMemoMap.values.contains(true),
        value: !studentMemoMap.values.contains(true),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          setState(() {
            if (selectStatus) {
              for (var eachStudentProfile in studentMemoMap.keys) {
                studentMemoMap[eachStudentProfile] = false;
              }
            }
          });
        },
      ),
      CheckboxListTile(
        enabled: studentsForSelectedSection.where((es) => es.studentAccommodationType == "D").isNotEmpty,
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Day Scholar"),
        selected: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "D")
            .map((e) => e.studentId)
            .map((e) => studentMemoMap[e])
            .contains(false),
        value: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "D")
            .map((e) => e.studentId)
            .map((e) => studentMemoMap[e])
            .contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          if (selectStatus) {
            setState(() {
              studentsForSelectedSection.where((es) => es.studentAccommodationType == "D").map((e) => e.studentId!).forEach((e) {
                studentMemoMap[e] = true;
              });
            });
          }
        },
      ),
      CheckboxListTile(
        enabled: studentsForSelectedSection.where((es) => es.studentAccommodationType == "R").isNotEmpty,
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Residential"),
        selected: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "R")
            .map((e) => e.studentId)
            .map((e) => studentMemoMap[e])
            .contains(false),
        value: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "R")
            .map((e) => e.studentId)
            .map((e) => studentMemoMap[e])
            .contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          if (selectStatus) {
            setState(() {
              studentsForSelectedSection.where((es) => es.studentAccommodationType == "R").map((e) => e.studentId!).forEach((e) {
                studentMemoMap[e] = true;
              });
            });
          }
        },
      ),
      CheckboxListTile(
        enabled: studentsForSelectedSection.where((es) => es.studentAccommodationType == "S").isNotEmpty,
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Semi Residential"),
        selected: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "S")
            .map((e) => e.studentId)
            .map((e) => studentMemoMap[e])
            .contains(false),
        value: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "S")
            .map((e) => e.studentId)
            .map((e) => studentMemoMap[e])
            .contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          if (selectStatus) {
            setState(() {
              studentsForSelectedSection.where((es) => es.studentAccommodationType == "S").map((e) => e.studentId!).forEach((e) {
                studentMemoMap[e] = true;
              });
            });
          }
        },
      ),
    ];
  }

  Widget autoSizeText(String s) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(s),
      );

  List<Subject> get subjectsList => allSubjectsList.where((es) {
        CustomExam? mainExam = exams.firstWhereOrNull((e) => e.customExamId == mainExamId);
        if (mainExamId == null) return true;
        List<CustomExam> cumulativeExamsSelected = exams.where((e) => cumulativeExams.contains(e.customExamId)).toList();
        List<int> availableSubjectIds = (mainExam?.examSectionSubjectMapList ?? [])
                .where((e) => e?.sectionId == selectedSection?.sectionId)
                .map((e) => e?.subjectId)
                .whereNotNull()
                .toList() +
            cumulativeExamsSelected
                .map((e) => (e.examSectionSubjectMapList ?? [])
                    .where((e) => e?.sectionId == selectedSection?.sectionId)
                    .map((e) => e?.subjectId)
                    .whereNotNull())
                .expand((i) => i)
                .toList();
        return availableSubjectIds.contains(es.subjectId);
      }).toList();
}

enum AttendanceViewOption {
  totalPercentage,
  summaryTable,
}
