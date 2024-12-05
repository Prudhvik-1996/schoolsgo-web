import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/populate_inter_exam_marks/populate_internal_exam_marks_widget.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/each_marks_cell_widget.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/each_student_memo_view.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/fa_exams_all_students_marks_excel_template.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/section_wise_marks_list_pdf.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class FaCumulativeExamMarksScreen extends StatefulWidget {
  const FaCumulativeExamMarksScreen({
    super.key,
    required this.schoolInfo,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.markingAlgorithm,
    required this.faExam,
    required this.selectedSection,
    required this.studentsList,
    required this.loadData,
    required this.isClassTeacher,
  });

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final MarkingAlgorithmBean? markingAlgorithm;
  final FAExam faExam;
  final Section selectedSection;
  final List<StudentProfile> studentsList;
  final Future<void> Function() loadData;
  final bool isClassTeacher;

  @override
  State<FaCumulativeExamMarksScreen> createState() => _FaCumulativeExamMarksScreenState();
}

class _FaCumulativeExamMarksScreenState extends State<FaCumulativeExamMarksScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _showInfo = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentProfile> studentsList = [];

  Map<int, List<StudentExamMarks>> examMarks = {};

  FocusScopeNode tableFocusScope = FocusScopeNode();

  StudentExamMarks? editingCell;

  late FAExam faExam;
  bool showPopulateInternalMarksWidget = false;

  @override
  void initState() {
    super.initState();
    faExam = widget.faExam;
    (faExam.faInternalExams ?? []).whereNotNull().forEach(
        (eachInternal) => eachInternal.examSectionSubjectMapList?.removeWhere((essm) => essm?.sectionId != widget.selectedSection.sectionId));
    _loadData();
  }

  Future<void> _loadData({bool loadCurrentExam = false}) async {
    setState(() => _isLoading = true);
    if (loadCurrentExam) {
      await _loadCurrentExam();
    }
    setState(() {
      studentsList = <StudentProfile>{
        ...widget.studentsList.where((e) => e.sectionId == widget.selectedSection.sectionId),
        ...widget.studentsList.where((e) => (faExam.faInternalExams ?? [])
            .map((e) => e?.examSectionSubjectMapList ?? [])
            .expand((i) => i)
            .whereNotNull()
            .map((e) => e.studentExamMarksList ?? [])
            .expand((i) => i)
            .whereNotNull()
            .map((e) => e.studentId)
            .contains(e.studentId))
      }.toList();
      studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      for (StudentProfile eachStudent in studentsList) {
        for (FaInternalExam eachInternal in (faExam.faInternalExams ?? []).whereNotNull()) {
          for (ExamSectionSubjectMap examSectionSubjectMap in (eachInternal.examSectionSubjectMapList ?? []).whereNotNull()) {
            examMarks[examSectionSubjectMap.examSectionSubjectMapId!] ??= [];
            if ((examSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.studentId == eachStudent.studentId).isNotEmpty) {
              examMarks[examSectionSubjectMap.examSectionSubjectMapId!]!
                  .add((examSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.studentId == eachStudent.studentId).first!);
            } else {
              examMarks[examSectionSubjectMap.examSectionSubjectMapId!]!.add(StudentExamMarks(
                examSectionSubjectMapId: examSectionSubjectMap.examSectionSubjectMapId,
                examId: examSectionSubjectMap.examId,
                agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                comment: null,
                studentId: eachStudent.studentId,
                marksObtained: null,
                marksId: null,
                studentExamMediaBeans: [],
              ));
            }
          }
        }
      }
    });

    setState(() => _isLoading = false);
  }

  Future<void> _loadCurrentExam() async {
    setState(() => _isLoading = true);
    GetFAExamsResponse getFAExamsResponse = await getFAExams(GetFAExamsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      faExamId: faExam.faExamId,
    ));
    if (getFAExamsResponse.httpStatus != "OK" || getFAExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      faExam = (getFAExamsResponse.exams ?? []).map((e) => e!).toList()[0];
    }
    setState(() => _isLoading = false);
  }

  void _handleArrowKeyNavigation(RawKeyDownEvent event, StudentExamMarks eachStudentExamMarks) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      try {
        setState(() => editingCell = examMarks[eachStudentExamMarks.examSectionSubjectMapId!]![
            examMarks[eachStudentExamMarks.examSectionSubjectMapId!]!.indexWhere((esm) => esm.studentId == eachStudentExamMarks.studentId) - 1]);
      } catch (_) {
        // debugPrint("Tried crossing bounds");
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      try {
        setState(() => editingCell = examMarks[eachStudentExamMarks.examSectionSubjectMapId!]![
            examMarks[eachStudentExamMarks.examSectionSubjectMapId!]!.indexWhere((esm) => esm.studentId == eachStudentExamMarks.studentId) + 1]);
      } catch (_) {
        // debugPrint("Tried crossing bounds");
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      try {
        setState(() => editingCell = examMarks[examMarks.keys.toList()[
                examMarks.keys.toList().indexWhere((e) => e == eachStudentExamMarks.examSectionSubjectMapId) -
                    (faExam.faInternalExams?.firstWhere((ei) => ei?.faInternalExamId == eachStudentExamMarks.examId)?.examSectionSubjectMapList ?? [])
                        .length]]!
            .firstWhere((e) => e.studentId == eachStudentExamMarks.studentId));
      } catch (_) {
        // debugPrint("Tried crossing bounds");
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      try {
        setState(() => editingCell = examMarks[examMarks.keys.toList()[
                examMarks.keys.toList().indexWhere((e) => e == eachStudentExamMarks.examSectionSubjectMapId) +
                    (faExam.faInternalExams?.firstWhere((ei) => ei?.faInternalExamId == eachStudentExamMarks.examId)?.examSectionSubjectMapList ?? [])
                        .length]]!
            .firstWhere((e) => e.studentId == eachStudentExamMarks.studentId));
      } catch (_) {
        // debugPrint("Tried crossing bounds");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(faExam.faExamName ?? " - "),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.info_outline),
          //   onPressed: () => setState(() => _showInfo = !_showInfo),
          // ),
          if (!_isLoading)
            IconButton(
              icon: _isEditMode ? const Icon(Icons.save) : const Icon(Icons.edit),
              onPressed: () async {
                if (_isEditMode) {
                  await saveChangesAlert(context);
                } else {
                  setState(() {
                    _showInfo = false;
                    _isEditMode = true;
                  });
                }
              },
            ),
          if (!_isLoading && showPopulateInternalMarksWidget)
            Tooltip(
              message: "Cancel",
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  setState(() => showPopulateInternalMarksWidget = false);
                },
              ),
            ),
          if (!_isLoading && !_isEditMode)
            Tooltip(
              message: "Download report",
              child: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await SectionWiseMarkListPdf(
                    schoolInfo: widget.schoolInfo,
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    sectionsList: widget.sectionsList,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    tdsList: widget.tdsList,
                    markingAlgorithm: widget.markingAlgorithm,
                    faExam: faExam,
                    studentsList: widget.studentsList,
                    selectedSection: widget.selectedSection,
                  ).downloadAsPdf();
                  setState(() => _isLoading = false);
                },
              ),
            ),
          if (!_isLoading && _isEditMode)
            PopupMenuButton<String>(
              tooltip: "Templates",
              onSelected: (String choice) async {
                if (choice == "Download Template") {
                  setState(() => _isLoading = true);
                  await FAExamsAllStudentsMarksExcel(
                    schoolInfo: widget.schoolInfo,
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    sectionsList: widget.sectionsList,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    tdsList: widget.tdsList,
                    markingAlgorithm: widget.markingAlgorithm,
                    faExam: faExam,
                    studentsList: widget.studentsList,
                    selectedSection: widget.selectedSection,
                    examMarks: examMarks,
                  ).downloadTemplate();
                  setState(() => _isLoading = false);
                } else if (choice == "Upload From Template") {
                  setState(() => _isLoading = true);
                  FAExamsAllStudentsMarksExcel faExamsAllStudentsMarksExcel = FAExamsAllStudentsMarksExcel(
                    schoolInfo: widget.schoolInfo,
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    sectionsList: widget.sectionsList,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    tdsList: widget.tdsList,
                    markingAlgorithm: widget.markingAlgorithm,
                    faExam: faExam,
                    studentsList: widget.studentsList,
                    selectedSection: widget.selectedSection,
                    examMarks: examMarks,
                  );
                  Excel? excel = await faExamsAllStudentsMarksExcel.readAndValidateExcel();
                  if (excel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invalid format! Try again later.."),
                      ),
                    );
                    return;
                  }
                  faExamsAllStudentsMarksExcel.readExamMarks(excel);
                  setState(() => _isLoading = false);
                  await saveChangesAlert(context);
                } else if (choice == "Populate Internal Marks") {
                  setState(() => showPopulateInternalMarksWidget = true);
                } else {
                  // debugPrint("Invalid choice");
                }
              },
              itemBuilder: (BuildContext context) {
                return {
                  "Download Template",
                  "Upload From Template",
                  if (widget.adminProfile != null) "Populate Internal Marks",
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : showPopulateInternalMarksWidget
              ? PopulateInternalExamMarksWidget(
                  faExam: faExam,
                  adminProfile: widget.adminProfile!,
                  loadData: () {
                    Navigator.pop(context);
                  },
                  selectedSectionId: widget.selectedSection.sectionId!,
                  scaffoldKey: scaffoldKey,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: stickyHeaderTable()),
                  ],
                ),
    );
  }

  Future<void> saveChangesAlert(BuildContext context) async {
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(faExam.faExamName ?? " - "),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateExamMarksResponse createOrUpdateExamMarksResponse = await createOrUpdateExamMarks(CreateOrUpdateExamMarksRequest(
                  agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                  examMarks:
                      examMarks.values.expand((i) => i).where((e) => !const DeepCollectionEquality().equals(e.origJson(), e.toJson())).toList(),
                  schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                ));
                if (createOrUpdateExamMarksResponse.httpStatus != "OK" || createOrUpdateExamMarksResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                  return;
                } else {
                  setState(() {
                    widget.loadData();
                  });
                }
                setState(() {
                  _isEditMode = false;
                  _isLoading = false;
                });
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _loadData();
                setState(() => _isEditMode = false);
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget stickyHeaderTable() {
    double marksObtainedCellWidth = 150;
    double legendCellWidth = MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 150;
    double defaultCellHeight = 80;
    List<Subject> subjectsList = widget.subjectsList..sort((a, b) => (a.seqOrder ?? 0).compareTo((b.seqOrder ?? 0)));
    List<ExamSectionSubjectMap?> essmList = [];
    List<String> headerStrings = [];
    for (Subject eachSubject in subjectsList) {
      List<ExamSectionSubjectMap?> subjectWiseEssmList = [];
      List<String> subjectWiseHeaderStrings = [];
      (faExam.faInternalExams ?? []).whereNotNull().forEach((eachInternal) {
        var x = (eachInternal.examSectionSubjectMapList ?? [])
            .where((essm) =>
                essm?.subjectId == eachSubject.subjectId &&
                essm?.sectionId == widget.selectedSection.sectionId &&
                (widget.teacherProfile == null || widget.isClassTeacher || widget.teacherProfile?.teacherId == essm?.authorisedAgent))
            .firstOrNull;
        // print("356:\n${x?.toJson()}\n${eachSubject.toJson()}\n");
        subjectWiseEssmList.add(x);
        if (x != null) {
          subjectWiseHeaderStrings.add("${eachSubject.subjectName}|${eachInternal.faInternalExamName ?? "-"}");
        }
      });
      essmList.addAll(subjectWiseEssmList);
      headerStrings.addAll(subjectWiseHeaderStrings);
      // if (subjectWiseHeaderStrings.isNotEmpty) {
      //   headerStrings.add("${eachSubject.subjectName}\nTotal");
      //   essmList.add(ExamSectionSubjectMap(
      //     subjectId: eachSubject.subjectId,
      //   ));
      // }
    }
    return Container(
      margin: const EdgeInsets.all(15),
      child: clayCell(
        child: StickyHeadersTable(
          cellDimensions: CellDimensions.variableColumnWidth(
            columnWidths: [...headerStrings.map((e) => marksObtainedCellWidth)],
            contentCellHeight: defaultCellHeight,
            stickyLegendWidth: legendCellWidth,
            stickyLegendHeight: defaultCellHeight,
          ),
          showHorizontalScrollbar: true,
          showVerticalScrollbar: true,
          columnsLength: headerStrings.length,
          rowsLength: studentsList.length,
          legendCell: clayCell(
            child: const Center(
              child: Text(
                "Student",
                style: TextStyle(fontSize: 12),
              ),
            ),
            emboss: true,
          ),
          rowsTitleBuilder: (int rowIndex) => Stack(
            children: [
              clayCell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text("${studentsList[rowIndex].rollNumber ?? "-"}. ${studentsList[rowIndex].studentFirstName ?? "-"}"),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                emboss: true,
              ),
              if (!_isEditMode)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EachStudentMemoView(
                                schoolInfo: widget.schoolInfo,
                                adminProfile: widget.adminProfile,
                                teacherProfile: widget.teacherProfile,
                                selectedAcademicYearId: widget.selectedAcademicYearId,
                                teachersList: widget.teachersList,
                                subjectsList: widget.subjectsList,
                                tdsList: widget.tdsList,
                                markingAlgorithm: widget.markingAlgorithm,
                                faExam: faExam,
                                studentProfile: studentsList[rowIndex],
                                selectedSection: widget.selectedSection,
                              );
                            },
                          ),
                        );
                      },
                      child: Tooltip(
                        message: "Memo",
                        child: ClayButton(
                          depth: 40,
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          spread: 1,
                          borderRadius: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            width: 20,
                            height: 20,
                            child: const Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Icon(Icons.add_chart),
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
          columnsTitleBuilder: (int colIndex) => columnHeaderBuilder(headerStrings, colIndex),
          contentCellBuilder: (int columnIndex, int rowIndex) {
            int? studentId = studentsList[rowIndex].studentId;
            ExamSectionSubjectMap? essm = essmList.whereNotNull().toList()[columnIndex];
            StudentExamMarks? eachStudentExamMarks =
                (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
            if (essm == null) {
              return clayCell(
                child: const Center(child: Text("N/A")),
                emboss: true,
              );
            } else if (essm.examSectionSubjectMapId == null) {
              int? marksSubjectId = essm.subjectId;
              return clayCell(
                child: Center(
                    child: Text(examMarks.values
                        .expand((i) => i)
                        .where((e) => e.studentId == studentId)
                        .where((eachMarks) {
                          int? eachMarksSubjectId = (faExam.faInternalExams ?? [])
                              .map((e) => e?.examSectionSubjectMapList ?? [])
                              .expand((i) => i)
                              .where((e) => e?.examSectionSubjectMapId == eachMarks.examSectionSubjectMapId)
                              .firstOrNull
                              ?.subjectId;
                          return eachMarksSubjectId == marksSubjectId;
                        })
                        .map((e) => e.isAbsent == 'N' ? 0.0 : e.marksObtained ?? 0.0)
                        .fold<double>(0.0, (double a, double b) => a + b)
                        .toStringAsFixed(2))),
                emboss: true,
              );
            } else {
              return clayCell(
                child: studentMarksObtainedWidget(eachStudentExamMarks!, essm, columnIndex),
                emboss: true,
              );
            }
          },
        ),
      ),
    );
  }

  Widget columnHeaderBuilder(List<String> headerStrings, int columnIndex) {
    return clayCell(
      padding: headerStrings[columnIndex].contains("|") ? EdgeInsets.zero : null,
      child: headerStrings[columnIndex].contains("|")
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                      color: Colors.blue,
                    ),
                    child: Center(child: Text(headerStrings[columnIndex].split("|")[0])),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    ),
                    child: Center(child: Text(headerStrings[columnIndex].split("|")[1])),
                  ),
                ),
              ],
            )
          : headerStrings[columnIndex].contains("\nTotal")
              ? Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.blue,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Center(child: Text(headerStrings[columnIndex].split("\n")[0])),
                      ),
                      Expanded(
                        child: Center(child: Text(headerStrings[columnIndex].split("\n")[1])),
                      ),
                    ],
                  ))
              : Center(
                  child: Text(
                    headerStrings.tryGet(columnIndex) ?? "-",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
      emboss: true,
    );
  }

  Widget studentMarksObtainedWidget(StudentExamMarks eachStudentExamMarks, ExamSectionSubjectMap? essm, int colIndex) {
    if (essm == null) {
      return const Center(child: Text("-"));
    }
    int studentId = eachStudentExamMarks.studentId!;
    var essmIdIndex = examMarks.keys.toList().indexWhere((e) => e == essm.examSectionSubjectMapId);
    if (_isEditMode) {
      if (editingCell == eachStudentExamMarks) {
        // print("369: $studentId, $essmIdIndex");
        return EachMarksCellWidget(
          studentId: studentId,
          essmIdIndex: essmIdIndex,
          eachStudentExamMarks: eachStudentExamMarks,
          examSectionSubjectMap: essm,
          handleArrowKeyNavigation: _handleArrowKeyNavigation,
          setState: setState,
        );
      } else {
        return InkWell(
          onTap: () => setState(() => editingCell = eachStudentExamMarks),
          child: Center(
            child: Text(eachStudentExamMarks.isAbsent == 'N' ? "Absent" : "${eachStudentExamMarks.marksObtained ?? ""}"),
          ),
        );
      }
    }
    return Center(
      child: Text(eachStudentExamMarks.isAbsent == 'N' ? "Absent" : "${eachStudentExamMarks.marksObtained ?? ""}"),
    );
  }

  Widget clayCell({
    Widget? child,
    EdgeInsetsGeometry? margin = const EdgeInsets.all(4),
    EdgeInsetsGeometry? padding = const EdgeInsets.all(8),
    bool emboss = false,
    double height = double.infinity,
    double width = double.infinity,
  }) {
    return Container(
      margin: margin,
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: emboss,
        child: Container(
          padding: padding,
          height: height,
          width: width,
          child: child,
        ),
      ),
    );
  }

  Widget examHeaderWidget() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayButton(
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      faExam.faExamName ?? " - ",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
