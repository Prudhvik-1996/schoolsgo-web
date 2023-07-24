import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/manage_custom_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/views/custom_exam_widget.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class CustomExamsScreen extends StatefulWidget {
  const CustomExamsScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;

  @override
  State<CustomExamsScreen> createState() => _CustomExamsScreenState();
}

class _CustomExamsScreenState extends State<CustomExamsScreen> {
  bool _isLoading = true;

  List<Section> _sectionsList = [];
  Section? _selectedSection;

  List<StudentProfile> studentsList = [];
  List<TeacherDealingSection> tdsList = [];
  List<Teacher> teachersList = [];

  bool _isSectionPickerOpen = false;

  List<CustomExam> customExams = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetCustomExamsResponse getCustomExamsResponse = await getCustomExams(GetCustomExamsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      academicYearId: widget.selectedAcademicYearId,
      teacherId: widget.teacherProfile?.teacherId,
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

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      teacherId: widget.teacherProfile?.teacherId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        tdsList = (getTeacherDealingSectionsResponse.teacherDealingSections ?? []).toList();
      });
    }

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      teacherId: widget.teacherProfile?.teacherId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        teachersList = getTeachersResponse.teachers!;
      });
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _selectSectionExpanded() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: Text(
                _selectedSection == null ? "Select a section" : "Sections:",
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            shrinkWrap: true,
            children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      height: 60,
      child: _selectedSection != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_isLoading) return;
                      setState(() {
                        _isSectionPickerOpen = !_isSectionPickerOpen;
                      });
                    },
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName!}",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  child: const Icon(Icons.close),
                  onTap: () {
                    setState(() {
                      _selectedSection = null;
                    });
                  },
                ),
                const SizedBox(width: 10),
              ],
            )
          : InkWell(
              onTap: () {
                if (_isLoading) return;
                setState(() {
                  _isSectionPickerOpen = !_isSectionPickerOpen;
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 14, 5, 14),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName!}",
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (_isLoading) return;
          setState(() {
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
            _isSectionPickerOpen = false;
          });
        },
        child: ClayButton(
          depth: 40,
          color: _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? Colors.blue[200] : clayContainerColor(context),
          spread: _selectedSection != null && _selectedSection!.sectionId == section.sectionId! ? 0 : 2,
          borderRadius: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              section.sectionName!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 40,
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Manage Exams") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ManageCustomExamsScreen(
          adminProfile: widget.adminProfile,
          teacherProfile: widget.teacherProfile,
          selectedAcademicYearId: widget.selectedAcademicYearId,
          sectionsList: _sectionsList,
          teachersList: teachersList,
          tdsList: tdsList,
          studentsList: studentsList,
        );
      }));
    } else {
      debugPrint("Clicked on $choice");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Exams"),
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
          if (!_isLoading && widget.teacherProfile == null)
            PopupMenuButton<String>(
              onSelected: (String choice) async => await handleClick(choice),
              itemBuilder: (BuildContext context) {
                return {
                  "Manage Exams",
                }.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
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
          : ListView(
              children: <Widget>[
                const SizedBox(height: 20),
                _sectionPicker(),
                const SizedBox(height: 20),
                widget.teacherProfile == null && _selectedSection == null
                    ? const Center(
                        child: Text("Select a section to continue"),
                      )
                    : Column(
                        children: [
                          ...customExams
                              .where((e) => (e.examSectionSubjectMapList ?? []).map((e) => e?.sectionId).contains(_selectedSection?.sectionId))
                              .map(
                                (customExam) => Container(
                                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: CustomExamWidget(
                                    adminProfile: widget.adminProfile,
                                    teacherProfile: widget.teacherProfile,
                                    selectedAcademicYearId: widget.selectedAcademicYearId,
                                    sectionsList: _sectionsList,
                                    teachersList: teachersList,
                                    tdsList: tdsList,
                                    customExam: customExam,
                                    studentsList: studentsList,
                                    loadData: _loadData,
                                    editingEnabled: false,
                                  ),
                                ),
                              ),
                        ],
                      ),
              ],
            ),
    );
  }
}
