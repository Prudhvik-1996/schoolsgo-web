import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/attendance_qr_pdf.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/attendance_qr_screen.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/employee_attendance_utils.dart';
import 'package:schoolsgo_web/src/employee_attendance/model/employee_attendance.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminEmployeeAttendanceManagementScreen extends StatefulWidget {
  const AdminEmployeeAttendanceManagementScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminEmployeeAttendanceManagementScreen> createState() => _AdminEmployeeAttendanceManagementScreenState();
}

class _AdminEmployeeAttendanceManagementScreenState extends State<AdminEmployeeAttendanceManagementScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;
  int? selectedAcademicYearId;
  List<EmployeeAttendanceBean> employeeAttendanceBeanList = [];
  List<EmployeeAttendanceBean> filteredEmployeeAttendanceBeanList = [];

  TextEditingController employeeNameSearchController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  SchoolInfoBean? schoolInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');

    GetEmployeeAttendanceResponse getEmployeeAttendanceResponse = await getEmployeeAttendance(GetEmployeeAttendanceRequest(
      schoolId: widget.adminProfile.schoolId,
      academicYearId: selectedAcademicYearId,
    ));
    if (getEmployeeAttendanceResponse.httpStatus != "OK" || getEmployeeAttendanceResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      employeeAttendanceBeanList = (getEmployeeAttendanceResponse.employeeAttendanceBeanList ?? []).map((e) => e!).toList();
    }
    filterEmployeesList();
    await _loadSchoolInfo();
    setState(() => _isLoading = false);
  }

  void filterEmployeesList() {
    setState(() {
      filteredEmployeeAttendanceBeanList = employeeAttendanceBeanList
          .where((e) => (e.employeeName ?? "").toLowerCase().contains(employeeNameSearchController.text.trim().toLowerCase()))
          .toList();
      for (EmployeeAttendanceBean eachEmployeeBean in filteredEmployeeAttendanceBeanList) {
        eachEmployeeBean.dateWiseEmployeeAttendanceBeanList ??= [];
        if ((eachEmployeeBean.dateWiseEmployeeAttendanceBeanList ?? [])
                .firstWhereOrNull((eachDateBean) => eachDateBean?.date == convertDateTimeToYYYYMMDDFormat(selectedDate)) ==
            null) {
          eachEmployeeBean.dateWiseEmployeeAttendanceBeanList!.add(DateWiseEmployeeAttendanceBean(
            employeeId: eachEmployeeBean.employeeId,
            date: convertDateTimeToYYYYMMDDFormat(selectedDate),
            dateWiseEmployeeAttendanceDetailsBeans: [],
            isPresent: null,
          ));
        }
      }
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    List<DateWiseEmployeeAttendanceBean> toUpdate =
        filteredEmployeeAttendanceBeanList.map((e) => e.dateWiseEmployeeAttendanceBeanList ?? []).expand((i) => i).whereNotNull().where((e) {
      DateWiseEmployeeAttendanceBean org = DateWiseEmployeeAttendanceBean.fromJson(e.origJson());
      bool isPresentChanged = e.isPresent != org.isPresent;
      if (isPresentChanged) return true;
      return e.dateWiseEmployeeAttendanceDetailsBeans?.length != org.dateWiseEmployeeAttendanceDetailsBeans?.length;
    }).toList();
    if (toUpdate.isEmpty) {
      setState(() {
        _isEditMode = false;
        _isLoading = false;
      });
      return;
    }
    CreateOrUpdateEmployeesAttendanceResponse createOrUpdateEmployeesAttendanceResponse =
        await createOrUpdateEmployeesAttendance(CreateOrUpdateEmployeesAttendanceRequest(
      schoolId: widget.adminProfile.schoolId,
      agentId: widget.adminProfile.userId,
      dateWiseEmployeeAttendanceBeans: toUpdate,
    ));
    if (createOrUpdateEmployeesAttendanceResponse.httpStatus != "OK" || createOrUpdateEmployeesAttendanceResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() => _isEditMode = false);
      _loadData();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadSchoolInfo() async {
    setState(() {
      _isLoading = true;
    });
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      setState(() {
        schoolInfo = getSchoolsResponse.schoolInfo!;
        _isLoading = false;
      });
    }
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Print QR") {
      setState(() => _isLoading = true);
      var qrBaseUrl = QR_BASE_URL;
      var qrCodeData = getQRCodeData(widget.adminProfile.schoolId!, false, DateTime.now().millisecondsSinceEpoch, widget.adminProfile.userId!);
      var qrUrl = "$qrBaseUrl$qrCodeData&size=250x250";
      debugPrint("162: QR generation URL: $qrUrl");
      String printStatus = await downloadAttendanceQRPdf(qrUrl, schoolInfo!);
      debugPrint("165: $printStatus");
      setState(() => _isLoading = false);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EmployeeAttendanceQRScreen(
          adminProfile: widget.adminProfile,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Attendance Management"),
        actions: _isLoading
            ? []
            : [
                const SizedBox(width: 10),
                Tooltip(
                  message: _isEditMode ? "Save" : "Edit",
                  child: IconButton(
                    onPressed: () async {
                      if (!_isEditMode) {
                        setState(() => _isEditMode = true);
                      } else {
                        _saveChanges();
                      }
                    },
                    icon: Icon(_isEditMode ? Icons.check : Icons.edit),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (String choice) async => await handleClick(choice),
                  itemBuilder: (BuildContext context) {
                    return {"Print QR", "Dynamic QR"}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
                const SizedBox(width: 10),
              ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    _getLeftArrow(),
                    const SizedBox(width: 10),
                    Expanded(child: _getDatePicker()),
                    const SizedBox(width: 10),
                    _getRightArrow(),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: employeeAttendanceBeanList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text("No employees found.."),
                          ),
                        )
                      : ClayTable2DWidgetV2(
                          context: context,
                          horizontalScrollController: ScrollController(),
                          columns: [
                            const DataColumn(label: Text('S. No.')),
                            DataColumn(label: employeeNameLabel()),
                            const DataColumn(label: Text('No. Of. Hours\npresent')),
                            const DataColumn(label: Text('Attendance')),
                            const DataColumn(label: Text('Clocks')),
                          ],
                          rows: filteredEmployeeAttendanceBeanList.mapIndexed((int index, EmployeeAttendanceBean eachEmployeeBean) {
                            DateWiseEmployeeAttendanceBean attendanceBeanForSelectedDate = (eachEmployeeBean.dateWiseEmployeeAttendanceBeanList ?? [])
                                .firstWhere((eachDateBean) => eachDateBean?.date == convertDateTimeToYYYYMMDDFormat(selectedDate))!;
                            List<DateWiseEmployeeAttendanceDetailsBean> dateWiseAttendanceDetails =
                                (attendanceBeanForSelectedDate.dateWiseEmployeeAttendanceDetailsBeans ?? []).whereNotNull().toList();
                            dateWiseAttendanceDetails.sort((a, b) => (a.clockedTime ?? 0).compareTo(b.clockedTime ?? 0));
                            double? noOfHoursSpent;
                            int? noOfHours;
                            int? noOfMinutes;
                            List<int> clockedInTimes = dateWiseAttendanceDetails
                                .where((e) => (e.clockedIn ?? false) && (e.status == 'active'))
                                .map((e) => e.clockedTime)
                                .whereNotNull()
                                .toList();
                            List<int> clockedOutTimes = dateWiseAttendanceDetails
                                .where((e) => !(e.clockedIn ?? false) && (e.status == 'active'))
                                .map((e) => e.clockedTime)
                                .whereNotNull()
                                .toList();
                            if (clockedInTimes.isNotEmpty) {
                              if (clockedOutTimes.length - clockedInTimes.length == 1) {
                                clockedOutTimes.add(DateTime.now().millisecondsSinceEpoch);
                              }
                              if (clockedOutTimes.length == clockedInTimes.length) {
                                int noOfMillisSpent = 0;
                                for (int i = 0; i < clockedOutTimes.length; i++) {
                                  noOfMillisSpent += (clockedOutTimes[i] - clockedInTimes[i]);
                                }
                                noOfHoursSpent = noOfMillisSpent / (1000 * 60 * 60);
                                int totalMinutes = (noOfHoursSpent * 60).round();
                                noOfHours = totalMinutes ~/ 60;
                                noOfMinutes = totalMinutes % 60;
                              }
                            }
                            return DataRow(
                              cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(Text(eachEmployeeBean.employeeName ?? "-")),
                                DataCell(Text(noOfHoursSpent == null ? "-" : "${noOfHours ?? "-"}h ${noOfMinutes ?? "-"}m")),
                                DataCell(
                                  _isEditMode
                                      ? getAttendanceMarkers(attendanceBeanForSelectedDate)
                                      : Text(
                                          attendanceStatusDescription(attendanceBeanForSelectedDate.isPresent),
                                          style: TextStyle(color: attendanceMarkerColor(attendanceBeanForSelectedDate.isPresent)),
                                        ),
                                ),
                                DataCell(
                                  (attendanceBeanForSelectedDate.dateWiseEmployeeAttendanceDetailsBeans ?? []).isEmpty && !_isEditMode
                                      ? const Text("-")
                                      : Row(
                                          children: [
                                            ...(attendanceBeanForSelectedDate.dateWiseEmployeeAttendanceDetailsBeans ?? [])
                                                .where((e) => e?.clockedTime != null && e?.status == 'active')
                                                .whereNotNull()
                                                .map((DateWiseEmployeeAttendanceDetailsBean eachDateWiseEmployeeAttendanceDetailsBean) =>
                                                    timeChip(eachDateWiseEmployeeAttendanceDetailsBean)),
                                            if (_isEditMode)
                                              addNewChipButton(
                                                attendanceBeanForSelectedDate,
                                                DateWiseEmployeeAttendanceDetailsBean(
                                                  employeeId: eachEmployeeBean.employeeId,
                                                  schoolId: eachEmployeeBean.schoolId,
                                                  agent: widget.adminProfile.userId,
                                                  status: 'active',
                                                  comment: 'Reviewed by admin',
                                                  attendanceId: null,
                                                  clockedIn: true,
                                                  clockedTime: DateTime.now().millisecondsSinceEpoch,
                                                  latitude: null,
                                                  longitude: null,
                                                  qr: null,
                                                ),
                                              ),
                                          ],
                                        ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                )
              ],
            ),
    );
  }

  Widget getAttendanceMarkers(DateWiseEmployeeAttendanceBean dateWiseEmployeeAttendanceBean) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        attendanceMarkerWidget("P", dateWiseEmployeeAttendanceBean),
        attendanceMarkerWidget("A", dateWiseEmployeeAttendanceBean),
        attendanceMarkerWidget("H", dateWiseEmployeeAttendanceBean),
        if (dateWiseEmployeeAttendanceBean.isPresent != null &&
            (dateWiseEmployeeAttendanceBean.isPresent!.contains("A") || dateWiseEmployeeAttendanceBean.isPresent!.contains("H")))
          attendanceMarkerWidget("L", dateWiseEmployeeAttendanceBean),
      ],
    );
  }

  Widget attendanceMarkerWidget(String attendanceStatus, DateWiseEmployeeAttendanceBean employeeAttendanceBean) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: GestureDetector(
        onTap: () {
          if (employeeAttendanceBean.isPresent == attendanceStatus) {
            employeeAttendanceBean.isPresent = "-";
          }
          switch (attendanceStatus) {
            case "P":
              setState(() => employeeAttendanceBean.isPresent = "P");
              return;
            case "A":
              setState(() => employeeAttendanceBean.isPresent = "A");
              return;
            case "H":
              setState(() => employeeAttendanceBean.isPresent = "H");
              return;
            case "L":
              if (employeeAttendanceBean.isPresent != null) {
                String isPresentInitially = employeeAttendanceBean.isPresent!;
                if (isPresentInitially.contains("L")) {
                  setState(() => employeeAttendanceBean.isPresent = isPresentInitially.replaceAll("L", ""));
                } else {
                  setState(() => employeeAttendanceBean.isPresent = isPresentInitially + "L");
                }
              }
              return;
            default:
              setState(() => employeeAttendanceBean.isPresent = "-");
              return;
          }
        },
        child: ClayButton(
          depth: 40,
          parentColor: employeeAttendanceBean.isPresent?.contains(attendanceStatus) ?? false ? Colors.blue : clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 100,
          child: Container(
            margin: const EdgeInsets.all(3),
            child: SizedBox(
              height: 12,
              width: 12,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: attendanceStatusIconWidget(attendanceStatus),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color attendanceMarkerColor(String? status) {
    if ((status ?? "").contains("P")) return Colors.green;
    if ((status ?? "").contains("A")) return Colors.red;
    if ((status ?? "").contains("H")) return Colors.amber;
    return clayContainerTextColor(context);
  }

  Widget attendanceStatusIconWidget(String? status) {
    switch (status) {
      case "P":
        return Tooltip(message: "Present", child: Text("P", style: TextStyle(color: attendanceMarkerColor(status))));
      case "A":
        return Tooltip(message: "Absent", child: Text("A", style: TextStyle(color: attendanceMarkerColor(status))));
      case "H":
        return Tooltip(message: "Half Day", child: Text("H", style: TextStyle(color: attendanceMarkerColor(status))));
      case "L":
        return Tooltip(message: "Leave", child: Text("L", style: TextStyle(color: attendanceMarkerColor(status))));
      default:
        return Tooltip(message: "Not Marked", child: Text("-", style: TextStyle(color: attendanceMarkerColor(status))));
    }
  }

  String attendanceStatusDescription(String? status) {
    switch (status) {
      case "P":
        return "Present";
      case "A":
        return "Absent";
      case "H":
        return "Half day";
      case "L":
        return "Leave";
      case "AL":
        return "Absent (Leave)";
      case "HL":
        return "Half day (Leave)";
      default:
        return "Not Marked";
    }
  }

  Widget addNewChipButton(DateWiseEmployeeAttendanceBean attendanceBeanForSelectedDate, DateWiseEmployeeAttendanceDetailsBean employeeClockDetails) {
    return GestureDetector(
      onTap: () async {
        await showDialog<void>(
          context: context,
          builder: (currentContext) {
            return StatefulBuilder(builder: (context, localSetState) {
              return AlertDialog(
                title: const Text("Attendance details"),
                content: SizedBox(
                  height: 250,
                  width: 300,
                  child: attendanceChipEditableContent(employeeClockDetails, localSetState),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        localSetState(() {
                          attendanceBeanForSelectedDate.dateWiseEmployeeAttendanceDetailsBeans ??= [];
                          attendanceBeanForSelectedDate.dateWiseEmployeeAttendanceDetailsBeans?.add(employeeClockDetails);
                        });
                      });
                      await createOrUpdateClock(employeeClockDetails);
                    },
                    child: const Text("Add"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            });
          },
        );
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 25,
        width: 25,
        borderRadius: 50,
        spread: 1,
        surfaceColor: clayContainerColor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget timeChip(DateWiseEmployeeAttendanceDetailsBean attendanceBeanForSelectedDate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: GestureDetector(
        onTap: () async {
          await showDialog<void>(
            context: context,
            builder: (currentContext) {
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  title: const Text("Attendance details"),
                  content: SizedBox(height: 250, width: 250, child: attendanceChipExpandedContent(attendanceBeanForSelectedDate)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Close"),
                    ),
                  ],
                );
              });
            },
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              convertEpochToHHMMAA(attendanceBeanForSelectedDate.clockedTime!),
              style: TextStyle(
                color: (attendanceBeanForSelectedDate.clockedIn ?? false) ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget attendanceChipExpandedContent(DateWiseEmployeeAttendanceDetailsBean attendanceClockBean) {
    bool? scannedFromDynamicQrForChip = scannedFromDynamicQr(attendanceClockBean.qr);
    Color clockedInTextColor = (attendanceClockBean.clockedIn ?? false) ? Colors.green : Colors.red;
    return ListView(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Time: "),
            Expanded(
              child: Text(
                convertEpochToHHMMAA(attendanceClockBean.clockedTime!),
                style: TextStyle(
                  color: clockedInTextColor,
                ),
              ),
            ),
            deleteClockButton(attendanceClockBean),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Clock "),
            Text(
              (attendanceClockBean.clockedIn ?? false) ? "In" : "Out",
              style: TextStyle(
                color: clockedInTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(child: Text("Marked from:")),
            Text(
              scannedFromDynamicQrForChip == null
                  ? "Admin"
                  : scannedFromDynamicQrForChip
                      ? "Dynamic QR"
                      : "Static QR",
            ),
            const SizedBox(width: 10),
            qrWidgetForAttendanceChip(attendanceClockBean),
          ],
        ),
        if (attendanceClockBean.comment != null) ...[
          const SizedBox(height: 10),
          const Text("Comments:"),
          const SizedBox(height: 10),
          Text(attendanceClockBean.comment ?? "-"),
        ],
        const SizedBox(height: 10),
      ],
    );
  }

  Widget deleteClockButton(DateWiseEmployeeAttendanceDetailsBean attendanceClockBean) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await showDialog<void>(
          context: context,
          builder: (currentContext) {
            return StatefulBuilder(builder: (context, localSetState) {
              return AlertDialog(
                title: Text("Delete clock - ${convertEpochToHHMMAA(attendanceClockBean.clockedTime!)}"),
                content: SizedBox(
                  height: 100,
                  width: 300,
                  child: TextFormField(
                    initialValue: "Reviewed by Admin",
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                      hintText: 'Comments',
                    ),
                    onChanged: (value) {
                      attendanceClockBean.comment = value;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        localSetState(() {
                          attendanceClockBean.status = 'inactive';
                        });
                      });
                      if (attendanceClockBean.attendanceId != null) {
                        await createOrUpdateClock(attendanceClockBean);
                      }
                    },
                    child: const Text("Delete"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            });
          },
        );
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 25,
        width: 25,
        borderRadius: 50,
        spread: 1,
        surfaceColor: clayContainerColor(context),
        child: const Padding(
          padding: EdgeInsets.all(6.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Future<void> createOrUpdateClock(DateWiseEmployeeAttendanceDetailsBean attendanceClockBean) async {
    setState(() => _isLoading = true);
    CreateOrUpdateEmployeeAttendanceClockResponse createOrUpdateEmployeeAttendanceClockResponse =
        await createOrUpdateEmployeeAttendanceClock(CreateOrUpdateEmployeeAttendanceClockRequest(
      schoolId: widget.adminProfile.schoolId,
      agent: widget.adminProfile.userId,
      status: attendanceClockBean.status,
      attendanceId: attendanceClockBean.attendanceId,
      comment: attendanceClockBean.comment,
      employeeId: attendanceClockBean.employeeId,
      clockedIn: attendanceClockBean.clockedIn,
      clockedTime: attendanceClockBean.clockedTime,
    ));
    if (createOrUpdateEmployeeAttendanceClockResponse.httpStatus != "OK" ||
        createOrUpdateEmployeeAttendanceClockResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      _loadData();
    }
    setState(() => _isLoading = false);
  }

  Widget attendanceChipEditableContent(DateWiseEmployeeAttendanceDetailsBean employeeClockDetails, StateSetter localSetState) {
    Color clockedInTextColor = (employeeClockDetails.clockedIn ?? false) ? Colors.green : Colors.red;
    return ListView(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(child: Text("Time")),
            GestureDetector(
              onTap: () => pickClockedTime(employeeClockDetails, localSetState),
              child: ClayButton(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      employeeClockDetails.clockedTime == null ? "-" : convertEpochToHHMMSSAA(employeeClockDetails.clockedTime!),
                      style: TextStyle(
                        color: clockedInTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Clock "),
            ...[true, false].map(
              (e) => Expanded(
                child: RadioListTile<bool?>(
                  value: e,
                  groupValue: employeeClockDetails.clockedIn,
                  onChanged: (newValue) {
                    setState(() {
                      localSetState(() {
                        employeeClockDetails.clockedIn = newValue;
                      });
                    });
                  },
                  title: Text(e ? "In" : "Out"),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: Text("Marked by:")),
            Text("Admin"),
          ],
        ),
        TextFormField(
          initialValue: "Reviewed by Admin",
          decoration: const InputDecoration(
            labelText: 'Comments',
            hintText: 'Comments',
          ),
          onChanged: (value) {
            employeeClockDetails.comment = value;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> pickClockedTime(DateWiseEmployeeAttendanceDetailsBean employeeClockDetails, StateSetter localSetState) async {
    TimeOfDay? timePicker = await showTimePicker(
      context: context,
      initialTime: millisToTimeOfDay(employeeClockDetails.clockedTime),
    );
    if (timePicker == null) return;
    setState(() {
      localSetState(() {
        employeeClockDetails.clockedTime =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day, timePicker.hour, timePicker.minute, 0, 0, 0).millisecondsSinceEpoch;
      });
    });
  }

  Widget qrWidgetForAttendanceChip(DateWiseEmployeeAttendanceDetailsBean attendanceBeanForSelectedDate) {
    return attendanceBeanForSelectedDate.qr == null
        ? Container()
        : SizedBox(
            height: 25,
            width: 25,
            child: Image.network(
              "$QR_BASE_URL${attendanceBeanForSelectedDate.qr ?? "-"}&size=100x100",
              fit: BoxFit.scaleDown,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          );
  }

  Widget employeeNameLabel() {
    return SizedBox(
      width: 100,
      child: TextField(
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          labelText: 'Employee Name',
          hintText: 'Employee Name',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        ),
        style: const TextStyle(
          fontSize: 12,
        ),
        controller: employeeNameSearchController,
        autofocus: true,
        onChanged: (_) {
          filterEmployeesList();
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
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now(),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            selectedDate = _newDate;
          });
          filterEmployeesList();
        },
        child: ClayButton(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          height: 60,
          width: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, // mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    convertDateTimeToDDMMYYYYFormat(selectedDate),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLeftArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Previous Day",
        child: GestureDetector(
          onTap: () {
            if (selectedDate.millisecondsSinceEpoch == DateTime.now().subtract(const Duration(days: 364)).millisecondsSinceEpoch) return;
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
            filterEmployeesList();
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            spread: 1,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_left),
          ),
        ),
      ),
    );
  }

  Widget _getRightArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Next Day",
        child: GestureDetector(
          onTap: () {
            if (selectedDate.add(const Duration(days: 1)).millisecondsSinceEpoch >= DateTime.now().millisecondsSinceEpoch) return;
            setState(() {
              selectedDate = selectedDate.add(const Duration(days: 1));
            });
            filterEmployeesList();
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            spread: 1,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_right),
          ),
        ),
      ),
    );
  }
}
