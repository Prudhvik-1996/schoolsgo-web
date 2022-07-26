import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminMarkStudentAttendanceScreen extends StatefulWidget {
  const AdminMarkStudentAttendanceScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  _AdminMarkStudentAttendanceScreenState createState() => _AdminMarkStudentAttendanceScreenState();
}

class _AdminMarkStudentAttendanceScreenState extends State<AdminMarkStudentAttendanceScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _selectedDate = DateTime.now();

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionPickerOpen = false;

  bool _showOnlyAbsentees = false;

  List<AttendanceTimeSlotBean> attendanceTimeSlotBeans = [];
  List<_StudentWiseAttendanceTimeSlot> studentWiseAttendanceBeans = [];

  late LinkedScrollControllerGroup _verticalControllers;
  late ScrollController _studentsController;
  late ScrollController _studentWiseAttendanceController;
  late ScrollController _header;
  late ScrollController _subHeader;
  late LinkedScrollControllerGroup _horizontalControllers;
  late final List<ScrollController> _scrollControllers = [];
  ScrollController sliverScrollController = ScrollController();

  static const double _studentColumnWidth = 150;
  static const double _studentColumnHeight = 60;
  static const double _cellColumnWidth = 150;
  static const double _cellColumnHeight = 60;
  late final Color _headerColor = clayContainerColor(context);
  static final Color _headerTextColor = Colors.blue.shade300;
  static const double _cellPadding = 4.0;
  final int _lhsFlex = 1;
  final int _rhsFlex = 4;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _studentsController.dispose();
    _studentWiseAttendanceController.dispose();
    _header.dispose();
    _subHeader.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadStudentAttendance() async {
    if (_selectedSection == null) return;
    List<StudentAttendanceBean> studentAttendanceBeans = [];
    List<StudentProfile> studentProfiles = [];
    setState(() {
      _isLoading = true;
      studentWiseAttendanceBeans = [];
    });
    GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse = await getStudentAttendanceBeans(GetStudentAttendanceBeansRequest(
      schoolId: widget.adminProfile.schoolId,
      date: convertDateTimeToYYYYMMDDFormat(_selectedDate),
      sectionId: _selectedSection!.sectionId,
      // studentId: 71,
    ));
    if (getStudentAttendanceBeansResponse.httpStatus == "OK" && getStudentAttendanceBeansResponse.responseStatus == "success") {
      setState(() {
        studentAttendanceBeans = getStudentAttendanceBeansResponse.studentAttendanceBeans ?? [];
        attendanceTimeSlotBeans = getStudentAttendanceBeansResponse.attendanceTimeSlotBeans ?? [];
        studentProfiles = studentAttendanceBeans
            .where((e) => e.studentId != null)
            .map((e) => e.studentId!)
            .toSet()
            .toList()
            .map((int eachStudentId) => StudentProfile(
                  studentId: eachStudentId,
                  schoolId: widget.adminProfile.schoolId,
                  sectionId: _selectedSection?.sectionId,
                  sectionName: _selectedSection?.sectionName,
                  studentFirstName: studentAttendanceBeans.where((e) => e.studentId == eachStudentId).firstOrNull?.studentName,
                  rollNumber: (studentAttendanceBeans.where((e) => e.studentId == eachStudentId).firstOrNull?.studentRollNumber)?.toString(),
                ))
            .toList();
        for (StudentProfile eachStudentProfile in studentProfiles) {
          if (studentWiseAttendanceBeans.where((e) => e.studentProfile.studentId == eachStudentProfile.studentId).isEmpty) {
            studentWiseAttendanceBeans.add(
              _StudentWiseAttendanceTimeSlot(
                studentProfile: eachStudentProfile,
                studentAttendanceBeans: studentAttendanceBeans.where((eachATS) => eachATS.studentId == eachStudentProfile.studentId).toList()
                  ..sort((a, b) =>
                      getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime, null).compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime, null))),
              ),
            );
          }
        }
        studentWiseAttendanceBeans.sort(
          (a, b) => (int.tryParse(a.studentProfile.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.studentProfile.rollNumber ?? "0") ?? 0),
        );
        _verticalControllers = LinkedScrollControllerGroup();
        _studentsController = _verticalControllers.addAndGet();
        _studentWiseAttendanceController = _verticalControllers.addAndGet();

        _horizontalControllers = LinkedScrollControllerGroup();
        _header = _horizontalControllers.addAndGet();
        _subHeader = _horizontalControllers.addAndGet();
        _scrollControllers.clear();
        for (int i = 0; i < studentProfiles.length; i++) {
          _scrollControllers.add(_horizontalControllers.addAndGet());
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Mark Attendance"),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _sectionPicker(),
                      ),
                      if (!_isSectionPickerOpen)
                        Expanded(
                          flex: 2,
                          child: _getDatePicker(),
                        ),
                      if (!_isSectionPickerOpen && attendanceTimeSlotBeans.isNotEmpty && MediaQuery.of(context).orientation == Orientation.landscape)
                        Expanded(
                          flex: 1,
                          child: _showOnlyAbsenteesButton(),
                        ),
                      _isSectionPickerOpen || _selectedSection == null || widget.adminProfile.isMegaAdmin ? Container() : buildEditButton(context),
                    ],
                  ),
                  if (!_isSectionPickerOpen && attendanceTimeSlotBeans.isNotEmpty && MediaQuery.of(context).orientation == Orientation.portrait)
                    _showOnlyAbsenteesButton(),
                  if (attendanceTimeSlotBeans.isEmpty)
                    _selectedSection == null
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(10, 50, 10, 50),
                            child: const Center(
                              child: Text(
                                "Select a section to mark attendance..",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _selectedDate.weekday == 7
                            ? _noTimeSlotsForSundayWidget()
                            : _noTimeSlotsWidget(),
                  if (attendanceTimeSlotBeans.isNotEmpty) _headerWidget(),
                  if (attendanceTimeSlotBeans.isNotEmpty && _isEditMode) _subHeaderWidget(),
                  if (attendanceTimeSlotBeans.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height - (_isEditMode ? 4 : 3) * (_cellColumnHeight + _cellPadding + _cellPadding),
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            _studentAttendanceWidgets(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _noTimeSlotsWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 50, 10, 50),
      child: const Center(
        child: Text(
          "No time slots are assigned for the day..",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _noTimeSlotsForSundayWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 50, 10, 50),
      child: const Center(
        child: Text(
          "Its Sunday..\n"
          "No time slots are assigned for the day..",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _showOnlyAbsenteesButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? const EdgeInsets.fromLTRB(10, 10, 10, 10)
          : const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: InkWell(
          onTap: () {
            setState(() {
              _showOnlyAbsentees = !_showOnlyAbsentees;
            });
          },
          child: ClayContainer(
            depth: 40,
            surfaceColor: Colors.red.shade400,
            parentColor: clayContainerColor(context),
            spread: 2,
            borderRadius: 10,
            emboss: _showOnlyAbsentees,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Show only\nabsentees",
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget _headerWidget() {
    return Row(
      children: [
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          Expanded(
            flex: _lhsFlex,
            child: const Text(""),
          ),
        Expanded(
          flex: MediaQuery.of(context).orientation == Orientation.landscape ? _lhsFlex : 2,
          child: InkWell(
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
                child: Center(
                  child: Text(
                    _selectedSection?.sectionName ?? "-",
                    style: TextStyle(
                      color: _headerTextColor,
                    ),
                  ),
                ),
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
                for (int i = 0; i < attendanceTimeSlotBeans.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(_cellPadding),
                    child: GestureDetector(
                      onTap: () {
                        int noOfStudentsPresent = studentWiseAttendanceBeans
                            .map((e) => e.studentAttendanceBeans)
                            .expand((i) => i)
                            .where((e) => e.attendanceTimeSlotId == attendanceTimeSlotBeans[i].attendanceTimeSlotId)
                            .where((e) => e.isPresent == 1)
                            .length;
                        int noOfStudentsAbsent = studentWiseAttendanceBeans
                            .map((e) => e.studentAttendanceBeans)
                            .expand((i) => i)
                            .where((e) => e.attendanceTimeSlotId == attendanceTimeSlotBeans[i].attendanceTimeSlotId)
                            .where((e) => e.isPresent == -1)
                            .length;
                        String presentStats =
                            "${attendanceTimeSlotBeans[i].startTime == null ? " - " : formatHHMMSStoHHMMA(attendanceTimeSlotBeans[i].startTime!)} - ${attendanceTimeSlotBeans[i].endTime == null ? " - " : formatHHMMSStoHHMMA(attendanceTimeSlotBeans[i].endTime!)}\n"
                            "Attendance Manager: ${attendanceTimeSlotBeans[i].managerName}\n\n"
                            "No. of students present: $noOfStudentsPresent\n"
                            "No. of students absent: $noOfStudentsAbsent\n";
                        showDialog(
                          context: _scaffoldKey.currentContext!,
                          builder: (currentContext) {
                            return AlertDialog(
                              elevation: 0,
                              title: const Text("Attendance"),
                              content: Text(presentStats),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Ok"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: ClayButton(
                        depth: 40,
                        parentColor: clayContainerColor(context),
                        surfaceColor: _headerColor,
                        spread: 2,
                        borderRadius: 10,
                        height: _cellColumnHeight,
                        width: _cellColumnWidth,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              ("${attendanceTimeSlotBeans[i].startTime == null ? " - " : formatHHMMSStoHHMMA(attendanceTimeSlotBeans[i].startTime!)} - ${attendanceTimeSlotBeans[i].endTime == null ? " - " : formatHHMMSStoHHMMA(attendanceTimeSlotBeans[i].endTime!)}\n${attendanceTimeSlotBeans[i].managerName}"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _headerTextColor,
                              ),
                            ),
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
    );
  }

  Widget _subHeaderWidget() {
    return Row(
      children: [
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          Expanded(
            flex: _lhsFlex,
            child: const Text(""),
          ),
        Expanded(
          flex: MediaQuery.of(context).orientation == Orientation.landscape ? _lhsFlex : 2,
          child: InkWell(
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
                child: const Center(child: Text("")),
              ),
            ),
          ),
        ),
        Expanded(
          flex: _rhsFlex,
          child: SingleChildScrollView(
            controller: _subHeader,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < attendanceTimeSlotBeans.length; i++)
                  Padding(
                    padding: const EdgeInsets.all(_cellPadding),
                    child: ClayContainer(
                      depth: 40,
                      parentColor: clayContainerColor(context),
                      surfaceColor: _headerColor,
                      spread: 2,
                      borderRadius: 10,
                      height: _cellColumnHeight,
                      width: _cellColumnWidth,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: InkWell(
                              child: Image.asset(
                                'assets/images/tick_icon.png',
                                height: 30,
                                width: 30,
                              ),
                              onTap: () {
                                for (int k = 0; k < studentWiseAttendanceBeans.length; k++) {
                                  setState(() {
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].isPresent = 1;
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].agent = widget.adminProfile.userId;
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].markedById = widget.adminProfile.userId;
                                  });
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              child: Image.asset(
                                'assets/images/cross_icon.png',
                                height: 30,
                                width: 30,
                              ),
                              onTap: () {
                                for (int k = 0; k < studentWiseAttendanceBeans.length; k++) {
                                  setState(() {
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].isPresent = -1;
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].agent = widget.adminProfile.userId;
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].markedById = widget.adminProfile.userId;
                                  });
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              child: const Icon(
                                Icons.delete,
                                size: 24,
                                color: Colors.black,
                              ),
                              onTap: () {
                                for (int k = 0; k < studentWiseAttendanceBeans.length; k++) {
                                  setState(() {
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].isPresent = 0;
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].agent = widget.adminProfile.userId;
                                    studentWiseAttendanceBeans[k].studentAttendanceBeans[i].markedById = widget.adminProfile.userId;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _studentAttendanceWidgets() {
    List<_StudentWiseAttendanceTimeSlot> studentWiseAttendanceBeansToBeDisplayed = studentWiseAttendanceBeans
        .where((eachWiseStudentAttendanceBean) =>
            (!_showOnlyAbsentees) ||
            (_showOnlyAbsentees &&
                eachWiseStudentAttendanceBean.studentAttendanceBeans
                    .where((eachStudentAttendanceBean) => eachStudentAttendanceBean.isPresent != 1)
                    .isNotEmpty))
        .toList();
    return Row(
      children: [
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          Expanded(
            flex: _lhsFlex,
            child: const Text(""),
          ),
        Expanded(
          flex: MediaQuery.of(context).orientation == Orientation.landscape ? _lhsFlex : 2,
          child: ListView(
            shrinkWrap: true,
            controller: _studentsController,
            children: <Widget>[
              for (int j = 0; j < studentWiseAttendanceBeansToBeDisplayed.length; j++)
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Text(
                          (studentWiseAttendanceBeansToBeDisplayed[j].studentProfile.rollNumber ?? "-") +
                              (". ") +
                              (studentWiseAttendanceBeansToBeDisplayed[j].studentProfile.studentFirstName ?? "-").capitalize(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: _rhsFlex,
          child: ListView(
            shrinkWrap: true,
            controller: _studentWiseAttendanceController,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [for (int i = 0; i < studentWiseAttendanceBeansToBeDisplayed.length; i++) i].map((i) {
                  return SingleChildScrollView(
                    controller: _scrollControllers[i],
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for (int j = 0; j < attendanceTimeSlotBeans.length; j++)
                          Padding(
                            padding: const EdgeInsets.all(_cellPadding),
                            child: ClayContainer(
                              depth: 40,
                              surfaceColor: _headerColor,
                              parentColor: clayContainerColor(context),
                              spread: 2,
                              borderRadius: 10,
                              height: _cellColumnHeight,
                              width: _cellColumnWidth,
                              child: _isEditMode ? _editModeSwitchCell(i, j) : _readModeCell(i, j),
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

  Center _readModeCell(int i, int j) {
    int isPresent = studentWiseAttendanceBeans[i].studentAttendanceBeans[j].isPresent ?? 0;
    return Center(
      child: isPresent == -1
          ? Image.asset(
              'assets/images/cross_icon.png',
              height: 30,
              width: 30,
            )
          : isPresent == 1
              ? Image.asset(
                  'assets/images/tick_icon.png',
                  height: 30,
                  width: 30,
                )
              : Image.asset(
                  'assets/images/empty_stroke.png',
                  height: 30,
                  width: 30,
                ),
    );
  }

  Widget _editModeSwitchCell(int i, int j) {
    int isPresent = studentWiseAttendanceBeans[i].studentAttendanceBeans[j].isPresent ?? 0;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: FlutterSwitch(
        activeText: isPresent == 0 ? "" : "Present",
        inactiveText: isPresent == 0 ? "" : "Absent",
        activeColor: isPresent == 0 ? Colors.grey : Colors.green.shade400,
        inactiveColor: isPresent == 0 ? Colors.grey : Colors.red.shade400,
        width: 75,
        value: isPresent == 1,
        disabled: isPresent == 0,
        valueFontSize: 10.0,
        borderRadius: 30.0,
        showOnOff: true,
        onToggle: (newValue) {
          setState(() {
            studentWiseAttendanceBeans[i].studentAttendanceBeans[j].isPresent = newValue ? 1 : -1;
          });
        },
      ),
    );
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: GestureDetector(
        onTap: () async {
          if (_isEditMode) return;
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2021),
            lastDate: DateTime.now(),
            helpText: "Pick  date to mark attendance",
          );
          setState(() {
            _selectedDate = _newDate ?? _selectedDate;
          });
          await _loadStudentAttendance();
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      convertDateTimeToDDMMYYYYFormat(_selectedDate),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogueContext) {
        return AlertDialog(
          title: const Text('Attendance Management'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
                child: const Text("Yes"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _isLoading = true;
                  });
                  CreateOrUpdateStudentAttendanceRequest createOrUpdateStudentAttendanceRequest = CreateOrUpdateStudentAttendanceRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId,
                    studentAttendanceBeans: studentWiseAttendanceBeans
                        .map((e) => e.studentAttendanceBeans)
                        .expand((i) => i)
                        .where((e) => !const DeepCollectionEquality().equals(e.toJson(), e.origJson()))
                        .toList(),
                  );
                  CreateOrUpdateStudentAttendanceResponse createOrUpdateStudentAttendanceResponse =
                      await createOrUpdateStudentAttendance(createOrUpdateStudentAttendanceRequest);
                  if (createOrUpdateStudentAttendanceResponse.httpStatus == "OK" &&
                      createOrUpdateStudentAttendanceResponse.responseStatus == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Success!"),
                      ),
                    );
                    setState(() {
                      _isEditMode = false;
                    });
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
                }),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
                _loadStudentAttendance();
                setState(() {
                  _isEditMode = false;
                });
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSectionPickerOpen = false;
        });
        if (_isEditMode) {
          _saveChanges();
        } else {
          setState(() {
            _isEditMode = !_isEditMode;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
        child: _isEditMode
            ? ClayButton(
                color: clayContainerColor(context),
                height: 50,
                width: 50,
                borderRadius: 100,
                spread: 4,
                child: const Icon(
                  Icons.check,
                ),
              )
            : ClayButton(
                color: clayContainerColor(context),
                height: 50,
                width: 50,
                borderRadius: 100,
                spread: 4,
                child: const Icon(
                  Icons.edit,
                ),
              ),
      ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: _isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget _buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          setState(() {
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
              _loadStudentAttendance();
            }
            _isSectionPickerOpen = false;
          });
        },
        child: ClayButton(
          depth: 40,
          spread: _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              section.sectionName!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            shrinkWrap: true,
            children: _sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          if (_isLoading) return;
          if (_isEditMode) return;
          setState(() {
            _isSectionPickerOpen = !_isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _selectedSection == null ? "Section" : "${_selectedSection!.sectionName}",
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentWiseAttendanceTimeSlot {
  late StudentProfile studentProfile;
  late List<StudentAttendanceBean> studentAttendanceBeans;

  _StudentWiseAttendanceTimeSlot({
    required this.studentProfile,
    required this.studentAttendanceBeans,
  });
}
