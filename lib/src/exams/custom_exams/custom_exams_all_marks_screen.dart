import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/each_marks_cell_widget.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/custom_exams_all_students_marks_excel_template.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/each_student_memo_view.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/section_wise_marks_list_pdf.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class CustomExamsAllMarksScreen extends StatefulWidget {
  const CustomExamsAllMarksScreen({
    Key? key,
    required this.schoolInfo,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.markingAlgorithm,
    required this.customExam,
    required this.studentsList,
    required this.selectedSection,
    required this.examMemoHeader,
    required this.loadData,
  }) : super(key: key);

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final MarkingAlgorithmBean? markingAlgorithm;
  final CustomExam customExam;
  final List<StudentProfile> studentsList;
  final Section selectedSection;
  final String? examMemoHeader;
  final Future<void> Function() loadData;

  @override
  State<CustomExamsAllMarksScreen> createState() => _CustomExamsAllMarksScreenState();
}

class _CustomExamsAllMarksScreenState extends State<CustomExamsAllMarksScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _showInfo = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentProfile> studentsList = [];
  Map<int, List<StudentExamMarks>> examMarks = {};

  StudentExamMarks? editingCell;

  @override
  void initState() {
    super.initState();
    (widget.customExam.examSectionSubjectMapList ?? []).removeWhere((e) => e?.sectionId != widget.selectedSection.sectionId);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    setState(() {
      studentsList = <StudentProfile>{
        ...widget.studentsList.where((e) => e.sectionId == widget.selectedSection.sectionId),
        ...widget.studentsList.where((e) => (widget.customExam.examSectionSubjectMapList ?? [])
            .whereNotNull()
            .map((e) => e.studentExamMarksList ?? [])
            .expand((i) => i)
            .whereNotNull()
            .map((e) => e.studentId)
            .contains(e.studentId))
      }.toList();
      studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      for (StudentProfile eachStudent in studentsList) {
        for (ExamSectionSubjectMap examSectionSubjectMap in (widget.customExam.examSectionSubjectMapList ?? []).whereNotNull()) {
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
    });

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.customExam.customExamName ?? " - "),
        actions: [
          if (!_isLoading)
            Tooltip(
              message: _isEditMode ? "Save" : "Edit",
              child: IconButton(
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
                    customExam: widget.customExam,
                    studentsList: widget.studentsList,
                    selectedSection: widget.selectedSection,
                    examMemoHeader: widget.examMemoHeader,
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
                  await CustomExamsAllStudentsMarksExcel(
                    schoolInfo: widget.schoolInfo,
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    sectionsList: widget.sectionsList,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    tdsList: widget.tdsList,
                    markingAlgorithm: widget.markingAlgorithm,
                    customExam: widget.customExam,
                    studentsList: widget.studentsList,
                    selectedSection: widget.selectedSection,
                    examMarks: examMarks,
                  ).downloadTemplate();
                  setState(() => _isLoading = false);
                } else if (choice == "Upload From Template") {
                  setState(() => _isLoading = true);
                  CustomExamsAllStudentsMarksExcel customExamsAllStudentsMarksExcel = CustomExamsAllStudentsMarksExcel(
                    schoolInfo: widget.schoolInfo,
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    sectionsList: widget.sectionsList,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    tdsList: widget.tdsList,
                    markingAlgorithm: widget.markingAlgorithm,
                    customExam: widget.customExam,
                    studentsList: widget.studentsList,
                    selectedSection: widget.selectedSection,
                    examMarks: examMarks,
                  );
                  Excel? excel = await customExamsAllStudentsMarksExcel.readAndValidateExcel();
                  if (excel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invalid format! Try again later.."),
                      ),
                    );
                    return;
                  }
                  customExamsAllStudentsMarksExcel.readExamMarks(excel);
                  setState(() => _isLoading = false);
                } else {
                  debugPrint("Invalid choice");
                }
              },
              itemBuilder: (BuildContext context) {
                return {
                  "Download Template",
                  "Upload From Template",
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
          title: Text(widget.customExam.customExamName ?? " - "),
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
    List<Subject> subjectsList = (widget.customExam.examSectionSubjectMapList ?? [])
        .where((essm) => essm?.sectionId == widget.selectedSection.sectionId)
        .map((e) => e?.subjectId)
        .map((eachSubjectId) => widget.subjectsList.where((e) => e.subjectId == eachSubjectId).firstOrNull)
        .whereNotNull()
        .toList();
    List<ExamSectionSubjectMap?> essmList = widget.customExam.examSectionSubjectMapList ?? [];
    List<String> headerStrings = [];
    List<Subject> subjectsForExam = [];
    double totalMaxMarks = 0;
    subjectsList.forEach((es) {
      ExamSectionSubjectMap? essm = essmList.where((essm) => essm?.subjectId == es.subjectId).firstOrNull;
      if (essm != null) {
        subjectsForExam.add(es);
        headerStrings.add("${es.subjectName ?? " - "}\n(${essm.maxMarks})");
        totalMaxMarks += essm.maxMarks ?? 0;
      }
    });
    headerStrings.add("Total|($totalMaxMarks)");
    headerStrings.add("Total|(Percentage %)");
    if (widget.markingAlgorithm?.isGpaAllowed ?? false) {
      headerStrings.add("Total|(GPA)");
    }
    if (widget.markingAlgorithm?.isGradeAllowed ?? false) {
      headerStrings.add("Total|(Grade)");
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
                                customExam: widget.customExam,
                                studentProfile: studentsList[rowIndex],
                                selectedSection: widget.selectedSection,
                                examMemoHeader: widget.examMemoHeader,
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
            if (columnIndex >= essmList.length || headerStrings[columnIndex].contains("Total")) {
              double studentWiseTotalMarks = essmList.map((essm) {
                StudentExamMarks? marks = (examMarks[essm?.examSectionSubjectMapId] ?? []).where((e) => e.studentId == studentId).firstOrNull;
                return marks == null
                    ? 0.0
                    : marks.isAbsent == "N"
                        ? 0.0
                        : marks.marksObtained;
              }).fold<double>(0.0, (double a, double? b) => a + (b ?? 0));
              double percentage = ((studentWiseTotalMarks / totalMaxMarks) * 100);
              if (headerStrings[columnIndex].contains("Percentage")) {
                return clayCell(
                  child: Center(child: Text("${doubleToStringAsFixed(percentage)} %")),
                  emboss: true,
                );
              } else if (headerStrings[columnIndex].contains("GPA")) {
                return clayCell(
                  child: Center(child: Text("${widget.markingAlgorithm?.gpaForPercentage(percentage) ?? "-"}")),
                  emboss: true,
                );
              } else if (headerStrings[columnIndex].contains("Grade")) {
                return clayCell(
                  child: Center(child: Text(widget.markingAlgorithm?.gradeForPercentage(percentage) ?? "-")),
                  emboss: true,
                );
              } else {
                return clayCell(
                  child: Center(child: Text("$studentWiseTotalMarks")),
                  emboss: true,
                );
              }
            }
            ExamSectionSubjectMap? essm = essmList[columnIndex];
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
                          int? eachMarksSubjectId = (widget.customExam.examSectionSubjectMapList ?? [])
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

  Widget studentMarksObtainedWidget(StudentExamMarks eachStudentExamMarks, ExamSectionSubjectMap? essm, int colIndex) {
    if (essm == null) {
      return const Center(child: Text("-"));
    }
    int studentId = eachStudentExamMarks.studentId!;
    var essmIdIndex = examMarks.keys.toList().indexWhere((e) => e == essm.examSectionSubjectMapId);
    if (_isEditMode) {
      if (editingCell == eachStudentExamMarks) {
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

  void _handleArrowKeyNavigation(RawKeyDownEvent event, StudentExamMarks eachStudentExamMarks) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      try {
        setState(() => editingCell = examMarks[eachStudentExamMarks.examSectionSubjectMapId!]![
            examMarks[eachStudentExamMarks.examSectionSubjectMapId!]!.indexWhere((esm) => esm.studentId == eachStudentExamMarks.studentId) - 1]);
      } catch (_) {
        debugPrint("Tried crossing bounds");
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      try {
        setState(() => editingCell = examMarks[eachStudentExamMarks.examSectionSubjectMapId!]![
            examMarks[eachStudentExamMarks.examSectionSubjectMapId!]!.indexWhere((esm) => esm.studentId == eachStudentExamMarks.studentId) + 1]);
      } catch (_) {
        debugPrint("Tried crossing bounds");
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      try {
        List<int?> essmList =
            (widget.customExam.examSectionSubjectMapList ?? []).whereNotNull().map((e) => e.examSectionSubjectMapId).toSet().toList();
        int currentEssmIndex = essmList.indexWhere((e) => e == eachStudentExamMarks.examSectionSubjectMapId!);
        int newIndex = currentEssmIndex - 1;
        setState(() => editingCell = examMarks[essmList[newIndex]]![
            examMarks[eachStudentExamMarks.examSectionSubjectMapId!]!.indexWhere((esm) => esm.studentId == eachStudentExamMarks.studentId)]);
      } catch (_) {
        debugPrint("Tried crossing bounds");
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      try {
        List<int?> essmList =
            (widget.customExam.examSectionSubjectMapList ?? []).whereNotNull().map((e) => e.examSectionSubjectMapId).toSet().toList();
        int currentEssmIndex = essmList.indexWhere((e) => e == eachStudentExamMarks.examSectionSubjectMapId!);
        int newIndex = currentEssmIndex + 1;
        setState(() => editingCell = examMarks[essmList[newIndex]]![
            examMarks[eachStudentExamMarks.examSectionSubjectMapId!]!.indexWhere((esm) => esm.studentId == eachStudentExamMarks.studentId)]);
      } catch (_) {
        debugPrint("Tried crossing bounds");
      }
    }
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
                    textAlign: TextAlign.center,
                  ),
                ),
      emboss: true,
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
}
