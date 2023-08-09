import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/edit_custom_exams_widget.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class CustomExamWidget extends StatefulWidget {
  const CustomExamWidget({
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
    required this.editingEnabled,
    required this.selectedSection,
    required this.markingAlgorithms,
  }) : super(key: key);

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
  final bool editingEnabled;
  final Section? selectedSection;
  final List<MarkingAlgorithmBean> markingAlgorithms;

  @override
  State<CustomExamWidget> createState() => _CustomExamWidgetState();
}

class _CustomExamWidgetState extends State<CustomExamWidget> {
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
        emboss: false,
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
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        emboss: true,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          width: double.infinity,
          child: Scrollbar(
            thumbVisibility: true,
            controller: _controller,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: [
                    "Section",
                    "Subject",
                    "Teacher",
                    "Avg Marks",
                    "Max Marks",
                    "Date",
                    "Start Time",
                    "End Time",
                  ].map((e) => DataColumn(label: Center(child: Text(e)))).toList(),
                  rows: [
                    ...examSectionSubjectMapList.where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId).map(
                          (eachExamSectionSubjectMap) => DataRow(
                            onSelectChanged: (bool? selected) {
                              if (selected ?? false) {
                                goToMarksScreen(eachExamSectionSubjectMap);
                              }
                            },
                            cells: [
                              dataCellWidget(
                                InkWell(
                                  onTap: () => goToMarksScreen(eachExamSectionSubjectMap),
                                  child: Text(
                                    widget.sectionsList.firstWhere((e) => e.sectionId == eachExamSectionSubjectMap.sectionId).sectionName ?? "-",
                                  ),
                                ),
                              ),
                              dataCellWidget(
                                Text(
                                  tdsList.firstWhere((e) => e.subjectId == eachExamSectionSubjectMap.subjectId).subjectName ?? "-",
                                ),
                                isCenter: false,
                              ),
                              dataCellWidget(
                                Text(
                                  tdsList.firstWhere((e) => e.teacherId == eachExamSectionSubjectMap.authorisedAgent).teacherName ?? "-",
                                ),
                                isCenter: false,
                              ),
                              dataCellWidget(
                                Text("${eachExamSectionSubjectMap.classAverage ?? " - "}"),
                              ),
                              dataCellWidget(
                                Text("${eachExamSectionSubjectMap.maxMarks ?? " - "}"),
                              ),
                              dataCellWidget(Text(eachExamSectionSubjectMap.examDate)),
                              dataCellWidget(Text(eachExamSectionSubjectMap.startTimeSlot)),
                              dataCellWidget(Text(eachExamSectionSubjectMap.endTimeSlot)),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
      Container(
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
          // const SizedBox(width: 15),
          // Text(widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull?.algorithmName ?? "-"),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(widget.customExam.customExamName ?? "-")),
        const SizedBox(width: 15),
        Text(widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull?.algorithmName ?? "-"),
        if (widget.editingEnabled) const SizedBox(width: 15),
        if (widget.editingEnabled)
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EditCustomExamWidget(
                  adminProfile: widget.adminProfile,
                  teacherProfile: widget.teacherProfile,
                  selectedAcademicYearId: widget.selectedAcademicYearId,
                  sectionsList: widget.sectionsList,
                  teachersList: widget.teachersList,
                  tdsList: widget.tdsList,
                  markingAlgorithms: widget.markingAlgorithms,
                  customExam: widget.customExam,
                );
              })).then((_) => widget.loadData());
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
                  child: Icon(Icons.edit),
                ),
              ),
            ),
          ),
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
    );
  }
}
