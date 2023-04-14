import 'package:clay_containers/widgets/clay_container.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/student_information_center/modal/month_wise_attendance.dart';
import 'package:schoolsgo_web/src/student_information_center/student_base_widget.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentInformationScreen extends StatefulWidget {
  const StudentInformationScreen({
    Key? key,
    required this.adminProfile,
    required this.studentProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final StudentProfile studentProfile;

  @override
  State<StudentInformationScreen> createState() => _StudentInformationScreenState();
}

class _StudentInformationScreenState extends State<StudentInformationScreen> {
  bool _isLoading = true;
  bool _loadingStudentAttendance = true;
  bool _isAttendanceGraphView = false;

  List<StudentMonthWiseAttendance> studentMonthWiseAttendanceList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadStudentAttendance();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadStudentAttendance() async {
    setState(() {
      _loadingStudentAttendance = true;
    });
    GetStudentMonthWiseAttendanceResponse getStudentMonthWiseAttendanceResponse = await getStudentMonthWiseAttendance(
        GetStudentMonthWiseAttendanceRequest(studentId: widget.studentProfile.studentId, schoolId: widget.studentProfile.schoolId, isAdminView: "Y"));
    if (getStudentMonthWiseAttendanceResponse.httpStatus != "OK" || getStudentMonthWiseAttendanceResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentMonthWiseAttendanceList =
            (getStudentMonthWiseAttendanceResponse.studentMonthWiseAttendanceList ?? []).where((e) => e != null).map((e) => e!).toList();
      });
    }
    setState(() {
      _loadingStudentAttendance = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentProfile.studentFirstName ?? ""),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          StudentBaseWidget(context: context, studentProfile: widget.studentProfile),
          const SizedBox(height: 20),
          studentAttendanceCard(),
        ],
      ),
    );
  }

  Widget studentAttendanceCard() {
    if (_loadingStudentAttendance) {
      return Container(
        padding: MediaQuery.of(context).orientation == Orientation.portrait
            ? const EdgeInsets.all(10)
            : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
        child: ClayContainer(
          emboss: false,
          depth: 15,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: const [
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "Attendance",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    double screenWidth =
        (MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 2) - 50;
    double eachWidgetHeight = 105;
    double eachWidgetWidth = MediaQuery.of(context).orientation == Orientation.portrait ? 100 : 150;
    List<Widget> rows = [];
    int index = 0;
    double horizontalPadding = MediaQuery.of(context).orientation == Orientation.portrait ? 7.5 : 15;
    double verticalPadding = MediaQuery.of(context).orientation == Orientation.portrait ? 7.5 : 15;
    while (index < studentMonthWiseAttendanceList.length) {
      List<Widget> eachRowChildren = [];
      double remainingWidth = screenWidth;
      while (remainingWidth > (eachWidgetWidth) && index < studentMonthWiseAttendanceList.length) {
        eachRowChildren.add(Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
          child:
              monthWiseTile(studentMonthWiseAttendanceList[index], eachWidgetHeight - 2 * verticalPadding, eachWidgetWidth - 2 * horizontalPadding),
        ));
        remainingWidth -= (eachWidgetWidth);
        index += 1;
      }
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: eachRowChildren,
        ),
      );
    }

    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: ClayContainer(
        emboss: false,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Attendance",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setState(() => _isAttendanceGraphView = !_isAttendanceGraphView),
                        child: ClayButton(
                          depth: 40,
                          spread: 2,
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          borderRadius: 100,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(10),
                            child: !_isAttendanceGraphView ? const Icon(Icons.auto_graph_sharp, size: 12,) : const Icon(Icons.grid_view_rounded, size: 12,),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "No. of days present: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => e.present ?? 0.0).reduce((a, b) => a + b))}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "No. of days absent: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => e.absent ?? 0.0).reduce((a, b) => a + b))}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Total no.of working days: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => (e.present ?? 0.0) + (e.absent ?? 0)).reduce((a, b) => a + b))}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Attendance Percentage: ${doubleToStringAsFixed(studentMonthWiseAttendanceList.map((e) => e.present ?? 0.0).reduce((a, b) => a + b) * 100.0 / studentMonthWiseAttendanceList.map((e) => (e.present ?? 0.0) + (e.absent ?? 0)).reduce((a, b) => a + b))} %",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ] +
                (_isAttendanceGraphView ? [graphView()] : rows) +
                <Widget>[
                  const SizedBox(height: 10),
                ],
          ),
        ),
      ),
    );
  }

  Widget graphView() {
    List ranking = studentMonthWiseAttendanceList
        .map((e) => {
              "monthYear": "${MONTHS[(e.month ?? 1) - 1].substring(0, 3).toLowerCase().capitalize()}\n${e.year ?? "-"}",
              "percentage": double.parse(doubleToStringAsFixed((e.present ?? 0.0) * 100.0 / ((e.present ?? 0.0) + (e.absent ?? 0.0))))
            })
        .toList();
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DChartBarCustom(
        loadingDuration: const Duration(milliseconds: 1500),
        showLoading: true,
        valueAlign: Alignment.topCenter,
        showDomainLine: true,
        showDomainLabel: true,
        showMeasureLine: true,
        showMeasureLabel: true,
        spaceDomainLabeltoChart: 0,
        spaceMeasureLabeltoChart: 0,
        spaceDomainLinetoChart: 0,
        spaceMeasureLinetoChart: 10,
        spaceBetweenItem: 10,
        radiusBar: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        max: 100,
        listData: List.generate(ranking.length, (index) {
          return DChartBarDataCustom(
            onTap: () {
              print(
                '${ranking[index]['monthYear']} => ${ranking[index]['percentage']}',
              );
            },
            elevation: 8,
            value: ranking[index]['percentage'].toDouble(),
            label: ranking[index]['monthYear'],
            color: Colors.blue,
            splashColor: Colors.blue,
            showValue: true,
            labelCustom: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                ranking[index]['monthYear'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            valueCustom: const Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 1,
                width: 1,
              ),
            ),
            valueTooltip: '${ranking[index]['percentage']} %',
          );
        }),
      ),
    );
  }

  Widget monthWiseTile(StudentMonthWiseAttendance e, double height, double width) {
    double percentage = (e.present ?? 0.0) / ((e.present ?? 0.0) + (e.absent ?? 0.0)) * 100.0;
    return SizedBox(
      height: height,
      width: width,
      child: FlipCard(
        fill: Fill.fillBack,
        direction: FlipDirection.HORIZONTAL,
        side: CardSide.FRONT,
        front: ClayContainer(
          emboss: true,
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Text(
                "${MONTHS[(e.month ?? 1) - 1].substring(0, 3).toLowerCase().capitalize()} ${e.year ?? "-"}",
                style: const TextStyle(
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                doubleToStringAsFixed(percentage) + " %",
                style: TextStyle(
                  color: percentage >= 75
                      ? Colors.green
                      : percentage >= 65
                          ? Colors.amber
                          : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
        back: ClayContainer(
          emboss: true,
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Text(
                "${MONTHS[(e.month ?? 1) - 1].substring(0, 3).toLowerCase().capitalize()} ${e.year ?? "-"}",
                style: const TextStyle(
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                "Present: ${doubleToStringAsFixed(e.present ?? 0.0)}",
                style: TextStyle(
                  color: percentage >= 75
                      ? Colors.green
                      : percentage >= 65
                          ? Colors.amber
                          : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                "Total: ${doubleToStringAsFixed((e.present ?? 0.0) + (e.absent ?? 0.0))}",
                style: TextStyle(
                  color: percentage >= 75
                      ? Colors.green
                      : percentage >= 65
                          ? Colors.amber
                          : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
        flipOnTouch: true,
      ),
    );
  }
}
