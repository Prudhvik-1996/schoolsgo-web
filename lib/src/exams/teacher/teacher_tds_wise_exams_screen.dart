import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/publish_results/admin_exam_marks_screen.dart';
import 'package:schoolsgo_web/src/exams/model/admin_exams.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class TeacherTdsWiseExamsScreen extends StatefulWidget {
  const TeacherTdsWiseExamsScreen({
    Key? key,
    required this.teacherProfile,
    required this.tds,
  }) : super(key: key);

  final TeacherProfile teacherProfile;
  final TeacherDealingSection tds;

  @override
  State<TeacherTdsWiseExamsScreen> createState() => _TeacherTdsWiseExamsScreenState();
}

class _TeacherTdsWiseExamsScreenState extends State<TeacherTdsWiseExamsScreen> {
  bool _isLoading = true;

  List<AdminExamBean> exams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetAdminExamsResponse getAdminExamsResponse = await getAdminExams(GetAdminExamsRequest(
      schoolId: widget.teacherProfile.schoolId,
    ));
    if (getAdminExamsResponse.httpStatus != "OK" || getAdminExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        exams = getAdminExamsResponse.adminExamBeanList!.map((e) => e!).toList();
        for (var eachExam in exams) {
          eachExam.examSectionMapBeanList?.removeWhere((e) => e?.sectionId != widget.tds.sectionId);
          eachExam.examSectionMapBeanList?.forEach((eachSectionMapBean) {
            eachSectionMapBean?.examTdsMapBeanList?.removeWhere((e) => e?.tdsId != widget.tds.tdsId);
          });
        }
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
          buildRoleButtonForAppBar(context, widget.teacherProfile),
        ],
      ),
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              children: exams.map((e) => eachExamWidget(e)).toList(),
            ),
    );
  }

  Widget eachExamWidget(AdminExamBean exam) {
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
              return AdminExamMarksScreen(
                examBean: exam,
                subjectId: widget.tds.subjectId,
                section: Section(
                  schoolId: widget.tds.schoolId,
                  sectionId: widget.tds.sectionId,
                  sectionName: widget.tds.sectionName,
                ),
                teacherId: widget.teacherProfile.teacherId,
                adminProfile: AdminProfile(
                  isMegaAdmin: false,
                  schoolId: widget.teacherProfile.schoolId,
                  franchiseId: widget.teacherProfile.franchiseId,
                  userId: widget.teacherProfile.teacherId,
                ),
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
