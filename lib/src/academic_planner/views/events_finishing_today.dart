import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class EventsFinishingTodayScreen extends StatefulWidget {
  const EventsFinishingTodayScreen({
    Key? key,
    required this.date,
    required this.tdsWisePlannerBeans,
    required this.tdsList,
  }) : super(key: key);

  final DateTime date;
  final Map<int, List<PlannedBeanForTds>> tdsWisePlannerBeans;
  final List<TeacherDealingSection> tdsList;

  @override
  State<EventsFinishingTodayScreen> createState() => _EventsFinishingTodayScreenState();
}

class _EventsFinishingTodayScreenState extends State<EventsFinishingTodayScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
  }

  Map<int, List<PlannedBeanForTds>> tdsWiseEventsFinishingToday() {
    return widget.tdsWisePlannerBeans.map((tdsId, plannerBeans) {
      List<PlannedBeanForTds> x = [];
      for (PlannedBeanForTds eachPlannerBean in plannerBeans) {
        List<PlannerTimeSlot> plannerSlots = (eachPlannerBean.plannerSlots ?? []);
        plannerSlots.sort((a1, a2) => convertYYYYMMDDFormatToDateTime(a1.date).compareTo(convertYYYYMMDDFormatToDateTime(a2.date)));
        PlannerTimeSlot? lastSlot = plannerSlots.isNotEmpty ? plannerSlots.last : null;
        if (lastSlot != null && lastSlot.date == convertDateTimeToYYYYMMDDFormat(selectedDate)) {
          print("33: $eachPlannerBean :: ${lastSlot.date} ${convertDateTimeToYYYYMMDDFormat(selectedDate)}");
          x.add(eachPlannerBean);
        }
      }
      return MapEntry(tdsId, x);
    })
      ..removeWhere((key, value) => value.isEmpty);
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now(),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            selectedDate = _newDate;
          });
        },
        child: ClayButton(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          height: 60,
          width: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, // mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    convertDateTimeToDDMMYYYYFormat(selectedDate),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLeftArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Previous Day",
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 1));
            });
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_left),
          ),
        ),
      ),
    );
  }

  Widget _getRightArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Next Day",
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = selectedDate.add(const Duration(days: 1));
            });
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_right),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portion completing today"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 10),
              _getLeftArrow(),
              const SizedBox(width: 10),
              Expanded(child: _getDatePicker()),
              const SizedBox(width: 10),
              _getRightArrow(),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: tdsWiseEventsFinishingToday().isEmpty
                ? const Center(child: Text("Nothing to show here.."))
                : ListView(
                    children: tdsWiseEventsFinishingToday().keys.map((tdsId) {
                      TeacherDealingSection tds = widget.tdsList.where((e) => e.tdsId == tdsId).first;
                      return Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(tds.sectionName ?? "-"),
                                      const SizedBox(height: 10),
                                      Text(tds.subjectName ?? "-"),
                                      const SizedBox(height: 10),
                                      Text(tds.teacherName ?? "-"),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: tdsWiseEventsFinishingToday()[tdsId]
                                            ?.map((eachPlannerBean) => Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    Text("${eachPlannerBean.title}"),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        const CustomVerticalDivider(),
                                                        const SizedBox(width: 10),
                                                        Text("${eachPlannerBean.description}"),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
                                                ))
                                            .toList() ??
                                        [],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
