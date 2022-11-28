import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/exams/model/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AdminExamMarksV3Screen extends StatefulWidget {
  const AdminExamMarksV3Screen({
    Key? key,
    required this.adminProfile,
    required this.examBean,
    required this.section,
    required this.teacherId,
    required this.subjectId,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final AdminExamBean examBean;
  final Section section;

  final int? teacherId;
  final int? subjectId;

  @override
  State<AdminExamMarksV3Screen> createState() => _AdminExamMarksV3ScreenState();
}

class _AdminExamMarksV3ScreenState extends State<AdminExamMarksV3Screen> {
  bool _isLoading = true;
  List<StudentExamMarksDetailsBean> studentExamMarksDetailsList = [];

  MarkingAlgorithmBean? markingAlgorithm;
  List<Subject> subjects = [];
  List<StudentProfile> students = [];
  late DataGridController marksDataGridController;
  late MarksDataSource marksDataSource;
  Map<String, double> widthsMap = {};
  List<GridColumn> gridColumns = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    marksDataGridController = DataGridController();

    int? _markingAlgorithmId =
        (widget.examBean.examSectionMapBeanList ?? []).map((e) => e!).where((e) => e.sectionId == widget.section.sectionId!).first.markingAlgorithmId;
    if (_markingAlgorithmId != null) {
      GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await getMarkingAlgorithms(
        GetMarkingAlgorithmsRequest(
          schoolId: widget.adminProfile.schoolId,
          markingAlgorithmId: _markingAlgorithmId,
        ),
      );
      if (getMarkingAlgorithmsResponse.httpStatus == "OK" && getMarkingAlgorithmsResponse.responseStatus == "success") {
        try {
          setState(() {
            markingAlgorithm = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList().first;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Try again later.."),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      }
    }

    GetStudentExamMarksDetailsResponse getStudentExamMarksDetailsResponse = await getStudentExamMarksDetails(GetStudentExamMarksDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
      examId: widget.examBean.examId,
      sectionId: widget.section.sectionId,
    ));
    if (getStudentExamMarksDetailsResponse.httpStatus != "OK" || getStudentExamMarksDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentExamMarksDetailsList = getStudentExamMarksDetailsResponse.studentExamMarksDetailsList!.map((e) => e!).toList();
        subjects = extractSubjects();
        students = extractStudentsList();
      });
    }

    List<ExamMarksRowSource> examMarksCellsDataList = buildExamMarksCellsData();
    buildExamMarksColumns();
    marksDataSource = MarksDataSource(examMarksCellsDataList, context);
    widthsMap = {
      "rno": 150,
      "name": 150,
    };
    Iterable<ExamTdsMapBean> examTdsMapBeans = (widget.examBean.examSectionMapBeanList ?? [])
        .where((e) => e?.sectionId == widget.section.sectionId)
        .map((e) => e?.examTdsMapBeanList ?? [])
        .map((e) => e.where((e) => e != null).map((e) => e!))
        .expand((i) => i);
    for (Subject subject in subjects) {
      List<ExamTdsMapBean> subjectWiseExamTdsMapBeans = examTdsMapBeans.where((e) => e.subjectId == subject.subjectId).toList();
      List<InternalExamTdsMapBean> subjectWiseInternalsExamTdsMapBeans = examTdsMapBeans
          .where((e) => e.subjectId == subject.subjectId)
          .map((e) => (e.internalExamTdsMapBeanList ?? []).map((e) => e!))
          .expand((i) => i)
          .toList();
      for (InternalExamTdsMapBean e in subjectWiseInternalsExamTdsMapBeans) {
        widthsMap[e.internalExamMapTdsId!.toString()] = 150;
      }
      for (ExamTdsMapBean e in subjectWiseExamTdsMapBeans) {
        widthsMap[e.examTdsMapId!.toString()] = 150;
      }
      // TODO + add preview headers
    }

    setState(() => _isLoading = false);
  }

  List<Subject> extractSubjects() => studentExamMarksDetailsList
      .map((e) => Subject(
            subjectId: e.subjectId,
            subjectName: e.subjectName,
            schoolId: widget.adminProfile.schoolId,
          ))
      .toSet()
      .toList();

  List<StudentProfile> extractStudentsList() {
    List<StudentProfile> students = studentExamMarksDetailsList
        .map((e) => StudentProfile(studentId: e.studentId, rollNumber: e.rollNumber, studentFirstName: e.studentName))
        .toSet()
        .toList()
      ..sort((a, b) => (int.tryParse(a.rollNumber!) ?? 0).compareTo((int.tryParse(b.rollNumber!) ?? 0)));
    students = studentExamMarksDetailsList
        .map((e) => StudentProfile(studentId: e.studentId, rollNumber: e.rollNumber, studentFirstName: e.studentName))
        .toSet()
        .toList();
    students.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0)) != 0
        ? (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))
        : (a.studentFirstName ?? "").compareTo(b.studentFirstName ?? ""));
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.examBean.examName ?? "-").capitalize()),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : SfDataGrid(
              source: marksDataSource,
              allowEditing: true,
              selectionMode: SelectionMode.single,
              columnResizeMode: ColumnResizeMode.onResize,
              navigationMode: GridNavigationMode.cell,
              columnWidthMode: ColumnWidthMode.none,
              horizontalScrollController: ScrollController(),
              controller: marksDataGridController,
              frozenColumnsCount: 2,
              frozenRowsCount: 0,
              isScrollbarAlwaysShown: true,
              horizontalScrollPhysics: const AlwaysScrollableScrollPhysics(),
              verticalScrollPhysics: const AlwaysScrollableScrollPhysics(),
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              defaultColumnWidth: 150,
              allowColumnsResizing: true,
              onColumnResizeStart: (ColumnResizeStartDetails details) {
                return true;
              },
              onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                setState(() {
                  widthsMap[details.column.columnName] = details.width;
                  buildExamMarksColumns();
                });
                return true;
              },
              stackedHeaderRows: buildExamMarksStackedHeadersRow(),
              columns: gridColumns,
            ),
    );
  }

  List<StackedHeaderRow> buildExamMarksStackedHeadersRow() {
    List<StackedHeaderCell> headerCells = [];
    Iterable<ExamTdsMapBean> examTdsMapBeans = (widget.examBean.examSectionMapBeanList ?? [])
        .where((e) => e?.sectionId == widget.section.sectionId)
        .map((e) => e?.examTdsMapBeanList ?? [])
        .map((e) => e.where((e) => e != null).map((e) => e!))
        .expand((i) => i);
    for (Subject subject in subjects) {
      List<String> subjectWiseExamTdsMapBeans =
          examTdsMapBeans.where((e) => e.subjectId == subject.subjectId).map((e) => e.examTdsMapId?.toString() ?? "").toList();
      List<String> subjectWiseInternalsExamTdsMapBeans = examTdsMapBeans
          .where((e) => e.subjectId == subject.subjectId)
          .map((e) => (e.internalExamTdsMapBeanList ?? []).map((e) => e!))
          .expand((i) => i)
          .map((e) => e.internalExamMapTdsId?.toString() ?? "")
          .toList();
      headerCells.add(StackedHeaderCell(
        columnNames: subjectWiseExamTdsMapBeans + subjectWiseInternalsExamTdsMapBeans,
        child: Center(
          child: Text(subject.subjectName ?? "-"),
        ),
      ));
    }
    return <StackedHeaderRow>[
      StackedHeaderRow(
        cells: headerCells,
      ),
    ];
  }

  void buildExamMarksColumns() {
    gridColumns = [
      GridColumn(
        width: widthsMap["rno"] ?? 150,
        columnWidthMode: ColumnWidthMode.none,
        columnName: "rno",
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: const Text(
            "Roll No.",
          ),
        ),
      ),
      GridColumn(
        width: widthsMap["student"] ?? 150,
        columnWidthMode: ColumnWidthMode.none,
        columnName: "student",
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: const Text(
            "Student Name",
          ),
        ),
      ),
    ];
    Iterable<ExamTdsMapBean> examTdsMapBeans = (widget.examBean.examSectionMapBeanList ?? [])
        .where((e) => e?.sectionId == widget.section.sectionId)
        .map((e) => e?.examTdsMapBeanList ?? [])
        .map((e) => e.where((e) => e != null).map((e) => e!))
        .expand((i) => i);
    for (Subject subject in subjects) {
      List<ExamTdsMapBean> subjectWiseExamTdsMapBeans = examTdsMapBeans.where((e) => e.subjectId == subject.subjectId).toList();
      List<InternalExamTdsMapBean> subjectWiseInternalsExamTdsMapBeans = examTdsMapBeans
          .where((e) => e.subjectId == subject.subjectId)
          .map((e) => (e.internalExamTdsMapBeanList ?? []).map((e) => e!))
          .expand((i) => i)
          .toList();
      gridColumns.addAll(
        subjectWiseInternalsExamTdsMapBeans
                .map(
                  (e) => GridColumn(
                    width: getColumnWidthByName(e.internalExamMapTdsId?.toString() ?? ""),
                    columnWidthMode: ColumnWidthMode.none,
                    columnName: e.internalExamMapTdsId!.toString(),
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Text(
                        e.internalExamName ?? "-",
                      ),
                    ),
                  ),
                )
                .toList() +
            subjectWiseExamTdsMapBeans
                .map(
                  (e) => GridColumn(
                    width: getColumnWidthByName(e.examTdsMapId?.toString() ?? ""),
                    columnWidthMode: ColumnWidthMode.none,
                    columnName: e.examTdsMapId!.toString(),
                    label: Container(
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Text(
                        e.examName ?? "-",
                      ),
                    ),
                  ),
                )
                .toList(),
      );
      // TODO + add preview headers
    }
  }

  double getColumnWidthByName(String e) => widthsMap[e] ?? 150;

  List<ExamMarksRowSource> buildExamMarksCellsData() {
    List<ExamMarksRowSource> data = [];
    Iterable<ExamTdsMapBean> examTdsMapBeans = (widget.examBean.examSectionMapBeanList ?? [])
        .where((e) => e?.sectionId == widget.section.sectionId)
        .map((e) => e?.examTdsMapBeanList ?? [])
        .map((e) => e.where((e) => e != null).map((e) => e!))
        .expand((i) => i);
    for (StudentProfile eachStudent in students) {
      ExamMarksRowSource marksRowSource = ExamMarksRowSource(
        studentId: eachStudent.studentId,
        rollNumber: int.tryParse(eachStudent.rollNumber ?? ""),
        studentName: ([eachStudent.studentFirstName ?? "", eachStudent.studentMiddleName ?? "", eachStudent.studentLastName ?? ""]
            .where((e) => e != "")
            .join(" ")
            .trim()),
        sourceCells: [],
      );
      for (Subject eachSubject in subjects) {
        List<ExamTdsMapBean> subjectWiseExamTdsMapBeans = examTdsMapBeans.where((e) => e.subjectId == eachSubject.subjectId).toList();
        List<InternalExamTdsMapBean> subjectWiseInternalsExamTdsMapBeans = examTdsMapBeans
            .where((e) => e.subjectId == eachSubject.subjectId)
            .map((e) => (e.internalExamTdsMapBeanList ?? []).map((e) => e!))
            .expand((i) => i)
            .toList();
        marksRowSource.sourceCells!.addAll(
          subjectWiseInternalsExamTdsMapBeans
                  .map(
                    (eachInternal) => ExamMarksCellSource(
                      studentId: eachStudent.studentId,
                      subjectId: eachInternal.subjectId,
                      examTdsMapId: eachInternal.internalExamMapTdsId,
                      parentExamTdsMapId: eachInternal.examTdsMapId,
                      internalsComputationCode: null,
                      parentExamInternalsComputationCode: fromInternalsComputationCodeString(subjectWiseExamTdsMapBeans
                              .where((eachExternal) => (eachExternal.internalExamTdsMapBeanList ?? [])
                                  .map((eachInnerInternal) => eachInnerInternal?.internalExamMapTdsId)
                                  .contains(eachInternal.internalExamMapTdsId))
                              .firstOrNull
                              ?.internalsComputationCode ??
                          ""),
                      marksObtained: null,
                      maxMarks: eachInternal.maxMarks,
                      internalsWeightage: null,
                      isInternal: true,
                      canEdit: fromInternalsComputationCodeString(subjectWiseExamTdsMapBeans.firstOrNull?.internalsComputationCode ?? "") ==
                          InternalsComputationCode.S,
                      setState: setState,
                      updateExternalsMarksAsPerInternalSum: updateExternalsMarksAsPerInternalSum,
                    ),
                  )
                  .toList() +
              subjectWiseExamTdsMapBeans
                  .map(
                    (e) => ExamMarksCellSource(
                      studentId: eachStudent.studentId,
                      subjectId: e.subjectId,
                      examTdsMapId: e.examTdsMapId,
                      parentExamTdsMapId: null,
                      internalsComputationCode: fromInternalsComputationCodeString(e.internalsComputationCode ?? ""),
                      parentExamInternalsComputationCode: null,
                      marksObtained: null,
                      maxMarks: e.maxMarks,
                      internalsWeightage: e.internalsWeightage,
                      isInternal: false,
                      canEdit: e.internalsWeightage != 100,
                      setState: setState,
                      updateExternalsMarksAsPerInternalSum: null,
                    ),
                  )
                  .toList(),
        );
      }
      data.add(marksRowSource);
    }
    for (ExamMarksRowSource eachRow in data) {
      for (ExamMarksCellSource eachCell in eachRow.sourceCells ?? []) {
        eachCell.marksObtained = studentExamMarksDetailsList
                .where((e) => e.studentId == eachRow.studentId && e.examTdsMapId == eachCell.examTdsMapId)
                .firstOrNull
                ?.marksObtained ??
            studentExamMarksDetailsList
                .where((e) => e.studentId == eachRow.studentId)
                .map((e) => e.studentInternalExamMarksDetailsBeanList ?? [])
                .expand((i) => i)
                .where((e) => e?.examTdsMapId == eachCell.examTdsMapId)
                .firstOrNull
                ?.internalsMaxMarks;
        if (eachCell.marksObtained != null && eachCell.marksObtained! < 0) {
          eachCell.marksObtained = 0;
        }
      }
    }
    return data;
  }

  void updateExternalsMarksAsPerInternalSum(int studentId, int parentExamTdsMapId) {
    setState(() {
      int newMarks = marksDataSource.dataGridSourceRows
          .where((e) => e.studentId == studentId)
          .map((e) => e.sourceCells ?? [])
          .expand((i) => i)
          .where((e) => e.parentExamTdsMapId == parentExamTdsMapId)
          .map((e) => e.marksObtained ?? 0)
          .reduce((a, b) => a + b);
      ExamMarksCellSource? x = marksDataSource.dataGridSourceRows
          .where((e) => e.studentId == studentId)
          .map((e) => e.sourceCells ?? [])
          .expand((i) => i)
          .where((e) => e.examTdsMapId == parentExamTdsMapId)
          .firstOrNull;
      if (x != null) {
        x.marksObtained = newMarks;
        x.marksObtainedController.text = "$newMarks";
      }
    });
  }
}

