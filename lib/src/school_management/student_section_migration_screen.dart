import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentSectionMigrationScreen extends StatefulWidget {
  const StudentSectionMigrationScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<StudentSectionMigrationScreen> createState() => _StudentSectionMigrationScreenState();
}

class _StudentSectionMigrationScreenState extends State<StudentSectionMigrationScreen> {
  bool _isLoading = true;
  final _bodyController = ScrollController();

  List<StudentProfile> studentProfiles = [];
  Set<int> selectedStudentsList = {};

  List<Section> sectionsList = [];
  Section? selectedSection;
  bool isSectionPickerOpen = false;
  Section? newSection;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isMigrateMode = false;
  bool _isRollNumberEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      selectedStudentsList = {};
      newSection = null;
      _isMigrateMode = false;
      _isRollNumberEditMode = false;
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

  void handleMoreOptions(String choice) {
    switch (choice) {
      case 'Migrate Students':
        return setState(() => _isMigrateMode = true);
      case 'Update Roll Numbers':
        return setState(() => _isRollNumberEditMode = true);
      case 'Exit Edit Mode':
        return setState(() => _isMigrateMode ? _isMigrateMode = false : _isRollNumberEditMode = false);
      case 'Select All':
        setState(() {
          selectedStudentsList.clear();
          selectedStudentsList.addAll((studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId).map((e) => e.studentId!)));
        });
        _bodyController.animateTo(
          _bodyController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.bounceIn,
        );
        return;
      default:
        return debugPrint("Selected Choice: $choice");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Section Migration"),
        actions: selectedSection == null
            ? []
            : [
                PopupMenuButton<String>(
                  onSelected: handleMoreOptions,
                  itemBuilder: (BuildContext context) {
                    return ((!_isMigrateMode && !_isRollNumberEditMode)
                            ? {'Migrate Students', 'Update Roll Numbers'}
                            : _isMigrateMode
                                ? {if (selectedSection != null) 'Select All', 'Exit Edit Mode'}
                                : {'Exit Edit Mode'})
                        .map((String choice) {
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
              controller: _bodyController,
              children: [
                sectionPicker(),
                if (selectedSection != null && _isRollNumberEditMode) rollNumberSortOptionsWidget(),
                if (selectedSection != null)
                  ...(studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId).toList()
                        ..sort(
                          (a, b) => (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0) == 0
                              ? (a.studentFirstName ?? "-").compareTo(b.studentFirstName ?? "-")
                              : (int.tryParse(a.rollNumber ?? "0") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "0") ?? 0),
                        ))
                      .map(
                        (e) => buildStudentWidget(e),
                      )
                      .toList(),
                if (selectedSection != null && selectedStudentsList.isNotEmpty) migrateToSectionWidget(),
                const SizedBox(height: 150),
              ],
            ),
      floatingActionButton: (_isMigrateMode && selectedStudentsList.isNotEmpty && newSection != null) || (_isRollNumberEditMode)
          ? GestureDetector(
              onTap: _isRollNumberEditMode ? showRollNumberChangeAlertDialogue : showMigrateStudentsAlertDialogue,
              child: ClayButton(
                color: clayContainerColor(context),
                height: 50,
                width: 50,
                borderRadius: 100,
                spread: 4,
                child: const Icon(
                  Icons.check,
                ),
              ),
            )
          : null,
    );
  }

  Container buildStudentWidget(StudentProfile e) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () {
          if (_isMigrateMode) {
            bool value = !selectedStudentsList.contains(e.studentId);
            setState(() {
              if (value == false) {
                selectedStudentsList.remove(e.studentId);
              } else {
                selectedStudentsList.add(e.studentId!);
              }
            });
          }
        },
        child: ClayContainer(
          emboss: false,
          depth: 15,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: _isMigrateMode
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Checkbox(
                        value: selectedStudentsList.contains(e.studentId),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == false || value == null) {
                              selectedStudentsList.remove(e.studentId);
                            } else {
                              selectedStudentsList.add(e.studentId!);
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      if (e.rollNumber != null) Text("${e.rollNumber ?? " - "}."),
                      if (e.rollNumber != null) const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ((e.studentFirstName == null ? "" : (e.studentFirstName ?? "").capitalize() + " ") +
                              (e.studentMiddleName == null ? "" : (e.studentMiddleName ?? "").capitalize() + " ") +
                              (e.studentLastName == null ? "" : (e.studentLastName ?? "").capitalize() + " ")),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: e.studentPhotoUrl == null
                                ? Image.asset(
                                    "assets/images/avatar.png",
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(
                                    e.studentPhotoUrl!,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          Text(e.sectionName ?? "-"),
                        ],
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                : _isRollNumberEditMode
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).orientation == Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.2
                                : MediaQuery.of(context).size.width * 0.1,
                            child: InputDecorator(
                              isFocused: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                label: Text(
                                  "Roll No.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              child: TextField(
                                controller: e.rollNumberController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Roll No.",
                                ),
                                keyboardType: TextInputType.text,
                                autofocus: true,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.studentFirstName ?? "-")),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: e.studentPhotoUrl == null
                                    ? Image.asset(
                                        "assets/images/avatar.png",
                                        fit: BoxFit.contain,
                                      )
                                    : Image.network(
                                        e.studentPhotoUrl!,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                              const SizedBox(height: 10),
                              Text(e.sectionName ?? "-"),
                            ],
                          ),
                          const SizedBox(width: 10),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          if (e.rollNumber != null) Text("${e.rollNumber ?? " - "}."),
                          if (e.rollNumber != null) const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ((e.studentFirstName == null ? "" : (e.studentFirstName ?? "").capitalize() + " ") +
                                  (e.studentMiddleName == null ? "" : (e.studentMiddleName ?? "").capitalize() + " ") +
                                  (e.studentLastName == null ? "" : (e.studentLastName ?? "").capitalize() + " ")),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: e.studentPhotoUrl == null
                                    ? Image.asset(
                                        "assets/images/avatar.png",
                                        fit: BoxFit.contain,
                                      )
                                    : Image.network(
                                        e.studentPhotoUrl!,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                              const SizedBox(height: 10),
                              Text(e.sectionName ?? "-"),
                            ],
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget migrateToSectionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 20),
        const Text("Migrate to"),
        const SizedBox(width: 20),
        DropdownButton(
          isExpanded: false,
          items: sectionsList
              .where((e) => e.sectionId != selectedSection?.sectionId)
              .map((e) => DropdownMenuItem<Section>(
                    value: e,
                    child: Text(e.sectionName ?? "-"),
                  ))
              .toList(),
          onChanged: (Section? value) {
            setState(() {
              newSection = value;
            });
          },
          value: newSection,
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget rollNumberSortOptionsWidget() {
    String sortAsPer = "Alphabetically";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext dialogueContext) {
                  return AlertDialog(
                    title: const Text('Download receipts'),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              value: "Boys First, Girls Next",
                              title: const Text("Boys First, Girls Next"),
                              groupValue: sortAsPer,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() => sortAsPer = newValue);
                                }
                              },
                            ),
                            RadioListTile<String>(
                              value: "Girls First, Boys Next",
                              title: const Text("Girls First, Boys Next"),
                              groupValue: sortAsPer,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() => sortAsPer = newValue);
                                }
                              },
                            ),
                            RadioListTile<String>(
                              value: "Alphabetically",
                              title: const Text("Alphabetically"),
                              groupValue: sortAsPer,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() => sortAsPer = newValue);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Proceed"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          print("611: $sortAsPer");
                          if (sortAsPer == "Alphabetically") {
                            sortStudentsAlphabetically();
                          } else if (sortAsPer == "Boys First, Girls Next") {
                            sortStudentsAlphabetically(boysFirstGirlsNext: true);
                          } else if (sortAsPer == "Girls First, Boys Next") {
                            sortStudentsAlphabetically(boysFirstGirlsNext: false);
                          }
                        },
                      ),
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: ClayButton(
              depth: 15,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 10),
                    Text("Sort alphabetically"),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () {
              debugPrint("585: Tapped");
              setState(() {
                List<StudentProfile> updatedStudentProfiles = studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId).toList();
                updatedStudentProfiles.sort(
                  (a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0),
                );
                for (int i = 0; i < updatedStudentProfiles.length; i++) {
                  updatedStudentProfiles[i].rollNumberController.text = (i + 1).toString();
                }
              });
            },
            child: ClayButton(
              depth: 15,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.filter_list),
                    SizedBox(width: 10),
                    Text("Rearrange as per existing list"),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void sortStudentsAlphabetically({bool? boysFirstGirlsNext}) {
    if (boysFirstGirlsNext == null) {
      setState(() {
        List<StudentProfile> updatedStudentProfiles = studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId).toList();
        updatedStudentProfiles.sort(
          (a, b) => (a.studentFirstName ?? "").compareTo(b.studentFirstName ?? ""),
        );
        for (int i = 0; i < updatedStudentProfiles.length; i++) {
          updatedStudentProfiles[i].rollNumberController.text = (i + 1).toString();
        }
      });
    } else if (boysFirstGirlsNext) {
      setState(() {
        List<StudentProfile> updatedStudentProfiles = studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId).toList();
        updatedStudentProfiles.sort(
          (a, b) {
            int aGender = a.sex == null
                ? 2
                : a.sex == "male"
                    ? 1
                    : 0;
            int bGender = b.sex == null
                ? 2
                : b.sex == "male"
                    ? 1
                    : 0;
            if (aGender == bGender) {
              return (a.studentFirstName ?? "").compareTo(b.studentFirstName ?? "");
            } else {
              return aGender.compareTo(bGender);
            }
          },
        );
        for (int i = 0; i < updatedStudentProfiles.length; i++) {
          updatedStudentProfiles[i].rollNumberController.text = (i + 1).toString();
        }
      });
    } else {
      setState(() {
        List<StudentProfile> updatedStudentProfiles = studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId).toList();
        updatedStudentProfiles.sort(
          (a, b) {
            int aGender = a.sex == null
                ? 2
                : a.sex == "female"
                    ? 1
                    : 0;
            int bGender = b.sex == null
                ? 2
                : b.sex == "female"
                    ? 1
                    : 0;
            if (aGender == bGender) {
              return (a.studentFirstName ?? "").compareTo(b.studentFirstName ?? "");
            } else {
              return aGender.compareTo(bGender);
            }
          },
        );
        for (int i = 0; i < updatedStudentProfiles.length; i++) {
          updatedStudentProfiles[i].rollNumberController.text = (i + 1).toString();
        }
      });
    }
  }

  Future<void> showMigrateStudentsAlertDialogue() async {
    if (selectedStudentsList.isEmpty) return;
    if (newSection == null) return;
    if (selectedSection == null) return;
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: Text(
              'Are you sure you want to migrate the following students from ${selectedSection?.sectionName ?? "-"} to ${newSection?.sectionName ?? "-"}?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: studentProfiles
                  .where((eachStudent) => selectedStudentsList.contains(eachStudent.studentId))
                  .map((eachStudent) => Text("${eachStudent.rollNumber}. ${eachStudent.studentFirstName}"))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                CreateOrUpdateBulkStudentProfilesRequest createOrUpdateBulkStudentProfilesRequest = CreateOrUpdateBulkStudentProfilesRequest(
                  agent: widget.adminProfile.userId,
                  schoolId: widget.adminProfile.schoolId,
                  studentProfiles: studentProfiles
                      .where((eachStudent) => selectedStudentsList.contains(eachStudent.studentId))
                      .map((eachStudent) => StudentProfile.fromJson(eachStudent.origJson())
                        ..sectionId = newSection?.sectionId
                        ..rollNumber = "0"
                        ..agentId = widget.adminProfile.userId)
                      .toList(),
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
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> showRollNumberChangeAlertDialogue() async {
    if (selectedSection == null) return;
    List<StudentProfile> updatedStudentProfiles = studentProfiles
        .where((e) => e.sectionId == selectedSection?.sectionId && (e.rollNumber ?? "") != e.rollNumberController.text.trim())
        .map((e) => StudentProfile.fromJson(e.origJson())
          ..rollNumber = e.rollNumberController.text.trim()
          ..agentId = widget.adminProfile.userId
          ..rollNumberController.text = e.rollNumberController.text.trim())
        .toList();
    if (updatedStudentProfiles.isEmpty) return;
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text(
            'Are you sure you want to change the roll number of following students?',
          ),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: studentProfiles
                        .where((eachStudent) => updatedStudentProfiles.map((e) => e.studentId).contains(eachStudent.studentId))
                        .map((eachStudent) => Text("${eachStudent.rollNumber}. ${eachStudent.studentFirstName}"))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children:
                        updatedStudentProfiles.map((eachStudent) => Text(" -\t${eachStudent.rollNumber}. ${eachStudent.studentFirstName}")).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                CreateOrUpdateBulkStudentProfilesRequest createOrUpdateBulkStudentProfilesRequest = CreateOrUpdateBulkStudentProfilesRequest(
                  agent: widget.adminProfile.userId,
                  schoolId: widget.adminProfile.schoolId,
                  studentProfiles: updatedStudentProfiles,
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
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
