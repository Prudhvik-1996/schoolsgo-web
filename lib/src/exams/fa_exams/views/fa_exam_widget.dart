import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_cumulative_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/edit_fa_exam_widget.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class FAExamWidget extends StatefulWidget {
  const FAExamWidget({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.faExam,
    required this.studentsList,
    required this.loadData,
    required this.editingEnabled,
    required this.selectedSection,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final FAExam faExam;
  final List<StudentProfile> studentsList;
  final Future<void> Function() loadData;
  final bool editingEnabled;
  final Section? selectedSection;

  @override
  State<FAExamWidget> createState() => _FAExamWidgetState();
}

class _FAExamWidgetState extends State<FAExamWidget> {
  List<FaInternalExam> internals = [];
  List<ExamSectionSubjectMap> examSectionSubjectMapList = [];
  List<TeacherDealingSection> tdsList = [];

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    internals = (widget.faExam.faInternalExams ?? []).map((e) => e!).toList();
    examSectionSubjectMapList = internals.map((e) => (e.examSectionSubjectMapList ?? [])).expand((i) => i).map((e) => e!).toList();
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
              faExamNameWidget(),
              if (_isExpanded) const SizedBox(height: 15),
              if (_isExpanded) ...populatedTdsLists(),
              if (_isExpanded) const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> populatedTdsLists() {
    List<Widget> widgetsOfEachInternal = [];
    for (FaInternalExam eachInternal in internals) {
      ScrollController controller = ScrollController();
      List<ExamSectionSubjectMap> essmListForInternal =
          examSectionSubjectMapList.where((e) => e.examId == eachInternal.faInternalExamId && e.masterExamId == eachInternal.masterExamId).toList();
      widgetsOfEachInternal.add(Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eachInternal.faInternalExamName ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: controller,
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
                          ...essmListForInternal.where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId).map(
                                (eachExamSectionSubjectMap) => DataRow(
                                  onSelectChanged: (bool? selected) {
                                    if (selected ?? false) {
                                      goToMarksScreen(eachInternal, eachExamSectionSubjectMap);
                                    }
                                  },
                                  cells: [
                                    dataCellWidget(
                                      InkWell(
                                        onTap: () => goToMarksScreen(eachInternal, eachExamSectionSubjectMap),
                                        child: Text(
                                          widget.sectionsList.firstWhere((e) => e.sectionId == eachExamSectionSubjectMap.sectionId).sectionName ??
                                              "-",
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
              ],
            ),
          ),
        ),
      ));
    }
    return widgetsOfEachInternal;
  }

  void goToMarksScreen(FaInternalExam internal, ExamSectionSubjectMap eachExamSectionSubjectMap) {
    TeacherDealingSection? tds = widget.tdsList
        .where((eachTds) =>
            eachTds.sectionId == eachExamSectionSubjectMap.sectionId &&
            eachTds.subjectId == eachExamSectionSubjectMap.subjectId &&
            eachTds.teacherId == eachExamSectionSubjectMap.authorisedAgent)
        .firstOrNull;
    if (tds == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FAExamMarksScreen(
        adminProfile: widget.adminProfile,
        teacherProfile: widget.teacherProfile,
        selectedAcademicYearId: widget.selectedAcademicYearId,
        sectionsList: widget.sectionsList,
        teachersList: widget.teachersList,
        tds: tds,
        faExam: widget.faExam,
        faInternalExam: internal,
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

  Widget faExamNameWidget() {
    if (!_isExpanded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(widget.faExam.faExamName ?? "-")),
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
        Expanded(
          child: Text(
            widget.faExam.faExamName ?? "-",
            style: TextStyle(
              fontSize: _isExpanded ? 21 : null,
              fontWeight: _isExpanded ? FontWeight.bold : null,
            ),
          ),
        ),
        if (widget.selectedSection != null) const SizedBox(width: 15),
        if (widget.selectedSection != null)
          Tooltip(
            message: "Update Marks",
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FaCumulativeExamMarksScreen(
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    sectionsList: widget.sectionsList,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    faExam: widget.faExam,
                    selectedSection: widget.selectedSection!,
                    loadData: widget.loadData,
                    studentsList: widget.studentsList,
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
                    child: Icon(Icons.score_outlined),
                  ),
                ),
              ),
            ),
          ),
        if (widget.editingEnabled) const SizedBox(width: 15),
        if (widget.editingEnabled)
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EditFAExamWidget(
                  adminProfile: widget.adminProfile,
                  teacherProfile: widget.teacherProfile,
                  selectedAcademicYearId: widget.selectedAcademicYearId,
                  sectionsList: widget.sectionsList,
                  teachersList: widget.teachersList,
                  tdsList: widget.tdsList,
                  faExam: widget.faExam,
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
