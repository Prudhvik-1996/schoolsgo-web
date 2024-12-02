import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class ExamTimeSlotSelectorWidget extends StatefulWidget {
  const ExamTimeSlotSelectorWidget({
    super.key,
    required this.exam,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
  });

  final FAExam exam;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;

  @override
  State<ExamTimeSlotSelectorWidget> createState() => _ExamTimeSlotSelectorWidgetState();
}

class _ExamTimeSlotSelectorWidgetState extends State<ExamTimeSlotSelectorWidget> {
  ScrollController scrollController = ScrollController();
  static const double defaultCellWidth = 120;
  static const double defaultCellHeight = 60;
  Set<String> checkedSlots = {};
  bool selectionMode = false;

  List<Subject> subjectsForExam = [];
  List<Section> sectionsForExam = [];

  List<Section> selectedSections = [];
  List<Subject> selectedSubjects = [];

  Map<int, Map<int, ExamTimeSlotBean?>> timeSlotMap = {};

  @override
  void initState() {
    super.initState();
    subjectsForExam = (widget.exam.faInternalExams ?? [])
        .map((e) => e?.examSectionSubjectMapList ?? [])
        .expand((i) => i)
        .where((e) => e?.status == 'active')
        .map((e) => e?.subjectId)
        .whereNotNull()
        .toSet()
        .map((e) => widget.subjectsList.firstWhere((es) => es.subjectId == e))
        .toList()
      ..sort((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0));
    sectionsForExam = (widget.exam.faInternalExams ?? [])
        .map((e) => e?.examSectionSubjectMapList ?? [])
        .expand((i) => i)
        .where((e) => e?.status == 'active')
        .map((e) => e?.sectionId)
        .whereNotNull()
        .toSet()
        .map((e) => widget.sectionsList.firstWhere((es) => es.sectionId == e))
        .toList()
      ..sort((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0));
    selectedSections = [...sectionsForExam];
    selectedSubjects = [...subjectsForExam];
    timeSlotMap = buildTimeSlotMap(sectionsForExam, subjectsForExam);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.exam.examTimeSlots = timeSlotMap.values.map((e) => e.values).expand((i) => i).toList();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Exam Time Table"),
          actions: [
            if (checkedSlots.isNotEmpty) dateTimePickerButton(),
            IconButton(
              icon: isSelectionMode ? const Icon(Icons.deselect_sharp) : const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  if (isSelectionMode) {
                    checkedSlots.clear();
                    selectionMode = false;
                  } else {
                    selectionMode = true;
                  }
                });
              },
            )
          ],
        ),
        body: v2Widget(),
      ),
    );
  }

  bool get isSelectionMode => selectionMode || checkedSlots.isNotEmpty;

  IconButton dateTimePickerButton() {
    return IconButton(
      icon: const Icon(Icons.timer),
      onPressed: () async {
        await dateTimePickerAlert();
      },
    );
  }

  Future<void> dateTimePickerAlert({String? date, String? startTime, String? endTime}) async {
    date ??= convertDateTimeToYYYYMMDDFormat(DateTime.now());
    startTime ??= "09:00:00";
    endTime ??= "10:00:00";
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text('Set Date & Time'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView(
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text("Date")),
                        GestureDetector(
                          onTap: () async {
                            DateTime? _newDate = await showDatePicker(
                              context: context,
                              initialDate: convertYYYYMMDDFormatToDateTime(date),
                              firstDate: DateTime.now().subtract(const Duration(days: 364)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              helpText: "Select a date",
                            );
                            if (_newDate == null) return;
                            setState(() {
                              date = convertDateTimeToYYYYMMDDFormat(_newDate);
                            });
                          },
                          child: ClayButton(
                            depth: 20,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 30,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                    ),
                                    Text(
                                      convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(date)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(child: Text("Start Time")),
                        GestureDetector(
                          onTap: () async {
                            TimeOfDay? _startTimePicker = await showTimePicker(
                              context: context,
                              initialTime: formatHHMMSSToTimeOfDay(startTime!),
                            );

                            if (_startTimePicker == null) return;
                            setState(() {
                              startTime = timeOfDayToHHMMSS(_startTimePicker);
                            });
                          },
                          child: ClayButton(
                            depth: 20,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 30,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_sharp,
                                    ),
                                    Text(
                                      formatHHMMSStoHHMMA(startTime!),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(child: Text("End Time")),
                        GestureDetector(
                          onTap: () async {
                            TimeOfDay? _endTimePicker = await showTimePicker(
                              context: context,
                              initialTime: formatHHMMSSToTimeOfDay(endTime!),
                            );

                            if (_endTimePicker == null) return;
                            setState(() {
                              endTime = timeOfDayToHHMMSS(_endTimePicker);
                            });
                          },
                          child: ClayButton(
                            depth: 20,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 30,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_sharp,
                                    ),
                                    Text(
                                      formatHHMMSStoHHMMA(endTime!),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Apply"),
              onPressed: () async {
                setDateAndTime(date!, startTime!, endTime!);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void setDateAndTime(String date, String startTime, String endTime) => setState(() {
        timeSlotMap.values.map((e) => e.values).expand((i) => i).whereNotNull().where((e) => checkedSlots.contains(e.mapKey)).forEach((e) {
          e.date = date;
          e.startTime = startTime;
          e.endTime = endTime;
        });
        checkedSlots.clear();
      });

  Widget v2Widget() {
    List<Section> sectionsToShow = sectionsForExam.where((e) => selectedSections.contains(e)).toList();
    List<Subject> subjectsToShow = subjectsForExam.where((e) => selectedSubjects.contains(e)).toList();
    return StickyHeadersTable(
      cellDimensions: CellDimensions.variableColumnWidth(
        columnWidths: List.generate(subjectsToShow.length, (index) => defaultCellWidth),
        contentCellHeight: defaultCellHeight,
        stickyLegendWidth: defaultCellWidth,
        stickyLegendHeight: defaultCellHeight,
      ),
      showHorizontalScrollbar: true,
      showVerticalScrollbar: true,
      columnsLength: subjectsToShow.length,
      rowsLength: sectionsToShow.length,
      legendCell: clayCell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            sectionFilter(),
            const SizedBox(width: 4),
            subjectsFilter(),
          ],
        ),
      ),
      rowsTitleBuilder: (int rowIndex) {
        Section eachSection = sectionsToShow[rowIndex];
        return clayCell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: defaultCellHeight - 4,
                width: 30,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => checkedSlots.addAll(timeSlotMap.values
                            .map((e) => e.values)
                            .expand((i) => i)
                            .where((e) => e?.sectionId == eachSection.sectionId)
                            .map((e) => e?.mapKey)
                            .whereNotNull())),
                        child: Tooltip(
                          message: "Select All Sections",
                          child: ClayButton(
                            width: 24,
                            depth: 20,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 100,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => setState(() => checkedSlots.removeAll(timeSlotMap.values
                            .map((e) => e.values)
                            .expand((i) => i)
                            .where((e) => e?.sectionId == eachSection.sectionId)
                            .map((e) => e?.mapKey)
                            .whereNotNull())),
                        child: Tooltip(
                          message: "Unselect All Sections",
                          child: ClayButton(
                            width: 24,
                            depth: 20,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 100,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(child: Text(sectionsToShow[rowIndex].sectionName ?? "-")),
              ),
            ],
          ),
        );
      },
      columnsTitleBuilder: (int columnIndex) {
        Subject eachSubject = subjectsToShow[columnIndex];
        return clayCell(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: defaultCellHeight - 4,
                width: 30,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => checkedSlots.addAll(timeSlotMap.values
                            .map((e) => e.values)
                            .expand((i) => i)
                            .where((e) => e?.subjectId == eachSubject.subjectId)
                            .map((e) => e?.mapKey)
                            .whereNotNull())),
                        child: Tooltip(
                          message: "Select All Subjects",
                          child: ClayButton(
                            width: 24,
                            depth: 20,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 100,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => setState(() => checkedSlots.removeAll(timeSlotMap.values
                            .map((e) => e.values)
                            .expand((i) => i)
                            .where((e) => e?.subjectId == eachSubject.subjectId)
                            .map((e) => e?.mapKey)
                            .whereNotNull())),
                        child: Tooltip(
                          message: "Unselect All Subjects",
                          child: ClayButton(
                            width: 24,
                            depth: 20,
                            color: clayContainerColor(context),
                            spread: 2,
                            borderRadius: 100,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(child: Text(eachSubject.subjectName ?? "-")),
              ),
            ],
          ),
        );
      },
      contentCellBuilder: (int columnIndex, int rowIndex) {
        Section eachSection = sectionsToShow[rowIndex];
        Subject eachSubject = subjectsToShow[columnIndex];
        ExamTimeSlotBean? timeSlotForSectionSubject = timeSlotMap[eachSection.sectionId!]![eachSubject.subjectId!];
        if (timeSlotForSectionSubject == null) {
          return clayCell(
            child: const Center(child: Text("N/A")),
          );
        } else {
          return clayCell(
            child: timeSlotButton(timeSlotForSectionSubject),
            padding: const EdgeInsets.all(0),
            parentColor: checkedSlots.contains(timeSlotForSectionSubject.mapKey) ? Colors.cyanAccent : null,
            spread: checkedSlots.contains(timeSlotForSectionSubject.mapKey) ? 1 : 1,
          );
        }
      },
    );
  }

  Widget subjectsFilter() {
    return GestureDetector(
      onTap: () {
        SelectDialog.showModal<Subject>(
          context,
          showSelectedItemsFirst: true,
          label: "Select Subjects",
          multipleSelectedValues: selectedSubjects..sort((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0)),
          items: subjectsForExam..sort((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0)),
          onMultipleItemsChange: (List<Subject> subjects) => setState(() {
            selectedSubjects = subjects;
          }),
          itemBuilder: (BuildContext context, Subject subject, bool isSelected) {
            return ListTile(
              title: Text(
                subject.subjectName ?? "-",
                style: TextStyle(
                  color: isSelected ? Colors.blue : null,
                ),
              ),
            );
          },
        );
      },
      child: Tooltip(
        message: "Subject Filter",
        child: ClayButton(
          width: 24,
          depth: 20,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 100,
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: RotatedBox(
                quarterTurns: 3,
                child: Icon(Icons.filter_list),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionFilter() {
    return GestureDetector(
      onTap: () {
        SelectDialog.showModal<Section>(
          context,
          showSelectedItemsFirst: true,
          label: "Select Sections",
          multipleSelectedValues: selectedSections..sort((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0)),
          items: sectionsForExam..sort((a, b) => (a.seqOrder ?? 0).compareTo(b.seqOrder ?? 0)),
          onMultipleItemsChange: (List<Section> sections) => setState(() {
            selectedSections = sections;
          }),
          itemBuilder: (BuildContext context, Section section, bool isSelected) {
            return ListTile(
              title: Text(
                section.sectionName ?? "-",
                style: TextStyle(
                  color: isSelected ? Colors.blue : null,
                ),
              ),
            );
          },
        );
      },
      child: Tooltip(
        message: "Section Filter",
        child: ClayButton(
          width: 24,
          depth: 20,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 100,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(Icons.filter_list),
            ),
          ),
        ),
      ),
    );
  }

  Map<int, Map<int, ExamTimeSlotBean?>> buildTimeSlotMap(List<Section> sections, List<Subject> subjects) {
    Map<int, Map<int, ExamTimeSlotBean?>> timeSlotMap = {};
    for (Section eachSection in sectionsForExam) {
      timeSlotMap[eachSection.sectionId!] ??= {};
      for (Subject eachSubject in subjectsForExam) {
        timeSlotMap[eachSection.sectionId!]![eachSubject.subjectId!] ??= null;
        ExamSectionSubjectMap? selectedEssm = (widget.exam.faInternalExams ?? [])
            .map((e) => e?.examSectionSubjectMapList ?? [])
            .expand((i) => i)
            .whereNotNull()
            .where((e) => e.status == 'active' && e.sectionId == eachSection.sectionId && e.subjectId == eachSubject.subjectId)
            .toList()
            .firstOrNull;
        if (selectedEssm != null) {
          ExamTimeSlotBean? alreadyExistingSlot = (widget.exam.examTimeSlots ?? [])
              .where((ets) =>
                  ets?.sectionId == eachSection.sectionId &&
                  ets?.subjectId == eachSubject.subjectId &&
                  ets?.authorisedAgentId == selectedEssm.authorisedAgent)
              .firstOrNull;
          if (alreadyExistingSlot == null) {
            timeSlotMap[eachSection.sectionId!]![eachSubject.subjectId!] = ExamTimeSlotBean(
              status: 'active',
              subjectId: eachSubject.subjectId,
              sectionId: eachSection.sectionId,
              authorisedAgentId: selectedEssm.authorisedAgent,
              examId: widget.exam.faExamId,
            );
          } else {
            timeSlotMap[eachSection.sectionId!]![eachSubject.subjectId!] = alreadyExistingSlot;
          }
        }
      }
    }
    return timeSlotMap;
  }

  Widget timeSlotButton(ExamTimeSlotBean e) {
    return GestureDetector(
      onTap: () async {
        if (isSelectionMode) {
          setState(() {
            if (checkedSlots.contains(e.mapKey)) {
              checkedSlots.remove(e.mapKey);
            } else {
              checkedSlots.add(e.mapKey);
            }
          });
        } else {
          setState(() {
            checkedSlots.add(e.mapKey);
          });
          await dateTimePickerAlert(date: e.date, startTime: e.startTime, endTime: e.endTime);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: checkedSlots.contains(e.mapKey) ? Colors.blue : Colors.grey,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(e.formattedDateString),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                ),
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text("${e.formattedStartTime} - ${e.formattedEndTime}"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell dataCellWidget(
    Widget child, {
    bool isCenter = true,
    bool isClay = true,
    EdgeInsetsGeometry? padding = const EdgeInsets.all(8),
  }) {
    var childWidget = isCenter
        ? Center(child: child)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              child,
            ],
          );
    return DataCell(
      isClay ? clayCell(child: childWidget, padding: padding) : childWidget,
    );
  }

  Widget clayCell({
    Widget? child,
    EdgeInsetsGeometry? margin = const EdgeInsets.all(4),
    EdgeInsetsGeometry? padding = const EdgeInsets.all(8),
    bool emboss = true,
    double width = defaultCellWidth,
    double height = defaultCellHeight,
    Color? parentColor,
    double spread = 1,
  }) {
    return Container(
      margin: margin,
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: parentColor ?? clayContainerColor(context),
        spread: spread,
        borderRadius: 10,
        emboss: emboss,
        child: Container(
          width: width,
          height: height,
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  ListView v1Widget() {
    List<Section> sectionsToShow = sectionsForExam.where((e) => selectedSections.contains(e)).toList();
    List<Subject> subjectsToShow = subjectsForExam.where((e) => selectedSubjects.contains(e)).toList();
    List<DataColumn> dataColumns = [
      DataColumn(
        label: clayCell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              sectionFilter(),
              const SizedBox(width: 4),
              subjectsFilter(),
            ],
          ),
        ),
      ),
      ...(subjectsToShow.map((e) => DataColumn(label: clayCell(child: FittedBox(fit: BoxFit.scaleDown, child: Text(e.subjectName ?? "-")))))),
    ];
    List<DataRow> dataRows = [];
    for (Section eachSection in sectionsToShow) {
      List<DataCell> sectionWiseCells = [dataCellWidget(Text(eachSection.sectionName ?? "-"))];
      for (Subject eachSubject in subjectsToShow) {
        ExamTimeSlotBean? timeSlotForSectionSubject = timeSlotMap[eachSection.sectionId!]![eachSubject.subjectId!];
        if (timeSlotForSectionSubject == null) {
          sectionWiseCells.add(dataCellWidget(const Text("N/A")));
        } else {
          sectionWiseCells.add(
            dataCellWidget(timeSlotButton(timeSlotForSectionSubject), padding: const EdgeInsets.all(0)),
          );
        }
      }
      dataRows.add(DataRow(cells: sectionWiseCells));
    }
    return ListView(
      children: [
        Scrollbar(
          thumbVisibility: true,
          controller: scrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: DataTable(
                horizontalMargin: 0,
                columnSpacing: 0,
                columns: dataColumns,
                rows: dataRows,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
