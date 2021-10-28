import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class TeacherMarkStudentAttendanceScreen extends StatefulWidget {
  final TeacherProfile teacherProfile;
  final DateTime selectedDate;
  final AttendanceTimeSlotBean attendanceTimeSlotBean;

  const TeacherMarkStudentAttendanceScreen({
    Key? key,
    required this.teacherProfile,
    required this.selectedDate,
    required this.attendanceTimeSlotBean,
  }) : super(key: key);

  @override
  _TeacherMarkStudentAttendanceScreenState createState() =>
      _TeacherMarkStudentAttendanceScreenState();
}

class _TeacherMarkStudentAttendanceScreenState
    extends State<TeacherMarkStudentAttendanceScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  List<StudentAttendanceBean> _studentAttendanceBeans = [];
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
      _studentAttendanceBeans = [];
      _studentProfiles = [];
    });

    setState(() {
      _isLoading = false;
    });

    _loadStudentAttendance();
  }

  Future<void> _loadStudentAttendance() async {
    setState(() {
      _isLoading = true;
    });

    GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse =
        await getStudentAttendanceBeans(GetStudentAttendanceBeansRequest(
      schoolId: widget.teacherProfile.schoolId,
      date: convertDatTimeToYYYYMMDDFormat(widget.selectedDate),
      sectionId: widget.attendanceTimeSlotBean.sectionId,
      teacherId: widget.teacherProfile.teacherId,
    ));
    if (getStudentAttendanceBeansResponse.httpStatus == "OK" &&
        getStudentAttendanceBeansResponse.responseStatus == "success") {
      setState(() {
        _studentAttendanceBeans =
            getStudentAttendanceBeansResponse.studentAttendanceBeans!;
        _studentProfiles = _studentAttendanceBeans
            .map(
              (e) => StudentProfile(
                  sectionId: e.sectionId,
                  schoolId: widget.teacherProfile.schoolId,
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
                    schoolId: widget.teacherProfile.schoolId,
                    agent: widget.teacherProfile.teacherId,
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
            studentAttendanceBean.markedById = widget.teacherProfile.teacherId;
            studentAttendanceBean.agent = widget.teacherProfile.teacherId;
            studentAttendanceBean.isEdited = true;
          });
        } else {
          setState(() {
            studentAttendanceBean.isPresent = markPresent;
            studentAttendanceBean.markedById = widget.teacherProfile.teacherId;
            studentAttendanceBean.agent = widget.teacherProfile.teacherId;
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
            eachStudentAttendanceBean.agent = widget.teacherProfile.teacherId;
            eachStudentAttendanceBean.isEdited = true;
            eachStudentAttendanceBean.markedById =
                widget.teacherProfile.teacherId;
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
                children: [widget.attendanceTimeSlotBean].map((e) {
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
                      children:
                          [widget.attendanceTimeSlotBean].map((eachATSBean) {
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
                                            studentAttendanceBean, 1),
                                        markAttendanceButton(
                                            studentAttendanceBean, -1),
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

  Widget _getDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: ClayButton(
              depth: 40,
              color: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    "Date: ${convertDateTimeToDDMMYYYYFormat(widget.selectedDate)}",
                  ),
                ),
              ),
            ),
          ),
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
                ? ClayButton(
                    color: clayContainerColor(context),
                    height: 50,
                    width: 50,
                    borderRadius: 50,
                    spread: 4,
                    child: const Icon(
                      Icons.check,
                    ),
                  )
                : ClayButton(
                    color: clayContainerColor(context),
                    height: 50,
                    width: 50,
                    borderRadius: 50,
                    spread: 4,
                    child: const Icon(
                      Icons.edit,
                    ),
                  ),
          ),
        ),
      ],
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
                  _getDatePicker(),
                  _studentAttendanceBeans.isEmpty
                      ? const Text(
                          "No timeslots to mark attendance",
                          textAlign: TextAlign.center,
                        )
                      : _buildAttendanceTable(),
                ],
              ),
            ),
    );
  }
}
