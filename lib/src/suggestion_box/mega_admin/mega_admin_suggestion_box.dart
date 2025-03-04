import 'package:clay_containers/widgets/clay_container.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/suggestion_box/model/suggestion_box.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class MegaAdminSuggestionBox extends StatefulWidget {
  const MegaAdminSuggestionBox({
    Key? key,
    required this.megaAdminProfile,
  }) : super(key: key);

  final MegaAdminProfile megaAdminProfile;

  @override
  State<MegaAdminSuggestionBox> createState() => _MegaAdminSuggestionBoxState();
}

class _MegaAdminSuggestionBoxState extends State<MegaAdminSuggestionBox> {
  bool _isLoading = true;

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionPickerOpen = false;

  List<TeacherDealingSection> _tdsList = [];
  List<TeacherDealingSection> _filteredTdsList = [];

  List<Suggestion> _suggestions = [];
  List<Suggestion> _filteredSuggestions = [];

  String? _selectedComplainStatus;

  bool _showOnlyAnonymous = false;

  AdminProfile? selectedSchool;

  @override
  void initState() {
    super.initState();
    _loadSchoolWiseData();
  }

  Future<void> _loadSchoolWiseData() async {
    setState(() {
      _isLoading = true;
    });

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.megaAdminProfile.schoolId,
      franchiseId: widget.megaAdminProfile.franchiseId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachersList = getTeachersResponse.teachers!;
        if (_teachersList.length == 1) {
          _selectedTeacher = _teachersList[0];
        } else {
          _teachersList.sort((a, b) => (a.teacherName ?? "-").compareTo((b.teacherName ?? "-")));
        }
      });
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.megaAdminProfile.schoolId,
      franchiseId: widget.megaAdminProfile.franchiseId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.megaAdminProfile.schoolId,
      franchiseId: widget.megaAdminProfile.franchiseId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
        _filteredTdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }

    GetSuggestionBoxResponse getSuggestionBoxResponse = await getSuggestionBox(GetSuggestionBoxRequest(
      schoolId: widget.megaAdminProfile.schoolId,
      franchiseId: widget.megaAdminProfile.franchiseId,
    ));
    if (getSuggestionBoxResponse.httpStatus == "OK" && getSuggestionBoxResponse.responseStatus == "success") {
      setState(() {
        _suggestions = getSuggestionBoxResponse.complaintBeans!.map((e) => e!).toList();
        _filteredSuggestions = getSuggestionBoxResponse.complaintBeans!.map((e) => e!).toList();
      });
    }

    _applyFilters();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _filteredTdsList = _tdsList;
      _filteredSuggestions = _suggestions;
    });
    if (selectedSchool != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList.where((e) => e.schoolId == selectedSchool!.schoolId).toList();
        _filteredSuggestions = _filteredSuggestions.where((e) => e.schoolId == selectedSchool!.schoolId).toList();
      });
    }
    if (_selectedTeacher != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList.where((e) => e.teacherId == _selectedTeacher!.teacherId).toList();
        _filteredSuggestions = _filteredSuggestions.where((e) => e.teacherId == _selectedTeacher!.teacherId).toList();
      });
    }
    if (_selectedSection != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList.where((e) => e.sectionId == _selectedSection!.sectionId).toList();
        _filteredSuggestions = _filteredSuggestions.where((e) => e.sectionId == _selectedSection!.sectionId).toList();
      });
    }
    if (_showOnlyAnonymous) {
      setState(() {
        _filteredSuggestions = _filteredSuggestions.where((e) => e.anonymous!).toList();
      });
    }
    if (_selectedComplainStatus != null) {
      setState(() {
        _filteredSuggestions = _filteredSuggestions.where((e) => e.complainStatus == _selectedComplainStatus).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  DropdownSearch<AdminProfile> searchableDropdownButtonForSchool() {
    return DropdownSearch<AdminProfile>(
      mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
      selectedItem: selectedSchool,
      items: widget.megaAdminProfile.adminProfiles ?? [],
      itemAsString: (AdminProfile? school) {
        return school == null ? "-" : (school.schoolName! + (school.branchCode != null ? " - ${school.branchCode}" : ""));
      },
      showSearchBox: true,
      dropdownBuilder: (BuildContext context, AdminProfile? school) {
        return buildSchoolWidget(school);
      },
      onChanged: (AdminProfile? school) {
        setState(() {
          selectedSchool = school;
          if (school == null) {
            _selectedSection = null;
          }
        });
        _applyFilters();
      },
      showClearButton: true,
      compareFn: (item, selectedItem) => item?.schoolId == selectedItem?.schoolId,
      dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
      filterFn: (AdminProfile? school, String? key) {
        return (school == null ? "-" : (school.schoolName! + (school.branchCode != null ? " - ${school.branchCode}" : "")))
            .toLowerCase()
            .contains(key!.toLowerCase());
      },
    );
  }

  Widget buildSchoolWidget(AdminProfile? e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListTile(
        leading: Container(
          width: 50,
          padding: const EdgeInsets.all(5),
          child: e?.schoolPhotoUrl == null
              ? SvgPicture.asset(
                  "assets/images/school.svg",
                  fit: BoxFit.contain,
                )
              : Image.network(
                  e!.schoolPhotoUrl!,
                  fit: BoxFit.contain,
                ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            (e == null ? "Select a school" : (e.schoolName! + (e.branchCode != null ? " - ${e.branchCode}" : ""))),
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  ClayButton _selectTeacher() {
    return ClayButton(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      height: 50,
      width: 50,
      child: DropdownSearch<Teacher>(
        mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
        selectedItem: _selectedTeacher,
        items: _teachersList,
        itemAsString: (Teacher? teacher) {
          return teacher == null ? "" : teacher.teacherName ?? "";
        },
        showSearchBox: true,
        dropdownBuilder: (BuildContext context, Teacher? teacher) {
          return _buildTeacherWidget(teacher ?? Teacher());
        },
        onChanged: (Teacher? teacher) {
          setState(() {
            _selectedTeacher = teacher;
          });
          _applyFilters();
        },
        showClearButton: true,
        compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
        dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
        filterFn: (Teacher? teacher, String? key) {
          return teacher!.teacherName!.toLowerCase().contains(key!.toLowerCase());
        },
      ),
    );
  }

  Widget _buildTeacherWidget(Teacher e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.all(5),
            child: e.teacherPhotoUrl == null
                ? Image.asset(
                    "assets/images/avatar.png",
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    e.teacherPhotoUrl!,
                    fit: BoxFit.contain,
                  ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                e.teacherName ?? "Select a Teacher",
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          )
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
          GestureDetector(
            onTap: () {
              HapticFeedback.vibrate();
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
            children: _sectionsList.where((e) => e.schoolId == selectedSchool?.schoolId).map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        if (_isLoading) return;
        setState(() {
          _isSectionPickerOpen = !_isSectionPickerOpen;
        });
      },
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
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
          HapticFeedback.vibrate();
          if (_isLoading) return;
          setState(() {
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
            }
            _isSectionPickerOpen = false;
          });
          _applyFilters();
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
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: _isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  color: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Container _getSuggestionWidget(Suggestion suggestion) {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      suggestion.anonymous! ? "Anonymous" : "Section: ${suggestion.sectionName}",
                      style: TextStyle(
                        color: (suggestion.anonymous!) ? null : Colors.blue,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        suggestion.isEditMode
                            ? DropdownButton<String>(
                                value: suggestion.complainStatus,
                                onChanged: (String? newStatus) {
                                  setState(() {
                                    suggestion.complainStatus = newStatus!;
                                  });
                                },
                                items: ["INITIATED", "RESOLVED"]
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(
                                          e,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(color: e == "INITIATED" ? Colors.red : Colors.green),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              )
                            : Text(
                                "${suggestion.complainStatus}",
                                textAlign: TextAlign.end,
                                style: TextStyle(color: suggestion.complainStatus == "INITIATED" ? Colors.red : Colors.green),
                              ),
                        // const SizedBox(
                        //   width: 15,
                        // ),
                        // buildEditButton(suggestion),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(suggestion.anonymous ?? false ? "" : "Student Name: ${suggestion.postingStudentName}"),
                  ),
                  Expanded(
                    child: Text(
                      "Raised Against: " + (suggestion.teacherId == null ? "${suggestion.schoolName}" : "${suggestion.teacherName}"),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                child: ClayContainer(
                  depth: 20,
                  color: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  emboss: true,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.title!.capitalize(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(suggestion.description!.capitalize()),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      suggestion.schoolName! + (suggestion.branchCode != null ? " - ${suggestion.branchCode}" : ""),
                    ),
                  ),
                  Text(
                    "Created Time: ${suggestion.createTime != null ? convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(suggestion.createTime!)) : "-"}",
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges(Suggestion suggestion) async {
    setState(() {
      _isLoading = true;
    });

    UpdateSuggestionResponse updateSuggestionResponse = await updateSuggestion(UpdateSuggestionRequest(
      schoolId: widget.megaAdminProfile.schoolId,
      agent: widget.megaAdminProfile.userId,
      complaintId: suggestion.complaintId,
      complaintStatus: suggestion.complainStatus,
    ));

    if (updateSuggestionResponse.httpStatus != "OK" || updateSuggestionResponse.responseStatus != "success") {
      setState(() {
        suggestion.complainStatus = suggestion.origJson()["complainStatus"];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      _loadSchoolWiseData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Container buildEditButton(Suggestion suggestion) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: GestureDetector(
        onTap: () {
          if (suggestion.isEditMode) {
            if (suggestion.complainStatus != suggestion.origJson()["complainStatus"]) {
              _saveChanges(suggestion);
            }
          }
          setState(() {
            suggestion.isEditMode = !suggestion.isEditMode;
          });
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 35,
          width: 35,
          borderRadius: 35,
          surfaceColor: clayContainerColor(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: FittedBox(
              child: Icon(suggestion.isEditMode ? Icons.check : Icons.edit),
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectStatus() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? const EdgeInsets.fromLTRB(15, 10, 15, 15)
          : const EdgeInsets.fromLTRB(0, 10, 15, 15),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: _selectedComplainStatus == null
            ? dropdownButtonForComplaintStatus()
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: dropdownButtonForComplaintStatus()),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedComplainStatus = null;
                      });
                      _applyFilters();
                    },
                    child: const Icon(Icons.close),
                  )
                ],
              ),
      ),
    );
  }

  DropdownButton<String> dropdownButtonForComplaintStatus() {
    return DropdownButton<String>(
      underline: Container(),
      isExpanded: true,
      hint: const Center(child: Text("Status")),
      value: _selectedComplainStatus,
      onChanged: (String? newStatus) {
        setState(() {
          _selectedComplainStatus = newStatus!;
        });
        _applyFilters();
      },
      items: ["INITIATED", "RESOLVED"]
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      e,
                      textAlign: TextAlign.end,
                      style: TextStyle(color: e == "INITIATED" ? Colors.red : Colors.green),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget showOnlyAnonymousSwitch() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? const EdgeInsets.fromLTRB(15, 10, 15, 15)
          : const EdgeInsets.fromLTRB(5, 3, 0, 3),
      height: 50,
      width: 100,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showOnlyAnonymous = !_showOnlyAnonymous;
          });
          _applyFilters();
        },
        child: ClayContainer(
          emboss: _showOnlyAnonymous,
          depth: 40,
          surfaceColor: _showOnlyAnonymous ? Colors.blue[300] : clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          height: 30,
          width: 30,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Show\nanonymous",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suggestion Box"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.megaAdminProfile,
          ),
        ],
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled() ? null : MegaAdminAppDrawer(megaAdminProfile: widget.megaAdminProfile),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: ClayContainer(
                        depth: 40,
                        color: clayContainerColor(context),
                        spread: 2,
                        borderRadius: 10,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(1, 1, 1, 5),
                          child: searchableDropdownButtonForSchool(),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: MediaQuery.of(context).orientation == Orientation.landscape
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (selectedSchool != null) Expanded(child: _sectionPicker()),
                                if (!_isSectionPickerOpen) Expanded(child: _selectTeacher()),
                                if (!_isSectionPickerOpen) Expanded(child: _selectStatus()),
                                if (!_isSectionPickerOpen) showOnlyAnonymousSwitch(),
                              ],
                            )
                          : Column(
                              children: [
                                if (selectedSchool != null) _sectionPicker(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _selectTeacher(),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: _selectStatus()),
                                    showOnlyAnonymousSwitch(),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    if (_filteredSuggestions.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 100,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text("No suggestions.."),
                        ),
                      ),
                  ] +
                  _filteredSuggestions.map((e) => _getSuggestionWidget(e)).toList(),
            ),
    );
  }
}
