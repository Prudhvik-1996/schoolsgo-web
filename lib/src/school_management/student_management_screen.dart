import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/student_status.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/school_management/student_card_widget.dart';
import 'package:schoolsgo_web/src/school_management/student_creation_in_bulk.dart';
import 'package:schoolsgo_web/src/school_management/student_enrollment_form_screen.dart';

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

  bool showSearchBar = false;
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
      showSearchBar = false;
      newStudent = StudentProfile(
        agentId: widget.adminProfile.userId,
        schoolId: widget.adminProfile.schoolId,
        status: 'active',
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
      studentProfiles.sort((a, b) {
        int aSectionSeqOder = a.sectionSeqOrder ?? 0;
        int bSectionSeqOder = b.sectionSeqOrder ?? 0;
        int aRollNumber = int.tryParse(a.rollNumber ?? "") ?? 0;
        int bRollNumber = int.tryParse(b.rollNumber ?? "") ?? 0;
        return aSectionSeqOder != bSectionSeqOder ? aSectionSeqOder.compareTo(bSectionSeqOder) : aRollNumber.compareTo(bRollNumber);
      });
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

  @override
  Widget build(BuildContext context) {
    if (_isAddNew) _scrollDown();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: selectedSection == null ? const Text("Student Management") : Text(selectedSection?.sectionName ?? "-"),
        actions: ((MediaQuery.of(context).orientation == Orientation.landscape)
            ? [
                if (!_isLoading && !showSearchBar) IconButton(onPressed: () => setState(() => showSearchBar = true), icon: const Icon(Icons.search)),
                if (!_isLoading && showSearchBar) _studentSearchableDropDown(),
              ]
            : [])
          ..addAll([
            if (!_isLoading && selectedSection != null)
              PopupMenuButton<String>(
                tooltip: "Templates for student bulk upload",
                onSelected: (String choice) async {
                  switch (choice) {
                    case "Download Template":
                      await downloadTemplateAction();
                      return;
                    case "Upload From Template":
                      await uploadFromTemplateAction();
                      return;
                    default:
                      return;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {
                    "Download Template",
                    "Upload From Template",
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            // PopupMenuButton<String>(
            //   onSelected: (String? selectedValue) {
            //     if (selectedValue == "V2") {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) {
            //             return StudentManagementScreenV2(
            //               adminProfile: widget.adminProfile,
            //               studentProfiles: studentProfiles,
            //               sectionsList: sectionsList,
            //             );
            //           },
            //         ),
            //       );
            //     }
            //   },
            //   itemBuilder: (BuildContext context) {
            //     return {"V2"}.map((String choice) {
            //       return PopupMenuItem<String>(
            //         value: choice,
            //         child: Text(choice),
            //       );
            //     }).toList();
            //   },
            // ),
          ]),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              controller: _controller,
              children: <Widget>[
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
                          students: studentProfiles,
                          sections: sectionsList,
                        ),
                      )
                      .toList(),
                if (selectedSection != null)
                  ...(studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId && e.status == "inactive").toList()
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
                              students: studentProfiles,
                              sections: sectionsList,
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
                            students: studentProfiles,
                            sections: sectionsList,
                          ),
                      ],
              ],
            ),
      floatingActionButton: _isLoading || editingStudentId != null || _isAddNew ? null : fab(context),
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
          status: 'active',
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

  Future<void> downloadTemplateAction() async {
    await CreateStudentsInBulkExcel(
      studentProfiles.where((es) => es.sectionId == selectedSection?.sectionId).toList(),
      selectedSection!,
      agentId: widget.adminProfile.userId,
      schoolId: widget.adminProfile.schoolId,
    ).downloadTemplate();
  }

  Future<void> uploadFromTemplateAction() async {
    List<StudentProfile>? newStudentsList = await CreateStudentsInBulkExcel(
      studentProfiles.where((es) => es.sectionId == selectedSection?.sectionId).toList(),
      selectedSection!,
      agentId: widget.adminProfile.userId,
      schoolId: widget.adminProfile.schoolId,
    ).readAndValidateExcel(context);
    if ((newStudentsList ?? []).isEmpty) return;
    await showDialog(
      context: scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: Text("Confirm to add new students to ${selectedSection?.sectionName}"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView(
                  children: [
                    ...newStudentsList?.map((e) => Text("${e.rollNumber == null ? "" : "${e.rollNumber}. "}${e.studentFirstName ?? " - "}")) ?? []
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                CreateOrUpdateBulkStudentProfilesRequest createOrUpdateBulkStudentProfilesRequest = CreateOrUpdateBulkStudentProfilesRequest(
                  agent: widget.adminProfile.userId,
                  schoolId: widget.adminProfile.schoolId,
                  studentProfiles: newStudentsList,
                );
                CreateOrUpdateBulkStudentProfilesResponse createOrUpdateBulkStudentProfilesResponse =
                    await createOrUpdateBulkStudentProfiles(createOrUpdateBulkStudentProfilesRequest);
                if (createOrUpdateBulkStudentProfilesResponse.httpStatus != "OK" ||
                    createOrUpdateBulkStudentProfilesResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                } else {
                  _loadData();
                }
                setState(() => _isLoading = false);
                await _loadData();
              },
              child: const Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _studentSearchableDropDown() {
    return Container(
      width: 300,
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: DropdownSearch<StudentProfile>(
              mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
              selectedItem: null,
              items: studentProfiles,
              itemAsString: (StudentProfile? student) {
                return student == null
                    ? ""
                    : [
                          ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                          student.studentFirstName ?? "",
                          student.studentMiddleName ?? "",
                          student.studentLastName ?? ""
                        ].where((e) => e != "").join(" ").trim() +
                        " - ${student.sectionName}";
              },
              showSearchBox: true,
              dropdownBuilder: (BuildContext context, StudentProfile? student) {
                return buildStudentWidget(student ?? StudentProfile());
              },
              onChanged: (StudentProfile? student) {
                if (student != null) {
                  setState(() {
                    selectedSection = sectionsList.where((e) => e.sectionId == student.sectionId).firstOrNull;
                  });
                  //  TODO scroll down to student
                }
              },
              compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
              dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
              filterFn: (StudentProfile? student, String? key) {
                return ([
                          ((student?.rollNumber ?? "") == "" ? "" : student!.rollNumber! + "."),
                          student?.studentFirstName ?? "",
                          student?.studentMiddleName ?? "",
                          student?.studentLastName ?? ""
                        ].where((e) => e != "").join(" ") +
                        " - ${student?.sectionName ?? ""}")
                    .toLowerCase()
                    .trim()
                    .contains(key!.toLowerCase());
              },
            ),
          ),
          InkWell(
            child: const SizedBox(
              height: 15,
              width: 15,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Icon(Icons.clear),
              ),
            ),
            onTap: () => setState(() => showSearchBar = false),
          )
        ],
      ),
    );
  }

  Widget buildStudentWidget(StudentProfile e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: Center(
        child: AutoSizeText(
          ((e.rollNumber ?? "") == "" ? "" : e.rollNumber! + ". ") +
              ([e.studentFirstName ?? "", e.studentMiddleName ?? "", e.studentLastName ?? ""].where((e) => e != "").join(" ") +
                      " - ${e.sectionName ?? ""}")
                  .trim(),
          style: const TextStyle(
            fontSize: 14,
          ),
          overflow: TextOverflow.visible,
          maxLines: 1,
          minFontSize: 12,
        ),
      ),
    );
  }

  GestureDetector fab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if (selectedSection == null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("Select a section to add student"),
        //     ),
        //   );
        //   return;
        // }
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
          // _isAddNew = !_isAddNew;
        });
        // StudentCardWidgetV2
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return StudentEnrollmentFormScreen(
            studentProfile: newStudent
              ..sectionId = selectedSection?.sectionId
              ..sectionName = selectedSection?.sectionName
              ..studentStatus = StudentStatus.new_admission.name,
            sections: sectionsList,
            adminProfile: widget.adminProfile,
            students: studentProfiles,
            isEditMode: true,
          );
        })).then((value) => _loadData());
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
    );
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
}
