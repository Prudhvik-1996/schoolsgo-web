import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/time_slot.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentTimeTableView extends StatefulWidget {
  const StudentTimeTableView({Key? key, required this.studentProfile})
      : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/timetable";

  @override
  _StudentTimeTableViewState createState() => _StudentTimeTableViewState();
}

class _StudentTimeTableViewState extends State<StudentTimeTableView>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<SectionWiseTimeSlotBean> _sectionWiseTimeSlots = [];

  late TabController _tabController;

  bool _previewMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: DateTime.now().weekday - 1,
    );
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
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
      status: "active",
    ));
    if (getSectionWiseTimeSlotsResponse.httpStatus == "OK" &&
        getSectionWiseTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _sectionWiseTimeSlots =
            getSectionWiseTimeSlotsResponse.sectionWiseTimeSlotBeanList!;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _previewTimeTable() {
    List<TeacherDealingSection> _tdsList = _sectionWiseTimeSlots
        .where((e) => e.tdsId != null)
        .map((e) => TeacherDealingSection(
              tdsId: e.tdsId,
              subjectId: e.subjectId,
              subjectName: e.subjectName,
              teacherId: e.teacherId,
              teacherName: e.teacherName,
              sectionId: e.sectionId,
              sectionName: e.sectionName,
              schoolId: widget.studentProfile.schoolId,
            ))
        .toList();
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
        .where((eachTimeSlot) =>
            eachTimeSlot.sectionId == widget.studentProfile.sectionId)
        .map((e) =>
            TimeSlot(weekId: 0, startTime: (e.startTime), endTime: (e.endTime)))
        .toSet()
        .toList();
    double height = 25;
    double width =
        (MediaQuery.of(context).size.width - 21) / (timeSlots.length + 1);
    return InteractiveViewer(
      minScale: 0.25,
      maxScale: 10,
      panEnabled: true,
      alignPanAxis: false,
      child: RepaintBoundary(
        key: GlobalKey(),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Container(
            child: Column(
                children: [
                      Row(
                        children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.5),
                                  color: Colors.blue[200],
                                ),
                                height: height,
                                width: width,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${widget.studentProfile.sectionName}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
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
                                      color: Colors.blue[200],
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text(
                                          "${convert24To12HourFormat(e.startTime!)}\n${convert24To12HourFormat(e.endTime!)}" +
                                              " " *
                                                  (allStrings.last.length - 12),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            color: Colors.black,
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
                                      color: Colors.blue[200],
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
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                ] +
                                timeSlots.map((eachTimeSlot) {
                                  String res = "N/A" +
                                      " " * (allStrings.last.length - 5);
                                  var x = _sectionWiseTimeSlots.where((e) =>
                                      e.week == eachWeek &&
                                      e.startTime == eachTimeSlot.startTime &&
                                      e.endTime == eachTimeSlot.endTime &&
                                      e.sectionId ==
                                          widget.studentProfile.sectionId);
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
                                    padding: EdgeInsets.all(3),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        res,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.black,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
        actions: [
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : _previewMode
              ? _previewTimeTable()
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  controller: ScrollController(),
                  children: [const Text("Time Table")] +
                      _sectionWiseTimeSlots.map((e) => Text("$e")).toList(),
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
