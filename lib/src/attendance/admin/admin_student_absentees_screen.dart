import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminStudentAbsenteesScreen extends StatefulWidget {
  const AdminStudentAbsenteesScreen({
    super.key,
    required this.adminProfile,
  });

  final AdminProfile adminProfile;

  @override
  State<AdminStudentAbsenteesScreen> createState() => _AdminStudentAbsenteesScreenState();
}

class _AdminStudentAbsenteesScreenState extends State<AdminStudentAbsenteesScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentProfile> studentsList = [];
  List<StudentProfile> filteredStudentsList = [];
  String? searchingWith;
  final ScrollController dataTableController = ScrollController();
  TextEditingController studentNameSearchController = TextEditingController();
  TextEditingController studentRollNoSearchController = TextEditingController();
  TextEditingController phoneNoSearchController = TextEditingController();

  List<Section> sectionsList = [];
  Section? selectedSection;
  bool _isSectionPickerOpen = false;

  List<StudentAttendanceBean> _studentAttendanceBeans = [];
  List<AttendanceTimeSlotBean> _attendanceTimeSlotBeans = [];
  bool showOnlyAbsentees = true;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      sectionsList = [];
      _studentAttendanceBeans = [];
      _attendanceTimeSlotBeans = [];
    });

    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
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
        studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      });
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });

    _loadStudentAttendance();
    filterStudentsList();
  }

  Future<void> _loadStudentAttendance() async {
    if (selectedSection == null) return;
    setState(() {
      _isLoading = true;
    });

    GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse = await getStudentAttendanceBeans(GetStudentAttendanceBeansRequest(
      schoolId: widget.adminProfile.schoolId,
      date: convertDateTimeToYYYYMMDDFormat(selectedDate),
      sectionId: selectedSection!.sectionId,
    ));
    if (getStudentAttendanceBeansResponse.httpStatus == "OK" && getStudentAttendanceBeansResponse.responseStatus == "success") {
      setState(() {
        _studentAttendanceBeans = getStudentAttendanceBeansResponse.studentAttendanceBeans!;
        _attendanceTimeSlotBeans = getStudentAttendanceBeansResponse.attendanceTimeSlotBeans!;
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
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              children: [
                const SizedBox(height: 30),
                _sectionPicker(),
                const SizedBox(height: 30),
                datePickerWidget(),
                if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 30),
                if (MediaQuery.of(context).orientation == Orientation.portrait)
                  Container(
                    margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    child: showOnlyAbsenteesButton(),
                  ),
                const SizedBox(height: 30),
                selectedSection == null
                    ? const Center(
                        child: Text("Select a section to continue"),
                      )
                    : populateDataTableForAbsentees(selectedSection!),
              ],
            ),
    );
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
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
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                selectedSection == null ? "Select a section" : "Sections:",
              ),
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
            children: sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      height: 60,
      child: selectedSection != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_isLoading) return;
                      setState(() {
                        _isSectionPickerOpen = !_isSectionPickerOpen;
                      });
                    },
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName!}",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  child: const Icon(Icons.close),
                  onTap: () {
                    setState(() {
                      selectedSection = null;
                    });
                    filterStudentsList();
                  },
                ),
                const SizedBox(width: 10),
              ],
            )
          : InkWell(
              onTap: () {
                if (_isLoading) return;
                setState(() {
                  _isSectionPickerOpen = !_isSectionPickerOpen;
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 14, 5, 14),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName!}",
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
          if (_isLoading) return;
          setState(() {
            if (selectedSection != null && selectedSection!.sectionId == section.sectionId) {
              selectedSection = null;
            } else {
              selectedSection = section;
            }
            _isSectionPickerOpen = false;
          });
          filterStudentsList();
          _loadStudentAttendance();
        },
        child: ClayButton(
          depth: 40,
          color: selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue[200] : clayContainerColor(context),
          spread: selectedSection != null && selectedSection!.sectionId == section.sectionId! ? 0 : 2,
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

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              )
            : _selectSectionCollapsed(),
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

  Widget populateDataTableForAbsentees(Section selectedSection) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 20,
      child: Scrollbar(
        thumbVisibility: true,
        controller: dataTableController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: dataTableController,
          child: DataTable(
            columns: [
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
              DataColumn(
                label: const Text("Parent Name"),
                onSort: (columnIndex, ascending) => onSortColum(columnIndex, ascending),
              ),
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
              ...filteredStudentsList.where((StudentProfile es) => es.sectionId == selectedSection.sectionId).map(
                    (es) => DataRow(
                      cells: [
                        DataCell(
                          placeholder: true,
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(es.rollNumber ?? ""),
                          ),
                        ),
                        DataCell(Text(es.studentFirstName ?? "")),
                        DataCell(Text(es.gaurdianFirstName ?? "")),
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
                              schoolId: widget.adminProfile.schoolId,
                              agent: widget.adminProfile.userId,
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
                                esab.agent = widget.adminProfile.userId;
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
