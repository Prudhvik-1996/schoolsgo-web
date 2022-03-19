import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/exams/model/exams.dart';
import 'package:schoolsgo_web/src/exams/student/student_each_exam_memo_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentEachExamScreen extends StatefulWidget {
  const StudentEachExamScreen({
    Key? key,
    required this.studentProfile,
    required this.exam,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final Exam exam;

  @override
  _StudentEachExamScreenState createState() => _StudentEachExamScreenState();
}

class _StudentEachExamScreenState extends State<StudentEachExamScreen> {
  bool _isLoading = true;
  List<StudentExamMarksDetailsBean> _studentExamMarksDetailsList = [];
  MarkingAlgorithmBean? markingAlgorithmBean;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetStudentExamMarksDetailsResponse getStudentExamMarksDetailsResponse = await getStudentExamMarksDetails(GetStudentExamMarksDetailsRequest(
      schoolId: widget.studentProfile.schoolId,
      examId: widget.exam.examId,
      sectionId: widget.studentProfile.sectionId,
      studentId: widget.studentProfile.studentId,
    ));
    if (getStudentExamMarksDetailsResponse.httpStatus != "OK" || getStudentExamMarksDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        _studentExamMarksDetailsList = getStudentExamMarksDetailsResponse.studentExamMarksDetailsList!.map((e) => e!).toList();
      });
    }

    if (widget.exam.markingAlgorithmId != null) {
      GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await getMarkingAlgorithms(
        GetMarkingAlgorithmsRequest(
          schoolId: widget.studentProfile.schoolId,
          markingAlgorithmId: widget.exam.markingAlgorithmId,
        ),
      );
      if (getMarkingAlgorithmsResponse.httpStatus == "OK" && getMarkingAlgorithmsResponse.responseStatus == "success") {
        try {
          setState(() {
            markingAlgorithmBean = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList().first;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Try again later.."),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exams"),
        actions: [
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: [
                Container(
                  margin: MediaQuery.of(context).orientation == Orientation.landscape
                      ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 0, MediaQuery.of(context).size.width / 4, 0)
                      : const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      _getExamDetailsWidget(),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: ClayContainer(
                          depth: 40,
                          parentColor: clayContainerColor(context),
                          surfaceColor: clayContainerColor(context),
                          spread: 1,
                          borderRadius: 10,
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            child: Column(
                              children: _studentExamMarksDetailsList.map((e) => getStudentExamMarksDetailsWidget(e)).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _isLoading
          ? Container()
          : Container(
              margin: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return StudentEachExamMemoScreen(
                      studentProfile: widget.studentProfile,
                      exam: widget.exam,
                      studentExamMarksDetailsList: _studentExamMarksDetailsList,
                      markingAlgorithmBean: markingAlgorithmBean,
                    );
                  }));
                },
                child: ClayButton(
                  depth: 40,
                  parentColor: clayContainerColor(context),
                  surfaceColor: Colors.blue.shade300,
                  spread: 1,
                  borderRadius: 10,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: const Text("MEMO"),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _getExamDetailsWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    (widget.exam.examName ?? "-").capitalize(),
                    style: const TextStyle(
                      fontSize: 32,
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

  Widget getStudentExamMarksDetailsWidget(StudentExamMarksDetailsBean e) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayContainer(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(convertDateToDDMMMYYYEEEE(e.date)),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("${convert24To12HourFormat(e.startTime!)} - ${convert24To12HourFormat(e.endTime!)}"),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(e.subjectName ?? "-"),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(e.teacherName ?? "-"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