class MarksDataSource extends DataGridSource {
  MarksDataSource(this.dataGridSourceRows, this.context);

  List<ExamMarksRowSource> dataGridSourceRows = [];
  BuildContext context;

  @override
  List<DataGridRow> get rows => dataGridSourceRows.map((e) => examMarksRows(e)).toList();

  DataGridRow examMarksRows(ExamMarksRowSource examMarksRowSourceList) {
    List<DataGridCell> cells = [];
    cells.add(DataGridCell<int>(columnName: "rno", value: examMarksRowSourceList.rollNumber));
    cells.add(DataGridCell<String>(columnName: "name", value: (examMarksRowSourceList.studentName ?? "")));
    cells.addAll((examMarksRowSourceList.sourceCells ?? []).map((e) => DataGridCell<ExamMarksCellSource>(
          columnName: e.examTdsMapId?.toString() ?? "",
          value: e,
        )));
    return DataGridRow(cells: cells);
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((DataGridCell<dynamic> dataGridCell) {
      if (dataGridCell.columnName == "rno" || dataGridCell.columnName == "name") {
        return Container(
          alignment: dataGridCell.columnName == "rno" ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      } else {
        return dataGridCell.value!.widget(context);
      }
    }).toList());
  }
}

class ExamMarksRowSource {
  int? studentId;
  int? rollNumber;
  String? studentName;
  List<ExamMarksCellSource>? sourceCells;

