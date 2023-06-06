import 'dart:convert';
import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/academic_planner/views/events_finishing_today.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/local_clean_calender/flutter_clean_calendar.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerViewForAllTdsScreen extends StatefulWidget {
  const PlannerViewForAllTdsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<PlannerViewForAllTdsScreen> createState() => _PlannerViewForAllTdsScreenState();
}

class _PlannerViewForAllTdsScreenState extends State<PlannerViewForAllTdsScreen> {
  bool _isLoading = false;

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionPickerOpen = false;

  List<TeacherDealingSection> _tdsList = [];

  Map<int, List<PlannedBeanForTds>> tdsWisePlannerBeans = {};
  List<PlannerTimeSlot> plannerTimeSlots = [];
  Map<DateTime, List<CleanCalendarEvent>> eventMap = {};

  DateTime selectedDate = DateTime.now();
  final GlobalKey<CalendarState> calenderKey = GlobalKey<CalendarState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachersList = getTeachersResponse.teachers!;
        if (_teachersList.length == 1) {
          _selectedTeacher = _teachersList[0];
        } else {
          _teachersList.sort((a, b) => (a.teacherName ?? "-").compareTo((b.teacherName ?? "-")));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }

    GetTeacherDealingSectionsRequest getTeacherDealingSectionsRequest = GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(getTeacherDealingSectionsRequest);
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!.map((e) => e).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');
    GetSchoolWiseAcademicYearsResponse response = await getSchoolWiseAcademicYears(
      GetSchoolWiseAcademicYearsRequest(schoolId: widget.adminProfile.schoolId),
    );

