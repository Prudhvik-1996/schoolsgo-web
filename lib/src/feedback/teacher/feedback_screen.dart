import 'package:clay_containers/widgets/clay_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/feedback/model/feedback.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class TeacherFeedbackScreen extends StatefulWidget {
  const TeacherFeedbackScreen({
    Key? key,
    required this.teacherProfile,
  }) : super(key: key);

  final TeacherProfile teacherProfile;

  static const routeName = "/feedback";

  @override
  _TeacherFeedbackScreenState createState() => _TeacherFeedbackScreenState();
}

class _TeacherFeedbackScreenState extends State<TeacherFeedbackScreen> {
  bool _isLoading = true;

  bool _isMonthWiseFeedback = false;
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    // const Color(0xff02d39a),
  ];

  List<StudentToTeacherFeedback> _feedbackBeans = [];

  // teacherId, dateString, rating
  final Map<int, Map<String, double>> _teacherWiseFilteredRatingKMap = {};
  final Map<int, String> _teacherWiseAverageRatingMap = {};
  List<DateTime> _dates = [];
  List<DateTime> _months = [];
  final ScrollController _feedbackGraphController = ScrollController();

  DateFormat format = DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetStudentToTeacherFeedbackResponse getStudentToTeacherFeedbackResponse = await getStudentToTeacherFeedback(GetStudentToTeacherFeedbackRequest(
      teacherId: widget.teacherProfile.teacherId,
      schoolId: widget.teacherProfile.schoolId,
      teacherWiseAverageRating: true,
      adminView: true,
    ));

    if (getStudentToTeacherFeedbackResponse.httpStatus == "OK" && getStudentToTeacherFeedbackResponse.responseStatus == "success") {
      setState(() {
        _feedbackBeans = getStudentToTeacherFeedbackResponse.feedbackBeans!.map((e) => e!).where((e) => e.feedbackId != null).toList();
      });
    }

    // teacherId, dateString, feedbackBean
    Map<int, Map<String, List<StudentToTeacherFeedback>>> _teacherWiseFeedbackMap = {};
    _teacherWiseFeedbackMap[widget.teacherProfile.teacherId!] = {};
    for (var eachFeedbackBean in _feedbackBeans) {
      String dateString = format.format(DateTime.fromMillisecondsSinceEpoch(eachFeedbackBean.createTime!));
      if (_teacherWiseFeedbackMap[eachFeedbackBean.teacherId]!.containsKey(dateString)) {
        _teacherWiseFeedbackMap[eachFeedbackBean.teacherId]![dateString]!.add(eachFeedbackBean);
      } else {
        _teacherWiseFeedbackMap[eachFeedbackBean.teacherId]![dateString] = [eachFeedbackBean];
      }
    }
    for (var teacherId in _teacherWiseFeedbackMap.keys) {
      _teacherWiseFilteredRatingKMap[teacherId] = _teacherWiseFeedbackMap[teacherId]!.map((dateString, feedbackBeans) {
        double avgRating = feedbackBeans.map((e) => e.rating!.toDouble()).reduce((a, b) => (a + b));
        return MapEntry(dateString, avgRating / feedbackBeans.length);
      });
    }

    _teacherWiseAverageRatingMap[widget.teacherProfile.teacherId!] = "N/A";
    if (_teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]!.isNotEmpty) {
      _dates = _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]!.keys.map((e) => format.parse(e)).toList();
      _dates.sort();

      DateTime _index = _dates.first.add(const Duration(days: 1));
      while (_index.millisecondsSinceEpoch <= DateTime.now().millisecondsSinceEpoch) {
        if (!_teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]!.keys.contains(format.format(_index))) {
          _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]![format.format(_index)] =
              _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]![format.format(_index.add(const Duration(days: -1)))] ?? 0.0;
        }
        _index = _index.add(const Duration(days: 1));
      }

      // debugPrint(
      //     "191: ${widget.teacherProfile.teacherId} - ${_teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]}");

      _dates = _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]!.keys.map((e) => format.parse(e)).toList();
      _dates.sort();

      _months = _dates.map((e) => DateTime(e.year, e.month)).toSet().toList();
      _months.sort();

      _teacherWiseAverageRatingMap[widget.teacherProfile.teacherId!] =
          (_teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]!.values.reduce((a, b) => a + b) /
                  _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]!.values.length)
              .toStringAsFixed(2);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Container loadTeachersGraphs(int teacherId) {
    if (_teacherWiseFilteredRatingKMap[teacherId]!.isEmpty) {
      return Container();
    } else {
      return Container(
        height: 300,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          color: Color(0xff232d37),
        ),
        padding: const EdgeInsets.only(
          right: 18.0,
          top: 24,
          bottom: 24,
        ),
        margin: const EdgeInsets.all(25),
        child: ListView(
          scrollDirection: Axis.horizontal,
          controller: _feedbackGraphController,
          reverse: !_isMonthWiseFeedback,
          children: [
            Container(
              width: (_isMonthWiseFeedback ? _months.length * 75.0 : _dates.length * 50.0),
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
              ),
              child: buildLineChart(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        actions: [
          buildRoleButtonForAppBar(context, widget.teacherProfile),
        ],
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : TeacherAppDrawer(
              teacherProfile: widget.teacherProfile,
            ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Average Rating:"),
                          Tooltip(
                            message: _teacherWiseAverageRatingMap[widget.teacherProfile.teacherId!]!,
                            child: RatingBarIndicator(
                              rating: double.tryParse(_teacherWiseAverageRatingMap[widget.teacherProfile.teacherId!]!) ?? 0.0,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemSize: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClayContainer(
                            depth: 15,
                            spread: 2,
                            emboss: !_isMonthWiseFeedback,
                            surfaceColor: _isMonthWiseFeedback ? clayContainerColor(context) : Colors.lightGreen.shade400,
                            parentColor: clayContainerColor(context),
                            borderRadius: 1000,
                            height: 30,
                            width: 30,
                            child: const Center(
                              child: Text(
                                "D",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Switch(
                            onChanged: (value) {
                              setState(() {
                                _isMonthWiseFeedback = value;
                              });
                            },
                            value: _isMonthWiseFeedback,
                          ),
                          ClayContainer(
                            depth: 15,
                            spread: 2,
                            emboss: _isMonthWiseFeedback,
                            surfaceColor: !_isMonthWiseFeedback ? clayContainerColor(context) : Colors.lightGreen.shade400,
                            parentColor: clayContainerColor(context),
                            borderRadius: 1000,
                            height: 30,
                            width: 30,
                            child: const Center(
                              child: Text(
                                "M",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] +
                  [
                    loadTeachersGraphs(widget.teacherProfile.teacherId!),
                  ],
            ),
    );
  }

  LineChart buildLineChart() {
    return LineChart(
      _isMonthWiseFeedback ? buildMonthlyLineChartData() : buildDailyLineChartData(),
      swapAnimationDuration: const Duration(milliseconds: 500), // Optional
      swapAnimationCurve: Curves.easeInOutSine, // Optional
    );
  }

  LineChartData buildDailyLineChartData() {
    List<String> xAxis = _dates.map((e) => DateFormat("dd\nMMM\nyyyy").format(e)).toList();
    List<MapEntry<double, double>> plottedPoints = _dates
        .map((e) =>
            MapEntry(_dates.indexOf(e).toDouble(), _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]![format.format(e)]!.toDouble()))
        .toList();
    return getLineChartData(xAxis, plottedPoints);
  }

  LineChartData buildMonthlyLineChartData() {
    List<MapEntry<double, double>> plottedPoints = [];
    for (var eachMonth in _months) {
      var x = _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]!
          .keys
          .map((eachDate) => format.parse(eachDate))
          .where((eachDate) => eachDate.year == eachMonth.year && eachDate.month == eachMonth.month)
          .map((eachDate) {
        return _teacherWiseFilteredRatingKMap[widget.teacherProfile.teacherId]![format.format(eachDate)] ?? 0;
      });
      double avg = x.reduce((a, b) => a + b) / x.length;
      plottedPoints.add(MapEntry(_months.indexOf(eachMonth).toDouble(), avg));
    }
    return getLineChartData(_months.map((e) => DateFormat("MMM\nyyyy").format(e)).toList(), plottedPoints);
  }

  LineChartData getLineChartData(List<String> xAxis, List<MapEntry<double, double>> plottedPoints) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: getYAxis(),
        leftTitles: getYAxis(),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff68737d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {
            if (value.round() == value && value < xAxis.length) {
              return xAxis[value.toInt()];
            }
            return '';
          },
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: xAxis.length.toDouble() - 1.0,
      minY: 0,
      maxY: 7,
      lineBarsData: [
        LineChartBarData(
          spots: plottedPoints.map((e) => FlSpot(e.key, (e.value * 100).toInt() / 100.0)).toList(),
          isCurved: false,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  SideTitles getYAxis() {
    return SideTitles(
      showTitles: true,
      interval: 1,
      getTextStyles: (context, value) => const TextStyle(
        color: Color(0xff67727d),
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      getTitles: (value) {
        switch (value.toInt()) {
          case 1:
            return '1';
          case 2:
            return '2';
          case 3:
            return '3';
          case 4:
            return '4';
          case 5:
            return '5';
        }
        return '';
      },
      reservedSize: 1,
      margin: 12,
    );
  }
}
