import 'package:clay_containers/widgets/clay_container.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/feedback/model/feedback.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/feedback";

  @override
  _AdminFeedbackScreenState createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  bool _isLoading = true;

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    // const Color(0xff02d39a),
  ];

  bool _isMonthWiseFeedback = false;

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;
  // teacherId, isExpanded
  final Map<int, bool> _isTeacherExpandedMap = {};

  List<TeacherDealingSection> _tdsList = [];

  List<StudentToTeacherFeedback> _feedbackBeans = [];

  // teacherId, dateString, rating
  final Map<int, Map<String, double>> _teacherWiseRatingKMap = {};

  // tdsId, dateString, rating
  final Map<int, Map<String, double>> _tdsWiseRatingKMap = {};

  final Map<int, String> _teacherWiseAverageRatingMap = {};
  final Map<int, String> _tdsWiseAverageRatingMap = {};

  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  DateFormat monthFormat = DateFormat("MMM\nyyyy");

  bool _isSectionPickerOpen = false;
  List<Section> _sectionsList = [];
  Section? _selectedSection;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Get all teachers data
    GetTeachersResponse getTeachersResponse = await getTeachers(
      GetTeachersRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachersList = getTeachersResponse.teachers!;
        for (var eachTeacher in _teachersList) {
          _isTeacherExpandedMap[eachTeacher.teacherId!] = false;
        }
      });
    }

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

    // Get all TDS
    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(
      GetTeacherDealingSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }

    // Get all teachers feedback
    GetStudentToTeacherFeedbackResponse getStudentToTeacherFeedbackResponse = await getStudentToTeacherFeedback(
      GetStudentToTeacherFeedbackRequest(
        schoolId: widget.adminProfile.schoolId,
        teacherWiseAverageRating: true,
        adminView: true,
      ),
    );
    if (getStudentToTeacherFeedbackResponse.httpStatus == "OK" && getStudentToTeacherFeedbackResponse.responseStatus == "success") {
      setState(() {
        _feedbackBeans = getStudentToTeacherFeedbackResponse.feedbackBeans!.map((e) => e!).where((e) => e.feedbackId != null).toList();
      });
    }

    // teacherId, dateString, feedbackBean
    Map<int, Map<String, List<StudentToTeacherFeedback>>> _teacherWiseFeedbackMap = {};

    for (var eachTeacher in _teachersList) {
      _teacherWiseFeedbackMap[eachTeacher.teacherId!] = {};
      for (var eachFeedbackBean in _feedbackBeans) {
        if (eachFeedbackBean.teacherId == eachTeacher.teacherId) {
          String dateString = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(eachFeedbackBean.createTime!));
          if (_teacherWiseFeedbackMap[eachFeedbackBean.teacherId]!.containsKey(dateString)) {
            _teacherWiseFeedbackMap[eachFeedbackBean.teacherId]![dateString]?.add(eachFeedbackBean);
          } else {
            _teacherWiseFeedbackMap[eachFeedbackBean.teacherId]![dateString] ??= [eachFeedbackBean];
          }
        }
      }

      _teacherWiseAverageRatingMap[eachTeacher.teacherId!] = "N/A";

      _teacherWiseRatingKMap[eachTeacher.teacherId!] = _teacherWiseFeedbackMap[eachTeacher.teacherId]!.map((dateString, feedbackBeans) {
        double avgRating = feedbackBeans.map((e) => (e.rating ?? 0).toDouble()).reduce((a, b) => (a + b));
        return MapEntry(dateString, avgRating / feedbackBeans.length);
      });

      List<DateTime> _dates = _teacherWiseRatingKMap[eachTeacher.teacherId!]!.keys.map((eachDateString) => dateFormat.parse(eachDateString)).toList();
      _dates.sort();

      if (_dates.isEmpty) continue;

      DateTime _index = _dates.first.add(const Duration(days: 1));
      while (_index.millisecondsSinceEpoch <= DateTime.now().millisecondsSinceEpoch) {
        if (!_teacherWiseRatingKMap[eachTeacher.teacherId]!.keys.contains(dateFormat.format(_index))) {
          _teacherWiseRatingKMap[eachTeacher.teacherId]![dateFormat.format(_index)] =
              _teacherWiseRatingKMap[eachTeacher.teacherId]![dateFormat.format(_index.add(const Duration(days: -1)))] ?? 0.0;
        }
        _index = _index.add(const Duration(days: 1));
      }
      print("152: ${eachTeacher.teacherId}: ${_teacherWiseRatingKMap[eachTeacher.teacherId!]}");

      _teacherWiseAverageRatingMap[eachTeacher.teacherId!] = (_teacherWiseRatingKMap[eachTeacher.teacherId]!.values.reduce((a, b) => a + b) /
              _teacherWiseRatingKMap[eachTeacher.teacherId]!.values.length)
          .toStringAsFixed(2);
    }

    // tdsId, dateString, feedbackBean
    Map<int, Map<String, List<StudentToTeacherFeedback>>> _tdsWiseFeedbackMap = {};

    for (var eachTds in _tdsList) {
      try {
        _tdsWiseFeedbackMap[eachTds.tdsId!] = {};
        for (var eachFeedbackBean in _feedbackBeans) {
          if (eachFeedbackBean.tdsId == eachTds.tdsId) {
            String dateString = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(eachFeedbackBean.createTime!));
            if (_tdsWiseFeedbackMap[eachFeedbackBean.tdsId]!.containsKey(dateString)) {
              _tdsWiseFeedbackMap[eachFeedbackBean.tdsId]![dateString]!.add(eachFeedbackBean);
            } else {
              _tdsWiseFeedbackMap[eachFeedbackBean.tdsId]![dateString] = [eachFeedbackBean];
            }
          }
        }

        _tdsWiseRatingKMap[eachTds.tdsId!] = _tdsWiseFeedbackMap[eachTds.tdsId]!.map((dateString, feedbackBeans) {
          double avgRating = feedbackBeans.map((e) => e.rating!.toDouble()).reduce((a, b) => (a + b));
          return MapEntry(dateString, avgRating / feedbackBeans.length);
        });

        _tdsWiseAverageRatingMap[eachTds.tdsId!] = "N/A";

        List<DateTime> _dates = _tdsWiseRatingKMap[eachTds.tdsId!]!.keys.map((eachDateString) => dateFormat.parse(eachDateString)).toList();
        _dates.sort();

        if (_dates.isEmpty) continue;

        DateTime _index = _dates.first.add(const Duration(days: 1));
        while (_index.millisecondsSinceEpoch <= DateTime.now().millisecondsSinceEpoch) {
          if (!_tdsWiseRatingKMap[eachTds.tdsId]!.keys.contains(dateFormat.format(_index))) {
            _tdsWiseRatingKMap[eachTds.tdsId]![dateFormat.format(_index)] =
                _tdsWiseRatingKMap[eachTds.tdsId]![dateFormat.format(_index.add(const Duration(days: -1)))] ?? 0.0;
          }
          _index = _index.add(const Duration(days: 1));
        }
        print("207: ${eachTds.tdsId}: ${_tdsWiseRatingKMap[eachTds.tdsId!]}");

        _tdsWiseAverageRatingMap[eachTds.tdsId!] =
            (_tdsWiseRatingKMap[eachTds.tdsId]!.values.reduce((a, b) => a + b) / _tdsWiseRatingKMap[eachTds.tdsId]!.values.length).toStringAsFixed(2);

        print("212: ${eachTds.tdsId}: ${_tdsWiseAverageRatingMap[eachTds.tdsId!]}");
      } catch (e) {
        print("217: $e");
      }
    }

    print("TDS wise avg feedback: $_tdsWiseAverageRatingMap");

    setState(() {
      _isLoading = false;
    });
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
                _selectedSection == null ? "Select a Section" : "Sections:",
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
                child: Center(
                  child: Text(
                    _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName!}",
                  ),
                ),
              ),
              if (_selectedSection != null)
                InkWell(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    setState(() {
                      _selectedSection = null;
                    });
                  },
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          if (_isLoading) return;
          setState(() {
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
            _isSectionPickerOpen = false;
          });
          _applyFilters();
        },
        child: ClayButton(
          depth: 40,
          color: _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? Colors.blue[200] : clayContainerColor(context),
          spread: _selectedSection != null && _selectedSection!.sectionId == section.sectionId! ? 0 : 2,
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

  DropdownButton<Teacher> dropdownButtonForTeacher() {
    return DropdownButton(
      hint: const Center(child: Text("Select Teacher")),
      underline: Container(),
      isExpanded: true,
      value: _selectedTeacher,
      onChanged: (Teacher? teacher) {
        setState(() {
          _selectedTeacher = teacher!;
          _isTeacherExpandedMap[_selectedTeacher!.teacherId!] = true;
          _selectedSection = null;
        });
        _applyFilters();
      },
      items: _teachersList
          // .where((teacher) => _filteredTdsList
          // .map((tds) => tds.teacherId)
          // .contains(teacher.teacherId))
          .map(
            (e) => DropdownMenuItem<Teacher>(
              value: e,
              child: buildTeacherWidget(e),
            ),
          )
          .toList(),
    );
  }

  Widget buildTeacherWidget(Teacher e) {
    return SizedBox(
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            e.teacherName ?? "Select a Teacher",
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectTeacher() {
    return Container(
      margin: const EdgeInsets.all(25),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: searchableDropdownButtonForTeacher(),
      ),
    );
  }

  DropdownSearch<Teacher> searchableDropdownButtonForTeacher() {
    return DropdownSearch<Teacher>(
      mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
      selectedItem: _selectedTeacher,
      items: _teachersList,
      itemAsString: (Teacher? teacher) {
        return teacher == null ? "" : teacher.teacherName ?? "";
      },
      showSearchBox: true,
      dropdownBuilder: (BuildContext context, Teacher? teacher) {
        return buildTeacherWidget(teacher ?? Teacher());
      },
      onChanged: (Teacher? teacher) {
        setState(() {
          _selectedTeacher = teacher;
          if (teacher != null) {
            _isTeacherExpandedMap[teacher.teacherId!] = true;
          }
        });
      },
      showClearButton: true,
      compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
      dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
      filterFn: (Teacher? teacher, String? key) {
        return teacher!.teacherName!.toLowerCase().contains(key!.toLowerCase());
      },
    );
  }

  void _applyFilters() {}

  Widget buildChart(Teacher? teacher, TeacherDealingSection? tds, String? leftTopHeader, String? rightTopHeader) {
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
      margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
      child: Stack(
        children: [
          ((teacher != null && teacher.teacherId != null && _teacherWiseRatingKMap[teacher.teacherId]!.keys.isNotEmpty) ||
                  (tds != null && tds.tdsId != null && _tdsWiseRatingKMap[tds.tdsId]!.keys.isNotEmpty))
              ? const Center(
                  child: Text(
                    "N/A",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: !_isMonthWiseFeedback,
                  children: [
                    Container(
                      width: (_isMonthWiseFeedback
                              ? (tds != null
                                  ? _tdsWiseRatingKMap[tds.tdsId]!
                                      .keys
                                      .map((e) => dateFormat.parse(e))
                                      .map((e) => monthFormat.format(e))
                                      .toSet()
                                      .length
                                  : _teacherWiseRatingKMap[teacher!.teacherId]!
                                      .keys
                                      .map((e) => dateFormat.parse(e))
                                      .map((e) => monthFormat.format(e))
                                      .toSet()
                                      .length)
                              : (tds != null
                                  ? _tdsWiseRatingKMap[tds.tdsId]!.keys.length
                                  : _teacherWiseRatingKMap[teacher!.teacherId]!.keys.length)) *
                          (_isMonthWiseFeedback ? 75.0 : 50.0),
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                      ),
                      child: tds != null ? buildLineChart(null, tds.tdsId) : buildLineChart(teacher!.teacherId, null),
                    ),
                  ],
                ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Text(
                rightTopHeader ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Text(
                leftTopHeader ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLineChart(int? teacherId, int? tdsId) {
    return LineChart(
      _isMonthWiseFeedback ? buildMonthlyLineChartData(teacherId, tdsId) : buildDailyLineChartData(teacherId, tdsId),
      swapAnimationDuration: const Duration(milliseconds: 500), // Optional
      swapAnimationCurve: Curves.easeInOutSine, // Optional
    );
  }

  LineChartData buildMonthlyLineChartData(int? teacherId, int? tdsId) {
    List<DateTime> _months = [];
    if (teacherId != null) {
      _months = _teacherWiseRatingKMap[teacherId]!.keys.map((e) => dateFormat.parse(e)).map((e) => DateTime(e.year, e.month, 1)).toSet().toList();
    } else if (tdsId != null) {
      _months = _tdsWiseRatingKMap[tdsId]!.keys.map((e) => dateFormat.parse(e)).map((e) => DateTime(e.year, e.month, 1)).toSet().toList();
    }
    _months.sort();

    List<String> xAxis = _months.map((e) => DateFormat("MMM\nyyyy").format(e)).toList();

    List<MapEntry<double, double>> plottedPoints = [];
    if (teacherId != null) {
      for (var eachMonth in _months) {
        var x = _teacherWiseRatingKMap[teacherId]!
            .keys
            .map((eachDate) => dateFormat.parse(eachDate))
            .where((eachDate) => eachDate.year == eachMonth.year && eachDate.month == eachMonth.month)
            .map((eachDate) {
          return _teacherWiseRatingKMap[teacherId]![dateFormat.format(eachDate)] ?? 0;
        });
        double avg = x.reduce((a, b) => a + b) / x.length;
        plottedPoints.add(MapEntry(_months.indexOf(eachMonth).toDouble(), avg));
      }
    } else if (tdsId != null) {
      for (var eachMonth in _months) {
        var x = _tdsWiseRatingKMap[tdsId]!
            .keys
            .map((eachDate) => dateFormat.parse(eachDate))
            .where((eachDate) => eachDate.year == eachMonth.year && eachDate.month == eachMonth.month)
            .map((eachDate) {
          return _tdsWiseRatingKMap[tdsId]![dateFormat.format(eachDate)] ?? 0;
        });
        double avg = x.reduce((a, b) => a + b) / x.length;
        plottedPoints.add(MapEntry(_months.indexOf(eachMonth).toDouble(), avg));
      }
    }

    return getLineChartData(xAxis, plottedPoints);
  }

  LineChartData buildDailyLineChartData(int? teacherId, int? tdsId) {
    List<DateTime> _dates = [];
    if (teacherId != null) {
      _dates = _teacherWiseRatingKMap[teacherId]!.keys.map((e) => dateFormat.parse(e)).toList();
    } else if (tdsId != null) {
      _dates = _tdsWiseRatingKMap[tdsId]!.keys.map((e) => dateFormat.parse(e)).toList();
    }
    _dates.sort();
    List<String> xAxis = _dates.map((e) => DateFormat("dd\nMMM\nyyyy").format(e)).toList();
    List<MapEntry<double, double>> plottedPoints = _dates
        .map((e) => MapEntry(
            _dates.indexOf(e).toDouble(),
            teacherId != null
                ? _teacherWiseRatingKMap[teacherId]![dateFormat.format(e)]!.toDouble()
                : _tdsWiseRatingKMap[tdsId!]![dateFormat.format(e)]!.toDouble()))
        .toList();
    return getLineChartData(xAxis, plottedPoints);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.adminProfile,
          ),
        ],
      ),
      drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              children: <Widget>[
                    if (MediaQuery.of(context).orientation == Orientation.landscape)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_selectedTeacher == null) Expanded(child: _sectionPicker()),
                          if (_selectedSection == null && !_isSectionPickerOpen) Expanded(child: _selectTeacher()),
                          if (!_isSectionPickerOpen) _buildMonthlySwitch()
                        ],
                      ),
                    if (MediaQuery.of(context).orientation == Orientation.portrait && _selectedTeacher == null) _sectionPicker(),
                    if (MediaQuery.of(context).orientation == Orientation.portrait && _selectedSection == null && !_isSectionPickerOpen)
                      _selectTeacher(),
                    if (MediaQuery.of(context).orientation == Orientation.portrait && !_isSectionPickerOpen) _buildMonthlySwitch(),
                  ] +
                  // (_selectedSection == null ? [] : [])+
                  buildGraphs(),
            ),
    );
  }

  Widget _buildMonthlySwitch() {
    return Container(
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
    );
  }

  List<Widget> buildGraphs() {
    if (_selectedSection != null) {
      return _tdsList
          .where((eachTds) => eachTds.sectionId == _selectedSection!.sectionId!)
          .map(
            (e) => Container(
              margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: buildChart(
                  null, e, (e.sectionName ?? "").capitalize(), "${(e.teacherName ?? "").capitalize()}\n ${(e.subjectName ?? "").capitalize()}"),
            ),
          )
          .toList();
    } else if (_selectedTeacher != null) {
      return [buildTeacherWiseWidget(_selectedTeacher!)];
    }
    return _teachersList.map((eachTeacher) => buildTeacherWiseWidget(eachTeacher)).toList();
  }

  Widget buildTeacherWiseWidget(Teacher teacher) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isTeacherExpandedMap[teacher.teacherId!] = !_isTeacherExpandedMap[teacher.teacherId!]!;
            });
          },
          child: ClayButton(
            depth: 40,
            color: clayContainerColor(context),
            spread: 2,
            borderRadius: 10,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _isTeacherExpandedMap[teacher.teacherId!]!
                  ? Column(
                      children: [
                            buildTeacherStatsRow(teacher),
                            buildChart(teacher, null, (teacher.teacherName ?? "").capitalize(), ""),
                          ] +
                          _tdsList
                              .where((eachTds) => eachTds.teacherId == teacher.teacherId)
                              .map((e) => buildChart(null, e, (e.sectionName ?? "").capitalize(),
                                  "${(e.teacherName ?? "").capitalize()}\n ${(e.subjectName ?? "").capitalize()}"))
                              .toList(),
                    )
                  : buildTeacherStatsRow(teacher),
            ),
          ),
        ),
      ),
    );
  }

  Row buildTeacherStatsRow(Teacher teacher) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text("${teacher.teacherName}")),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Tooltip(
            message: "Over all rating: ${_teacherWiseAverageRatingMap[teacher.teacherId!]!}",
            child: RatingBarIndicator(
              rating: double.tryParse(_teacherWiseAverageRatingMap[teacher.teacherId!]!) ?? 0.0,
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
        ),
      ],
    );
  }
}
