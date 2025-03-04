import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/generate_memos/generate_memos.dart';
import 'package:schoolsgo_web/src/exams/admin/populate_inter_exam_marks/populate_internal_exam_marks.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class PopulateInternalExamMarksWidget extends StatefulWidget {
  const PopulateInternalExamMarksWidget({
    super.key,
    required this.faExam,
    required this.adminProfile,
    required this.loadData,
    required this.selectedSectionId,
    required this.scaffoldKey,
  });

  final FAExam faExam;
  final AdminProfile adminProfile;
  final void Function() loadData;
  final int selectedSectionId;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<PopulateInternalExamMarksWidget> createState() => _PopulateInternalExamMarksWidgetState();
}

class _PopulateInternalExamMarksWidgetState extends State<PopulateInternalExamMarksWidget> {
  bool _isLoading = true;
  List<CustomExam> otherExams = [];
  int? selectedInternalExamId;
  List<int> selectedOtherExamIds = [];
  String computingStrategy = "A";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetCustomExamsResponse getCustomExamsResponse = await getAllExams(GetCustomExamsRequest(
      schoolId: widget.adminProfile.schoolId,
      sectionId: widget.selectedSectionId,
    ));
    if (getCustomExamsResponse.httpStatus == "OK" && getCustomExamsResponse.responseStatus == "success") {
      otherExams = getCustomExamsResponse.customExamsList!.map((e) => e!).toList();
      otherExams.removeWhere((e) => e.customExamId == widget.faExam.faExamId);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const EpsilonDiaryLoadingWidget(
        defaultLoadingText: "Populating your data",
      );
    }
    return ListView(
      children: [
        buildDropdownToChooseFaInternalExam(),
        if (selectedInternalExamId != null) buildOtherExamsPicker(),
        if (selectedInternalExamId != null && selectedOtherExamIds.isNotEmpty) buildComputingStrategyPicker(),
        if (selectedInternalExamId != null && selectedOtherExamIds.isNotEmpty) buildProceedButton(),
      ],
    );
  }

  Widget buildProceedButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GestureDetector(
        onTap: () async {
          showDialog(
            context: widget.scaffoldKey.currentContext!,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Populate Internal Exam Marks'),
                content: const Text(
                    "**Warning:** Proceeding will override any previously made changes to the marks. Please review carefully and ensure you fully understand the implications before continuing."),
                actions: <Widget>[
                  TextButton(
                    child: const Text("YES"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      setState(() => _isLoading = true);
                      GetCustomExamsResponse populateExamMarksAsPerOtherExamsResponse =
                          await populateExamMarksAsPerOtherExams(PopulateInternalExamMarksRequest(
                        schoolId: widget.adminProfile.schoolId,
                        sectionId: widget.selectedSectionId,
                        agent: widget.adminProfile.userId,
                        masterExamId: widget.faExam.faExamId,
                        computingStrategy: computingStrategy,
                        internalExamId: selectedInternalExamId,
                        otherExamIds: selectedOtherExamIds,
                        roundingStrategy: null,
                      ));
                      setState(() => _isLoading = false);
                      if (populateExamMarksAsPerOtherExamsResponse.httpStatus != "OK" ||
                          populateExamMarksAsPerOtherExamsResponse.responseStatus != "success") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong! Try again later.."),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Marks populated successfully, please wait while we load your data.."),
                          ),
                        );
                        widget.loadData();
                      }
                    },
                  ),
                  TextButton(
                    child: const Text("No"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: ClayButton(
          surfaceColor: Colors.green,
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.check),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Proceed to populate"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildComputingStrategyPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          const Text("Select computing style:"),
          ...["A", "M"].map(
            (e) => RadioListTile<String?>(
              value: e,
              groupValue: computingStrategy,
              onChanged: (newValue) {
                if (newValue == null) return;
                setState(() => computingStrategy = newValue);
              },
              title: Text(e == "A" ? "Average" : "Maximum"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOtherExamsPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text("Select exams to compute from:"),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownSearch<CustomExam?>(
                  mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                  selectedItem: null,
                  items: otherExams.where((e) => !selectedOtherExamIds.contains(e.customExamId)).toList(),
                  itemAsString: (CustomExam? exam) {
                    return exam?.customExamName ?? "-";
                  },
                  showSearchBox: true,
                  dropdownBuilder: (BuildContext context, CustomExam? exam) {
                    return Text(exam?.customExamName ?? "-");
                  },
                  onChanged: (CustomExam? exam) {
                    if (exam?.customExamId == null) return;
                    setState(() => selectedOtherExamIds.add(exam!.customExamId!));
                  },
                  compareFn: (item, selectedItem) => item?.customExamId == selectedItem?.customExamId,
                  dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                  filterFn: (CustomExam? exam, String? key) {
                    return (exam?.customExamName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (selectedOtherExamIds.isEmpty)
            const Text("Select exams to continue")
          else
            ...selectedOtherExamIds.map(
              (eId) => eachOtherExamWidget(
                otherExams.firstWhereOrNull((e) => e.customExamId == eId),
                showClear: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDropdownToChooseFaInternalExam() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Text("Computing marks for:"),
          const SizedBox(width: 8),
          Expanded(
            child: ClayButton(
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              borderRadius: 20,
              spread: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: DropdownSearch<FaInternalExam?>(
                  mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
                  selectedItem: null,
                  items: widget.faExam.faInternalExams ?? [],
                  itemAsString: (FaInternalExam? exam) {
                    return exam?.faInternalExamName ?? "-";
                  },
                  showSearchBox: true,
                  dropdownBuilder: (BuildContext context, FaInternalExam? exam) {
                    return Text(exam?.faInternalExamName ?? "-");
                  },
                  onChanged: (FaInternalExam? exam) {
                    if (exam?.faInternalExamId == null) return;
                    setState(() => selectedInternalExamId = exam!.faInternalExamId);
                  },
                  compareFn: (item, selectedItem) => item?.faInternalExamId == selectedItem?.faInternalExamId,
                  dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
                  filterFn: (FaInternalExam? exam, String? key) {
                    return (exam?.faInternalExamName ?? "-").toLowerCase().trim().contains(key!.toLowerCase());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget eachOtherExamWidget(CustomExam? otherExam, {required bool showClear}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: Text(otherExam?.customExamName ?? "-")),
              const SizedBox(width: 10),
              Chip(label: Text(otherExam?.examType ?? "-")),
              if (showClear) const SizedBox(width: 10),
              if (showClear)
                IconButton(
                  onPressed: () => setState(() => selectedOtherExamIds.remove(otherExam?.customExamId)),
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
