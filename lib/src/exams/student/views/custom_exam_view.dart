import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';

class CustomExamView extends StatefulWidget {
  const CustomExamView({
    super.key,
    required this.studentProfile,
    required this.customExam,
    required this.subjects,
    required this.schoolInfo,
  });

  final StudentProfile studentProfile;
  final CustomExam customExam;
  final List<Subject> subjects;
  final SchoolInfoBean schoolInfo;

  @override
  State<CustomExamView> createState() => _CustomExamViewState();
}

class _CustomExamViewState extends State<CustomExamView> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    (widget.customExam.examSectionSubjectMapList ?? []).sort(
      (a, b) {
        Subject? aSubject = widget.subjects.where((e) => e.subjectId == a?.subjectId).firstOrNull;
        Subject? bSubject = widget.subjects.where((e) => e.subjectId == b?.subjectId).firstOrNull;
        return (aSubject?.seqOrder ?? 0).compareTo(bSubject?.seqOrder ?? 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customExam.customExamName ?? "-"),
      ),
      body: ListView(
        children: [
          clayCell(
            margin: MediaQuery.of(context).orientation == Orientation.landscape
                ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 6, 20, MediaQuery.of(context).size.width / 6, 20)
                : const EdgeInsets.all(20),
            child: Column(
              children: [
                clayCell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Center(child: schoolHeaderWidget()),
                      const SizedBox(height: 10),
                      const Divider(color: Colors.grey, thickness: .5),
                      const SizedBox(height: 10),
                      studentNameWidget(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: rollNumberWidget()),
                          Expanded(child: sectionWidget()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: totalMarksObtainedWidget()), Expanded(child: percentageWidget()), // Expanded(child: gradeWidget()),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  emboss: true,
                ),
                const SizedBox(height: 10),
                clayCell(
                  child: marksTable(),
                  emboss: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget clayCell({
    Widget? child,
    EdgeInsetsGeometry? margin = const EdgeInsets.all(4),
    EdgeInsetsGeometry? padding = const EdgeInsets.all(8),
    bool emboss = false,
    double height = double.infinity,
    double width = double.infinity,
    bool isUnBounded = true,
  }) {
    return Container(
      margin: margin,
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: emboss,
        child: Container(
          width: isUnBounded ? null : width,
          height: isUnBounded ? null : height,
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  Widget schoolHeaderWidget() {
    return Text(
      widget.studentProfile.schoolName ?? " - ",
      textAlign: TextAlign.center,
      style: GoogleFonts.archivoBlack(
        textStyle: const TextStyle(
          fontSize: 36,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget studentNameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Name",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            widget.studentProfile.studentFirstName ?? "-",
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget rollNumberWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Roll No.",
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            widget.studentProfile.rollNumber ?? "-",
          ),
        ),
      ],
    );
  }

  Widget sectionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Class",
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            widget.studentProfile.sectionName ?? "-",
          ),
        ),
      ],
    );
  }

  Widget totalMarksObtainedWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Marks",
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            "${((widget.customExam.examSectionSubjectMapList ?? []).map((e) => e?.studentExamMarksList ?? [])).expand((i) => i).map((e) => e?.marksObtained ?? 0).fold<double>(0.0, (double a, double b) => a + b)} / ${(widget.customExam.examSectionSubjectMapList ?? []).map((e) => e?.maxMarks ?? 0).fold<double>(0.0, (double a, double b) => a + b)}",
          ),
        ),
      ],
    );
  }

  Widget percentageWidget() {
    double? percentage = widget.customExam.getPercentage(widget.studentProfile.studentId!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Percentage",
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            percentage == null ? "-" : "$percentage%",
          ),
        ),
      ],
    );
  }

  Widget marksTable() {
    return Scrollbar(
      thumbVisibility: true,
      controller: _controller,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  clayCell(
                    height: 70,
                    width: 140,
                    isUnBounded: false,
                    child: const Center(
                      child: Text(
                        "Subject",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  clayCell(
                    height: 70,
                    width: 100,
                    isUnBounded: false,
                    child: const Center(
                      child: Text(
                        "Max Marks",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  clayCell(
                    height: 70,
                    width: 100,
                    isUnBounded: false,
                    child: const Center(
                      child: Text(
                        "Marks Obtained",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  clayCell(
                    height: 70,
                    width: 150,
                    isUnBounded: false,
                    child: const Center(
                      child: Text(
                        "Comments",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  clayCell(
                    height: 70,
                    width: 250,
                    isUnBounded: false,
                    child: const Center(
                      child: Text(
                        "Attachments",
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              ...[
                for (ExamSectionSubjectMap eachExamSectionSubjectMap in (widget.customExam.examSectionSubjectMapList ?? []).map((e) => e!)) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      clayCell(
                        height: 70,
                        width: 140,
                        isUnBounded: false,
                        child: Center(
                          child: Text(
                            widget.subjects.where((e) => e.subjectId == eachExamSectionSubjectMap.subjectId).firstOrNull?.subjectName ?? "-",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      clayCell(
                        height: 70,
                        width: 100,
                        isUnBounded: false,
                        child: Center(
                          child: Text(
                            "${eachExamSectionSubjectMap.maxMarks ?? " - "}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      clayCell(
                        height: 70,
                        width: 100,
                        isUnBounded: false,
                        child: Center(
                          child: Text(
                            "${(eachExamSectionSubjectMap.studentExamMarksList ?? []).where((e) => e?.studentId == widget.studentProfile.studentId).firstOrNull?.marksObtained ?? " - "}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      clayCell(
                        height: 70,
                        width: 150,
                        isUnBounded: false,
                        child: SingleChildScrollView(
                          child: Center(
                            child: Text(
                              (eachExamSectionSubjectMap.studentExamMarksList ?? [])
                                      .where((e) => e?.studentId == widget.studentProfile.studentId)
                                      .firstOrNull
                                      ?.comment ??
                                  " - ",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      clayCell(
                        height: 70,
                        width: 250,
                        isUnBounded: false,
                        child: studentMarksMediaScrollableWidget((eachExamSectionSubjectMap.studentExamMarksList ?? [])
                            .where((e) => e?.studentId == widget.studentProfile.studentId)
                            .firstOrNull),
                      )
                    ],
                  ),
                ]
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget studentMarksMediaScrollableWidget(StudentExamMarks? eachStudentExamMarks) {
    if (eachStudentExamMarks == null) return Container();
    return Scrollbar(
      controller: eachStudentExamMarks.mediaScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: eachStudentExamMarks.mediaScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...(eachStudentExamMarks.studentExamMediaBeans ?? []).map(
              (e) => CachedNetworkImage(
                imageUrl: e!.mediaUrl!,
                height: 70,
                width: 70,
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
