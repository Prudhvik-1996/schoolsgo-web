import 'dart:convert';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/common_components/local_clean_calender/flutter_clean_calendar.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerCreationScreen extends StatefulWidget {
  const PlannerCreationScreen({
    Key? key,
    required this.adminProfile,
    required this.tds,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final TeacherDealingSection tds;

  @override
  State<PlannerCreationScreen> createState() => _PlannerCreationScreenState();
}

class _PlannerCreationScreenState extends State<PlannerCreationScreen> {
  bool _isLoading = false;
  bool _isEditMode = false;

  List<PlannedBeanForTds> plannerBeans = [];
  Map<int, List<PlannedBeanForTds>> tdsWisePlannerBeans = {};
  List<PlannerTimeSlot> plannerTimeSlots = [];
  int? currentlyEditedIndex;

  List<String> approvalStatusOptions = ["Pending", "Approved", "Revise"];
  DateTime selectedDate = DateTime.now();

  final ItemScrollController _plannerListController = ItemScrollController();
  Map<DateTime, List<CleanCalendarEvent>> eventMap = {};

  bool showCalenderInPortrait = false;
  final GlobalKey<CalendarState> calenderKey = GlobalKey<CalendarState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isEditMode = false;
    });
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
        tdsId: widget.tds.tdsId,
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
        tdsId: widget.tds.tdsId,
        teacherId: widget.tds.teacherId,
        subjectId: widget.tds.subjectId,
        sectionId: widget.tds.sectionId,
        schoolId: widget.adminProfile.schoolId,
        academicYearId: selectedAcademicYearId,
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
        plannerBeans = tdsWisePlannerBeans[widget.tds.tdsId] ?? [];
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
    setState(() => _isLoading = false);
    refreshScroll();
  }

  Future<void> saveChanges() async {
    setState(() => _isLoading = true);
    CreateOrUpdatePlannerResponse createOrUpdatePlannerResponse = await createOrUpdatePlanner(CreateOrUpdatePlannerRequest(
      tdsId: widget.tds.tdsId,
      teacherId: widget.tds.teacherId,
      subjectId: widget.tds.subjectId,
      sectionId: widget.tds.sectionId,
      schoolId: widget.adminProfile.schoolId,
      agent: widget.adminProfile.userId,
      plannerBeanJsonString: jsonEncode("[" + plannerBeans.map((e) => jsonEncode(e.toJson())).join(",") + "]"),
    ));
    if (createOrUpdatePlannerResponse.httpStatus == "OK" && createOrUpdatePlannerResponse.responseStatus == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your updates are successful.."),
        ),
      );
      await _loadData();
      setState(() => _isEditMode = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  void updateSlotsForAllBeans() {
    if (plannerBeans.isEmpty) return;
    List<PlannerTimeSlot> plannerTimeSlotsDup = [...plannerTimeSlots];
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
          plannerBean.title ?? "-",
          description: plannerBean.description ?? "-",
          startTime: plannerSlot.getStartTimeInDate(),
          endTime: plannerSlot.getEndTimeInDate(),
          color: Colors.indigo,
          isApproved: plannerBean.approvalStatus == "Approved",
        ));
      }
    }
    setState(() => {});
  }

  void refreshScroll({int? slotPositionIndex}) {
    int newIndex = plannerBeans.indexWhere((e) => (e.plannerSlots ?? [])
        .map((e) => e.getDate())
        .whereNotNull()
        .map((e) => convertDateTimeToDDMMYYYYFormat(e))
        .contains(convertDateTimeToDDMMYYYYFormat(selectedDate)));
    print("190: $newIndex");
    if (newIndex == -1) return;
    _plannerListController.scrollTo(
      index: newIndex,
      duration: const Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    );
    slotPositionIndex ??= (plannerBeans[newIndex].plannerSlots ?? []).indexWhere((e) => e.date == convertDateTimeToYYYYMMDDFormat(selectedDate));
    if (slotPositionIndex < 0) return;
    plannerBeans[newIndex].slotsController.animateTo(
          slotPositionIndex * 180,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.tds.sectionName} - ${widget.tds.subjectName} - ${widget.tds.teacherName}"),
        actions: [
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            IconButton(
                onPressed: () => setState(() => showCalenderInPortrait = !showCalenderInPortrait),
                icon: showCalenderInPortrait ? const Icon(Icons.splitscreen) : const Icon(Icons.calendar_month)),
          if (_isEditMode && !plannerBeans.map((e) => e.isEditMode).contains(true))
            IconButton(
              onPressed: () => saveChanges(),
              icon: const Icon(Icons.check),
            ),
          if (!_isEditMode)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              icon: const Icon(Icons.edit),
            ),
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
          : MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 400,
                      child: plannerCreationListWidget(),
                    ),
                    SizedBox(
                      width: 400,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: calenderWidget(),
                        ),
                      ),
                    ),
                  ],
                )
              : showCalenderInPortrait
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: calenderWidget(),
                      ),
                    )
                  : plannerCreationListWidget(),
      floatingActionButton: _isLoading || !_isEditMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  plannerBeans.add(PlannedBeanForTds()..isEditMode = true);
                  currentlyEditedIndex = plannerBeans.length - 1;
                });
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget calenderWidget() {
    return Calendar(
      key: calenderKey,
      initialDate: selectedDate,
      startOnMonday: true,
      weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      events: eventMap,
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
        refreshScroll();
      },
      onEventSelected: (CleanCalendarEvent? event) {
        if (event == null) return;
        refreshScroll(slotPositionIndex: eventMap[selectedDate]?.indexWhere((e) => e == event) ?? -1);
      },
      selectedDate: selectedDate,
      hideTodayIcon: true,
    );
  }

  Widget plannerCreationListWidget() {
    return ScrollablePositionedList.builder(
      itemScrollController: _plannerListController,
      itemCount: plannerBeans.length,
      itemBuilder: (context, index) {
        final plannerBean = plannerBeans[index];
        final slots = plannerBean.noOfSlots ?? 0;
        final assignedSlots = plannerBean.plannerSlots?.take(slots).toList() ?? [];
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: ClayContainer(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 10,
            emboss: true,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: plannerBean.isEditMode
                        ? TextFormField(
                            initialValue: plannerBean.title,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter title',
                            ),
                            onChanged: (value) {
                              setState(() {
                                plannerBean.title = value;
                              });
                            },
                          )
                        : Text(
                            '${plannerBean.title} (${plannerBean.startDate} - ${plannerBean.endDate})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        plannerBean.isEditMode
                            ? TextFormField(
                                initialValue: plannerBean.description,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  hintText: 'Enter description',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    plannerBean.description = value;
                                  });
                                },
                              )
                            : Text('Description: ${plannerBean.description}'),
                        plannerBean.isEditMode
                            ? TextFormField(
                                initialValue: plannerBean.noOfSlots?.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'No. of Slots',
                                  hintText: 'Enter number of slots',
                                ),
                                onChanged: (value) {
                                  final newSlots = int.tryParse(value);
                                  if (newSlots != null) {
                                    setState(() {
                                      plannerBean.noOfSlots = newSlots;
                                      updateSlotsForAllBeans();
                                    });
                                  }
                                },
                              )
                            : Text('No. of Slots: ${plannerBean.noOfSlots}'),
                        plannerBean.isEditMode
                            ? DropdownButtonFormField<String>(
                                value: plannerBean.approvalStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Approval Status',
                                ),
                                items: approvalStatusOptions.map((String status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    plannerBean.approvalStatus = value;
                                  });
                                },
                              )
                            : Text('Approval Status: ${plannerBean.approvalStatus}'),
                      ],
                    ),
                    trailing: !_isEditMode
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentlyEditedIndex == null)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      currentlyEditedIndex = index;
                                      plannerBean.isEditMode = true;
                                    });
                                  },
                                ),
                              if (currentlyEditedIndex == index)
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    if ((plannerBean.title?.trim() ?? "") == "") {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Title cannot be empty.."),
                                        ),
                                      );
                                      return;
                                    }
                                    if ((plannerBean.description?.trim() ?? "") == "") {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Description cannot be empty.."),
                                        ),
                                      );
                                      return;
                                    }
                                    if (plannerBean.noOfSlots == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Number of slots cannot be empty.."),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      currentlyEditedIndex = null;
                                      plannerBean.isEditMode = false;
                                    });
                                  },
                                ),
                              if (!plannerBean.isEditMode && currentlyEditedIndex == null)
                                IconButton(
                                  icon: const Icon(Icons.call_split),
                                  onPressed: () {
                                    splitSlots(plannerBean);
                                  },
                                ),
                              if (!plannerBean.isEditMode && currentlyEditedIndex == null)
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    addRowAbove(plannerBean);
                                  },
                                ),
                            ],
                          ),
                  ),
                  SizedBox(
                    height: 100,
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 8.0,
                      controller: plannerBean.slotsController,
                      child: SingleChildScrollView(
                        controller: plannerBean.slotsController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: assignedSlots
                              .map(
                                (e) => SizedBox(
                                  width: 180,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => selectedDate = convertYYYYMMDDFormatToDateTime(e.date));
                                      refreshScroll();
                                    },
                                    child: Card(
                                      color: e.date == convertDateTimeToYYYYMMDDFormat(selectedDate) ? Colors.blue : null,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${e.getDate() == null ? "-" : convertDateTimeToDDMMYYYYFormat(e.getDate()!)}\n${e.getStartTime() == null ? "-" : timeOfDayToString(e.getStartTime()!)} - ${e.getEndTime() == null ? "-" : timeOfDayToString(e.getEndTime()!)}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void splitSlots(PlannedBeanForTds plannerBean) {
    final slots = plannerBean.noOfSlots ?? 0;
    if (slots > 1) {
      final newSlots = (slots / 2).ceil();
      plannerBean.noOfSlots = slots - newSlots;
      final index = plannerBeans.indexOf(plannerBean);
      plannerBeans.insert(
        index,
        PlannedBeanForTds(
          title: plannerBean.title,
          description: plannerBean.description,
          noOfSlots: newSlots,
          approvalStatus: plannerBean.approvalStatus,
          comments: plannerBean.comments,
          plannerSlots: plannerBean.plannerSlots?.sublist(0, newSlots),
        ),
      );
      plannerBean.plannerSlots = plannerBean.plannerSlots?.sublist(newSlots);
      setState(() {});
    }
  }

  void addRowAbove(PlannedBeanForTds plannerBean) {
    final index = plannerBeans.indexOf(plannerBean);
    plannerBeans.insert(
      index,
      PlannedBeanForTds()..isEditMode = true,
    );
    currentlyEditedIndex = index;
    setState(() {});
  }
}
