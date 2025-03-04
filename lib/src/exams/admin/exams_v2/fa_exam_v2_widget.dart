import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_cumulative_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/edit_fa_exam_widget.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/sms/modal/sms.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class FaExamV2Widget extends StatefulWidget {
  const FaExamV2Widget({
    super.key,
    required this.adminProfile,
    required this.exam,
    required this.tdsList,
    required this.selectedSection,
    required this.sectionsList,
    required this.subjectsList,
    required this.teachersList,
    required this.markingAlgorithms,
    required this.schoolInfo,
    required this.studentsList,
    required this.editingEnabled,
    required this.showMoreOptions,
  });

  final AdminProfile adminProfile;
  final FAExam exam;
  final List<TeacherDealingSection> tdsList;
  final Section? selectedSection;

  final List<Section> sectionsList;
  final List<Subject> subjectsList;
  final List<Teacher> teachersList;

  final List<MarkingAlgorithmBean> markingAlgorithms;

  final SchoolInfoBean schoolInfo;
  final List<StudentProfile> studentsList;

  final bool editingEnabled;
  final bool showMoreOptions;

  @override
  State<FaExamV2Widget> createState() => _FaExamV2WidgetState();
}

class _FaExamV2WidgetState extends State<FaExamV2Widget> {
  bool _isLoading = true;
  List<TdsWiseMarksStats> tdsWiseList = [];
  bool isExpanded = false;

  ScrollController scrollController = ScrollController();

  FAExam? faExam;
  SmsTemplateBean? smsTemplate;

  String? downloadMessage;

