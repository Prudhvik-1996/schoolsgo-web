// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/sections_reorder_screen.dart';
import 'package:schoolsgo_web/src/teacher_dashboard/class_teacher_section_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class SectionInfoScreen extends StatefulWidget {
  const SectionInfoScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<SectionInfoScreen> createState() => _SectionInfoScreenState();
}

class _SectionInfoScreenState extends State<SectionInfoScreen> {
  bool _isSectionLoading = false;
  bool _isLoading = true;

  List<Section> sectionsList = [];
  List<Teacher> teachersList = [];
  List<StudentProfile> studentsList = [];

  Section? selectedSection;
  late int selectedAcademicYearId;

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID')!;
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);
    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        teachersList = getTeachersResponse.teachers!;
        teachersList.sort((a, b) => (a.teacherName ?? "-").compareTo((b.teacherName ?? "-")));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      setState(() {
        studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sections Info"),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: () => setState(() => _isEditMode = !_isEditMode),
              icon: _isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit),
            ),
          if (!_isLoading && !_isEditMode)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SectionsReorderScreen(
                      adminProfile: widget.adminProfile,
                      sections: sectionsList,
                      teachers: teachersList,
                      students: studentsList,
                    );
                  },
                ),
              ).then((_) => _loadData()),
              icon: const Icon(Icons.reorder),
            ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: sectionsDataTable(context),
                ),
              ],
            ),
    );
  }

  DataTable sectionsDataTable(BuildContext context) {
    return DataTable(
      dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected) || states.contains(MaterialState.hovered)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return null; // Use the default value.
      }),
      headingRowColor: MaterialStateColor.resolveWith((states) => Theme.of(context).colorScheme.primary),
      border: TableBorder.all(
        color: Colors.grey,
      ),
      decoration: BoxDecoration(color: clayContainerColor(context)),
      columns: const [
        DataColumn(label: Text('S. No.', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Section Name', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Class Teacher', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('No. Of Students', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('More Info', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      showCheckboxColumn: false,
      rows: [
        ...sectionsList.map(
          (section) => DataRow(
            onSelectChanged: (selected) {
              if (!_isEditMode) {
                goToSection(section);
              }
            },
            cells: [
              DataCell(Text(section.seqOrder?.toString() ?? "-")),
              DataCell(Text(section.sectionName ?? "-")),
              DataCell(
                _isEditMode
                    ? classTeacherPicker(section)
                    : Text(teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull?.teacherName ?? "-"),
              ),
              DataCell(Text(studentsList.where((es) => es.sectionId == section.sectionId && es.status == 'active').length.toString())),
              DataCell(
                GestureDetector(
                  onTap: () => goToSection(section),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ClayButton(
                      depth: 40,
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 100,
                      child: const Center(
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.exit_to_app),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DropdownButton<Teacher?> classTeacherPicker(Section section) {
    return DropdownButton<Teacher?>(
      value: teachersList.where((et) => et.teacherId == section.classTeacherId).firstOrNull,
      items: teachersList.map((e) => DropdownMenuItem<Teacher>(value: e, child: Text(e.teacherName ?? "-"))).toList(),
      onChanged: (Teacher? teacher) async {
        setState(() {
          section.classTeacherId = teacher?.teacherId;
          section.agent = "${widget.adminProfile.userId}";
        });
        setState(() => _isLoading = true);
        CreateOrUpdateSectionRequest createOrUpdateSectionRequest = CreateOrUpdateSectionRequest.fromSection(section);
        CreateOrUpdateSectionResponse createOrUpdateSectionResponse = await createOrUpdateSection(createOrUpdateSectionRequest);
        if (createOrUpdateSectionResponse.httpStatus != "OK" || createOrUpdateSectionResponse.responseStatus != "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong! Try again later.."),
            ),
          );
        }
        setState(() => _isLoading = false);
      },
    );
  }

  Future<dynamic> goToSection(Section section) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ClassTeacherSectionScreen(
            adminProfile: widget.adminProfile,
            teacherProfile: null,
            section: section,
            selectedAcademicYearId: selectedAcademicYearId,
          );
        },
      ),
    );
  }
}
