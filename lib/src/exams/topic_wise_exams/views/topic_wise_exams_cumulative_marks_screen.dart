import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/exam_topics.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/views/topic_wise_exams_all_students_marks_excel_template.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class TopicWiseExamCumulativeMarksScreen extends StatefulWidget {
  const TopicWiseExamCumulativeMarksScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.tds,
    required this.selectedAcademicYearId,
    required this.studentsList,
    required this.examTopic,
    required this.topicWiseExams,
    required this.updateExamMarks,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final TeacherDealingSection tds;
  final int selectedAcademicYearId;
  final List<StudentProfile> studentsList;
  final ExamTopic examTopic;
  final List<TopicWiseExam> topicWiseExams;
  final Future<void> Function(List<StudentExamMarks> marksList) updateExamMarks;

  @override
  State<TopicWiseExamCumulativeMarksScreen> createState() => _TopicWiseExamCumulativeMarksScreenState();
}

class _TopicWiseExamCumulativeMarksScreenState extends State<TopicWiseExamCumulativeMarksScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _showInfo = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentProfile> studentsList = [];

  List<StudentExamMarks> examMarks = [];

  FocusScopeNode tableFocusScope = FocusScopeNode();
  List<List<FocusNode>> focusNodesMap = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    setState(() {
      studentsList = <StudentProfile>{
        ...widget.studentsList.where((e) => e.sectionId == widget.tds.sectionId),
        ...widget.studentsList.where((e) =>
            (widget.topicWiseExams.map((e) => e.studentExamMarksList ?? []).expand((i) => i) ?? []).map((e) => e?.studentId).contains(e.studentId))
      }.toSet().toList();
      studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      for (StudentProfile eachStudent in studentsList) {
        focusNodesMap.add([]);
        for (TopicWiseExam topicWiseExam in widget.topicWiseExams) {
          StudentExamMarks? actualMarksBean =
              (topicWiseExam.studentExamMarksList ?? []).where((e) => e?.studentId == eachStudent.studentId).firstOrNull;
          if (actualMarksBean != null) {
            examMarks.add(StudentExamMarks.fromJson(actualMarksBean.toJson()));
          } else {
            examMarks.add(StudentExamMarks(
              examSectionSubjectMapId: topicWiseExam.examSectionSubjectMapId,
              examId: topicWiseExam.examId,
              agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
              comment: actualMarksBean?.comment,
              studentId: eachStudent.studentId,
              marksObtained: actualMarksBean?.marksObtained,
              marksId: actualMarksBean?.marksId,
              studentExamMediaBeans: actualMarksBean?.studentExamMediaBeans ?? [],
            ));
          }
          focusNodesMap.last.add(FocusNode());
        }
      }
    });

    setState(() => _isLoading = false);
  }

  Future<void> saveChangesAlert(BuildContext context) async {
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Topic wise exam'),
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
                  examMarks: examMarks.where((e) => !const DeepCollectionEquality().equals(e.origJson(), e.toJson())).toList(),
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
                    widget.updateExamMarks(examMarks);
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

  void _handleArrowKeyNavigation(RawKeyDownEvent event, int rowIndex, int columnIndex) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && rowIndex > 0) {
      FocusScope.of(context).requestFocus(focusNodesMap[rowIndex - 1][columnIndex]);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && rowIndex < studentsList.length - 1) {
      FocusScope.of(context).requestFocus(focusNodesMap[rowIndex + 1][columnIndex]);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && columnIndex > 0) {
      FocusScope.of(context).requestFocus(focusNodesMap[rowIndex][columnIndex - 1]);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && columnIndex < 2) {
      FocusScope.of(context).requestFocus(focusNodesMap[rowIndex][columnIndex + 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("${widget.tds.sectionName} - ${widget.tds.subjectName} - ${widget.tds.teacherName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => setState(() => _showInfo = !_showInfo),
          ),
          Tooltip(
            message: _isEditMode ? "Download Template" : "Download Report",
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                await TopicWiseExamsAllStudentMarksUpdateTemplate(
                  adminProfile: widget.adminProfile,
                  teacherProfile: widget.teacherProfile,
                  tds: widget.tds,
                  selectedAcademicYearId: widget.selectedAcademicYearId,
                  studentsList: studentsList,
                  examTopic: widget.examTopic,
                  topicWiseExams: widget.topicWiseExams,
                  examMarks: examMarks,
                ).downloadTemplate();
              },
            ),
          ),
          if (_isEditMode)
            Tooltip(
              message: "Upload from template",
              child: IconButton(
                icon: const Icon(Icons.upload),
                onPressed: () async {
                  setState(() => _isLoading = true);
                  TopicWiseExamsAllStudentMarksUpdateTemplate template = TopicWiseExamsAllStudentMarksUpdateTemplate(
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    tds: widget.tds,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    studentsList: studentsList,
                    examTopic: widget.examTopic,
                    topicWiseExams: widget.topicWiseExams,
                    examMarks: examMarks,
                  );
                  Excel? validExcel = await template.readAndValidateExcel();
                  if (validExcel == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invalid format! Try again later.."),
                      ),
                    );
                  } else {
                    template.readExamMarks(validExcel);
                  }
                  setState(() => _isLoading = false);
                },
              ),
            ),
          IconButton(
            icon: _isEditMode ? const Icon(Icons.save) : const Icon(Icons.edit),
            onPressed: () async {
              if (_isEditMode) {
                await saveChangesAlert(context);
              } else {
                setState(() => _isEditMode = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showInfo) topicWiseExamHeaderWidget(),
                Expanded(child: stickyHeaderTable()),
              ],
            ),
    );
  }

  Widget stickyHeaderTable() {
    List<String> columnNames = widget.topicWiseExams.map((e) => e.examName ?? "-").toList();
    double marksObtainedCellWidth = 150;
    double legendCellWidth = MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 150;
    double defaultCellHeight = 80;
    return Container(
      margin: const EdgeInsets.all(15),
      child: clayCell(
        child: StickyHeadersTable(
          cellDimensions: CellDimensions.variableColumnWidth(
            columnWidths: columnNames.map((e) => marksObtainedCellWidth).toList(),
            contentCellHeight: defaultCellHeight,
            stickyLegendWidth: legendCellWidth,
            stickyLegendHeight: defaultCellHeight,
          ),
          showHorizontalScrollbar: true,
          showVerticalScrollbar: true,
          columnsLength: columnNames.length,
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
          rowsTitleBuilder: (int rowIndex) => clayCell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text("${studentsList[rowIndex].rollNumber ?? "-"}. ${studentsList[rowIndex].studentFirstName ?? "-"}"),
                ),
              ],
            ),
            emboss: true,
          ),
          columnsTitleBuilder: (int colIndex) => clayCell(
            child: Center(
              child: Text(
                columnNames[colIndex],
                style: const TextStyle(fontSize: 12),
              ),
            ),
            emboss: true,
          ),
          contentCellBuilder: (int columnIndex, int rowIndex) {
            int? studentId = studentsList[rowIndex].studentId;
            StudentExamMarks eachStudentExamMarks =
                examMarks.where((e) => e.studentId == studentId && e.examId == widget.topicWiseExams[columnIndex].examId).first;
            return clayCell(
              child: studentMarksObtainedWidget(eachStudentExamMarks),
              emboss: true,
            );
          },
        ),
      ),
    );
  }

  Widget studentMarksObtainedWidget(StudentExamMarks eachStudentExamMarks) {
    TopicWiseExam? topicWiseExam = widget.topicWiseExams.where((e) => e.examId == eachStudentExamMarks.examId).firstOrNull;
    if (_isEditMode) {
      int rowIndex = studentsList.indexWhere((student) => student.studentId == eachStudentExamMarks.studentId);
      int colIndex = widget.topicWiseExams.indexWhere((e) => e == topicWiseExam);
      FocusNode focusNode = focusNodesMap[rowIndex][colIndex];
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            _handleArrowKeyNavigation(event, rowIndex, colIndex);
          }
        },
        child: Stack(
          children: [
            TextFormField(
              enabled: eachStudentExamMarks.isAbsent != 'N',
              focusNode: focusNode,
              initialValue: "${eachStudentExamMarks.marksObtained ?? ""}",
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    final text = newValue.text;
                    if (text.isEmpty || (double.tryParse(text) != null && double.parse(text) <= (topicWiseExam?.maxMarks ?? 0))) {
                      return newValue;
                    }
                    return oldValue;
                  } catch (e) {
                    debugPrintStack();
                  }
                  return oldValue;
                }),
              ],
              onChanged: (String? newText) => setState(() {
                if ((newText ?? "").trim().isEmpty) {
                  eachStudentExamMarks.marksObtained = null;
                }
                double? newMarks = double.tryParse(newText ?? "");
                if (newMarks != null) {
                  eachStudentExamMarks.marksObtained = newMarks;
                }
              }),
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  setState(() {
                    eachStudentExamMarks.isAbsent = eachStudentExamMarks.isAbsent == null || eachStudentExamMarks.isAbsent == 'P' ? 'N' : 'P';
                  });
                },
                child: Tooltip(
                  message: eachStudentExamMarks.isAbsent == 'N' ? "Mark Present" : "Mark Absent",
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: eachStudentExamMarks.isAbsent == 'N' ? Colors.blue : Colors.grey,
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      width: 15,
                      height: 15,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(eachStudentExamMarks.isAbsent == 'N' ? "P" : "A"),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
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

  Widget topicWiseExamHeaderWidget() {
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
                      widget.examTopic.topicName ?? "-",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Class Average: ${topicWiseAverage()}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  String topicWiseAverage() {
    Iterable<double> marksList = examMarks.map((e) => e.isAbsent == "N" ? 0.0 : e.marksObtained ?? 0.0);
    return marksList.isEmpty ? "-" : ((marksList.average * 100).toInt() / 100.0).toString();
  }
}
