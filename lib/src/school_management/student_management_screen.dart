import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/student_card_widget.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<StudentManagementScreen> createState() => StudentManagementScreenState();
}

class StudentManagementScreenState extends State<StudentManagementScreen> {
  bool _isLoading = true;
  List<StudentProfile> studentProfiles = [];
  List<Section> sectionsList = [];
  Section? selectedSection;
  bool isSectionPickerOpen = false;

  int? selectedStudentId;
  int? editingStudentId;

  bool _isAddNew = false;
  late StudentProfile newStudent;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      newStudent = StudentProfile(
        agentId: widget.adminProfile.userId,
        schoolId: widget.adminProfile.schoolId,
      );
    });
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
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: selectSectionExpanded(),
                ),
              )
            : selectSectionCollapsed(),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            if (selectedSection != null && selectedSection!.sectionId == section.sectionId) {
              selectedSection = null;
            } else {
              selectedSection = section;
              isSectionPickerOpen = false;
            }
            newStudent.sectionId = selectedSection?.sectionId;
            newStudent.sectionName = selectedSection?.sectionName;
          });
        },
        child: ClayButton(
          depth: 40,
          spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
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

  Widget selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                isSectionPickerOpen = !isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
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
            children: sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            isSectionPickerOpen = !isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onStudentSelected(int? studentId) {
    if (_isAddNew) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the new student's details to continue"),
        ),
      );
      return;
    }
    if (editingStudentId == null) {
      setState(() => selectedStudentId = studentId);
    }
  }

  void onEditSelected(int? studentId) {
    if (_isAddNew) {
      setState(() {
        _isAddNew = false;
        newStudent = StudentProfile(
          agentId: widget.adminProfile.userId,
          schoolId: widget.adminProfile.schoolId,
          sectionId: selectedSection?.sectionId,
          sectionName: selectedSection?.sectionName,
        );
      });
      return;
    }
    setState(() => editingStudentId = studentId);
  }

  void updateStudentProfile(int? studentId, StudentProfile updatedStudentProfile, {bool addNew = false}) {
    if (studentId == null && !addNew) return;
    setState(() {
      studentProfiles.removeWhere((eachStudent) => eachStudent.studentId == studentId);
      studentProfiles.add(updatedStudentProfile);
    });
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAddNew) _scrollDown();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Management"),
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
              controller: _controller,
              children: [
                sectionPicker(),
                if (selectedSection != null)
                  ...(studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId && e.status == "active").toList()
                            ..sort(
                              (a, b) => (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0) == 0
                                  ? (a.studentFirstName ?? "-").compareTo(b.studentFirstName ?? "-")
                                  : (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0),
                            ))
                          .map(
                            (e) => StudentCardWidget(
                              scaffoldKey: scaffoldKey,
                              studentProfile: e,
                              adminProfile: widget.adminProfile,
                              isStudentSelected: selectedStudentId == e.studentId,
                              onStudentSelected: onStudentSelected,
                              isEditMode: editingStudentId == e.studentId,
                              onEditSelected: onEditSelected,
                              updateStudentProfile: updateStudentProfile,
                              allowExpansion: true,
                              loadAllData: _loadData,
                            ),
                          )
                          .toList() +
    (studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId && e.status == "inactive").toList()
                            ..sort(
                              (a, b) => (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0) == 0
                                  ? (a.studentFirstName ?? "-").compareTo(b.studentFirstName ?? "-")
                                  : (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0),
                            ))
                          .map(
                            (e) => StudentCardWidget(
                              scaffoldKey: scaffoldKey,
                              studentProfile: e,
                              adminProfile: widget.adminProfile,
                              isStudentSelected: selectedStudentId == e.studentId,
                              onStudentSelected: onStudentSelected,
                              isEditMode: editingStudentId == e.studentId,
                              onEditSelected: onEditSelected,
                              updateStudentProfile: updateStudentProfile,
                              allowExpansion: true,
                              loadAllData: _loadData,
                            ),
                          )
                          .toList() +
                      [
                        if (_isAddNew)
                          StudentCardWidget(
                            scaffoldKey: scaffoldKey,
                            studentProfile: newStudent,
                            adminProfile: widget.adminProfile,
                            isStudentSelected: true,
                            onStudentSelected: onStudentSelected,
                            isEditMode: true,
                            onEditSelected: onEditSelected,
                            updateStudentProfile: updateStudentProfile,
                            allowExpansion: true,
                            loadAllData: _loadData,
                          ),
                      ],
              ],
            ),
      floatingActionButton: _isLoading || editingStudentId != null || _isAddNew
          ? null
          : GestureDetector(
              onTap: () {
                if (selectedSection == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Select a section to add student"),
                    ),
                  );
                  return;
                }
                setState(() {
                  newStudent.rollNumber = ((int.tryParse((studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId).toList()
                                        ..sort(
                                          (a, b) => (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0) == 0
                                              ? (a.studentFirstName ?? "-").compareTo(b.studentFirstName ?? "-")
                                              : (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0),
                                        ))
                                      .reversed
                                      .firstOrNull
                                      ?.rollNumber ??
                                  "") ??
                              0) +
                          1)
                      .toString();
                  newStudent.rollNumberController.text = newStudent.rollNumber ?? "";
                  selectedStudentId = null;
                  _isAddNew = !_isAddNew;
                });
              },
              child: _isAddNew
                  ? ClayButton(
                      color: clayContainerColor(context),
                      height: 50,
                      width: 50,
                      borderRadius: 100,
                      spread: 4,
                      child: const Icon(
                        Icons.check,
                      ),
                    )
                  : ClayButton(
                      color: clayContainerColor(context),
                      height: 50,
                      width: 50,
                      borderRadius: 100,
                      spread: 4,
                      child: const Icon(
                        Icons.add,
                      ),
                    ),
            ),
    );
  }
}
