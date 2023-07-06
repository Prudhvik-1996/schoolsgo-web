import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class EachPlanWidget extends StatefulWidget {
  const EachPlanWidget({
    Key? key,
    required this.index,
    required this.plannerBeans,
    required this.superSetState,
    required this.updateSlotsForAllBeans,
    required this.approvalStatusOptions,
    required this.isEditMode,
    required this.currentlyEditedIndex,
    required this.updateEditingIndex,
    required this.canSubmit,
    required this.splitSlots,
    required this.isRearrangeMode,
  }) : super(key: key);

  final int index;
  final List<PlannedBeanForTds> plannerBeans;
  final Function superSetState;
  final Function updateSlotsForAllBeans;
  final List<String> approvalStatusOptions;
  final bool isEditMode;
  final int? currentlyEditedIndex;
  final Function updateEditingIndex;
  final Function canSubmit;
  final Function splitSlots;
  final bool isRearrangeMode;

  @override
  State<EachPlanWidget> createState() => _EachPlanWidgetState();
}

class _EachPlanWidgetState extends State<EachPlanWidget> {
  late PlannedBeanForTds plannerBean;

  @override
  void initState() {
    super.initState();
    plannerBean = widget.plannerBeans[widget.index];
  }

  @override
  Widget build(BuildContext context) {
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
                title: buildTitleWidget(),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDescriptionWidget(),
                    buildNoOfSlotsWidget(),
                    buildApprovalStatusWidget(),
                  ],
                ),
                trailing: buildEditOptionsWidget(context),
              ),
              buildSlotsView(),
            ],
          ),
        ),
      ),
    );
  }

  Row? buildEditOptionsWidget(BuildContext context) {
    if (widget.isRearrangeMode) return null;
    return !widget.isEditMode
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.currentlyEditedIndex == null)
                plannerIconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    widget.superSetState(() {
                      widget.updateEditingIndex(widget.index);
                      plannerBean.isEditMode = true;
                    });
                  },
                  toolTip: "Edit",
                ),
              if (widget.currentlyEditedIndex == widget.index)
                plannerIconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (widget.currentlyEditedIndex != null) {
                        widget.superSetState(() {
                          widget.plannerBeans.removeAt(widget.currentlyEditedIndex!);
                          widget.updateEditingIndex(null);
                        });
                      }
                    },
                    toolTip: "Delete"),
              if (!plannerBean.isEditMode && widget.currentlyEditedIndex == null)
                plannerIconButton(
                  icon: const Icon(Icons.call_split),
                  onPressed: () {
                    widget.splitSlots(widget.index);
                  },
                  toolTip: "Split",
                ),
              if (widget.currentlyEditedIndex == widget.index)
                plannerIconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    String? errorMessage = widget.canSubmit(plannerBean);
                    if (errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                      return;
                    }
                    widget.superSetState(() {
                      widget.updateEditingIndex(null);
                      plannerBean.isEditMode = false;
                    });
                  },
                  toolTip: "Done",
                ),
            ],
          );
  }

  Widget buildApprovalStatusWidget() {
    return plannerBean.isEditMode
        ? DropdownButtonFormField<String>(
            value: plannerBean.approvalStatus,
            decoration: const InputDecoration(
              labelText: 'Approval Status',
            ),
            items: widget.approvalStatusOptions.map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (String? value) {
              widget.superSetState(() {
                plannerBean.approvalStatus = value;
              });
            },
          )
        : Text('Approval Status: ${plannerBean.approvalStatus}');
  }

  Widget buildNoOfSlotsWidget() {
    return plannerBean.isEditMode
        ? TextFormField(
            initialValue: plannerBean.noOfSlots?.toString(),
            decoration: const InputDecoration(
              labelText: 'No. of Slots',
              hintText: 'Enter number of slots',
            ),
            onChanged: (value) {
              final newSlots = int.tryParse(value);
              if (newSlots != null) {
                widget.superSetState(() {
                  plannerBean.noOfSlots = newSlots;
                  widget.updateSlotsForAllBeans();
                });
              }
            },
          )
        : Text('No. of Slots: ${plannerBean.noOfSlots}');
  }

  Widget buildDescriptionWidget() {
    return plannerBean.isEditMode
        ? TextFormField(
            initialValue: plannerBean.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter description',
            ),
            onChanged: (value) {
              widget.superSetState(() {
                plannerBean.description = value;
              });
            },
          )
        : Text('Description: ${plannerBean.description}');
  }

  Widget buildTitleWidget() {
    return plannerBean.isEditMode
        ? TextFormField(
            initialValue: plannerBean.title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter title',
            ),
            onChanged: (value) {
              widget.superSetState(() {
                plannerBean.title = value;
              });
            },
          )
        : Text(
            '${plannerBean.title} (${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(plannerBean.startDate))} - ${convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(plannerBean.endDate))})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
  }

  Widget buildSlotsView() {
    if ((plannerBean.plannerSlots ?? []).isEmpty) return Container();
    if (!plannerBean.isExpanded && !plannerBean.isEditMode) {
      return Row(
        children: [
          Expanded(child: timeslotsScrollView(plannerBean)),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () {
              widget.superSetState(() {
                plannerBean.isExpanded = true;
              });
            },
          ),
        ],
      );
    }
    if (plannerBean.isExpanded || plannerBean.isEditMode) return timeslotsGridView(plannerBean);
    return Container();
  }

  Widget plannerIconButton({Widget? icon, Function()? onPressed, String? toolTip}) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Tooltip(
        message: toolTip,
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
      ),
    );
  }

  Widget timeslotsScrollView(PlannedBeanForTds plannerBean) {
    final slots = plannerBean.noOfSlots ?? 0;
    final assignedSlots = plannerBean.plannerSlots?.take(slots).toList() ?? [];
    return SizedBox(
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
                        //  TODO
                      },
                      child: Card(
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
    );
  }

  Widget timeslotsGridView(PlannedBeanForTds plannerBean) {
    final int slots = plannerBean.noOfSlots ?? 0;
    final List<PlannerTimeSlot> assignedSlots = plannerBean.plannerSlots?.take(slots).toList() ?? [];
    Map<String, List<PlannerTimeSlot>> dateWiseSlotsMap = {};
    Map<String, ScrollController> dateWiseSlotsControllerMap = {};
    for (PlannerTimeSlot eachSlot in assignedSlots) {
      if (eachSlot.date == null) continue;
      String date = eachSlot.date!;
      if (!dateWiseSlotsMap.keys.contains(date)) {
        dateWiseSlotsMap[date] = [];
        dateWiseSlotsControllerMap[date] = ScrollController();
      }
      dateWiseSlotsMap[date]!.add(eachSlot);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: GestureDetector(
        onTap: () {
          widget.superSetState(() {
            plannerBean.isExpanded = false;
          });
        },
        child: ClayContainer(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          emboss: true,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...dateWiseSlotsMap.keys.map((eachDate) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Scrollbar(
                        thumbVisibility: true,
                        thickness: 8.0,
                        controller: dateWiseSlotsControllerMap[eachDate],
                        child: SingleChildScrollView(
                          controller: dateWiseSlotsControllerMap[eachDate],
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: dateWiseSlotsMap[eachDate]!.map((e) => startAndEndTimeChip(e)).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget startAndEndTimeChip(PlannerTimeSlot e) {
    return AbsorbPointer(
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: ClayContainer(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          emboss: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              Text(e.getDate() == null ? "-" : convertDateTimeToDDMMYYYYFormat(e.getDate()!)),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  timeChipWidget(DateFormat('hh:mm a').format(e.getStartTimeInDate()).toString()),
                  const SizedBox(width: 5),
                  timeChipWidget(DateFormat('hh:mm a').format(e.getEndTimeInDate()).toString()),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox timeChipWidget(String time) {
    return SizedBox(
      height: 40,
      width: 60,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ClayContainer(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 5,
          emboss: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(time, style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      ),
    );
  }
}
