import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
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
  Map<int, List<PlannedBeanForTds>> tdsWiseEventsFinishingToday() {
    return widget.tdsWisePlannerBeans.map((tdsId, plannerBeans) {
      List<PlannedBeanForTds> x = [];
      for (PlannedBeanForTds eachPlannerBean in plannerBeans) {
        if (eachPlannerBean.plannerSlots?.last.date == convertDateTimeToYYYYMMDDFormat(widget.date)) {
          x.add(eachPlannerBean);
        }
      }
      return MapEntry(tdsId, x);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portion completing today"),
      ),
      body: ListView(
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
    );
  }
}
