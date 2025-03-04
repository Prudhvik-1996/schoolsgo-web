import 'package:clay_containers/widgets/clay_container.dart';
// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_attendence_stats_pdf_download.dart';
import 'package:schoolsgo_web/src/attendance/student/student_attendance_view_screen.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_information_center/modal/date_range_attendance.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminStudentAttendanceStatsScreen extends StatefulWidget {
  const AdminStudentAttendanceStatsScreen({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.defaultSelectedSection,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final Section? defaultSelectedSection;

  @override
  State<AdminStudentAttendanceStatsScreen> createState() => _AdminStudentAttendanceStatsScreenState();
}

class _AdminStudentAttendanceStatsScreenState extends State<AdminStudentAttendanceStatsScreen> {
  bool _isLoading = true;
  ScrollController dataTableHorizontalController = ScrollController();
  ScrollController dataTableVerticalController = ScrollController();

  late int selectedAcademicYearId;
  List<Section> sectionsList = [];

  List<StudentProfile> studentsList = [];
  Section? selectedSection;

  List<StudentDateRangeAttendanceBean> studentAttendanceBeansList = [];
  Map<StudentProfile, StudentDateRangeAttendanceBean?> studentAttendanceMap = {};

  bool _showDatePicker = false;
  bool _showContactInfo = false;
  int sortByPercentage = 0;
  late String startDate;
  late String endDate;
  late String startDateForAttendance;
  late String endDateForAttendance;
  TextEditingController rNoSearchController = TextEditingController();
  TextEditingController studentNameSearchController = TextEditingController();

  late SchoolInfoBean schoolInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        schoolInfo = getSchoolsResponse.schoolInfo!;
        startDate = schoolInfo.academicYearStartDate ?? convertDateTimeToYYYYMMDDFormat(DateTime.now());
        endDate = schoolInfo.academicYearEndDate ?? convertDateTimeToYYYYMMDDFormat(DateTime.now());
        startDateForAttendance = startDate;
        endDateForAttendance = DateTime.now().millisecondsSinceEpoch < convertYYYYMMDDFormatToDateTime(endDate).millisecondsSinceEpoch
            ? convertDateTimeToYYYYMMDDFormat(DateTime.now())
            : endDate;
      });
    }
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
          schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId, sectionId: widget.defaultSelectedSection?.sectionId),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId, sectionId: widget.defaultSelectedSection?.sectionId));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      setState(() {
        studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        studentsList.sort((a, b) {
          int aSection = sectionsList.where((es) => es.sectionId == a.sectionId).firstOrNull?.seqOrder ?? 0;
          int bSection = sectionsList.where((es) => es.sectionId == b.sectionId).firstOrNull?.seqOrder ?? 0;
          if (aSection == bSection) {
            return (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0);
          }
          return aSection.compareTo(bSection);
        });
      });
    }
    setState(() => _isLoading = false);
    await loadStudentAttendanceData();
  }

  Future<void> loadStudentAttendanceData() async {
    setState(() {
      _isLoading = true;
    });
    GetStudentDateRangeAttendanceResponse getStudentDateRangeAttendanceResponse = await getStudentDateRangeAttendance(
      GetStudentDateRangeAttendanceRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
        isAdminView: true,
        startDate: startDateForAttendance,
        endDate: endDateForAttendance,
      ),
    );
    if (getStudentDateRangeAttendanceResponse.httpStatus == "OK" && getStudentDateRangeAttendanceResponse.responseStatus == "success") {
      setState(() {
        studentAttendanceBeansList = getStudentDateRangeAttendanceResponse.studentDateRangeAttendanceBeanList!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    setState(() {
      _isLoading = false;
    });
    filteredStudentAttendanceStatsMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Stats"),
        actions: [
          if (!_isLoading)
            IconButton(
              tooltip: "Show Date Picker",
              onPressed: () => setState(() => _showDatePicker = !_showDatePicker),
              icon: Icon(
                Icons.date_range_outlined,
                color: _showDatePicker ? Colors.blue : null,
              ),
            ),
          if (!_isLoading)
            IconButton(
              tooltip: "Show Contact Info",
              onPressed: () => setState(() => _showContactInfo = !_showContactInfo),
              icon: Icon(
                Icons.phone,
                color: _showContactInfo ? Colors.blue : null,
              ),
            ),
          if (!_isLoading)
            IconButton(
              tooltip: "Download Stats Report",
              onPressed: () async {
                setState(() => _isLoading = true);
                await StudentAttendanceStatsPdfDownload(
                  studentAttendanceMap: studentAttendanceMap,
                  showContactInfo: _showContactInfo,
                  startDateForAttendance: startDateForAttendance,
                  endDateForAttendance: endDateForAttendance,
                  schoolInfo: schoolInfo,
                ).downloadAsPdf();
                setState(() => _isLoading = false);
              },
              icon: const Icon(
                Icons.download,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showDatePicker)
                  Row(
                    children: [
                      Expanded(child: _datePickers()),
                    ],
                  ),
                Expanded(
                  child: studentAttendanceTable(),
                ),
              ],
            ),
    );
  }

  Widget studentAttendanceTable() {
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 20,
      child: Scrollbar(
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
              child: Container(
                margin: const EdgeInsets.all(10),
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: DropdownButton<Section>(
                            hint: const Center(child: Text("Select Section")),
                            value: selectedSection,
                            onChanged: (Section? section) {
                              setState(() {
                                selectedSection = section;
                              });
                              filteredStudentAttendanceStatsMap();
                            },
                            items: [null, ...sectionsList]
                                .map(
                                  (e) => DropdownMenuItem<Section>(
                                    value: e,
                                    child: SizedBox(
                                      width: 75,
                                      height: 50,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            e?.sectionName ?? "All",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'R. No.',
                            hintText: 'R. No.',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          controller: rNoSearchController,
                          autofocus: true,
                          onChanged: (_) => filteredStudentAttendanceStatsMap(),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
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
                          controller: studentNameSearchController,
                          autofocus: true,
                          onChanged: (_) => filteredStudentAttendanceStatsMap(),
                        ),
                      ),
                    ),
                    if (_showContactInfo)
                      const DataColumn(
                        label: Text("Parent Name"),
                      ),
                    if (_showContactInfo)
                      const DataColumn(
                        label: Text("Contact"),
                      ),
                    const DataColumn(
                      numeric: true,
                      label: Text("No of working days"),
                    ),
                    const DataColumn(
                      numeric: true,
                      label: Text("No of days present"),
                    ),
                    const DataColumn(
                      numeric: true,
                      label: Text("No of days absent"),
                    ),
                    const DataColumn(
                      numeric: true,
                      label: Text("Attendance Percentage"),
                    ),
                  ],
                  rows: studentAttendanceMap.entries.mapIndexed((int index, MapEntry<StudentProfile, StudentDateRangeAttendanceBean?> entry) {
                    StudentProfile es = entry.key;
                    StudentDateRangeAttendanceBean? attendanceBean = entry.value;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith((Set states) {
                        if (index % 2 == 0) {
                          return Colors.grey[400];
                        }
                        return Colors.grey;
                      }),
                      cells: [
                        DataCell(Text(
                          es.sectionName ?? "-",
                          style: outLinedTextStyle(
                            textColor: Colors.black,
                            strokeWidth: 0,
                          ),
                        )),
                        DataCell(Row(
                          children: [
                            Text(
                              es.rollNumber ?? "-",
                              style: outLinedTextStyle(
                                textColor: Colors.black,
                                strokeWidth: 0,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              iconSize: 12,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentAttendanceViewScreen(
                                    studentProfile: es,
                                    startDate: startDateForAttendance,
                                    endDate: endDateForAttendance,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                        DataCell(Text(
                          es.studentFirstName ?? "-",
                          style: outLinedTextStyle(
                            textColor: Colors.black,
                            strokeWidth: 0,
                          ),
                        )),
                        if (_showContactInfo)
                          DataCell(Text(
                            es.gaurdianFirstName ?? "-",
                            style: outLinedTextStyle(
                              textColor: Colors.black,
                              strokeWidth: 0,
                            ),
                          )),
                        if (_showContactInfo)
                          DataCell(
                            (es.gaurdianMobile ?? "").isEmpty
                                ? const Center(child: Text("-"))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        es.gaurdianMobile ?? "",
                                        style: outLinedTextStyle(
                                          textColor: Colors.black,
                                          strokeWidth: 0,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () => launch("tel://${es.gaurdianMobile}"),
                                        icon: const Icon(
                                          Icons.phone,
                                          size: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                          ),
                        DataCell(
                          Text(
                            doubleToStringAsFixed(attendanceBean?.totalWorkingDays ?? 0),
                            style: outLinedTextStyle(outlinedTextColor: Colors.blue),
                          ),
                        ),
                        DataCell(
                          Text(
                            doubleToStringAsFixed((attendanceBean?.presentDays ?? 0)),
                            style: outLinedTextStyle(outlinedTextColor: Colors.green),
                          ),
                        ),
                        DataCell(
                          Text(
                            doubleToStringAsFixed((attendanceBean?.absentDays ?? 0)),
                            style: outLinedTextStyle(outlinedTextColor: Colors.red),
                          ),
                        ),
                        DataCell(Text("${doubleToStringAsFixed(attendanceBean?.attendancePercentage ?? 0)} %")),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void filteredStudentAttendanceStatsMap() {
    setState(() {
      studentAttendanceMap = Map.fromEntries(studentsList
          .where((es) =>
              (selectedSection != null ? (es.sectionId == selectedSection?.sectionId) : true) &&
              (es.rollNumber ?? "").toLowerCase().contains(rNoSearchController.text.toLowerCase()) &&
              (es.studentFirstName ?? "").toLowerCase().contains(studentNameSearchController.text.toLowerCase()))
          .map((e) => MapEntry(e, studentAttendanceBeansList.where((eab) => eab.studentId == e.studentId).firstOrNull)));
    });
  }

  TextStyle outLinedTextStyle({
    double fontSize = 14.0,
    Color textColor = Colors.black,
    Color outlinedTextColor = Colors.black,
    double strokeWidth = 0.25,
  }) {
    return TextStyle(
      inherit: true,
      fontSize: fontSize,
      color: textColor,
      shadows: [
        Shadow(
          offset: Offset(-strokeWidth, -strokeWidth),
          color: outlinedTextColor,
        ),
        Shadow(
          offset: Offset(strokeWidth, -strokeWidth),
          color: outlinedTextColor,
        ),
        Shadow(
          offset: Offset(strokeWidth, strokeWidth),
          color: outlinedTextColor,
        ),
        Shadow(
          offset: Offset(-strokeWidth, strokeWidth),
          color: outlinedTextColor,
        ),
      ],
    );
  }

  Widget _datePickers() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: true,
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(child: _getStartDatePicker()),
            const SizedBox(width: 10),
            Expanded(child: _getEndDatePicker()),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _getStartDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: convertYYYYMMDDFormatToDateTime(startDateForAttendance),
            firstDate: convertYYYYMMDDFormatToDateTime(startDate),
            lastDate: DateTime.now(),
            helpText: "Pick start date",
          );
          if (_newDate == null || _newDate.millisecondsSinceEpoch == convertYYYYMMDDFormatToDateTime(startDateForAttendance).millisecondsSinceEpoch)
            return;
          setState(() {
            startDateForAttendance = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
          await loadStudentAttendanceData();
        },
        child: ClayButton(
          depth: 20,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Start Date: ${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(startDateForAttendance))}",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getEndDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: convertYYYYMMDDFormatToDateTime(endDateForAttendance),
            firstDate: convertYYYYMMDDFormatToDateTime(startDate),
            lastDate: convertYYYYMMDDFormatToDateTime(endDate),
            helpText: "Pick end date",
          );
          if (_newDate == null || _newDate.millisecondsSinceEpoch == convertYYYYMMDDFormatToDateTime(endDateForAttendance).millisecondsSinceEpoch)
            return;
          setState(() {
            endDateForAttendance = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
          await loadStudentAttendanceData();
        },
        child: ClayButton(
          depth: 20,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "End Date: ${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(endDateForAttendance))}",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
