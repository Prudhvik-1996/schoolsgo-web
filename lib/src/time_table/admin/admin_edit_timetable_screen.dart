import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

import 'admin_edit_section_wise_time_slots.dart';

class AdminEditTimeTable extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminEditTimeTable({Key? key, required this.adminProfile})
      : super(key: key);

  @override
  _AdminEditTimeTableState createState() => _AdminEditTimeTableState();
}

class _AdminEditTimeTableState extends State<AdminEditTimeTable>
    with TickerProviderStateMixin {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  late Map<Section, bool> _selectedSectionMap;
  Section? _sectionToBeEdited;
  int? _sectionIndex;

  List<TeacherDealingSection> _tdsList = [];

  List<SectionWiseTimeSlotBean> _sectionWiseTimeSlots = [];

  bool _isSectionPickerOpen = false;

  bool _previewMode = false;

  late Map<Section, GlobalKey<State<StatefulWidget>>> _printKeys;

  late PageController pageController;

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
      _selectedSectionMap = {};
      _sectionToBeEdited = null;
      _isSectionPickerOpen = false;
      _previewMode = false;
      _printKeys = {};
      _sectionIndex = 0;
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
      for (Section eachSection in _sectionsList) {
        setState(() {
          _selectedSectionMap[eachSection] = true;
          _printKeys[eachSection] = GlobalKey();
          pageController = PageController(
            initialPage: _sectionIndex!,
            keepPage: true,
            viewportFraction: 1,
          );
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

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildSectionCheckBox(Section section) {
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
            onTap: () {
              HapticFeedback.vibrate();
              if (_isLoading) return;
              setState(() {
                _sectionIndex = _sectionsList.indexOf(section);
                _isSectionPickerOpen = false;
                pageController.animateToPage(
                  _sectionIndex!,
                  duration: const Duration(seconds: 1),
                  curve: Curves.linear,
                );
              });
            },
            child: Center(
              child: Text(
                section.sectionName!,
                style: const TextStyle(
                  color: Colors.black,
                ),
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
      return;
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
                        ClayText(
                          week,
                          // emboss: true,
                          size: 28,
                          textColor: Colors.lightBlue[200],
                          parentColor: Colors.blue,
                          depth: 40,
                          color: Colors.black,
                          spread: 1.2,
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
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
                            padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Text(
                                //   "${e.week} - ${e.startTime} - ${e.endTime} - ${e.managerName}",
                                // ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    convert24To12HourFormat(e.startTime!),
                                    // "${convert24To12HourFormat(e.startTime)}\n${convert24To12HourFormat(e.endTime)}",
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
                                    child: _sectionToBeEdited != section
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
      height: 600,
      child: PageView.builder(
        itemCount: _sectionsList.length,
        controller: pageController,
        dragStartBehavior: DragStartBehavior.down,
        allowImplicitScrolling: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int itemIndex) {
          Section eachSection = _sectionsList[itemIndex];
          return SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: Colors.blue[200],
                    borderRadius: 10,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClayText(
                            "${eachSection.sectionName}",
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                            textColor: Colors.black,
                            emboss: true,
                            spread: 1,
                          ),
                          InkWell(
                            onTap: () async {
                              HapticFeedback.vibrate();
                              if (_sectionToBeEdited != null &&
                                  _sectionToBeEdited == eachSection) {
                                if (_sectionWiseTimeSlots
                                    .where((e) => e.isEdited ?? false)
                                    .isEmpty) {
                                  setState(() {
                                    _sectionToBeEdited = null;
                                  });
                                  return;
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Time Table"),
                                      content: Text(
                                          "Proceed to Save Changes for Section,\n${eachSection.sectionName}"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Proceed"),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            await _saveChanges();
                                            setState(() {
                                              _sectionToBeEdited = null;
                                            });
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (_sectionToBeEdited != null &&
                                  _sectionToBeEdited != eachSection) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Please save changes for Section ${_sectionToBeEdited!.sectionName} to proceed editing ${eachSection.sectionName}"),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _sectionToBeEdited = eachSection;
                                });
                              }
                            },
                            child: ClayContainer(
                              color: Colors.blue[200],
                              height: 50,
                              width: 50,
                              borderRadius: 50,
                              surfaceColor: Colors.blue[200],
                              emboss: _sectionToBeEdited != null &&
                                  _sectionToBeEdited == eachSection,
                              child: Icon(
                                _sectionToBeEdited != null &&
                                        _sectionToBeEdited == eachSection
                                    ? Icons.check
                                    : Icons.edit,
                                color: _sectionToBeEdited != null &&
                                        _sectionToBeEdited == eachSection
                                    ? Colors.black38
                                    : Colors.black38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      children: WEEKS
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
          );
        },
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
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: ClayText(
                "Go to section",
                textColor: Colors.black54,
                spread: 2,
                size: 18,
                emboss: true,
              ),
            ),
          ),
          GridView.count(
              childAspectRatio: 2.25,
              crossAxisCount: MediaQuery.of(context).size.width ~/ 125,
              shrinkWrap: true,
              children:
                  _sectionsList.map((e) => buildSectionCheckBox(e)).toList()
              // + _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
              ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return InkWell(
      onTap: () {
        HapticFeedback.vibrate();
        if (_isLoading) return;
        setState(() {
          _isSectionPickerOpen = !_isSectionPickerOpen;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: ClayText(
          "Go to section",
          textColor: Colors.black54,
          spread: 2,
          size: 24,
          emboss: true,
        ),
      ),
    );
  }

  Widget _sectionPicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ClayButton(
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
    );
  }

  void handleNextScreenOptions(String value) {
    switch (value) {
      case 'Edit Attendance Time Slots':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AdminEditSectionWiseTimeSlots(
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
        title: const Text("Time Table"),
        actions: <Widget>[
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
                      child: !_selectedSectionMap.values.toSet().contains(true)
                          ? Container()
                          : buildSectionWiseTimeSlotsForAllSelectedSections(),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        child:
            Icon(_previewMode ? Icons.close : Icons.preview_outlined, size: 28),
        onPressed: () {
          setState(() {
            _previewMode = !_previewMode;
          });
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
}
