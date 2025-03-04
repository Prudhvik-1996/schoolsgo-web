import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/online_class_room/meeting/meeting_room.dart';
import 'package:schoolsgo_web/src/online_class_room/model/online_class_room.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AdminMonitorOnlineClassRoomsScreen extends StatefulWidget {
  const AdminMonitorOnlineClassRoomsScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/onlineclassroom";

  @override
  _AdminMonitorOnlineClassRoomsScreenState createState() => _AdminMonitorOnlineClassRoomsScreenState();
}

class _AdminMonitorOnlineClassRoomsScreenState extends State<AdminMonitorOnlineClassRoomsScreen> {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  bool _isSectionPickerOpen = false;
  int _sectionIndex = 0;

  List<OnlineClassRoom> _onlineClassRooms = [];

  late PageController pageController;

  bool _showAllOngoingClassRooms = false;

  @override
  void initState() {
    _loadData();
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
        List<OnlineClassRoom> _allOnlineClassRooms = getOnlineClassRoomsResponse.onlineClassRooms!.map((e) => e!).toList();
        _allOnlineClassRooms.map((eachOcr) => _getAllOverlappedOcrs(eachOcr)).expand((i) => i).toList().forEach((eachOverlappedOcr) {
          _allOnlineClassRooms.remove(eachOverlappedOcr);
        });
        _allOnlineClassRooms.sort((a, b) => a.compareTo(b));
        _onlineClassRooms = _allOnlineClassRooms
            .where((eachOcr) => eachOcr.tdsId != null && eachOcr.tdsId != 0)
            .map((eachOcr) {
              if (eachOcr.date != null) return [eachOcr];
              DateTime now = DateTime.now();
              DateTime i = DateTime(now.year, now.month, now.day);
              List<OnlineClassRoom> _newOcrs = [];
              while (now.add(const Duration(days: 6)).millisecondsSinceEpoch > i.millisecondsSinceEpoch) {
                if (eachOcr.weekId == i.weekday) {
                  OnlineClassRoom newOcr = eachOcr.clone();
                  newOcr.date = convertDateTimeToYYYYMMDDFormat(i);
                  _newOcrs.add(newOcr);
                }
                i = i.add(const Duration(days: 1));
              }
              return _newOcrs;
            })
            .expand((i) => i)
            .toList();
        _onlineClassRooms.sort((a, b) => a.compareTo(b));
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<OnlineClassRoom> _getAllOverlappedOcrs(OnlineClassRoom onlineClassRoom) {
    List<OnlineClassRoom> _thisOcrOverlappedWith = [];

    if (onlineClassRoom.date == null) {
      DateTime x = DateTime.now();
      DateTime now = DateTime(x.year, x.month, x.day);

      var customCRs = _onlineClassRooms.where((eachOcr) {
        return eachOcr.date != null && convertYYYYMMDDFormatToDateTime(eachOcr.date!).difference(now).inDays < 7;
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
    return _thisOcrOverlappedWith;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ClayContainer(
            depth: 20,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
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
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          height: 50,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showAllOngoingClassRooms = !_showAllOngoingClassRooms;
              });
            },
            child: ClayButton(
              depth: 20,
              surfaceColor: _showAllOngoingClassRooms ? Colors.blue[200] : Colors.green[300],
              parentColor: clayContainerColor(context),
              borderRadius: 10,
              spread: 5,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _showAllOngoingClassRooms
                        ? "Show upcoming Classes\nfor ${_sectionsList[_sectionIndex].sectionName ?? "-"}".toUpperCase()
                        : "Show all\non-going classes".toUpperCase(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
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
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget _buildLandscapeWidget() {
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
          List<OnlineClassRoom> _ongoingClasses = _onlineClassRooms.where((eachOcr) {
            if (eachOcr.sectionId != eachSection.sectionId) return false;
            if (eachOcr.tdsId == null) return false;
            int currentMillis = getSecondsEquivalentOfTimeFromWHHMMSS(null, DateTime.now().weekday);
            int eachOcrStartTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.startTime!, eachOcr.weekId);
            int eachOcrEndTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.endTime!, eachOcr.weekId);
            return eachOcrStartTimeMillis <= currentMillis && currentMillis <= eachOcrEndTimeMillis;
          }).toList();
          List<OnlineClassRoom> _upcomingClasses = _onlineClassRooms.where((eachOcr) {
            if (eachOcr.sectionId != eachSection.sectionId) return false;
            if (eachOcr.tdsId == null) return false;
            int currentMillis = getSecondsEquivalentOfTimeFromWHHMMSS(null, DateTime.now().weekday);
            int eachOcrStartTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.startTime!, eachOcr.weekId);
            int eachOcrEndTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.endTime!, eachOcr.weekId);
            return !(eachOcrStartTimeMillis <= currentMillis && currentMillis <= eachOcrEndTimeMillis);
          }).toList();
          return SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container(
                //   margin: const EdgeInsets.all(10),
                //   padding: const EdgeInsets.all(10),
                //   child: ClayContainer(
                //     depth: 40,
                //     surfaceColor: Colors.blue[200],
                //     parentColor: clayContainerColor(context),
                //     borderRadius: 10,
                //     child: Container(
                //       padding: const EdgeInsets.all(10),
                //       child: Center(
                //         child: Text(
                //           "${eachSection.sectionName}",
                //           style: const TextStyle(
                //             fontSize: 24,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: buildOnGoingClassesWidget(_ongoingClasses),
                      ),
                      Expanded(
                        flex: 1,
                        child: _showAllOngoingClassRooms ? buildAllOngoingClasses() : buildUpcomingClassesWidget(_upcomingClasses),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortraitWidget() {
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
          List<OnlineClassRoom> _ongoingClasses = _onlineClassRooms.where((eachOcr) {
            if (eachOcr.sectionId != eachSection.sectionId) return false;
            if (eachOcr.tdsId == null) return false;
            int currentMillis = getSecondsEquivalentOfTimeFromWHHMMSS(null, DateTime.now().weekday);
            int eachOcrStartTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.startTime!, eachOcr.weekId);
            int eachOcrEndTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.endTime!, eachOcr.weekId);
            return eachOcrStartTimeMillis <= currentMillis && currentMillis <= eachOcrEndTimeMillis;
          }).toList();
          List<OnlineClassRoom> _upcomingClasses = _onlineClassRooms.where((eachOcr) {
            if (eachOcr.sectionId != eachSection.sectionId) return false;
            if (eachOcr.tdsId == null) return false;
            int currentMillis = getSecondsEquivalentOfTimeFromWHHMMSS(null, DateTime.now().weekday);
            int eachOcrStartTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.startTime!, eachOcr.weekId);
            int eachOcrEndTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.endTime!, eachOcr.weekId);
            return !(eachOcrStartTimeMillis <= currentMillis && currentMillis <= eachOcrEndTimeMillis);
          }).toList();
          return SizedBox(
            width: MediaQuery.of(context).size.width - 10,
            child: Column(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: buildOnGoingClassesWidget(_ongoingClasses),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: _showAllOngoingClassRooms ? buildAllOngoingClasses() : buildUpcomingClassesWidget(_upcomingClasses),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildAllOngoingClasses() {
    List<OnlineClassRoom> _allOngoingClassRooms = _onlineClassRooms.where((eachOcr) {
      if (eachOcr.tdsId == null) return false;
      int currentMillis = getSecondsEquivalentOfTimeFromWHHMMSS(null, DateTime.now().weekday);
      int eachOcrStartTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.startTime!, eachOcr.weekId);
      int eachOcrEndTimeMillis = getSecondsEquivalentOfTimeFromWHHMMSS(eachOcr.endTime!, eachOcr.weekId);
      return eachOcrStartTimeMillis <= currentMillis && currentMillis <= eachOcrEndTimeMillis;
    }).toList();
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: ListView(
            children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: ClayContainer(
                      depth: 20,
                      surfaceColor: Colors.green[300],
                      parentColor: clayContainerColor(context),
                      borderRadius: 10,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("On Going Classes"),
                        ),
                      ),
                    ),
                  ),
                ] +
                (_allOngoingClassRooms.isEmpty
                    ? [
                        SizedBox(
                          height: 100,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: ClayContainer(
                              depth: 20,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              borderRadius: 10,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text("No on going classes"),
                                ),
                              ),
                            ),
                          ),
                        )
                      ]
                    : _allOngoingClassRooms.map((eachOcr) => buildOngoingOcrContainer(eachOcr)).toList()),
          ),
        ),
      ),
    );
  }

  Widget buildOngoingOcrContainer(OnlineClassRoom e) {
    return Stack(
      children: [
        SizedBox(
          height: 85,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _sectionIndex = _sectionsList.map((e) => e.sectionId).toList().indexOf(e.sectionId);
                  pageController.animateToPage(
                    _sectionIndex,
                    duration: const Duration(seconds: 1),
                    curve: Curves.linear,
                  );
                });
              },
              child: ClayButton(
                depth: 20,
                // height: 100,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                borderRadius: 10,
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
                              // child: Text(
                              //   convertDateToDDMMMEEEE(e.date!),
                              // ),
                              child: Text.rich(
                                TextSpan(
                                  text: convertDateToDDMMMEEEE(e.date!).split(", ")[0] + " ",
                                  style: const TextStyle(
                                    color: Colors.pink,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: convertDateToDDMMMEEEE(e.date!).split(", ")[1],
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                    )
                                  ],
                                ),
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
                                (e.sectionName ?? "-").capitalize() + " " + (e.subjectName ?? "-").capitalize(),
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
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.all(5),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.green,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOnGoingClassesWidget(List<OnlineClassRoom> _ongoingClasses) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: _ongoingClasses.isEmpty
            ? [
                SizedBox(
                  height: 100,
                  child: ClayContainer(
                    depth: 20,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    borderRadius: 10,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("No on going classes"),
                      ),
                    ),
                  ),
                )
              ]
            : _ongoingClasses
                .map(
                  (eachOcr) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return MeetingRoom(
                                onlineClassRoom: eachOcr,
                                adminProfile: widget.adminProfile,
                              );
                            }));
                          },
                          child: ClayButton(
                            depth: 20,
                            surfaceColor: Colors.blue[200],
                            parentColor: clayContainerColor(context),
                            borderRadius: 10,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: Text(
                                  "${eachOcr.date} - ${eachOcr.startTime} - ${eachOcr.endTime}\n"
                                  "${eachOcr.sectionName ?? "-"} - ${(eachOcr.subjectName ?? "-").capitalize()} - ${(eachOcr.teacherName ?? "-").capitalize()}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.videocam_rounded,
                            color: Colors.green,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }

  Container buildUpcomingClassesWidget(List<OnlineClassRoom> _upcomingClasses) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: ListView(
            children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: ClayContainer(
                      depth: 20,
                      surfaceColor: Colors.blue[200],
                      parentColor: clayContainerColor(context),
                      borderRadius: 10,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Upcoming Classes"),
                        ),
                      ),
                    ),
                  ),
                ] +
                (_upcomingClasses.isEmpty
                    ? [
                        SizedBox(
                          height: 100,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: ClayContainer(
                              depth: 20,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              borderRadius: 10,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text("No upcoming classes"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                    : _upcomingClasses
                        .map(
                          (eachOcr) => buildUpcomingOcrContainer(eachOcr),
                        )
                        .toList()),
          ),
        ),
      ),
    );
  }

  Widget buildUpcomingOcrContainer(OnlineClassRoom e) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          text: convertDateToDDMMMEEEE(e.date!).split(", ")[0] +
                              (MediaQuery.of(context).orientation == Orientation.landscape ? "\n" : " "),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: convertDateToDDMMMEEEE(e.date!).split(", ")[1],
                              style: TextStyle(
                                color: clayContainerTextColor(context),
                                fontSize: 11,
                              ),
                            )
                          ],
                        ),
                        textAlign: TextAlign.center,
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
              const SizedBox(
                width: 20,
              ),
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitor Online Class Rooms"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.adminProfile,
          ),
        ],
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled() ? null : AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
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
                  child: MediaQuery.of(context).orientation == Orientation.landscape ? _buildLandscapeWidget() : _buildPortraitWidget(),
                ),
              ],
            ),
    );
  }
}
