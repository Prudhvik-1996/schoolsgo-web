import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/app_expansion_tile.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AdminMarkAttendanceScreen extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminMarkAttendanceScreen({Key? key, required this.adminProfile})
      : super(key: key);

  @override
  _AdminMarkAttendanceScreenState createState() =>
      _AdminMarkAttendanceScreenState();
}

class _AdminMarkAttendanceScreenState extends State<AdminMarkAttendanceScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  DateTime _selectedDate = DateTime.now();

  List<Section> _sectionsList = [];
  Section? _selectedSection;

  List<StudentAttendanceBean> _studentAttendanceBeans = [];
  List<AttendanceTimeSlotBean> _attendanceTimeSlotBeans = [];
  List<StudentProfile> _studentProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isEditMode = false;
      _sectionsList = [];
      _studentAttendanceBeans = [];
      _attendanceTimeSlotBeans = [];
      _studentProfiles = [];
    });

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse =
        await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" &&
        getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });

    _loadStudentAttendance();
  }

  Future<void> _loadStudentAttendance() async {
    if (_selectedSection == null) return;
    setState(() {
      _isLoading = true;
    });

    GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse =
        await getStudentAttendanceBeans(GetStudentAttendanceBeansRequest(
      schoolId: widget.adminProfile.schoolId,
      date: convertDateTimeToYYYYMMDDFormat(_selectedDate),
      sectionId: _selectedSection!.sectionId,
    ));
    if (getStudentAttendanceBeansResponse.httpStatus == "OK" &&
        getStudentAttendanceBeansResponse.responseStatus == "success") {
      setState(() {
        _studentAttendanceBeans =
            getStudentAttendanceBeansResponse.studentAttendanceBeans!;
        _attendanceTimeSlotBeans =
            getStudentAttendanceBeansResponse.attendanceTimeSlotBeans!;
        _studentProfiles = _studentAttendanceBeans
            .map(
              (e) => StudentProfile(
                  sectionId: e.sectionId,
                  schoolId: widget.adminProfile.schoolId,
                  studentId: e.studentId,
                  rollNumber: "${e.studentRollNumber}",
                  studentFirstName: e.studentName),
            )
            .toSet()
            .toList();
        _studentProfiles.sort((a, b) => (int.tryParse(a.rollNumber!) ?? 0)
            .compareTo((int.tryParse(b.rollNumber!) ?? 0)));
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  CreateOrUpdateStudentAttendanceRequest
                      createOrUpdateStudentAttendanceRequest =
                      CreateOrUpdateStudentAttendanceRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId,
                    studentAttendanceBeans: _studentAttendanceBeans
                        .where((e) => e.isEdited ?? false)
                        .toList(),
                  );
                  CreateOrUpdateStudentAttendanceResponse
                      createOrUpdateStudentAttendanceResponse =
                      await createOrUpdateStudentAttendance(
                          createOrUpdateStudentAttendanceRequest);
                  if (createOrUpdateStudentAttendanceResponse.httpStatus ==
                          "OK" &&
                      createOrUpdateStudentAttendanceResponse.responseStatus ==
                          "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Success!"),
                      ),
                    );
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong!"),
                      ),
                    );
                  }
                  setState(() {
                    _isLoading = true;
                  });
                }),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
                _loadData();
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
          _loadStudentAttendance();
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                "Date: ${convertDateTimeToDDMMYYYYFormat(_selectedDate)}",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_selectedSection == section) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
          });
          _loadStudentAttendance();
        },
        child: ClayContainer(
          depth: 40,
          color: _selectedSection == section
              ? Colors.blue[200]
              : clayContainerColor(context),
          spread: _selectedSection == section ? 0 : 2,
          borderRadius: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: Center(
              child: Text(
                section.sectionName!,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionsFilter() {
    final GlobalKey<AppExpansionTileState> expansionTile = GlobalKey();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: AppExpansionTile(
            allowExpansion: !_isEditMode,
            key: expansionTile,
            title: Text(
              _selectedSection == null
                  ? "Select a section"
                  : "Section: ${_selectedSection!.sectionName}",
            ),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.all(7),
                child: GridView.count(
                  childAspectRatio: 2.25,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
                  shrinkWrap: true,
                  children: _sectionsList
                      .map((e) => buildSectionCheckBox(e))
                      .toList(),
                ),
              ),
            ],
            onExpansionChanged: (val) {},
          ),
        ),
      ),
    );
  }

  Widget _studentDetailsColumns() {
    return Column(
      children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              padding: const EdgeInsets.all(8),
              height: 100,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                color: Colors.lightBlueAccent,
              ),
              child: const Center(
                child: Text(
                  "Roll No.\nStudent Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ] +
          _studentProfiles.map(
            (_eachStudent) {
              String _rollNumber = "N/A";
              String _name = "N/A";

              _rollNumber = _eachStudent.rollNumber == null
                  ? "N/A"
                  : _eachStudent.rollNumber.toString();
              _name = _eachStudent.studentFirstName!;

              return Container(
                height: 100,
                width: 250,
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  color: Colors.lightBlueAccent,
                ),
                child: Text(
                  _rollNumber + ". " + _name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              );
            },
          ).toList(),
    );
  }

  Widget markAttendanceButton(
      StudentAttendanceBean studentAttendanceBean, int markPresent) {
    return GestureDetector(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: markPresent == 1
                ? Colors.green
                : markPresent == -1
                    ? Colors.red
                    : Colors.blue,
          ),
          borderRadius: BorderRadius.circular(10),
          color: markPresent == 1
              ? Colors.greenAccent[200]
              : markPresent == -1
                  ? Colors.red[200]
                  : Colors.blue[200],
        ),
        padding: const EdgeInsets.all(10),
        child: markPresent == 1
            ? Image.asset('assets/images/tick_icon.png')
            : markPresent == -1
                ? Image.asset('assets/images/cross_icon.png')
                : Image.asset('assets/images/empty_stroke.png'),
      ),
      onTap: () {
        if (studentAttendanceBean.isPresent == markPresent) {
          setState(() {
            studentAttendanceBean.isPresent = 0;
            studentAttendanceBean.markedById = widget.adminProfile.userId;
            studentAttendanceBean.agent = widget.adminProfile.userId;
            studentAttendanceBean.isEdited = true;
          });
        } else {
          setState(() {
            studentAttendanceBean.isPresent = markPresent;
            studentAttendanceBean.markedById = widget.adminProfile.userId;
            studentAttendanceBean.agent = widget.adminProfile.userId;
            studentAttendanceBean.isEdited = true;
          });
        }
      },
    );
  }

  Widget markAttendanceForAllStudentsButton(int atsId, int markPresent) {
    return GestureDetector(
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: markPresent == 1
                ? Colors.green
                : markPresent == -1
                    ? Colors.red
                    : Colors.black,
          ),
          borderRadius: BorderRadius.circular(10),
          color: markPresent == 1
              ? Colors.greenAccent[200]
              : markPresent == -1
                  ? Colors.red[200]
                  : Colors.lightBlueAccent,
        ),
        padding: const EdgeInsets.all(10),
        child: markPresent == 1
            ? Image.asset('assets/images/tick_icon.png')
            : markPresent == -1
                ? Image.asset('assets/images/cross_icon.png')
                : const Center(
                    child: Icon(
                      Icons.delete,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
      ),
      onTap: () {
        _studentAttendanceBeans
            .where((eachStudentAttendanceBean) =>
                eachStudentAttendanceBean.attendanceTimeSlotId == atsId)
            .forEach((eachStudentAttendanceBean) {
          setState(() {
            eachStudentAttendanceBean.isPresent = markPresent;
            eachStudentAttendanceBean.agent = widget.adminProfile.userId;
            eachStudentAttendanceBean.isEdited = true;
            eachStudentAttendanceBean.markedById = widget.adminProfile.userId;
          });
        });
      },
    );
  }

  Widget _slotsColumns() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
              Row(
                children: _attendanceTimeSlotBeans.map((e) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: const EdgeInsets.all(8),
                    height: 100,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      color: Colors.lightBlueAccent,
                    ),
                    child: _isEditMode
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${convert24To12HourFormat(e.startTime!)} - ${convert24To12HourFormat(e.endTime!)}\n${e.managerName}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  markAttendanceForAllStudentsButton(
                                    e.attendanceTimeSlotId!,
                                    1,
                                  ),
                                  markAttendanceForAllStudentsButton(
                                    e.attendanceTimeSlotId!,
                                    -1,
                                  ),
                                  markAttendanceForAllStudentsButton(
                                    e.attendanceTimeSlotId!,
                                    0,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              "${convert24To12HourFormat(e.startTime!)} - ${convert24To12HourFormat(e.endTime!)}\n${e.managerName}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                  );
                }).toList(),
              ),
            ] +
            _studentProfiles
                .map((eachStudent) => Row(
                      children: _attendanceTimeSlotBeans.map((eachATSBean) {
                        StudentAttendanceBean studentAttendanceBean =
                            _studentAttendanceBeans
                                .where((e) =>
                                    e.studentId == eachStudent.studentId &&
                                    e.attendanceTimeSlotId ==
                                        eachATSBean.attendanceTimeSlotId)
                                .first;
                        return GestureDetector(
                          onLongPress: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${convert24To12HourFormat(eachATSBean.startTime!)} - ${convert24To12HourFormat(eachATSBean.endTime!)}\n${eachATSBean.managerName}",
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            padding: const EdgeInsets.all(8),
                            height: 100,
                            width: 250,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.white),
                              color: studentAttendanceBean.isPresent == 1
                                  ? Colors.greenAccent[100]
                                  : studentAttendanceBean.isPresent == -1
                                      ? Colors.redAccent[100]
                                      : Colors.lightBlueAccent[100],
                            ),
                            child: _isEditMode
                                ? Center(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        markAttendanceButton(
                                          studentAttendanceBean,
                                          1,
                                        ),
                                        markAttendanceButton(
                                          studentAttendanceBean,
                                          -1,
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: studentAttendanceBean.isPresent == 1
                                        ? Image.asset(
                                            'assets/images/tick_icon.png',
                                            fit: BoxFit.scaleDown,
                                            height: 40,
                                            width: 40,
                                          )
                                        : studentAttendanceBean.isPresent == -1
                                            ? Image.asset(
                                                'assets/images/cross_icon.png',
                                                fit: BoxFit.scaleDown,
                                                height: 40,
                                                width: 40,
                                              )
                                            : Image.asset(
                                                'assets/images/empty_stroke.png',
                                                fit: BoxFit.scaleDown,
                                                height: 40,
                                                width: 40,
                                              ),
                                  ),
                          ),
                        );
                      }).toList(),
                    ))
                .toList(),
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _studentDetailsColumns(),
          ),
          Expanded(
            flex: 7,
            child: _slotsColumns(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _loadData();
                return;
              },
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _getDatePicker(),
                      ),
                      InkWell(
                        onTap: () {
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
                              ? ClayContainer(
                                  emboss: true,
                                  color: clayContainerColor(context),
                                  height: 50,
                                  width: 50,
                                  borderRadius: 50,
                                  spread: 4,
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                )
                              : ClayContainer(
                                  color: clayContainerColor(context),
                                  height: 50,
                                  width: 50,
                                  borderRadius: 50,
                                  spread: 4,
                                  child: Icon(
                                    Icons.edit,
                                    color: _isEditMode
                                        ? Colors.green[200]
                                        : Colors.black38,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  _buildSectionsFilter(),
                  _attendanceTimeSlotBeans.isEmpty
                      ? Container()
                      : _buildAttendanceTable(),
                ],
              ),
            ),
    );
  }
}
