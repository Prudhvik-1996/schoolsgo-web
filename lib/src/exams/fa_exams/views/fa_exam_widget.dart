import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:schoolsgo_web/src/attendance/model/month_wise_attendance.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_cumulative_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/fa_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/edit_fa_exam_widget.dart';
import 'package:schoolsgo_web/src/exams/model/constants.dart';
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
import 'package:schoolsgo_web/src/utils/list_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

import 'each_student_pdf_download.dart';

class FAExamWidget extends StatefulWidget {
  const FAExamWidget({
    super.key,
    required this.schoolInfo,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.faExam,
    required this.studentsList,
    required this.loadData,
    required this.editingEnabled,
    required this.selectedSection,
    required this.markingAlgorithms,
    required this.scaffoldKey,
    required this.setLoading,
    required this.isClassTeacher,
    required this.smsTemplate,
    required this.examMemoHeader,
    required this.principalSignature,
  });

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final FAExam faExam;
  final List<StudentProfile> studentsList;
  final Future<void> Function() loadData;
  final bool editingEnabled;
  final Section? selectedSection;
  final List<MarkingAlgorithmBean> markingAlgorithms;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final void Function(bool isLoading) setLoading;
  final bool isClassTeacher;
  final SmsTemplateBean? smsTemplate;
  final String? examMemoHeader;
  final String? principalSignature;

  @override
  State<FAExamWidget> createState() => _FAExamWidgetState();
}

class _FAExamWidgetState extends State<FAExamWidget> {
  List<FaInternalExam> internals = [];
  List<ExamSectionSubjectMap> examSectionSubjectMapList = [];
  List<TeacherDealingSection> tdsList = [];

  bool _isExpanded = false;
  String? downloadMessage;

