import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/views/support_components/each_plan_widget.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class PlannerListForEachTds extends StatefulWidget {
  const PlannerListForEachTds({
    Key? key,
    required this.adminProfile,
    required this.tds,
    required this.width,
    required this.scrollController,
    required this.plannerBeans,
    this.actionOnAdd,
    this.actionOnEdit,
    required this.updateSlotsForAllBeans,
    required this.canSubmit,
    required this.onReorder,
    required this.superSetState,
    required this.isEditMode,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final TeacherDealingSection tds;
  final double width;
  final ScrollController scrollController;
  final List<PlannedBeanForTds> plannerBeans;
  final Function? actionOnAdd;
  final Function? actionOnEdit;
  final Function updateSlotsForAllBeans;
  final Function canSubmit;
  final Function onReorder;
  final Function superSetState;
  final bool isEditMode;

  @override
  State<PlannerListForEachTds> createState() => _PlannerListForEachTdsState();
}

class _PlannerListForEachTdsState extends State<PlannerListForEachTds> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SizedBox(
            width: widget.width,
            child: Image.asset(
              'assets/images/gear-loader.gif',
              fit: BoxFit.scaleDown,
            ),
          )
        : SizedBox(
            width: widget.width,
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: buildReorderableListView(),
            ),
          );
  }

  ReorderableListView buildReorderableListView() {
    return ReorderableListView(
      buildDefaultDragHandles: widget.isEditMode,
      physics: const BouncingScrollPhysics(),
      scrollController: ScrollController(),
      onReorder: (int oldIndex, int newIndex) async {
        setState(() {
          _isLoading = true;
        });
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        widget.superSetState(() {
          final PlannedBeanForTds removedItem = widget.plannerBeans.removeAt(oldIndex);
          widget.plannerBeans.insert(newIndex, removedItem);
        });
        await widget.onReorder(widget.tds.tdsId, widget.plannerBeans);
        await widget.updateSlotsForAllBeans();
        setState(() {
          _isLoading = false;
        });
      },
      children: [
        for (int index = 0; index < widget.plannerBeans.length; index++)
          EachPlanWidget(
            key: Key(index.toString()),
            index: index,
            plannerBeans: widget.plannerBeans,
            superSetState: widget.superSetState,
            updateSlotsForAllBeans: widget.updateSlotsForAllBeans,
            approvalStatusOptions: const ["Approved", "Revise"],
            isEditMode: false,
            currentlyEditedIndex: null,
            updateEditingIndex: null,
            canSubmit: widget.canSubmit,
            splitSlots: null,
            isRearrangeMode: widget.isEditMode,
          ),
      ],
    );
  }
}
