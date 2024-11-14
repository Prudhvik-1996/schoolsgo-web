import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/edit_fa_exam_widget.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/fa_exam_widget.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class ManageExamsV2Screen extends StatefulWidget {
  const ManageExamsV2Screen({
    super.key,
    required this.schoolInfo,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.studentsList,
    required this.markingAlgorithms,
  });

  final SchoolInfoBean schoolInfo;
  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final List<StudentProfile> studentsList;
  final List<MarkingAlgorithmBean> markingAlgorithms;

  @override
  State<ManageExamsV2Screen> createState() => _ManageExamsV2ScreenState();
}

class _ManageExamsV2ScreenState extends State<ManageExamsV2Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  List<FAExam> faExams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetFAExamsResponse getFAExamsResponse = await getFAExams(GetFAExamsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getFAExamsResponse.httpStatus != "OK" || getFAExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      faExams = (getFAExamsResponse.exams ?? []).map((e) => e!).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Exams With Internals"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.adminProfile!,
          ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : faExams.isEmpty
              ? const Center(child: Text("Create an exam to proceed.."))
              : ListView(
                  children: [
                    ...faExams.map(
                      (faExam) => faExamWidget(faExam),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
      floatingActionButton: faExams.map((e) => e.isEditMode).contains(true) || _isLoading
          ? null
          : fab(
              const Icon(Icons.add),
              "Add",
              () async => goToEditMode(
                context,
                FAExam(
                  status: "active",
                  academicYearId: widget.selectedAcademicYearId,
                  agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                  schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                  examType: "FA",
                ),
              ),
              color: Colors.blue,
            ),
    );
  }

  Future<void> goToEditMode(BuildContext context, FAExam faExam) {
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditFAExamWidget(
        adminProfile: widget.adminProfile,
        teacherProfile: widget.teacherProfile,
        selectedAcademicYearId: widget.selectedAcademicYearId,
        sectionsList: widget.sectionsList,
        teachersList: widget.teachersList,
        subjectsList: widget.subjectsList,
        tdsList: widget.tdsList,
        markingAlgorithms: widget.markingAlgorithms,
        faExam: faExam,
      );
    })).then((_) => _loadData());
  }

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

  Widget faExamWidget(FAExam faExam) {
    return FAExamWidget(
      scaffoldKey: _scaffoldKey,
      schoolInfo: widget.schoolInfo,
      adminProfile: widget.adminProfile,
      teacherProfile: widget.teacherProfile,
      selectedAcademicYearId: widget.selectedAcademicYearId,
      sectionsList: widget.sectionsList,
      teachersList: widget.teachersList,
      subjectsList: widget.subjectsList,
      tdsList: widget.tdsList,
      faExam: faExam,
      studentsList: widget.studentsList,
      loadData: _loadData,
      editingEnabled: true,
      selectedSection: null,
      setLoading: (bool isLoading) => setState(() => _isLoading = isLoading),
      markingAlgorithms: widget.markingAlgorithms,
      isClassTeacher: false,
      smsTemplate: null,
    );
  }
}