    if (response.httpStatus == "OK" && response.responseStatus == "success") {
      List<AcademicYearBean> academicYears = response.academicYearBeanList?.whereNotNull().toList() ?? [];
      String? startDate;
      String? endDate;

      if (academicYears.isNotEmpty) {
        if (selectedAcademicYearId != null) {
          if (academicYears.any((e) => e.academicYearId == selectedAcademicYearId)) {
            startDate = academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearStartDate;
            endDate = academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearEndDate;
          } else {
            startDate = academicYears.last.academicYearStartDate;
            endDate = academicYears.last.academicYearEndDate;
          }
        } else {
          startDate = academicYears.last.academicYearStartDate;
          endDate = academicYears.last.academicYearEndDate;
        }
      }
      GetPlannerTimeSlotsRequest getPlannerTimeSlotsRequest = GetPlannerTimeSlotsRequest(
        schoolId: widget.adminProfile.schoolId,
        startDate: startDate,
        endDate: endDate,
      );
      GetPlannerTimeSlotsResponse getPlannerTimeSlotsResponse = await getPlannerTimeSlots(getPlannerTimeSlotsRequest);
      if (getPlannerTimeSlotsResponse.httpStatus == "OK" && getPlannerTimeSlotsResponse.responseStatus == "success") {
        setState(() {
          plannerTimeSlots = getPlannerTimeSlotsResponse.plannerTimeSlots!.map((e) => e!).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        return;
      }
      GetPlannerResponse getPlannerResponse = await getPlanner(GetPlannerRequest(
        schoolId: widget.adminProfile.schoolId,
        // academicYearId: TODO
      ));
      if (getPlannerResponse.httpStatus == "OK" && getPlannerResponse.responseStatus == "success") {
        setState(() {
          getPlannerResponse.plannerBeans!.map((e) => e!).map((e) {
            int? tdsId = e.tdsId;
            String rawJsonListString = e.plannerBeanJsonString ?? "[]";
            rawJsonListString = rawJsonListString.replaceAll('"[', '[').replaceAll(']"', ']').replaceAll('\\', '');
            List<dynamic> rawJsonList = jsonDecode(rawJsonListString);
            List<PlannedBeanForTds> x = [];
            for (var json in rawJsonList) {
              x.add(PlannedBeanForTds.fromJson(json));
            }
            return MapEntry(tdsId, x);
          }).forEach((entry) {
            int? tdsId = entry.key;
            List<PlannedBeanForTds> list = entry.value;
            if (tdsId != null) {
              tdsWisePlannerBeans[tdsId] = list.whereNotNull().toList();
            }
          });
        });
        updateSlotsForAllBeans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void updateSlotsForAllBeans() {
    List<Color> colors = generateRandomColors(tdsWisePlannerBeans.keys.length);
    for (int i = 0; i < tdsWisePlannerBeans.keys.length; i++) {
      int tdsId = tdsWisePlannerBeans.keys.elementAt(i);
      TeacherDealingSection tds = _tdsList.firstWhere((e) => e.tdsId == tdsId);
      List<PlannedBeanForTds> plannerBeans = tdsWisePlannerBeans[tdsId]!;
      if (plannerBeans.isEmpty) return;
      List<PlannerTimeSlot> plannerTimeSlotsDup = [...plannerTimeSlots.where((e) => e.tdsId == tdsId)];
      for (var plannerBean in plannerBeans) {
        if ((plannerBean.noOfSlots ?? 0) != 0) {
          plannerBean.plannerSlots = plannerTimeSlotsDup.sublist(0, plannerBean.noOfSlots!);
          plannerTimeSlotsDup.removeRange(0, plannerBean.noOfSlots!);
        }
      }
      for (PlannedBeanForTds plannerBean in plannerBeans) {
        for (PlannerTimeSlot plannerSlot in (plannerBean.plannerSlots ?? [])) {
          if (!eventMap.containsKey(convertYYYYMMDDFormatToDateTime(plannerSlot.date))) {
            eventMap[convertYYYYMMDDFormatToDateTime(plannerSlot.date)] = [];
          }
          eventMap[convertYYYYMMDDFormatToDateTime(plannerSlot.date)]!.add(CleanCalendarEvent(
            "${tds.sectionName ?? " - "} - ${tds.subjectName ?? " - "}\n${tds.teacherName ?? " - "}",
            description: "${plannerBean.title ?? " - "}\n${plannerBean.description ?? " - "}",
            startTime: plannerSlot.getStartTimeInDate(),
            endTime: plannerSlot.getEndTimeInDate(),
            color: colors[i],
            isDone: plannerBean.approvalStatus == "Approved",
            tds: tds,
          ));
        }
      }
    }
    setState(() => {});
  }

  List<Color> generateRandomColors(int count) {
    final List<Color> colors = [];
    final Random random = Random();

    while (colors.length < count) {
      final int red = random.nextInt(256);
      final int green = random.nextInt(256);
      final int blue = random.nextInt(256);
      final Color color = Color.fromARGB(255, red, green, blue);

      // Check if the color is a black or white shade
      final int luminance = (0.299 * red + 0.587 * green + 0.114 * blue).round();
      if (luminance > 64 && luminance < 192) {
        colors.add(color);
      }
    }

    return colors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planner"),
        actions: [
          if (!_isLoading)
            IconButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EventsFinishingTodayScreen(
                            date: DateTime.now(),
                            tdsWisePlannerBeans: tdsWisePlannerBeans,
                            tdsList: _tdsList,
                          );
                        },
                      ),
                    ),
                icon: const Icon(Icons.playlist_add_check)),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: _sectionPicker(),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 25,
                    ),
                    Expanded(
                      child: _teacherPicker(),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: calenderWidget(),
                  ),
                ),
              ],
            ),
    );
  }

  Map<DateTime, List<CleanCalendarEvent>> get loadingEvents =>
      eventMap.map((dateTime, events) => MapEntry(dateTime, events.where((eachEvent) => filteredTdsList.contains(eachEvent.tds)).toList()))
        ..removeWhere((dateTime, events) => events.isEmpty);

  Widget calenderWidget() {
    calenderKey.currentState?.reload(loadingEvents);
    return Calendar(
      key: calenderKey,
      initialDate: selectedDate,
      startOnMonday: true,
      weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      isExpandable: true,
      eventDoneColor: Colors.green,
      selectedColor: Colors.pink,
      todayColor: Colors.blue,
      eventColor: Colors.grey,
      locale: 'en_IN',
      todayButtonText: 'Today',
      isExpanded: true,
      expandableDateFormat: 'EEEE, dd. MMMM yyyy',
      dayOfWeekStyle: TextStyle(color: clayContainerTextColor(context), fontWeight: FontWeight.w800, fontSize: 11),
      onDateSelected: (DateTime? newDate) {
        if (newDate == null) return;
        setState(() => selectedDate = newDate);
      },
      onEventSelected: (CleanCalendarEvent? event) {
        if (event == null) return;
      },
      selectedDate: selectedDate,
      hideTodayIcon: true,
      sideBySide: MediaQuery.of(context).orientation == Orientation.landscape,
      events: eventMap,
    );
  }

  List<TeacherDealingSection> get filteredTdsList => _tdsList
      .where((e) =>
          (_selectedTeacher == null || _selectedTeacher?.teacherId == e.teacherId) &&
          (_selectedSection == null || _selectedSection?.sectionId == e.sectionId))
      .toList();

  Widget _teacherPicker() {
    return _buildSearchableTeacherDropdown();
  }

  ClayButton _buildSearchableTeacherDropdown() {
    return ClayButton(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      height: 60,
      width: 60,
      child: DropdownSearch<Teacher>(
        clearButton: IconButton(
          onPressed: () {
            setState(() => _selectedTeacher = null);
          },
          icon: const Icon(Icons.clear),
        ),
        enabled: true,
        mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
        selectedItem: _selectedTeacher,
        items: _teachersList,
        itemAsString: (Teacher? teacher) {
          return teacher == null ? "" : teacher.teacherName ?? "";
        },
        showSearchBox: true,
        dropdownBuilder: (BuildContext context, Teacher? teacher) {
          return _buildTeacherWidget(teacher ?? Teacher());
        },
        onChanged: (Teacher? teacher) {
          setState(() => _selectedTeacher = teacher);
        },
        showClearButton: true,
        compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
        dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
        filterFn: (Teacher? teacher, String? key) {
          return teacher!.teacherName!.toLowerCase().contains(key!.toLowerCase());
        },
      ),
    );
  }

  Widget _buildTeacherWidget(Teacher e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                e.teacherName ?? "Select a Teacher",
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(20),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget _buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          if (_selectedSection?.sectionId == section.sectionId) {
            setState(() => _selectedSection = null);
          } else {
            setState(() => _selectedSection = section);
          }
        },
        child: ClayButton(
          depth: 40,
          spread: _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
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
          GestureDetector(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
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
            children: _sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;
        setState(() => _isSectionPickerOpen = !_isSectionPickerOpen);
      },
      child: ClayButton(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        height: 60,
        width: 60,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    _selectedSection == null ? "Select a section" : "Sections: ${_selectedSection!.sectionName}",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
