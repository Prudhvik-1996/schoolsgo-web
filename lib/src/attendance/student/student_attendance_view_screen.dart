import 'dart:math';

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/clay_pie_chart/clay_pie_chart.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../model/attendance_beans.dart';

class StudentAttendanceViewScreen extends StatefulWidget {
  final StudentProfile studentProfile;

  static const routeName = "/attendance";

  const StudentAttendanceViewScreen({Key? key, required this.studentProfile}) : super(key: key);

  @override
  _StudentAttendanceViewScreenState createState() => _StudentAttendanceViewScreenState();
}

class _StudentAttendanceViewScreenState extends State<StudentAttendanceViewScreen> {
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

    GetStudentAttendanceBeansResponse getStudentAttendanceBeansResponse = await getStudentAttendanceBeans(GetStudentAttendanceBeansRequest(
      schoolId: widget.studentProfile.schoolId,
      studentId: widget.studentProfile.studentId,
      sectionId: widget.studentProfile.sectionId,
    ));
    if (getStudentAttendanceBeansResponse.httpStatus == "OK" && getStudentAttendanceBeansResponse.responseStatus == "success") {
      setState(() {
        _studentAttendanceBeans = getStudentAttendanceBeansResponse.studentAttendanceBeans!;
      });
    }
    setState(() {
      _availableDates = _studentAttendanceBeans.where((e) => e.startTime != null).map((e) => e.date).toSet().toList();
    });

    _studentAttendanceBeans.map((e) => e.date).toSet().forEach((eachDate) {
      List<StudentAttendanceBean> iterableSlots = _studentAttendanceBeans.where((e) => e.date == eachDate).where((e) => e.startTime != null).toList();

      if (iterableSlots.isNotEmpty) {
        setState(() {
          int totalSlotsPerDay = iterableSlots.length;
          int unmarkedSlotsPerDay = iterableSlots.where((e) => e.isPresent == null || e.isPresent == 0).length;
          int markedPresentSlotsPerDay = iterableSlots.where((e) => e.isPresent != null && e.isPresent == 1).length;
          int markedAbsentSlotsPerDay = iterableSlots.where((e) => e.isPresent != null && e.isPresent == -1).length;

          if (unmarkedSlotsPerDay != totalSlotsPerDay) {
            totalDays += 1;
            presentDays += markedPresentSlotsPerDay / (totalSlotsPerDay - unmarkedSlotsPerDay);
            absentDays += markedAbsentSlotsPerDay / (totalSlotsPerDay - unmarkedSlotsPerDay);
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
      List<StudentAttendanceBean> iterableSlots = _studentAttendanceBeans.where((e) => e.date == eachDate).where((e) => e.startTime != null).toList();

      if (iterableSlots.isNotEmpty) {
        setState(() {
          _dateWiseAttendanceBeans.add(
            Container(
              margin: MediaQuery.of(context).orientation == Orientation.landscape
                  ? const EdgeInsets.fromLTRB(100, 10, 100, 15)
                  : const EdgeInsets.fromLTRB(15, 10, 15, 10),
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
                                convertDateToDDMMMYYYEEEE(eachDate!),
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
                      StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        children: iterableSlots.map(
                          (e) {
                            return Container(
                              width: 100,
                              height: 120,
                              margin: const EdgeInsets.all(1),
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                convertDateToDDMMMYYYEEEE(eachDate),
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
                                                  (e.isPresent == null || e.isPresent == 0 ? "Attendance manager:" : "Marked by:") +
                                                      "\n" +
                                                      "${e.managerName}",
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: e.isPresent == null || e.isPresent == 0
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
                                  child: ClayContainer(
                                    depth: 20,
                                    spread: 1,
                                    emboss: true,
                                    color: clayContainerColor(context),
                                    borderRadius: 10,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: ClayText(
                                              convert24To12HourFormat(e.startTime!),
                                              textColor: clayContainerTextColor(context),
                                              parentColor: clayContainerColor(context),
                                              color: clayContainerColor(context),
                                              emboss: true,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                                          child: e.isPresent == null || e.isPresent == 0
                                              ? Image.asset(
                                                  'assets/images/empty_stroke.png',
                                                  height: 30,
                                                  width: 30,
                                                )
                                              : e.isPresent == -1
                                                  ? Image.asset(
                                                      'assets/images/cross_icon.png',
                                                      height: 30,
                                                      width: 30,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/tick_icon.png',
                                                      height: 30,
                                                      width: 30,
                                                    ),
                                        ),
                                      ],
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
              return _availableDates.contains(convertDateTimeToYYYYMMDDFormat(val));
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
              index: _availableDates.indexOf(convertDateTimeToYYYYMMDDFormat(_selectedDate!)) + 1,
              duration: const Duration(seconds: 1),
              curve: Curves.linear,
            );
          });
          _buildStudentAttendanceDateWise();
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: const Color(0xFFC9EDF8),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 50,
          height: 60,
          width: 60,
          child: const Center(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "${widget.studentProfile.studentFirstName}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("No. of days present: $presentDays"),
        ),
        const SizedBox(height: 15),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("No. of days absent: $absentDays"),
        ),
        const SizedBox(height: 15),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Total Working Days: $totalDays",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Attendance Percentage: ${doubleToStringAsFixed((totalDays == 0 ? 0 : presentDays / totalDays) * 100)}%",
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildStudentAttendanceDateWise();
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
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : SafeArea(
              top: false,
              child: MediaQuery.of(context).orientation == Orientation.landscape
                  ? Row(
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
                            itemBuilder: (context, index) => _dateWiseAttendanceBeans[index],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ScrollablePositionedList.builder(
                            itemScrollController: _itemScrollController,
                            itemCount: _dateWiseAttendanceBeans.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return buildStatsWidget();
                              }
                              return _dateWiseAttendanceBeans[index - 1];
                            },
                          ),
                        ),
                      ],
                    ),
            ),
      floatingActionButton: _isLoading ? null : _getDatePicker(),
    );
  }

  Widget buildStatsWidget() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape ? const EdgeInsets.fromLTRB(50, 15, 15, 15) : const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
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
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ClayPieChart(
                            angle: 2 * pi * (totalDays == 0 ? 0 : presentDays / totalDays),
                            diameter: 90,
                            highlightColor: Colors.green,
                            surfaceColor: Colors.red,
                            parentColor: clayContainerColor(context),
                            spread: 5,
                            customBorderRadius: BorderRadius.circular(100),
                            depth: 20,
                            highlightedText: "${doubleToStringAsFixed((totalDays == 0 ? 0 : presentDays / totalDays) * 100)}%",
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
