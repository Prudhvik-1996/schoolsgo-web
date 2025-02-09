import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/generate_memos/generate_memos.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:schoolsgo_web/src/exams/student/student_memo_screen.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentExamSummaryWidget extends StatefulWidget {
  const StudentExamSummaryWidget({
    Key? key,
    required this.adminProfile,
    required this.studentProfile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final StudentProfile studentProfile;

  @override
  State<StudentExamSummaryWidget> createState() => _StudentExamSummaryWidgetState();
}

class _StudentExamSummaryWidgetState extends State<StudentExamSummaryWidget> {
  bool _isLoading = true;
  bool canShowExamsSummary = false;
  List<Subject> subjectsList = [];
  List<CustomExam> exams = [];
  final double columnSpacing = 3;
  final double rowHeight = 45;
  final double columnWidth = 90;

  @override
  void initState() {
    _loadExamSummaryReport();
  }

  Future<void> _loadExamSummaryReport() async {
    setState(() => _isLoading = true);
    GetSubjectsRequest getSubjectsRequest = GetSubjectsRequest(
      schoolId: widget.studentProfile.schoolId,
    );
    GetSubjectsResponse getSubjectsResponse = await getSubjects(getSubjectsRequest);
    if (getSubjectsResponse.httpStatus != "OK" || getSubjectsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
    }
    GetCustomExamsForStudentsSummaryResponse getCustomExamsForStudentsSummaryResponse = await getExamsForStudentsSummary(GenerateStudentMemosRequest(
      sectionId: widget.studentProfile.sectionId,
      studentIds: [widget.studentProfile.studentId],
      schoolId: widget.studentProfile.schoolId,
    ));
    if (getCustomExamsForStudentsSummaryResponse.httpStatus != "OK" || getCustomExamsForStudentsSummaryResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      exams = (getCustomExamsForStudentsSummaryResponse.mainExams ?? []).where((e) => e != null).map((e) => e!).toList();
      canShowExamsSummary = exams.isNotEmpty;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const EpsilonDiaryLoadingWidget(defaultLoadingText: "Loading exams");
    }
    if (exams.isEmpty) return Container();
    List<int> subjectIdsToShow =
        exams.map((e) => (e.examSectionSubjectMapList ?? []).map((e) => e?.subjectId)).expand((i) => i).whereNotNull().toSet().toList();
    List<Subject> subjectsToShow = subjectsList.where((e) => subjectIdsToShow.contains(e.subjectId)).toList();
    subjectsToShow.sort(
      (a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0),
    );

    List<String> examNames = exams.map((e) => (e.customExamName ?? "-").capitalize()).toList();
    List<String> subjectNamesToShow = subjectsToShow.map((e) => (e.subjectName ?? "-").capitalize()).toList();

    List<List<ExamSectionSubjectMap?>> subjectWiseExamWiseEssm = [];
    for (Subject eachSubject in subjectsToShow) {
      List<ExamSectionSubjectMap?> subjectWiseEssms = [];
      for (CustomExam eachExam in exams) {
        ExamSectionSubjectMap? eachEssm = (eachExam.examSectionSubjectMapList ?? []).firstWhereOrNull((e) => e?.subjectId == eachSubject.subjectId);
        subjectWiseEssms.add(eachEssm);
      }
      subjectWiseExamWiseEssm.add(subjectWiseEssms);
    }

    List<List<Widget>> rows = [
      ...subjectsToShow.mapIndexed((index, eachSubject) {
        List<Widget> cells = [];
        cells.add(Center(child: Text(subjectNamesToShow[index])));
        List<ExamSectionSubjectMap?> subjectWiseEssms = subjectWiseExamWiseEssm[index];
        for (ExamSectionSubjectMap? eachEssm in subjectWiseEssms) {
          if (eachEssm == null || (eachEssm.maxMarks ?? 0) <= 0) {
            cells.add(const Center(child: Text("-")));
            continue;
          }
          StudentExamMarks? studentExamMarks = (eachEssm.studentExamMarksList ?? []).firstOrNull;
          if (studentExamMarks == null) {
            cells.add(const Center(child: Text("-")));
            continue;
          }
          cells.add(Center(child: Text(studentExamMarks.isAbsent == 'N' ? "Absent" : "${studentExamMarks.getMarksObtained()}/${eachEssm.maxMarks}")));
        }
        return cells;
      })
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: clayDataTable(
        ScrollController(),
        columnSpacing,
        rowHeight,
        columnWidth,
        ["Subject", ...examNames.map((e) => e.split(" ").map((e) => e[0]).join())],
        rows,
        columnsTooltips: ["Subject", ...examNames].map((e) => e).toList(),
      ),
    );
  }

  Scrollbar clayDataTable(
    ScrollController horizontalScrollController,
    double columnSpacing,
    double rowHeight,
    double columnWidth,
    List<String> columns,
    List<List<Widget>> rows, {
    List<Widget> graphRow = const [],
    List<String>? columnsTooltips,
  }) {
    columnsTooltips ??= columns;
    return Scrollbar(
      thumbVisibility: true,
      thickness: 8,
      controller: horizontalScrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalScrollController,
        child: SingleChildScrollView(
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: DataTable(
              horizontalMargin: 0,
              dividerThickness: 0,
              columnSpacing: columnSpacing,
              dataRowHeight: rowHeight + 2 * columnSpacing,
              headingRowHeight: rowHeight + 2 * columnSpacing,
              columns: columns
                  .mapIndexed(
                    (i, e) => DataColumn(
                      label: clayCellWithMemoButton(
                        i == 0
                            ? const Text("")
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return StudentMemoScreen(
                                          studentProfile: widget.studentProfile,
                                          adminProfile: widget.adminProfile,
                                          exam: exams[i-1],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: ClayButton(
                                      depth: 40,
                                      parentColor: clayContainerColor(context),
                                      surfaceColor: clayContainerColor(context),
                                      spread: 1,
                                      borderRadius: 100,
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        child: const Icon(Icons.download),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        text: e,
                        height: rowHeight,
                        width: columnWidth,
                        tooltipText: columnsTooltips![i],
                      ),
                    ),
                  )
                  .toList(),
              rows: [
                ...rows.map((e) => DataRow(cells: e.map((e) => DataCell(clayCell(child: e, height: rowHeight, width: columnWidth))).toList())),
                if (graphRow.isNotEmpty)
                  DataRow(
                    cells: graphRow
                        .map(
                          (e) => DataCell(
                            clayCell(
                              child: e,
                              height: rowHeight,
                              width: columnWidth,
                              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget clayCellWithMemoButton(
    Widget memoButton, {
    String? text,
    Widget? child,
    EdgeInsetsGeometry margin = const EdgeInsets.all(2),
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
    bool emboss = true,
    TextStyle textStyle = const TextStyle(fontSize: 12),
    double height = 45,
    double width = 90,
    TextAlign alignment = TextAlign.center,
    String? tooltipText,
  }) {
    return Container(
      margin: margin,
      child: text != null
          ? Tooltip(
              message: tooltipText ?? text,
              child: clayCellClayChildAndButton(memoButton, emboss, height, width, padding, text, alignment, child),
            )
          : clayCellClayChildAndButton(memoButton, emboss, height, width, padding, text, alignment, child),
    );
  }

  ClayContainer clayCellClayChildAndButton(
    Widget memoButton,
    bool emboss,
    double height,
    double width,
    EdgeInsetsGeometry padding,
    String? text,
    TextAlign alignment,
    Widget? child,
  ) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 5,
      emboss: emboss,
      height: height,
      width: width,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(child: text != null ? clayCellChild(text, alignment: alignment) : child!),
            memoButton,
          ],
        ),
      ),
    );
  }

  Widget clayCell({
    String? text,
    Widget? child,
    EdgeInsetsGeometry margin = const EdgeInsets.all(2),
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
    bool emboss = true,
    TextStyle textStyle = const TextStyle(fontSize: 12),
    double height = 45,
    double width = 90,
    TextAlign alignment = TextAlign.center,
    String? tooltipText,
  }) {
    return Container(
      margin: margin,
      child: text != null
          ? Tooltip(
              message: tooltipText ?? text,
              child: clayCellClayChild(emboss, height, width, padding, text, alignment, child),
            )
          : clayCellClayChild(emboss, height, width, padding, text, alignment, child),
    );
  }

  ClayContainer clayCellClayChild(
      bool emboss, double height, double width, EdgeInsetsGeometry padding, String? text, TextAlign alignment, Widget? child) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 5,
      emboss: emboss,
      height: height,
      width: width,
      child: Padding(
        padding: padding,
        child: text != null ? clayCellChild(text, alignment: alignment) : child!,
      ),
    );
  }

  Widget clayCellChild(
    String text, {
    TextAlign alignment = TextAlign.center,
  }) {
    return Center(
      child: AutoSizeText(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        minFontSize: 7,
        maxFontSize: 12,
        softWrap: true,
        textAlign: alignment,
      ),
    );
  }
}
