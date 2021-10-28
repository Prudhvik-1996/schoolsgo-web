import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
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
      _previewMode = false;
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
        _sectionWiseTimeSlots =
            getSectionWiseTimeSlotsResponse.sectionWiseTimeSlotBeanList!;
        heightOfEachCard = [1, 2, 3, 4, 5, 6, 7].map((eachWeekId) {
                  return _sectionWiseTimeSlots
                      .where(
                          (eachTimeSlot) => eachTimeSlot.weekId == eachWeekId)
                      .length;
                }).reduce(max) *
                50 +
            275;
      });
    }

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
                )
              : GridView.count(
                  crossAxisCount: crossAxisCount,
                  physics: const BouncingScrollPhysics(),
                  childAspectRatio: widthOfEachCard / heightOfEachCard,
                  children: WEEKS
                      .map(
                        (eachWeek) => buildWeekWiseTile(eachWeek),
                      )
                      .toList(),
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
