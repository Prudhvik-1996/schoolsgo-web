import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/app_expansion_tile.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

import 'admin_bulk_edit_attendance_time_slots_screen.dart';

class AdminAttendanceManagementScreen extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminAttendanceManagementScreen({Key? key, required this.adminProfile}) : super(key: key);

  @override
  _AdminAttendanceManagementScreenState createState() => _AdminAttendanceManagementScreenState();
}

class _AdminAttendanceManagementScreenState extends State<AdminAttendanceManagementScreen> {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionFilterSelected = false;

  List<Teacher> _teachers = [];

  List<AttendanceTimeSlotBean> _attendanceTimeSlots = [];

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isEditMode = false;
      _isLoading = true;
      _isSectionFilterSelected = false;
      _sectionsList = [];
      _teachers = [];
    });
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetStudentAttendanceTimeSlotsResponse getStudentAttendanceTimeSlotsResponse =
        await getStudentAttendanceTimeSlots(GetStudentAttendanceTimeSlotsRequest(
      schoolId: widget.adminProfile.schoolId,
      status: "active",
    ));
    if (getStudentAttendanceTimeSlotsResponse.httpStatus == "OK" && getStudentAttendanceTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _attendanceTimeSlots = getStudentAttendanceTimeSlotsResponse.attendanceTimeSlotBeans!;
      });
    }

    GetTeachersResponse getTeachersResponse = await getTeachers(GetTeachersRequest(schoolId: widget.adminProfile.schoolId));
    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachers = getTeachersResponse.teachers!;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayButton(
        depth: 40,
        color: _selectedSection == section ? Colors.blue[200] : clayContainerColor(context),
        spread: _selectedSection == section ? 0 : 2,
        borderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                if (_selectedSection == section) {
                  _selectedSection = null;
                } else {
                  _selectedSection = section;
                }
                _isSectionFilterSelected = !_isSectionFilterSelected;
              });
            },
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
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
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
              _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName!}",
            ),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.all(7),
                child: GridView.count(
                  childAspectRatio: 2.25,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
                  shrinkWrap: true,
                  children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
                ),
              ),
            ],
            onExpansionChanged: (val) {
              HapticFeedback.vibrate();
            },
          ),
        ),
      ),
    );
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
              child: const Text("YES"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                CreateOrUpdateAttendanceTimeSlotBeansRequest createOrUpdateAttendanceTimeSlotBeansRequest =
                    CreateOrUpdateAttendanceTimeSlotBeansRequest(
                  schoolId: widget.adminProfile.schoolId,
                  agent: widget.adminProfile.userId,
                  attendanceTimeSlotBeans: _attendanceTimeSlots.where((e) => e.isEdited).toList(),
                );
                CreateOrUpdateAttendanceTimeSlotBeansResponse createOrUpdateAttendanceTimeSlotBeansResponse =
                    await createOrUpdateAttendanceTimeSlotBeans(createOrUpdateAttendanceTimeSlotBeansRequest);
                if (createOrUpdateAttendanceTimeSlotBeansResponse.httpStatus == "OK" &&
                    createOrUpdateAttendanceTimeSlotBeansResponse.responseStatus == "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Success!"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error Occurred"),
                    ),
                  );
                }
                _loadData();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                _loadData();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildAttendanceTimeSlotsForEachSection(Section section) {
    List<AttendanceTimeSlotBean> attendanceTimeSlotsForSection = _attendanceTimeSlots.where((e) => e.sectionId == section.sectionId).toList();

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(section.sectionName!),
                      widget.adminProfile.isMegaAdmin
                          ? Container()
                          : InkWell(
                              onTap: () {
                                HapticFeedback.vibrate();
                                if (_isEditMode) {
                                  _saveChanges();
                                } else {
                                  setState(() {
                                    _isEditMode = true;
                                  });
                                }
                              },
                              child: ClayButton(
                                color: clayContainerColor(context),
                                height: 50,
                                width: 50,
                                borderRadius: 50,
                                child: Icon(
                                  _isEditMode ? Icons.check : Icons.edit,
                                  color: _isEditMode ? Colors.green[200] : Colors.black38,
                                ),
                              ),
                            )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ] +
                attendanceTimeSlotsForSection
                    .map(
                      (e) => Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: ClayContainer(
                          depth: 20,
                          color: clayContainerColor(context),
                          borderRadius: 10,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
                            padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: _isEditMode ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   "${e.week} - ${e.startTime} - ${e.endTime} - ${e.managerName}",
                                // ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    e.week!,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    convert24To12HourFormat(e.startTime!),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    convert24To12HourFormat(e.endTime!),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: _isEditMode
                                      ? DropdownButton(
                                          isExpanded: true,
                                          items: _teachers
                                              .map(
                                                (e1) => DropdownMenuItem<Teacher>(
                                                  value: e1,
                                                  child: Text(e1.teacherName!),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (Teacher? e1) {
                                            setState(() {
                                              e.managerId = e1?.teacherId;
                                              e.managerName = e1?.teacherName;
                                              e.agent = widget.adminProfile.agent;
                                              e.isEdited = true;
                                            });
                                          },
                                          value: e.managerId == null ? null : _teachers.where((e1) => e1.teacherId == e.managerId).first,
                                        )
                                      : Text(
                                          e.managerName!,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildAttendanceTimeSlotsForAllSelectedSections() {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: Column(
        children: [_selectedSection]
            .map(
              (e) => buildAttendanceTimeSlotsForEachSection(e!),
            )
            .toList(),
      ),
    );
  }

  void handleNextScreenOptions(String value) {
    switch (value) {
      case 'Edit Attendance Time Slots':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AdminBulkEditAttendanceTimeSlotsScreen(
            adminProfile: widget.adminProfile,
          );
        }));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Management"),
        actions: widget.adminProfile.isMegaAdmin
            ? null
            : <Widget>[
                PopupMenuButton<String>(
                  onSelected: handleNextScreenOptions,
                  itemBuilder: (BuildContext context) {
                    return {'Edit Attendance Time Slots'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
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
                  _buildSectionsFilter(),
                  _selectedSection == null ? Container() : buildAttendanceTimeSlotsForAllSelectedSections(),
                ],
              ),
            ),
    );
  }
}
