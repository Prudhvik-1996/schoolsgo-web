import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_student_absentees_pdf_download.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class AdminStudentAbsenteesScreen extends StatefulWidget {
  const AdminStudentAbsenteesScreen({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.defaultSelectedSection,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final Section? defaultSelectedSection;

  @override
  State<AdminStudentAbsenteesScreen> createState() => _AdminStudentAbsenteesScreenState();
}

class _AdminStudentAbsenteesScreenState extends State<AdminStudentAbsenteesScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selectedAcademicYearId;

  List<StudentProfile> studentsList = [];
  List<StudentProfile> filteredStudentsList = [];
  String? searchingWith;
  ScrollController dataTableHorizontalController = ScrollController();
  ScrollController dataTableVerticalController = ScrollController();
  TextEditingController studentNameSearchController = TextEditingController();
  TextEditingController studentRollNoSearchController = TextEditingController();
  TextEditingController phoneNoSearchController = TextEditingController();
  bool _showContactInfo = false;

  List<Section> sectionsList = [];
  Section? selectedSection;

  List<StudentAttendanceBean> _studentAttendanceBeans = [];
  bool showOnlyAbsentees = true;

  DateTime selectedDate = DateTime.now();

  late SchoolInfoBean schoolInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      sectionsList = [];
      selectedSection = widget.defaultSelectedSection;
      _studentAttendanceBeans = [];
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');

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
      });
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      sectionId: widget.defaultSelectedSection?.sectionId,
      academicYearId: selectedAcademicYearId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
        sectionsList.sort((a, b) => (a.seqOrder ?? 0).compareTo(a.seqOrder ?? 0));
      });
    }

    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      sectionId: widget.defaultSelectedSection?.sectionId,
      academicYearId: selectedAcademicYearId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
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
        filteredStudentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        filteredStudentsList.sort((a, b) {
          int aSection = sectionsList.where((es) => es.sectionId == a.sectionId).firstOrNull?.seqOrder ?? 0;
          int bSection = sectionsList.where((es) => es.sectionId == b.sectionId).firstOrNull?.seqOrder ?? 0;
          if (aSection == bSection) {
            return (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0);
          }
          return aSection.compareTo(bSection);
        });
      });
    }

    await _loadStudentAttendance();
    filterStudentsList();
  }

  Future<void> _loadStudentAttendance() async {
    // if (selectedSection == null) return;
    setState(() {
      _isLoading = true;
    });

    GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse = await getStudentAttendanceBeans(GetStudentAttendanceBeansRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId, date: convertDateTimeToYYYYMMDDFormat(selectedDate),
      // sectionId: selectedSection!.sectionId,
      academicYearId: selectedAcademicYearId,
    ));
    if (getStudentAttendanceBeansResponse.httpStatus == "OK" && getStudentAttendanceBeansResponse.responseStatus == "success") {
      setState(() {
        _studentAttendanceBeans = getStudentAttendanceBeansResponse.studentAttendanceBeans!;
      });
    }
    filterStudentsList();

    setState(() {
      _isLoading = false;
    });
  }

  void filterStudentsList() {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      filteredStudentsList = studentsList.where((e) => selectedSection != null ? e.sectionId == selectedSection?.sectionId : true).toList();
      if (studentNameSearchController.text.trim().isNotEmpty) {
        filteredStudentsList = filteredStudentsList.where((student) {
          String searchObject = [
                ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                student.studentFirstName ?? "",
                student.studentMiddleName ?? "",
                student.studentLastName ?? ""
              ].where((e) => e != "").join(" ").trim() +
              " - ${student.sectionName}";
          return searchObject.toLowerCase().contains(studentNameSearchController.text.trim().toLowerCase());
        }).toList();
      }
      if (studentRollNoSearchController.text.trim().isNotEmpty) {
        filteredStudentsList = filteredStudentsList.where((es) => (es.rollNumber ?? "").contains(studentRollNoSearchController.text.trim())).toList();
      }
      if (phoneNoSearchController.text.trim().isNotEmpty) {
        filteredStudentsList = filteredStudentsList.where((es) => (es.gaurdianMobile ?? "").contains(phoneNoSearchController.text.trim())).toList();
      }
      if (showOnlyAbsentees) {
        filteredStudentsList = filteredStudentsList.where((es) {
          List<StudentAttendanceBean> eachStudentAttendanceBeans = (_studentAttendanceBeans.where((esab) => esab.studentId == es.studentId).toList()
            ..sort((a, b) =>
                getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime, null).compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime, null))));
          return eachStudentAttendanceBeans.where((e) => e.isPresent == -1).isNotEmpty;
        }).toList();
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Absentees Screen"),
        actions: [
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
              tooltip: "Download Report",
              onPressed: () async {
                setState(() => _isLoading = true);
                await StudentAbsenteesPdfDownload(
                  filteredStudentsList: filteredStudentsList,
                  studentAttendanceBeans: _studentAttendanceBeans,
                  showContactInfo: _showContactInfo,
                  showOnlyAbsentees: showOnlyAbsentees,
                  schoolInfo: schoolInfo,
                  selectedDate: selectedDate,
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
              children: [
                const SizedBox(height: 10),
                datePickerWidget(),
                if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 10),
                if (MediaQuery.of(context).orientation == Orientation.portrait)
                  Container(
                    margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: showOnlyAbsenteesButton(),
                  ),
                if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 10),
                Expanded(
                  child: populateDataTableForAbsentees(),
                ),
              ],
            ),
    );
  }

  Widget datePickerWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              setState(() => selectedDate = selectedDate.subtract(const Duration(days: 1)));
              await _loadStudentAttendance();
            },
            child: ClayButton(
              depth: 40,
              parentColor: clayContainerColor(context),
              surfaceColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 100,
              height: 30,
              width: 30,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_left),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2021),
                  lastDate: DateTime.now(),
                  helpText: "Pick date",
                );
                setState(() {
                  selectedDate = _newDate ?? selectedDate;
                });
                await _loadStudentAttendance();
              },
              child: ClayButton(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 1,
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
                            convertDateTimeToDDMMYYYYFormat(selectedDate),
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
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              if (convertDateTimeToDDMMYYYYFormat(selectedDate) == convertDateTimeToDDMMYYYYFormat(DateTime.now())) return;
              setState(() => selectedDate = selectedDate.add(const Duration(days: 1)));
              await _loadStudentAttendance();
            },
            child: ClayButton(
              depth: 40,
              parentColor: clayContainerColor(context),
              surfaceColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 100,
              height: 30,
              width: 30,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_right),
                ),
              ),
            ),
          ),
          if (MediaQuery.of(context).orientation == Orientation.landscape)
            const SizedBox(
              width: 10,
            ),
          if (MediaQuery.of(context).orientation == Orientation.landscape) showOnlyAbsenteesButton(),
        ],
      ),
    );
  }

  Widget showOnlyAbsenteesButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showOnlyAbsentees = !showOnlyAbsentees;
        });
        filterStudentsList();
      },
      child: Card(
        color: showOnlyAbsentees ? Colors.blue : null,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Text("Show Only Absentees")),
        ),
      ),
    );
  }

  Widget populateDataTableForAbsentees() {
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
                              filterStudentsList();
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
                      numeric: true,
                      label: Row(
                        children: [
                          searchingWith == "Roll No."
                              ? SizedBox(
                                  width: 100,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Roll No.',
                                      hintText: 'Roll No.',
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blue),
                                      ),
                                      contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                    controller: studentRollNoSearchController,
                                    autofocus: true,
                                    onChanged: (_) {
                                      filterStudentsList();
                                    },
                                  ),
                                )
                              : const Text("Roll No."),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              editSearchingWith(searchingWith == "Roll No." ? null : "Roll No.");
                              filterStudentsList();
                            },
                            icon: Icon(
                              searchingWith != "Roll No." ? Icons.search : Icons.close,
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                    ),
                    DataColumn(
                      label: Row(
                        children: [
                          searchingWith == "Student Name"
                              ? SizedBox(
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
                                    onChanged: (_) {
                                      filterStudentsList();
                                    },
                                  ),
                                )
                              : const Text("Student Name"),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              editSearchingWith(searchingWith == "Student Name" ? null : "Student Name");
                              filterStudentsList();
                            },
                            icon: Icon(
                              searchingWith != "Student Name" ? Icons.search : Icons.close,
                            ),
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                    ),
                    if (_showContactInfo)
                      DataColumn(
                        label: const Text("Parent Name"),
                        onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                      ),
                    if (_showContactInfo)
                      DataColumn(
                        numeric: true,
                        label: Row(
                          children: [
                            searchingWith == "Phone Number"
                                ? SizedBox(
                                    width: 100,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Phone Number',
                                        hintText: 'Phone Number',
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                      controller: phoneNoSearchController,
                                      keyboardType: TextInputType.phone,
                                      autofocus: true,
                                      onChanged: (_) {
                                        filterStudentsList();
                                      },
                                    ),
                                  )
                                : const Text("Phone Number"),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                editSearchingWith(searchingWith == "Phone Number" ? null : "Phone Number");
                                filterStudentsList();
                              },
                              icon: Icon(
                                searchingWith != "Phone Number" ? Icons.search : Icons.close,
                              ),
                            ),
                          ],
                        ),
                        onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
                      ),
                    const DataColumn(label: Text("Attendance")),
                  ],
                  rows: [
                    ...filteredStudentsList
                        // .where((StudentProfile es) => es.sectionId == selectedSection.sectionId)
                        .map(
                      (es) => DataRow(
                        color: MaterialStateProperty.resolveWith((Set states) {
                          if (filteredStudentsList.indexOf(es) % 2 == 0) {
                            return Colors.grey[400];
                          }
                          return Colors.grey;
                        }),
                        cells: [
                          DataCell(Text(es.sectionName ?? "")),
                          DataCell(
                            placeholder: true,
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(es.rollNumber ?? ""),
                            ),
                          ),
                          DataCell(Text(es.studentFirstName ?? "")),
                          if (_showContactInfo) DataCell(Text(es.gaurdianFirstName ?? "")),
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
                          DataCell(
                            Row(
                              children: [
                                ...(_studentAttendanceBeans.where((esab) => esab.studentId == es.studentId).toList()
                                      ..sort((a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime, null)
                                          .compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime, null))))
                                    .where((e) => showOnlyAbsentees ? e.isPresent == -1 : true)
                                    .map((esab) => studentAttendanceBeanWidget(esab))
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
      ),
    );
  }

  Widget studentAttendanceBeanWidget(StudentAttendanceBean esab) {
    if (esab.startTime == null && esab.endTime == null) return Container();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                "${esab.startTime == null ? "-" : formatHHMMSStoHHMMA(esab.startTime!)} - ${esab.endTime == null ? "-" : formatHHMMSStoHHMMA(esab.endTime!)}",
              ),
            ),
            if (esab.isPresent == 1 || esab.isPresent == -1)
              PopupMenuButton<String>(
                tooltip: "More Options",
                onSelected: (String choice) async {
                  if (choice == "Mark Present") {
                    //  TODO mark present
                  } else if (choice == "Mark Absent") {
                    //  TODO mark absent
                  } else if (choice == "Clear") {
                    //  TODO un mark
                  } else {
                    debugPrint("Clicked on invalid choice");
                  }
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
                                schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                                agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                                studentAttendanceBeans: [
                                  esab
                                    ..isPresent = choice == "Mark Present"
                                        ? 1
                                        : choice == "Mark Absent"
                                            ? -1
                                            : 0
                                ],
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
                                  esab.isPresent = choice == "Mark Present"
                                      ? 1
                                      : choice == "Mark Absent"
                                          ? -1
                                          : 0;
                                  esab.agent = widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId;
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
                },
                itemBuilder: (BuildContext context) {
                  return {
                    if (esab.isPresent != 1) "Mark Present",
                    if (esab.isPresent != -1) "Mark Absent",
                    if (esab.isPresent != 0) "Clear",
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
          ],
        ),
        color: esab.isPresent == 1
            ? Colors.green
            : esab.isPresent == -1
                ? Colors.red
                : Colors.blue,
      ),
    );
  }

  void editSearchingWith(String? newSearchingWith) => setState(() {
        studentNameSearchController.text = "";
        studentRollNoSearchController.text = "";
        phoneNoSearchController.text = "";
        searchingWith = newSearchingWith;
      });

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0)));
      } else {
        filteredStudentsList.sort((a, b) => (int.tryParse(b.rollNumber ?? "") ?? 0).compareTo((int.tryParse(a.rollNumber ?? "") ?? 0)));
      }
    } else if (columnIndex == 1) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (a.studentFirstName ?? "").compareTo((b.studentFirstName ?? "")));
      } else {
        filteredStudentsList.sort((a, b) => (b.studentFirstName ?? "").compareTo((a.studentFirstName ?? "")));
      }
    } else if (columnIndex == 2) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (a.gaurdianFirstName ?? "").compareTo((b.gaurdianFirstName ?? "")));
      } else {
        filteredStudentsList.sort((a, b) => (b.gaurdianFirstName ?? "").compareTo((a.gaurdianFirstName ?? "")));
      }
    } else if (columnIndex == 3) {
      if (ascending) {
        filteredStudentsList.sort((a, b) => (a.gaurdianMobile ?? "").compareTo((b.gaurdianMobile ?? "")));
      } else {
        filteredStudentsList.sort((a, b) => (b.gaurdianMobile ?? "").compareTo((a.gaurdianMobile ?? "")));
      }
    }
    setState(() => debugPrint("Sorted based on $columnIndex"));
  }
}
