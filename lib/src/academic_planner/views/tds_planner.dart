import 'package:clay_containers/widgets/clay_container.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/views/master_planner/master_planner_screen.dart';
import 'package:schoolsgo_web/src/academic_planner/views/planner_creation.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class TdsPlanner extends StatefulWidget {
  const TdsPlanner({
    Key? key,
    required this.adminProfile,
    required this.teacherProfile,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;

  @override
  State<TdsPlanner> createState() => _TdsPlannerState();
}

class _TdsPlannerState extends State<TdsPlanner> {
  bool _isLoading = false;

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

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      teacherId: widget.teacherProfile?.teacherId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = (getTeacherDealingSectionsResponse.teacherDealingSections ?? []).toList();
        _filteredTdsList = (getTeacherDealingSectionsResponse.teacherDealingSections ?? []).toList();
      });
    }

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      teacherId: widget.teacherProfile?.teacherId,
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
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
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
      _filteredTdsList = _tdsList.where((e) => e.status == "active").map((e) => e).toList();
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

  Widget _teacherPicker() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape ? null : const EdgeInsets.all(25),
      child: _buildSearchableTeacherDropdown(),
    );
  }

  ClayButton _buildSearchableTeacherDropdown() {
    return ClayButton(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      height: 60,
      child: DropdownSearch<Teacher>(
        clearButton: widget.adminProfile != null ? IconButton(
          onPressed: () {
            setState(() => _selectedTeacher = null);
            _applyFilters();
          },
          icon: const Icon(Icons.clear),
        ) : Container(),
        enabled: widget.adminProfile != null,
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
          setState(() => _selectedTeacher = teacher);
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
      spread: 2,
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
                      _applyFilters();
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
                parentColor: clayContainerColor(context),
                surfaceColor: clayContainerColor(context),
                spread: 2,
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
            return PlannerCreationScreen(
              adminProfile: widget.adminProfile,
              teacherProfile: widget.teacherProfile,
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
            return PlannerCreationScreen(
              adminProfile: widget.adminProfile,
              teacherProfile: widget.teacherProfile,
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

  void handleMoreOptions(String value) {
    switch (value) {
      case "Master Planner":
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MasterPlannerScreen(
            adminProfile: widget.adminProfile!,
          );
        }));
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic Planner"),
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
          if (!_isLoading && widget.adminProfile != null)
            PopupMenuButton<String>(
              onSelected: handleMoreOptions,
              itemBuilder: (BuildContext context) {
                return {'Master Planner'}.map((String choice) {
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
                    const SizedBox(height: 10),
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!_isSectionPickerOpen) const SizedBox(width: 10),
                              Expanded(child: _sectionPicker()),
                              if (!_isSectionPickerOpen) const SizedBox(width: 10),
                              if (!_isSectionPickerOpen) Expanded(child: _teacherPicker()),
                              if (!_isSectionPickerOpen) const SizedBox(width: 30),
                            ],
                          )
                        : Column(
                            children: [
                              _sectionPicker(),
                              _teacherPicker(),
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
