import 'package:clay_containers/widgets/clay_container.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/list_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminTeacherDealingSectionsV2 extends StatefulWidget {
  const AdminTeacherDealingSectionsV2({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminTeacherDealingSectionsV2> createState() => _AdminTeacherDealingSectionsV2State();
}

class _AdminTeacherDealingSectionsV2State extends State<AdminTeacherDealingSectionsV2> {
  late bool _isLoading;
  late bool _isEditMode;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionPickerOpen = false;

  List<Subject> _subjectsList = [];
  List<Teacher> _teachersList = [];

  List<TeacherDealingSection> _tdsList = [];
  late TeacherDealingSection _newTds;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isEditMode = false;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _sectionsList = [];
      _tdsList = [];
      setNewTds();
    });
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(schoolId: widget.adminProfile.schoolId);
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachersList = getTeachersResponse.teachers!;
      });
    }

    GetSubjectsRequest getSubjectsRequest = GetSubjectsRequest(schoolId: widget.adminProfile.schoolId);
    GetSubjectsResponse getSubjectsResponse = await getSubjects(getSubjectsRequest);

    if (getSubjectsResponse.httpStatus == "OK" && getSubjectsResponse.responseStatus == "success") {
      setState(() {
        _subjectsList = getSubjectsResponse.subjects!.map((e) => e!).toList();
      });
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(
      GetTeacherDealingSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
        status: "active",
      ),
    );
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    List<TeacherDealingSection> editedList = _tdsList.where((e) => e.isEdited).toList();
    if (editedList.isEmpty) {
      setState(() => _isEditMode = false);
      return;
    }

    setState(() => _isLoading = true);

    CreateOrUpdateTeacherDealingSectionsRequest createOrUpdateTeacherDealingSectionsRequest = CreateOrUpdateTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
      agentId: widget.adminProfile.userId,
      tdsList: editedList,
    );

    CreateOrUpdateTeacherDealingSectionsResponse createOrUpdateTeacherDealingSectionsResponse =
        await createOrUpdateTeacherDealingSections(createOrUpdateTeacherDealingSectionsRequest);

    if (createOrUpdateTeacherDealingSectionsResponse.httpStatus != 'OK' || createOrUpdateTeacherDealingSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong..\nPlease try later.."),
        ),
      );
      return;
    }

    setState(() => _isEditMode = false);

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dealing Sections"),
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
              children: [
                const SizedBox(height: 10),
                _sectionPicker(),
                const SizedBox(height: 10),
                _selectedSection == null ? const Center(child: Text("Select a section to continue")) : tdsTableWidget(),
                const SizedBox(height: 200),
              ],
            ),
    );
  }

  Widget clayButton(Widget child) => ClayButton(
        color: clayContainerColor(context),
        height: 75,
        width: 75,
        borderRadius: 100,
        spread: 2,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: child,
          ),
        ),
      );

  Widget tdsTableWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 8.0,
        controller: scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          child: DataTable(
            columns: [
              DataColumn(
                label: IconButton(
                  onPressed: () {
                    if (_isEditMode) {
                      _saveChanges();
                    } else {
                      setState(() => _isEditMode = true);
                    }
                  },
                  icon: clayButton(_isEditMode ? const Icon(Icons.check) : const Icon(Icons.edit)),
                ),
              ),
              const DataColumn(label: Text('Teacher')),
              const DataColumn(label: Text('Subject')),
              if (_isEditMode && _selectedSection != null) const DataColumn(label: Text('Actions')),
            ],
            rows: [
              ..._tdsList.where((e) => (e.sectionId == _selectedSection?.sectionId) && (e.status == "active")).map(
                    (e) => DataRow(
                      cells: [
                        DataCell(
                          Text(e.sectionName ?? "-"),
                        ),
                        DataCell(
                          Text(e.teacherName ?? "-"),
                        ),
                        DataCell(
                          Text(e.subjectName ?? "-"),
                        ),
                        if (_isEditMode && _selectedSection != null)
                          DataCell(
                            IconButton(
                                onPressed: () {
                                  setState(() => e
                                    ..status = "inactive"
                                    ..agentId = widget.adminProfile.userId
                                    ..isEdited = true);
                                },
                                icon: clayButton(
                                  const Icon(Icons.delete, color: Colors.red),
                                )),
                          ),
                      ],
                    ),
                  ),
              if (_isEditMode && _selectedSection != null)
                DataRow(
                  cells: [
                    DataCell(
                      Text(_selectedSection?.sectionName ?? "-"),
                    ),
                    DataCell(
                      teacherDropDown(),
                    ),
                    DataCell(
                      subjectDropDown(),
                    ),
                    if (_isEditMode)
                      DataCell(
                        IconButton(
                          onPressed: () {
                            if (_newTds.teacherId == null || _newTds.subjectId == null || _newTds.sectionId == null) return;
                            List<TeacherDealingSection> sameTdsList = _tdsList
                                .where(
                                    (e) => e.sectionId == _newTds.sectionId && e.teacherId == _newTds.teacherId && e.subjectId == _newTds.subjectId)
                                .toList();
                            if (sameTdsList.where((e) => e.status == 'active').isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Same combination already exists.."),
                                ),
                              );
                              return;
                            }
                            if (sameTdsList.where((e) => e.status == 'inactive').isNotEmpty) {
                              setState(() {
                                sameTdsList.where((e) => e.status == 'inactive').first.status = "active";
                              });
                              return;
                            }
                            setState(() {
                              _tdsList.add(_newTds);
                              setNewTds();
                            });
                          },
                          icon: clayButton(const Icon(Icons.add, color: Colors.green)),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownButton<Subject> subjectDropDown() {
    return DropdownButton<Subject>(
      items: _subjectsList
          .map(
            (e1) => DropdownMenuItem<Subject>(
              value: e1,
              child: Text(
                e1.subjectName!.capitalize(),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (Subject? e1) {
        // debugPrint("${e1!} clicked");
        setState(() {
          _newTds.subjectId = e1!.subjectId;
          _newTds.subjectName = e1.subjectName;
        });
      },
      value: _newTds.subjectId == null
          ? null
          : Subject(
              subjectId: _newTds.subjectId,
              subjectName: _newTds.subjectName,
            ),
      underline: Container(),
      hint: const Text("Select Subject"),
    );
  }

  void setNewTds() {
    _newTds = TeacherDealingSection(
      sectionId: _selectedSection != null ? _selectedSection!.sectionId : null,
      sectionName: _selectedSection != null ? _selectedSection!.sectionName : null,
      agentId: widget.adminProfile.userId,
      status: "active",
    )..isEdited = true;
  }

  Widget teacherDropDown() {
    return SizedBox(
      width: 300,
      child: DropdownSearch<Teacher>(
        mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
        items: _teachersList,
        selectedItem: _teachersList.where((e) => _newTds.teacherId == e.teacherId).toList().firstOrNull(),
        itemAsString: (Teacher? teacher) {
          return teacher == null ? "" : teacher.teacherName ?? "";
        },
        showSearchBox: true,
        dropdownBuilder: (BuildContext context, Teacher? teacher) {
          return teacher == null ? const Text("-") : _buildTeacherWidget(teacher);
        },
        showClearButton: true,
        compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
        dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
        filterFn: (Teacher? teacher, String? key) {
          return teacher!.teacherName!.toLowerCase().contains(key!.toLowerCase());
        },
        onChanged: (Teacher? teacher) {
          setState(() {
            _newTds.teacherId = teacher?.teacherId;
            _newTds.teacherName = teacher?.teacherName;
          });
        },
      ),
    );
  }

  Widget _buildTeacherWidget(Teacher e) {
    return SizedBox(
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
          alignment: Alignment.centerLeft,
          child: Text(
            e.teacherName ?? "Select a Teacher",
            style: const TextStyle(
              fontSize: 14,
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
        margin: const EdgeInsets.all(10),
        child: _isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
              )
            : _selectSectionCollapsed(),
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
              setNewTds();
            } else {
              _selectedSection = section;
              setNewTds();
            }
            _isSectionPickerOpen = false;
          });
        },
        child: ClayButton(
          depth: 40,
          spread: _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              _selectedSection != null && _selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
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

  Widget _selectSectionExpanded() {
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
              if (_isLoading) return;
              setState(() {
                _isSectionPickerOpen = !_isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName}",
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
            children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          HapticFeedback.vibrate();
          if (_isLoading || _isEditMode) return;
          setState(() {
            _isSectionPickerOpen = !_isSectionPickerOpen;
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
                    _selectedSection == null ? "Select a section" : "Sections: ${_selectedSection!.sectionName}",
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
