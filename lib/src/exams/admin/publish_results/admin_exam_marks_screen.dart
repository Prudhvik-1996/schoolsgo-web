import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/marks_input_formatter.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/exams/model/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminExamMarksScreen extends StatefulWidget {
  const AdminExamMarksScreen({
    Key? key,
    required this.adminProfile,
    required this.examBean,
    required this.section,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final AdminExamBean examBean;
  final Section section;

  @override
  _AdminExamMarksScreenState createState() => _AdminExamMarksScreenState();
}

class _AdminExamMarksScreenState extends State<AdminExamMarksScreen> {
  bool _isLoading = true;
  List<StudentExamMarksDetailsBean> _studentExamMarksDetailsList = [];

  MarkingAlgorithmBean? _markingAlgorithm;

  List<Subject> _subjects = [];
  List<StudentProfile> _students = [];

  final List<List<StudentExamMarksDetailsBean>> _marksGrid = [];
  int currentCellIndexX = 0;
  int currentCellIndexY = 0;

  ScrollController horizontalBodyController = ScrollController();
  ScrollController verticalBodyController = ScrollController();

  ScrollController horizontalTitleController = ScrollController();
  ScrollController verticalTitleController = ScrollController();

  late LinkedScrollControllerGroup _controllers;
  late ScrollController _studentsController;
  late ScrollController _detailsController;
  late ScrollController _marksController;
  late ScrollController _header;
  late ScrollController _subHeader;
  late LinkedScrollControllerGroup _marksControllers;
  final List<ScrollController> _scrollControllers = [];
  ScrollController sliverScrollController = ScrollController();

  late ExamSectionMapBean _examSectionMapBean;
  bool _isEditMode = false;
  bool _showInternals = false;
  bool _showPreview = false;

  static const double _studentColumnWidth = 200;
  static const double _studentColumnHeight = 60;
  static const double _cellColumnWidth = 88;
  static const double _cellColumnHeight = 60;
  static final Color _headerColor = Colors.blue.shade300;
  static const double _cellPadding = 4.0;
  final int _lhsFlex = 1;
  int _rhsFlex = 3;

  @override
  void initState() {
    super.initState();
    _examSectionMapBean = (widget.examBean.examSectionMapBeanList ?? []).map((e) => e!).where((e) => widget.section.sectionId == e.sectionId).first;
    _loadData();
  }

  @override
  void dispose() {
    horizontalTitleController.dispose();
    horizontalBodyController.dispose();
    verticalTitleController.dispose();
    verticalBodyController.dispose();

    _studentsController.dispose();
    _detailsController.dispose();
    _marksController.dispose();
    _header.dispose();
    _subHeader.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _subjects = (widget.examBean.examSectionMapBeanList ?? [])
          .map((ExamSectionMapBean? e) => e!)
          .where((ExamSectionMapBean eachSectionMapBean) => eachSectionMapBean.sectionId == widget.section.sectionId)
          .map((ExamSectionMapBean eachSectionMapBean) => eachSectionMapBean.examTdsMapBeanList ?? [])
          .expand((List<ExamTdsMapBean?> i) => i)
          .map((ExamTdsMapBean? examTdsMapBean) => examTdsMapBean!)
          .where((ExamTdsMapBean examTdsMapBean) => examTdsMapBean.sectionId == widget.section.sectionId)
          .map((ExamTdsMapBean examTdsMapBean) => Subject(
                subjectId: examTdsMapBean.subjectId,
                subjectName: examTdsMapBean.subjectName,
                schoolId: widget.adminProfile.schoolId,
              ))
          .toList();
      _isEditMode = false;
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
        _studentExamMarksDetailsList = getStudentExamMarksDetailsResponse.studentExamMarksDetailsList!.map((e) => e!).toList();
        _students = _studentExamMarksDetailsList
            .map((e) => StudentProfile(studentId: e.studentId, rollNumber: e.rollNumber, studentFirstName: e.studentName))
            .toSet()
            .toList();
        // for (StudentProfile eachStudent in _students) {
        for (int i = 0; i < _students.length; i++) {
          List<StudentExamMarksDetailsBean> x = [];
          // for (Subject eachSubject in _subjects) {
          for (int j = 0; j < _subjects.length; j++) {
            StudentExamMarksDetailsBean y =
                _studentExamMarksDetailsList.where((e) => e.studentId == _students[i].studentId && e.subjectId == _subjects[j].subjectId).first;
            if (_markingAlgorithm != null) {
              y.computeGrades(_markingAlgorithm!);
            }
            x.add(y);
          }
          _marksGrid.add(x);
        }
      });
      _makeCellEditable(0, 0, 0, 0);
    }

    _controllers = LinkedScrollControllerGroup();
    _studentsController = _controllers.addAndGet();
    _detailsController = _controllers.addAndGet();
    _marksController = _controllers.addAndGet();

    _marksControllers = LinkedScrollControllerGroup();
    _header = _marksControllers.addAndGet();
    _subHeader = _marksControllers.addAndGet();
    for (int i = 0; i < _students.length; i++) {
      _scrollControllers.add(_marksControllers.addAndGet());
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _rhsFlex = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 2;
    });
    _scrollToTableWithWaitTime();
    return Scaffold(
        appBar: AppBar(
          title: Text((widget.examBean.examName ?? "-").capitalize()),
        ),
        drawer: AdminAppDrawer(
          adminProfile: widget.adminProfile,
        ),
        body: _isLoading
            ? Center(
                child: Image.asset('assets/images/eis_loader.gif'),
              )
            : RawKeyboardListener(
                onKey: (RawKeyEvent event) {
                  if (!_isEditMode) return;
                  setState(() {
                    if ((event.isKeyPressed(LogicalKeyboardKey.tab) || event.isKeyPressed(LogicalKeyboardKey.arrowRight)) &&
                        currentCellIndexY <= _marksGrid[currentCellIndexX].length - 2) {
                      _makeCellEditable(currentCellIndexX, currentCellIndexY, currentCellIndexX, currentCellIndexY + 1);
                    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) && currentCellIndexY >= 1) {
                      _makeCellEditable(currentCellIndexX, currentCellIndexY, currentCellIndexX, currentCellIndexY - 1);
                    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) && currentCellIndexX >= 1) {
                      _makeCellEditable(currentCellIndexX, currentCellIndexY, currentCellIndexX - 1, currentCellIndexY);
                    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) && currentCellIndexX <= _marksGrid.length - 2) {
                      _makeCellEditable(currentCellIndexX, currentCellIndexY, currentCellIndexX + 1, currentCellIndexY);
                    } else {
                      _makeCellEditable(currentCellIndexX, currentCellIndexY, currentCellIndexX, currentCellIndexY);
                    }
                  });
                },
                focusNode: FocusNode(),
                autofocus: true,
                child: CustomScrollView(
                  controller: sliverScrollController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverAppBar(
                      pinned: false,
                      snap: false,
                      floating: false,
                      stretch: true,
                      onStretchTrigger: () {
                        return Future<void>.value();
                      },
                      toolbarHeight: 0,
                      collapsedHeight: 0,
                      leading: null,
                      backgroundColor: Colors.transparent,
                      expandedHeight: (MediaQuery.of(context).size.height / 2) + 50,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _examDetailsWidget(),
                        stretchModes: const <StretchMode>[
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground,
                          StretchMode.fadeTitle,
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      fillOverscroll: true,
                      child: _marksTableWidget(),
                    ),
                  ],
                ),
              ),
        floatingActionButton: _isLoading ? null : _changeEditModeButton());
  }

  // Future<void> _saveChanges() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(widget.examBean.examName ?? "-"),
  //         content: const Text("Are you sure to save changes?"),
  //         actions: <Widget>[
  //           TextButton(
  //               child: const Text("Yes"),
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 await _submitChanges();
  //               }),
  //           TextButton(
  //             child: const Text("Cancel"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _submitChanges() async {
    setState(() {
      _isLoading = true;
    });
    List<StudentMarksUpdateBean> x = _studentExamMarksDetailsList
        .where((e) => e.marksObtained != StudentExamMarksDetailsBean.fromJson(e.origJson()).marksObtained)
        .map((e) => StudentMarksUpdateBean(studentId: e.studentId, examId: e.examId, examTdsMapId: e.examTdsMapId, marksObtained: e.marksObtained))
        .toList();

    CreateOrUpdateStudentExamMarksRequest createOrUpdateStudentExamMarksRequest = CreateOrUpdateStudentExamMarksRequest(
      schoolId: widget.adminProfile.schoolId,
      agentId: widget.adminProfile.userId,
      studentExamMarksDetailsList: x,
    );
    CreateOrUpdateStudentExamMarksResponse createOrUpdateStudentExamMarksResponse =
        await createOrUpdateStudentExamMarks(createOrUpdateStudentExamMarksRequest);
    if (createOrUpdateStudentExamMarksResponse.httpStatus == "OK" && createOrUpdateStudentExamMarksResponse.responseStatus == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Success!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong!"),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _changeEditModeButton() {
    return GestureDetector(
      onTap: () {
        if (_isEditMode) {
          _submitChanges();
        }
        setState(() {
          _isEditMode = !_isEditMode;
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: _isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
        ),
      ),
    );
  }

  void _scrollToTableWithWaitTime() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (sliverScrollController.hasClients) {
        Future.delayed(
          const Duration(milliseconds: 2000),
          () {
            _scrollToTable();
          },
        );
      }
    });
  }

  void _scrollToTable() {
    sliverScrollController.animateTo(
      sliverScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
    );
  }

  Widget _examDetailsWidget() {
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
                            (widget.examBean.examName ?? "-").capitalize(),
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
              children: [
                Expanded(
                  flex: MediaQuery.of(context).orientation == Orientation.landscape ? 2 : 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          (widget.section.sectionName ?? "-").capitalize(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      _showMoreOptions(),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(25),
                    child: _buildMarkingSchemeWidgetForSectionWiseTdsMapBean(
                        (widget.examBean.examSectionMapBeanList ?? []).map((e) => e!).where((e) => e.sectionId == widget.section.sectionId).first),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _showMoreOptions() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _showInternalsButton(),
            _showPreviewButton(),
          ],
        ),
      ),
    );
  }

  Widget _showInternalsButton() {
    return ((_examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e!).map((e) => e.internalExamTdsMapBeanList ?? [])).expand((i) => i).isEmpty
        ? Container()
        : Container(
            margin: const EdgeInsets.all(10),
            child: ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    const Center(child: Text("Show Internals")),
                    const SizedBox(
                      width: 5,
                    ),
                    Switch(
                      onChanged: (bool newValue) {
                        setState(() {
                          _showInternals = newValue;
                        });
                      },
                      value: _showInternals,
                      autofocus: false,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                )),
          );
  }

  Widget _showPreviewButton() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 5,
              ),
              const Center(child: Text("Show Preview")),
              const SizedBox(
                width: 5,
              ),
              Switch(
                onChanged: (bool newValue) {
                  setState(() {
                    _showPreview = newValue;
                  });
                },
                value: _showPreview,
                autofocus: false,
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          )),
    );
  }

  Widget _buildMarkingSchemeWidgetForSectionWiseTdsMapBean(ExamSectionMapBean eachSectionWiseTdsMapBean) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      emboss: true,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Marking Algorithm: ${eachSectionWiseTdsMapBean.markingAlgorithmName ?? "-"}"),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Results are shown in"),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _markingSchemeButtonForSection("Marks"),
                ),
                Expanded(
                  child: _markingSchemeButtonForSection("Grade"),
                ),
                Expanded(
                  child: _markingSchemeButtonForSection("GPA"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _markingSchemeButtonForSection(String type) {
    Color color = clayContainerColor(context);
    MarkingSchemeCode? x = fromMarkingSchemeCodeString(
        (widget.examBean.examSectionMapBeanList ?? []).where((e) => e != null && e.sectionId == widget.section.sectionId).first?.markingSchemeCode ??
            "-");
    bool _isMarksForBean = x == null ? false : x.value[0] == "T";
    bool _isGradeForBean = x == null ? false : x.value[1] == "T";
    bool _isGpaForBean = x == null ? false : x.value[2] == "T";
    if ((type == "Marks" && _isMarksForBean) || (type == "Grade" && _isGradeForBean) || (type == "GPA" && _isGpaForBean)) {
      color = Colors.blue.shade300;
    }
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayContainer(
        depth: 40,
        surfaceColor: color,
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 100,
        emboss: color == Colors.blue.shade300,
        child: Container(
          width: 15,
          margin: const EdgeInsets.all(5),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(type),
            ),
          ),
        ),
      ),
    );
  }

  Widget _marksTableWidget() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 750),
      child: !_isEditMode && _showInternals
          ? Column(
              children: [
                _headerWidget(),
                _subHeaderWidget(),
                Expanded(child: _studentWiseMarksWidget()),
              ],
            )
          : Column(
              children: [
                _headerWidget(),
                Expanded(child: _studentWiseMarksWidget()),
              ],
            ),
    );
  }

  Widget _headerWidget() {
    return Row(
      children: [
        Expanded(
          flex: _lhsFlex,
          child: InkWell(
            onTap: _scrollToTable,
            child: Padding(
              padding: const EdgeInsets.all(_cellPadding),
              child: ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: _headerColor,
                spread: 2,
                borderRadius: 10,
                height: _studentColumnHeight,
                width: _studentColumnWidth,
                child: Center(child: Text(widget.section.sectionName ?? "-")),
              ),
            ),
          ),
        ),
        Expanded(
          flex: _rhsFlex,
          child: SingleChildScrollView(
            controller: _header,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < _subjects.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(_cellPadding),
                    child: ClayContainer(
                      depth: 40,
                      parentColor: clayContainerColor(context),
                      surfaceColor: _headerColor,
                      spread: 2,
                      borderRadius: 10,
                      height: _cellColumnHeight,
                      width: !_isEditMode && _showInternals
                          ? (_cellColumnWidth * ((_marksGrid[0][i].studentInternalExamMarksDetailsBeanList ?? []).length + 1)) +
                              (2 * (_marksGrid[0][i].studentInternalExamMarksDetailsBeanList ?? []).length)
                          : (_marksGrid[0][i].studentInternalExamMarksDetailsBeanList ?? []).isEmpty
                              ? _cellColumnWidth
                              : _cellColumnWidth - _cellPadding,
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              ((_subjects[i].subjectName ?? "-").capitalize()),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          (!_isEditMode && _showInternals ||
                                  ((_examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e!).map((e) => e.internalExamTdsMapBeanList ?? []))
                                      .expand((i) => i)
                                      .isNotEmpty)
                              ? Container()
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Max marks: ${_marksGrid[0][i].maxMarks}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: clayContainerTextColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _subHeaderWidget() {
    if (((_examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e!).map((e) => e.internalExamTdsMapBeanList ?? [])).expand((i) => i).isEmpty) {
      return Container();
    }
    List<Widget> _subHeaders = [];
    for (int i = 0; i < _subjects.length; i++) {
      for (StudentInternalExamMarksDetailsBean eachInternalExamBean
          in (_marksGrid[0][i].studentInternalExamMarksDetailsBeanList ?? []).map((e) => e!)) {
        _subHeaders.add(
          Padding(
            padding: const EdgeInsets.all(_cellPadding),
            child: Tooltip(
              message: eachInternalExamBean.internalExamName ?? "-",
              child: ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: _headerColor,
                spread: 2,
                borderRadius: 10,
                height: _cellColumnHeight,
                width: _cellColumnWidth - _cellPadding,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        (eachInternalExamBean.internalNumber == null ? "-" : "Internal ${eachInternalExamBean.internalNumber}").capitalize(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Max marks: ${eachInternalExamBean.internalsMaxMarks}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: clayContainerTextColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      _subHeaders.add(
        Padding(
          padding: const EdgeInsets.all(_cellPadding),
          child: ClayContainer(
            depth: 40,
            parentColor: clayContainerColor(context),
            surfaceColor: _headerColor,
            spread: 2,
            borderRadius: 10,
            height: _cellColumnHeight,
            width: _cellColumnWidth - _cellPadding,
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    ("External"),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Max marks: ${_marksGrid[0][i].maxMarks}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: clayContainerTextColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          flex: _lhsFlex,
          child: Padding(
            padding: const EdgeInsets.all(_cellPadding),
            child: ClayContainer(
              depth: 40,
              parentColor: clayContainerColor(context),
              surfaceColor: _headerColor,
              spread: 2,
              borderRadius: 10,
              height: _studentColumnHeight,
              width: _studentColumnWidth,
              child: const Center(child: Text("Student Name")),
            ),
          ),
        ),
        Expanded(
          flex: _rhsFlex,
          child: SingleChildScrollView(
            controller: _subHeader,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _subHeaders,
            ),
          ),
        ),
      ],
    );
  }

  Widget _subHeaderWidgetForPreview() {
    if (((_examSectionMapBean.examTdsMapBeanList ?? []).map((e) => e!).map((e) => e.internalExamTdsMapBeanList ?? [])).expand((i) => i).isEmpty) {
      return Container();
    }
    List<Widget> _subHeaders = [];
    for (int i = 0; i < _subjects.length; i++) {
      for (StudentInternalExamMarksDetailsBean eachInternalExamBean
          in (_marksGrid[0][i].studentInternalExamMarksDetailsBeanList ?? []).map((e) => e!)) {
        _subHeaders.add(
          Padding(
            padding: const EdgeInsets.all(_cellPadding),
            child: Tooltip(
              message: eachInternalExamBean.internalExamName ?? "-",
              child: ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: _headerColor,
                spread: 2,
                borderRadius: 10,
                height: _cellColumnHeight,
                width: _cellColumnWidth - _cellPadding,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        (eachInternalExamBean.internalNumber == null ? "-" : "Internal ${eachInternalExamBean.internalNumber}").capitalize(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Max marks: ${eachInternalExamBean.internalsMaxMarks}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: clayContainerTextColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      _subHeaders.add(
        Padding(
          padding: const EdgeInsets.all(_cellPadding),
          child: ClayContainer(
            depth: 40,
            parentColor: clayContainerColor(context),
            surfaceColor: _headerColor,
            spread: 2,
            borderRadius: 10,
            height: _cellColumnHeight,
            width: _cellColumnWidth - _cellPadding,
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    ("External"),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Max marks: ${_marksGrid[0][i].maxMarks}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: clayContainerTextColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          flex: _lhsFlex,
          child: Padding(
            padding: const EdgeInsets.all(_cellPadding),
            child: ClayContainer(
              depth: 40,
              parentColor: clayContainerColor(context),
              surfaceColor: _headerColor,
              spread: 2,
              borderRadius: 10,
              height: _studentColumnHeight,
              width: _studentColumnWidth,
              child: const Center(child: Text("Student Name")),
            ),
          ),
        ),
        Expanded(
          flex: _rhsFlex,
          child: SingleChildScrollView(
            controller: _subHeader,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _subHeaders,
            ),
          ),
        ),
      ],
    );
  }

  Widget _studentWiseMarksWidget() {
    return Row(
      children: [
        Expanded(
          flex: _lhsFlex,
          child: ListView(
            shrinkWrap: true,
            controller: _studentsController,
            children: <Widget>[
              for (int j = 0; j < _students.length; j++)
                Padding(
                  padding: const EdgeInsets.all(_cellPadding),
                  child: ClayContainer(
                    depth: 40,
                    surfaceColor: _headerColor,
                    parentColor: clayContainerColor(context),
                    spread: 2,
                    borderRadius: 10,
                    height: _studentColumnHeight,
                    width: _studentColumnWidth,
                    child: Center(child: Text((_students[j].rollNumber ?? "-") + (". ") + (_students[j].studentFirstName ?? "-").capitalize())),
                  ),
                )
            ],
          ),
        ),
        Expanded(
          flex: _rhsFlex,
          child: ListView(
            shrinkWrap: true,
            controller: _marksController,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [for (int i = 0; i < _students.length; i++) i].map((i) {
                  return SingleChildScrollView(
                    controller: _scrollControllers[i],
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int j = 0; j < _subjects.length; j++)
                          GestureDetector(
                            onTap: () {
                              // _onPointerDown(j,i);
                              _makeCellEditable(currentCellIndexX, currentCellIndexY, i, j);
                            },
                            child: EachMarksCell(
                              section: widget.section,
                              adminProfile: widget.adminProfile,
                              examBean: widget.examBean,
                              marksBean: _marksGrid[i][j],
                              isEditMode: _isEditMode,
                              showInternals: !_isEditMode && _showInternals,
                              markingAlgorithm: _markingAlgorithm,
                              previewMode: _showPreview,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _makeCellEditable(int oldIndexX, int oldIndexY, int newIndexX, int newIndexY) {
    setState(() {
      _marksGrid[oldIndexX][oldIndexY].isMarksEditable = false;
      _marksGrid[newIndexX][newIndexY].isMarksEditable = true;
      currentCellIndexX = newIndexX;
      currentCellIndexY = newIndexY;
    });
  }
}

//ignore: must_be_immutable
class EachMarksCell extends StatefulWidget {
  EachMarksCell({
    Key? key,
    required this.adminProfile,
    required this.examBean,
    required this.section,
    required this.marksBean,
    required this.isEditMode,
    required this.showInternals,
    required this.markingAlgorithm,
    required this.previewMode,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final AdminExamBean examBean;
  final Section section;
  final bool isEditMode;
  StudentExamMarksDetailsBean marksBean;
  final bool showInternals;
  final MarkingAlgorithmBean? markingAlgorithm;
  final bool previewMode;

  @override
  _EachMarksCellState createState() => _EachMarksCellState();
}

class _EachMarksCellState extends State<EachMarksCell> {
  late FocusNode _focusNode;

  static const double _cellHeight = 60;
  static const double _width = 80;
  static const double _cellPadding = 4.0;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.marksBean.marksEditingController.selection =
            TextSelection(baseOffset: 0, extentOffset: widget.marksBean.marksEditingController.text.length);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (StudentInternalExamMarksDetailsBean eachInternal
            in (widget.marksBean.studentInternalExamMarksDetailsBeanList ?? []).where((e) => e != null).map((e) => e!))
          if (widget.showInternals)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                height: _cellHeight,
                width: (widget.marksBean.studentInternalExamMarksDetailsBeanList ?? []).where((e) => e != null).map((e) => e!).isEmpty
                    ? _width + (2 * _cellPadding)
                    : _width + (_cellPadding),
                child: Center(
                  child: Text(
                    "${(eachInternal.internalsMarksObtained ?? -1) == -1 ? "-" : eachInternal.internalsMarksObtained == -2 ? "A" : eachInternal.internalsMarksObtained}",
                  ),
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.all(_cellPadding),
          child: ClayContainer(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 2,
            borderRadius: 10,
            height: _cellHeight,
            width: (widget.marksBean.studentInternalExamMarksDetailsBeanList ?? []).where((e) => e != null).map((e) => e!).isEmpty
                ? _width + (2 * _cellPadding)
                : _width + (_cellPadding),
            child: Center(
              child: widget.previewMode
                  ? Text(
                      widget.marksBean.grade ?? "-",
                    )
                  : widget.isEditMode && widget.marksBean.isMarksEditable
                      ? InputDecorator(
                          isFocused: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusColor: Colors.blue,
                          ),
                          child: TextField(
                            focusNode: _focusNode,
                            autofocus: true,
                            keyboardType: TextInputType.text,
                            controller: widget.marksBean.marksEditingController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (String e) {
                              setState(() {
                                if (e == "A") {
                                  widget.marksBean.setMarks(-2, widget.markingAlgorithm);
                                } else if (e == "-") {
                                  widget.marksBean.setMarks(-1, widget.markingAlgorithm);
                                } else {
                                  widget.marksBean.setMarks(int.tryParse(e) ?? 0, widget.markingAlgorithm);
                                }
                              });
                            },
                            inputFormatters: <TextInputFormatter>[MarksInputFormatter()],
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Text(
                          "${(widget.marksBean.marksObtained ?? -1) == -1 ? "-" : widget.marksBean.marksObtained == -2 ? "A" : widget.marksBean.marksObtained}",
                        ),
            ),
          ),
        ),
      ],
    );
  }
}
