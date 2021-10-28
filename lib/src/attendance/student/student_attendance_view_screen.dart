import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_app_bar.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../model/attendance_beans.dart';

class StudentAttendanceViewScreen extends StatefulWidget {
  final StudentProfile studentProfile;

  static const routeName = "/attendance";

  const StudentAttendanceViewScreen({Key? key, required this.studentProfile})
      : super(key: key);

  @override
  _StudentAttendanceViewScreenState createState() =>
      _StudentAttendanceViewScreenState();
}

class _StudentAttendanceViewScreenState
    extends State<StudentAttendanceViewScreen> {
  bool _isLoading = true;

  List<StudentAttendanceBean> _studentAttendanceBeans = [];
  List<Widget> _dateWiseAttendanceBeans = [];

  late double totalDays, presentDays, absentDays;

  late List<String?> _availableDates;

  DateTime? _selectedDate;

  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _studentAttendanceBeans = [];
      _dateWiseAttendanceBeans = [];
      totalDays = 0;
      presentDays = 0;
      absentDays = 0;
      _availableDates = [];
      _selectedDate = null;
    });

    GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse =
        await getStudentAttendanceBeans(GetStudentAttendanceBeansRequest(
      schoolId: widget.studentProfile.schoolId,
      studentId: widget.studentProfile.studentId,
      sectionId: widget.studentProfile.sectionId,
    ));
    if (getStudentAttendanceBeansResponse.httpStatus == "OK" &&
        getStudentAttendanceBeansResponse.responseStatus == "success") {
      setState(() {
        _studentAttendanceBeans =
            getStudentAttendanceBeansResponse.studentAttendanceBeans!;
      });
    }
    setState(() {
      _availableDates = _studentAttendanceBeans
          .where((e) => e.startTime != null)
          .map((e) => e.date)
          .toSet()
          .toList();
    });

    _studentAttendanceBeans.map((e) => e.date).toSet().forEach((eachDate) {
      List<StudentAttendanceBean> iterableSlots = _studentAttendanceBeans
          .where((e) => e.date == eachDate)
          .where((e) => e.startTime != null)
          .toList();

      if (iterableSlots.isNotEmpty) {
        setState(() {
          int totalSlotsPerDay = iterableSlots.length;
          int unmarkedSlotsPerDay = iterableSlots
              .where((e) => e.isPresent == null || e.isPresent == 0)
              .length;
          int markedPresentSlotsPerDay = iterableSlots
              .where((e) => e.isPresent != null && e.isPresent == 1)
              .length;
          int markedAbsentSlotsPerDay = iterableSlots
              .where((e) => e.isPresent != null && e.isPresent == -1)
              .length;

          if (unmarkedSlotsPerDay != totalSlotsPerDay) {
            totalDays += 1;
            presentDays += markedPresentSlotsPerDay /
                (totalSlotsPerDay - unmarkedSlotsPerDay);
            absentDays += markedAbsentSlotsPerDay /
                (totalSlotsPerDay - unmarkedSlotsPerDay);
          }
        });
      }
    });

    _buildStudentAttendanceDateWise();

    setState(() {
      _isLoading = false;
    });
  }

  void _buildStudentAttendanceDateWise() {
    setState(() {
      _dateWiseAttendanceBeans = [];
    });
    _studentAttendanceBeans.map((e) => e.date).toSet().forEach((eachDate) {
      List<StudentAttendanceBean> iterableSlots = _studentAttendanceBeans
          .where((e) => e.date == eachDate)
          .where((e) => e.startTime != null)
          .toList();

      if (iterableSlots.isNotEmpty) {
        setState(() {
          _dateWiseAttendanceBeans.add(
            Container(
              margin: const EdgeInsets.fromLTRB(25, 10, 25, 15),
              child: ClayContainer(
                depth: 20,
                color: clayContainerColor(context),
                spread: 5,
                borderRadius: 10,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 1),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                              padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                              child: ClayText(
                                convertDateToDDMMMYYY(eachDate!),
                                textColor: clayContainerTextColor(context),
                                parentColor: clayContainerColor(context),
                                // color: clayContainerColor(context),
                                emboss: true,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      GridView.count(
                        childAspectRatio: 2,
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                        children: iterableSlots.map(
                          (e) {
                            return Container(
                              margin: const EdgeInsets.all(1),
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                convertDateToDDMMMYYY(eachDate),
                                              ),
                                              Text(
                                                '${convert24To12HourFormat(e.startTime!)} : ${convert24To12HourFormat(e.endTime!)}',
                                              )
                                            ],
                                          ),
                                          content: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  (e.isPresent == null ||
                                                              e.isPresent == 0
                                                          ? "Attendance manager:"
                                                          : "Marked by:") +
                                                      "\n" +
                                                      "${e.managerName}",
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: e.isPresent == null ||
                                                        e.isPresent == 0
                                                    ? Image.asset(
                                                        'assets/images/empty_stroke.png',
                                                        height: 50,
                                                        width: 50,
                                                      )
                                                    : e.isPresent == -1
                                                        ? Image.asset(
                                                            'assets/images/cross_icon.png',
                                                            height: 50,
                                                            width: 50,
                                                          )
                                                        : Image.asset(
                                                            'assets/images/tick_icon.png',
                                                            height: 50,
                                                            width: 50,
                                                          ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: ClayButton(
                                    depth: 20,
                                    spread: 1,
                                    color:
                                        e.isPresent == null || e.isPresent == 0
                                            ? clayContainerColor(context)
                                            : e.isPresent == 1
                                                ? const Color(0xFFBCF78A)
                                                : const Color(0xFFF88C6C),
                                    surfaceColor:
                                        e.isPresent == null || e.isPresent == 0
                                            ? clayContainerColor(context)
                                            : e.isPresent == 1
                                                ? const Color(0xFFBCF78A)
                                                : const Color(0xFFF88C6C),
                                    borderRadius: 10,
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(8),
                                      child: ClayText(
                                        convert24To12HourFormat(e.startTime!),
                                        textColor:
                                            clayContainerTextColor(context),
                                        parentColor:
                                            clayContainerColor(context),
                                        color: clayContainerColor(context),
                                        emboss: true,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }
    });
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.vibrate();
          if (_availableDates.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Attendance entries not found"),
              ),
            );
            return;
          }
          DateTime? _newDate = await showDatePicker(
            context: context,
            selectableDayPredicate: (DateTime val) {
              return _availableDates
                  .contains(convertDatTimeToYYYYMMDDFormat(val));
            },
            initialDate: DateTime.parse(_availableDates.first!),
            firstDate: DateTime.parse(_availableDates.last!),
            lastDate: DateTime.parse(_availableDates.first!),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            _selectedDate = _newDate;
            _itemScrollController.scrollTo(
              index: _availableDates
                  .indexOf(convertDatTimeToYYYYMMDDFormat(_selectedDate!)),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutCubic,
            );
          });
          _buildStudentAttendanceDateWise();
        },
        child: const ClayButton(
          depth: 40,
          surfaceColor: Color(0xFFC9EDF8),
          spread: 2,
          borderRadius: 50,
          height: 60,
          width: 60,
          child: Center(
            child: Icon(
              Icons.calendar_today_rounded,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTileForAttendanceStats() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("No. of days present: $presentDays"),
        const SizedBox(height: 15),
        Text("No. of days absent: $absentDays"),
        const SizedBox(height: 15),
        Text(
          "Total Working Days: $totalDays",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    if (_isLoading) {
      return Scaffold(
        // appBar: AppBar(),
        body: Center(
          child: Image.asset('assets/images/eis_loader.gif'),
        ),
      );
    }
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Attendance"),
          actions: [
            buildRoleButtonForAppBar(context, widget.studentProfile),
          ],
        ),
        drawer: StudentAppDrawer(
          studentProfile: widget.studentProfile,
        ),
        body: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Center(child: buildStatsWidget()),
              ),
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemCount: _dateWiseAttendanceBeans.length,
                  itemBuilder: (context, index) =>
                      _dateWiseAttendanceBeans[index],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _getDatePicker(),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            controller: controller,
            slivers: [
              CustomAppBar(
                collapsedTitle: const Text(
                  "Attendance",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24.0,
                  ),
                ),
                backgroundColor: const Color(0xFF5FC9EC),
                expandedHeight: 300,
                backgroundWidget: buildStatsWidget(),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                fillOverscroll: true,
                child: ScrollablePositionedList.builder(
                  itemScrollController: _itemScrollController,
                  itemCount: _dateWiseAttendanceBeans.length,
                  itemBuilder: (context, index) =>
                      _dateWiseAttendanceBeans[index],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _getDatePicker(),
      );
    }
  }

  Widget buildStatsWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClayText(
                "Attendance",
                size: 32,
                textColor: clayContainerTextColor(context),
                parentColor: clayContainerColor(context),
                emboss: true,
                // depth: 2,
                spread: 2,
              )
            ],
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: buildTileForAttendanceStats(),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Attendance Percentage",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    CircularPercentIndicator(
                      animation: true,
                      animationDuration: 1000,
                      radius: 100.0,
                      lineWidth: 15.0,
                      percent: totalDays == 0 ? 0 : presentDays / totalDays,
                      center: Text(
                        totalDays == 0
                            ? "N/A"
                            : (presentDays * 100.0 / totalDays)
                                    .toStringAsFixed(2) +
                                " %",
                      ),
                      progressColor: Colors.blueAccent,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
