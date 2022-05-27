import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'dart:ui';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/exams/model/constants.dart';
import 'package:schoolsgo_web/src/exams/model/exams.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:screenshot/screenshot.dart';

class StudentEachExamMemoScreen extends StatefulWidget {
  const StudentEachExamMemoScreen({
    Key? key,
    required this.studentProfile,
    required this.exam,
    required this.studentExamMarksDetailsList,
    required this.markingAlgorithmBean,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final Exam exam;
  final List<StudentExamMarksDetailsBean> studentExamMarksDetailsList;
  final MarkingAlgorithmBean? markingAlgorithmBean;

  @override
  _StudentEachExamMemoScreenState createState() => _StudentEachExamMemoScreenState();
}

class _StudentEachExamMemoScreenState extends State<StudentEachExamMemoScreen> {
  List<Subject> subjects = [];
  bool _hasInternals = false;

  bool _isLoading = true;
  bool _isPrinting = false;
  bool _isPreview = false;

  late bool _isMarksForBean;
  late bool _isGradeForBean;
  late bool _isGpaForBean;

  double totalMarksObtained = 0;
  double totalMaxMarks = 0;
  String overAllGrade = "-";
  List<double> gpaPerSubject = [];
  String overAllGpa = "-";

  List<List<Widget>> marksTable = [];
  List<List<Widget>> fittedMarksTable = [];

  static const double _studentColumnWidth = 200;
  static const double _studentColumnHeight = 60;
  static const double _cellColumnWidth = 88;
  static const double _cellColumnHeight = 60;
  static final Color _headerColor = Colors.blue.shade300;
  static const double _cellPadding = 4.0;

  ScreenshotController screenshotController = ScreenshotController();

  late LinkedScrollControllerGroup _controllers;
  final List<ScrollController> _scrollControllers = [];

  late String reportName;

  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    reportName = (widget.studentProfile.rollNumber ?? "-") +
        " " +
        (widget.studentProfile.studentFirstName ?? "-") +
        " " +
        (widget.exam.examName ?? "-") +
        ".xlsx";
    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      totalMarksObtained = 0;
      totalMaxMarks = 0;
      overAllGrade = "-";
      gpaPerSubject = [];
      overAllGpa = "-";
      subjects = widget.studentExamMarksDetailsList
          .map((e) => Subject(
                subjectId: e.subjectId,
                subjectName: e.subjectName,
                schoolId: e.schoolId,
              ))
          .toList();
      MarkingSchemeCode? x = fromMarkingSchemeCodeString(widget.exam.markingSchemeCode ?? "-");
      _isMarksForBean = x == null ? false : x.value[0] == "T";
      _isGradeForBean = x == null ? false : x.value[1] == "T";
      _isGpaForBean = x == null ? false : x.value[2] == "T";
      _hasInternals =
          widget.studentExamMarksDetailsList.map((e) => (e.studentInternalExamMarksDetailsBeanList ?? []).length).where((e) => e > 0).isNotEmpty;
      _isLoading = false;
    });
    setState(() {
      _isLoading = true;
    });
    await _loadMarksTable();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMarksTable() async {
    marksTable.add(
      [
        _subjectContainer("Subject"),
        if (_hasInternals) _cellHeader("Internals Marks Obtained"),
        if (_hasInternals) _cellHeader("Internals Max Marks"),
        if (_hasInternals && _isGradeForBean) _cellHeader("Internals Grade"),
        _cellHeader(_hasInternals ? "Externals Marks Obtained" : "Marks Obtained"),
        _cellHeader(_hasInternals ? "Externals Max Marks" : "Max Marks"),
        if (_isGradeForBean) _cellHeader(_hasInternals ? "Externals Grade" : "Grade"),
        if (_isGpaForBean) _cellHeader(_hasInternals ? "Externals GPA" : "GPA"),
      ],
    );

    for (Subject eachSubject in subjects) {
      StudentExamMarksDetailsBean eachSubjectWiseMarksBean =
          widget.studentExamMarksDetailsList.where((e) => e.subjectId == eachSubject.subjectId).first;

      String internalsMarksComputedString = "";
      String internalsMaxMarksString = "";
      String internalsGradeString = "";
      String externalsMarksObtainedString = eachSubjectWiseMarksBean.marksObtained == null || eachSubjectWiseMarksBean.marksObtained == -1
          ? "-"
          : eachSubjectWiseMarksBean.marksObtained == -2
              ? "A"
              : eachSubjectWiseMarksBean.marksObtained!.toString();
      totalMarksObtained += double.tryParse(externalsMarksObtainedString) ?? 0;
      String externalsMaxMarksString = "${eachSubjectWiseMarksBean.maxMarks == null ? "-" : eachSubjectWiseMarksBean.maxMarks!}";
      totalMaxMarks += eachSubjectWiseMarksBean.maxMarks ?? 0;
      String externalsGradeString = "";
      String subjectWiseGpaString = "";

      if (double.tryParse(externalsMarksObtainedString) != null && double.tryParse(externalsMaxMarksString) != null) {
        double externalsPercentage = double.tryParse(externalsMarksObtainedString)! * 100 / double.tryParse(externalsMaxMarksString)!;
        if (widget.markingAlgorithmBean != null) {
          (widget.markingAlgorithmBean!.markingAlgorithmRangeBeanList ?? []).map((e) => e!).forEach((MarkingAlgorithmRangeBean eachRangeBean) {
            if (eachRangeBean.startRange! <= externalsPercentage.ceil() && externalsPercentage.ceil() <= eachRangeBean.endRange!) {
              if (_isGradeForBean) {
                externalsGradeString = eachRangeBean.grade!;
              }
              if (_isGpaForBean) {
                subjectWiseGpaString = doubleToStringAsFixed(eachRangeBean.gpa);
                gpaPerSubject.add(eachRangeBean.gpa ?? 0);
              }
            }
          });
        }
      }

      if (_hasInternals) {
        double internalsComputedMarks = 0;
        double internalsWeightage = eachSubjectWiseMarksBean.internalsWeightage ?? 100;
        String internalsComputationCode = eachSubjectWiseMarksBean.internalsComputationCode ?? "A";
        List<StudentInternalExamMarksDetailsBean> internals =
            (eachSubjectWiseMarksBean.studentInternalExamMarksDetailsBeanList ?? []).map((e) => e!).toList();
        if (internalsComputationCode == "A") {
          internalsComputedMarks = internals
              .where((e) => e.internalsMarksObtained != null && e.internalsMarksObtained != -1)
              .map((e) => (e.internalsMarksObtained == -2 ? 0 : e.internalsMarksObtained!) * internalsWeightage / (e.internalsMaxMarks ?? 0))
              .average;
        } else {
          internalsComputedMarks = internals
              .where((e) => e.internalsMarksObtained != null && e.internalsMarksObtained != -1)
              .map((e) => (e.internalsMarksObtained == -2 ? 0 : e.internalsMarksObtained!) * internalsWeightage / (e.internalsMaxMarks ?? 0))
              .reduce(max)
              .toDouble();
        }
        double internalsPercentage = internalsComputedMarks * 100 / internalsWeightage;
        if (widget.markingAlgorithmBean != null) {
          (widget.markingAlgorithmBean!.markingAlgorithmRangeBeanList ?? []).map((e) => e!).forEach((MarkingAlgorithmRangeBean eachRangeBean) {
            if (eachRangeBean.startRange! <= internalsPercentage.ceil() && internalsPercentage.ceil() <= eachRangeBean.endRange!) {
              if (_isGradeForBean) {
                internalsGradeString = eachRangeBean.grade!;
              }
            }
          });
        }
        internalsMarksComputedString = doubleToStringAsFixed(internalsPercentage * (eachSubjectWiseMarksBean.internalsWeightage ?? 100) / 100);
        totalMarksObtained += internalsPercentage * (eachSubjectWiseMarksBean.internalsWeightage ?? 100) / 100;
        internalsMaxMarksString = doubleToStringAsFixed(internalsWeightage);
        totalMaxMarks += internalsWeightage;
      }

      marksTable.add(
        [
          _subjectContainer(eachSubject.subjectName ?? "-"),
          if (_hasInternals) _cellContainer(internalsMarksComputedString),
          if (_hasInternals) _cellContainer(internalsMaxMarksString),
          if (_hasInternals && _isGradeForBean) _cellContainer(internalsGradeString),
          _cellContainer(externalsMarksObtainedString),
          _cellContainer(externalsMaxMarksString),
          if (_isGradeForBean) _cellContainer(externalsGradeString),
          if (_isGpaForBean) _cellContainer(subjectWiseGpaString),
        ],
      );
    }
    _controllers = LinkedScrollControllerGroup();
    for (var i in List<int>.generate(subjects.length + 1, (i) => i + 1)) {
      _scrollControllers.add(_controllers.addAndGet());
    }
  }

