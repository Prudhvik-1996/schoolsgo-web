import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/topic_wise_exams/model/exam_topics.dart';
import 'package:schoolsgo_web/src/exams/admin/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/exams/admin/topic_wise_exams/topic_wise_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class ExamTopicWidget extends StatefulWidget {
  const ExamTopicWidget({
    Key? key,
    required this.scaffoldKey,
    required this.examTopic,
    required this.tds,
    required this.adminProfile,
    required this.teacherProfile,
    required this.academicYearId,
    required this.studentsList,
    required this.topicWiseExams,
    required this.saveTopicWiseExam,
    required this.loadTopicWiseExams,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final ExamTopic examTopic;
  final TeacherDealingSection tds;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int academicYearId;
  final List<StudentProfile> studentsList;
  final List<TopicWiseExam> topicWiseExams;
  final Future<TopicWiseExam> Function(TopicWiseExam topicWiseExam) saveTopicWiseExam;
  final Future<void> Function() loadTopicWiseExams;

  @override
  State<ExamTopicWidget> createState() => _ExamTopicWidgetState();
}

class _ExamTopicWidgetState extends State<ExamTopicWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        emboss: _isExpanded,
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: !_isExpanded ? buildCompactView() : buildExpandedView(),
        ),
      ),
    );
  }

  Widget buildExpandedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopicName(),
        const SizedBox(height: 15),
        buildNumberOfExamsRow(),
        const SizedBox(height: 15),
        ...widget.topicWiseExams.where((e) => e.status == 'active').map(
              (eachTopicWiseExam) => buildTopicWiseExamWidget(eachTopicWiseExam),
            ),
        if (widget.examTopic.isEditMode && !widget.topicWiseExams.map((e) => e.isEditMode).contains(true)) const SizedBox(height: 15),
        if (widget.examTopic.isEditMode && !widget.topicWiseExams.map((e) => e.isEditMode).contains(true))
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(child: Text("")),
              addNewExamButton(),
              const SizedBox(width: 15),
            ],
          ),
      ],
    );
  }

  Container buildTopicWiseExamWidget(TopicWiseExam eachTopicWiseExam) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          if (widget.examTopic.isEditMode) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return TopicWiseExamMarksScreen(
                  adminProfile: widget.adminProfile,
                  teacherProfile: widget.teacherProfile,
                  tds: widget.tds,
                  selectedAcademicYearId: widget.academicYearId,
                  studentsList: widget.studentsList,
                  topicWiseExam: eachTopicWiseExam,
                  updateExamMarks: (_) => widget.loadTopicWiseExams(),
                );
              },
            ),
          );
        },
        child: ClayButton(
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
                Row(
                  children: [
                    Expanded(
                      child: topicWiseExamNameWidget(eachTopicWiseExam),
                    ),
                    if (widget.examTopic.isEditMode) const SizedBox(width: 15),
                    if (widget.examTopic.isEditMode && eachTopicWiseExam.isEditMode) deleteExamButton(eachTopicWiseExam),
                    if (widget.examTopic.isEditMode && eachTopicWiseExam.isEditMode) const SizedBox(width: 15),
                    if (widget.examTopic.isEditMode)
                      eachTopicWiseExam.isEditMode
                          ? saveExamDetailsButton(eachTopicWiseExam)
                          : (widget.topicWiseExams.map((e) => e.isEditMode).where((e) => e).length == 1)
                              ? Container()
                              : editExamDetailsButton(eachTopicWiseExam),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: topicWiseExamMaxMarksWidget(eachTopicWiseExam),
                    ),
                    const SizedBox(width: 15),
                    Expanded(child: Text("Class Average: ${eachTopicWiseExam.classAverage ?? "-"}")),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: topicWiseExamDateWidget(eachTopicWiseExam),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: topicWiseExamTimeSlotWidget(eachTopicWiseExam),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topicWiseExamNameWidget(TopicWiseExam eachTopicWiseExam) {
    return eachTopicWiseExam.isEditMode
        ? TextFormField(
            initialValue: eachTopicWiseExam.examName,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            ),
            onChanged: (String? newText) => setState(() => eachTopicWiseExam.examName = newText),
            maxLines: null,
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          )
        : Text(
            eachTopicWiseExam.examName ?? "-",
            style: const TextStyle(fontSize: 18),
          );
  }

  Widget topicWiseExamTimeSlotWidget(TopicWiseExam eachTopicWiseExam) {
    return eachTopicWiseExam.isEditMode
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: _buildStartTimePicker(eachTopicWiseExam)),
              const SizedBox(width: 15),
              Expanded(child: _buildEndTimePicker(eachTopicWiseExam)),
            ],
          )
        : Text("Time: ${eachTopicWiseExam.examTimeSlot}");
  }

  Future<void> _pickStartTime(BuildContext context, TopicWiseExam topicWiseExam) async {
    TimeOfDay? _startTimePicker = await showTimePicker(
      context: context,
      initialTime: formatHHMMSSToTimeOfDay(topicWiseExam.startTime ?? "00:00:00"),
    );

    if (_startTimePicker == null) return;
    setState(() {
      topicWiseExam.startTime = timeOfDayToHHMMSS(_startTimePicker);
    });
  }

  Widget _buildStartTimePicker(TopicWiseExam topicWiseExam) {
    return ClayButton(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () async {
            await _pickStartTime(context, topicWiseExam);
          },
          child: Center(
            child: Text(topicWiseExam.startTimeSlot),
          ),
        ),
      ),
    );
  }

  Future<void> _pickEndTime(BuildContext context, TopicWiseExam topicWiseExam) async {
    TimeOfDay? _endTimePicker = await showTimePicker(
      context: context,
      initialTime: formatHHMMSSToTimeOfDay(topicWiseExam.endTime ?? "00:00:00"),
    );

    if (_endTimePicker == null) return;
    setState(() {
      topicWiseExam.endTime = timeOfDayToHHMMSS(_endTimePicker);
    });
  }

  Widget _buildEndTimePicker(TopicWiseExam topicWiseExam) {
    return ClayButton(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () async {
            await _pickEndTime(context, topicWiseExam);
          },
          child: Center(
            child: Text(topicWiseExam.endTimeSlot),
          ),
        ),
      ),
    );
  }

  Widget topicWiseExamDateWidget(TopicWiseExam eachTopicWiseExam) {
    if (eachTopicWiseExam.isEditMode) {
      return GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: convertYYYYMMDDFormatToDateTime(eachTopicWiseExam.date),
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now(),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            eachTopicWiseExam.date = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
        },
        child: ClayButton(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                ),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(eachTopicWiseExam.examDate),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Text("Date: ${eachTopicWiseExam.examDate}");
    }
  }

  Widget topicWiseExamMaxMarksWidget(TopicWiseExam eachTopicWiseExam) {
    return eachTopicWiseExam.isEditMode
        ? TextFormField(
            initialValue: "${eachTopicWiseExam.maxMarks ?? ""}",
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
                eachTopicWiseExam.maxMarks = null;
              }
              double? newMaxMarks = double.tryParse(newText ?? "");
              if (newMaxMarks != null) {
                eachTopicWiseExam.maxMarks = newMaxMarks;
              }
            }),
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          )
        : Text("Max. Marks: ${eachTopicWiseExam.maxMarks ?? "-"}");
  }

  Row buildNumberOfExamsRow() {
    return Row(
      children: [
        Expanded(child: Text("No. of exams: ${widget.topicWiseExams.length}")),
      ],
    );
  }

  Widget buildCompactView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopicName(),
        const SizedBox(height: 15),
        buildNumberOfExamsRow(),
      ],
    );
  }

  Row buildTopicName() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              //  TODO: show cumulative stats table
            },
            child: !widget.examTopic.isEditMode
                ? Text(
                    widget.examTopic.topicName ?? "-",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: _isExpanded ? FontWeight.bold : null,
                    ),
                  )
                : TextFormField(
                    initialValue: widget.examTopic.topicName,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                    ),
                    onChanged: (String? newText) => setState(() => widget.examTopic.topicName = newText),
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.start,
                  ),
          ),
        ),
        if (widget.examTopic.isEditMode && !widget.topicWiseExams.map((e) => e.isEditMode).contains(true)) saveChangesButton(),
        if (widget.examTopic.isEditMode) const SizedBox(width: 15),
        if (!widget.examTopic.isEditMode && _isExpanded) editButton(),
        if (!widget.examTopic.isEditMode && _isExpanded) const SizedBox(width: 15),
        if (!widget.examTopic.isEditMode) expandButton(),
      ],
    );
  }

  Widget addNewExamButton() => fab(
        const Icon(Icons.add),
        "Add New Exam",
        () => setState(() => widget.topicWiseExams.add(
              TopicWiseExam(
                academicYearId: widget.academicYearId,
                schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                subjectId: widget.tds.subjectId,
                status: "active",
                date: null,
                comment: null,
                agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                sectionId: widget.tds.sectionId,
                authorisedAgent: widget.tds.teacherId,
                endTime: null,
                examId: null,
                examName: "",
                examSectionSubjectMapId: null,
                examType: "TOPIC",
                maxMarks: null,
                startTime: null,
                studentExamMarksList: [],
                topicId: widget.examTopic.topicId,
                topicName: widget.examTopic.topicName,
              )..isEditMode = true,
            )),
        color: Colors.blue,
      );

  Widget saveChangesButton() => fab(
        const Icon(Icons.check),
        "Save",
        () {
          setState(() => widget.examTopic.isEditMode = false);
        },
        color: Colors.green,
      );

  Widget editButton() => fab(const Icon(Icons.edit), "Edit", () => setState(() => widget.examTopic.isEditMode = true), color: Colors.blue);

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

  Tooltip expandButton() {
    return Tooltip(
      message: _isExpanded ? "Minimise" : "Expand",
      child: GestureDetector(
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 30,
          width: 30,
          borderRadius: 50,
          surfaceColor: clayContainerColor(context),
          child: _isExpanded ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  Tooltip saveExamDetailsButton(TopicWiseExam topicWiseExam) {
    return Tooltip(
      message: "Save",
      child: GestureDetector(
        onTap: () async {
          if ((topicWiseExam.examName ?? "") == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Exam Name cannot be empty"),
              ),
            );
            return;
          }
          if ((topicWiseExam.maxMarks ?? 0) == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Max marks cannot be 0"),
              ),
            );
            return;
          }
          widget.saveTopicWiseExam(topicWiseExam);
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 30,
          width: 30,
          borderRadius: 50,
          surfaceColor: clayContainerColor(context),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.check,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Tooltip deleteExamButton(TopicWiseExam topicWiseExam) {
    return Tooltip(
      message: "Delete",
      child: GestureDetector(
        onTap: () {
          if (topicWiseExam.examId == null) {
            setState(() {
              widget.topicWiseExams.remove(topicWiseExam);
            });
          } else {
            widget.saveTopicWiseExam(topicWiseExam
              ..status = "inactive"
              ..agent = widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId);
          }
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 30,
          width: 30,
          borderRadius: 50,
          surfaceColor: clayContainerColor(context),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Tooltip editExamDetailsButton(TopicWiseExam topicWiseExam) {
    return Tooltip(
      message: "Edit",
      child: GestureDetector(
        onTap: () {
          setState(() => topicWiseExam.isEditMode = true);
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 30,
          width: 30,
          borderRadius: 50,
          surfaceColor: clayContainerColor(context),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                Icons.edit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