  ExamMarksRowSource({
    this.studentId,
    this.rollNumber,
    this.studentName,
    this.sourceCells,
  });
}

class ExamMarksCellSource {
  int? studentId;
  int? subjectId;
  int? examTdsMapId;
  int? parentExamTdsMapId;
  int? marksObtained;
  int? maxMarks;
  InternalsComputationCode? internalsComputationCode;
  InternalsComputationCode? parentExamInternalsComputationCode;
  double? internalsWeightage;
  bool? isInternal;
  bool? canEdit;

  TextEditingController marksObtainedController = TextEditingController();
  FocusNode focusNode = FocusNode();

  Function setState;
  Function? updateExternalsMarksAsPerInternalSum;

  ExamMarksCellSource({
    this.studentId,
    this.subjectId,
    this.examTdsMapId,
    this.parentExamTdsMapId,
    this.marksObtained,
    this.maxMarks,
    this.internalsComputationCode,
    this.parentExamInternalsComputationCode,
    this.internalsWeightage,
    this.isInternal,
    this.canEdit,
    required this.setState,
    this.updateExternalsMarksAsPerInternalSum,
  });

  Widget widget(BuildContext context) {
    return Center(
      child: canEdit == null || !canEdit!
          ? Text("$marksObtained")
          : TextField(
              keyboardType: TextInputType.number,
              expands: true,
              maxLines: null,
              minLines: null,
              textInputAction: TextInputAction.next,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              enabled: canEdit,
              decoration: const InputDecoration.collapsed(hintText: ''),
              onChanged: (String e) {
                setState(() {
                  marksObtained = int.tryParse(e) ?? marksObtained;
                  if (updateExternalsMarksAsPerInternalSum != null && parentExamInternalsComputationCode == InternalsComputationCode.S) {
                    updateExternalsMarksAsPerInternalSum!(studentId, parentExamTdsMapId);
                  }
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    if (newValue.text == "") return newValue;
                    final text = newValue.text;
                    double newMarks = double.parse(text);
                    if (newMarks > (maxMarks ?? 0)) {
                      return oldValue;
                    }
                    return newValue;
                  } catch (e) {
                    return oldValue;
                  }
                }),
              ],
            ),
    );
  }

  @override
  String toString() {
    return 'ExamMarksCellSource{studentId: $studentId, subjectId: $subjectId, examTdsMapId: $examTdsMapId, parentExamTdsMapId: $parentExamTdsMapId, marksObtained: $marksObtained, maxMarks: $maxMarks, internalsComputationCode: $internalsComputationCode, internalsWeightage: $internalsWeightage, isInternal: $isInternal, canEdit: $canEdit, marksObtainedController: $marksObtainedController, focusNode: $focusNode, setState: $setState, updateExternalsMarksAsPerInternal: $updateExternalsMarksAsPerInternalSum}';
  }
}