  List<StudentProfile> studentsForSelectedSection = [];
  Map<int, bool> studentHallTicketMap = {};

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    print("85: ${widget.selectedSection?.sectionName}");
    for (TeacherDealingSection eachTds in widget.tdsList) {
      List<double?> tdsWiseMarks = [];
      List<double?> maxMarks = [];
      for (FaInternalExam? eachInternal in (widget.exam.faInternalExams ?? [])) {
        ExamSectionSubjectMap? examSectionSubjectMap = (eachInternal?.examSectionSubjectMapList ?? [])
            .where(
                (essm) => essm?.sectionId == eachTds.sectionId && essm?.subjectId == eachTds.subjectId && essm?.authorisedAgent == eachTds.teacherId)
            .firstOrNull;
        // if (examSectionSubjectMap == null) continue;
        tdsWiseMarks.add(examSectionSubjectMap?.status == 'active' ? examSectionSubjectMap?.averageMarksObtained : null);
        maxMarks.add(examSectionSubjectMap?.status == 'active' ? examSectionSubjectMap?.maxMarks : null);
      }
      tdsWiseList.add(TdsWiseMarksStats.fromAverageMarksAndMaxMarks(eachTds.subjectId, eachTds.sectionId, eachTds.teacherId, tdsWiseMarks, maxMarks));
    }
    tdsWiseList = tdsWiseList.toSet().toList();
    setState(() => _isLoading = false);
  }

  Future<void> _loadExam() async {
    setState(() => _isLoading = true);
    faExam = ((await getFAExams(GetFAExamsRequest(faExamId: widget.exam.faExamId, schoolId: widget.exam.schoolId))).exams ?? []).firstOrNull;
    await _loadData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadSmsTemplate() async {
    setState(() => _isLoading = true);
    GetSmsTemplatesResponse getSmsTemplatesResponse = await getSmsTemplates(GetSmsTemplatesRequest(
      categoryId: 4,
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSmsTemplatesResponse.httpStatus != "OK" ||
        getSmsTemplatesResponse.responseStatus != "success" ||
        getSmsTemplatesResponse.smsTemplateBeans == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      smsTemplate = getSmsTemplatesResponse.smsTemplateBeans?.firstOrNull;
    }
    setState(() => _isLoading = false);
  }

  Future<void> refreshExam() async {
    setState(() => _isLoading = true);
    if (faExam == null) await _loadExam();
    widget.exam.faInternalExams = faExam?.faInternalExams;
    widget.exam.markingAlgorithmId = faExam?.markingAlgorithmId;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                examNameWidget(),
                if (_isLoading)
                  Center(
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: EpsilonDiaryLoadingWidget(
                        defaultLoadingText: downloadMessage,
                      ),
                    ),
                  ),
                if (!_isLoading && isExpanded && widget.showMoreOptions) moreOptionsWidget(),
                if (!_isLoading && isExpanded) internalsStatsWidget(),
              ],
            ),
          )),
    );
  }

  Widget moreOptionsWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // editExamButton(),
          // const SizedBox(width: 12),
          updateMarksButton(),
          const SizedBox(width: 12),
          sendSmsButton(),
          if ((widget.exam.examTimeSlots ?? []).isNotEmpty) const SizedBox(width: 12),
          if ((widget.exam.examTimeSlots ?? []).isNotEmpty) buildStudentsSelectorWidgetToDownloadHallTickets(),
        ],
      ),
    );
  }

  Widget buildStudentsSelectorWidgetToDownloadHallTickets() {
    return Tooltip(
      message: "Download Hall Tickets",
      child: GestureDetector(
        onTap: () async => await showStudentsPickerDialogue(),
        child: fab(const Icon(Icons.download), "Hall Tickets"),
      ),
    );
  }

  Future<void> downloadHallTicketsAction() async {
    setState(() {
      downloadMessage = "Downloading Hall Tickets";
      _isLoading = true;
    });
    GenerateExamHallTicketsRequest generateStudentMemosRequest = GenerateExamHallTicketsRequest(
      examId: widget.exam.faExamId,
      sectionId: widget.selectedSection?.sectionId,
      schoolId: widget.adminProfile.schoolId,
      studentPhotoSize: "S",
      showStudentPhoto: false,
      studentIds: studentsForSelectedSection.where((es) => studentHallTicketMap[es.studentId!] ?? false).map((e) => e.studentId).toList(),
    );
    List<int>? bytes = await downloadHallTicketsForExam(generateStudentMemosRequest);
    html.AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "${widget.selectedSection?.sectionName ?? ""}_${widget.exam.faExamName}_HallTickets.pdf")
      ..click();
    setState(() {
      downloadMessage = null;
      _isLoading = false;
    });
  }

  Future<void> showStudentsPickerDialogue() async {
    studentsForSelectedSection = widget.studentsList.where((e) => e.sectionId == widget.selectedSection?.sectionId).toList();
    studentHallTicketMap = {};
    for (StudentProfile es in studentsForSelectedSection) {
      studentHallTicketMap[es.studentId!] = true;
    }
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text("Students' Hall Tickets"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              var horizontalScrollView = ScrollController();
              return SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width - 100,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: horizontalScrollView,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: horizontalScrollView,
                    child: SizedBox(
                      width: max(500, MediaQuery.of(context).size.width - 150),
                      child: ListView(
                        children: [
                          MediaQuery.of(context).orientation == Orientation.landscape
                              ? Row(
                                  children: selectAllCheckBoxes(setState).map((e) => Expanded(child: e)).toList(),
                                )
                              : Column(
                                  children: selectAllCheckBoxes(setState),
                                ),
                          ...studentHallTicketMap.entries.map((eachEntry) {
                            int eachStudentId = eachEntry.key;
                            StudentProfile eachStudentProfile = studentsForSelectedSection.firstWhere((e) => e.studentId == eachStudentId);
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Row(
                                children: [
                                  Text(
                                    eachStudentProfile.rollNumber ?? "-",
                                    style: TextStyle(color: clayContainerTextColor(context)),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      eachStudentProfile.studentFirstName ?? "-",
                                      style: TextStyle(color: clayContainerTextColor(context)),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Tooltip(
                                    message: eachStudentProfile.getAccommodationType(),
                                    child: ClayContainer(
                                      depth: 20,
                                      surfaceColor: clayContainerColor(context),
                                      parentColor: clayContainerColor(context),
                                      spread: 2,
                                      borderRadius: 2,
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.center,
                                            child: Text(eachStudentProfile.studentAccommodationType ?? "-"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              selected: studentHallTicketMap[eachStudentId] ?? false,
                              value: studentHallTicketMap[eachStudentId] ?? false,
                              onChanged: (bool? selectStatus) {
                                if (selectStatus == null) return;
                                setState(() => studentHallTicketMap[eachStudentId] = selectStatus);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            studentHallTicketMap.values.contains(true)
                ? TextButton(
                    child: const Text("Done"),
                    onPressed: () async {
                      if (studentHallTicketMap.values.contains(true)) {
                        Navigator.pop(context);
                      }
                      await downloadHallTicketsAction();
                    },
                  )
                : const Text("Select at least one student to continue"),
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

  List<CheckboxListTile> selectAllCheckBoxes(StateSetter setState) {
    return [
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Select All"),
        selected: !studentHallTicketMap.values.contains(false),
        value: !studentHallTicketMap.values.contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          setState(() {
            if (selectStatus) {
              for (var eachStudentProfile in studentHallTicketMap.keys) {
                studentHallTicketMap[eachStudentProfile] = true;
              }
            } else {
              for (var eachStudentProfile in studentHallTicketMap.keys) {
                studentHallTicketMap[eachStudentProfile] = false;
              }
            }
          });
        },
      ),
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Clear All"),
        selected: !studentHallTicketMap.values.contains(true),
        value: !studentHallTicketMap.values.contains(true),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          setState(() {
            if (selectStatus) {
              for (var eachStudentProfile in studentHallTicketMap.keys) {
                studentHallTicketMap[eachStudentProfile] = false;
              }
            }
          });
        },
      ),
      CheckboxListTile(
        enabled: studentsForSelectedSection.where((es) => es.studentAccommodationType == "D").isNotEmpty,
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Day Scholar"),
        selected: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "D")
            .map((e) => e.studentId)
            .map((e) => studentHallTicketMap[e])
            .contains(false),
        value: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "D")
            .map((e) => e.studentId)
            .map((e) => studentHallTicketMap[e])
            .contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          if (selectStatus) {
            setState(() {
              studentsForSelectedSection.where((es) => es.studentAccommodationType == "D").map((e) => e.studentId!).forEach((e) {
                studentHallTicketMap[e] = true;
              });
            });
          }
        },
      ),
      CheckboxListTile(
        enabled: studentsForSelectedSection.where((es) => es.studentAccommodationType == "R").isNotEmpty,
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Residential"),
        selected: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "R")
            .map((e) => e.studentId)
            .map((e) => studentHallTicketMap[e])
            .contains(false),
        value: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "R")
            .map((e) => e.studentId)
            .map((e) => studentHallTicketMap[e])
            .contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          if (selectStatus) {
            setState(() {
              studentsForSelectedSection.where((es) => es.studentAccommodationType == "R").map((e) => e.studentId!).forEach((e) {
                studentHallTicketMap[e] = true;
              });
            });
          }
        },
      ),
      CheckboxListTile(
        enabled: studentsForSelectedSection.where((es) => es.studentAccommodationType == "S").isNotEmpty,
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: false,
        title: autoSizeText("Semi Residential"),
        selected: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "S")
            .map((e) => e.studentId)
            .map((e) => studentHallTicketMap[e])
            .contains(false),
        value: !studentsForSelectedSection
            .where((es) => es.studentAccommodationType == "S")
            .map((e) => e.studentId)
            .map((e) => studentHallTicketMap[e])
            .contains(false),
        onChanged: (bool? selectStatus) {
          if (selectStatus == null) return;
          if (selectStatus) {
            setState(() {
              studentsForSelectedSection.where((es) => es.studentAccommodationType == "S").map((e) => e.studentId!).forEach((e) {
                studentHallTicketMap[e] = true;
              });
            });
          }
        },
      ),
    ];
  }

  Widget autoSizeText(String s) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(s),
      );

  Widget sendSmsButton() {
    return Tooltip(
      message: "Send SMS",
      child: GestureDetector(
        onTap: () async {
          Map<StudentProfile, String> studentSmsMap = {};
          if (faExam == null) await _loadExam();
          await _loadSmsTemplate();
          widget.studentsList
              .where((eachStudentProfile) => eachStudentProfile.sectionId == widget.selectedSection?.sectionId)
              .forEach((eachStudentProfile) {
            if (eachStudentProfile.gaurdianMobile == null) return;
            String studentName = (eachStudentProfile.studentFirstName ?? "-").getShortenedMessage(shortLength: 29);
            String shortExamName = (faExam?.faExamName ?? "").split(" ").map((e) => e[0].toUpperCase()).join("");
            List<MapEntry<String, String>> marksPerSubject =
                faExam?.overAllEssmList.where((essm) => essm.sectionId == widget.selectedSection?.sectionId).map((essm) {
                      String subjectName =
                          (widget.subjectsList.firstWhereOrNull((eachSubject) => essm.subjectId == eachSubject.subjectId)?.subjectName ?? "-")
                              .replaceAll(".", "")
                              .substring(0, 2)
                              .toUpperCase();
                      String marksObtained = "";
                      StudentExamMarks? esm =
                          (essm.studentExamMarksList ?? []).firstWhereOrNull((esm) => esm?.studentId == eachStudentProfile.studentId);
                      if (esm == null) {
                        marksObtained = "-";
                      } else if (esm.isAbsent == "N") {
                        marksObtained = "A";
                      } else if (esm.marksObtained == null) {
                        marksObtained = "-";
                      } else {
                        marksObtained = doubleToStringAsFixed(esm.marksObtained);
                      }
                      return MapEntry(subjectName, marksObtained);
                    }).toList() ??
                    [];
            String marksData = marksPerSubject.map((eachEntry) => "${eachEntry.key}:${eachEntry.value}").join("\n");
            String message = "Dear parent,\n"
                "$studentName's Exam marks are\n"
                "\n${("$shortExamName:\n$marksData").getShortenedMessage(shortLength: 60)}\n"
                "\n-EISPL";
            studentSmsMap[eachStudentProfile] = message;
          });
          await getStudentExamMarksForSmsFromAlertDialogue(context, studentSmsMap);
        },
        child: fab(const Icon(Icons.sms), "Send SMS"),
      ),
    );
  }

  Widget updateMarksButton() {
    if (faExam == null) Container();
    return Tooltip(
      message: "Update Marks",
      child: GestureDetector(
        onTap: () async {
          if (faExam == null) await _loadExam();
          FAExam faExamToUpdate = FAExam.fromJson(faExam!.origJson());
          for (FaInternalExam? eachInternal in (faExamToUpdate.faInternalExams ?? [])) {
            (eachInternal?.examSectionSubjectMapList ?? [])
                .removeWhere((essm) => essm?.status != 'active' || essm?.sectionId != widget.selectedSection?.sectionId);
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return FaCumulativeExamMarksScreen(
              schoolInfo: widget.schoolInfo,
              adminProfile: widget.adminProfile,
              teacherProfile: null,
              selectedAcademicYearId: -1,
              sectionsList: widget.sectionsList,
              teachersList: widget.teachersList,
              subjectsList: widget.subjectsList,
              tdsList: widget.tdsList.where((e) => e.sectionId == widget.selectedSection?.sectionId).toList(),
              markingAlgorithm: widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.exam.markingAlgorithmId).firstOrNull,
              faExam: faExamToUpdate,
              selectedSection: widget.selectedSection!,
              loadData: _loadExam,
              studentsList: widget.studentsList,
              isClassTeacher: false,
            );
          })).then((_) => _loadExam());
        },
        child: fab(const Icon(Icons.padding), "Update Marks"),
      ),
    );
  }

  Tooltip editExamButton() {
    return Tooltip(
      message: "Edit Exam",
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return EditFAExamWidget(
              adminProfile: widget.adminProfile,
              teacherProfile: null,
              selectedAcademicYearId: -1,
              sectionsList: widget.sectionsList,
              teachersList: widget.teachersList,
              subjectsList: widget.subjectsList,
              tdsList: widget.tdsList,
              markingAlgorithms: widget.markingAlgorithms,
              faExam: widget.exam,
            );
          })).then((_) {
            refreshExam();
          });
        },
        child: fab(const Icon(Icons.edit), "Edit"),
      ),
    );
  }

  Widget fab(Icon icon, String text, {Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayButton(
        surfaceColor: color ?? clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        spread: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: icon,
                ),
                height: 16,
                width: 16,
              ),
              const SizedBox(width: 8),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }

  Widget circularFab(Icon icon, String text, {Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Tooltip(
        message: text,
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 100,
          spread: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: icon,
              ),
              height: 16,
              width: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget internalsStatsWidget() {
    List<DataColumn> headers =
        ["Section", "Subject", "Teacher", ...(widget.exam.faInternalExams ?? []).map((e) => e?.faInternalExamName ?? "-")].map((e) {
      return DataColumn(label: Text(e));
    }).toList();

    List<DataRow> dataRows = [];
    for (TdsWiseMarksStats eachTdsWiseList
        in tdsWiseList.where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId)) {
      if (eachTdsWiseList.averageMarksStrings.isEmpty ||
          (eachTdsWiseList.averageMarksStrings.toSet().length == 1 && eachTdsWiseList.averageMarksStrings.toSet().firstOrNull == null)) {
        continue;
      }
      TeacherDealingSection? tds = widget.tdsList.firstWhereOrNull(
          (e) => e.teacherId == eachTdsWiseList.teacherId && e.sectionId == eachTdsWiseList.sectionId && e.subjectId == eachTdsWiseList.subjectId);
      if (tds == null) continue;
      dataRows.add(DataRow(
        cells: [
          DataCell(Text(tds.sectionName ?? "-")),
          DataCell(Text(tds.subjectName ?? "-")),
          DataCell(Text(tds.teacherName ?? "-")),
          ...eachTdsWiseList.averageMarksStrings.map(
            (e) => DataCell(
              Center(child: Text(e)),
            ),
          ),
        ],
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scrollbar(
            thumbVisibility: true,
            controller: scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: DataTable(
                  columnSpacing: 12,
                  showCheckboxColumn: false,
                  columns: headers,
                  rows: dataRows,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget examNameWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(widget.exam.faExamName ?? "-"),
              ),
              if (!widget.showMoreOptions && widget.exam.status != 'inactive') editExamButton(),
              if (!widget.showMoreOptions && widget.exam.status != 'inactive') const SizedBox(width: 8),
              if (!_isLoading && isExpanded && !widget.showMoreOptions && widget.exam.status == 'active') deleteExamButton(),
              if (!_isLoading && isExpanded && !widget.showMoreOptions && widget.exam.status == 'active') const SizedBox(width: 8),
              if (!_isLoading && isExpanded && !widget.showMoreOptions && widget.exam.status != 'active') recoverExamButton(),
              if (!_isLoading && isExpanded && !widget.showMoreOptions && widget.exam.status != 'active') const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  setState(() => isExpanded = !isExpanded);
                },
                child: ClayButton(
                  color: clayContainerColor(context),
                  height: 30,
                  width: 30,
                  borderRadius: 50,
                  surfaceColor: clayContainerColor(context),
                  spread: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget deleteExamButton() {
    return Tooltip(
      message: "Delete Exam",
      child: GestureDetector(
        onTap: () async {
          TextEditingController reasonToDeleteController = TextEditingController();
          await showDialog(
            context: context,
            builder: (BuildContext dialogueContext) {
              return AlertDialog(
                title: const Text('Are you sure you want to delete the exam?'),
                content: TextField(
                  onChanged: (value) {},
                  controller: reasonToDeleteController,
                  decoration: InputDecoration(
                    hintText: "Reason to delete",
                    errorText: reasonToDeleteController.text.trim() == "" ? "Reason cannot be empty!" : "",
                  ),
                  autofocus: true,
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () async {
                      if (_isLoading) return;
                      if (reasonToDeleteController.text.trim() == "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Reason to delete cannot be empty.."),
                          ),
                        );
                        Navigator.pop(context);
                        return;
                      }
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      CreateOrUpdateFAExamResponse createOrUpdateFAExamResponse = await createOrUpdateFAExam(CreateOrUpdateFAExamRequest(
                        academicYearId: widget.exam.academicYearId,
                        agent: widget.adminProfile.userId,
                        comment: reasonToDeleteController.text,
                        date: widget.exam.date,
                        examType: widget.exam.examType,
                        faExamId: widget.exam.faExamId,
                        faExamName: widget.exam.faExamName,
                        markingAlgorithmId: widget.exam.markingAlgorithmId,
                        faInternalExams: widget.exam.faInternalExams,
                        examTimeSlots: widget.exam.examTimeSlots,
                        schoolId: widget.exam.schoolId,
                        status: 'inactive',
                      ));
                      if (createOrUpdateFAExamResponse.httpStatus == "OK" && createOrUpdateFAExamResponse.responseStatus == "success") {
                        Navigator.of(context).pop();
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
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: circularFab(
          const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          "Delete exam",
        ),
      ),
    );
  }

  Widget recoverExamButton() {
    return Tooltip(
      message: "Recover Exam",
      child: GestureDetector(
        onTap: () async {
          TextEditingController reasonToRecoverController = TextEditingController();
          await showDialog(
            context: context,
            builder: (BuildContext dialogueContext) {
              return AlertDialog(
                title: const Text('Are you sure you want to recover the exam?'),
                content: TextField(
                  onChanged: (value) {},
                  controller: reasonToRecoverController,
                  decoration: InputDecoration(
                    hintText: "Reason to recover",
                    errorText: reasonToRecoverController.text.trim() == "" ? "Reason cannot be empty!" : "",
                  ),
                  autofocus: true,
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () async {
                      if (_isLoading) return;
                      if (reasonToRecoverController.text.trim() == "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Reason to recover cannot be empty.."),
                          ),
                        );
                        Navigator.pop(context);
                        return;
                      }
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      CreateOrUpdateFAExamResponse createOrUpdateFAExamResponse = await createOrUpdateFAExam(CreateOrUpdateFAExamRequest(
                        academicYearId: widget.exam.academicYearId,
                        agent: widget.adminProfile.userId,
                        comment: reasonToRecoverController.text,
                        date: widget.exam.date,
                        examType: widget.exam.examType,
                        faExamId: widget.exam.faExamId,
                        faExamName: widget.exam.faExamName,
                        markingAlgorithmId: widget.exam.markingAlgorithmId,
                        faInternalExams: widget.exam.faInternalExams,
                        examTimeSlots: widget.exam.examTimeSlots,
                        schoolId: widget.exam.schoolId,
                        status: 'active',
                      ));
                      if (createOrUpdateFAExamResponse.httpStatus == "OK" && createOrUpdateFAExamResponse.responseStatus == "success") {
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong! Try again later.."),
                          ),
                        );
                      }
                      ;
                      setState(() => _isLoading = false);
                    },
                  ),
                  TextButton(
                    child: const Text("No"),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: fab(
          const Icon(
            Icons.undo,
            color: Colors.green,
          ),
          "Recover exam",
        ),
      ),
    );
  }

  Future<void> getStudentExamMarksForSmsFromAlertDialogue(BuildContext context, Map<StudentProfile, String> studentSmsMap) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        Map<StudentProfile, bool> sendSmsMap = studentSmsMap.map((key, value) => MapEntry(key, true));
        return AlertDialog(
          title: const Text("Students' Exam Marks"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              var horizontalScrollView = ScrollController();
              return SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                width: MediaQuery.of(context).size.width - 100,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: horizontalScrollView,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: horizontalScrollView,
                    child: SizedBox(
                      width: max(500, MediaQuery.of(context).size.width - 150),
                      child: ListView(
                        children: [
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            isThreeLine: false,
                            title: const Text("Select All"),
                            selected: !sendSmsMap.values.contains(false),
                            value: !sendSmsMap.values.contains(false),
                            onChanged: (bool? selectStatus) {
                              if (selectStatus == null) return;
                              setState(() {
                                if (selectStatus) {
                                  for (var eachStudentProfile in sendSmsMap.keys) {
                                    sendSmsMap[eachStudentProfile] = true;
                                  }
                                } else {
                                  for (var eachStudentProfile in sendSmsMap.keys) {
                                    sendSmsMap[eachStudentProfile] = false;
                                  }
                                }
                              });
                            },
                          ),
                          ...studentSmsMap.entries.map((eachEntry) {
                            StudentProfile eachStudentProfile = eachEntry.key;
                            String message = eachEntry.value;
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Row(
                                children: [
                                  Text(
                                    eachStudentProfile.rollNumber ?? "-",
                                    style: TextStyle(color: clayContainerTextColor(context)),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                      child: Text(
                                    eachStudentProfile.studentFirstName ?? "-",
                                    style: TextStyle(color: clayContainerTextColor(context)),
                                  )),
                                  const SizedBox(width: 5),
                                  Text(
                                    eachStudentProfile.gaurdianMobile ?? "-",
                                    style: TextStyle(color: clayContainerTextColor(context)),
                                  ),
                                  const SizedBox(width: 5),
                                  Tooltip(
                                    message: message,
                                    child: const Icon(Icons.info_outline),
                                  ),
                                ],
                              ),
                              selected: sendSmsMap[eachStudentProfile] ?? false,
                              value: sendSmsMap[eachStudentProfile] ?? false,
                              onChanged: (bool? selectStatus) {
                                if (selectStatus == null) return;
                                setState(() => sendSmsMap[eachStudentProfile] = selectStatus);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            if (sendSmsMap.values.contains(true))
              TextButton(
                child: const Text("Proceed to send SMS"),
                onPressed: () async {
                  if (!sendSmsMap.values.contains(true)) return;
                  Navigator.pop(context);
                  SendSmsResponse sendSmsResponse = await sendSms(SendSmsRequest(
                      schoolId: smsTemplate?.schoolId,
                      categoryId: smsTemplate?.categoryId,
                      templateId: smsTemplate?.templateId,
                      agent: widget.adminProfile.userId,
                      comments: "Sending SMS to notify class ${widget.selectedSection?.sectionName ?? "-"} for ${widget.exam.faExamName}",
                      smsLogBeans: [
                        ...studentSmsMap.keys.where((eachStudentProfile) => sendSmsMap[eachStudentProfile] ?? false).map((eachStudentProfile) {
                          String message = studentSmsMap[eachStudentProfile] ?? "";
                          String mobile = (eachStudentProfile.gaurdianMobile ?? "").lastChars(lastLength: 10);
                          return SmsLogBean(
                            agent: widget.adminProfile.userId,
                            message: message,
                            phone: mobile,
                            smsLogId: null,
                            smsTemplateWiseLogId: null,
                            status: "initiated",
                            studentId: eachStudentProfile.studentId,
                            userId: eachStudentProfile.gaurdianId,
                          );
                        })
                      ]));
                  if (sendSmsResponse.httpStatus != "OK" || sendSmsResponse.responseStatus != "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong! Try again later.."),
                      ),
                    );
                  }
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
}

class TdsWiseMarksStats {
  int? subjectId;
  int? sectionId;
  int? teacherId;
  List<String> averageMarksStrings = [];

  TdsWiseMarksStats(this.subjectId, this.sectionId, this.teacherId, this.averageMarksStrings);

  TdsWiseMarksStats.fromAverageMarksAndMaxMarks(this.subjectId, this.sectionId, this.teacherId, List<double?> averageMarks, List<double?> maxMarks) {
    for (int i = 0; i < averageMarks.length; i++) {
      averageMarksStrings.add(maxMarks[i] == null
          ? "-"
          : averageMarks[i] == null
              ? "-/${doubleToStringAsFixed(maxMarks[i])}"
              : "${doubleToStringAsFixed(averageMarks[i])}/${doubleToStringAsFixed(maxMarks[i])}");
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsWiseMarksStats &&
          runtimeType == other.runtimeType &&
          subjectId == other.subjectId &&
          sectionId == other.sectionId &&
          teacherId == other.teacherId;

  @override
  int get hashCode => subjectId.hashCode ^ sectionId.hashCode ^ teacherId.hashCode;

  @override
  String toString() {
    return 'TdsWiseMarksStats{subjectId: $subjectId, sectionId: $sectionId, teacherId: $teacherId, averageMarksStrings: $averageMarksStrings}';
  }
}
