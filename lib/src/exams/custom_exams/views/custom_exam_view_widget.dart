import 'dart:math';

import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/custom_exams_all_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/each_student_pdf_download.dart';
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
import 'package:schoolsgo_web/src/student_information_center/modal/month_wise_attendance.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class CustomExamViewWidget extends StatefulWidget {
  const CustomExamViewWidget({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.customExam,
    required this.studentsList,
    required this.loadData,
    required this.selectedSection,
    required this.markingAlgorithms,
    required this.schoolInfo,
    required this.isClassTeacher,
    required this.smsTemplate,
  }) : super(key: key);

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final CustomExam customExam;
  final List<StudentProfile> studentsList;
  final Future<void> Function() loadData;
  final Section? selectedSection;
  final List<MarkingAlgorithmBean> markingAlgorithms;
  final bool isClassTeacher;
  final SmsTemplateBean? smsTemplate;

  @override
  State<CustomExamViewWidget> createState() => _CustomExamViewWidgetState();
}

class _CustomExamViewWidgetState extends State<CustomExamViewWidget> {
  final ScrollController _controller = ScrollController();
  List<ExamSectionSubjectMap> examSectionSubjectMapList = [];
  List<TeacherDealingSection> tdsList = [];

  bool _isExpanded = false;
  bool _isLoading = false;

  String? downloadMessage;

