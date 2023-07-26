// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class CustomExamMarksScreen extends StatefulWidget {
  const CustomExamMarksScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.tds,
    required this.studentsList,
    required this.customExam,
    required this.examSectionSubjectMap,
    required this.loadData,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final TeacherDealingSection tds;
  final List<StudentProfile> studentsList;
  final CustomExam customExam;
  final ExamSectionSubjectMap examSectionSubjectMap;
  final Future<void> Function() loadData;

  @override
  State<CustomExamMarksScreen> createState() => _CustomExamMarksScreenState();
}

class _CustomExamMarksScreenState extends State<CustomExamMarksScreen> {
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
        ...widget.studentsList.where((e) => (widget.examSectionSubjectMap.studentExamMarksList ?? []).map((e) => e?.studentId).contains(e.studentId))
      }.toList();
      studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      for (StudentProfile eachStudent in studentsList) {
        StudentExamMarks? actualMarksBean =
            (widget.examSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.studentId == eachStudent.studentId).firstOrNull;
        if (actualMarksBean != null) {
          examMarks.add(StudentExamMarks.fromJson(actualMarksBean.toJson()));
        } else {
          examMarks.add(StudentExamMarks(
            examSectionSubjectMapId: widget.examSectionSubjectMap.examSectionSubjectMapId,
            examId: widget.examSectionSubjectMap.examId,
            agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
            comment: actualMarksBean?.comment,
            studentId: eachStudent.studentId,
            marksObtained: actualMarksBean?.marksObtained,
            marksId: actualMarksBean?.marksId,
            studentExamMediaBeans: actualMarksBean?.studentExamMediaBeans ?? [],
          ));
        }
        focusNodesMap.add([FocusNode(), FocusNode()]);
      }
    });

    setState(() => _isLoading = false);
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

  Future<void> saveChangesAlert(BuildContext context) async {
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.customExam.customExamName ?? "-"),
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
    List<String> columnNames = ["Marks Obtained", "Comments", "Attachments"];
    double marksObtainedCellWidth = 150;
    double commentsCellWidth = 400;
    double mediaCellWidth = 500;
    double legendCellWidth = MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 150;
    double defaultCellHeight = 80;
    return Container(
      margin: const EdgeInsets.all(15),
      child: clayCell(
        child: StickyHeadersTable(
          cellDimensions: CellDimensions.variableColumnWidth(
            columnWidths: [marksObtainedCellWidth, commentsCellWidth, mediaCellWidth],
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
          columnsTitleBuilder: columnHeaderBuilder,
          contentCellBuilder: (int columnIndex, int rowIndex) {
            int? studentId = studentsList[rowIndex].studentId;
            StudentExamMarks eachStudentExamMarks = examMarks.where((e) => e.studentId == studentId).first;
            switch (columnIndex) {
              case 0:
                return clayCell(
                  child: studentMarksObtainedWidget(eachStudentExamMarks),
                  emboss: true,
                );
              case 1:
                return clayCell(
                  child: studentMarksCommentWidget(eachStudentExamMarks),
                  emboss: true,
                );
              case 2:
                return clayCell(
                  child: studentMarksMediaScrollableWidget(eachStudentExamMarks),
                  emboss: true,
                );
              default:
                return Text("$rowIndex $columnIndex");
            }
          },
        ),
      ),
    );
  }

  Widget columnHeaderBuilder(int columnIndex) {
    switch (columnIndex) {
      case 0:
        return clayCell(
          child: const Center(
            child: Text(
              "Marks Obtained",
              style: TextStyle(fontSize: 12),
            ),
          ),
          emboss: true,
        );
      case 1:
        return clayCell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Expanded(
                child: Text(
                  "Comments",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          emboss: true,
        );
      case 2:
        return clayCell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Expanded(
                child: Text(
                  "Attachments",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          emboss: true,
        );
      default:
        return const Text("");
    }
  }

  Scrollbar studentMarksMediaScrollableWidget(StudentExamMarks eachStudentExamMarks) {
    return Scrollbar(
      controller: eachStudentExamMarks.mediaScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: eachStudentExamMarks.mediaScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...(eachStudentExamMarks.studentExamMediaBeans ?? []).map(
              (e) => CachedNetworkImage(
                imageUrl: e!.mediaUrl!,
                height: 70,
                width: 70,
                fit: BoxFit.scaleDown,
              ),
            ),
            if (_isEditMode) addNewImageButton(eachStudentExamMarks),
          ],
        ),
      ),
    );
  }

  Widget studentMarksCommentWidget(StudentExamMarks eachStudentExamMarks) {
    if (_isEditMode) {
      int rowIndex = studentsList.indexWhere((student) => student.studentId == eachStudentExamMarks.studentId);
      FocusNode focusNode = focusNodesMap[rowIndex][1];
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            _handleArrowKeyNavigation(event, rowIndex, 1);
          }
        },
        child: TextFormField(
          focusNode: focusNode,
          initialValue: eachStudentExamMarks.comment ?? "",
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
          ),
          onChanged: (String? newText) => setState(() {
            eachStudentExamMarks.comment = newText;
          }),
          maxLines: null,
          style: const TextStyle(
            fontSize: 16,
          ),
          textAlign: TextAlign.start,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(eachStudentExamMarks.comment ?? ""),
        ),
      ],
    );
  }

  Widget studentMarksObtainedWidget(StudentExamMarks eachStudentExamMarks) {
    if (_isEditMode) {
      int rowIndex = studentsList.indexWhere((student) => student.studentId == eachStudentExamMarks.studentId);
      FocusNode focusNode = focusNodesMap[rowIndex][0];
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            _handleArrowKeyNavigation(event, rowIndex, 0);
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
                    if (text.isEmpty || (double.tryParse(text) != null && double.parse(text) <= (widget.examSectionSubjectMap.maxMarks ?? 0))) {
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
                      widget.customExam.customExamName ?? "-",
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
                      "${widget.tds.sectionName ?? " - "}\n"
                      "${widget.tds.subjectName ?? " - "}\n"
                      "${widget.tds.teacherName ?? " - "}\n",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text("Max. Marks: ${widget.examSectionSubjectMap.maxMarks ?? "-"}"),
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: Text("Class Average: ${widget.examSectionSubjectMap.classAverage ?? "-"}")),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text("Date: ${widget.examSectionSubjectMap.examDate}"),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text("Time: ${widget.examSectionSubjectMap.startTimeSlot} - ${widget.examSectionSubjectMap.endTimeSlot}"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget oldMarksTable() {
    return DataTable(
      columns: [
        const DataColumn(label: Text('Roll No.')),
        const DataColumn(label: Text('Student Name')),
        DataColumn(label: Text('Marks Obtained\n${widget.examSectionSubjectMap.maxMarks}')),
        const DataColumn(label: Text('Comments')),
      ],
      rows: <DataRow>[
        ...studentsList.map((eachStudent) {
          StudentExamMarks eachStudentExamMarks = examMarks.where((e) => e.studentId == eachStudent.studentId).first;
          return DataRow(cells: <DataCell>[
            DataCell(Text(eachStudent.rollNumber ?? "-")),
            DataCell(Text(eachStudent.studentFirstName ?? "-")),
            DataCell(Text("${eachStudentExamMarks.marksObtained ?? ""}")),
            DataCell(Text(eachStudentExamMarks.comment ?? "")),
          ]);
        })
      ],
    );
  }

  Widget addNewImageButton(StudentExamMarks eachStudentExamMarks) {
    return IconButton(
      autofocus: false,
      icon: ClayButton(
        color: clayContainerColor(context),
        height: 45,
        width: 45,
        borderRadius: 50,
        spread: 1,
        surfaceColor: clayContainerColor(context),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(Icons.add_a_photo_outlined),
            ),
          ),
        ),
      ),
      onPressed: () {
        html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.multiple = true;
        uploadInput.draggable = true;
        uploadInput.accept =
            '.png,.jpg,.jpeg,.pdf,.zip,.doc,.7z,.arj,.deb,.pkg,.rar,.rpm,.tar.gz,.z,.zip,.csv,.dat,.db,.dbf,.log,.mdb,.sav,.sql,.tar,.xml';
        uploadInput.click();
        uploadInput.onChange.listen(
          (changeEvent) {
            final files = uploadInput.files!;
            for (html.File file in files) {
              final reader = html.FileReader();
              reader.readAsDataUrl(file);
              reader.onLoadEnd.listen(
                (loadEndEvent) async {
                  // _file = file;
                  debugPrint("File uploaded: " + file.name);
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    UploadFileToDriveResponse uploadFileResponse = await uploadFileToDrive(reader.result!, file.name);

                    StudentExamMediaBean studentExamMediaBean = StudentExamMediaBean();
                    studentExamMediaBean.marksId = eachStudentExamMarks.marksId;
                    studentExamMediaBean.status = "active";
                    studentExamMediaBean.mediaType = uploadFileResponse.mediaBean!.mediaType;
                    studentExamMediaBean.mediaUrl = uploadFileResponse.mediaBean!.mediaUrl;
                    studentExamMediaBean.agent = widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId;
                    studentExamMediaBean.mediaUrlId = uploadFileResponse.mediaBean!.mediaId;
                    studentExamMediaBean.marksMediaId = null;
                    studentExamMediaBean.comment = null;
                    setState(() {
                      eachStudentExamMarks.studentExamMediaBeans ??= [];
                      eachStudentExamMarks.studentExamMediaBeans!.add(studentExamMediaBean);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
                      ),
                    );
                  }

                  setState(() {
                    _isLoading = false;
                  });
                },
              );
            }
          },
        );
      },
    );
  }
}
