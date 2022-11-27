import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/exams/model/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminMarksV2Screen extends StatefulWidget {
  const AdminMarksV2Screen({
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
  State<AdminMarksV2Screen> createState() => _AdminMarksV2ScreenState();
}

class _AdminMarksV2ScreenState extends State<AdminMarksV2Screen> {
  bool _isLoading = true;
  List<StudentExamMarksDetailsBean> studentExamMarksDetailsList = [];

  MarkingAlgorithmBean? _markingAlgorithm;

  List<Subject> _subjects = [];
  List<StudentProfile> _students = [];

  List<_NewMarksBean> newMarksBeans = [];
  List<StudentProfile> students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
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
            _markingAlgorithm = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList().first;
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
        _students = studentExamMarksDetailsList
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

        for (StudentProfile eachStudent in students) {
          for (StudentExamMarksDetailsBean eachStudentMarksDetails
              in studentExamMarksDetailsList.where((e) => e.studentId == eachStudent.studentId)) {
            eachStudentMarksDetails.studentInternalExamMarksDetailsBeanList?.forEach((eachStudentInternalsMarks) {
              newMarksBeans.add(_NewMarksBean(
                eachStudent.studentId!,
                eachStudentInternalsMarks!.examTdsMapId!,
                eachStudentInternalsMarks.internalTdsMapId,
                eachStudentInternalsMarks.internalsMarksObtained == -1 ? null : eachStudentInternalsMarks.internalsMarksObtained,
                eachStudentInternalsMarks.internalsMaxMarks!,
                fromInternalsComputationCodeString(eachStudentInternalsMarks.internalsComputationCode ?? "-"),
              ));
            });
            newMarksBeans.add(_NewMarksBean(
              eachStudent.studentId!,
              eachStudentMarksDetails.examTdsMapId!,
              null,
              eachStudentMarksDetails.marksObtained == -1 ? null : eachStudentMarksDetails.marksObtained,
              eachStudentMarksDetails.maxMarks!,
              fromInternalsComputationCodeString(eachStudentMarksDetails.internalsComputationCode ?? "-"),
            ));
          }
        }
      });
    }
    setState(() {
      _isLoading = false;
    });
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
          : buildNewMarksSheetLayout(context),
    );
  }

  late final PlutoGridStateManager stateManager;

  Widget buildNewMarksSheetLayoutTemp(BuildContext context) {
    final List<PlutoColumn> columns = <PlutoColumn>[
      PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Age',
        field: 'age',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Role',
        field: 'role',
        type: PlutoColumnType.select(<String>[
          'Programmer',
          'Designer',
          'Owner',
        ]),
      ),
      PlutoColumn(
        title: 'Joined',
        field: 'joined',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Working time',
        field: 'working_time',
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: 'salary',
        field: 'salary',
        type: PlutoColumnType.currency(),
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            formatAsCurrency: true,
            type: PlutoAggregateColumnType.sum,
            format: '#,###',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Sum',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
    ];

    final List<PlutoRow> rows = [
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user1'),
          'name': PlutoCell(value: 'Mike'),
          'age': PlutoCell(value: 20),
          'role': PlutoCell(value: 'Programmer'),
          'joined': PlutoCell(value: '2021-01-01'),
          'working_time': PlutoCell(value: '09:00'),
          'salary': PlutoCell(value: 300),
        },
      ),
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user2'),
          'name': PlutoCell(value: 'Jack'),
          'age': PlutoCell(value: 25),
          'role': PlutoCell(value: 'Designer'),
          'joined': PlutoCell(value: '2021-02-01'),
          'working_time': PlutoCell(value: '10:00'),
          'salary': PlutoCell(value: 400),
        },
      ),
      PlutoRow(
        cells: {
          'id': PlutoCell(value: 'user3'),
          'name': PlutoCell(value: 'Suzi'),
          'age': PlutoCell(value: 40),
          'role': PlutoCell(value: 'Owner'),
          'joined': PlutoCell(value: '2021-03-01'),
          'working_time': PlutoCell(value: '11:00'),
          'salary': PlutoCell(value: 700),
        },
      ),
    ];

    /// columnGroups that can group columns can be omitted.
    final List<PlutoColumnGroup> columnGroups = [
      PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
      PlutoColumnGroup(title: 'User information', fields: ['name', 'age']),
      PlutoColumnGroup(title: 'Status', children: [
        PlutoColumnGroup(title: 'A', fields: ['role'], expandedColumn: true),
        PlutoColumnGroup(title: 'Etc.', fields: ['joined', 'working_time']),
      ]),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: PlutoGrid(
        columns: columns,
        rows: rows,
        columnGroups: columnGroups,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        configuration: const PlutoGridConfiguration(),
      ),
    );
  }

  TextEditingController controller = TextEditingController();

  Widget buildNewMarksSheetLayout(BuildContext context) {
    List<PlutoColumn> columns = [PlutoColumn(title: "Student", field: "student", type: PlutoColumnType.text(), readOnly: true)];
    List<PlutoRow> rows = [];
    List<PlutoColumnGroup> columnGroups = [];
    (widget.examBean.examSectionMapBeanList ?? [])
        .where((e) => e?.sectionId == widget.section.sectionId)
        .map((e) => e?.examTdsMapBeanList ?? [])
        .expand((i) => i)
        .forEach((ExamTdsMapBean? eachExamTdsMapBean) {
      List<PlutoColumn> tdsWiseColumns = [];
      eachExamTdsMapBean?.internalExamTdsMapBeanList?.forEach((eachInternalExamTdsMapBean) {
        tdsWiseColumns.add(PlutoColumn(
          title: (eachInternalExamTdsMapBean?.internalExamName?.toString() ?? "-") + " (${eachInternalExamTdsMapBean?.maxMarks ?? "-"})",
          field: eachInternalExamTdsMapBean?.internalExamMapTdsId?.toString() ?? "",
          type: PlutoColumnType.number(),
        ));
      });
      tdsWiseColumns.add(PlutoColumn(
        title: "Total (${eachExamTdsMapBean?.maxMarks ?? "-"})",
        field: eachExamTdsMapBean?.examTdsMapId?.toString() ?? "",
        type: PlutoColumnType.number(),
        readOnly: eachExamTdsMapBean?.internalsWeightage == 100,
      ));
      columns.addAll(tdsWiseColumns);
      columnGroups.add(PlutoColumnGroup(
        title: eachExamTdsMapBean?.subjectName ?? "",
        fields: tdsWiseColumns.map((e) => e.field).toList(),
      ));
    });
    columnGroups.add(PlutoColumnGroup(title: widget.examBean.examName ?? "", fields: columns.map((e) => e.field).toList()));

    for (StudentProfile eachStudent in students) {
      Map<String, PlutoCell> cellsPerStudent = {};
      cellsPerStudent.putIfAbsent(
          'student',
          () => PlutoCell(
                value: (eachStudent.rollNumber ?? "") + ". " + (eachStudent.studentFirstName ?? ""),
                key: Key(eachStudent.studentId?.toString() ?? ""),
              ));
      newMarksBeans.where((e) => e.studentId == eachStudent.studentId).forEach((eachNewMarkBean) {
        cellsPerStudent.putIfAbsent((eachNewMarkBean.internalTdsMapId ?? eachNewMarkBean.examTdsMapId).toString(), () => eachNewMarkBean.cell);
      });
      rows.add(PlutoRow(cells: cellsPerStudent));
    }
    return PlutoGrid(
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        stateManager = event.stateManager;
        stateManager.setShowColumnFilter(true);
        stateManager.addListener(() {
          if (stateManager.currentCell == null) return;
          _NewMarksBean bean = newMarksBeans.where((e) => stateManager.currentCell!.key.hashCode == Key(e.toString()).hashCode).first;
          int oldMarks = bean.marksObtained ?? 0;
          int maxMarks = bean.maxMarks;
          int? mayBeNewMarks = int.tryParse(stateManager.currentCell!.value.toString());
          if (mayBeNewMarks == null || mayBeNewMarks > maxMarks || mayBeNewMarks <= 0) {
            stateManager.changeCellValue(stateManager.currentCell!, oldMarks.toString());
          } else {
            newMarksBeans
                .where((e) =>
                    e.studentId == bean.studentId &&
                    e.examTdsMapId == bean.examTdsMapId &&
                    e.internalTdsMapId == null &&
                    e.internalsComputationCode == InternalsComputationCode.S)
                .forEach((e) {
              setState(() {
                e.marksObtained = (e.marksObtained ?? 0) + mayBeNewMarks;
                e.cell.value = e.marksObtained.toString();
              });
              print("363: ${e.marksObtained}");
            });
            setState(() {
              bean.marksObtained = mayBeNewMarks;
            });
          }
        });
      },
      onChanged: (PlutoGridOnChangedEvent event) {
        print(event);
      },
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          activatedBorderColor: Colors.blue,
          borderColor: Colors.black26,
          evenRowColor: Colors.grey.shade100,
        ),
        scrollbar: const PlutoGridScrollbarConfig(
          isAlwaysShown: true,
        ),
      ),
    );
  }
}

class _NewMarksBean {
  int studentId;
  int examTdsMapId;
  int? internalTdsMapId;
  int? marksObtained;
  int maxMarks;
  InternalsComputationCode? internalsComputationCode;

  PlutoCell get cell => PlutoCell(key: Key(toString()), value: marksObtained);

  _NewMarksBean(this.studentId, this.examTdsMapId, this.internalTdsMapId, this.marksObtained, this.maxMarks, this.internalsComputationCode);

  @override
  String toString() {
    return "_NewMarksBean(studentId: $studentId, examTdsMapId: $examTdsMapId, internalTdsMapId: $internalTdsMapId, maxMarks: $maxMarks)";
  }

  String c() {
    return "_NewMarksBean(studentId: $studentId, examTdsMapId: $examTdsMapId, internalTdsMapId: $internalTdsMapId, marksObtained: $marksObtained, maxMarks: $maxMarks, internalsComputationCode: $internalsComputationCode)";
  }
}
