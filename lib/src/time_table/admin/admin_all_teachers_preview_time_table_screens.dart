import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/online_class_room/model/online_class_room.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class TeacherTimeTablePreviewScreen extends StatefulWidget {
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final bool isOcr;

  const TeacherTimeTablePreviewScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.isOcr,
  }) : super(key: key);

  @override
  _TeacherTimeTablePreviewScreenState createState() => _TeacherTimeTablePreviewScreenState();
}

class _TeacherTimeTablePreviewScreenState extends State<TeacherTimeTablePreviewScreen> {
  bool _isLoading = true;
  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<SectionWiseTimeSlotBean> _sectionWiseTimeSlots = [];

  @override
  void initState() {
    super.initState();
    if (widget.teacherProfile != null) {
      print("36: ${widget.teacherProfile!.teacherName}");
      _selectedTeacher = Teacher(
        teacherName: widget.teacherProfile!.teacherName,
        schoolId: widget.teacherProfile!.schoolId,
        teacherId: widget.teacherProfile!.teacherId,
        teacherPhotoUrl: widget.teacherProfile!.teacherPhotoUrl,
      );
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _teachersList = [];
    });

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
      teacherId: widget.teacherProfile == null ? null : widget.teacherProfile!.teacherId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachersList = getTeachersResponse.teachers!;
        _selectedTeacher = _teachersList[0];
      });
    }

    if (!widget.isOcr) {
      GetSectionWiseTimeSlotsResponse getSectionWiseTimeSlotsResponse = await getSectionWiseTimeSlots(GetSectionWiseTimeSlotsRequest(
        schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
        // teacherId: widget.teacherProfile.teacherId,
        status: "active",
      ));
      if (getSectionWiseTimeSlotsResponse.httpStatus == "OK" && getSectionWiseTimeSlotsResponse.responseStatus == "success") {
        setState(() {
          _sectionWiseTimeSlots = getSectionWiseTimeSlotsResponse.sectionWiseTimeSlotBeanList!;

          _sectionWiseTimeSlots.sort((a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime!, a.weekId!)
              .compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime!, b.weekId!)));
        });
      }
    } else {
      // Get all online class rooms
      GetOnlineClassRoomsResponse getOnlineClassRoomsResponse = await getOnlineClassRooms(GetOnlineClassRoomsRequest(
        schoolId: widget.adminProfile == null ? widget.teacherProfile!.schoolId : widget.adminProfile!.schoolId,
        teacherId: widget.adminProfile == null ? null : widget.teacherProfile!.teacherId,
      ));
      if (getOnlineClassRoomsResponse.httpStatus == "OK" && getOnlineClassRoomsResponse.responseStatus == "success") {
        setState(() {
          List<OnlineClassRoom> _onlineClassRooms = [];
          _onlineClassRooms = getOnlineClassRoomsResponse.onlineClassRooms!.map((e) => e!).toList();
          DateTime x = DateTime.now();
          DateTime now = DateTime(x.year, x.month, x.day);
          var customOCRs = _onlineClassRooms
              .where((eachOcr) => eachOcr.date != null && (convertYYYYMMDDFormatToDateTime(eachOcr.date!).difference(now)).inDays < 7)
              .toList();
          var traditionalOCRs = _onlineClassRooms.where((eachOcr) => eachOcr.date == null);
          var overLappedOCRs = [];
          for (var eachTraditionalOcr in traditionalOCRs) {
            for (var eachCustomOcr in customOCRs) {
              bool isOverlapped = false;
              int startTimeEqOfTraditionalOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachTraditionalOcr.startTime, eachTraditionalOcr.weekId);
              int startTimeEqOfCustomOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachCustomOcr.startTime, eachCustomOcr.weekId);
              int endTimeEqOfTraditionalOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachTraditionalOcr.endTime, eachTraditionalOcr.weekId);
              int endTimeEqOfCustomOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachCustomOcr.endTime, eachCustomOcr.weekId);
              if ((startTimeEqOfCustomOcr < startTimeEqOfTraditionalOcr && startTimeEqOfTraditionalOcr < endTimeEqOfCustomOcr) ||
                  (startTimeEqOfCustomOcr < endTimeEqOfTraditionalOcr && endTimeEqOfTraditionalOcr < endTimeEqOfCustomOcr)) {
                isOverlapped = true;
              }
              if (startTimeEqOfCustomOcr == startTimeEqOfTraditionalOcr && endTimeEqOfCustomOcr == endTimeEqOfTraditionalOcr) {
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
              _sectionWiseTimeSlots.add(eachOcr.toSectionWiseTimeSlotBean());
            }
          }
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _selectTeacher() {
    // return SearchableDropdown<Teacher>.single(
    //   icon: Container(),
    //   underline: Container(),
    //   displayClearIcon: false,
    //   searchFn: (String keyword, List<DropdownMenuItem<Teacher>> items) {
    //     List<int> ret = <int>[];
    //     if (keyword.isNotEmpty) {
    //       keyword.split(" ").forEach((k) {
    //         int i = 0;
    //         for (var item in items) {
    //           if (k.isNotEmpty &&
    //               item.value != null &&
    //               (item.value!.teacherName!
    //                   .split(" ")
    //                   .map((e) => e)
    //                   .where((e) => e.toLowerCase().startsWith(k.toLowerCase()))
    //                   .isNotEmpty)) {
    //             ret.add(i);
    //           }
    //           i++;
    //         }
    //       });
    //     }
    //     if (keyword.isEmpty) {
    //       ret = Iterable<int>.generate(items.length).toList();
    //     }
    //     return (ret);
    //   },
    //   items: _teachersList
    //       .map(
    //         (e) => DropdownMenuItem<Teacher>(
    //           value: e,
    //           child: SizedBox(
    //             width: MediaQuery.of(context).size.width,
    //             height: 40,
    //             child: ListTile(
    //               leading: Container(
    //                 width: 50,
    //                 padding: const EdgeInsets.all(5),
    //                 child: e.teacherPhotoUrl == null
    //                     ? Image.asset(
    //                         "assets/images/avatar.png",
    //                         fit: BoxFit.contain,
    //                       )
    //                     : Image.network(
    //                         e.teacherPhotoUrl!,
    //                         fit: BoxFit.contain,
    //                       ),
    //               ),
    //               title: Text(
    //                 e.teacherName ?? "-",
    //                 style: const TextStyle(
    //                   fontSize: 14,
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       )
    //       .toList(),
    //   value: _selectedTeacher,
    //   hint: const SizedBox(
    //     height: 40,
    //     child: Center(child: Text("Select teacher")),
    //   ),
    //   searchHint: "Select teacher",
    //   onChanged: (selectedTeacher) {
    //     setState(() {
    //       _selectedTeacher = selectedTeacher;
    //     });
    //   },
    //   isExpanded: true,
    // );
    return DropdownButton(
      underline: Container(),
      isExpanded: true,
      value: _selectedTeacher,
      onChanged: (Teacher? teacher) {
        setState(() {
          _selectedTeacher = teacher!;
        });
      },
      items: _teachersList
          .map(
            (e) => DropdownMenuItem<Teacher>(
              value: e,
              child: SizedBox(
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
                  title: Text(
                    e.teacherName ?? "-",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Container _previewTimeTable(int weekId) {
    double height = 70;
    if (_selectedTeacher == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue[200],
          border: const Border(
            top: BorderSide(),
            bottom: BorderSide(),
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: height,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 2,
                  ),
                ),
              ),
              width: 50,
              height: height,
              child: Center(child: Text(WEEKS[weekId - 1])),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
              width: MediaQuery.of(context).size.width - 50,
              height: height,
              child: const Center(child: Text("")),
            ),
          ],
        ),
      );
    }
    List<int> timeValues = _sectionWiseTimeSlots
        .map((e) => [getSecondsEquivalentOfTimeFromWHHMMSS(e.startTime!, 0), getSecondsEquivalentOfTimeFromWHHMMSS(e.endTime!, 0)])
        .expand((i) => i)
        .toList();

    int minimumTimeValue = timeValues.reduce(min);
    int maximumTimeValue = timeValues.reduce(max);

    double widthEquivalentInSeconds = (maximumTimeValue - minimumTimeValue) / (MediaQuery.of(context).size.width - 50);

    int curMin = minimumTimeValue;

    List<Container> _widgets = [];

    List<TimeSlotForPreview> _previewingSlots = [];

    _sectionWiseTimeSlots.where((e) => e.tdsId != null && e.weekId == weekId && e.teacherId == _selectedTeacher!.teacherId).forEach((eachTimeSlot) {
      bool _updatedExistingPreview = false;
      String tsTimeKey = "${eachTimeSlot.week}|${eachTimeSlot.startTime}|${eachTimeSlot.endTime}";
      _previewingSlots.forEach((eachTimeSlotToPreview) {
        String psTimeKey = "${eachTimeSlotToPreview.week}|${eachTimeSlotToPreview.startTime}|${eachTimeSlotToPreview.endTime}";
        if (psTimeKey == tsTimeKey && eachTimeSlotToPreview.subjectId == eachTimeSlot.subjectId) {
          eachTimeSlotToPreview.sectionNames = (eachTimeSlotToPreview.sectionNames ?? "") + ", " + (eachTimeSlot.sectionName ?? "");
          _updatedExistingPreview = true;
        }
      });
      if (!_updatedExistingPreview) {
        _previewingSlots.add(TimeSlotForPreview(
          teacherName: eachTimeSlot.teacherName,
          teacherId: eachTimeSlot.teacherId,
          endTime: eachTimeSlot.endTime,
          startTime: eachTimeSlot.startTime,
          week: eachTimeSlot.week,
          weekId: eachTimeSlot.weekId,
          sectionNames: eachTimeSlot.sectionName,
          subjectId: eachTimeSlot.subjectId,
          subjectName: eachTimeSlot.subjectName,
        ));
      }
    });

    _previewingSlots.where((e) => e.sectionNames != null && e.weekId == weekId && e.teacherId == _selectedTeacher!.teacherId).forEach((e) {
      if (curMin != getSecondsEquivalentOfTimeFromWHHMMSS(e.startTime!, 0)) {
        _widgets.add(
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
            ),
            width: (getSecondsEquivalentOfTimeFromWHHMMSS(e.startTime!, 0) - curMin) / widthEquivalentInSeconds,
            height: height,
            child: const Center(child: Text("")),
          ),
        );
      }
      _widgets.add(
        Container(
          decoration: BoxDecoration(
            color: widget.isOcr ? Colors.green[200] : Colors.red[200],
            border: Border(
              left: BorderSide(
                width: 0.05,
                color: clayContainerTextColor(context),
              ),
              right: BorderSide(
                width: 0.025,
                color: clayContainerTextColor(context),
              ),
            ),
          ),
          width: (getSecondsEquivalentOfTimeFromWHHMMSS(e.endTime!, 0) - getSecondsEquivalentOfTimeFromWHHMMSS(e.startTime!, 0)) /
              widthEquivalentInSeconds,
          height: height,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "${e.startTime} - ${e.endTime}\n${(e.teacherName ?? "-").capitalize()}\n${(e.sectionNames ?? "-").trimTrailingRegex(", ")}\n${(e.subjectName ?? "-").capitalize()}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
      curMin = getSecondsEquivalentOfTimeFromWHHMMSS(e.endTime!, 0);
    });
    if (curMin != maximumTimeValue) {
      _widgets.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
          ),
          width: (maximumTimeValue - curMin) / widthEquivalentInSeconds,
          height: height,
          child: const Center(child: Text("")),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[200],
        border: const Border(
          top: BorderSide(),
          bottom: BorderSide(),
        ),
      ),
      width: MediaQuery.of(context).size.width,
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: 2,
                    ),
                  ),
                ),
                width: 50,
                height: height,
                child: Center(child: Text(WEEKS[weekId - 1])),
              )
            ] +
            _widgets,
      ),
    );
  }

  Container _buildGrid() {
    List<int> timeValues = _sectionWiseTimeSlots
        .map((e) => [getSecondsEquivalentOfTimeFromWHHMMSS(e.startTime!, 0), getSecondsEquivalentOfTimeFromWHHMMSS(e.endTime!, 0)])
        .expand((i) => i)
        .toList();

    int minimumTimeValue = timeValues.reduce(min);
    int maximumTimeValue = timeValues.reduce(max);

    double widthEquivalentInSeconds = (maximumTimeValue - minimumTimeValue) / (MediaQuery.of(context).size.width - 50);

    int nextMinHourEquivalent = minimumTimeValue + minimumTimeValue % 3600;
    // print(minimumTimeValue);
    // print(nextMinHourEquivalent);

    List<int> timeSlotValues = [minimumTimeValue];
    if (minimumTimeValue != nextMinHourEquivalent) {
      timeSlotValues.add(nextMinHourEquivalent);
    }
    int curMin = timeSlotValues.last;
    while (curMin < maximumTimeValue) {
      timeSlotValues.add(curMin + 3600);
      curMin += 3600;
    }
    if (timeSlotValues.last < maximumTimeValue) {
      timeSlotValues.add(maximumTimeValue);
    }

    List<Container> timeSlotWidgets = [];
    for (int i = 0; i < timeSlotValues.length - 1; i++) {
      timeSlotWidgets.add(
        Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(),
            ),
          ),
          height: 70 * 7.0,
          width: (timeSlotValues[i + 1] - timeSlotValues[i]) / widthEquivalentInSeconds,
          child: const Text(
            "",
            textAlign: TextAlign.end,
          ),
        ),
      );
    }
    timeSlotWidgets.add(
      Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(),
          ),
        ),
        height: 70 * 7.0,
        width: (timeSlotValues.last - timeSlotValues[timeSlotValues.length - 2]) / widthEquivalentInSeconds,
        child: const Text(
          "",
          textAlign: TextAlign.end,
        ),
      ),
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(),
          bottom: BorderSide(),
        ),
        color: Colors.blue[200],
      ),
      height: 70 * 7.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
              Container(
                decoration: BoxDecoration(
                  border: const Border(
                    right: BorderSide(width: 2),
                  ),
                  color: Colors.blue[200],
                ),
                width: 50,
                height: 70,
                child: const Text(""),
              ),
            ] +
            timeSlotWidgets,
      ),
    );
  }

  Container _buildXAxis() {
    List<int> timeValues = _sectionWiseTimeSlots
        .map((e) => [getSecondsEquivalentOfTimeFromWHHMMSS(e.startTime!, 0), getSecondsEquivalentOfTimeFromWHHMMSS(e.endTime!, 0)])
        .expand((i) => i)
        .toList();

    int minimumTimeValue = timeValues.reduce(min);
    int maximumTimeValue = timeValues.reduce(max);

    double widthEquivalentInSeconds = (maximumTimeValue - minimumTimeValue) / (MediaQuery.of(context).size.width - 50);

    int nextMinHourEquivalent = minimumTimeValue + minimumTimeValue % 3600;
    // print(minimumTimeValue);
    // print(nextMinHourEquivalent);

    List<int> timeSlotValues = [minimumTimeValue];
    if (minimumTimeValue != nextMinHourEquivalent) {
      timeSlotValues.add(nextMinHourEquivalent);
    }
    int curMin = timeSlotValues.last;
    while (curMin < maximumTimeValue) {
      timeSlotValues.add(curMin + 3600);
      curMin += 3600;
    }
    if (timeSlotValues.last < maximumTimeValue) {
      timeSlotValues.add(maximumTimeValue);
    }

    List<Container> timeSlotWidgets = [];
    for (int i = 0; i < timeSlotValues.length - 1; i++) {
      timeSlotWidgets.add(
        Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(),
            ),
          ),
          height: 70 * 8.0,
          width: (timeSlotValues[i + 1] - timeSlotValues[i]) / widthEquivalentInSeconds,
          child: RotatedBox(
            quarterTurns: 3,
            child: FittedBox(
              alignment: Alignment.topRight,
              fit: BoxFit.scaleDown,
              child: Text(
                convertHHMMSSSecondsEquivalentToHHMMA(timeSlotValues[i]),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ),
      );
    }
    timeSlotWidgets.add(
      Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(),
          ),
        ),
        height: 70,
        width: (timeSlotValues.last - timeSlotValues[timeSlotValues.length - 2]) / widthEquivalentInSeconds,
        child: RotatedBox(
          quarterTurns: 3,
          child: FittedBox(
            alignment: Alignment.topRight,
            fit: BoxFit.scaleDown,
            child: Text(
              convertHHMMSSSecondsEquivalentToHHMMA(timeSlotValues.last),
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ),
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(),
          bottom: BorderSide(),
        ),
        color: Colors.blue[200],
      ),
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
              Container(
                decoration: BoxDecoration(
                  border: const Border(
                    right: BorderSide(width: 2),
                  ),
                  color: Colors.blue[200],
                ),
                width: 50,
                height: 70,
                child: const Text(""),
              ),
            ] +
            timeSlotWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.teacherProfile == null
          ? AppBar(
              title: const Text("Teachers' time table preview"),
            )
          : null,
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              height: (70 * 9.0) + 2,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(),
                  bottom: BorderSide(),
                ),
              ),
              child: InteractiveViewer(
                minScale: 0.25,
                maxScale: 10,
                panEnabled: true,
                alignPanAxis: false,
                child: RepaintBoundary(
                  key: GlobalKey(),
                  child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                border: const Border(
                                  top: BorderSide(),
                                  bottom: BorderSide(),
                                ),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 70,
                              child: Center(
                                child: widget.teacherProfile == null
                                    ? _selectTeacher()
                                    : ListTile(
                                        leading: Container(
                                          width: 50,
                                          padding: const EdgeInsets.all(5),
                                          child: widget.teacherProfile == null
                                              ? Container()
                                              : widget.teacherProfile!.teacherPhotoUrl == null
                                                  ? Image.asset(
                                                      "assets/images/avatar.png",
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Image.network(
                                                      widget.teacherProfile!.teacherPhotoUrl!,
                                                      fit: BoxFit.contain,
                                                    ),
                                        ),
                                        title: Text(
                                          widget.teacherProfile == null ? "-" : widget.teacherProfile!.teacherName ?? "-",
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Stack(
                              children: [
                                ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [1, 2, 3, 4, 5, 6, 7].map((e) => _previewTimeTable(e)).toList(),
                                ),
                                Opacity(opacity: 0.05, child: _buildGrid()),
                              ],
                            ),
                          ] +
                          [_buildXAxis()]),
                ),
              ),
            ),
    );
  }
}

class TimeSlotForPreview {
  String? endTime;
  String? startTime;
  String? sectionNames;
  int? teacherId;
  String? teacherName;
  String? week;
  int? weekId;
  int? subjectId;
  String? subjectName;

  TimeSlotForPreview({
    this.endTime,
    this.startTime,
    this.sectionNames,
    this.teacherId,
    this.teacherName,
    this.week,
    this.weekId,
    this.subjectId,
    this.subjectName,
  });
}
