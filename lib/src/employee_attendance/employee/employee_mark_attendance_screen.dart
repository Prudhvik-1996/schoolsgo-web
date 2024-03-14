import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/employee_attendance_utils.dart';
import 'package:schoolsgo_web/src/employee_attendance/model/employee_attendance.dart';
import 'package:schoolsgo_web/src/employee_attendance/qr_scanner/qr_scanner_widget_v2.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/employees.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class EmployeeMarkAttendanceScreen extends StatefulWidget {
  const EmployeeMarkAttendanceScreen({
    Key? key,
    required this.employeeId,
    required this.schoolId,
  }) : super(key: key);

  final int employeeId;
  final int schoolId;

  @override
  State<EmployeeMarkAttendanceScreen> createState() => _EmployeeMarkAttendanceScreenState();
}

class _EmployeeMarkAttendanceScreenState extends State<EmployeeMarkAttendanceScreen> {
  bool _isLoading = true;
  List<EmployeeAttendanceBean> employeeAttendanceBeanList = [];
  late SchoolWiseEmployeeBean employeeBean;

  bool _showOnlyMarked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');

    GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest(
      schoolId: widget.schoolId,
      employeeId: widget.employeeId,
    ));
    if (getSchoolWiseEmployeesResponse.httpStatus != "OK" || getSchoolWiseEmployeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        employeeBean = (getSchoolWiseEmployeesResponse.employees ?? []).map((e) => e!).toList().first;
      });
    }
    GetEmployeeAttendanceResponse getEmployeeAttendanceResponse = await getEmployeeAttendance(GetEmployeeAttendanceRequest(
      employeeId: widget.employeeId,
      schoolId: widget.schoolId,
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

    GetSchoolWiseAcademicYearsResponse response = await getSchoolWiseAcademicYears(
      GetSchoolWiseAcademicYearsRequest(schoolId: widget.schoolId),
    );

    List<AcademicYearBean> academicYears = response.academicYearBeanList?.whereNotNull().toList() ?? [];
    String? startDate;
    String? endDate;

    if (academicYears.isNotEmpty) {
      if (selectedAcademicYearId != null) {
        if (academicYears.any((e) => e.academicYearId == selectedAcademicYearId)) {
          startDate = academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearStartDate;
          endDate = academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearEndDate;
        } else {
          startDate = academicYears.last.academicYearStartDate;
          endDate = academicYears.last.academicYearEndDate;
        }
      } else {
        startDate = academicYears.last.academicYearStartDate;
        endDate = academicYears.last.academicYearEndDate;
      }
    }
    List<DateTime> populateDatesList = populateDates(convertYYYYMMDDFormatToDateTime(startDate), DateTime.now());

    for (EmployeeAttendanceBean eachEmployeeBean in employeeAttendanceBeanList) {
      for (DateTime selectedDate in populateDatesList) {
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
      eachEmployeeBean.dateWiseEmployeeAttendanceBeanList!
          .sort((b, a) => convertYYYYMMDDFormatToDateTime(a!.date!).compareTo(convertYYYYMMDDFormatToDateTime(b!.date!)));
    }
    setState(() => _isLoading = false);
  }

  Future<void> goToScanQRScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const QRScannerWidgetV2();
    })).then((scannedQrCodeData) async {
      await clockAttendance(scannedQrCodeData.first);
    });
  }

  Future<void> clockAttendance(String scannedQRCode) async {
    setState(() => _isLoading = true);
    int? schoolId = extractSchoolIdFromQr(scannedQRCode);
    if (!isQRValid(scannedQRCode) && schoolId == widget.schoolId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scanned QR is invalid.."),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    CreateOrUpdateEmployeeAttendanceClockResponse createOrUpdateEmployeeAttendanceClockResponse = await createOrUpdateEmployeeAttendanceClock(
      CreateOrUpdateEmployeeAttendanceClockRequest(
        schoolId: schoolId,
        agent: widget.employeeId,
        status: "active",
        attendanceId: null,
        clockedIn: (employeeAttendanceBeanList.firstOrNull?.dateWiseEmployeeAttendanceBeanList ?? [])
            .firstWhereOrNull((e) => e?.date == convertDateTimeToYYYYMMDDFormat(DateTime.now()))
            ?.isNextClockIn() ?? true,
        clockedTime: DateTime.now().millisecondsSinceEpoch,
        comment: null,
        employeeId: widget.employeeId,
        latitude: null,
        longitude: null,
        qr: scannedQRCode,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Attendance"),
        actions: _isLoading
            ? []
            : [
                IconButton(
                  icon: Tooltip(
                    message: _showOnlyMarked ? "Show All" : "Show only marked",
                    child: Icon(_showOnlyMarked ? Icons.remove_red_eye : Icons.remove_red_eye_outlined),
                  ),
                  onPressed: () => setState(() => _showOnlyMarked = !_showOnlyMarked),
                ),
              ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : dateWiseStatsTable(context),
      floatingActionButton: _isLoading ? null : fab(
        const Icon(Icons.qr_code_scanner),
        "Scan",
            () => goToScanQRScreen(),
        color: Colors.blue,
      ),
    );
  }

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ClayTable2DWidgetV2 dateWiseStatsTable(BuildContext context) {
    return ClayTable2DWidgetV2(
      context: context,
      horizontalScrollController: ScrollController(),
      columns: const [
        DataColumn(label: Text('S. No.')),
        DataColumn(label: Text("Date")),
        DataColumn(label: Text('No. Of. Hours\npresent')),
        DataColumn(label: Text('Attendance')),
        DataColumn(label: Text('Clocks')),
      ],
      rows: (employeeAttendanceBeanList.firstOrNull?.dateWiseEmployeeAttendanceBeanList ?? [])
          .whereNotNull()
          .where((e) => !_showOnlyMarked || (e.dateWiseEmployeeAttendanceDetailsBeans ?? []).isNotEmpty)
          .mapIndexed((int index, DateWiseEmployeeAttendanceBean eachDateWiseEmployeeAttendanceBean) {
        List<DateWiseEmployeeAttendanceDetailsBean> dateWiseAttendanceDetails =
            (eachDateWiseEmployeeAttendanceBean.dateWiseEmployeeAttendanceDetailsBeans ?? []).whereNotNull().toList();
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
            DataCell(Text(eachDateWiseEmployeeAttendanceBean.date ?? "-")),
            DataCell(Text(noOfHoursSpent == null ? "-" : "${noOfHours ?? "-"}h ${noOfMinutes ?? "-"}m")),
            DataCell(
              Text(
                attendanceStatusDescription(eachDateWiseEmployeeAttendanceBean.isPresent),
                style: TextStyle(color: attendanceMarkerColor(eachDateWiseEmployeeAttendanceBean.isPresent)),
              ),
            ),
            DataCell(
              (eachDateWiseEmployeeAttendanceBean.dateWiseEmployeeAttendanceDetailsBeans ?? []).isEmpty
                  ? const Text("-")
                  : Row(
                      children: [
                        ...(eachDateWiseEmployeeAttendanceBean.dateWiseEmployeeAttendanceDetailsBeans ?? [])
                            .where((e) => e?.clockedTime != null && e?.status == 'active')
                            .whereNotNull()
                            .map((DateWiseEmployeeAttendanceDetailsBean eachDateWiseEmployeeAttendanceDetailsBean) =>
                                timeChip(eachDateWiseEmployeeAttendanceDetailsBean)),
                      ],
                    ),
            ),
          ],
        );
      }).toList(),
    );
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

  Color attendanceMarkerColor(String? status) {
    if ((status ?? "").contains("P")) return Colors.green;
    if ((status ?? "").contains("A")) return Colors.red;
    if ((status ?? "").contains("H")) return Colors.amber;
    return clayContainerTextColor(context);
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
}
