import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/attendance/teacher/teacher_mark_student_attendance_screen.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class TeacherAttendanceTimeslots extends StatefulWidget {
  final TeacherProfile teacherProfile;

  const TeacherAttendanceTimeslots({Key? key, required this.teacherProfile}) : super(key: key);

  @override
  _TeacherAttendanceTimeslotsState createState() => _TeacherAttendanceTimeslotsState();
}

class _TeacherAttendanceTimeslotsState extends State<TeacherAttendanceTimeslots> {
  bool _isLoading = true;
  List<AttendanceTimeSlotBean> _attendanceTimeSlots = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetStudentAttendanceTimeSlotsResponse getStudentAttendanceTimeSlotsResponse =
        await getStudentAttendanceTimeSlots(GetStudentAttendanceTimeSlotsRequest(
      schoolId: widget.teacherProfile.schoolId,
      status: "active",
      managerId: widget.teacherProfile.teacherId,
      date: convertDateTimeToYYYYMMDDFormat(_selectedDate),
    ));
    if (getStudentAttendanceTimeSlotsResponse.httpStatus == "OK" && getStudentAttendanceTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _attendanceTimeSlots = getStudentAttendanceTimeSlotsResponse.attendanceTimeSlotBeans!;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2021),
            lastDate: DateTime.now(),
            helpText: "Pick  date to mark attendance",
          );
          if (_newDate == null || _newDate == _selectedDate) return;
          setState(() {
            _selectedDate = _newDate;
          });
          _loadData();
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

  Widget buildEachATSWidget(AttendanceTimeSlotBean eachATS) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return TeacherMarkStudentAttendanceScreen(
              teacherProfile: widget.teacherProfile,
              attendanceTimeSlotBean: eachATS,
              selectedDate: _selectedDate,
            );
          }));
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(20),
            // child: Text("${eachATS.managerName}"),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${eachATS.week}, ${convert24To12HourFormat(eachATS.startTime!)} - ${convert24To12HourFormat(eachATS.endTime!)}",
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Section: ${eachATS.sectionName}",
                      ),
                    ),
                    // Text(
                    //     "${eachATS.week}, ${convert24To12HourFormat(eachATS.startTime)} - ${convert24To12HourFormat(eachATS.endTime)}"),
                    // Text("Section: ${eachATS.sectionName}")
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Attendance Manager: ${eachATS.managerName}",
                      ),
                    ),
                    // Text("Attendance Manager: ${eachATS.managerName}")
                  ],
                ),
              ],
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
        title: const Text("Attendance"),
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
                    ] +
                    _attendanceTimeSlots.map((e) => buildEachATSWidget(e)).toList(),
              ),
            ),
    );
  }
}
