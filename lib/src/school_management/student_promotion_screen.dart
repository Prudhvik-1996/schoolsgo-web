import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentPromotionScreen extends StatefulWidget {
  const StudentPromotionScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<StudentPromotionScreen> createState() => _StudentPromotionScreenState();
}

class _StudentPromotionScreenState extends State<StudentPromotionScreen> {
  bool _isLoading = true;
  final _bodyController = ScrollController();

  List<StudentProfile> studentProfiles = [];
  Set<int> selectedStudentsList = {};

  List<Section> sectionsList = [];
  List<Section> newSectionsList = [];
  Section? selectedSection;
  bool isSectionPickerOpen = false;
  Section? newSection;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPromotionMode = false;

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
      _isPromotionMode = false;
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
    GetSectionsResponse getNewSectionsResponse = await getSections(
      GetSectionsRequest(
        linkedSchoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getNewSectionsResponse.httpStatus == "OK" && getNewSectionsResponse.responseStatus == "success") {
      setState(() {
        newSectionsList = getNewSectionsResponse.sections!.map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void handleMoreOptions(String choice) {
    switch (choice) {
      case 'Promote Students':
        return setState(() => _isPromotionMode = true);
      case 'Exit Edit Mode':
        return setState(() => _isPromotionMode = false);
      case 'Select All':
        setState(() {
          selectedStudentsList.clear();
          selectedStudentsList
              .addAll(studentProfiles.where((e) => e.sectionId == selectedSection?.sectionId && !(e.promoted ?? false)).map((e) => e.studentId!));
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: selectedSection == null
              ? const Text("Student Promotion")
              : newSection == null
                  ? Text("Promote from ${selectedSection?.sectionName}")
                  : Text("Promote from ${selectedSection?.sectionName} to ${newSection?.sectionName}"),
        ),
        actions: selectedSection == null
            ? []
            : [
                PopupMenuButton<String>(
                  onSelected: handleMoreOptions,
                  itemBuilder: (BuildContext context) {
                    return ((!_isPromotionMode)
                            ? {'Promote Students'}
                            : _isPromotionMode
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
                if (selectedSection != null && selectedStudentsList.isNotEmpty) promoteToSectionWidget(),
                const SizedBox(height: 150),
              ],
            ),
      floatingActionButton: (_isPromotionMode && selectedStudentsList.isNotEmpty && newSection != null)
          ? GestureDetector(
              onTap: showMigrateStudentsAlertDialogue,
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

  Container buildStudentWidget(StudentProfile e) {
    if (e.studentId == 4202) {
      print("324: ${e.origJson()}");
    }
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.all(10)
          : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () {
          if (!_isPromotionMode) return;
          if (e.promoted ?? false) return;
          bool value = !selectedStudentsList.contains(e.studentId);
          addOrRemoveStudentToSelectedList(value, e);
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
            child: _isPromotionMode
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      if (!(e.promoted ?? false))
                        Checkbox(
                          value: selectedStudentsList.contains(e.studentId),
                          onChanged: (bool? value) {
                            if (e.promoted ?? false) return;
                            addOrRemoveStudentToSelectedList(value, e);
                          },
                        ),
                      const SizedBox(width: 10),
                      if (e.rollNumber != null) Text("${e.rollNumber ?? " - "}."),
                      if (e.rollNumber != null) const SizedBox(width: 10),
                      Expanded(
                        child: studentNameWidget(e),
                      ),
                      const SizedBox(width: 10),
                      studentProfileAvatarWidget(e),
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
                        child: studentNameWidget(e),
                      ),
                      const SizedBox(width: 10),
                      studentProfileAvatarWidget(e),
                      const SizedBox(width: 10),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Text studentNameWidget(StudentProfile e) {
    return Text(
      ((e.studentFirstName == null ? "" : (e.studentFirstName ?? "").capitalize() + " ") +
          (e.studentMiddleName == null ? "" : (e.studentMiddleName ?? "").capitalize() + " ") +
          (e.studentLastName == null ? "" : (e.studentLastName ?? "").capitalize() + " ")),
    );
  }

  Chip promotedSectionWidget(StudentProfile e) {
    return Chip(
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${e.sectionName}",
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_double_arrow_right_sharp,
                color: Colors.green,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                "${e.promotedSectionName}",
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column studentProfileAvatarWidget(StudentProfile e) {
    return Column(
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
        (e.promoted ?? false) ? promotedSectionWidget(e) : Text(e.sectionName ?? "-"),
      ],
    );
  }

  void addOrRemoveStudentToSelectedList(bool? value, StudentProfile e) {
    setState(() {
      if (value == false || value == null) {
        selectedStudentsList.remove(e.studentId);
      } else {
        selectedStudentsList.add(e.studentId!);
      }
    });
  }

  Widget promoteToSectionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 20),
        const Text("Promote to"),
        const SizedBox(width: 20),
        DropdownButton(
          isExpanded: false,
          items: newSectionsList
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

  Future<void> showMigrateStudentsAlertDialogue() async {
    if (selectedStudentsList.isEmpty) return;
    if (newSection == null) return;
    if (selectedSection == null) return;
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: Text(
              'Are you sure you want to promote the following students from ${selectedSection?.sectionName ?? "-"} to ${newSection?.sectionName ?? "-"}?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: studentProfiles
                  .where((eachStudent) => selectedStudentsList.contains(eachStudent.studentId) && !(eachStudent.promoted ?? false))
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
                      .where((eachStudent) => selectedStudentsList.contains(eachStudent.studentId) && !(eachStudent.promoted ?? false))
                      .map((eachStudent) => StudentProfile.fromJson(eachStudent.origJson())
                        ..linkedStudentId = eachStudent.studentId
                        ..studentId = null
                        ..schoolId = newSection?.schoolId
                        ..sectionId = newSection?.sectionId
                        ..rollNumber = eachStudent.rollNumber
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
