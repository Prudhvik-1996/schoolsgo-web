import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/study_material/model/study_material.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

import 'admin_study_material_screen.dart';

class AdminStudyMaterialTDSScreen extends StatefulWidget {
  const AdminStudyMaterialTDSScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/study_material";

  @override
  _AdminStudyMaterialTdsScreenState createState() => _AdminStudyMaterialTdsScreenState();
}

class _AdminStudyMaterialTdsScreenState extends State<AdminStudyMaterialTDSScreen> {
  bool _isLoading = true;

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;

  List<TeacherDealingSection> _tdsList = [];
  List<TeacherDealingSection> _filteredTdsList = [];

  bool _isSectionPickerOpen = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetAssignmentsAndStudyMaterialTilesResponse getAssignmentsAndStudyMaterialTilesResponse =
        await getAssignmentsAndStudyMaterialTiles(GetAssignmentsAndStudyMaterialTilesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getAssignmentsAndStudyMaterialTilesResponse.httpStatus == "OK" && getAssignmentsAndStudyMaterialTilesResponse.responseStatus == "success") {
      setState(() {
        _tdsList = (getAssignmentsAndStudyMaterialTilesResponse.teacherDealingSections ?? []).where((e) => e != null).map((e) => e!).toList();
        _filteredTdsList = (getAssignmentsAndStudyMaterialTilesResponse.teacherDealingSections ?? []).where((e) => e != null).map((e) => e!).toList();
      });
    }

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
      _filteredTdsList = _tdsList.map((e) => e).toList();
    });

    if (_selectedSection != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList.where((e) => e.sectionId == _selectedSection!.sectionId).toList();
      });
    }

    if (_selectedTeacher != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList.where((e) => e.teacherId == _selectedTeacher!.teacherId).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _selectTeacher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        spread: 1,
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
      spread: 1,
      borderRadius: 10,
      child: _selectedSection != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.vibrate();
                      if (_isLoading) return;
                      setState(() {
                        _isSectionPickerOpen = !_isSectionPickerOpen;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 14, 10, 14),
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
                ),
                InkWell(
                  child: const Icon(Icons.close),
                  onTap: () {
                    setState(() {
                      _selectedSection = null;
                    });
                    _applyFilters();
                  },
                ),
              ],
            )
          : InkWell(
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
        margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: _isSectionPickerOpen
            ? ClayContainer(
              depth: 40,
              color: clayContainerColor(context),
              spread: 1,
              borderRadius: 10,
              child: _selectSectionExpanded(),
            )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget _sectionWiseTdsButtonWidget(TeacherDealingSection tds) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: InkWell(
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        tds.subjectName!.capitalize(),
                        style: TextStyle(
                          color: tds.status == "active" ? Colors.blue : Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(tds.teacherName!.capitalize()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AdminStudyMaterialScreen(
              adminProfile: widget.adminProfile,
              tds: tds,
            );
          }));
        },
      ),
    );
  }

  Widget _buildSectionWiseTdsGrid(int sectionId) {
    int n = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    List<Widget> rows = [];
    rows.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Text(
              _filteredTdsList.where((e) => e.sectionId == sectionId).first.sectionName ?? "-",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    ));
    int i = 0;
    while (i < _filteredTdsList.where((e) => e.sectionId == sectionId).toList().length) {
      List<Widget> x = [];
      for (int j = 0; j < n; j++) {
        if (i >= _filteredTdsList.where((e) => e.sectionId == sectionId).toList().length) {
          x.add(Expanded(
            child: Container(),
          ));
        } else {
          x.add(Expanded(child: _sectionWiseTdsButtonWidget(_filteredTdsList.where((e) => e.sectionId == sectionId).toList()[i])));
        }
        i = i + 1;
      }
      rows.add(Row(
        // mainAxisSize: MainAxisSize.min,
        children: x,
      ));
    }
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: rows,
    );
  }

  Widget _sectionWiseTdsWidget(int sectionId) {
    return Container(
      margin: const EdgeInsets.all(25),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: _buildSectionWiseTdsGrid(sectionId),
        ),
      ),
    );
  }

  Widget _selectedTdsWidget(TeacherDealingSection tds) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: InkWell(
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // physics: const NeverScrollableScrollPhysics(),
                    // shrinkWrap: true,
                    children: [
                      // Text("Section: ${tds.sectionName}"),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tds.subjectName!.capitalize(),
                            style: TextStyle(
                              color: tds.status == "active" ? Colors.blue : Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(tds.teacherName!.capitalize()),
                        ),
                      ),
                    ],
                  ),
                ),
                // child: Text("Section: ${tds.sectionName}" +
                //     "\n" +
                //     "Teacher: ${tds.teacherName!.capitalize()}"),
                // child: Text("hi"),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                  child: ClayContainer(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    customBorderRadius: const BorderRadius.only(
                      topRight: Radius.elliptical(10, 10),
                      bottomLeft: Radius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text(tds.sectionName ?? "-"),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AdminStudyMaterialScreen(
              adminProfile: widget.adminProfile,
              tds: tds,
            );
          }));
        },
      ),
    );
  }

  List<Widget> _buildAllTdsGrid() {
    int n = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    List<Widget> rows = [];
    // for (int i = 0; i < _tdsList.length; i++) {
    int i = 0;
    while (i < _filteredTdsList.length) {
      List<Widget> x = [];
      for (int j = 0; j < n; j++) {
        if (i >= _filteredTdsList.length) {
          x.add(Expanded(
            child: Container(),
          ));
        } else {
          x.add(Expanded(child: _selectedTdsWidget(_filteredTdsList[i])));
        }
        i = i + 1;
      }
      rows.add(Row(
        // mainAxisSize: MainAxisSize.min,
        children: x,
      ));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Material"),
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
              children: <Widget>[
                    const SizedBox(height: 20),
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!_isSectionPickerOpen) const SizedBox(width: 10),
                              Expanded(child: _sectionPicker()),
                              if (!_isSectionPickerOpen) const SizedBox(width: 10),
                              if (!_isSectionPickerOpen) Expanded(child: _selectTeacher()),
                              if (!_isSectionPickerOpen) const SizedBox(width: 10),
                            ],
                          )
                        : Column(
                            children: [
                              _sectionPicker(),
                              _selectTeacher(),
                            ],
                          ),
                  ] +
                  ((_selectedTeacher != null)
                      ? _buildAllTdsGrid()
                      : _filteredTdsList.map((tds) => tds.sectionId).map((e) => e!).toSet().map((e) => _sectionWiseTdsWidget(e)).toList()),
            ),
    );
  }
}
