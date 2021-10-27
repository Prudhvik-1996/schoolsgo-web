import 'package:clay_containers/clay_containers.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/time_slot.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminTimeTableRandomizer extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminTimeTableRandomizer({Key? key, required this.adminProfile})
      : super(key: key);

  @override
  _AdminTimeTableRandomizerState createState() =>
      _AdminTimeTableRandomizerState();
}

class _AdminTimeTableRandomizerState extends State<AdminTimeTableRandomizer>
    with TickerProviderStateMixin {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  Map<Section, bool> _selectedSectionMap = {};

  List<TeacherDealingSection> _tdsList = [];

  List<SectionWiseTimeSlotBean> _sectionWiseTimeSlots = [];

  List<TdsDailyLimitBeans> _tdsDailyLimit = [];
  List<TdsWeeklyLimitBeans> _tdsWeeklyLimit = [];

  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  bool _isSectionPickerOpen = false;
  Map<Section, bool> _isMoreOptionsSelectedMap = {};

  bool _isRandomising = false;
  bool _previewMode = false;

  Map<Section, GlobalKey<State<StatefulWidget>>> _printKeys = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _sectionsList = [];
      _tdsList = [];
      _sectionWiseTimeSlots = [];
      _tdsDailyLimit = [];
      _tdsWeeklyLimit = [];
      _selectedSectionMap = {};
      _isMoreOptionsSelectedMap = {};
      _isSectionPickerOpen = false;
      _isRandomising = false;
      _previewMode = false;
      _printKeys = {};
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
      for (var eachSection in _sectionsList) {
        setState(() {
          _selectedSectionMap[eachSection] = false;
          _isMoreOptionsSelectedMap[eachSection] = false;
          _printKeys[eachSection] = GlobalKey();
        });
      }
    }

    GetSectionWiseTimeSlotsResponse getSectionWiseTimeSlotsResponse =
        await getSectionWiseTimeSlots(GetSectionWiseTimeSlotsRequest(
      schoolId: widget.adminProfile.schoolId,
      status: "active",
    ));
    if (getSectionWiseTimeSlotsResponse.httpStatus == "OK" &&
        getSectionWiseTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _sectionWiseTimeSlots =
            getSectionWiseTimeSlotsResponse.sectionWiseTimeSlotBeanList!;
      });
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse =
        await getTeacherDealingSections(
      GetTeacherDealingSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" &&
        getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }

    for (var eachSection in _sectionsList) {
      setState(() {
        _tdsDailyLimit.addAll(_tdsList
            .where((e) => e.sectionId == eachSection.sectionId)
            .map((eachTds) => _sectionWiseTimeSlots
                .map((eachTimeSlot) => eachTimeSlot.weekId)
                .toSet()
                .map((eachWeekId) => TdsDailyLimitBeans(
                    weekId: eachWeekId, tds: eachTds, dailyLimit: 1)))
            .toList()
            .expand((i) => i)
            .toList());
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
        color: _selectedSectionMap[section]!
            ? Colors.blue[200]
            : clayContainerColor(context),
        spread: _selectedSectionMap[section]! ? 0 : 2,
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
              if (_isLoading || _isRandomising) return;
              setState(() {
                if (_selectedSectionMap[section]!) {
                  _selectedSectionMap[section] = false;
                } else {
                  _selectedSectionMap[section] = true;
                }
                _isSectionPickerOpen = false;
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

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    if (_sectionWiseTimeSlots.where((e) => e.isEdited ?? false).isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    CreateOrUpdateSectionWiseTimeSlotsResponse
        createOrUpdateSectionWiseTimeSlotsResponse =
        await createOrUpdateSectionWiseTimeSlots(
      CreateOrUpdateSectionWiseTimeSlotsRequest(
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        sectionWiseTimeSlotBeans:
            _sectionWiseTimeSlots.where((e) => e.isEdited ?? false).toList(),
      ),
    );
    if (createOrUpdateSectionWiseTimeSlotsResponse.httpStatus != 'OK' ||
        createOrUpdateSectionWiseTimeSlotsResponse.responseStatus !=
            "success") {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong..\nPlease try later.."),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });

    _loadData();
  }

  Widget buildSectionWiseTimeSlotsForEachSection(Section section, String week) {
    List<SectionWiseTimeSlotBean> sectionWiseTimeSlotsForWeek =
        _sectionWiseTimeSlots
            .where((e) => section.sectionId == e.sectionId && e.week == week)
            .toList();

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
            children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          week,
                        ),
                      ],
                    ),
                  ),
                ] +
                sectionWiseTimeSlotsForWeek
                    .map(
                      (e) => Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: ClayContainer(
                          depth: 20,
                          // height: 100,
                          color: clayContainerColor(context),
                          borderRadius: 10,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.vibrate();
                                    if (e.isPinned ?? false) {
                                      setState(() {
                                        e.isPinned = false;
                                      });
                                    } else {
                                      setState(() {
                                        e.isPinned = true;
                                      });
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    child: RotationTransition(
                                      turns: const AlwaysStoppedAnimation(
                                          45 / 360),
                                      child: Icon(
                                        Icons.push_pin,
                                        color: e.isPinned ?? false
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(2, 20, 0, 20),
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 10, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //   "${e.week} - ${e.startTime} - ${e.endTime} - ${e.managerName}",
                                      // ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          convert24To12HourFormat(e.startTime!),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          convert24To12HourFormat(e.endTime!),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: e.isPinned ?? false
                                              ? Text(
                                                  (e.teacherName ?? "-")
                                                          .capitalize() +
                                                      "\n" +
                                                      (e.subjectName ?? "-")
                                                          .capitalize(),
                                                )
                                              : buildDropdownButtonToPickTDS(
                                                  section, e),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

  DropdownButton<TeacherDealingSection> buildDropdownButtonToPickTDS(
      Section section, SectionWiseTimeSlotBean timeSlotToBeEdited) {
    return DropdownButton(
      underline: Container(),
      isExpanded: true,
      items:
          (_tdsList.where((e1) => e1.sectionId == section.sectionId).toList() +
                  [TeacherDealingSection()])
              .map(
                (e1) => DropdownMenuItem<TeacherDealingSection>(
                  value: e1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(5),
                      color: e1.tdsId == timeSlotToBeEdited.tdsId
                          ? Colors.blue[100]
                          : Colors.grey[300],
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: RichText(
                      text: TextSpan(
                        text: (e1.teacherName ?? "-").capitalize() + "\n",
                        children: [
                          TextSpan(
                            text: (e1.subjectName ?? "-").capitalize(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: (TeacherDealingSection? selectedTds) {
        if (selectedTds == TeacherDealingSection()) {
          setState(() {
            timeSlotToBeEdited.teacherId = null;
            timeSlotToBeEdited.subjectId = null;
            timeSlotToBeEdited.teacherName = null;
            timeSlotToBeEdited.subjectName = null;
            timeSlotToBeEdited.agent = widget.adminProfile.agent;
            timeSlotToBeEdited.tdsId = null;
            timeSlotToBeEdited.isEdited = true;
          });
        } else {
          String? errorMessage;
          _sectionWiseTimeSlots
              .where((e) => e.sectionId != section.sectionId)
              .where((e) => e.teacherId == selectedTds!.teacherId)
              .forEach((eachTimeSlot) {
            int eachTimeSlotStartTime = getSecondsEquivalentOfTimeFromWHHMMSS(
                eachTimeSlot.startTime!, eachTimeSlot.weekId!);
            int eachTimeSlotEndTime = getSecondsEquivalentOfTimeFromWHHMMSS(
                eachTimeSlot.endTime!, eachTimeSlot.weekId!);
            int startTimeForTimeSlotToBeEdited =
                getSecondsEquivalentOfTimeFromWHHMMSS(
                    timeSlotToBeEdited.startTime!, timeSlotToBeEdited.weekId!);
            int endTimeForTimeSlotToBeEdited =
                getSecondsEquivalentOfTimeFromWHHMMSS(
                    timeSlotToBeEdited.endTime!, timeSlotToBeEdited.weekId!);

            if ((startTimeForTimeSlotToBeEdited >= eachTimeSlotStartTime &&
                    startTimeForTimeSlotToBeEdited <= eachTimeSlotEndTime) ||
                (endTimeForTimeSlotToBeEdited >= eachTimeSlotStartTime &&
                    endTimeForTimeSlotToBeEdited <= eachTimeSlotEndTime)) {
              errorMessage =
                  "Teacher ${selectedTds!.teacherName}, is occupied with Section ${eachTimeSlot.sectionName} and Subject ${eachTimeSlot.subjectName}";
            }
          });

          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage!),
              ),
            );
            return;
          }

          setState(() {
            timeSlotToBeEdited.sectionId = selectedTds!.sectionId;
            timeSlotToBeEdited.teacherId = selectedTds.teacherId;
            timeSlotToBeEdited.subjectId = selectedTds.subjectId;
            timeSlotToBeEdited.sectionName = selectedTds.sectionName;
            timeSlotToBeEdited.teacherName = selectedTds.teacherName;
            timeSlotToBeEdited.subjectName = selectedTds.subjectName;
            timeSlotToBeEdited.agent = widget.adminProfile.agent;
            timeSlotToBeEdited.tdsId = selectedTds.tdsId;
            timeSlotToBeEdited.isEdited = true;
          });
        }
      },
      value: timeSlotToBeEdited.tdsId == null
          ? null
          : _tdsList.where((e1) => e1.tdsId == timeSlotToBeEdited.tdsId).first,
    );
  }

  Widget buildSectionWiseTimeSlotsForAllSelectedSections() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: PageView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: _selectedSectionMap.keys
            .where((eachSection) => _selectedSectionMap[eachSection]!)
            .map(
              (eachSection) => SizedBox(
                width: MediaQuery.of(context).size.width - 10,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: ClayContainer(
                        depth: 40,
                        surfaceColor: Colors.blue[200],
                        borderRadius: 10,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "${eachSection.sectionName}",
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SafeArea(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          children: [_moreOptions(eachSection)] +
                              WEEKS
                                  .map(
                                    (eachWeek) =>
                                        buildSectionWiseTimeSlotsForEachSection(
                                            eachSection, eachWeek),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Container _tableForWeekDayTdsLimitMap(Section section) {
    List<int> weeks = _sectionWiseTimeSlots
        .where((e) =>
            e.sectionWiseTimeSlotId != null && e.sectionId == section.sectionId)
        .map((e) => e.weekId!)
        .toSet()
        .toList();
    weeks.sort();
    return Container(
      margin: const EdgeInsets.all(5),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
              Row(
                children: [
                      const Expanded(
                        flex: 2,
                        child: Text(""),
                      ),
                    ] +
                    weeks
                        .map((e) => Expanded(
                              flex: 1,
                              child: Text(
                                WEEKS[e - 1][0],
                                textAlign: TextAlign.center,
                              ),
                            ))
                        .toList(),
              ),
            ] +
            _tdsList
                .where((e) => e.sectionId == section.sectionId)
                .map(
                  (eachTds) => Row(
                    children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                                "${eachTds.teacherName!.capitalize()}\n${eachTds.subjectName!.capitalize()}"),
                          )
                        ] +
                        weeks.map((eachWeekId) {
                          TdsDailyLimitBeans? x = _tdsDailyLimit
                                  .where((eachLimit) =>
                                      eachWeekId == eachLimit.weekId &&
                                      eachLimit.tds!.tdsId == eachTds.tdsId)
                                  .toList()
                                  .isEmpty
                              ? null
                              : _tdsDailyLimit
                                  .where((eachLimit) =>
                                      eachWeekId == eachLimit.weekId &&
                                      eachLimit.tds!.tdsId == eachTds.tdsId)
                                  .toList()
                                  .first;
                          return Expanded(
                            flex: 1,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: NumberPicker(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                ),
                                textStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 8,
                                ),
                                selectedTextStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                value: x == null ? 0 : x.dailyLimit!,
                                minValue: 0,
                                maxValue: _sectionWiseTimeSlots
                                    .where((eachTimeSlot) =>
                                        eachTimeSlot.sectionId ==
                                            section.sectionId &&
                                        eachTimeSlot.weekId == eachWeekId)
                                    .length,
                                onChanged: (dynamic num) {
                                  if (x == null) return;
                                  setState(() {
                                    x.dailyLimit = num;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _moreOptionsExpanded(Section section) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: ClayButton(
        depth: 40,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            // shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            children: [
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text("More Options"),
                    Icon(
                      Icons.arrow_drop_up,
                      color: Colors.grey,
                    ),
                  ],
                ),
                onTap: () {
                  HapticFeedback.vibrate();
                  setState(() {
                    _isMoreOptionsSelectedMap[section] =
                        !_isMoreOptionsSelectedMap[section]!;
                  });
                },
              ),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const Text("Set Limit per day:"),
                  _tableForWeekDayTdsLimitMap(section),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moreOptionsCollapsed(Section section) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text("More Options"),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _isMoreOptionsSelectedMap[section] =
                    !_isMoreOptionsSelectedMap[section]!;
              });
            },
          ),
        ),
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
              HapticFeedback.vibrate();
              if (_isLoading || _isRandomising) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                !_selectedSectionMap.values.toSet().contains(true)
                    ? "Select a section"
                    : "Sections:",
              ),
            ),
          ),
          GridView.count(
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
            shrinkWrap: true,
            children:
                _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return InkWell(
      onTap: () {
        HapticFeedback.vibrate();
        if (_isLoading || _isRandomising) return;
        setState(() {
          _isSectionPickerOpen = !_isSectionPickerOpen;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          !_selectedSectionMap.values.toSet().contains(true)
              ? "Select a section"
              : "Sections:\n${_selectedSectionMap.keys.where((eachSection) => _selectedSectionMap[eachSection]!).map((e) => e.sectionName).toList().join(", ")}",
        ),
      ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: ClayContainer(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: _isSectionPickerOpen
              ? _selectSectionExpanded()
              : _selectSectionCollapsed(),
          // height: 40,
          // color: Colors.red,
        ),
      ),
    );
  }

  Widget _moreOptions(Section section) {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(
          milliseconds: _isMoreOptionsSelectedMap[section]! ? 750 : 500),
      child: _selectedSectionMap.values.toSet().contains(true)
          ? _isMoreOptionsSelectedMap[section]!
              ? _moreOptionsExpanded(section)
              : _moreOptionsCollapsed(section)
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table Generator"),
        actions: [
          InkWell(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Icon(
                _previewMode ? Icons.close : Icons.preview_outlined,
                size: 28,
              ),
            ),
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                _previewMode = !_previewMode;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : _previewMode
              ? _showPreviews()
              : CustomScrollView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _sectionPicker(),
                          // _moreOptions(),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      fillOverscroll: true,
                      child: _isRandomising
                          ? Image.asset(
                              "assets/images/rolling_dice.gif",
                              fit: BoxFit.contain,
                            )
                          : !_selectedSectionMap.values.toSet().contains(true)
                              ? Container()
                              : buildSectionWiseTimeSlotsForAllSelectedSections(),
                    ),
                  ],
                ),
      floatingActionButton: _previewMode
          ? FloatingActionButton(
              child: const Icon(Icons.save, size: 28),
              onPressed: () async {
                await _saveChanges();
              },
            )
          : FloatingActionButton(
              child: const Icon(Icons.shuffle, size: 28),
              onPressed: () async {
                await _randomize();
              },
            ),
    );
  }

  Widget _previewTimeTable(Section section) {
    List<String> allStrings = _tdsList
            .map((e) => (e.teacherName ?? "-").capitalize())
            .toSet()
            .toList() +
        _tdsList
            .map((e) => (e.subjectName ?? "-").capitalize())
            .toSet()
            .toList();
    allStrings.sort((a, b) => a.length.compareTo(b.length));

    List<TimeSlot> timeSlots = _sectionWiseTimeSlots
        .where((eachTimeSlot) => eachTimeSlot.sectionId == section.sectionId)
        .map((e) =>
            TimeSlot(weekId: 0, startTime: (e.startTime), endTime: (e.endTime)))
        .toSet()
        .toList();
    double height = 25;
    double width =
        (MediaQuery.of(context).size.width - 21) / (timeSlots.length + 1);
    return RepaintBoundary(
      key: _printKeys[section],
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
            ),
            color: Colors.blue[200],
          ),
          // height: 1000,
          // width: 1000,
          child: Column(
              children: [
                    Row(
                      children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.5),
                              ),
                              height: height,
                              width: width,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(section.sectionName!),
                              ),
                            )
                          ] +
                          timeSlots
                              .map(
                                (e) => Container(
                                  height: height,
                                  width: width,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "${convert24To12HourFormat(e.startTime!)}\n${convert24To12HourFormat(e.endTime!)}" +
                                            " " * (allStrings.last.length - 12),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          // fontWeight: FontWeight.bold,
                                        ),
                                        // maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    )
                  ] +
                  WEEKS
                      .map(
                        (eachWeek) => Row(
                          children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                  ),
                                  height: height,
                                  width: width,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      eachWeek +
                                          " " * (allStrings.last.length - 5),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ] +
                              timeSlots.map((eachTimeSlot) {
                                String res =
                                    "N/A" + " " * (allStrings.last.length - 5);
                                var x = _sectionWiseTimeSlots.where((e) =>
                                    e.week == eachWeek &&
                                    e.startTime == eachTimeSlot.startTime &&
                                    e.endTime == eachTimeSlot.endTime &&
                                    e.sectionId == section.sectionId);
                                if (x.isNotEmpty) {
                                  if (x.first.tdsId == null) {
                                    res = "-";
                                  } else {
                                    res = (x.first.subjectName ?? "-")
                                            .capitalize() +
                                        " " *
                                            (allStrings.last.length -
                                                (x.first.subjectName ?? "-")
                                                    .capitalize()
                                                    .length) +
                                        "\n" +
                                        (x.first.teacherName ?? "-")
                                            .capitalize() +
                                        " " *
                                            (allStrings.last.length -
                                                (x.first.teacherName ?? "-")
                                                    .capitalize()
                                                    .length);
                                  }
                                }
                                return Container(
                                  height: height,
                                  width: width,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                    color: Colors.blue[100],
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      res,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      )
                      .toList()),
        ),
      ),
    );
  }

  Widget _showPreviews() {
    return InteractiveViewer(
      minScale: 0.25,
      maxScale: 10,
      panEnabled: true,
      alignPanAxis: false,
      child: ListView(
        // shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        children: _sectionsList
            .where((eachSection) => _selectedSectionMap[eachSection]!)
            .map((e) => _previewTimeTable(e))
            .toList(),
      ),
    );
  }

  Future<void> _randomize() async {
    setState(() {
      _isRandomising = true;
      for (var eachSection in _sectionsList) {
        _isMoreOptionsSelectedMap[eachSection] = false;
      }
    });
    if (_selectedSectionMap.values.toSet().length == 1 &&
        _selectedSectionMap.values.toSet().contains(false)) {
      setState(() {
        _isRandomising = false;
      });
      return;
    }
    RandomizeSectionWiseTimeSlotsRequest randomizeSectionWiseTimeSlotsRequest =
        RandomizeSectionWiseTimeSlotsRequest(
      tdsList: _tdsList,
      agent: widget.adminProfile.userId,
      randomisingTimeSlotList: _sectionWiseTimeSlots
          .where((e) =>
              _selectedSectionMap.keys
                  .where((eachSection) => _selectedSectionMap[eachSection]!)
                  .map((e) => e.sectionId)
                  .contains(e.sectionId) &&
              !(e.tdsId == null && e.isPinned != null && e.isPinned!))
          .map(
            (e) => RandomisingTimeSlot(
              endTime: e.endTime,
              startTime: e.startTime,
              tds: ((e.isPinned != null && e.isPinned!) &&
                      _tdsList.where((e1) => e1.tdsId == e.tdsId).isNotEmpty)
                  ? _tdsList.where((e1) => e1.tdsId == e.tdsId).first
                  : null,
              timeSlotId: e.sectionWiseTimeSlotId,
              week: e.week,
              weekId: e.weekId,
              sectionId: e.sectionId,
            ),
          )
          .toList(),
      tdsDailyLimitBeans: _tdsDailyLimit,
      tdsWeeklyLimitBeans: _tdsWeeklyLimit,
      sectionWiseTimeSlotBeanList: _sectionWiseTimeSlots,
    );

    RandomizeSectionWiseTimeSlotsResponse response =
        await randomizeSectionWiseTimeSlots(
            randomizeSectionWiseTimeSlotsRequest);

    if (response.httpStatus != 'OK' || response.responseStatus != "success") {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong..\nPlease try later.."),
        ),
      );
      setState(() {
        _isRandomising = false;
      });
      return;
    }

    for (var newSlot in response.sectionWiseTimeSlotBeanList!) {
      _sectionWiseTimeSlots
          .where((oldSlot) =>
              oldSlot.sectionWiseTimeSlotId == newSlot.sectionWiseTimeSlotId &&
              newSlot.tdsId != null)
          .forEach((oldSlot) {
        setState(() {
          oldSlot.tdsId = newSlot.tdsId;
          oldSlot.sectionId = newSlot.sectionId;
          oldSlot.sectionName = newSlot.sectionName;
          oldSlot.teacherId = newSlot.teacherId;
          oldSlot.teacherName = newSlot.teacherName;
          oldSlot.subjectId = newSlot.subjectId;
          oldSlot.subjectName = newSlot.subjectName;
          oldSlot.isEdited = true;
          oldSlot.agent = newSlot.agent;
        });
      });
    }

    setState(() {
      _isRandomising = false;
    });
  }
}
