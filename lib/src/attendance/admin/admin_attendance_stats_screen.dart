import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_information_center/modal/date_range_attendance.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isSectionPickerOpen = false;

  List<StudentDateRangeAttendanceBean> studentAttendanceBeansList = [];

  bool _showDatePicker = false;
  bool _showContactInfo = false;
  late String startDate;
  late String endDate;
  late String startDateForAttendance;
  late String endDateForAttendance;
  TextEditingController rNoSearchController = TextEditingController();
  TextEditingController studentNameSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID')!;
    GetSchoolWiseAcademicYearsResponse getAcademicYearsResponse = await getSchoolWiseAcademicYears(
      GetSchoolWiseAcademicYearsRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
        academicYearId: selectedAcademicYearId,
      ),
    );
    if (getAcademicYearsResponse.httpStatus == "OK" && getAcademicYearsResponse.responseStatus == "success") {
      setState(() {
        startDate = (getAcademicYearsResponse.academicYearBeanList ?? [])
            .where((e) => e?.academicYearId == selectedAcademicYearId)
            .first!
            .academicYearStartDate!;
        endDate = convertDateTimeToYYYYMMDDFormat(DateTime.now());
        startDateForAttendance = (getAcademicYearsResponse.academicYearBeanList ?? [])
            .where((e) => e?.academicYearId == selectedAcademicYearId)
            .first!
            .academicYearStartDate!;
        endDateForAttendance = convertDateTimeToYYYYMMDDFormat(DateTime.now());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
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
        studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> loadStudentAttendanceData() async {
    setState(() {
      _isSectionPickerOpen = false;
    });
    if (selectedSection == null) {
      setState(() {
        studentAttendanceBeansList = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    GetStudentDateRangeAttendanceRequest getStudentDateRangeAttendanceRequest = GetStudentDateRangeAttendanceRequest(
      academicYearId: selectedAcademicYearId,
      sectionId: selectedSection?.sectionId,
      schoolId: selectedSection?.schoolId,
      isAdminView: true,
      startDate: startDateForAttendance,
      endDate: endDateForAttendance,
    );
    GetStudentDateRangeAttendanceResponse getStudentDateRangeAttendanceResponse = await getStudentDateRangeAttendance(
      GetStudentDateRangeAttendanceRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
        sectionId: widget.defaultSelectedSection?.sectionId,
        academicYearId: selectedAcademicYearId,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Stats"),
        actions: [
          if (!_isLoading && selectedSection != null)
            IconButton(
              onPressed: () => setState(() => _showDatePicker = !_showDatePicker),
              icon: Icon(
                Icons.date_range_outlined,
                color: _showDatePicker ? Colors.blue : null,
              ),
            ),
          if (!_isLoading && selectedSection != null)
            IconButton(
              onPressed: () => setState(() => _showContactInfo = !_showContactInfo),
              icon: Icon(
                Icons.phone,
                color: _showContactInfo ? Colors.blue : null,
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
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _sectionPicker()),
                  ],
                ),
                if (_showDatePicker)
                  Row(
                    children: [
                      Expanded(child: _datePickers()),
                    ],
                  ),
                Expanded(
                  child: selectedSection == null ? const Center(child: Text("Select a section to continue..")) : studentAttendanceTable(),
                ),
              ],
            ),
    );
  }

  Widget studentAttendanceTable() {
    List<StudentProfile> filteredStudentsList = studentsList
        .where((es) =>
            es.sectionId == selectedSection?.sectionId &&
            (es.rollNumber ?? "").toLowerCase().contains(rNoSearchController.text.toLowerCase()) &&
            (es.studentFirstName ?? "").toLowerCase().contains(studentNameSearchController.text.toLowerCase()))
        .toList();
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
                          onChanged: (_) => setState(() {}),
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
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
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
                  rows: filteredStudentsList.map((es) {
                    StudentDateRangeAttendanceBean? attendanceBean =
                        studentAttendanceBeansList.where((eab) => eab.studentId == es.studentId).firstOrNull;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith((Set states) {
                        if (filteredStudentsList.indexOf(es) % 2 == 0) {
                          return Colors.grey[400];
                        }
                        return null;
                      }),
                      cells: [
                        DataCell(Text(es.rollNumber ?? "-")),
                        DataCell(Text(es.studentFirstName ?? "-")),
                        if (_showContactInfo)
                          DataCell(
                            (es.gaurdianMobile ?? "").isEmpty
                                ? const Center(child: Text("-"))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(es.gaurdianMobile ?? ""),
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
                        DataCell(Text(doubleToStringAsFixed(attendanceBean?.totalWorkingDays ?? 0))),
                        DataCell(Text(doubleToStringAsFixed((attendanceBean?.presentDays ?? 0)))),
                        DataCell(Text(doubleToStringAsFixed((attendanceBean?.absentDays ?? 0)))),
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
          loadStudentAttendanceData();
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
          loadStudentAttendanceData();
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

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 20,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: _selectSectionExpanded(),
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
          if (selectedSection?.sectionId == section.sectionId) {
            setState(() => selectedSection = null);
            loadStudentAttendanceData();
          } else {
            setState(() => selectedSection = section);
            loadStudentAttendanceData();
          }
        },
        child: ClayButton(
          depth: 20,
          spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
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
          GestureDetector(
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
                      selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName}",
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
            children: sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;
        setState(() => _isSectionPickerOpen = !_isSectionPickerOpen);
      },
      child: ClayButton(
        depth: 20,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        height: 60,
        width: 60,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    selectedSection == null ? "Select a section" : "Sections: ${selectedSection!.sectionName}",
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