  @override
  void initState() {
    super.initState();
    internals = (widget.faExam.faInternalExams ?? [])
        .map((e) => e!)
        .where((e) =>
            widget.selectedSection == null ||
            (e.examSectionSubjectMapList ?? []).map((e) => e?.sectionId).contains(widget.selectedSection?.sectionId))
        .where((e) =>
            widget.isClassTeacher ||
            widget.teacherProfile == null ||
            (e.examSectionSubjectMapList ?? []).map((e) => e?.authorisedAgent).contains(widget.teacherProfile?.teacherId))
        .toList();
    examSectionSubjectMapList = internals
        .map((e) => (e.examSectionSubjectMapList ?? []))
        .expand((i) => i)
        .map((e) => e!)
        .where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId)
        .where((e) => widget.isClassTeacher || widget.teacherProfile == null || e.authorisedAgent == (widget.teacherProfile?.teacherId))
        .toList();
    tdsList = widget.tdsList
        .where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId)
        .where((e) => e.status == 'active')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
          margin: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              faExamNameWidget(),
              if (_isExpanded) const SizedBox(height: 15),
              if (_isExpanded) ...populatedExamsLists(),
              if (_isExpanded) const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> populatedExamsLists() {
    List<Widget> widgetsOfEachInternal = [];
    for (FaInternalExam eachInternal in internals) {
      ScrollController controller = ScrollController();
      List<ExamSectionSubjectMap> essmListForInternal = examSectionSubjectMapList
          .where((e) => e.status == 'active')
          .where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId)
          .where((e) => e.examId == eachInternal.faInternalExamId && e.masterExamId == eachInternal.masterExamId)
          .where((e) => widget.isClassTeacher || widget.teacherProfile == null || e.authorisedAgent == (widget.teacherProfile?.teacherId))
          .toList();
      essmListForInternal.sort((a, b) {
        int aSectionSeqOrder = widget.sectionsList.firstWhereOrNull((e) => a.sectionId == e.sectionId)?.seqOrder ?? -1;
        int bSectionSeqOrder = widget.sectionsList.firstWhereOrNull((e) => b.sectionId == e.sectionId)?.seqOrder ?? -1;
        int aSubjectSeqOrder = widget.subjectsList.firstWhereOrNull((e) => a.subjectId == e.subjectId)?.seqOrder ?? -1;
        int bSubjectSeqOrder = widget.subjectsList.firstWhereOrNull((e) => b.subjectId == e.subjectId)?.seqOrder ?? -1;
        if (aSectionSeqOrder == bSectionSeqOrder) return aSubjectSeqOrder.compareTo(bSubjectSeqOrder);
        return aSectionSeqOrder.compareTo(bSectionSeqOrder);
      });
      widgetsOfEachInternal.add(Container(
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
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        eachInternal.faInternalExamName ?? "-",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // if (widget.isClassTeacher || widget.teacherProfile == null && widget.editingEnabled) hallTicketsButton(widget.faExam, eachInternal),
                    if (widget.selectedSection != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Tooltip(
                          message: "Download Hall Tickets",
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                _isExpanded = false;
                              });
                              await Future.delayed(const Duration(seconds: 1));
                              await EachStudentPdfDownloadForFaExam(
                                schoolInfo: widget.schoolInfo,
                                adminProfile: widget.adminProfile,
                                teacherProfile: widget.teacherProfile,
                                selectedAcademicYearId: widget.selectedAcademicYearId,
                                teachersList: widget.teachersList,
                                subjectsList: widget.subjectsList,
                                tdsList: widget.tdsList,
                                markingAlgorithm:
                                    widget.markingAlgorithms.where((em) => em.markingAlgorithmId == widget.faExam.markingAlgorithmId).firstOrNull,
                                faExam: widget.faExam,
                                selectedInternal: eachInternal,
                                studentProfiles: widget.studentsList.where((es) => es.sectionId == widget.selectedSection?.sectionId).toList(),
                                selectedSection: widget.selectedSection!,
                                updateMessage: (String? e) => setState(() => downloadMessage = e),
                                examMemoHeader: widget.examMemoHeader,
                                principalSignature: widget.principalSignature,
                              ).downloadHallTickets();
                              setState(() {
                                _isExpanded = true;
                              });
                            },
                            child: ClayButton(
                              color: clayContainerColor(context),
                              height: 50,
                              borderRadius: 10,
                              surfaceColor: clayContainerColor(context),
                              spread: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.download),
                                      SizedBox(width: 10),
                                      Text("Hall Tickets"),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Scrollbar(
                  thumbVisibility: true,
                  controller: controller,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: [
                          "Section",
                          "Subject",
                          "Teacher",
                          "Avg Marks",
                          "Max Marks",
                          "Date",
                          "Start Time",
                          "End Time",
                        ].map((e) => DataColumn(label: Center(child: Text(e)))).toList(),
                        rows: [
                          ...essmListForInternal
                              .where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId)
                              .where((e) =>
                                  widget.isClassTeacher || widget.teacherProfile == null || e.authorisedAgent == (widget.teacherProfile?.teacherId))
                              .map(
                                (eachExamSectionSubjectMap) => DataRow(
                                  onSelectChanged: (bool? selected) {
                                    if (selected ?? false) {
                                      goToMarksScreen(eachInternal, eachExamSectionSubjectMap);
                                    }
                                  },
                                  cells: [
                                    dataCellWidget(
                                      InkWell(
                                        onTap: () => goToMarksScreen(eachInternal, eachExamSectionSubjectMap),
                                        child: Text(
                                          widget.sectionsList.firstWhere((e) => e.sectionId == eachExamSectionSubjectMap.sectionId).sectionName ??
                                              "-",
                                        ),
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
                                      Text("${eachExamSectionSubjectMap.classAverage ?? " - "}"),
                                    ),
                                    dataCellWidget(
                                      Text("${eachExamSectionSubjectMap.maxMarks ?? " - "}"),
                                    ),
                                    dataCellWidget(Text(eachExamSectionSubjectMap.examDate)),
                                    dataCellWidget(Text(eachExamSectionSubjectMap.startTimeSlot)),
                                    dataCellWidget(Text(eachExamSectionSubjectMap.endTimeSlot)),
                                  ],
                                ),
                              ),
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
    return widgetsOfEachInternal;
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
                      schoolId: widget.smsTemplate?.schoolId,
                      categoryId: widget.smsTemplate?.categoryId,
                      templateId: widget.smsTemplate?.templateId,
                      agent: widget.adminProfile?.userId,
                      comments: "Sending SMS to notify class ${widget.selectedSection?.sectionName ?? "-"} for ${widget.faExam.faExamName}",
                      smsLogBeans: [
                        ...studentSmsMap.keys.where((eachStudentProfile) => sendSmsMap[eachStudentProfile] ?? false).map((eachStudentProfile) {
                          String message = studentSmsMap[eachStudentProfile] ?? "";
                          String mobile = (eachStudentProfile.gaurdianMobile ?? "").lastChars(lastLength: 10);
                          return SmsLogBean(
                            agent: widget.adminProfile?.userId,
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

  void goToMarksScreen(FaInternalExam internal, ExamSectionSubjectMap eachExamSectionSubjectMap) {
    TeacherDealingSection? tds = widget.tdsList
        .where((eachTds) =>
            eachTds.sectionId == eachExamSectionSubjectMap.sectionId &&
            eachTds.subjectId == eachExamSectionSubjectMap.subjectId &&
            eachTds.teacherId == eachExamSectionSubjectMap.authorisedAgent)
        .firstOrNull;
    if (tds == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FAExamMarksScreen(
        adminProfile: widget.adminProfile,
        teacherProfile: widget.teacherProfile,
        selectedAcademicYearId: widget.selectedAcademicYearId,
        sectionsList: widget.sectionsList,
        teachersList: widget.teachersList,
        tds: tds,
        faExam: widget.faExam,
        faInternalExam: internal,
        studentsList: widget.studentsList,
        examSectionSubjectMap: eachExamSectionSubjectMap,
        loadData: widget.loadData,
      );
    }));
  }

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

  Widget faExamNameWidget() {
    if (!_isExpanded) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(widget.faExam.faExamName ?? "-")),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: ClayButton(
                  color: clayContainerColor(context),
                  height: 30,
                  width: 30,
                  borderRadius: 50,
                  surfaceColor: clayContainerColor(context),
                  spread: 1,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
          if (downloadMessage != null) renderingPdfWidget()
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            widget.faExam.faExamName ?? "-",
            style: TextStyle(
              fontSize: _isExpanded ? 21 : null,
              fontWeight: _isExpanded ? FontWeight.bold : null,
            ),
          ),
        ),
        if (widget.selectedSection != null)
          Container(
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Tooltip(
              message: "Send SMS",
              child: GestureDetector(
                onTap: () async {
                  Map<StudentProfile, String> studentSmsMap = {};
                  widget.studentsList
                      .where((eachStudentProfile) => eachStudentProfile.sectionId == widget.selectedSection?.sectionId)
                      .forEach((eachStudentProfile) {
                    if (eachStudentProfile.gaurdianMobile == null) return;
                    String phoneNumber = eachStudentProfile.gaurdianMobile ?? "";
                    String studentName = (eachStudentProfile.studentFirstName ?? "-").getShortenedMessage(shortLength: 29);
                    String shortExamName = (widget.faExam.faExamName ?? "").split(" ").map((e) => e[0].toUpperCase()).join("");
                    List<MapEntry<String, String>> marksPerSubject =
                        widget.faExam.overAllEssmList.where((essm) => essm.sectionId == widget.selectedSection?.sectionId).map((essm) {
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
                  setState(() {
                    _isExpanded = true;
                  });
                  // await Future.delayed(const Duration(seconds: 1));
                  // studentSmsMap.forEach((eachStudentProfile, message) {
                  //   print("${eachStudentProfile.gaurdianMobile}: $message\n");
                  // });
                  await getStudentExamMarksForSmsFromAlertDialogue(context, studentSmsMap);
                  setState(() {
                    _isExpanded = false;
                  });
                },
                child: ClayButton(
                  color: clayContainerColor(context),
                  height: 50,
                  borderRadius: 10,
                  surfaceColor: clayContainerColor(context),
                  spread: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.message),
                          SizedBox(width: 10),
                          Text("Send Message"),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (widget.selectedSection != null)
          Container(
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Tooltip(
              message: "Download all memos",
              child: GestureDetector(
                onTap: () async {
                  AttendanceType attendanceType = await getAttendanceTypeFromAlertDialogue(context);
                  setState(() {
                    _isExpanded = false;
                  });
                  List<StudentMonthWiseAttendance> studentMonthWiseAttendanceList = [];
                  if (attendanceType == AttendanceType.WITH) {
                    setState(() {
                      downloadMessage = "Getting attendance report";
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    GetStudentMonthWiseAttendanceResponse getStudentMonthWiseAttendanceResponse =
                        await getStudentMonthWiseAttendance(GetStudentMonthWiseAttendanceRequest(
                      schoolId: widget.schoolInfo.schoolId,
                      sectionId: widget.selectedSection?.sectionId,
                      academicYearId: widget.faExam.academicYearId,
                      isAdminView: "Y",
                      studentId: null,
                    ));
                    if (getStudentMonthWiseAttendanceResponse.httpStatus != "OK" ||
                        getStudentMonthWiseAttendanceResponse.responseStatus != "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong! Try again later.."),
                        ),
                      );
                    } else {
                      studentMonthWiseAttendanceList =
                          (getStudentMonthWiseAttendanceResponse.studentMonthWiseAttendanceList ?? []).whereNotNull().toList();
                    }
                    setState(() => downloadMessage = "Got the attendance report");
                  }
                  await EachStudentPdfDownloadForFaExam(
                    schoolInfo: widget.schoolInfo,
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    tdsList: widget.tdsList,
                    markingAlgorithm: widget.markingAlgorithms.where((em) => em.markingAlgorithmId == widget.faExam.markingAlgorithmId).firstOrNull,
                    faExam: widget.faExam,
                    studentProfiles: widget.studentsList.where((es) => es.sectionId == widget.selectedSection?.sectionId).toList(),
                    selectedSection: widget.selectedSection!,
                    updateMessage: (String? e) => setState(() => downloadMessage = e),
                    selectedInternal: null,
                    examMemoHeader: widget.examMemoHeader,
                    principalSignature: widget.principalSignature,
                  ).downloadMemo(studentMonthWiseAttendanceList, attendanceType: attendanceType);
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: ClayButton(
                  color: clayContainerColor(context),
                  height: 50,
                  borderRadius: 10,
                  surfaceColor: clayContainerColor(context),
                  spread: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.download),
                          SizedBox(width: 10),
                          Text("Memos"),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (widget.selectedSection != null)
          Tooltip(
            message: "Update Marks",
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FaCumulativeExamMarksScreen(
                    schoolInfo: widget.schoolInfo,
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    sectionsList: widget.sectionsList,
                    teachersList: widget.teachersList,
                    subjectsList: widget.subjectsList,
                    tdsList: widget.tdsList,
                    markingAlgorithm: widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.faExam.markingAlgorithmId).firstOrNull,
                    faExam: widget.faExam,
                    selectedSection: widget.selectedSection!,
                    loadData: widget.loadData,
                    studentsList: widget.studentsList,
                    isClassTeacher: widget.isClassTeacher,
                    examMemoHeader: widget.examMemoHeader,
                  );
                })).then((_) => widget.loadData());
              },
              child: ClayButton(
                color: clayContainerColor(context),
                height: 30,
                width: 130,
                borderRadius: 50,
                surfaceColor: clayContainerColor(context),
                spread: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.score_outlined),
                        SizedBox(width: 10),
                        Text("Update Marks"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (widget.editingEnabled) const SizedBox(width: 15),
        if (widget.editingEnabled)
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EditFAExamWidget(
                  adminProfile: widget.adminProfile,
                  teacherProfile: widget.teacherProfile,
                  selectedAcademicYearId: widget.selectedAcademicYearId,
                  sectionsList: widget.sectionsList,
                  teachersList: widget.teachersList,
                  subjectsList: widget.subjectsList,
                  tdsList: widget.tdsList,
                  markingAlgorithms: widget.markingAlgorithms,
                  faExam: widget.faExam,
                );
              })).then((_) => widget.loadData());
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 30,
              width: 30,
              borderRadius: 50,
              surfaceColor: clayContainerColor(context),
              spread: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.edit),
                ),
              ),
            ),
          ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = false;
            });
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            spread: 1,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(Icons.arrow_drop_up),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget renderingPdfWidget() {
    return Container(
      color: Colors.grey.withOpacity(0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Image.asset(
              'assets/images/eis_loader.gif',
              height: 100,
              width: 100,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              downloadMessage ?? "",
              style: const TextStyle(fontSize: 9),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget hallTicketsButton(FAExam faExam, FaInternalExam eachInternal) {
    return GestureDetector(
      onTap: () async {
        List<StudentProfile> selectedStudentsForHallTickets = widget.studentsList
            .where((e) => (eachInternal.examSectionSubjectMapList ?? []).map((essm) => essm?.sectionId).contains(e.sectionId))
            .map((e) => StudentProfile.fromJson(e.origJson()))
            .toList();
        List<StudentProfile> studentsMatchedWithSearchKey = widget.studentsList
            .where((e) => (eachInternal.examSectionSubjectMapList ?? []).map((essm) => essm?.sectionId).contains(e.sectionId))
            .map((e) => StudentProfile.fromJson(e.origJson()))
            .toList();
        List<Section> mappedSections = widget.sectionsList
            .where((eachSection) => (eachInternal.examSectionSubjectMapList ?? []).map((essm) => essm?.sectionId).contains(eachSection.sectionId))
            .map((e) => Section.fromJson(e.toJson()))
            .toList();
        String searchKey = '';
        await showDialog(
          context: widget.scaffoldKey.currentContext!,
          builder: (currentContext) {
            return AlertDialog(
              title: const Text("Hall Tickets"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: clayContainerColor(context),
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 2,
                        child: CustomScrollView(
                          slivers: [
                            ...mappedSections
                                .where((eachSection) => studentsMatchedWithSearchKey.any((e) => e.sectionId == eachSection.sectionId))
                                .map(
                              (Section eachSection) {
                                return SliverStickyHeader.builder(
                                  builder: (context, state) => Container(
                                    color: clayContainerColor(context),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (searchKey == '') const SizedBox(width: 10),
                                        if (searchKey == '')
                                          Checkbox(
                                            value: selectedStudentsForHallTickets.where((e) => e.sectionId == eachSection.sectionId).length ==
                                                    widget.studentsList.where((e) => e.sectionId == eachSection.sectionId).length &&
                                                widget.studentsList.where((e) => e.sectionId == eachSection.sectionId).isNotEmpty,
                                            onChanged: (bool? newValue) {
                                              if (newValue == null) return;
                                              setState(() {
                                                if (newValue) {
                                                  selectedStudentsForHallTickets.removeWhere((e) => e.sectionId == eachSection.sectionId);
                                                  selectedStudentsForHallTickets
                                                      .addAll(studentsMatchedWithSearchKey.where((e) => e.sectionId == eachSection.sectionId));
                                                } else {
                                                  selectedStudentsForHallTickets.removeWhere((e) => e.sectionId == eachSection.sectionId);
                                                }
                                              });
                                            },
                                          ),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(eachSection.sectionName ?? "-")),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        StudentProfile eachStudent = studentsMatchedWithSearchKey
                                            .where((eachStudent) => eachStudent.sectionId == eachSection.sectionId)
                                            .toList()
                                            .tryGet(i);
                                        return Container(
                                          color: clayContainerColor(context),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 20),
                                              Checkbox(
                                                value: selectedStudentsForHallTickets.map((e) => e.studentId).contains(eachStudent.studentId),
                                                onChanged: (bool? newValue) {
                                                  if (newValue == null) return;
                                                  setState(() {
                                                    if (newValue) {
                                                      selectedStudentsForHallTickets.add(eachStudent);
                                                    } else {
                                                      selectedStudentsForHallTickets.removeWhere((e) => e.studentId == eachStudent.studentId);
                                                    }
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                  child: Text(eachStudent.rollNumber == null
                                                      ? eachStudent.studentFirstName ?? "-"
                                                      : "${eachStudent.rollNumber}. ${eachStudent.studentFirstName}")),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        );
                                      },
                                      childCount:
                                          studentsMatchedWithSearchKey.where((eachStudent) => eachStudent.sectionId == eachSection.sectionId).length,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              selectedStudentsForHallTickets.clear();
                              selectedStudentsForHallTickets.addAll(widget.studentsList.map((e) => StudentProfile.fromJson(e.origJson())));
                            }),
                            child: ClayButton(
                              depth: 40,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              spread: 1,
                              borderRadius: 25,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: const Center(child: Text("Select All", style: TextStyle(fontSize: 9))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              maxLines: 1,
                              initialValue: '',
                              decoration: const InputDecoration(
                                labelText: 'Search Student',
                                hintText: 'Search Student',
                              ),
                              onChanged: (String? newValue) => setState(() {
                                searchKey = (newValue ?? "").trim();
                                studentsMatchedWithSearchKey = searchKey == ""
                                    ? widget.studentsList.map((e) => StudentProfile.fromJson(e.origJson())).toList()
                                    : widget.studentsList
                                        .map((e) => StudentProfile.fromJson(e.origJson()))
                                        .where((eachStudent) => "${eachStudent.rollNumber}. ${eachStudent.studentFirstName}"
                                            .toLowerCase()
                                            .contains(searchKey.toLowerCase()))
                                        .toList();
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => setState(() => selectedStudentsForHallTickets.clear()),
                            child: ClayButton(
                              depth: 40,
                              surfaceColor: clayContainerColor(context),
                              parentColor: clayContainerColor(context),
                              spread: 1,
                              borderRadius: 25,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: const Center(child: Text("Clear All", style: TextStyle(fontSize: 9))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // downloadHallTickets(context, widget.adminProfile!, faExam, eachInternal, selectedStudentsForHallTickets, widget.subjectsList);
                    widget.setLoading(true);
                    List<int> bytes = await downloadHallTicketsFromWeb(
                      widget.adminProfile!.schoolId!,
                      widget.selectedAcademicYearId,
                      selectedStudentsForHallTickets.map((e) => e.studentId).whereNotNull().toList(),
                      widget.faExam.faExamId!,
                      eachInternal.faInternalExamId!,
                    );
                    AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
                      ..setAttribute("download", "Hall Tickets for ${widget.faExam.faExamName ?? "-"} - ${eachInternal.faInternalExamName}.xls")
                      ..click();
                    widget.setLoading(false);
                  },
                  child: const Text("YES"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                ),
              ],
            );
          },
        );
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 30,
        width: 130,
        borderRadius: 50,
        surfaceColor: clayContainerColor(context),
        spread: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                child: const Icon(Icons.file_copy_outlined),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text("Hall Tickets")),
          ],
        ),
      ),
    );
  }
}
