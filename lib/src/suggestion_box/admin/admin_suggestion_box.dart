import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/suggestion_box/model/suggestion_box.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminSuggestionBox extends StatefulWidget {
  const AdminSuggestionBox({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/suggestion_box";

  @override
  _AdminSuggestionBoxState createState() => _AdminSuggestionBoxState();
}

class _AdminSuggestionBoxState extends State<AdminSuggestionBox> {
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile.schoolId,
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
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
        _filteredTdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }

    GetSuggestionBoxResponse getSuggestionBoxResponse = await getSuggestionBox(GetSuggestionBoxRequest(
      schoolId: widget.adminProfile.schoolId,
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

  Widget _selectTeacher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: _teachersList.length != 1 && _selectedTeacher != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: dropdownButtonForTeacher()),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTeacher = null;
                        });
                        _applyFilters();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ),
                ],
              )
            : dropdownButtonForTeacher(),
      ),
    );
  }

  DropdownButton<Teacher> dropdownButtonForTeacher() {
    return DropdownButton(
      hint: const Center(child: Text("Select Teacher")),
      underline: Container(),
      isExpanded: true,
      value: _selectedTeacher,
      onChanged: (Teacher? teacher) {
        setState(() {
          _selectedTeacher = teacher!;
        });
        _applyFilters();
      },
      items: _teachersList
          .where((teacher) => _filteredTdsList.map((tds) => tds.teacherId).contains(teacher.teacherId))
          .map(
            (e) => DropdownMenuItem<Teacher>(
              value: e,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: ListTile(
                  leading: Container(
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
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      e.teacherName ?? "-",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _selectSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: _sectionsList.length != 1 && _selectedSection != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: dropdownButtonForSection()),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSection = null;
                        });
                        _applyFilters();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ),
                ],
              )
            : dropdownButtonForSection(),
      ),
    );
  }

  DropdownButton<Section> dropdownButtonForSection() {
    return DropdownButton(
      hint: const Center(child: Text("Select Section")),
      underline: Container(),
      isExpanded: true,
      value: _selectedSection,
      onChanged: (Section? section) {
        setState(() {
          _selectedSection = section!;
        });
        _applyFilters();
      },
      items: _sectionsList
          .where((section) => _filteredTdsList.map((tds) => tds.sectionId).contains(section.sectionId))
          .map(
            (e) => DropdownMenuItem<Section>(
              value: e,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      e.sectionName ?? "-",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
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
            children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      color: clayContainerColor(context),
      spread: 5,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
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
                margin: const EdgeInsets.all(25),
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
                        const SizedBox(
                          width: 15,
                        ),
                        widget.adminProfile.isMegaAdmin ? Container() : buildEditButton(suggestion),
                      ],
                    ),
                  ),
                ],
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
                      "Raised Against: " + (suggestion.teacherId == null ? "${widget.adminProfile.schoolName}" : "${suggestion.teacherName}"),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                child: ClayContainer(
                  depth: 20,
                  color: clayContainerColor(context),
                  spread: 5,
                  borderRadius: 10,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Created Time: ${suggestion.createTime != null ? convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(suggestion.createTime!)) : "-"}",
                  ),
                ],
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
      schoolId: widget.adminProfile.schoolId,
      agent: widget.adminProfile.userId,
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
      _loadData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Container buildEditButton(Suggestion suggestion) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: InkWell(
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
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 5,
        borderRadius: 10,
        child: _selectedComplainStatus == null
            ? dropdownButtonForComplaintStatus()
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: dropdownButtonForComplaintStatus()),
                  InkWell(
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
      margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
      child: Column(
        children: [
          Switch(
            value: _showOnlyAnonymous,
            onChanged: (bool _newValue) {
              setState(() {
                _showOnlyAnonymous = _newValue;
              });
              _applyFilters();
            },
          ),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("Show anonymous"),
          )
        ],
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
            widget.adminProfile,
          ),
        ],
      ),
      drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                    Container(
                      child: MediaQuery.of(context).orientation == Orientation.landscape
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: _sectionPicker()),
                                if (!_isSectionPickerOpen) Expanded(child: _selectTeacher()),
                                if (!_isSectionPickerOpen) Expanded(child: _selectStatus()),
                                if (!_isSectionPickerOpen) showOnlyAnonymousSwitch(),
                              ],
                            )
                          : Column(
                              children: [
                                _selectSection(),
                                _selectTeacher(),
                                Row(
                                  children: [
                                    Expanded(child: _selectStatus()),
                                    showOnlyAnonymousSwitch(),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ] +
                  _filteredSuggestions.map((e) => _getSuggestionWidget(e)).toList(),
            ),
    );
  }
}
