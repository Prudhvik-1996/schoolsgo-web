import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/manage_fa_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/model/fa_exams.dart';
import 'package:schoolsgo_web/src/exams/fa_exams/views/fa_exam_widget.dart';
import 'package:schoolsgo_web/src/exams/model/marking_algorithms.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/sms/modal/sms.dart';
import 'package:collection/collection.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class FAExamsScreen extends StatefulWidget {
  const FAExamsScreen({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
    required this.selectedAcademicYearId,
    this.defaultSelectedSection,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;
  final int selectedAcademicYearId;
  final Section? defaultSelectedSection;

  @override
  State<FAExamsScreen> createState() => _AdminFAExamsScreenState();
}

class _AdminFAExamsScreenState extends State<FAExamsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  late SchoolInfoBean schoolInfo;

  List<Section> _sectionsList = [];
  Section? _selectedSection;

  List<StudentProfile> studentsList = [];
  List<TeacherDealingSection> tdsList = [];
  List<Teacher> teachersList = [];
  List<Subject> subjectsList = [];

  bool _isSectionPickerOpen = false;

  List<FAExam> faExams = [];
  List<MarkingAlgorithmBean> markingAlgorithms = [];

  SmsTemplateBean? smsTemplate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _selectedSection = widget.defaultSelectedSection;
    });

    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
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

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      teacherId: widget.defaultSelectedSection != null ? null : widget.teacherProfile?.teacherId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        tdsList = (getTeacherDealingSectionsResponse.teacherDealingSections ?? []).toList();
      });
    }

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      teacherId: widget.defaultSelectedSection != null ? null : widget.teacherProfile?.teacherId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        teachersList = getTeachersResponse.teachers!;
      });
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      sectionId: widget.defaultSelectedSection?.sectionId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetSubjectsRequest getSubjectsRequest = GetSubjectsRequest(schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId);
    GetSubjectsResponse getSubjectsResponse = await getSubjects(getSubjectsRequest);

    if (getSubjectsResponse.httpStatus == "OK" && getSubjectsResponse.responseStatus == "success") {
      setState(() {
        subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
      });
    }

    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      sectionId: widget.defaultSelectedSection?.sectionId,
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

    GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await getMarkingAlgorithms(GetMarkingAlgorithmsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getMarkingAlgorithmsResponse.httpStatus == "OK" && getMarkingAlgorithmsResponse.responseStatus == "success") {
      setState(() {
        markingAlgorithms = getMarkingAlgorithmsResponse.markingAlgorithmBeanList!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }

    if (widget.adminProfile != null) {
      GetSmsTemplatesResponse getSmsTemplatesResponse = await getSmsTemplates(GetSmsTemplatesRequest(
        categoryId: 4,
        schoolId: widget.adminProfile?.schoolId,
      ));
      if (getSmsTemplatesResponse.httpStatus != "OK" ||
          getSmsTemplatesResponse.responseStatus != "success" ||
          getSmsTemplatesResponse.smsTemplateBeans == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        smsTemplate = getSmsTemplatesResponse.smsTemplateBeans?.firstOrNull;
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Manage Exams") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ManageFAExamsScreen(
          schoolInfo: schoolInfo,
          adminProfile: widget.adminProfile,
          teacherProfile: widget.teacherProfile,
          selectedAcademicYearId: widget.selectedAcademicYearId,
          sectionsList: _sectionsList,
          teachersList: teachersList,
          subjectsList: subjectsList,
          tdsList: tdsList,
          studentsList: studentsList,
          markingAlgorithms: markingAlgorithms,
        );
      }));
    } else {
      debugPrint("Clicked on $choice");
    }
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
                      if (widget.defaultSelectedSection != null) return;
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
                if (widget.defaultSelectedSection != null) const SizedBox(width: 10),
                if (widget.defaultSelectedSection != null)
                  InkWell(
                    child: const Icon(Icons.close),
                    onTap: () {
                      setState(() {
                        _selectedSection = null;
                      });
                    },
                  ),
                if (widget.defaultSelectedSection != null) const SizedBox(width: 10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Exams With Internals"),
        actions: widget.defaultSelectedSection != null
            ? []
            : [
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
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: <Widget>[
                const SizedBox(height: 20),
                _sectionPicker(),
                const SizedBox(height: 20),
                _selectedSection == null
                    ? const Center(
                        child: Text("Select a section to continue"),
                      )
                    : Column(
                        children: [
                          ...faExams.map(
                            (faExam) => Container(
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: FAExamWidget(
                                scaffoldKey: scaffoldKey,
                                schoolInfo: schoolInfo,
                                adminProfile: widget.adminProfile,
                                teacherProfile: widget.teacherProfile,
                                selectedAcademicYearId: widget.selectedAcademicYearId,
                                sectionsList: _sectionsList,
                                teachersList: teachersList,
                                subjectsList: subjectsList,
                                tdsList: tdsList,
                                faExam: faExam,
                                studentsList: studentsList,
                                loadData: _loadData,
                                editingEnabled: false,
                                selectedSection: _selectedSection,
                                markingAlgorithms: markingAlgorithms,
                                setLoading: (bool isLoading) => setState(() => _isLoading = isLoading),
                                isClassTeacher: widget.defaultSelectedSection != null,
                                smsTemplate: smsTemplate,
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
