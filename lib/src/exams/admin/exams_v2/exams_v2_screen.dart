import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/exams_v2/fa_exam_v2_widget.dart';
import 'package:schoolsgo_web/src/exams/admin/exams_v2/manage_exams_v2_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class ExamsV2Screen extends StatefulWidget {
  const ExamsV2Screen({
    super.key,
    required this.adminProfile,
  });

  final AdminProfile adminProfile;

  @override
  State<ExamsV2Screen> createState() => _ExamsV2ScreenState();
}

class _ExamsV2ScreenState extends State<ExamsV2Screen> {
  bool _isLoading = true;

  List<TeacherDealingSection> tdsList = [];

  bool _isSectionPickerOpen = false;
  List<Section> _sectionsList = [];
  Section? _selectedSection;
  List<Teacher> teachersList = [];
  List<Subject> subjectsList = [];

  List<FAExam> examsList = [];
  List<MarkingAlgorithmBean> markingAlgorithms = [];

  late SchoolInfoBean schoolInfo;
  List<StudentProfile> studentsList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      tdsList = (getTeacherDealingSectionsResponse.teacherDealingSections ?? []).toList();
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
    }

    GetSubjectsRequest getSubjectsRequest = GetSubjectsRequest(schoolId: widget.adminProfile.schoolId);
    GetSubjectsResponse getSubjectsResponse = await getSubjects(getSubjectsRequest);
    if (getSubjectsResponse.httpStatus == "OK" && getSubjectsResponse.responseStatus == "success") {
      subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
    }

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        teachersList = getTeachersResponse.teachers!;
      });
    }

    await loadExams();

    GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await getMarkingAlgorithms(GetMarkingAlgorithmsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getMarkingAlgorithmsResponse.httpStatus == "OK" && getMarkingAlgorithmsResponse.responseStatus == "success") {
      markingAlgorithms = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }

    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfo = getSchoolsResponse.schoolInfo!;
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
    } else {
      studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
      studentsList.sort((a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0));
    }
    setState(() => _isLoading = false);
  }

  Future<void> loadExams() async {
    GetFAExamsResponse getFAExamsResponse = await getFAExamsWithStats(GetFAExamsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getFAExamsResponse.httpStatus != "OK" || getFAExamsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      examsList = (getFAExamsResponse.exams ?? []).map((e) => e!).toList();
    }
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Manage Exams") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ManageExamsV2Screen(
          schoolInfo: schoolInfo,
          adminProfile: widget.adminProfile,
          teacherProfile: null,
          selectedAcademicYearId: -1,
          sectionsList: _sectionsList,
          teachersList: teachersList,
          subjectsList: subjectsList,
          tdsList: tdsList,
          studentsList: studentsList,
          markingAlgorithms: markingAlgorithms,
        );
      })).then((value) async {
        setState(() => _isLoading = true);
        await loadExams();
        setState(() => _isLoading = false);
      });
    } else {
      debugPrint("Clicked on $choice");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exams"),
        actions: [
          if (!_isLoading)
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
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                const SizedBox(height: 10),
                _sectionPicker(),
                const SizedBox(height: 10),
                if (_selectedSection == null)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text("Select a section to continue.."),
                    ),
                  ),
                if (_selectedSection != null)
                  ...examsList
                      .where((e) => (e.faInternalExams ?? [])
                          .map((e) => e?.examSectionSubjectMapList ?? [])
                          .expand((i) => i)
                          .where((e) => e?.sectionId == _selectedSection?.sectionId && e?.status == 'active')
                          .isNotEmpty)
                      .map(
                        (e) => FaExamV2Widget(
                          exam: e,
                          adminProfile: widget.adminProfile,
                          tdsList: tdsList,
                          selectedSection: _selectedSection,
                          sectionsList: _sectionsList,
                          subjectsList: subjectsList,
                          teachersList: teachersList,
                          markingAlgorithms: markingAlgorithms,
                          schoolInfo: schoolInfo,
                          studentsList: studentsList.where((es) => es.sectionId == _selectedSection?.sectionId).toList(),
                          editingEnabled: false,
                          showMoreOptions: true,
                        ),
                      ),
                const SizedBox(height: 100),
              ],
            ),
    );
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
          setState(() => _isLoading = true);
          setState(() {
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
            _isSectionPickerOpen = false;
          });
          setState(() => _isLoading = false);
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
}
