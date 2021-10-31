import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/app_expansion_tile.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

import 'admin_bulk_edit_attendance_time_slots_screen.dart';

class AdminEditAttendanceTimeSlots extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminEditAttendanceTimeSlots({Key? key, required this.adminProfile})
      : super(key: key);

  @override
  _AdminEditAttendanceTimeSlotsState createState() =>
      _AdminEditAttendanceTimeSlotsState();
}

class _AdminEditAttendanceTimeSlotsState
    extends State<AdminEditAttendanceTimeSlots> {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionFilterSelected = false;

  List<AttendanceTimeSlotBean> _attendanceTimeSlots = [];

  bool _isEditMode = false;

  List<AttendanceTimeSlotBean> attendanceTimeSlotsForSection = [];

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
    });
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse =
        await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" &&
        getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetStudentAttendanceTimeSlotsResponse
        getStudentAttendanceTimeSlotsResponse =
        await getStudentAttendanceTimeSlots(
            GetStudentAttendanceTimeSlotsRequest(
      schoolId: widget.adminProfile.schoolId,
      status: "active",
    ));
    if (getStudentAttendanceTimeSlotsResponse.httpStatus == "OK" &&
        getStudentAttendanceTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _attendanceTimeSlots =
            getStudentAttendanceTimeSlotsResponse.attendanceTimeSlotBeans!;
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
        color: _selectedSection == section
            ? Colors.blue[200]
            : clayContainerColor(context),
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
                  attendanceTimeSlotsForSection = [];
                } else {
                  _selectedSection = section;
                  attendanceTimeSlotsForSection = _attendanceTimeSlots
                      .where((e) => e.sectionId == section.sectionId)
                      .toList();
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
              _selectedSection == null
                  ? "Select a section"
                  : "Section: ${_selectedSection!.sectionName}",
            ),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.all(7),
                child: GridView.count(
                  childAspectRatio: 2.25,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
                  shrinkWrap: true,
                  children: _sectionsList
                      .map((e) => buildSectionCheckBox(e))
                      .toList(),
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
          title: const Text('Edit Attendance Time Slots'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
                child: const Text("Yes"),
                onPressed: () async {
                  HapticFeedback.vibrate();
                  CreateOrUpdateAttendanceTimeSlotBeansRequest
                      createOrUpdateAttendanceTimeSlotBeansRequest =
                      CreateOrUpdateAttendanceTimeSlotBeansRequest(
                    schoolId: widget.adminProfile.schoolId!,
                    agent: widget.adminProfile.userId!,
                    attendanceTimeSlotBeans:
                        _attendanceTimeSlots.where((e) => e.isEdited).toList(),
                  );
                  CreateOrUpdateAttendanceTimeSlotBeansResponse
                      createOrUpdateAttendanceTimeSlotBeansResponse =
                      await createOrUpdateAttendanceTimeSlotBeans(
                          createOrUpdateAttendanceTimeSlotBeansRequest);
                  if (createOrUpdateAttendanceTimeSlotBeansResponse
                              .httpStatus ==
                          "OK" &&
                      createOrUpdateAttendanceTimeSlotBeansResponse
                              .responseStatus ==
                          "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Success!"),
                      ),
                    );
                    await _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong!"),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                }),
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

  Future<void> _pickStartTime(BuildContext context, int index) async {
    TimeOfDay? _startTimePicker = await showTimePicker(
      context: context,
      initialTime:
          index < 0 || attendanceTimeSlotsForSection[index].startTime == null
              ? const TimeOfDay(hour: 0, minute: 0)
              : formatHHMMSSToTimeOfDay(
                  attendanceTimeSlotsForSection[index].startTime!),
    );

    if (_startTimePicker == null ||
        attendanceTimeSlotsForSection[index].startTime ==
            timeOfDayToHHMMSS(_startTimePicker)) return;
    setState(() {
      attendanceTimeSlotsForSection[index].startTime =
          timeOfDayToHHMMSS(_startTimePicker);
      attendanceTimeSlotsForSection[index].isEdited = true;
      attendanceTimeSlotsForSection[index].agent = widget.adminProfile.userId;
    });
  }

  Widget _buildStartTimePicker(int index) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayButton(
        depth: 40,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () async {
              HapticFeedback.vibrate();
              if (_isEditMode) {
                await _pickStartTime(context, index);
              }
            },
            child: Center(
              child: Text(
                attendanceTimeSlotsForSection.tryGet(index) != null &&
                        attendanceTimeSlotsForSection.tryGet(index).startTime !=
                            null
                    ? formatHHMMSStoHHMMA(
                        attendanceTimeSlotsForSection.tryGet(index).startTime)
                    : "-",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickEndTime(BuildContext context, int index) async {
    TimeOfDay? _endTimePicker = await showTimePicker(
      context: context,
      initialTime:
          index < 0 || attendanceTimeSlotsForSection[index].endTime == null
              ? const TimeOfDay(hour: 0, minute: 0)
              : formatHHMMSSToTimeOfDay(
                  attendanceTimeSlotsForSection[index].endTime!),
    );

    if (_endTimePicker == null ||
        attendanceTimeSlotsForSection[index].endTime ==
            timeOfDayToHHMMSS(_endTimePicker)) return;
    setState(() {
      attendanceTimeSlotsForSection[index].endTime =
          timeOfDayToHHMMSS(_endTimePicker);
      attendanceTimeSlotsForSection[index].isEdited = true;
      attendanceTimeSlotsForSection[index].agent = widget.adminProfile.userId;
    });
  }

  Widget _buildEndTimePicker(int index) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayButton(
        depth: 40,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () async {
              HapticFeedback.vibrate();
              if (_isEditMode) {
                await _pickEndTime(context, index);
              }
            },
            child: Center(
              child: Text(
                attendanceTimeSlotsForSection.tryGet(index) != null &&
                        attendanceTimeSlotsForSection.tryGet(index).endTime !=
                            null
                    ? formatHHMMSStoHHMMA(
                        attendanceTimeSlotsForSection.tryGet(index).endTime)
                    : "-",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAttendanceTimeSlotsForEachSection(Section section) {
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
                      Text(
                        section.sectionName!,
                      ),
                      InkWell(
                        onTap: () {
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ] +
                [
                  for (var i = 0;
                      i < attendanceTimeSlotsForSection.length;
                      i += 1)
                    i
                ].map(
                  (index) {
                    var e = attendanceTimeSlotsForSection[index];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: GestureDetector(
                        onLongPress: () {
                          HapticFeedback.vibrate();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Manager Name: ${e.managerName ?? "N/A"}"),
                            ),
                          );
                        },
                        child: ClayContainer(
                          depth: 20,
                          color: clayContainerColor(context),
                          borderRadius: 10,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
                            padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    e.week!,
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: _buildStartTimePicker(index)),
                                Expanded(
                                  flex: 2,
                                  child: _buildEndTimePicker(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildAttendanceTimeSlotsForAllSelectedSections() {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20,
              MediaQuery.of(context).size.width / 4, 20)
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
      case 'Bulk Edit All Attendance Time Slots':
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
        title: const Text("Edit Attendance Time Slots"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleNextScreenOptions,
            itemBuilder: (BuildContext context) {
              return {'Bulk Edit All Attendance Time Slots'}
                  .map((String choice) {
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
                  _selectedSection == null
                      ? Container()
                      : buildAttendanceTimeSlotsForAllSelectedSections(),
                ],
              ),
            ),
    );
  }
}
