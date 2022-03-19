import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/model/exams.dart';
import 'package:schoolsgo_web/src/exams/student/student_each_exam_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentExamsScreen extends StatefulWidget {
  const StudentExamsScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/exams";

  @override
  _StudentExamsScreenState createState() => _StudentExamsScreenState();
}

class _StudentExamsScreenState extends State<StudentExamsScreen> {
  bool _isLoading = true;

  List<Exam> exams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetExamsResponse getExamsResponse = await getExams(GetExamsRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
    ));
    if (getExamsResponse.httpStatus != "OK" || getExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        exams = (getExamsResponse.exams ?? []).map((e) => e!).toList();
      });
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
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: exams.map((e) => eachExamWidget(e)).toList(),
            ),
    );
  }

  Widget eachExamWidget(Exam exam) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ClayButton(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return StudentEachExamScreen(
                studentProfile: widget.studentProfile,
                exam: exam,
              );
            }));
          },
          title: Text(exam.examName ?? "-"),
          leading: Icon(exam.examType == "TERM" ? Icons.widgets : Icons.description),
        ),
      ),
    );
  }
}
