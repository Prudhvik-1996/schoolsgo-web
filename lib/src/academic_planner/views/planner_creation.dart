import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/academic_planner/views/support_components/each_plan_widget.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
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
    required this.teacherProfile,
    required this.tds,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final TeacherDealingSection tds;

  @override
  State<PlannerCreationScreen> createState() => _PlannerCreationScreenState();
}

class _PlannerCreationScreenState extends State<PlannerCreationScreen> {
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isRearrangeMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<PlannedBeanForTds> plannerBeans = [];
  Map<int, List<PlannedBeanForTds>> tdsWisePlannerBeans = {};
  List<PlannerTimeSlot> plannerTimeSlots = [];
  int? currentlyEditedIndex;

  List<String> approvalStatusOptions = ["Approved", "Revise"];
  DateTime selectedDate = DateTime.now();

  final ItemScrollController _plannerListController = ItemScrollController();
  final ScrollController reorderablePlannerListController = ScrollController();
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
      GetSchoolWiseAcademicYearsRequest(
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      ),
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
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
        teacherId: widget.teacherProfile?.teacherId,
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
        schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
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
        await updateSlotsForAllBeans();
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
  }

  Future<void> saveChanges() async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Academic Planner'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                CreateOrUpdatePlannerResponse createOrUpdatePlannerResponse = await createOrUpdatePlanner(CreateOrUpdatePlannerRequest(
                  tdsId: widget.tds.tdsId,
                  teacherId: widget.tds.teacherId,
                  subjectId: widget.tds.subjectId,
                  sectionId: widget.tds.sectionId,
                  schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                  agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
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
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                Navigator.of(context).pop();
                _loadData();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateSlotsForAllBeans() async {
    if (plannerBeans.isEmpty) return;
    List<PlannerTimeSlot> plannerTimeSlotsDup = [...plannerTimeSlots];
    for (PlannedBeanForTds plannerBean in plannerBeans) {
      setState(() {
        plannerBean.plannerSlots = [];
      });
    }
    for (PlannedBeanForTds plannerBean in plannerBeans) {
      setState(() => plannerBean.slotsController = ScrollController());
      if ((plannerBean.noOfSlots ?? 0) != 0) {
        setState(() => plannerBean.plannerSlots = plannerTimeSlotsDup.sublist(0, plannerBean.noOfSlots!));
        plannerTimeSlotsDup.removeRange(0, plannerBean.noOfSlots!);
      }
    }
    for (PlannedBeanForTds plannerBean in plannerBeans) {
      for (PlannerTimeSlot plannerSlot in (plannerBean.plannerSlots ?? [])) {
        if (!eventMap.containsKey(convertYYYYMMDDFormatToDateTime(plannerSlot.date))) {
          setState(() => eventMap[convertYYYYMMDDFormatToDateTime(plannerSlot.date)] = []);
        }
        setState(() => eventMap[convertYYYYMMDDFormatToDateTime(plannerSlot.date)]!.add(CleanCalendarEvent(
              plannerBean.title ?? "-",
              description: plannerBean.description ?? "-",
              startTime: plannerSlot.getStartTimeInDate(),
              endTime: plannerSlot.getEndTimeInDate(),
              color: Colors.indigo,
              isApproved: plannerBean.approvalStatus == "Approved",
            )));
      }
    }
  }

  Future<void> refreshScroll({int? slotPositionIndex, DateTime? otherDate}) async {
    print("248: $slotPositionIndex");
    int newIndex = plannerBeans.indexWhere((e) => (e.plannerSlots ?? [])
        .map((e) => e.getDate())
        .whereNotNull()
        .map((e) => convertDateTimeToDDMMYYYYFormat(e))
        .contains(convertDateTimeToDDMMYYYYFormat(otherDate ?? selectedDate)));
    print("254: $newIndex");
    if (newIndex == -1) return;
    if (!_isRearrangeMode) {
      await _plannerListController.scrollTo(
        index: newIndex,
        duration: const Duration(milliseconds: 100),
        curve: Curves.bounceInOut,
      );
      slotPositionIndex ??= (plannerBeans[newIndex].plannerSlots ?? []).indexWhere((e) => e.date == convertDateTimeToYYYYMMDDFormat(selectedDate));
      if (slotPositionIndex < 0) return;
      await plannerBeans[newIndex].slotsController.animateTo(
            slotPositionIndex * 180,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("${widget.tds.sectionName} - ${widget.tds.subjectName} - ${widget.tds.teacherName}"),
        actions: [
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            IconButton(
                onPressed: () => setState(() => showCalenderInPortrait = !showCalenderInPortrait),
                icon: showCalenderInPortrait ? const Icon(Icons.splitscreen) : const Icon(Icons.calendar_month)),
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
                      child: _isRearrangeMode ? plannerCreationReOrderableListWidget() : plannerCreationListWidget(),
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
                  : _isRearrangeMode
                      ? plannerCreationReOrderableListWidget()
                      : plannerCreationListWidget(),
      floatingActionButton: _isLoading
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!(_isLoading || !_isEditMode || plannerBeans.map((e) => e.isEditMode).contains(true) || _isRearrangeMode))
                  fab(
                    const Icon(Icons.add),
                    "Add",
                    () {
                      setState(() {
                        plannerBeans.add(PlannedBeanForTds(approvalStatus: "Approved")..isEditMode = true);
                        currentlyEditedIndex = plannerBeans.length - 1;
                      });
                    },
                    postAction: () {
                      try {
                        if (plannerBeans.length > 2) {
                          if (!_isRearrangeMode) {
                            _plannerListController.scrollTo(
                              index: plannerBeans.length - 1,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.bounceInOut,
                            );
                          } else {
                            reorderablePlannerListController.animateTo(
                              reorderablePlannerListController.position.maxScrollExtent,
                              duration: const Duration(seconds: 2),
                              curve: Curves.fastOutSlowIn,
                            );
                          }
                        }
                      } on Exception catch (_, e) {
                        debugPrintStack(stackTrace: e);
                      }
                    },
                    color: Colors.blue[300],
                  ),
                if (_isEditMode && plannerBeans.isNotEmpty && !plannerBeans.map((e) => e.isEditMode).contains(true))
                  fab(const Icon(Icons.reorder), _isRearrangeMode ? "Done" : "Rearrange", () => setState(() => _isRearrangeMode = !_isRearrangeMode),
                      color: Colors.amber[300]),
                if (!_isRearrangeMode && _isEditMode && !plannerBeans.map((e) => e.isEditMode).contains(true))
                  fab(
                    const Icon(Icons.save),
                    "Save",
                    () => saveChanges(),
                    color: Colors.green[300],
                  ),
                if (!_isRearrangeMode && !_isEditMode)
                  fab(
                    const Icon(Icons.edit),
                    "Edit",
                    () => setState(() => _isEditMode = !_isEditMode),
                    color: Colors.green[300],
                  ),
              ],
            ),
    );
  }

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget calenderWidget() {
    calenderKey.currentState?.reload(eventMap);
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
      onDateSelected: (DateTime? newDate) async {
        if (newDate == null) return;
        setState(() => selectedDate = newDate);
        await refreshScroll();
      },
      onEventSelected: (CleanCalendarEvent? event) async {
        if (event == null) return;
        await refreshScroll(slotPositionIndex: eventMap[selectedDate]?.indexWhere((e) => e == event) ?? -1);
      },
      selectedDate: selectedDate,
      hideTodayIcon: true,
    );
  }

  String? canSubmit(PlannedBeanForTds plannerBean) {
    if ((plannerBean.title?.trim() ?? "") == "") {
      return "Title cannot be empty..";
    }
    if ((plannerBean.description?.trim() ?? "") == "") {
      return "Description cannot be empty..";
    }
    if (plannerBean.noOfSlots == null) {
      return "Number of slots cannot be empty..";
    }
    return null;
  }

  Widget plannerIconButton({Widget? icon, Function()? onPressed}) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onPressed,
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 100,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  Widget plannerCreationListWidget() {
    return ScrollablePositionedList.builder(
      itemScrollController: _plannerListController,
      itemCount: plannerBeans.length,
      itemBuilder: (context, index) {
        return eachPlanWidget(index);
      },
    );
  }

  Widget plannerCreationReOrderableListWidget() {
    return ReorderableListView(
      physics: const BouncingScrollPhysics(),
      scrollController: ScrollController(),
      onReorder: (int oldIndex, int newIndex) async {
        setState(() => _isLoading = true);
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final PlannedBeanForTds removedItem = plannerBeans.removeAt(oldIndex);
          plannerBeans.insert(newIndex, removedItem);
        });
        await updateSlotsForAllBeans();
        setState(() => _isLoading = false);
      },
      children: [for (int i = 0; i < plannerBeans.length; i++) eachPlanWidget(i)],
    );
  }

  Widget eachPlanWidget(int index) {
    return EachPlanWidget(
      key: Key(index.toString()),
      index: index,
      plannerBeans: plannerBeans,
      superSetState: setState,
      updateSlotsForAllBeans: updateSlotsForAllBeans,
      approvalStatusOptions: approvalStatusOptions,
      isEditMode: _isEditMode,
      currentlyEditedIndex: currentlyEditedIndex,
      updateEditingIndex: (int? newIndexToEdit) => setState(() => currentlyEditedIndex = newIndexToEdit),
      canSubmit: canSubmit,
      splitSlots: splitSlots,
      isRearrangeMode: _isRearrangeMode,
    );
  }

  void splitSlots(int index) {
    PlannedBeanForTds? newBean = plannerBeans[index].splitBean();
    if (newBean != null) {
      setState(() => _isLoading = true);
      setState(() {
        plannerBeans.insert(index + 1, newBean);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await updateSlotsForAllBeans();
        setState(() => _isLoading = false);
        await refreshScroll(
          otherDate: plannerBeans[index].plannerSlots?.firstOrNull?.getDate(),
        );
      });
    }
  }
}
