import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/custom_exam_widget.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/edit_custom_exams_widget.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class ManageCustomExamsScreen extends StatefulWidget {
  const ManageCustomExamsScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.studentsList,
    required this.markingAlgorithms,
    required this.schoolInfo,
  }) : super(key: key);

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
  State<ManageCustomExamsScreen> createState() => _ManageCustomExamsScreenState();
}

class _ManageCustomExamsScreenState extends State<ManageCustomExamsScreen> {
  bool _isLoading = true;

  List<CustomExam> customExams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetCustomExamsResponse getCustomExamsResponse = await getCustomExams(GetCustomExamsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getCustomExamsResponse.httpStatus != "OK" || getCustomExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      customExams = (getCustomExamsResponse.customExamsList ?? []).map((e) => e!).toList();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Exams Without Internals"),
        actions: [
          if (widget.adminProfile != null)
            buildRoleButtonForAppBar(
              context,
              widget.adminProfile!,
            )
          else
            buildRoleButtonForAppBar(
              context,
              widget.teacherProfile!,
            ),
        ],
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : widget.adminProfile != null
              ? AdminAppDrawer(adminProfile: widget.adminProfile!)
              : TeacherAppDrawer(teacherProfile: widget.teacherProfile!),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : customExams.isEmpty
              ? const Center(child: Text("Create an exam to proceed.."))
              : ListView(
                  children: [
                    ...customExams.map(
                      (customExam) => CustomExamWidget(
                        schoolInfo: widget.schoolInfo,
                        adminProfile: widget.adminProfile,
                        teacherProfile: widget.teacherProfile,
                        selectedAcademicYearId: widget.selectedAcademicYearId,
                        sectionsList: widget.sectionsList,
                        teachersList: widget.teachersList,
                        subjectsList: widget.subjectsList,
                        tdsList: widget.tdsList,
                        customExam: customExam,
                        studentsList: widget.studentsList,
                        loadData: _loadData,
                        editingEnabled: true,
                        selectedSection: null,
                        markingAlgorithms: widget.markingAlgorithms,
                        isClassTeacher: false,
                      ),
                    )
                  ],
                ),
      floatingActionButton: customExams.map((e) => e.isEditMode).contains(true)
          ? null
          : fab(
              const Icon(Icons.add),
              "Add",
              () async => goToEditMode(
                context,
                CustomExam(
                  status: "active",
                  academicYearId: widget.selectedAcademicYearId,
                  agent: widget.adminProfile?.userId ?? widget.teacherProfile?.teacherId,
                  schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
                  examType: "CUSTOM",
                ),
              ),
              color: Colors.blue,
            ),
    );
  }

  Future<void> goToEditMode(BuildContext context, CustomExam customExam) {
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditCustomExamWidget(
        schoolInfo: widget.schoolInfo,
        adminProfile: widget.adminProfile,
        teacherProfile: widget.teacherProfile,
        selectedAcademicYearId: widget.selectedAcademicYearId,
        sectionsList: widget.sectionsList,
        teachersList: widget.teachersList,
        tdsList: widget.tdsList,
        customExam: customExam,
        markingAlgorithms: widget.markingAlgorithms,
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
}
