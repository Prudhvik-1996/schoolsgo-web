import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/exam_topics.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/views/all_topics_students_marks_download.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/views/exam_topic_widget.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class TopicWiseExamsScreen extends StatefulWidget {
  const TopicWiseExamsScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.tds,
    required this.selectedAcademicYearId,
    required this.studentsList,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final TeacherDealingSection tds;
  final int selectedAcademicYearId;
  final List<StudentProfile> studentsList;

  @override
  State<TopicWiseExamsScreen> createState() => _TopicWiseExamsScreenState();
}

class _TopicWiseExamsScreenState extends State<TopicWiseExamsScreen> {
  bool _isLoading = true;
  List<ExamTopic> examTopics = [];
  List<TopicWiseExam> topicWiseExams = [];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetExamTopicsResponse getExamTopicsResponse = await getExamTopics(GetExamTopicsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      academicYearId: widget.selectedAcademicYearId,
      tdsId: widget.tds.tdsId,
    ));
    if (getExamTopicsResponse.httpStatus != "OK" || getExamTopicsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      examTopics = (getExamTopicsResponse.examTopics ?? []).map((e) => e!).toList();
    }
    await loadTopicWiseExams();
    setState(() => _isLoading = false);
  }

  Future<void> loadTopicWiseExams() async {
    setState(() {
      _isLoading = true;
    });
    GetTopicWiseExamsResponse getTopicWiseExamsResponse = await getTopicWiseExams(GetTopicWiseExamsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      academicYearId: widget.selectedAcademicYearId,
      tdsId: widget.tds.tdsId,
    ));
    if (getTopicWiseExamsResponse.httpStatus != "OK" || getTopicWiseExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        topicWiseExams = (getTopicWiseExamsResponse.topicWiseExams ?? []).map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("${widget.tds.sectionName} - ${widget.tds.subjectName} - ${widget.tds.teacherName}"),
        actions: [
          if (!(_isLoading || examTopics.map((e) => e.isEditMode).contains(true) || topicWiseExams.map((e) => e.isEditMode).contains(true)))
            Tooltip(
              message: "Download Report",
              child: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  await AllTopicsStudentsMarksDownload(
                    adminProfile: widget.adminProfile,
                    teacherProfile: widget.teacherProfile,
                    tds: widget.tds,
                    selectedAcademicYearId: widget.selectedAcademicYearId,
                    studentsList: widget.studentsList,
                    examTopics: examTopics,
                    topicWiseExams: topicWiseExams,
                  ).downloadReport();
                },
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : examTopics.isEmpty
              ? const Center(child: Text("Create Topics to proceed.."))
              : ListView(
                  children: [
                    ...examTopics.map(
                      (eachTopic) => ExamTopicWidget(
                        scaffoldKey: scaffoldKey,
                        examTopic: eachTopic,
                        tds: widget.tds,
                        adminProfile: widget.adminProfile,
                        teacherProfile: widget.teacherProfile,
                        academicYearId: widget.selectedAcademicYearId,
                        studentsList: widget.studentsList,
                        topicWiseExams: topicWiseExams.where((eachTopicWiseExam) => eachTopicWiseExam.topicId == eachTopic.topicId).toList(),
                        saveTopicWiseExam: (TopicWiseExam topicWiseExam) => saveTopicWiseExam(topicWiseExam),
                        loadTopicWiseExams: () => loadTopicWiseExams(),
                        setState: setState,
                      ),
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
      floatingActionButton: _isLoading || examTopics.map((e) => e.isEditMode).contains(true) || topicWiseExams.map((e) => e.isEditMode).contains(true)
          ? null
          : addNewTopicButton(),
    );
  }

  Widget addNewTopicButton() => fab(const Icon(Icons.add), "Add Topic", () async {
        String? newTopic = "";
        await showDialog(
          context: scaffoldKey.currentContext!,
          builder: (currentContext) {
            return AlertDialog(
              title: const Text("New Topic"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    height: MediaQuery.of(context).size.height / 2,
                    child: TextFormField(
                      initialValue: newTopic,
                      decoration: InputDecoration(
                        errorText: (newTopic ?? "").isEmpty ? "Topic Name cannot be empty" : "",
                        border: const UnderlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                      onChanged: (String? newText) => setState(() => newTopic = newText),
                      maxLines: null,
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
                    if ((newTopic?.trim() ?? "").isEmpty) return;
                    Navigator.pop(context);
                    setState(() {
                      _isLoading = true;
                    });
                    CreateOrUpdateExamTopicsResponse createOrUpdateExamTopicsResponse =
                        await createOrUpdateExamTopics(CreateOrUpdateExamTopicsRequest(
                      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                      agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                      examTopics: [
                        ExamTopic(
                          agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                          academicYearId: widget.selectedAcademicYearId,
                          status: "active",
                          tdsId: widget.tds.tdsId,
                          topicName: newTopic,
                        ),
                      ],
                    ));
                    if (createOrUpdateExamTopicsResponse.httpStatus != "OK" || createOrUpdateExamTopicsResponse.responseStatus != "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong! Try again later.."),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _isLoading = false;
                    });
                    await _loadData();
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
      }, color: Colors.green);

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                icon,
                const SizedBox(width: 10),
                Text(text),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<TopicWiseExam> saveTopicWiseExam(TopicWiseExam topicWiseExam) async {
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Topic wise exam'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateTopicWiseExamResponse createOrUpdateTopicWiseExamResponse =
                    await createOrUpdateTopicWiseExam(CreateOrUpdateTopicWiseExamRequest(
                  academicYearId: topicWiseExam.academicYearId,
                  agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                  authorisedAgent: topicWiseExam.authorisedAgent,
                  comment: topicWiseExam.comment,
                  date: topicWiseExam.date,
                  endTime: topicWiseExam.endTime,
                  examId: topicWiseExam.examId,
                  examName: topicWiseExam.examName,
                  examSectionSubjectMapId: topicWiseExam.examSectionSubjectMapId,
                  examType: topicWiseExam.examType,
                  maxMarks: topicWiseExam.maxMarks,
                  schoolId: topicWiseExam.schoolId,
                  sectionId: topicWiseExam.sectionId,
                  startTime: topicWiseExam.startTime,
                  status: topicWiseExam.status,
                  subjectId: topicWiseExam.subjectId,
                  topicId: topicWiseExam.topicId,
                  topicName: topicWiseExam.topicName,
                ));
                if (createOrUpdateTopicWiseExamResponse.httpStatus != "OK" || createOrUpdateTopicWiseExamResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                  return;
                } else {
                  setState(() {
                    topicWiseExam.isEditMode = false;
                  });
                }
                setState(() {
                  _isLoading = false;
                });
                await loadTopicWiseExams();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                Navigator.of(context).pop();
                if (topicWiseExam.examId != null) {
                  setState(() {
                    topicWiseExam.isEditMode = false;
                    topicWiseExam = TopicWiseExam.fromJson(topicWiseExam.origJson());
                  });
                } else {
                  setState(() {
                    topicWiseExams.remove(topicWiseExam);
                  });
                }
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
    return topicWiseExam;
  }
}
