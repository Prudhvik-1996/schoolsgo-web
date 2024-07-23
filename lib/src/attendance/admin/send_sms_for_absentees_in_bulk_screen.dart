import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class SendSmsForAbsenteesInBulkScreen extends StatefulWidget {
  const SendSmsForAbsenteesInBulkScreen({
    super.key,
    required this.adminProfile,
    required this.studentsList,
    required this.studentAttendanceBeans,
  });

  final AdminProfile adminProfile;
  final List<StudentProfile> studentsList;
  final List<StudentAttendanceBean> studentAttendanceBeans;

  @override
  State<SendSmsForAbsenteesInBulkScreen> createState() => _SendSmsForAbsenteesInBulkScreenState();
}

class _SendSmsForAbsenteesInBulkScreenState extends State<SendSmsForAbsenteesInBulkScreen> {
  bool _isLoading = true;
  bool showOnlyNeverNotified = true;
  ScrollController dataTableHorizontalController = ScrollController();
  ScrollController dataTableVerticalController = ScrollController();
  TextEditingController studentNameSearchControllerForSendSms = TextEditingController();
  List<StudentProfile> actualAbsenteesList = [];
  List<StudentProfile> studentsListToDisplay = [];
  List<StudentAttendanceBean> _studentAttendanceBeans = [];
  Set<int> attendanceIdsToSendSms = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _studentAttendanceBeans = widget.studentAttendanceBeans;
    attendanceIdsToSendSms = _studentAttendanceBeans
        .where((e) => e.isPresent == -1 && (e.noOfTimesNotified ?? 0) == 0)
        .map((e) => e.attendanceId)
        .where((e) => e != null)
        .map((e) => e!)
        .toSet();
    filterStudentsList();
    setState(() => _isLoading = false);
  }

  void filterStudentsList() {
    actualAbsenteesList = widget.studentsList.where((es) {
      List<StudentAttendanceBean> eachStudentAttendanceBeans = (_studentAttendanceBeans.where((esab) => esab.studentId == es.studentId).toList()
        ..sort(
            (a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime, null).compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime, null))));
      return eachStudentAttendanceBeans.where((e) => e.isPresent == -1).isNotEmpty;
    }).toList();
    studentsListToDisplay = actualAbsenteesList
        .where((es) => es.studentNameAsStringWithSectionAndRollNumber().toLowerCase().contains(studentNameSearchControllerForSendSms.text))
        .toList();
    if (showOnlyNeverNotified) {
      studentsListToDisplay = studentsListToDisplay.where((es) {
        List<StudentAttendanceBean> eachStudentAttendanceBeans = (_studentAttendanceBeans.where((esab) => esab.studentId == es.studentId).toList()
          ..sort((a, b) =>
              getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime, null).compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime, null))));
        return eachStudentAttendanceBeans.map((e) => e.noOfTimesNotified ?? 0).toSet().contains(0);
      }).toList();
    }
    setState(() {});
  }

  Future<void> sendSms() async {
    NotifyStudentsForAbsenceResponse notifyStudentsForAbsenceResponse = await notifyStudentsForAbsence(NotifyStudentsForAbsenceRequest(
      schoolId: widget.adminProfile.schoolId,
      agentId: widget.adminProfile.userId,
      attendanceIds: attendanceIdsToSendSms.toList(),
    ));
    if (notifyStudentsForAbsenceResponse.httpStatus == "OK" && notifyStudentsForAbsenceResponse.responseStatus == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notified successfully.."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
  }

  void _showConfirmationDialog(BuildContext masterContext) {
    showDialog(
      context: masterContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Do you want to send the SMS?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                await sendSms();
                setState(() => _isLoading = false);
                Navigator.of(masterContext).pop();
              },
              child: const Text("Proceed"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send SMS to absentees"),
        actions: _isLoading
            ? []
            : [
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _showConfirmationDialog(context),
                ),
              ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Scrollbar(
              thumbVisibility: true,
              controller: dataTableHorizontalController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: dataTableHorizontalController,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: dataTableVerticalController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: dataTableVerticalController,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Student Name',
                                    hintText: 'Student Name',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                  controller: studentNameSearchControllerForSendSms,
                                  autofocus: true,
                                  onChanged: (_) {
                                    filterStudentsList();
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => studentNameSearchControllerForSendSms.text = "");
                                  filterStudentsList();
                                },
                              ),
                            ],
                          ),
                        ),
                        DataColumn(
                          label: GestureDetector(
                            onTap: () {
                              setState(() => showOnlyNeverNotified = !showOnlyNeverNotified);
                              filterStudentsList();
                            },
                            child: ClayButton(
                              depth: 40,
                              parentColor: clayContainerColor(context),
                              surfaceColor: clayContainerColor(context),
                              spread: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(showOnlyNeverNotified ? "Show All Absentees" : "Show Absentees who are Never Notified"),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        ...studentsListToDisplay.map(
                          (es) => DataRow(
                            color: MaterialStateProperty.resolveWith((Set states) {
                              if (studentsListToDisplay.indexOf(es) % 2 == 0) {
                                return Colors.grey[400];
                              }
                              return Colors.grey;
                            }),
                            cells: [
                              DataCell(Text(es.studentNameAsStringWithSectionAndRollNumber())),
                              DataCell(
                                Row(
                                  children: [
                                    ...(_studentAttendanceBeans.where((esab) => esab.studentId == es.studentId).toList()
                                          ..sort((a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime, null)
                                              .compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime, null))))
                                        .where((e) => e.isPresent == -1)
                                        .map(
                                          (esab) => (esab.startTime == null && esab.endTime == null)
                                              ? Container()
                                              : GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (attendanceIdsToSendSms.contains(esab.attendanceId)) {
                                                        attendanceIdsToSendSms.remove(esab.attendanceId);
                                                      } else {
                                                        attendanceIdsToSendSms.add(esab.attendanceId!);
                                                      }
                                                    });
                                                  },
                                                  child: noOfTimesNotifiedWidget(
                                                    Card(
                                                      color: attendanceIdsToSendSms.contains(esab.attendanceId) ? Colors.blue : null,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8),
                                                        child: Text(
                                                          "${esab.startTime == null ? "-" : formatHHMMSStoHHMMA(esab.startTime!)} - ${esab.endTime == null ? "-" : formatHHMMSStoHHMMA(esab.endTime!)}",
                                                        ),
                                                      ),
                                                    ),
                                                    noOfTimesNotified: esab.noOfTimesNotified ?? 0,
                                                  ),
                                                ),
                                        )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget noOfTimesNotifiedWidget(Widget child, {int noOfTimesNotified = 0}) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: child,
        ),
        if (noOfTimesNotified != 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(100),
              ),
              height: 15,
              width: 15,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  (noOfTimesNotified ?? 0).toString(),
                  style: const TextStyle(
                    color: Colors.white, fontSize: 10, // Adjust the font size as needed
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
