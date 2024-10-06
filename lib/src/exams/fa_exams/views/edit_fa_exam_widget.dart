import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class EditFAExamWidget extends StatefulWidget {
  const EditFAExamWidget({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.markingAlgorithms,
    required this.faExam,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final List<MarkingAlgorithmBean> markingAlgorithms;
  final FAExam faExam;

  @override
  State<EditFAExamWidget> createState() => _EditFAExamWidgetState();
}

class _EditFAExamWidgetState extends State<EditFAExamWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  List<Section> selectedSections = [];
  bool _isSectionPickerOpen = false;

  List<TeacherDealingSection> tdsList = [];

  List<SubjectWiseDateTime> defaultSubjectWiseDates = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    selectedSections = widget.sectionsList
        .where((eachSection) => ((widget.faExam.faInternalExams ?? []).map((e) => (e?.examSectionSubjectMapList ?? [])).expand((i) => i))
            .map((e) => e?.sectionId)
            .contains(eachSection.sectionId))
        .toList();
    tdsList = widget.tdsList.where((e) => e.status == 'active').toList();
    defaultSubjectWiseDates
        .addAll(tdsList.map((e) => e.subjectId).toSet().where((e) => e != null).map((e) => SubjectWiseDateTime(e!, null, null, null)));
    _isLoading = false;
  }

  Future<void> saveChanges() async {
    if (const DeepCollectionEquality().equals(widget.faExam.toJson(), widget.faExam.origJson())) return;
    if ((widget.faExam.faExamName?.trim() ?? "").isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Exam name cannot be empty.."),
        ),
      );
      return;
    }
    if ((widget.faExam.faInternalExams ?? []).where((e) => e?.status == 'active').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select at least one internal to continue.."),
        ),
      );
      return;
    }
    if ((widget.faExam.faInternalExams ?? [])
        .where((e) => e?.status == 'active')
        .map((e) => (e?.faInternalExamName ?? '').trim() == '')
        .contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Internal Exam names must be valid.."),
        ),
      );
      return;
    }
    if ((widget.faExam.faInternalExams ?? [])
        .where((e) => e?.status == 'active')
        .map((e) => (e?.examSectionSubjectMapList ?? []).isEmpty)
        .contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select at least one section and subject to continue.."),
        ),
      );
      return;
    }
    for (ExamSectionSubjectMap eachExamSectionSubjectMap in (widget.faExam.faInternalExams ?? [])
        .where((e) => e?.status == 'active')
        .map((e) => e?.examSectionSubjectMapList ?? [])
        .expand((i) => i)
        .map((e) => e!)) {
      if ((eachExamSectionSubjectMap.maxMarks ?? 0) == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Max marks for ${tdsList.firstWhere((eachTds) => eachExamSectionSubjectMap.sectionId == eachTds.sectionId).sectionName} - ${tdsList.firstWhere((eachTds) => eachExamSectionSubjectMap.subjectId == eachTds.subjectId).subjectName} is not defined.."),
          ),
        );
        return;
      }
    }
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.faExam.faExamName ?? "-"),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                for (FaInternalExam eachInternal
                    in (widget.faExam.faInternalExams ?? []).where((e) => !(e?.faInternalExamId == null && e?.status == 'inactive')).map((e) => e!)) {
                  setState(() {
                    eachInternal.examSectionSubjectMapList?.removeWhere((e) => e?.examSectionSubjectMapId == null && e?.status == 'inactive');
                  });
                }
                CreateOrUpdateFAExamRequest createOrUpdateFAExamRequest = CreateOrUpdateFAExamRequest(
                  academicYearId: widget.selectedAcademicYearId,
                  schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                  examType: widget.faExam.examType,
                  agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                  status: "active",
                  comment: widget.faExam.comment,
                  date: widget.faExam.date,
                  faExamId: widget.faExam.faExamId,
                  faExamName: widget.faExam.faExamName,
                  markingAlgorithmId: widget.faExam.markingAlgorithmId,
                  faInternalExams: widget.faExam.faInternalExams,
                );
                CreateOrUpdateFAExamResponse createOrUpdateFAExamResponse = await createOrUpdateFAExam(createOrUpdateFAExamRequest);
                if (createOrUpdateFAExamResponse.httpStatus == "OK" && createOrUpdateFAExamResponse.responseStatus == "success") {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                }
                setState(() {
                  _isLoading = false;
                });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.faExam.faExamName ?? "-"),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveChanges,
            )
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                Container(
                  margin: const EdgeInsets.all(15),
                  child: ClayContainer(
                    emboss: true,
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          faExamNameWidget(),
                          const SizedBox(height: 15),
                          internalsWidget(),
                          const SizedBox(height: 15),
                          _sectionPicker(),
                          const SizedBox(height: 15),
                          ...populatedTdsList(),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget internalsWidget() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        emboss: false,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(child: Text("Internals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              const SizedBox(height: 8),
              ...(widget.faExam.faInternalExams ?? []).map(
                (e) => Row(
                  children: [
                    Checkbox(
                      value: e?.status == 'active',
                      onChanged: (bool? newValue) {
                        setState(() => e?.status = (newValue ?? false) ? 'active' : 'inactive');
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: faInternalExamNameWidget(e!, margin: const EdgeInsets.fromLTRB(15, 8, 15, 8))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              addNewInternalButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addNewInternalButton() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.faExam.faInternalExams ??= [];
                widget.faExam.faInternalExams?.add(FaInternalExam(
                  status: 'active',
                  agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                  examType: 'FA_INTERNAL',
                  examSectionSubjectMapList: [],
                  masterExamId: widget.faExam.faExamId,
                  faInternalExamId: null,
                  faInternalExamName: '',
                ));
              });
            },
            child: ClayButton(
              surfaceColor: Colors.blue,
              parentColor: clayContainerColor(context),
              borderRadius: 10,
              spread: 1,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Add"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> populatedTdsList() {
    List<Widget> widgetsForEachInternal = [];
    for (FaInternalExam eachInternal in (widget.faExam.faInternalExams ?? []).map((e) => e!).where((e) => e.status == 'active')) {
      List<ExamSectionSubjectMap> examSectionSubjectMapList = (eachInternal.examSectionSubjectMapList ?? []).map((e) => e!).toList();
      examSectionSubjectMapList.sort((a, b) {
        int aSectionSeqOrder = widget.sectionsList.firstWhereOrNull((e) => a.sectionId == e.sectionId)?.seqOrder ?? -1;
        int bSectionSeqOrder = widget.sectionsList.firstWhereOrNull((e) => b.sectionId == e.sectionId)?.seqOrder ?? -1;
        int aSubjectSeqOrder = widget.subjectsList.firstWhereOrNull((e) => a.subjectId == e.subjectId)?.seqOrder ?? -1;
        int bSubjectSeqOrder = widget.subjectsList.firstWhereOrNull((e) => b.subjectId == e.subjectId)?.seqOrder ?? -1;
        if (aSectionSeqOrder == bSectionSeqOrder) return aSubjectSeqOrder.compareTo(bSubjectSeqOrder);
        return aSectionSeqOrder.compareTo(bSectionSeqOrder);
      });
      ScrollController scrollController = ScrollController();
      widgetsForEachInternal.add(Container(
        margin: const EdgeInsets.all(15),
        child: ClayContainer(
          emboss: false,
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   eachInternal.faInternalExamName ?? "-",
                //   style: const TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                faInternalExamNameWidget(eachInternal),
                const SizedBox(height: 15),
                Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: [
                          "",
                          "Section",
                          "Subject",
                          "Teacher",
                          "Max Marks",
                          "Date",
                          "Start Time",
                          "End Time",
                        ]
                            .map((e) => DataColumn(
                                label: e == "Date" || e == "Start Time" || e == "End Time"
                                    ? datePopulator(eachInternal, e)
                                    : e == "Max Marks"
                                        ? maxMarksPopulator(eachInternal, e)
                                        : Center(child: Text(e))))
                            .toList(),
                        rows: [
                          ...examSectionSubjectMapList
                              .where((eachExamSectionSubjectMap) =>
                                  selectedSections.map((e) => e.sectionId).contains(eachExamSectionSubjectMap.sectionId))
                              .map(
                                (eachExamSectionSubjectMap) => DataRow(
                                  cells: [
                                    dataCellWidget(
                                      _buildCheckBox(eachExamSectionSubjectMap),
                                    ),
                                    dataCellWidget(
                                      Text(
                                        widget.sectionsList.firstWhere((e) => e.sectionId == eachExamSectionSubjectMap.sectionId).sectionName ?? "-",
                                      ),
                                    ),
                                    dataCellWidget(
                                      Text(
                                        tdsList.firstWhere((e) => e.subjectId == eachExamSectionSubjectMap.subjectId).subjectName ?? "-",
                                      ),
                                      isCenter: false,
                                    ),
                                    dataCellWidget(
                                      Text(
                                        tdsList.firstWhere((e) => e.teacherId == eachExamSectionSubjectMap.authorisedAgent).teacherName ?? "-",
                                      ),
                                      isCenter: false,
                                    ),
                                    dataCellWidget(
                                      _buildMaxMarksTextField(eachExamSectionSubjectMap),
                                    ),
                                    dataCellWidget(_buildDatePicker(eachExamSectionSubjectMap)),
                                    dataCellWidget(_buildStartTimePicker(eachExamSectionSubjectMap)),
                                    dataCellWidget(_buildEndTimePicker(eachExamSectionSubjectMap)),
                                  ],
                                ),
                              )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    return widgetsForEachInternal;
  }

  InkWell datePopulator(FaInternalExam? internal, String e) => InkWell(
        onTap: () async {
          ScrollController scrollController = ScrollController();
          await showDialog(
            context: scaffoldKey.currentContext!,
            builder: (currentContext) {
              return AlertDialog(
                title: const Text("Default Date and Time"),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                      child: ListView(
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
                                  columns: ["Subject", "Date", "Start Time", "End Time"].map((e) => DataColumn(label: Text(e))).toList(),
                                  rows: defaultSubjectWiseDates
                                      .map(
                                        (eachSubjectWiseDateTime) => DataRow(
                                          cells: [
                                            DataCell(
                                                Text(tdsList.firstWhere((e) => e.subjectId == eachSubjectWiseDateTime.subjectId).subjectName ?? "-")),
                                            DataCell(InkWell(
                                              onTap: () async {
                                                DateTime? _newDate = await showDatePicker(
                                                  context: context,
                                                  initialDate: convertYYYYMMDDFormatToDateTime(eachSubjectWiseDateTime.date),
                                                  firstDate: DateTime.now().subtract(const Duration(days: 364)),
                                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                                  helpText: "Select a date",
                                                );
                                                if (_newDate == null) return;
                                                setState(() {
                                                  eachSubjectWiseDateTime.date = convertDateTimeToYYYYMMDDFormat(_newDate);
                                                });
                                              },
                                              child: eachSubjectWiseDateTime.date == null
                                                  ? const FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Icon(
                                                        Icons.calendar_today_rounded,
                                                      ),
                                                    )
                                                  : Text(
                                                      convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(eachSubjectWiseDateTime.date))),
                                            )),
                                            DataCell(InkWell(
                                              onTap: () async {
                                                TimeOfDay? _startTimePicker = await showTimePicker(
                                                  context: context,
                                                  initialTime: formatHHMMSSToTimeOfDay(eachSubjectWiseDateTime.startTime ?? "00:00:00"),
                                                );

                                                if (_startTimePicker == null) return;
                                                setState(() {
                                                  eachSubjectWiseDateTime.startTime = timeOfDayToHHMMSS(_startTimePicker);
                                                });
                                              },
                                              child: Center(
                                                child: Text(eachSubjectWiseDateTime.startTime == null
                                                    ? "-"
                                                    : convert24To12HourFormat(eachSubjectWiseDateTime.startTime!)),
                                              ),
                                            )),
                                            DataCell(InkWell(
                                              onTap: () async {
                                                TimeOfDay? _endTimePicker = await showTimePicker(
                                                  context: context,
                                                  initialTime: formatHHMMSSToTimeOfDay(eachSubjectWiseDateTime.endTime ?? "00:00:00"),
                                                );

                                                if (_endTimePicker == null) return;
                                                setState(() {
                                                  eachSubjectWiseDateTime.endTime = timeOfDayToHHMMSS(_endTimePicker);
                                                });
                                              },
                                              child: Center(
                                                child: Text(eachSubjectWiseDateTime.endTime == null
                                                    ? "-"
                                                    : convert24To12HourFormat(eachSubjectWiseDateTime.endTime!)),
                                              ),
                                            )),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      for (FaInternalExam eachInternal in (internal == null ? (widget.faExam.faInternalExams ?? []).map((e) => e!) : [internal])
                          .where((e) => e.status == 'active')) {
                        for (ExamSectionSubjectMap eachExamSectionSubjectMap in (eachInternal.examSectionSubjectMapList ?? []).map((e) => e!)) {
                          SubjectWiseDateTime eachSubjectWiseDateTime =
                              defaultSubjectWiseDates.firstWhere((e) => e.subjectId == eachExamSectionSubjectMap.subjectId);
                          setState(() {
                            eachExamSectionSubjectMap.date ??= eachSubjectWiseDateTime.date;
                            eachExamSectionSubjectMap.startTime ??= eachSubjectWiseDateTime.startTime;
                            eachExamSectionSubjectMap.endTime ??= eachSubjectWiseDateTime.endTime;
                          });
                        }
                      }
                    },
                    child: const Text("Apply to all"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Center(child: Text(e)),
        ),
      );

  InkWell maxMarksPopulator(FaInternalExam? internal, String e) => InkWell(
        onTap: () async {
          await showDialog(
            context: scaffoldKey.currentContext!,
            builder: (currentContext) {
              double? defaultMaxMarks;
              return AlertDialog(
                title: const Text("Default Max Marks"),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 2,
                      child: TextFormField(
                        initialValue: "",
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: "Max. Marks",
                          hintText: "Max. Marks",
                          border: UnderlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (String? newText) => setState(() {
                          if (newText == "") {
                            defaultMaxMarks = null;
                          }
                          double? newMaxMarks = double.tryParse(newText ?? "");
                          if (newMaxMarks != null) {
                            defaultMaxMarks = newMaxMarks;
                          }
                        }),
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      for (FaInternalExam eachInternal in (internal == null ? (widget.faExam.faInternalExams ?? []).map((e) => e!) : [internal])
                          .where((e) => e.status == 'active')) {
                        for (ExamSectionSubjectMap eachExamSectionSubjectMap in (eachInternal.examSectionSubjectMapList ?? []).map((e) => e!)) {
                          setState(() {
                            if (eachExamSectionSubjectMap.maxMarks == null) {
                              eachExamSectionSubjectMap.maxMarks ??= defaultMaxMarks;
                              eachExamSectionSubjectMap.maxMarksController.text = '${defaultMaxMarks ?? ''}';
                            }
                          });
                        }
                      }
                    },
                    child: const Text("Apply to all"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Center(child: Text(e)),
        ),
      );

  DataCell dataCellWidget(
    Widget child, {
    bool isCenter = true,
  }) {
    return DataCell(
      Container(
        margin: const EdgeInsets.all(4),
        width: double.infinity,
        height: double.infinity,
        child: isCenter
            ? Center(child: child)
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  child,
                ],
              ),
      ),
    );
  }

  Checkbox _buildCheckBox(ExamSectionSubjectMap eachExamSectionSubjectMap) {
    return Checkbox(
      value: eachExamSectionSubjectMap.status == 'active',
      onChanged: (bool? newValue) {
        setState(() => eachExamSectionSubjectMap.status = (newValue ?? false) ? 'active' : 'inactive');
      },
    );
  }

  Widget _buildDatePicker(ExamSectionSubjectMap eachExamSectionSubjectMap) {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            DateTime? _newDate = await showDatePicker(
              context: context,
              initialDate: convertYYYYMMDDFormatToDateTime(eachExamSectionSubjectMap.date),
              firstDate: DateTime.now().subtract(const Duration(days: 364)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              helpText: "Select a date",
            );
            if (_newDate == null) return;
            setState(() {
              eachExamSectionSubjectMap.date = convertDateTimeToYYYYMMDDFormat(_newDate);
            });
          },
          child: eachExamSectionSubjectMap.date == null
              ? const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    Icons.calendar_today_rounded,
                  ),
                )
              : Text(eachExamSectionSubjectMap.examDate),
        ),
        PopupMenuButton<DateTime>(
          tooltip: "Other Dates",
          onSelected: (DateTime choice) async {
            setState(() {
              eachExamSectionSubjectMap.date = convertDateTimeToYYYYMMDDFormat(choice);
            });
          },
          itemBuilder: (BuildContext context) {
            return (widget.faExam.faInternalExams ?? [])
                .map((e) => e?.examSectionSubjectMapList ?? [])
                .expand((i) => i)
                .map((e) => e?.date == null ? null : convertYYYYMMDDFormatToDateTime(e?.date))
                .whereNotNull()
                .toSet()
                .toList()
                .sorted((a, b) => a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch))
                .map((DateTime choice) => PopupMenuItem<DateTime>(
                      value: choice,
                      child: Text(convertDateTimeToDDMMYYYYFormat(choice)),
                    ))
                .toList();
          },
        ),
      ],
    );
  }

  TextFormField _buildMaxMarksTextField(ExamSectionSubjectMap eachExamSectionSubjectMap) {
    return TextFormField(
      controller: eachExamSectionSubjectMap.maxMarksController,
      decoration: const InputDecoration(
        labelText: null,
        hintText: "Max. Marks",
        border: UnderlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
      ),
      keyboardType: TextInputType.number,
      onChanged: (String? newText) => setState(() {
        if (newText == "") {
          eachExamSectionSubjectMap.maxMarks = null;
        }
        double? newMaxMarks = double.tryParse(newText ?? "");
        if (newMaxMarks != null) {
          eachExamSectionSubjectMap.maxMarks = newMaxMarks;
        }
      }),
      maxLines: 1,
      style: const TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.start,
    );
  }

  Future<void> _pickStartTime(BuildContext context, ExamSectionSubjectMap eachExamSectionSubjectMap) async {
    TimeOfDay? _startTimePicker = await showTimePicker(
      context: context,
      initialTime: formatHHMMSSToTimeOfDay(eachExamSectionSubjectMap.startTime ?? "00:00:00"),
    );

    if (_startTimePicker == null) return;
    setState(() {
      eachExamSectionSubjectMap.startTime = timeOfDayToHHMMSS(_startTimePicker);
    });
  }

  Widget _buildStartTimePicker(ExamSectionSubjectMap eachExamSectionSubjectMap) {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            await _pickStartTime(context, eachExamSectionSubjectMap);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Center(
              child: Text(eachExamSectionSubjectMap.startTimeSlot),
            ),
          ),
        ),
        const SizedBox(width: 5),
        PopupMenuButton<TimeOfDay>(
          tooltip: "Other Start Times",
          onSelected: (TimeOfDay choice) async {
            setState(() {
              eachExamSectionSubjectMap.startTime = timeOfDayToHHMMSS(choice);
            });
          },
          itemBuilder: (BuildContext context) {
            return (widget.faExam.faInternalExams ?? [])
                .map((e) => e?.examSectionSubjectMapList ?? [])
                .expand((i) => i)
                .map((e) => e?.startTime == null ? null : formatHHMMSSToTimeOfDay(e!.startTime!))
                .whereNotNull()
                .toSet()
                .toList()
                .sorted(
                  (a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(timeOfDayToHHMMSS(a), 1)
                      .compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(timeOfDayToHHMMSS(b), 1)),
                )
                .map((TimeOfDay choice) => PopupMenuItem<TimeOfDay>(
                      value: choice,
                      child: Text(convert24To12HourFormat(timeOfDayToHHMMSS(choice))),
                    ))
                .toList();
          },
        ),
      ],
    );
  }

  Future<void> _pickEndTime(BuildContext context, ExamSectionSubjectMap eachExamSectionSubjectMap) async {
    TimeOfDay? _endTimePicker = await showTimePicker(
      context: context,
      initialTime: formatHHMMSSToTimeOfDay(eachExamSectionSubjectMap.endTime ?? "00:00:00"),
    );

    if (_endTimePicker == null) return;
    setState(() {
      eachExamSectionSubjectMap.endTime = timeOfDayToHHMMSS(_endTimePicker);
    });
  }

  Widget _buildEndTimePicker(ExamSectionSubjectMap eachExamSectionSubjectMap) {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            await _pickEndTime(context, eachExamSectionSubjectMap);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Center(
              child: Text(eachExamSectionSubjectMap.endTimeSlot),
            ),
          ),
        ),
        const SizedBox(width: 5),
        PopupMenuButton<TimeOfDay>(
          tooltip: "Other End Times",
          onSelected: (TimeOfDay choice) async {
            setState(() {
              eachExamSectionSubjectMap.endTime = timeOfDayToHHMMSS(choice);
            });
          },
          itemBuilder: (BuildContext context) {
            return (widget.faExam.faInternalExams ?? [])
                .map((e) => e?.examSectionSubjectMapList ?? [])
                .expand((i) => i)
                .map((e) => e?.endTime == null ? null : formatHHMMSSToTimeOfDay(e!.endTime!))
                .whereNotNull()
                .toSet()
                .toList()
                .sorted(
                  (a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(timeOfDayToHHMMSS(a), 1)
                      .compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(timeOfDayToHHMMSS(b), 1)),
                )
                .map((TimeOfDay choice) => PopupMenuItem<TimeOfDay>(
                      value: choice,
                      child: Text(convert24To12HourFormat(timeOfDayToHHMMSS(choice))),
                    ))
                .toList();
          },
        ),
      ],
    );
  }

  Widget faInternalExamNameWidget(
    FaInternalExam internalExam, {
    EdgeInsetsGeometry margin = const EdgeInsets.all(15),
  }) {
    return Container(
      margin: margin,
      child: TextFormField(
        autofocus: true,
        controller: internalExam.internalExamNameController,
        decoration: const InputDecoration(
          border: UnderlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        ),
        onChanged: (String? newText) => setState(() => internalExam.faInternalExamName = newText),
        maxLines: 1,
        style: const TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget faExamNameWidget() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              autofocus: true,
              initialValue: widget.faExam.faExamName,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
              ),
              onChanged: (String? newText) => setState(() => widget.faExam.faExamName = newText),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: 15),
          DropdownButton<MarkingAlgorithmBean?>(
            value: widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.faExam.markingAlgorithmId).firstOrNull,
            items: [null, ...widget.markingAlgorithms]
                .map((e) => DropdownMenuItem<MarkingAlgorithmBean?>(
              child: Text(e?.algorithmName ?? "-"),
              value: e,
            ))
                .toList(),
            onChanged: (MarkingAlgorithmBean? newMarkingAlgorithm) =>
                setState(() => widget.faExam.markingAlgorithmId = newMarkingAlgorithm?.markingAlgorithmId),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                selectedSections.isEmpty ? "Select sections" : "Sections:",
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
            children: widget.sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      height: 60,
      child: selectedSections.isEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isSectionPickerOpen = !_isSectionPickerOpen;
                      });
                    },
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          selectedSections.isEmpty ? "Select sections" : "Sections: ${selectedSections.map((e) => e.sectionName).join(", ")}",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            )
          : InkWell(
              onTap: () {
                setState(() {
                  _isSectionPickerOpen = !_isSectionPickerOpen;
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 14, 5, 14),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedSections.isEmpty ? "Select sections" : "Sections: ${selectedSections.map((e) => e.sectionName).join(", ")}",
                    ),
                  ),
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
          if (selectedSections.contains(section)) {
            setState(() {
              selectedSections.remove(section);
            });
            removeSection(section);
          } else {
            setState(() {
              selectedSections.add(section);
            });
            addSection(section);
          }
        },
        child: ClayButton(
          depth: 40,
          color: selectedSections.contains(section) ? Colors.blue[200] : clayContainerColor(context),
          spread: selectedSections.contains(section) ? 0 : 2,
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

  void removeSection(Section section) {
    List<TeacherDealingSection> tdsToAdd = tdsList.where((e) => e.sectionId == section.sectionId).toList();
    for (TeacherDealingSection eachTds in tdsToAdd) {
      for (FaInternalExam eachInternal in (widget.faExam.faInternalExams ?? []).map((e) => e!).where((e) => e.status == 'active')) {
        List<ExamSectionSubjectMap> examSectionSubjectMapList = (eachInternal.examSectionSubjectMapList ?? []).map((e) => e!).toList();
        examSectionSubjectMapList
            .where((e) => e.subjectId == eachTds.subjectId && e.sectionId == eachTds.sectionId && e.authorisedAgent == eachTds.teacherId)
            .forEach((eachExamSectionSubjectMap) {
          eachExamSectionSubjectMap
            ..status = 'inactive'
            ..agent = widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId;
        });
        setState(() {
          eachInternal.examSectionSubjectMapList = examSectionSubjectMapList;
        });
      }
    }
  }

  void addSection(Section section) {
    List<TeacherDealingSection> tdsToAdd = tdsList.where((e) => e.sectionId == section.sectionId).toList();
    for (TeacherDealingSection eachTds in tdsToAdd) {
      for (FaInternalExam eachInternal in (widget.faExam.faInternalExams ?? []).map((e) => e!).where((e) => e.status == 'active')) {
        List<ExamSectionSubjectMap> examSectionSubjectMapList = (eachInternal.examSectionSubjectMapList ?? []).map((e) => e!).toList();
        if (examSectionSubjectMapList
            .where((e) => e.subjectId == eachTds.subjectId && e.sectionId == eachTds.sectionId && e.authorisedAgent == eachTds.teacherId)
            .isEmpty) {
          examSectionSubjectMapList.add(ExamSectionSubjectMap(
            agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
            status: 'active',
            authorisedAgent: eachTds.teacherId,
            comment: null,
            date: null,
            endTime: null,
            examId: widget.faExam.faExamId,
            examSectionSubjectMapId: null,
            masterExamId: null,
            maxMarks: null,
            sectionId: eachTds.sectionId,
            startTime: null,
            studentExamMarksList: [],
            subjectId: eachTds.subjectId,
          ));
        } else {
          examSectionSubjectMapList
              .where((e) => e.subjectId == eachTds.subjectId && e.sectionId == eachTds.sectionId && e.authorisedAgent == eachTds.teacherId)
              .forEach((eachExamSectionSubjectMap) {
            eachExamSectionSubjectMap
              ..status = 'active'
              ..agent = widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId;
          });
        }
        setState(() {
          eachInternal.examSectionSubjectMapList = examSectionSubjectMapList;
        });
      }
    }
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }
}

class SubjectWiseDateTime {
  int subjectId;
  String? date;
  String? startTime;
  String? endTime;

  SubjectWiseDateTime(this.subjectId, this.date, this.startTime, this.endTime);
}
