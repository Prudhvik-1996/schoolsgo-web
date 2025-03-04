import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/time_slot.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';

class AdminBulkEditSectionWiseTimeSlots extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminBulkEditSectionWiseTimeSlots({Key? key, required this.adminProfile}) : super(key: key);

  @override
  _AdminBulkEditSectionWiseTimeSlotsState createState() => _AdminBulkEditSectionWiseTimeSlotsState();
}

class _AdminBulkEditSectionWiseTimeSlotsState extends State<AdminBulkEditSectionWiseTimeSlots> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Section> _sectionsList = [];

  Map<int, bool> _selectedSectionsMap = {};
  final Map<String, bool> _selectedWeeksMap = {};

  List<TimeSlot> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _sectionsList = [];
      _selectedSectionsMap = {};
      for (var eachWeek in WEEKS) {
        _selectedWeeksMap[eachWeek] = false;
      }
      _timeSlots = [TimeSlot(startTime: null, endTime: null)];
    });

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
        for (var e in _sectionsList) {
          _selectedSectionsMap[e.sectionId!] = false;
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget getWarningCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 40,
        color: const Color(0xFFFA795D),
        spread: 1,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ClayText(
            "The changes you make here will replace all the time slots for the marked sections and weeks from now i.e., ${getCurrentDateString()}",
            spread: 1,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            if (_selectedSectionsMap[section.sectionId]!) {
              _selectedSectionsMap[section.sectionId!] = false;
            } else {
              _selectedSectionsMap[section.sectionId!] = true;
            }
          });
        },
        child: ClayContainer(
          depth: 40,
          color: _selectedSectionsMap[section.sectionId]! ? Colors.blue[200] : clayContainerColor(context),
          spread: _selectedSectionsMap[section.sectionId]! ? 0 : 2,
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
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 25,
              ),
              Center(
                child: ClayText(
                  "Select sections",
                  textColor: Colors.black54,
                  spread: 2,
                  size: 24,
                  emboss: true,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.25,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
                  shrinkWrap: true,
                  children: _sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
                ),
              ),
            ],
            shrinkWrap: true,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCheckBox(String week) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        color: _selectedWeeksMap[week]! ? Colors.blue[200] : clayContainerColor(context),
        spread: _selectedWeeksMap[week]! ? 0 : 2,
        borderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          // padding: EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                if (_selectedWeeksMap[week]!) {
                  _selectedWeeksMap[week] = false;
                } else {
                  _selectedWeeksMap[week] = true;
                }
              });
            },
            child: Center(
              child: Text(
                week,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeksFilter() {
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
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 25,
              ),
              Center(
                child: ClayText(
                  "Select day",
                  textColor: clayContainerTextColor(context),
                  spread: 2,
                  size: 24,
                  emboss: true,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.75,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
                  shrinkWrap: true,
                  children: WEEKS.map((e) => _buildWeekCheckBox(e)).toList(),
                ),
              ),
            ],
            shrinkWrap: true,
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartTime(BuildContext context, int index) async {
    TimeOfDay? _startTimePicker = await showTimePicker(
      context: context,
      initialTime: index - 1 < 0 || _timeSlots[index - 1].endTime == null
          ? const TimeOfDay(hour: 0, minute: 0)
          : formatHHMMSSToTimeOfDay(_timeSlots[index - 1].endTime!),
    );

    if (_startTimePicker == null) return;
    setState(() {
      if (_timeSlots.tryGet(index) == null) {
        _timeSlots.add(TimeSlot(startTime: timeOfDayToHHMMSS(_startTimePicker), endTime: null));
      } else {
        _timeSlots[index].startTime = timeOfDayToHHMMSS(_startTimePicker);
      }
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
              await _pickStartTime(context, index);
            },
            child: Center(
              child: Text(
                _timeSlots.tryGet(index) != null && _timeSlots.tryGet(index).startTime != null
                    ? formatHHMMSStoHHMMA(_timeSlots.tryGet(index).startTime)
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
      initialTime: index + 1 >= _timeSlots.length || _timeSlots[index + 1].startTime == null
          ? const TimeOfDay(hour: 0, minute: 0)
          : formatHHMMSSToTimeOfDay(_timeSlots[index + 1].startTime!),
    );

    if (_endTimePicker == null) return;
    setState(() {
      if (_timeSlots.tryGet(index) == null) {
        _timeSlots.add(TimeSlot(startTime: null, endTime: timeOfDayToHHMMSS(_endTimePicker)));
      } else {
        _timeSlots[index].endTime = timeOfDayToHHMMSS(_endTimePicker);
      }
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
              await _pickEndTime(context, index);
            },
            child: Center(
              child: Text(
                _timeSlots.tryGet(index) != null && _timeSlots.tryGet(index).endTime != null
                    ? formatHHMMSStoHHMMA(_timeSlots.tryGet(index).endTime)
                    : "-",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTimePickers() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        child: ClayText(
                          "Time Slots",
                          textColor: clayContainerTextColor(context),
                          spread: 2,
                          size: 24,
                          emboss: true,
                        ),
                      ),
                    ],
                  ),
                ] +
                [for (var i = 0; i < _timeSlots.length; i += 1) i]
                    .map(
                      (index) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildStartTimePicker(index)),
                          Expanded(child: _buildEndTimePicker(index)),
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.vibrate();
                                if (index == _timeSlots.length - 1) {
                                  if (_timeSlots.tryGet(index).startTime == null || _timeSlots.tryGet(index).endTime == null) {
                                    return;
                                  }
                                  setState(() {
                                    _timeSlots.add(TimeSlot(startTime: null, endTime: null));
                                  });
                                } else {
                                  if (_timeSlots.tryGet(index).startTime == null || _timeSlots.tryGet(index).endTime == null) {
                                    return;
                                  }
                                  setState(() {
                                    _timeSlots.removeAt(index);
                                  });
                                }
                              },
                              child: ClayContainer(
                                color: clayContainerColor(context),
                                height: 35,
                                width: 35,
                                borderRadius: 35,
                                spread: 4,
                                child: index == _timeSlots.length - 1
                                    ? const Icon(
                                        Icons.add,
                                        color: Colors.green,
                                      )
                                    : const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Time Table Management'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
                child: const Text("YES"),
                onPressed: () async {
                  HapticFeedback.vibrate();
                  Navigator.of(context).pop();

                  if (!(_selectedSectionsMap.values.toSet().contains(true))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select sections you want to edit!"),
                      ),
                    );
                    return;
                  }

                  if (!(_selectedWeeksMap.values.toSet().contains(true))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select weeks you want to edit!"),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });
                  BulkEditSectionWiseTimeSlotsRequest bulkEditSectionWiseTimeSlotsRequest = BulkEditSectionWiseTimeSlotsRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId,
                    sectionIds: _selectedSectionsMap.keys.where((eachSectionId) => _selectedSectionsMap[eachSectionId]!).toList(),
                    weekIds: _selectedWeeksMap.keys.where((eachWeekId) => _selectedWeeksMap[eachWeekId]!).map((e) => WEEKS.indexOf(e) + 1).toList(),
                    timeSlots: _timeSlots.where((eachTimeSlot) => eachTimeSlot.startTime != null && eachTimeSlot.endTime != null).toList(),
                  );
                  BulkEditSectionWiseTimeSlotsResponse bulkEditSectionWiseTimeSlotsResponse =
                      await bulkEditSectionWiseTimeSlots(bulkEditSectionWiseTimeSlotsRequest);
                  if (bulkEditSectionWiseTimeSlotsResponse.httpStatus == "OK" && bulkEditSectionWiseTimeSlotsResponse.responseStatus == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Success!"),
                      ),
                    );
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong!"),
                      ),
                    );
                  }
                  setState(() {
                    _isLoading = true;
                  });
                }),
            TextButton(
              child: const Text("NO"),
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

  Widget _buildSubmitButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(75, 20, 75, 20),
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          _saveChanges();
        },
        child: ClayContainer(
          depth: 40,
          color: const Color(0xFFC0EE74),
          spread: 2,
          borderRadius: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: Center(
              child: ClayText(
                "Submit",
                size: 21,
                textColor: const Color(0xFF54524E),
                emboss: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Section Wise Time Slots"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                getWarningCard(),
                _buildSectionsFilter(),
                _buildWeeksFilter(),
                // SizedBox(
                //   height: 500,
                // ),
                _getTimePickers(),
                _buildSubmitButton(),
                getWarningCard(),
              ],
            ),
    );
  }
}
