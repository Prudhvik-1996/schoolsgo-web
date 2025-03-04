import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/diary/model/diary.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AdminStudentIssuesScreen extends StatefulWidget {
  const AdminStudentIssuesScreen({
    Key? key,
    this.adminProfile,
    this.teacherProfile,
    required this.teachersList,
    required this.sectionsList,
    required this.subjectsList,
    required this.tdsList,
    this.selectedSection,
    this.selectedSubject,
    this.selectedTeacher,
    required this.selectedDate,
    required this.schoolInfoBean,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;

  final List<Teacher> teachersList;
  final List<Section> sectionsList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;

  final Section? selectedSection;
  final Subject? selectedSubject;
  final Teacher? selectedTeacher;
  final DateTime selectedDate;

  final SchoolInfoBean schoolInfoBean;

  @override
  State<AdminStudentIssuesScreen> createState() => _AdminStudentIssuesScreenState();
}

class _AdminStudentIssuesScreenState extends State<AdminStudentIssuesScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentProfile> studentsList = [];
  List<DiaryTopicBean> diaryTopics = [];
  List<DiaryIssueBean> diaryIssues = [];

  Section? selectedSection;
  Subject? selectedSubject;
  Teacher? selectedTeacher;
  DateTime? selectedDate = DateTime.now();
  TextEditingController studentNameEditingController = TextEditingController();
  TextEditingController topicNameEditingController = TextEditingController();

  DiaryIssueBean newDiaryIssueBean = DiaryIssueBean();

  @override
  void initState() {
    super.initState();
    selectedSection = widget.selectedSection;
    selectedSubject = widget.selectedSubject;
    selectedTeacher = widget.selectedTeacher;
    selectedDate = widget.selectedDate;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetStudentProfileRequest getStudentProfileRequest = GetStudentProfileRequest(
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
    );
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(getStudentProfileRequest);
    if (getStudentProfileResponse.httpStatus == "OK" && getStudentProfileResponse.responseStatus == "success") {
      studentsList = (getStudentProfileResponse.studentProfiles ?? []).map((e) => e!).toList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
      return;
    }
    GetDiaryTopicsRequest getDiaryTopicsRequest = GetDiaryTopicsRequest(
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
    );
    GetDiaryTopicsResponse getDiaryTopicsResponse = await getDiaryTopics(getDiaryTopicsRequest);
    if (getDiaryTopicsResponse.httpStatus == "OK" && getDiaryTopicsResponse.responseStatus == "success") {
      diaryTopics = (getDiaryTopicsResponse.diaryTopicBeans ?? []).map((e) => e!).toList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
      return;
    }
    GetDiaryIssuesRequest getDiaryIssuesRequest = GetDiaryIssuesRequest(
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
    );
    GetDiaryIssuesResponse getDiaryIssuesResponse = await getDiaryIssues(getDiaryIssuesRequest);
    if (getDiaryIssuesResponse.httpStatus == "OK" && getDiaryIssuesResponse.responseStatus == "success") {
      diaryIssues = (getDiaryIssuesResponse.diaryIssueBeans ?? []).map((e) => e!).toList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
      return;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Remarks"),
      ),
      body: _isLoading ? const EpsilonDiaryLoadingWidget() : oldTable(),
      floatingActionButton: _isLoading ? null : addIssueButton(context),
    );
  }

  Widget addIssueButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () async => addOrEditIssueDialog(DiaryIssueBean()),
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
                Icon(Icons.add),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Add Issue"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addOrEditIssueDialog(DiaryIssueBean diaryIssue) async {
    return await showDialog(
      context: scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: Text(diaryIssue.diaryIssueId == null ? "New Issue" : "Edit Issue"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: ListView(
                          children: [
                            dateAndActionsRow(diaryIssue, setState),
                            studentDetailsRow(diaryIssue, setState),
                            subjectPicker(diaryIssue, setState),
                            topicNamePicker(diaryIssue, setState),
                            remarksRow(diaryIssue, setState),
                            resolutionRow(diaryIssue, setState),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: saveActionsRow(diaryIssue, context),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget resolutionRow(DiaryIssueBean diaryIssue, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Resolution',
            hintText: 'Resolution',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
          ),
          maxLines: 5,
          controller: diaryIssue.resolutionEditingController,
          autofocus: false,
        ),
      ),
    );
  }

  Widget remarksRow(DiaryIssueBean diaryIssue, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Remarks',
            hintText: 'Remarks',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
          ),
          maxLines: 2,
          controller: diaryIssue.issueEditingController,
          autofocus: false,
        ),
      ),
    );
  }

  Widget topicNamePicker(DiaryIssueBean diaryIssue, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Topic Name',
            hintText: 'Topic Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
          ),
          controller: diaryIssue.topicNameEditingController,
          autofocus: false,
        ),
      ),
    );
  }

  Widget subjectPicker(DiaryIssueBean diaryIssue, StateSetter setState) {
    Subject? selectedSubjectForTheIssue = widget.subjectsList.firstWhereOrNull((es) => es.subjectId == diaryIssue.subjectId);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<Subject>(
            underline: Container(),
            hint: const Center(child: Text("Select Subject")),
            value: selectedSubjectForTheIssue,
            onChanged: (Subject? subject) {
              if (subject != null) {
                setState(() => diaryIssue.subjectId = subject.subjectId);
              }
            },
            items: widget.subjectsList
                .map(
                  (e) => DropdownMenuItem<Subject>(
                    value: e,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        e.subjectName ?? "-",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget studentDetailsRow(DiaryIssueBean diaryIssue, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InputDecorator(
              isFocused: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                label: Text(
                  "Student",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: DropdownSearch<StudentProfile>(
                  mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                  selectedItem: diaryIssue.studentId == null ? null : studentsList.where((e) => e.studentId == diaryIssue.studentId).firstOrNull,
                  items: studentsList.where((e) => diaryIssue.sectionId == null || diaryIssue.sectionId == e.sectionId).toList(),
                  itemAsString: (StudentProfile? student) {
                    return student == null
                        ? ""
                        : [
                              ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                              student.studentFirstName ?? "",
                              student.studentMiddleName ?? "",
                              student.studentLastName ?? ""
                            ].where((e) => e != "").join(" ").trim() +
                            " - ${student.sectionName}";
                  },
                  showSearchBox: true,
                  dropdownBuilder: (BuildContext context, StudentProfile? student) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child: ListTile(
                        leading: MediaQuery.of(context).orientation == Orientation.portrait
                            ? null
                            : Container(
                                width: 50,
                                padding: const EdgeInsets.all(5),
                                child: student?.studentPhotoUrl == null
                                    ? Image.asset(
                                        "assets/images/avatar.png",
                                        fit: BoxFit.contain,
                                      )
                                    : Image.network(
                                        student!.studentPhotoUrl!,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                        title: AutoSizeText(
                          "${student?.rollNumber == null ? "" : "${student!.rollNumber!}. "} ${student?.studentFirstName} [${student?.sectionName ?? "-"}]"
                              .trim(),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          minFontSize: 12,
                        ),
                      ),
                    );
                  },
                  onChanged: (StudentProfile? student) {
                    setState(() {
                      diaryIssue.sectionId = student?.sectionId;
                      diaryIssue.studentId = student?.studentId;
                    });
                  },
                  showClearButton: false,
                  compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
                  dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                  filterFn: (StudentProfile? student, String? key) {
                    return ([
                              ((student?.rollNumber ?? "") == "" ? "" : student!.rollNumber! + "."),
                              student?.studentFirstName ?? "",
                              student?.studentMiddleName ?? "",
                              student?.studentLastName ?? ""
                            ].where((e) => e != "").join(" ") +
                            " - ${student?.sectionName ?? ""}")
                        .toLowerCase()
                        .trim()
                        .contains(key!.toLowerCase());
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: InputDecorator(
              isFocused: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(15, 0, 5, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                label: Text(
                  "Section",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: DropdownSearch<Section>(
                  mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                  selectedItem: widget.sectionsList.where((e) => e.sectionId == diaryIssue.sectionId).firstOrNull,
                  items: widget.sectionsList,
                  itemAsString: (Section? section) {
                    return section == null ? "" : section.sectionName ?? "-";
                  },
                  showSearchBox: true,
                  dropdownBuilder: (BuildContext context, Section? section) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(widget.sectionsList.where((e) => e.sectionId == diaryIssue.sectionId).firstOrNull?.sectionName ?? "-"),
                    );
                  },
                  onChanged: (Section? section) {
                    setState(() {
                      diaryIssue.sectionId = section?.sectionId;
                      diaryIssue.studentId = null;
                    });
                  },
                  showClearButton: false,
                  compareFn: (item, selectedItem) => item?.sectionId == selectedItem?.sectionId,
                  dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                  filterFn: (Section? section, String? key) {
                    return (section?.sectionName ?? "").toLowerCase().contains(key!.toLowerCase());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dateAndActionsRow(DiaryIssueBean diaryIssue, StateSetter setState) {
    DateTime dateOfIssue = diaryIssue.date == null ? getDefaultDate() : convertYYYYMMDDFormatToDateTime(diaryIssue.date);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              DateTime? _newDate = await showDatePicker(
                context: context,
                initialDate: dateOfIssue,
                firstDate: convertYYYYMMDDFormatToDateTime(widget.schoolInfoBean.academicYearStartDate),
                lastDate: convertYYYYMMDDFormatToDateTime(widget.schoolInfoBean.academicYearEndDate),
                helpText: "Pick a date",
              );
              if (_newDate == null) return;
              setState(() {
                diaryIssue.date = convertDateTimeToDDMMYYYYFormat(_newDate);
              });
            },
            child: ClayButton(
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              borderRadius: 10,
              spread: 2,
              child: SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(convertDateTimeToDDMMYYYYFormat(dateOfIssue)),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              setState(() => diaryIssue.status = 'inactive');
            },
            child: ClayButton(
              depth: 15,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 100,
              child: const SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row saveActionsRow(DiaryIssueBean diaryIssue, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              setState(() => diaryIssue.populateFromTextControllers());
              // TODO save issue
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
        ),
        const SizedBox(width: 30),
        GestureDetector(
          onTap: () async {
            Navigator.pop(context);
          },
          child: ClayButton(
            surfaceColor: Colors.red,
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
                  Icon(Icons.clear),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget oldTable() {
    var filteredDiaryIssues = diaryIssues
        .where((ei) => selectedDate == null || ei.date == convertDateTimeToYYYYMMDDFormat(selectedDate))
        .where((ei) => selectedSection == null || ei.sectionId == selectedSection?.sectionId)
        .where((ei) => selectedSubject == null || ei.subjectId == selectedSubject?.subjectId)
        .where((ei) {
      if (studentNameEditingController.text.trim().isEmpty) return true;
      StudentProfile? es = studentsList.firstWhereOrNull((e) => e.studentId == ei.studentId);
      return "${es?.rollNumber == null ? "" : "${es?.rollNumber}."} ${es?.studentFirstName ?? ""}"
          .toLowerCase()
          .contains(studentNameEditingController.text.trim().toLowerCase());
    }).where((ei) {
      if (topicNameEditingController.text.trim().isEmpty) return true;
      DiaryTopicBean? diaryTopicBean = diaryTopics.firstWhereOrNull((e) => e.diaryTopicId == ei.topicId);
      return (diaryTopicBean?.topicName ?? "").toLowerCase().contains(topicNameEditingController.text.trim().toLowerCase());
    });
    return ClayTable2DWidgetV2(
      context: context,
      horizontalScrollController: ScrollController(),
      columns: [
        const DataColumn(label: Text('S. No.')),
        DataColumn(label: dateHeader()),
        DataColumn(label: sectionHeader()),
        DataColumn(label: studentNameHeader()),
        DataColumn(label: subjectNameHeader()),
        DataColumn(label: topicNameHeader()),
        const DataColumn(label: Text('Remarks')),
        const DataColumn(label: Text('Resolution')),
        const DataColumn(label: Text('')),
      ],
      rows: filteredDiaryIssues.mapIndexed((int index, DiaryIssueBean eachDiaryIssue) {
        DiaryTopicBean? diaryTopicBean = diaryTopics.firstWhereOrNull((e) => e.diaryTopicId == eachDiaryIssue.topicId);
        StudentProfile? student = studentsList.firstWhereOrNull((es) => es.studentId == eachDiaryIssue.studentId);
        Section? section = widget.sectionsList.firstWhereOrNull((es) => es.sectionId == eachDiaryIssue.sectionId);
        Subject? subject = widget.subjectsList.firstWhereOrNull((es) => es.subjectId == eachDiaryIssue.subjectId);
        return DataRow(
          color: MaterialStateProperty.resolveWith((Set states) {
            if (index % 2 == 0) {
              return clayContainerColor(context);
            }
            return Colors.grey;
          }),
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  "${index + 1}",
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(eachDiaryIssue.date)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  section?.sectionName ?? "-",
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  "${student?.rollNumber == null ? "" : "${student?.rollNumber}."} ${student?.studentFirstName ?? ""}",
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  subject?.subjectName ?? "-",
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  diaryTopicBean?.topicName ?? "",
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  eachDiaryIssue.issue ?? "",
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  eachDiaryIssue.resolution ?? "",
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            DataCell(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: GestureDetector(
                  onTap: () => addOrEditIssueDialog(eachDiaryIssue),
                  child: const SizedBox(
                    height: 25,
                    width: 25,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
      bottomMessage: filteredDiaryIssues.isEmpty ? "No records found for the applied filters" : null,
    );
  }

  Widget topicNameHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: SizedBox(
          width: 300,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Topic Name',
              hintText: 'Topic Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
            controller: topicNameEditingController,
            autofocus: false,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
    );
  }

  Widget subjectNameHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<Subject>(
            underline: Container(),
            hint: const Center(child: Text("Select Subject")),
            value: selectedSubject,
            onChanged: (Subject? subject) => setState(() => selectedSubject = subject),
            items: [null, ...widget.subjectsList]
                .map(
                  (e) => DropdownMenuItem<Subject>(
                    value: e,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        e?.subjectName ?? "All subjects",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget studentNameHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Student Name',
              hintText: 'Student Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
            controller: studentNameEditingController,
            autofocus: false,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
    );
  }

  Widget sectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<Section>(
            underline: Container(),
            hint: const Center(child: Text("Select Section")),
            value: selectedSection,
            onChanged: (Section? section) => setState(() => selectedSection = section),
            items: [null, ...widget.sectionsList]
                .map(
                  (e) => DropdownMenuItem<Section>(
                    value: e,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        e?.sectionName ?? "All sections",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget dateHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            DateTime? _newDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? getDefaultDate(),
              firstDate: convertYYYYMMDDFormatToDateTime(widget.schoolInfoBean.academicYearStartDate),
              lastDate: convertYYYYMMDDFormatToDateTime(widget.schoolInfoBean.academicYearEndDate),
              helpText: "Pick a date",
              // selectableDayPredicate: (DateTime? eachDate) {
              //   return convertDateTimeToYYYYMMDDFormat(eachDate) == convertDateTimeToYYYYMMDDFormat(widget.selectedDate) ||
              //       diaryIssues.map((e) => e.date).contains(convertDateTimeToYYYYMMDDFormat(eachDate));
              // },
            );
            if (_newDate == null) return;
            setState(() {
              selectedDate = _newDate;
            });
          },
          child: ClayButton(
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            borderRadius: 10,
            spread: 2,
            child: SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(selectedDate == null ? 'Date' : convertDateTimeToDDMMYYYYFormat(selectedDate!)),
                ),
              ),
            ),
          ),
        ),
        if (selectedDate != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => setState(() => selectedDate = null),
              child: ClayButton(
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                borderRadius: 20,
                spread: 2,
                width: 25,
                height: 25,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(Icons.clear),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

// Widget _subjectsDropdown() => DropdownButton<Subject?>(
//   isExpanded: true,
//   items: filteredSubjects
//       .map((Subject eachSubject) => DropdownMenuItem<Subject>(
//     child: FittedBox(
//       fit: BoxFit.scaleDown,
//       child: Text(eachSubject.subjectName ?? "-"),
//     ),
//     value: eachSubject,
//   ))
//       .toList(),
//   value: filteredSubjects.where((e) => e.subjectId == selectedSubjectId).firstOrNull,
//   onChanged: (Subject? newSubject) => setState(() => selectedSubjectId = newSubject?.subjectId),
// );

  DateTime getDefaultDate() {
    var startDate = convertYYYYMMDDFormatToDateTime(widget.schoolInfoBean.academicYearStartDate);
    int startMillis = startDate.millisecondsSinceEpoch;
    var endDate = convertYYYYMMDDFormatToDateTime(widget.schoolInfoBean.academicYearEndDate);
    int endMillis = endDate.millisecondsSinceEpoch;
    if (startMillis < DateTime.now().millisecondsSinceEpoch && DateTime.now().millisecondsSinceEpoch < endMillis) {
      return DateTime.now();
    } else if (startMillis > DateTime.now().millisecondsSinceEpoch) {
      return startDate;
    } else {
      return endDate;
    }
  }
}
