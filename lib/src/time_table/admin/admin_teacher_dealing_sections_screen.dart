import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/app_expansion_tile.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/subjects.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminTeacherDealingSectionsScreen extends StatefulWidget {
  final AdminProfile adminProfile;

  const AdminTeacherDealingSectionsScreen({Key? key, required this.adminProfile}) : super(key: key);

  @override
  _AdminTeacherDealingSectionsScreenState createState() => _AdminTeacherDealingSectionsScreenState();
}

class _AdminTeacherDealingSectionsScreenState extends State<AdminTeacherDealingSectionsScreen> {
  late bool _isLoading;
  late bool _isEditMode;

  List<Section> _sectionsList = [];
  Section? _selectedSection;

  List<Subject> _subjectsList = [];
  List<Teacher> _teachersList = [];

  late bool _isSectionFilterSelected;
  List<TeacherDealingSection> _tdsList = [];
  late TeacherDealingSection _newTds;

  @override
  void initState() {
    super.initState();
    _isEditMode = false;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isSectionFilterSelected = false;
      _sectionsList = [];
      _tdsList = [];
      _newTds = TeacherDealingSection(
        sectionId: _selectedSection != null ? _selectedSection!.sectionId : null,
        sectionName: _selectedSection != null ? _selectedSection!.sectionName : null,
      );
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
    setState(() {
      _isLoading = true;
    });

    List<TeacherDealingSection> _editedTds = _tdsList.where((e) => e.isEdited).toList();
    debugPrint("120: $_editedTds");

    if (_editedTds.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    CreateOrUpdateTeacherDealingSectionsRequest createOrUpdateTeacherDealingSectionsRequest = CreateOrUpdateTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
      agentId: widget.adminProfile.userId,
      tdsList: _editedTds,
    );

    CreateOrUpdateTeacherDealingSectionsResponse createOrUpdateTeacherDealingSectionsResponse =
        await createOrUpdateTeacherDealingSections(createOrUpdateTeacherDealingSectionsRequest);

    if (createOrUpdateTeacherDealingSectionsResponse.httpStatus != 'OK' || createOrUpdateTeacherDealingSectionsResponse.responseStatus != "success") {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong..\nPlease try later.."),
        ),
      );
      return;
    }

    setState(() {
      _isEditMode = false;
    });

    _loadData();
  }

  Widget _editModeButton() {
    return InkWell(
      onTap: () {
        HapticFeedback.vibrate();
        if (_isEditMode) {
          _saveChanges();
          // debugPrint("Saving changes");
          setState(() {
            _isEditMode = false;
          });
        } else {
          setState(() {
            _isEditMode = true;
          });
        }
      },
      child: ClayButton(
        depth: 40,
        surfaceColor: Theme.of(context).primaryColor,
        parentColor: Theme.of(context).primaryColor,
        spread: 1,
        height: 50,
        width: 50,
        borderRadius: 50,
        child: Icon(
          _isEditMode ? Icons.check : Icons.edit,
          color: _isEditMode ? Colors.green[200] : Colors.black38,
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
          setState(() {
            if (_selectedSection == section) {
              _selectedSection = null;
              _newTds.sectionId = null;
              _newTds.sectionName = null;
            } else {
              _selectedSection = section;
              _newTds.sectionId = section.sectionId;
              _newTds.sectionName = section.sectionName;
            }
            _isSectionFilterSelected = !_isSectionFilterSelected;
          });
        },
        child: ClayButton(
          depth: 40,
          color: _selectedSection == section ? Theme.of(context).primaryColor.withOpacity(0.4) : clayContainerColor(context),
          spread: _selectedSection == section ? 0 : 2,
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

  Widget _buildSectionsFilter() {
    final GlobalKey<AppExpansionTileState> expansionTile = GlobalKey();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: AppExpansionTile(
            allowExpansion: !_isEditMode,
            key: expansionTile,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedSection == null ? "Select a section" : "Section: ${_selectedSection!.sectionName}",
                ),
                _editModeButton(),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.025),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                margin: const EdgeInsets.all(7),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.25,
                  crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
                  shrinkWrap: true,
                  children: _sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
                ),
              ),
            ],
            onExpansionChanged: (val) {
              HapticFeedback.vibrate();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTDSWidgetViewMode(TeacherDealingSection tds) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
          padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  tds.subjectName!.capitalize(),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  tds.teacherName!.capitalize(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTDSWidgetEditMode(TeacherDealingSection tds) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  tds.subjectName!.capitalize(),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(
                    tds.teacherName!.capitalize(),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.vibrate();
                    // debugPrint("clicked");
                    setState(() {
                      tds.status = 'inactive';
                      tds.isEdited = true;
                      tds.agentId = widget.adminProfile.userId;
                    });
                  },
                  child: ClayContainer(
                    color: clayContainerColor(context),
                    height: 50,
                    width: 50,
                    borderRadius: 50,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewTdsWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ClayContainer(
        depth: 20,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.fromLTRB(2, 20, 0, 20),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: DropdownButton<Subject>(
                    isExpanded: true,
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
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: DropdownButton<Teacher>(
                    isExpanded: true,
                    items: _teachersList
                        .map(
                          (e1) => DropdownMenuItem<Teacher>(
                            value: e1,
                            child: Text(
                              e1.teacherName!,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (Teacher? e1) {
                      setState(() {
                        _newTds.teacherId = e1!.teacherId;
                        _newTds.teacherName = e1.teacherName;
                      });
                    },
                    value: _newTds.teacherId == null
                        ? null
                        : Teacher(
                            teacherId: _newTds.teacherId,
                            teacherName: _newTds.teacherName,
                          ),
                    underline: Container(),
                    hint: const Text("Select teacher"),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.vibrate();
                    // debugPrint("clicked");
                    if (_newTds.subjectId == null) {
                      HapticFeedback.vibrate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Select a subject to proceed.."),
                        ),
                      );
                      return;
                    }
                    if (_newTds.teacherId == null) {
                      HapticFeedback.vibrate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Select a teacher to proceed.."),
                        ),
                      );
                      return;
                    }
                    // debugPrint("508: $_newTds");
                    setState(() {
                      _newTds.status = 'active';
                      _newTds.isEdited = true;
                      _newTds.agentId = widget.adminProfile.userId;
                      _tdsList.add(_newTds);
                      _newTds = TeacherDealingSection(
                        sectionId: _selectedSection!.sectionId,
                      );
                    });
                  },
                  child: ClayContainer(
                    color: clayContainerColor(context),
                    height: 50,
                    width: 50,
                    borderRadius: 50,
                    child: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTDSWidgets() {
    if (_tdsList
        .where((e) => e.sectionId == _selectedSection!.sectionId && e.status == 'active')
        .map((e) => _isEditMode ? _buildTDSWidgetEditMode(e) : _buildTDSWidgetViewMode(e))
        .toList()
        .isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text("No records to show!!"),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        color: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: _tdsList
                    .where((e) => e.sectionId == _selectedSection!.sectionId && e.status == 'active')
                    .map((e) => _isEditMode ? _buildTDSWidgetEditMode(e) : _buildTDSWidgetViewMode(e))
                    .toList() +
                [_isEditMode ? _buildNewTdsWidget() : Container()],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(
    //     "${_tdsList.where((e) => _selectedSection != null && e.sectionId == _selectedSection!.sectionId).length}");
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Teacher Dealing Sections",
        ),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                // await _loadData();
                return;
              },
              child: ListView(
                children: [
                  _buildSectionsFilter(),
                  // Text("$_selectedSection"),
                  Container(
                    padding: EdgeInsets.fromLTRB(screenWidth / 4, 0, screenWidth / 4, 0),
                    child: _selectedSection != null ? _buildTDSWidgets() : Container(),
                  ),
                ],
              ),
            ),
    );
  }
}
