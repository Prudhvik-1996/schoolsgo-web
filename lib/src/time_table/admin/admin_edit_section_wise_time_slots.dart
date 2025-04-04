import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/app_expansion_tile.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

import 'admin_bulk_edit_section_wise_time_slots.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AdminEditSectionWiseTimeSlots extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminEditSectionWiseTimeSlots({Key? key, required this.adminProfile}) : super(key: key);

  @override
  _AdminEditSectionWiseTimeSlotsState createState() => _AdminEditSectionWiseTimeSlotsState();
}

class _AdminEditSectionWiseTimeSlotsState extends State<AdminEditSectionWiseTimeSlots> {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  late bool _isSectionFilterSelected;

  List<SectionWiseTimeSlotBean> _sectionWiseTimeSlots = [];

  late SectionWiseTimeSlotBean _newSectionWiseTimeSlotBean;

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
      _sectionWiseTimeSlots = [];
      _newSectionWiseTimeSlotBean = SectionWiseTimeSlotBean();
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

    GetSectionWiseTimeSlotsResponse getSectionWiseTimeSlotsResponse = await getSectionWiseTimeSlots(GetSectionWiseTimeSlotsRequest(
      schoolId: widget.adminProfile.schoolId,
      status: "active",
    ));
    if (getSectionWiseTimeSlotsResponse.httpStatus == "OK" && getSectionWiseTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _sectionWiseTimeSlots = getSectionWiseTimeSlotsResponse.sectionWiseTimeSlotBeanList!;
      });
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(
      GetTeacherDealingSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
        status: "active",
      ),
    );
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {});
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            if (_selectedSection == section) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
            _newSectionWiseTimeSlotBean = SectionWiseTimeSlotBean(
              sectionName: _selectedSection!.sectionName,
              sectionId: _selectedSection!.sectionId,
              agent: widget.adminProfile.userId,
            );
            _isSectionFilterSelected = !_isSectionFilterSelected;
          });
        },
        child: ClayButton(
          depth: 40,
          color: _selectedSection == section ? Colors.blue[300] : clayContainerColor(context),
          spread: _selectedSection == section ? 0 : 2,
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
              _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName}",
            ),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.025),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.all(7),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.25,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
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
    if (_sectionWiseTimeSlots.where((e) => e.isEdited ?? false).isEmpty) {
      setState(() {
        _isEditMode = false;
      });
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Section Time Slots'),
          content: const Text("Are You Sure Want To Proceed ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateSectionWiseTimeSlotsResponse createOrUpdateSectionWiseTimeSlotsResponse = await createOrUpdateSectionWiseTimeSlots(
                  CreateOrUpdateSectionWiseTimeSlotsRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId,
                    sectionWiseTimeSlotBeans: _sectionWiseTimeSlots.where((e) => e.isEdited ?? false).toList(),
                  ),
                );
                if (createOrUpdateSectionWiseTimeSlotsResponse.httpStatus != 'OK' ||
                    createOrUpdateSectionWiseTimeSlotsResponse.responseStatus != "success") {
                  HapticFeedback.vibrate();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong..\nPlease try later.."),
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }
                _loadData();
                setState(() {
                  _isEditMode = false;
                  _isLoading = false;
                });
              },
            ),
            TextButton(
              child: const Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = false;
                });
                _loadData();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickStartTime(BuildContext context, SectionWiseTimeSlotBean e) async {
    TimeOfDay? _startTimePicker = await showTimePicker(
      context: context,
      initialTime: e.startTime == null ? const TimeOfDay(hour: 0, minute: 0) : formatHHMMSSToTimeOfDay(e.startTime!),
    );

    if (_startTimePicker == null || e.startTime == timeOfDayToHHMMSS(_startTimePicker)) return;
    setState(() {
      e.startTime = timeOfDayToHHMMSS(_startTimePicker);
      e.isEdited = true;
      e.agent = widget.adminProfile.userId;
    });
  }

  Widget _buildStartTimePicker(SectionWiseTimeSlotBean e) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayContainer(
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
              if (_isEditMode) await _pickStartTime(context, e);
            },
            child: Center(
              child: Text(
                e.startTime != null ? formatHHMMSStoHHMMA(e.startTime!) : "-",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickEndTime(BuildContext context, SectionWiseTimeSlotBean e) async {
    TimeOfDay? _endTimePicker = await showTimePicker(
      context: context,
      initialTime: e.endTime == null ? const TimeOfDay(hour: 0, minute: 0) : formatHHMMSSToTimeOfDay(e.endTime!),
    );

    if (_endTimePicker == null || e.endTime == timeOfDayToHHMMSS(_endTimePicker)) return;
    setState(() {
      e.endTime = timeOfDayToHHMMSS(_endTimePicker);
      e.isEdited = true;
      e.agent = widget.adminProfile.userId;
    });
  }

  Widget _buildEndTimePicker(SectionWiseTimeSlotBean e) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ClayContainer(
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
              if (_isEditMode) await _pickEndTime(context, e);
            },
            child: Center(
              child: Text(
                e.endTime != null ? formatHHMMSStoHHMMA(e.endTime!) : "-",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAttendanceTimeSlotsForEachSection(Section section) {
    List<SectionWiseTimeSlotBean> _timeslotsForThisSection =
        _sectionWiseTimeSlots.where((e) => e.sectionId == section.sectionId).toList() + (_isEditMode ? [_newSectionWiseTimeSlotBean] : []);
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
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
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
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
                            color: _isEditMode ? Colors.green[200] : Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ] +
                [for (var i = 0; i < _timeslotsForThisSection.length; i += 1) i].map(
                  (index) {
                    var e = _timeslotsForThisSection[index];
                    // if (_timeslotsForThisSection[index].sectionId !=
                    //     _selectedSection.sectionId) return Container();
                    return Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: GestureDetector(
                        onLongPress: () {
                          HapticFeedback.vibrate();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${(e.teacherName ?? "N/A").capitalize()} - ${(e.subjectName ?? "N/A").capitalize()}",
                              ),
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
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: _isEditMode && e.sectionWiseTimeSlotId == null
                                          ? DropdownButton<String>(
                                              isExpanded: true,
                                              hint: const Text("Week"),
                                              onChanged: (String? newWeek) {
                                                setState(() {
                                                  e.weekId = WEEKS.indexOf(newWeek!) + 1;
                                                  e.week = newWeek;
                                                  e.isEdited = true;
                                                  e.agent = widget.adminProfile.userId;
                                                });
                                              },
                                              value: e.week,
                                              items: WEEKS
                                                  .map(
                                                    (eachWeek) => DropdownMenuItem(
                                                      value: eachWeek,
                                                      child: AutoSizeText(
                                                        eachWeek,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            )
                                          : Text(
                                              e.week ?? "-",
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(flex: 2, child: _buildStartTimePicker(e)),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: _buildEndTimePicker(e),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ] +
                                  (_isEditMode
                                      ? [
                                          e.status == 'active'
                                              ? Expanded(
                                                  flex: 1,
                                                  child: InkWell(
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        e.status = 'inactive';
                                                        e.isEdited = true;
                                                      });
                                                    },
                                                  ),
                                                )
                                              : Expanded(
                                                  flex: 1,
                                                  child: InkWell(
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.green,
                                                    ),
                                                    onTap: () {
                                                      if (e.sectionWiseTimeSlotId == null) {
                                                        if (e.weekId == null || e.startTime == null || e.endTime == null) {
                                                          HapticFeedback.vibrate();
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text("Select Week, StartTime and EndTime.."),
                                                            ),
                                                          );
                                                          return;
                                                        }
                                                      }
                                                      setState(() {
                                                        e.status = 'active';
                                                        e.isEdited = true;
                                                      });
                                                      if (e.sectionWiseTimeSlotId == null) {
                                                        setState(() {
                                                          _sectionWiseTimeSlots.add(e);
                                                          _newSectionWiseTimeSlotBean = SectionWiseTimeSlotBean(
                                                            sectionName: _selectedSection!.sectionName,
                                                            sectionId: _selectedSection!.sectionId,
                                                            agent: widget.adminProfile.userId,
                                                          );
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                        ]
                                      : []),
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
    return Column(
      children: [_selectedSection]
          .map(
            (e) => buildAttendanceTimeSlotsForEachSection(e!),
          )
          .toList(),
    );
  }

  void handleNextScreenOptions(String value) {
    switch (value) {
      case 'Bulk Edit Section Wise Time Slots':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AdminBulkEditSectionWiseTimeSlots(
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
        title: const Text("Edit Section Wise Time Slots"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleNextScreenOptions,
            itemBuilder: (BuildContext context) {
              return {'Bulk Edit Section Wise Time Slots'}.map((String choice) {
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
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                _buildSectionsFilter(),
                _selectedSection == null ? Container() : buildAttendanceTimeSlotsForAllSelectedSections(),
              ],
            ),
    );
  }
}
