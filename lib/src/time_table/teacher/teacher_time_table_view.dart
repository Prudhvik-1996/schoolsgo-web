import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/online_class_room/model/online_class_room.dart';
import 'package:schoolsgo_web/src/time_table/admin/admin_all_teachers_preview_time_table_screens.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class TeacherTimeTableView extends StatefulWidget {
  const TeacherTimeTableView({Key? key, required this.teacherProfile})
      : super(key: key);

  final TeacherProfile teacherProfile;

  static const routeName = "/timetable";

  @override
  _TeacherTimeTableViewState createState() => _TeacherTimeTableViewState();
}

class _TeacherTimeTableViewState extends State<TeacherTimeTableView>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<SectionWiseTimeSlotBean> _allSectionWiseTimeSlots = [];
  bool _showOnlyOcr = false;

  List<SectionWiseTimeSlotBean> _sectionWiseTimeSlots = [];

  bool _previewMode = false;

  late double heightOfEachCard;
  late double widthOfEachCard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _sectionWiseTimeSlots = [];
      _allSectionWiseTimeSlots = [];
      _previewMode = false;
      _showOnlyOcr = false;
    });

    GetSectionWiseTimeSlotsResponse getSectionWiseTimeSlotsResponse =
        await getSectionWiseTimeSlots(GetSectionWiseTimeSlotsRequest(
      schoolId: widget.teacherProfile.schoolId,
      teacherId: widget.teacherProfile.teacherId,
      status: "active",
    ));
    if (getSectionWiseTimeSlotsResponse.httpStatus == "OK" &&
        getSectionWiseTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _allSectionWiseTimeSlots =
            getSectionWiseTimeSlotsResponse.sectionWiseTimeSlotBeanList!;
        heightOfEachCard = [1, 2, 3, 4, 5, 6, 7].map((eachWeekId) {
                  return _allSectionWiseTimeSlots
                      .where(
                          (eachTimeSlot) => eachTimeSlot.weekId == eachWeekId)
                      .length;
                }).reduce(max) *
                50 +
            275;
      });
    }

    // Get all online class rooms
    GetOnlineClassRoomsResponse getOnlineClassRoomsResponse =
        await getOnlineClassRooms(GetOnlineClassRoomsRequest(
      schoolId: widget.teacherProfile.schoolId,
      teacherId: widget.teacherProfile.teacherId,
    ));
    if (getOnlineClassRoomsResponse.httpStatus == "OK" &&
        getOnlineClassRoomsResponse.responseStatus == "success") {
      setState(() {
        List<OnlineClassRoom> _onlineClassRooms = [];
        _onlineClassRooms = getOnlineClassRoomsResponse.onlineClassRooms!
            .map((e) => e!)
            .toList();
        DateTime x = DateTime.now();
        DateTime now = DateTime(x.year, x.month, x.day);
        var customOCRs = _onlineClassRooms
            .where((eachOcr) =>
                eachOcr.date != null &&
                (convertYYYYMMDDFormatToDateTime(eachOcr.date!).difference(now))
                        .inDays <
                    7)
            .toList();
        var traditionalOCRs =
            _onlineClassRooms.where((eachOcr) => eachOcr.date == null);
        var overLappedOCRs = [];
        for (var eachTraditionalOcr in traditionalOCRs) {
          for (var eachCustomOcr in customOCRs) {
            bool isOverlapped = false;
            int startTimeEqOfTraditionalOcr =
                getSecondsEquivalentOfTimeFromWHHMMSS(
                    eachTraditionalOcr.startTime, eachTraditionalOcr.weekId);
            int startTimeEqOfCustomOcr = getSecondsEquivalentOfTimeFromWHHMMSS(
                eachCustomOcr.startTime, eachCustomOcr.weekId);
            int endTimeEqOfTraditionalOcr =
                getSecondsEquivalentOfTimeFromWHHMMSS(
                    eachTraditionalOcr.endTime, eachTraditionalOcr.weekId);
            int endTimeEqOfCustomOcr = getSecondsEquivalentOfTimeFromWHHMMSS(
                eachCustomOcr.endTime, eachCustomOcr.weekId);
            if ((startTimeEqOfCustomOcr < startTimeEqOfTraditionalOcr &&
                    startTimeEqOfTraditionalOcr < endTimeEqOfCustomOcr) ||
                (startTimeEqOfCustomOcr < endTimeEqOfTraditionalOcr &&
                    endTimeEqOfTraditionalOcr < endTimeEqOfCustomOcr)) {
              isOverlapped = true;
            }
            if (startTimeEqOfCustomOcr == startTimeEqOfTraditionalOcr &&
                endTimeEqOfCustomOcr == endTimeEqOfTraditionalOcr) {
              isOverlapped = true;
            }
            if (isOverlapped) {
              overLappedOCRs.add(eachTraditionalOcr);
            }
          }
        }
        for (var eachOverlappedOcr in overLappedOCRs) {
          _onlineClassRooms.remove(eachOverlappedOcr);
        }
        _onlineClassRooms.sort((a, b) => a.compareTo(b));
        for (var eachOcr in _onlineClassRooms) {
          if (!overLappedOCRs.contains(eachOcr)) {
            _allSectionWiseTimeSlots.add(eachOcr.toSectionWiseTimeSlotBean());
          }
        }
      });
    }

    await _refreshStsBeansAsPerIsOcr();

    setState(() {
      _isLoading = false;
    });
  }

  Widget _switchToShowOnlyOcr() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Column(
        children: [
          Switch(
            value: _showOnlyOcr,
            onChanged: (bool newValue) {
              setState(() {
                _showOnlyOcr = newValue;
              });
              _refreshStsBeansAsPerIsOcr();
            },
          ),
          Text(
            _showOnlyOcr ? "Show Offline Time Table" : "Show Online Time Table",
          ),
        ],
      ),
    );
  }

  Future<void> _refreshStsBeansAsPerIsOcr() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _sectionWiseTimeSlots = _showOnlyOcr
          ? _allSectionWiseTimeSlots.where((eachSts) => eachSts.isOcr).toList()
          : _allSectionWiseTimeSlots
              .where((eachSts) => !eachSts.isOcr)
              .toList();
    });
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildWeekWiseTile(String week) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
                  Container(
                    margin: const EdgeInsets.all(3),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            week,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: DateTime.now().weekday - 1 ==
                                      WEEKS.indexOf(week)
                                  ? Colors.blue[300]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ] +
                (_sectionWiseTimeSlots.where((e) => e.week == week).isEmpty
                    ? [
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ClayContainer(
                            depth: 40,
                            surfaceColor: clayContainerColor(context),
                            parentColor: clayContainerColor(context),
                            spread: 1,
                            borderRadius: 10,
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.all(3),
                              child: const Center(child: Text("No Sessions")),
                            ),
                          ),
                        )
                      ]
                    : _sectionWiseTimeSlots
                        .where((e) => e.week == week)
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.all(8),
                            child: ClayContainer(
                              depth: 40,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              spread: 1,
                              borderRadius: 10,
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.all(3),
                                // child: Text(
                                //   e.toString(),
                                // ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            8, 0, 8, 0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "${convert24To12HourFormat(e.startTime!)} - ${convert24To12HourFormat(e.endTime!)}",
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            5, 0, 5, 0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                (e.subjectName ?? "-")
                                                    .capitalize(),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            if (e.tdsId == null)
                                              Container()
                                            else
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  (e.sectionName ?? "")
                                                      .capitalize(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width ~/ 300;
    widthOfEachCard = (MediaQuery.of(context).size.width - 10) / crossAxisCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
        actions: [
          buildRoleButtonForAppBar(context, widget.teacherProfile),
        ],
      ),
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : _previewMode
              ? TeacherTimeTablePreviewScreen(
                  adminProfile: null,
                  teacherProfile: widget.teacherProfile,
                  isOcr: _showOnlyOcr,
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _switchToShowOnlyOcr(),
                      ],
                    ),
                    GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: widthOfEachCard / heightOfEachCard,
                      children: WEEKS
                          .map(
                            (eachWeek) => buildWeekWiseTile(eachWeek),
                          )
                          .toList(),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          _previewMode ? Icons.close : Icons.preview_outlined,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            _previewMode = !_previewMode;
          });
        },
      ),
    );
  }
}