  Widget _cellHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(_cellPadding),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        height: _cellColumnHeight,
        width: _cellColumnWidth - _cellPadding,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _headerColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cellContainer(String text) {
    return Padding(
      padding: const EdgeInsets.all(_cellPadding),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        height: _cellColumnHeight,
        width: _cellColumnWidth - _cellPadding,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _subjectContainer(String text) {
    return Padding(
      padding: const EdgeInsets.all(_cellPadding),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        height: _studentColumnHeight,
        width: _studentColumnWidth,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: _headerColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(""),
          actions: [
            InkWell(
              onTap: () async {
                setState(() {
                  _isPreview = !_isPreview;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: _isPreview ? const Icon(Icons.clear) : const Icon(Icons.remove_red_eye),
              ),
            ),
            InkWell(
              onTap: () async {
                if (_isPrinting) return;
                setState(() {
                  _isPrinting = true;
                });
                List<int> bytes = await getStudentExamBytes(GetStudentExamBytesRequest(
                  studentProfile: widget.studentProfile,
                  exam: widget.exam,
                  markingAlgorithmBean: widget.markingAlgorithmBean,
                  studentExamMarksDetailsList: widget.studentExamMarksDetailsList,
                ));
                AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
                  ..setAttribute("download", reportName)
                  ..click();
                setState(() {
                  _isPrinting = false;
                });
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Icon(Icons.download),
              ),
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
            : _isPrinting
                ? Column(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Center(
                          child: Text("Download in progress"),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Image.asset(
                          'assets/images/eis_loader.gif',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(reportName),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text("Downloading.."),
                        ),
                      )
                    ],
                  )
                : !_isPreview
                    ? bodyWidget()
                    : tableWithFixedDimensions());
  }

  Widget bodyWidget() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: MediaQuery.of(context).orientation == Orientation.landscape
              ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 0, MediaQuery.of(context).size.width / 5, 0)
              : const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: examDetailsWidget(),
        ),
        marksTable.isEmpty ? Container() : marksTableWidget(),
        const SizedBox(
          height: 20,
        ),
        if (_isPrinting)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: const Text("© Powered by Epsilon Infinity Services Pvt. Ltd."),
              ),
            ],
          ),
        if (_isPrinting)
          const SizedBox(
            height: 20,
          ),
      ],
    );
  }

  Widget examDetailsWidget() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ClayContainer(
                      depth: 40,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      emboss: true,
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        child: Center(
                          child: Text(
                            (widget.exam.examName ?? "-").capitalize(),
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Name:      ${widget.studentProfile.studentFirstName ?? "-"}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Roll No.:   ${widget.studentProfile.rollNumber ?? "-"}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Section:    ${widget.studentProfile.sectionName ?? "-"}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("School:     ${widget.studentProfile.schoolName ?? "-"}"),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.all(25),
                          child: overAllScoreWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget overAllScoreWidget() {
    // Over all Grade computation
    if (totalMaxMarks != 0 && _isGradeForBean) {
      int percentage = (totalMarksObtained * 100 / totalMaxMarks).ceil();
      (widget.markingAlgorithmBean!.markingAlgorithmRangeBeanList ?? []).map((e) => e!).forEach((eachRange) {
        if (eachRange.startRange! <= percentage && percentage <= eachRange.endRange!) {
          overAllGrade = eachRange.grade ?? "-";
        }
      });
    }

    // Over all Gpa computation
    if (gpaPerSubject.isNotEmpty && _isGpaForBean) {
      overAllGpa = doubleToStringAsFixed((gpaPerSubject.reduce((a, b) => a + b) / gpaPerSubject.length));
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 60 + 10 + 60 + 10 + (_isGradeForBean ? 70 : 0) + (_isGpaForBean ? 70 : 0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    "Marks",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ClayContainer(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    height: 45,
                    width: 60,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          Container(
                            height: 30,
                            width: 60,
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                doubleToStringAsFixed(totalMarksObtained),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 60,
                              height: 15,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "$totalMaxMarks",
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  const Text(
                    "Percentage",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ClayContainer(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    height: 45,
                    width: 60,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      child: Center(
                        child: Text("${doubleToStringAsFixed(totalMarksObtained * 100 / totalMaxMarks)} %"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              if (_isGradeForBean)
                Column(
                  children: [
                    const Text(
                      "Grade",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ClayContainer(
                      depth: 40,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      height: 45,
                      width: 60,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: Center(
                          child: Text(overAllGrade),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_isGradeForBean)
                const SizedBox(
                  width: 10,
                ),
              if (_isGpaForBean)
                Column(
                  children: [
                    const Text(
                      "CGPA",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ClayContainer(
                      depth: 40,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      height: 45,
                      width: 60,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: Center(
                          child: Text(overAllGpa),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_isGpaForBean)
                const SizedBox(
                  width: 10,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget marksTableWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: marksTable
            .map(
              (eachRow) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollControllers[marksTable.indexOf(eachRow)],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: eachRow,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget tableWithFixedDimensions() {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 10,
      panEnabled: true,
      alignPanAxis: false,
      child: RepaintBoundary(
        key: GlobalKey(),
        child: SizedBox(
          key: key,
          height: 1000,
          width: 1800,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                    const SizedBox(
                      height: 30,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            (widget.exam.examName ?? "-").capitalize(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name:      ${widget.studentProfile.studentFirstName ?? "-"}",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Roll No.:   ${widget.studentProfile.rollNumber ?? "-"}",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Section:    ${widget.studentProfile.sectionName ?? "-"}",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "School:     ${widget.studentProfile.schoolName ?? "-"}",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    overAllScoreWidget(),
                    const SizedBox(
                      height: 10,
                    ),
                  ] +
                  marksTable
                      .map(
                        (eachRow) => FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: eachRow,
                          ),
                        ),
                      )
                      .toList() +
                  [
                    const SizedBox(
                      height: 30,
                    ),
                  ],
            ),
          ),
        ),
      ),
    );
  }
}
