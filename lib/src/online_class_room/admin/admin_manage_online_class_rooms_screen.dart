import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/online_class_room/model/online_class_room.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class AdminManageOnlineClassRoomsScreen extends StatefulWidget {
  const AdminManageOnlineClassRoomsScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/onlineclassroom";

  @override
  _AdminManageOnlineClassRoomsScreenState createState() => _AdminManageOnlineClassRoomsScreenState();
}

class _AdminManageOnlineClassRoomsScreenState extends State<AdminManageOnlineClassRoomsScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;

  List<Section> _sectionsList = [];
  bool _isSectionPickerOpen = false;
  int _sectionIndex = 0;

  List<OnlineClassRoom> _onlineClassRooms = [];
  late OnlineClassRoom _newCustomOcr;

  late PageController pageController;

  @override
  void initState() {
    _loadData();
    _newCustomOcr = OnlineClassRoom(
      agent: widget.adminProfile.userId,
      status: "active",
    );
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    pageController = PageController(
      initialPage: _sectionIndex,
      keepPage: true,
      viewportFraction: 1,
    );

    // Get all sections data
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    // Get all online class rooms
    GetOnlineClassRoomsResponse getOnlineClassRoomsResponse = await getOnlineClassRooms(GetOnlineClassRoomsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getOnlineClassRoomsResponse.httpStatus == "OK" && getOnlineClassRoomsResponse.responseStatus == "success") {
      setState(() {
        _onlineClassRooms = getOnlineClassRoomsResponse.onlineClassRooms!.map((e) => e!).toList();
        _onlineClassRooms.sort((a, b) => a.compareTo(b));
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateSectionOCRAsPerTTFlag(Section section, bool ocrAsPerTt) async {
    setState(() {
      _isLoading = true;
    });
    UpdateOcrAsPerTtResponse updateOcrAsPerTtResponse = await updateOcrAsPerTtRooms(
      UpdateOcrAsPerTtRequest(
        schoolId: widget.adminProfile.schoolId,
        sectionId: section.sectionId,
        agent: widget.adminProfile.userId,
        ocrAsPerTt: ocrAsPerTt,
      ),
    );

    if (updateOcrAsPerTtResponse.httpStatus != "OK" || updateOcrAsPerTtResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong.. Please try again later!"),
        ),
      );
    } else {
      _loadData();
      pageController.animateToPage(
        _sectionIndex,
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
      );
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
          if (_isLoading) return;
          setState(() {
            _sectionIndex = _sectionsList.indexOf(section);
            pageController.animateToPage(
              _sectionIndex,
              duration: const Duration(seconds: 1),
              curve: Curves.linear,
            );
            _newCustomOcr.sectionId = _sectionsList[_sectionIndex].sectionId;
            _newCustomOcr.sectionName = _sectionsList[_sectionIndex].sectionName;
            _isSectionPickerOpen = false;
          });
          // _applyFilters();
        },
        child: ClayButton(
          depth: 40,
          color: _sectionsList.indexOf(section) == _sectionIndex ? Colors.blue[200] : clayContainerColor(context),
          spread: _sectionsList.indexOf(section) == _sectionIndex ? 0 : 2,
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
              child: Text(
                "Section: ${_sectionsList[_sectionIndex].sectionName}",
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
            children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      color: clayContainerColor(context),
      spread: 5,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          if (_isLoading) return;
          setState(() {
            _isSectionPickerOpen = !_isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 14, 5, 14),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    "Section: ${_sectionsList[_sectionIndex].sectionName}",
                  ),
                ),
              ),
              if (_isEditMode && !widget.adminProfile.isMegaAdmin)
                Expanded(
                  flex: 1,
                  child: buildIsOcrAsPerTtSwitch(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildIsOcrAsPerTtSwitch() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Switch(
          onChanged: (value) {
            _updateSectionOCRAsPerTTFlag(_sectionsList[_sectionIndex], value);
          },
          value: _sectionsList[_sectionIndex].ocrAsPerTt ?? false,
        ),
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("OCR as per TT"),
        ),
      ],
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(25),
        child: _isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  color: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget buildOnlineClassRoomsForSectionAndWeek(Section section, String week) {
    List<OnlineClassRoom> sectionWiseOCRsForWeek = _onlineClassRooms
        .where((e) => section.sectionId == e.sectionId && e.week == week && e.sectionWiseTimeSlotId != null && e.sectionWiseTimeSlotId != 0)
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
          child: sectionWiseOCRsForWeek.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            week,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ClayContainer(
                        depth: 20,
                        color: clayContainerColor(context),
                        borderRadius: 10,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("Time Slots not assigned"),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: <Widget>[
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
                      sectionWiseOCRsForWeek
                          .map(
                            (e) => buildTtOcrContainer(e),
                          )
                          .toList(),
                ),
        ),
      ),
    );
  }

  Widget buildTtOcrContainer(OnlineClassRoom onlineClassRoom) {
    List<OnlineClassRoom> _thisOcrOverlappedWith = [];

    if (onlineClassRoom.date == null) {
      DateTime x = DateTime.now();
      DateTime now = DateTime(x.year, x.month, x.day);

      var customCRs = _onlineClassRooms.where((eachOcr) {
        return eachOcr.date != null && (convertYYYYMMDDFormatToDateTime(eachOcr.date!).difference(now)).inDays < 7;
      });

      _thisOcrOverlappedWith = customCRs.where((eachOcr) {
        int startTimeEqOfThisOcr = getSecondsEquivalentOfTimeFromWHHMMSS(onlineClassRoom.startTime, onlineClassRoom.weekId);
        int startTimeEqOfEachOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.startTime, eachOcr.weekId);
        int endTimeEqOfThisOcr = getSecondsEquivalentOfTimeFromWHHMMSS(onlineClassRoom.endTime, onlineClassRoom.weekId);
        int endTimeEqOfEachOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.endTime, eachOcr.weekId);
        if ((startTimeEqOfEachOcr < startTimeEqOfThisOcr && startTimeEqOfThisOcr < endTimeEqOfEachOcr) ||
            (startTimeEqOfEachOcr < endTimeEqOfThisOcr && endTimeEqOfThisOcr < endTimeEqOfEachOcr)) return true;
        if (startTimeEqOfEachOcr == startTimeEqOfThisOcr && endTimeEqOfEachOcr == endTimeEqOfThisOcr) return true;
        return false;
      }).toList();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: _thisOcrOverlappedWith.isNotEmpty
          ? Tooltip(
              message: _getOverlappedMessage(_thisOcrOverlappedWith),
              child: buildTtOcrClayContainer(_thisOcrOverlappedWith, onlineClassRoom),
            )
          : buildTtOcrClayContainer(_thisOcrOverlappedWith, onlineClassRoom),
    );
  }

  String _getOverlappedMessage(List<OnlineClassRoom> _thisOcrOverlappedWith) {
    return "This session is replaced with\n" +
        _thisOcrOverlappedWith
            .map((eachOcr) =>
                "${eachOcr.date == null ? "-" : convertDateToDDMMMYYYEEEE(eachOcr.date!)} - ${eachOcr.startTime == null ? "-" : convert24To12HourFormat(eachOcr.startTime!)} - ${eachOcr.endTime == null ? "-" : convert24To12HourFormat(eachOcr.endTime!)}\n${eachOcr.sectionName == null ? "-" : eachOcr.sectionName!} - ${eachOcr.subjectName == null ? "-" : eachOcr.subjectName!.capitalize()} - ${eachOcr.teacherName == null ? "-" : eachOcr.teacherName!.capitalize()}")
            .join("\n");
  }

  ClayContainer buildTtOcrClayContainer(List<OnlineClassRoom> _thisOcrOverlappedWith, OnlineClassRoom onlineClassRoom) {
    return ClayContainer(
      depth: 20,
      // height: 100,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      borderRadius: 10,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(5),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    convert24To12HourFormat(onlineClassRoom.startTime!),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(5),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    convert24To12HourFormat(onlineClassRoom.endTime!),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (onlineClassRoom.subjectName ?? "-").capitalize(),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (onlineClassRoom.teacherName ?? "-").capitalize(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomOnlineClassRoomsForSection(Section section) {
    List<OnlineClassRoom> sectionWiseOCRsForWeek = _onlineClassRooms
        .where((e) => section.sectionId == e.sectionId && (e.sectionWiseTimeSlotId == null || e.sectionWiseTimeSlotId == 0))
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
          child: sectionWiseOCRsForWeek.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Custom Class Rooms",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ClayContainer(
                        depth: 20,
                        color: clayContainerColor(context),
                        borderRadius: 10,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("No Custom Class Rooms available"),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: <Widget>[
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Custom Class Rooms",
                              ),
                            ],
                          ),
                        ),
                      ] +
                      sectionWiseOCRsForWeek
                          .map(
                            (e) => buildCustomOcrContainer(e),
                          )
                          .toList(),
                ),
        ),
      ),
    );
  }

  Widget buildCustomOcrContainer(OnlineClassRoom e) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayContainer(
        depth: 20,
        // height: 100,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          e.date!,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${convert24To12HourFormat(e.startTime!)} - ${convert24To12HourFormat(e.endTime!)}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          (e.subjectName ?? "-").capitalize(),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          (e.teacherName ?? "-").capitalize(),
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
    );
  }

  Widget _buildOnlineClassRoomWidgetsForAllSections() {
    int crossAxisCount = MediaQuery.of(context).size.width ~/ 300;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: PageView(
        physics: const BouncingScrollPhysics(),
        controller: pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (int x) {
          setState(() {
            _sectionIndex = x;
          });
        },
        children: _sectionsList.map((eachSection) {
          List<OnlineClassRoom> onlineClassRoomsForGivenSection = _onlineClassRooms.where((e) => eachSection.sectionId == e.sectionId).toList();
          double heightOfEachCard = [1, 2, 3, 4, 5, 6, 7].map((eachWeekId) {
                    return onlineClassRoomsForGivenSection.where((eachTimeSlot) => eachTimeSlot.weekId == eachWeekId).length;
                  }).reduce(max) *
                  50 +
              275;
          double widthOfEachCard = (MediaQuery.of(context).size.width - 10) / crossAxisCount;
          return SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  child: ClayContainer(
                    depth: 40,
                    surfaceColor: Colors.blue[200],
                    parentColor: clayContainerColor(context),
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
                      children: [
                        GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: widthOfEachCard / heightOfEachCard,
                          children: (eachSection.ocrAsPerTt ?? false)
                              ? WEEKS
                                      .map(
                                        (eachWeek) => buildOnlineClassRoomsForSectionAndWeek(
                                          eachSection,
                                          eachWeek,
                                        ),
                                      )
                                      .toList() +
                                  [
                                    buildCustomOnlineClassRoomsForSection(eachSection),
                                    const SizedBox(
                                      height: 100,
                                    ),
                                  ]
                              : [
                                  buildCustomOnlineClassRoomsForSection(eachSection),
                                  const SizedBox(
                                    height: 100,
                                  ),
                                ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _createNewCustomOcrWidget() {
    if (!_isEditMode || widget.adminProfile.isMegaAdmin) return Container();
    return Container(
      margin: const EdgeInsets.all(50),
      padding: const EdgeInsets.all(50),
      child: Center(
        child: ClayContainer(
          depth: 100,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: Container(
            color: Colors.pink,
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  child: const Text("Create new Custom OCR"),
                ),
                Container(
                  child: Text("Section: ${_sectionsList[_sectionIndex].sectionName}"),
                ),
                Container(
                  child: Text("Date picker"),
                ),
                Container(
                  child: Text("Start Time Picker"),
                ),
                Container(
                  child: Text("End Time Picker"),
                ),
                Container(
                  child: Text("TDS Picker"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Online Class Rooms"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.adminProfile,
          ),
        ],
      ),
      drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          // : ListView(
          //     children: [
          //       _sectionPicker(),
          //       _buildOnlineClassRoomWidgetsForAllSections(),
          //     ],
          //   ),
          : _manageOCRsWidget(),
      // : Stack(
      //         children: [
      //           Opacity(
      //             opacity: 1,
      //             child: _createNewCustomOcrWidget(),
      //           ),
      //           Opacity(
      //             opacity: _isEditMode ? 0.4 : 1,
      //             child: _manageOCRsWidget(),
      //           ),
      //         ],
      //       ),
      floatingActionButton: _isLoading || widget.adminProfile.isMegaAdmin
          ? Container()
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.vibrate();
                  setState(() {
                    _isEditMode = !_isEditMode;
                  });
                },
                child: ClayButton(
                  parentColor: clayContainerColor(context),
                  surfaceColor: _isEditMode ? Colors.green[500] : Colors.blue,
                  height: 50,
                  width: 50,
                  borderRadius: 50,
                  child: Icon(
                    _isEditMode ? Icons.check : Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }

  CustomScrollView _manageOCRsWidget() {
    return CustomScrollView(
      shrinkWrap: true,
      physics: _isEditMode && !widget.adminProfile.isMegaAdmin ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
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
          child: _buildOnlineClassRoomWidgetsForAllSections(),
        ),
      ],
    );
  }
}
