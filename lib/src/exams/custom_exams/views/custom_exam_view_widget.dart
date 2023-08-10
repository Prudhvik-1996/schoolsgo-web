import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exams_all_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class CustomExamViewWidget extends StatefulWidget {
  const CustomExamViewWidget({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.customExam,
    required this.studentsList,
    required this.loadData,
    required this.selectedSection,
    required this.markingAlgorithms, required this.schoolInfo,
  }) : super(key: key);

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final CustomExam customExam;
  final List<StudentProfile> studentsList;
  final Future<void> Function() loadData;
  final Section? selectedSection;
  final List<MarkingAlgorithmBean> markingAlgorithms;

  @override
  State<CustomExamViewWidget> createState() => _CustomExamViewWidgetState();
}

class _CustomExamViewWidgetState extends State<CustomExamViewWidget> {
  final ScrollController _controller = ScrollController();
  List<ExamSectionSubjectMap> examSectionSubjectMapList = [];
  List<TeacherDealingSection> tdsList = [];

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    examSectionSubjectMapList = (widget.customExam.examSectionSubjectMapList ?? []).map((e) => e!).toList();
    tdsList = widget.tdsList.where((e) => e.status == 'active').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        emboss: _isExpanded,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customExamNameWidget(),
              if (_isExpanded) const SizedBox(height: 15),
              if (_isExpanded) populatedTdsList(),
              if (_isExpanded) const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget populatedTdsList() {
    return Column(
      children: [
        ...examSectionSubjectMapList.where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId).map(
              (eachExamSectionSubjectMap) => Container(
                margin: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () => goToMarksScreen(eachExamSectionSubjectMap),
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Class: ${widget.sectionsList.firstWhere((e) => e.sectionId == eachExamSectionSubjectMap.sectionId).sectionName ?? " - "}",
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Subject: ${tdsList.firstWhere((e) => e.subjectId == eachExamSectionSubjectMap.subjectId).subjectName ?? " - "}",
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Card(
                                        color: Colors.blue,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(eachExamSectionSubjectMap.examDate),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Card(
                                            color: Colors.blueGrey,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(eachExamSectionSubjectMap.startTimeSlot),
                                            ),
                                          ),
                                          Card(
                                            color: Colors.blueGrey,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(eachExamSectionSubjectMap.endTimeSlot),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Max Marks: ${eachExamSectionSubjectMap.maxMarks ?? " - "}",
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Class Average: ${eachExamSectionSubjectMap.classAverage ?? " - "}",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Absentees: ${(eachExamSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.isAbsent == 'N').length}",
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Highest Marks: ${(eachExamSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.isAbsent != 'N').map((e) => e?.marksObtained).whereNotNull().maxOrNull ?? " - "}",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  void goToMarksScreen(ExamSectionSubjectMap eachExamSectionSubjectMap) {
    TeacherDealingSection? tds = widget.tdsList
        .where((eachTds) =>
            eachTds.sectionId == eachExamSectionSubjectMap.sectionId &&
            eachTds.subjectId == eachExamSectionSubjectMap.subjectId &&
            eachTds.teacherId == eachExamSectionSubjectMap.authorisedAgent)
        .firstOrNull;
    if (tds == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CustomExamMarksScreen(
        adminProfile: widget.adminProfile,
        teacherProfile: widget.teacherProfile,
        selectedAcademicYearId: widget.selectedAcademicYearId,
        sectionsList: widget.sectionsList,
        teachersList: widget.teachersList,
        tds: tds,
        customExam: widget.customExam,
        studentsList: widget.studentsList,
        examSectionSubjectMap: eachExamSectionSubjectMap,
        loadData: widget.loadData,
      );
    }));
  }

  DataCell dataCellWidget(
    Widget child, {
    bool isCenter = true,
  }) {
    return DataCell(
      clayCell(isCenter, child),
    );
  }

  Container clayCell(bool isCenter, Widget child) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: double.infinity,
      height: double.infinity,
      child: isCenter
          ? Center(child: child)
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                child,
              ],
            ),
    );
  }

  Widget customExamNameWidget() {
    if (!_isExpanded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(widget.customExam.customExamName ?? "-")),
          const SizedBox(width: 15),
          Text(widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull?.algorithmName ?? "-"),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 30,
              width: 30,
              borderRadius: 50,
              surfaceColor: clayContainerColor(context),
              spread: 1,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(widget.customExam.customExamName ?? "-")),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = false;
                });
              },
              child: ClayButton(
                color: clayContainerColor(context),
                height: 30,
                width: 30,
                borderRadius: 50,
                surfaceColor: clayContainerColor(context),
                spread: 1,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(Icons.arrow_drop_up),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        if (widget.selectedSection != null) const SizedBox(height: 30),
        if (widget.selectedSection != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.markingAlgorithms
                      .where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId)
                      .firstOrNull
                      ?.algorithmName ??
                      "-",
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Marking Algorithm",
                    hintText: "Marking Algorithm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Tooltip(
                    message: "Update Marks",
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return CustomExamsAllMarksScreen(
                            schoolInfo: widget.schoolInfo,
                            adminProfile: widget.adminProfile,
                            teacherProfile: widget.teacherProfile,
                            selectedAcademicYearId: widget.selectedAcademicYearId,
                            sectionsList: widget.sectionsList,
                            teachersList: widget.teachersList,
                            subjectsList: widget.subjectsList,
                            tdsList: widget.tdsList,
                            customExam: widget.customExam,
                            selectedSection: widget.selectedSection!,
                            loadData: widget.loadData,
                            studentsList: widget.studentsList,
                            markingAlgorithm: widget.customExam.markingAlgorithmId == null
                                ? null
                                : widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull,
                          );
                        })).then((_) => widget.loadData());
                      },
                      child: ClayButton(
                        color: clayContainerColor(context),
                        height: 50,
                        borderRadius: 50,
                        surfaceColor: clayContainerColor(context),
                        spread: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.score_outlined),
                                SizedBox(width: 10),
                                Text("Update Marks"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