  @override
  void initState() {
    super.initState();
    examSectionSubjectMapList = (widget.customExam.examSectionSubjectMapList ?? []).map((e) => e!).toList();
    tdsList = widget.tdsList.where((e) => e.status == 'active').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: ClayContainer(
        emboss: _isExpanded,
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
              customExamNameWidget(),
              if (_isExpanded) const SizedBox(height: 15),
              if (_isExpanded) populatedTdsList(),
              if (_isExpanded) const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget populatedTdsList() {
    return Column(
      children: [
        ...examSectionSubjectMapList.where((e) => widget.selectedSection == null || e.sectionId == widget.selectedSection?.sectionId).map(
              (eachExamSectionSubjectMap) => Container(
                margin: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () => goToMarksScreen(eachExamSectionSubjectMap),
                  child: ClayButton(
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Class: ${widget.sectionsList.firstWhere((e) => e.sectionId == eachExamSectionSubjectMap.sectionId).sectionName ?? " - "}",
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Subject: ${tdsList.firstWhere((e) => e.subjectId == eachExamSectionSubjectMap.subjectId).subjectName ?? " - "}",
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Card(
                                        color: Colors.blue,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(eachExamSectionSubjectMap.examDate),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Card(
                                            color: Colors.blueGrey,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(eachExamSectionSubjectMap.startTimeSlot),
                                            ),
                                          ),
                                          Card(
                                            color: Colors.blueGrey,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(eachExamSectionSubjectMap.endTimeSlot),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Max Marks: ${eachExamSectionSubjectMap.maxMarks ?? " - "}",
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Class Average: ${eachExamSectionSubjectMap.classAverage ?? " - "}",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Absentees: ${(eachExamSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.isAbsent == 'N').length}",
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Highest Marks: ${(eachExamSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.isAbsent != 'N').map((e) => e?.marksObtained).whereNotNull().maxOrNull ?? " - "}",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  void goToMarksScreen(ExamSectionSubjectMap eachExamSectionSubjectMap) {
    TeacherDealingSection? tds = widget.tdsList
        .where((eachTds) =>
            eachTds.sectionId == eachExamSectionSubjectMap.sectionId &&
            eachTds.subjectId == eachExamSectionSubjectMap.subjectId &&
            eachTds.teacherId == eachExamSectionSubjectMap.authorisedAgent)
        .firstOrNull;
    if (tds == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CustomExamMarksScreen(
        adminProfile: widget.adminProfile,
        teacherProfile: widget.teacherProfile,
        selectedAcademicYearId: widget.selectedAcademicYearId,
        sectionsList: widget.sectionsList,
        teachersList: widget.teachersList,
        tds: tds,
        customExam: widget.customExam,
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
      clayCell(isCenter, child),
    );
  }

  Container clayCell(bool isCenter, Widget child) {
    return Container(
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
    );
  }

  Widget customExamNameWidget() {
    if (!_isExpanded) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(widget.customExam.customExamName ?? "-")),
              const SizedBox(width: 15),
              Text(widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull?.algorithmName ??
                  "-"),
              const SizedBox(width: 15),
              if (downloadMessage == null)
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(widget.customExam.customExamName ?? "-")),
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
        ),
        if (widget.selectedSection != null) const SizedBox(height: 30),
        if (widget.selectedSection != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.markingAlgorithms
                          .where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId)
                          .firstOrNull
                          ?.algorithmName ??
                      "-",
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Marking Algorithm",
                    hintText: "Marking Algorithm",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Tooltip(
                  message: "Marks",
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return CustomExamsAllMarksScreen(
                          schoolInfo: widget.schoolInfo,
                          adminProfile: widget.adminProfile,
                          teacherProfile: widget.teacherProfile,
                          selectedAcademicYearId: widget.selectedAcademicYearId,
                          sectionsList: widget.sectionsList,
                          teachersList: widget.teachersList,
                          subjectsList: widget.subjectsList,
                          tdsList: widget.tdsList,
                          customExam: widget.customExam,
                          selectedSection: widget.selectedSection!,
                          loadData: widget.loadData,
                          studentsList: widget.studentsList.where((es) => es.sectionId == widget.selectedSection?.sectionId).toList(),
                          markingAlgorithm: widget.customExam.markingAlgorithmId == null
                              ? null
                              : widget.markingAlgorithms.where((e) => e.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull,
                        );
                      })).then((_) => widget.loadData());
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
                              Icon(Icons.score_outlined),
                              SizedBox(width: 10),
                              Text("Marks"),
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
                          _isLoading = true;
                          _isExpanded = false;
                        });
                        List<StudentMonthWiseAttendance> studentMonthWiseAttendanceList = [];
                        if (attendanceType == AttendanceType.WITH) {
                          setState(() {
                            downloadMessage = "Getting attendance report";
                          });
                          await Future.delayed(const Duration(seconds: 1));
                          List<StudentMonthWiseAttendance> studentMonthWiseAttendanceList = [];
                          GetStudentMonthWiseAttendanceResponse getStudentMonthWiseAttendanceResponse =
                              await getStudentMonthWiseAttendance(GetStudentMonthWiseAttendanceRequest(
                            schoolId: widget.schoolInfo.schoolId,
                            sectionId: widget.selectedSection?.sectionId,
                            academicYearId: widget.customExam.academicYearId,
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
                        await EachStudentPdfDownloadForCustomExam(
                          schoolInfo: widget.schoolInfo,
                          adminProfile: widget.adminProfile,
                          teacherProfile: widget.teacherProfile,
                          selectedAcademicYearId: widget.selectedAcademicYearId,
                          teachersList: widget.teachersList,
                          subjectsList: widget.subjectsList,
                          tdsList: widget.tdsList,
                          markingAlgorithm:
                              widget.markingAlgorithms.where((em) => em.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull,
                          customExam: widget.customExam,
                          studentProfiles: widget.studentsList.where((es) => es.sectionId == widget.selectedSection?.sectionId).toList(),
                          selectedSection: widget.selectedSection!,
                          updateMessage: (String? e) => setState(() => downloadMessage = e),
                        ).downloadMemo(studentMonthWiseAttendanceList, attendanceType: attendanceType);
                        setState(() {
                          _isLoading = false;
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
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Tooltip(
                    message: "Download Hall Tickets",
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isLoading = true;
                          _isExpanded = false;
                        });
                        await Future.delayed(const Duration(seconds: 1));
                        await EachStudentPdfDownloadForCustomExam(
                          schoolInfo: widget.schoolInfo,
                          adminProfile: widget.adminProfile,
                          teacherProfile: widget.teacherProfile,
                          selectedAcademicYearId: widget.selectedAcademicYearId,
                          teachersList: widget.teachersList,
                          subjectsList: widget.subjectsList,
                          tdsList: widget.tdsList,
                          markingAlgorithm:
                              widget.markingAlgorithms.where((em) => em.markingAlgorithmId == widget.customExam.markingAlgorithmId).firstOrNull,
                          customExam: widget.customExam,
                          studentProfiles: widget.studentsList.where((es) => es.sectionId == widget.selectedSection?.sectionId).toList(),
                          selectedSection: widget.selectedSection!,
                          updateMessage: (String? e) => setState(() => downloadMessage = e),
                        ).downloadHallTickets();
                        setState(() {
                          _isLoading = false;
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
              if (widget.selectedSection != null && widget.adminProfile != null && widget.smsTemplate != null)
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
                          String shortExamName = (widget.customExam.customExamName ?? "").split(" ").map((e) => e[0].toUpperCase()).join("");
                          List<MapEntry<String, String>> marksPerSubject = widget.customExam.examSectionSubjectMapList
                                  ?.where((essm) => essm?.sectionId == widget.selectedSection?.sectionId)
                                  .map((essm) {
                                String subjectName =
                                    (widget.subjectsList.firstWhereOrNull((eachSubject) => essm?.subjectId == eachSubject.subjectId)?.subjectName ??
                                            "-")
                                        .replaceAll(".", "")
                                        .substring(0, 2)
                                        .toUpperCase();
                                String marksObtained = "";
                                StudentExamMarks? esm =
                                    (essm?.studentExamMarksList ?? []).firstWhereOrNull((esm) => esm?.studentId == eachStudentProfile.studentId);
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
                          _isLoading = true;
                        });
                        // await Future.delayed(const Duration(seconds: 1));
                        // studentSmsMap.forEach((eachStudentProfile, message) {
                        //   print("${eachStudentProfile.gaurdianMobile}: $message\n");
                        // });
                        await getStudentExamMarksForSmsFromAlertDialogue(context, studentSmsMap);
                        setState(() {
                          _isLoading = false;
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
            ],
          ),
      ],
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
                      schoolId: widget.smsTemplate?.schoolId,
                      categoryId: widget.smsTemplate?.categoryId,
                      templateId: widget.smsTemplate?.templateId,
                      agent: widget.adminProfile?.userId,
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
}
