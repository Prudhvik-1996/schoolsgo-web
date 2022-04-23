import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/attendance/model/attendance_beans.dart';
import 'package:schoolsgo_web/src/common_components/app_expansion_tile.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionFilterSelected = false;

  List<Teacher> _teachers = [];

  List<AttendanceTimeSlotBean> _attendanceTimeSlots = [];
  AttendanceTimeSlotBean? newAttendanceTimeSlot;

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
                  newAttendanceTimeSlot = AttendanceTimeSlotBean(
                    sectionName: section.sectionName,
                    sectionId: section.sectionId,
                    status: "active",
                    agent: widget.adminProfile.userId,
                  );
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
      context: _scaffoldKey.currentContext!,
      builder: (dialogueContext) {
        print("175: ${_attendanceTimeSlots.where((e) => e.isEdited).map((e) => e.toJson().toString()).join("\n")}");
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
    List<AttendanceTimeSlotBean> attendanceTimeSlotsForSection =
        _attendanceTimeSlots.where((e) => e.sectionId == section.sectionId && e.status == "active").toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 25, 15, 25),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        borderRadius: 10,
        spread: 4,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 25, 15, 25),
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
                        margin: MediaQuery.of(context).orientation == Orientation.portrait
                            ? const EdgeInsets.fromLTRB(0, 10, 0, 10)
                            : const EdgeInsets.fromLTRB(40, 10, 40, 10),
                        child: ClayContainer(
                          depth: 20,
                          color: clayContainerColor(context),
                          borderRadius: 10,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
                            padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: _isEditMode ? CrossAxisAlignment.center : CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        e.week!,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    if (!_isEditMode)
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          convert24To12HourFormat(e.startTime!) + "   " + convert24To12HourFormat(e.endTime!),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    if (_isEditMode)
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                          child: _startTimePicker(e),
                                        ),
                                      ),
                                    if (_isEditMode)
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                          child: _endTimePicker(e),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: _isEditMode
                                          ? searchableDropdownButtonForTeacher(e)
                                          : Text(
                                              e.managerName!,
                                            ),
                                    ),
                                    if (_isEditMode)
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: _scaffoldKey.currentContext!,
                                                builder: (currentContext) {
                                                  return AlertDialog(
                                                    title: const Text("Are you sure you want to delete the time slot"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            e.status = "inactive";
                                                            e.agent = widget.adminProfile.userId;
                                                            e.isEdited = true;
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("Yes"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("No"),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList() +
                [
                  if (_isEditMode)
                    Container(
                      margin: MediaQuery.of(context).orientation == Orientation.portrait
                          ? const EdgeInsets.fromLTRB(0, 10, 0, 10)
                          : const EdgeInsets.fromLTRB(40, 10, 40, 10),
                      child: ClayContainer(
                        depth: 20,
                        color: clayContainerColor(context),
                        borderRadius: 10,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
                          padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: DropdownButton(
                                      hint: const Text("Week"),
                                      value: newAttendanceTimeSlot!.week,
                                      items: WEEKS
                                          .map((e) => DropdownMenuItem(
                                                child: Text(e),
                                                value: e,
                                              ))
                                          .toList(),
                                      onChanged: (String? newWeek) {
                                        setState(() {
                                          if (newWeek == null) {
                                            newAttendanceTimeSlot?.week = null;
                                            newAttendanceTimeSlot?.weekId = null;
                                            newAttendanceTimeSlot?.isEdited = true;
                                          } else {
                                            newAttendanceTimeSlot?.week = newWeek;
                                            newAttendanceTimeSlot?.weekId = WEEKS.indexOf(newWeek) + 1;
                                            newAttendanceTimeSlot?.isEdited = true;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                      child: _startTimePicker(newAttendanceTimeSlot!),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                                      child: _endTimePicker(newAttendanceTimeSlot!),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: _isEditMode
                                        ? searchableDropdownButtonForTeacher(newAttendanceTimeSlot!)
                                        : Text(
                                            newAttendanceTimeSlot?.managerName ?? "",
                                          ),
                                  ),
                                  if (_isEditMode)
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (newAttendanceTimeSlot!.startTime == null ||
                                              newAttendanceTimeSlot!.endTime == null ||
                                              newAttendanceTimeSlot!.week == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("All the fields are mandatory!"),
                                              ),
                                            );
                                            return;
                                          }
                                          showDialog(
                                              context: _scaffoldKey.currentContext!,
                                              builder: (currentContext) {
                                                return AlertDialog(
                                                  title: const Text("Are you sure you want to add the time slot"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _attendanceTimeSlots.add(newAttendanceTimeSlot!);
                                                        });
                                                        setState(() {
                                                          newAttendanceTimeSlot = AttendanceTimeSlotBean(
                                                            sectionName: section.sectionName,
                                                            sectionId: section.sectionId,
                                                            status: "active",
                                                            agent: widget.adminProfile.userId,
                                                          )..isEdited = true;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Yes"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("No"),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
          ),
        ),
      ),
    );
  }

  GestureDetector _startTimePicker(AttendanceTimeSlotBean atsBean) {
    return GestureDetector(
      onTap: () async {
        if (atsBean.week == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Select week to pick start time"),
            ),
          );
          return;
        }
        TimeOfDay? _startTimePicker = await showTimePicker(
          helpText: atsBean.attendanceTimeSlotId == null ? "Start time for Attendance New Time Slot" : "Start time for Attendance Time Slot",
          context: context,
          initialTime: atsBean.startTime == null ? const TimeOfDay(hour: 0, minute: 0) : formatHHMMSSToTimeOfDay(atsBean.startTime!),
        );
        if (_startTimePicker == null || atsBean.startTime == timeOfDayToHHMMSS(_startTimePicker)) return;
        String? errorText;
        _attendanceTimeSlots
            .where((e) => e.sectionId == _selectedSection?.sectionId && e != atsBean && e.startTime != null && e.endTime != null && e.week != null)
            .toList()
            .forEach((AttendanceTimeSlotBean slot) {
          int eachSlotStartTime = getSecondsEquivalentOfTimeFromWHHMMSS(slot.startTime, slot.weekId);
          int eachSlotEndTime = getSecondsEquivalentOfTimeFromWHHMMSS(slot.endTime, slot.weekId);
          int atsStartTime = getSecondsEquivalentOfTimeFromWHHMMSS(timeOfDayToHHMMSS(_startTimePicker), atsBean.weekId!);
          if ((eachSlotStartTime < atsStartTime && atsStartTime < eachSlotEndTime) || eachSlotStartTime == atsStartTime) {
            errorText =
                "Start time should not fall in between other time slots. Violating time slot is: ${slot.week} ${convert24To12HourFormat(slot.startTime!)} - ${convert24To12HourFormat(slot.endTime!)}";
            return;
          }
        });
        if (errorText != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorText!),
            ),
          );
          return;
        }
        setState(() {
          atsBean.startTime = timeOfDayToHHMMSS(_startTimePicker);
          atsBean.isEdited = true;
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Start Time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Center(
              child: Text(
                atsBean.startTime == null ? "-" : convert24To12HourFormat(atsBean.startTime!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _endTimePicker(AttendanceTimeSlotBean atsBean) {
    return GestureDetector(
      onTap: () async {
        if (atsBean.startTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Select start time to pick end time"),
            ),
          );
          return;
        }
        TimeOfDay? _endTimePicker = await showTimePicker(
          helpText: atsBean.attendanceTimeSlotId == null ? "End time for Attendance New Time Slot" : "End time for Attendance Time Slot",
          context: context,
          initialTime: stringToTimeOfDay(atsBean.startTime!),
        );
        if (_endTimePicker == null || atsBean.endTime == timeOfDayToHHMMSS(_endTimePicker)) return;
        if (getSecondsEquivalentOfTimeFromWHHMMSS(timeOfDayToHHMMSS(_endTimePicker), atsBean.weekId!) <=
            getSecondsEquivalentOfTimeFromWHHMMSS(atsBean.startTime, atsBean.weekId!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("End time must be greater than Start time"),
            ),
          );
          return;
        }
        String? errorText;
        _attendanceTimeSlots
            .where((e) => e.sectionId == _selectedSection?.sectionId && e != atsBean && e.startTime != null && e.endTime != null && e.week != null)
            .toList()
            .forEach((AttendanceTimeSlotBean slot) {
          int eachSlotStartTime = getSecondsEquivalentOfTimeFromWHHMMSS(slot.startTime, slot.weekId);
          int eachSlotEndTime = getSecondsEquivalentOfTimeFromWHHMMSS(slot.endTime, slot.weekId);
          int atsEndTime = getSecondsEquivalentOfTimeFromWHHMMSS(timeOfDayToHHMMSS(_endTimePicker), atsBean.weekId!);
          if ((eachSlotStartTime < atsEndTime && atsEndTime < eachSlotEndTime) || eachSlotEndTime == atsEndTime) {
            errorText =
                "End time should not fall in between other time slots. Violating time slot is: ${slot.week} ${convert24To12HourFormat(slot.startTime!)} - ${convert24To12HourFormat(slot.endTime!)}";
            return;
          }
        });
        if (errorText != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorText!),
            ),
          );
          return;
        }
        setState(() {
          atsBean.endTime = timeOfDayToHHMMSS(_endTimePicker);
          atsBean.isEdited = true;
        });
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'End Time',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Center(
              child: Text(
                atsBean.endTime == null ? "-" : convert24To12HourFormat(atsBean.endTime!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DropdownSearch<Teacher> searchableDropdownButtonForTeacher(AttendanceTimeSlotBean atsBean) {
    return DropdownSearch<Teacher>(
      mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
      selectedItem: atsBean.managerId == null ? null : _teachers.where((e) => e.teacherId == atsBean.managerId).firstOrNull,
      items: _teachers,
      itemAsString: (Teacher? teacher) {
        return teacher == null ? "" : teacher.teacherName ?? "";
      },
      showSearchBox: true,
      dropdownBuilder: (BuildContext context, Teacher? teacher) {
        return buildTeacherWidget(teacher ?? Teacher());
      },
      onChanged: (Teacher? teacher) {
        setState(() {
          atsBean.managerId = teacher?.teacherId;
          atsBean.managerName = teacher?.teacherName;
          atsBean.agent = widget.adminProfile.agent;
          atsBean.isEdited = true;
        });
      },
      showClearButton: true,
      compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
      dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
      filterFn: (Teacher? teacher, String? key) {
        return teacher!.teacherName!.toLowerCase().contains(key!.toLowerCase());
      },
    );
  }

  Widget buildTeacherWidget(Teacher e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListTile(
        leading: Container(
          width: 50,
          padding: const EdgeInsets.all(5),
          child: e.teacherPhotoUrl == null
              ? Image.asset(
                  "assets/images/avatar.png",
                  fit: BoxFit.contain,
                )
              : Image.network(
                  e.teacherPhotoUrl!,
                  fit: BoxFit.contain,
                ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            e.teacherName ?? "Select a Teacher",
            style: const TextStyle(
              fontSize: 14,
            ),
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Attendance Management"),
        actions: widget.adminProfile.isMegaAdmin
            ? null
            : <Widget>[
                PopupMenuButton<String>(
                  onSelected: handleNextScreenOptions,
                  itemBuilder: (BuildContext context) {
                    return {'Bulk Edit Attendance Time Slots'}.map((String choice) {
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
