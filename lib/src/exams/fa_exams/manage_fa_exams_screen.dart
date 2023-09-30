import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/edit_fa_exam_widget.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/fa_exam_widget.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class ManageFAExamsScreen extends StatefulWidget {
  const ManageFAExamsScreen({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    required this.sectionsList,
    required this.teachersList,
    required this.subjectsList,
    required this.tdsList,
    required this.studentsList,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final List<Section> sectionsList;
  final List<Teacher> teachersList;
  final List<Subject> subjectsList;
  final List<TeacherDealingSection> tdsList;
  final List<StudentProfile> studentsList;

  @override
  State<ManageFAExamsScreen> createState() => _ManageFAExamsScreenState();
}

class _ManageFAExamsScreenState extends State<ManageFAExamsScreen> {
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
      academicYearId: widget.selectedAcademicYearId,
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
        title: const Text("Manage FA Exams"),
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
      drawer:
          widget.adminProfile != null ? AdminAppDrawer(adminProfile: widget.adminProfile!) : TeacherAppDrawer(teacherProfile: widget.teacherProfile!),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : faExams.isEmpty
              ? const Center(child: Text("Create an exam to proceed.."))
              : ListView(
                  children: [
                    ...faExams.map(
                      (faExam) => FAExamWidget(
                        scaffoldKey: _scaffoldKey,
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
                      ),
                    ),
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
}
