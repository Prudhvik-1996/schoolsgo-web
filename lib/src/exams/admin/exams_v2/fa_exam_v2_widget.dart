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
import 'package:schoolsgo_web/src/exams/fa_exams/views/each_student_pdf_download.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/edit_fa_exam_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    for (TeacherDealingSection eachTds in widget.tdsList) {
      List<double?> tdsWiseMarks = [];
      for (FaInternalExam? eachInternal in (widget.exam.faInternalExams ?? [])) {
        tdsWiseMarks.add((eachInternal?.examSectionSubjectMapList ?? [])
            .where((essm) =>
                essm?.status == 'active' &&
                essm?.sectionId == eachTds.sectionId &&
                essm?.subjectId == eachTds.subjectId &&
                essm?.authorisedAgent == eachTds.teacherId)
            .firstOrNull
            ?.averageMarksObtained);
      }
      tdsWiseList.add(TdsWiseMarksStats(eachTds.subjectId, eachTds.sectionId, eachTds.teacherId, tdsWiseMarks));
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
                if (!_isLoading && isExpanded) moreOptionsWidget(),
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
          editExamButton(),
          const SizedBox(width: 12),
          updateMarksButton(),
          const SizedBox(width: 12),
          sendSmsButton(),
          const SizedBox(width: 12),
          downloadHallTicketsButton(),
        ],
      ),
    );
  }

  Widget downloadHallTicketsButton() {
    return Tooltip(
      message: "Download Hall Tickets",
      child: GestureDetector(
        onTap: () async {
          int? selectedExamId;
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext dialogueContext) {
              return AlertDialog(
                title: const Text('Select exam to download hall tickets.'),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView(
                        children: [
                          ...(widget.exam.faInternalExams ?? []).map((e) => RadioListTile<int?>(
                              title: Text(e?.faInternalExamName ?? "-"),
                              value: e?.faInternalExamId,
                              groupValue: selectedExamId,
                              onChanged: (int? newThing) => setState(() => selectedExamId = newThing))),
                        ],
                      ),
                    );
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Proceed to print"),
                    onPressed: () async {
                      if (selectedExamId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Select the exam you want to print the hall tickets for."),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
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
          setState(() => _isLoading = true);
          await EachStudentPdfDownloadForFaExam(
            schoolInfo: widget.schoolInfo,
            adminProfile: widget.adminProfile,
            teacherProfile: null,
            selectedAcademicYearId: -1,
            teachersList: widget.teachersList,
            subjectsList: widget.subjectsList,
            tdsList: widget.tdsList,
            markingAlgorithm: widget.markingAlgorithms.where((em) => em.markingAlgorithmId == widget.exam.markingAlgorithmId).firstOrNull,
            faExam: widget.exam,
            selectedInternal: (widget.exam.faInternalExams ?? []).firstWhereOrNull((e) => e?.faInternalExamId == selectedExamId),
            studentProfiles: widget.studentsList.where((es) => es.sectionId == widget.selectedSection?.sectionId).toList(),
            selectedSection: widget.selectedSection!,
            updateMessage: (String? e) => setState(() => downloadMessage = e),
          ).downloadHallTickets();
          setState(() {
            downloadMessage = null;
            _isLoading = false;
          });
        },
        child: fab(const Icon(Icons.download), "Hall Tickets"),
      ),
    );
  }

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

  Tooltip updateMarksButton() {
    return Tooltip(
      message: "Update Marks",
      child: GestureDetector(
        onTap: () async {
          if (faExam == null) await _loadExam();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return FaCumulativeExamMarksScreen(
              schoolInfo: widget.schoolInfo,
              adminProfile: widget.adminProfile,
              teacherProfile: null,
              selectedAcademicYearId: -1,
              sectionsList: widget.sectionsList,
              teachersList: widget.teachersList,
              subjectsList: widget.subjectsList,
              tdsList: widget.tdsList,
              markingAlgorithm: widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.exam.markingAlgorithmId).firstOrNull,
              faExam: faExam!,
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

  Widget internalsStatsWidget() {
    List<DataColumn> headers = ["Section", "Subject", "Teacher", ...(widget.exam.faInternalExams ?? []).map((e) => e?.faInternalExamName ?? "-")]
        .map((e) => DataColumn(label: Text(e)))
        .toList();

    List<DataRow> dataRows = [];
    for (TdsWiseMarksStats eachTdsWiseList
        in tdsWiseList.where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId)) {
      if (eachTdsWiseList.averageMarks.isEmpty ||
          (eachTdsWiseList.averageMarks.toSet().length == 1 && eachTdsWiseList.averageMarks.toSet().firstOrNull == null)) {
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
          ...eachTdsWiseList.averageMarks.map(
            (e) => DataCell(
              Center(
                child: Text(
                  e == null ? "N/A" : doubleToStringAsFixed(e),
                ),
              ),
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
  List<double?> averageMarks = [];

  TdsWiseMarksStats(this.subjectId, this.sectionId, this.teacherId, this.averageMarks);

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
}
