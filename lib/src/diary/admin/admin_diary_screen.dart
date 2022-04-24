import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/diary/model/diary.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class DiaryEditScreen extends StatefulWidget {
  const DiaryEditScreen({Key? key, this.adminProfile, this.teacherProfile}) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;

  static const routeName = "/diary";

  @override
  _DiaryEditScreenState createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionPickerOpen = false;

  List<TeacherDealingSection> _tdsList = [];
  List<TeacherDealingSection> _filteredTdsList = [];

  DateTime _selectedDate = DateTime.now();

  List<DiaryEntry> _diaryList = [];
  List<DiaryEntry> _filteredDiaryList = [];

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
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
      teacherId: widget.teacherProfile == null ? null : widget.teacherProfile!.teacherId,
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
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
      teacherId: widget.teacherProfile == null ? null : widget.teacherProfile!.teacherId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
        _filteredTdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }

    await _loadDiary();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDiary() async {
    setState(() {
      _isLoading = true;
    });

    GetStudentDiaryResponse getDiaryResponse = await getDiary(
      GetDiaryRequest(
        schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
        teacherId: widget.teacherProfile == null ? null : widget.teacherProfile!.teacherId,
        date: convertDateTimeToYYYYMMDDFormat(_selectedDate),
      ),
    );
    if (getDiaryResponse.httpStatus == "OK" && getDiaryResponse.responseStatus == "success") {
      setState(() {
        _diaryList = (getDiaryResponse.diaryEntries ?? []).where((e) => e != null).map((e) => e!).toList();
        _diaryList.sort((b, a) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0));
        _filteredDiaryList = (getDiaryResponse.diaryEntries ?? []).where((e) => e != null).map((e) => e!).toList();
        _filteredDiaryList.sort((b, a) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0));
      });
    }

    await _applyFilters();

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
      _filteredDiaryList = _diaryList;
    });
    if (_selectedTeacher != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList.where((e) => e.teacherId == _selectedTeacher!.teacherId).toList();
        _filteredDiaryList = _filteredDiaryList.where((e) => e.teacherId == _selectedTeacher!.teacherId).toList();
      });
    }
    if (_selectedSection != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList.where((e) => e.sectionId == _selectedSection!.sectionId).toList();
        _filteredDiaryList = _filteredDiaryList.where((e) => e.sectionId == _selectedSection!.sectionId).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _teacherPicker() {
    return _filteredDiaryList.where((e) => e.isEditMode).isNotEmpty
        ? GestureDetector(
            onTap: () {
              DiaryEntry? editingEntry = _filteredDiaryList.where((e) => e.isEditMode).firstOrNull;
              if (editingEntry != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Save changes for the following diary entry to proceed..\n"
                        "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
                  ),
                );
                return;
              }
            },
            child: ClayButton(
              depth: 40,
              parentColor: clayContainerColor(context),
              surfaceColor: clayContainerColor(context),
              spread: 2,
              borderRadius: 10,
              height: 60,
              width: 60,
              child: Center(
                child: _buildTeacherWidget(_selectedTeacher ?? Teacher()),
              ),
            ),
          )
        : _buildSearchableTeacherDropdown();
  }

  ClayButton _buildSearchableTeacherDropdown() {
    return ClayButton(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      height: 60,
      width: 60,
      child: DropdownSearch<Teacher>(
        enabled: _filteredDiaryList.where((e) => e.isEditMode).isEmpty,
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
          DiaryEntry? editingEntry = _filteredDiaryList.where((e) => e.isEditMode).firstOrNull;
          if (editingEntry != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for the following diary entry to proceed..\n"
                    "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
              ),
            );
            return;
          } else {
            setState(() {
              _selectedTeacher = teacher;
            });
            _applyFilters();
          }
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

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(20),
        child: _isSectionPickerOpen
            ? ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 2,
                borderRadius: 10,
                child: _selectSectionExpanded(),
              )
            : _selectSectionCollapsed(),
      ),
    );
  }

  Widget _buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          if (_isLoading) return;
          DiaryEntry? editingEntry = _filteredDiaryList.where((e) => e.isEditMode).firstOrNull;
          if (editingEntry != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for the following diary entry to proceed..\n"
                    "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
              ),
            );
            return;
          } else {
            setState(() {
              if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
                _selectedSection = null;
              } else {
                _selectedSection = section;
              }
              _isSectionPickerOpen = false;
            });
            _applyFilters();
          }
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
          GestureDetector(
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
            children: _sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
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
        DiaryEntry? editingEntry = _filteredDiaryList.where((e) => e.isEditMode).firstOrNull;
        if (editingEntry != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Save changes for the following diary entry to proceed..\n"
                  "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
            ),
          );
          return;
        } else {
          setState(() {
            _isSectionPickerOpen = !_isSectionPickerOpen;
          });
        }
      },
      child: ClayButton(
        depth: 40,
        parentColor: clayContainerColor(context),
        surfaceColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        height: 60,
        width: 60,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
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

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: GestureDetector(
        onTap: () async {
          DiaryEntry? editingEntry = _filteredDiaryList.where((e) => e.isEditMode).firstOrNull;
          if (editingEntry != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for the following diary entry to proceed..\n"
                    "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
              ),
            );
            return;
          }
          HapticFeedback.vibrate();
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now(),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            _selectedDate = _newDate;
          });
          _loadDiary();
        },
        child: ClayButton(
          depth: 40,
          parentColor: clayContainerColor(context),
          surfaceColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          height: 60,
          width: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    convertDateTimeToDDMMYYYYFormat(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.calendar_today_rounded,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getLeftArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Previous Day",
        child: GestureDetector(
          onTap: () {
            if (_selectedDate.millisecondsSinceEpoch == DateTime.now().subtract(const Duration(days: 364)).millisecondsSinceEpoch) return;
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            });
            _loadDiary();
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_left),
          ),
        ),
      ),
    );
  }

  Widget _getRightArrow() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Tooltip(
        message: "Next Day",
        child: GestureDetector(
          onTap: () {
            if (_selectedDate.millisecondsSinceEpoch == DateTime.now().millisecondsSinceEpoch) return;
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            });
            _loadDiary();
          },
          child: ClayButton(
            color: clayContainerColor(context),
            height: 30,
            width: 30,
            borderRadius: 50,
            surfaceColor: clayContainerColor(context),
            child: const Icon(Icons.arrow_right),
          ),
        ),
      ),
    );
  }

  Container _getDiaryWidget(DiaryEntry diary) {
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildSectionNameWidget(diary),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildSubjectNameWidget(diary),
                  ),
                  Expanded(
                    child: buildTeacherNameWidget(diary),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: buildAssignmentWidget(diary)),
                  (widget.adminProfile != null && widget.adminProfile!.isMegaAdmin) ? Container() : buildEditButton(diary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAssignmentWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: diary.isEditMode
              ? TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Assignment",
                  ),
                  maxLines: null,
                  initialValue: diary.assignment ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.start,
                  onChanged: (text) => setState(() {
                    diary.assignment = text;
                  }),
                )
              : Text(
                  diary.assignment ?? "-",
                  textAlign: diary.assignment == null ? TextAlign.center : TextAlign.start,
                ),
        ),
      ),
    );
  }

  Container buildSubjectNameWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Subject: ${diary.subjectName!.capitalize()}"),
    );
  }

  Container buildTeacherNameWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Teacher: ${diary.teacherFirstName!.capitalize()}"),
    );
  }

  Container buildSectionNameWidget(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text(
        "Section: ${diary.sectionName}",
      ),
    );
  }

  Future<void> _saveChanges(DiaryEntry diary) async {
    setState(() {
      _isLoading = true;
    });

    CreateOrUpdateDiaryResponse createOrUpdateDiaryResponse = await createOrUpdateDiary(CreateOrUpdateDiaryRequest(
      sectionId: diary.sectionId,
      date: _selectedDate.millisecondsSinceEpoch,
      teacherId: diary.teacherId,
      subjectId: diary.subjectId,
      agentId: widget.adminProfile == null ? widget.teacherProfile!.teacherId : widget.adminProfile!.userId,
      status: "active",
      schoolId: widget.adminProfile == null ? widget.teacherProfile!.schoolId : widget.adminProfile!.schoolId,
      diaryId: diary.diaryId,
      assignment: diary.assignment,
    ));

    if (createOrUpdateDiaryResponse.httpStatus != "OK" || createOrUpdateDiaryResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
    }

    await _loadDiary();

    setState(() {
      _isLoading = false;
    });
  }

  Container buildEditButton(DiaryEntry diary) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          if (diary.isEditMode) {
            showDialog(
              context: _scaffoldKey.currentContext!,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text("Are you sure you want to save changes?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (diary.assignment != diary.origJson()["assignment"]) {
                          _saveChanges(diary);
                        }
                      },
                      child: const Text("YES"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          diary.assignment = diary.origJson()["assignment"];
                          diary.isEditMode = false;
                        });
                      },
                      child: const Text("No"),
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
          } else {
            DiaryEntry? editingEntry = _filteredDiaryList.where((e) => e.isEditMode).firstOrNull;
            if (editingEntry != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Save changes for the following diary entry to proceed..\n"
                      "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
                ),
              );
            } else {
              setState(() {
                diary.isEditMode = true;
              });
            }
          }
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 50,
          width: 50,
          borderRadius: 50,
          surfaceColor: clayContainerColor(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Icon(diary.isEditMode ? Icons.check : Icons.edit),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Diary"),
        actions: [
          buildRoleButtonForAppBar(context, widget.teacherProfile == null ? widget.adminProfile! : widget.teacherProfile!),
        ],
      ),
      drawer: widget.teacherProfile == null
          ? AdminAppDrawer(adminProfile: widget.adminProfile!)
          : TeacherAppDrawer(
              teacherProfile: widget.teacherProfile!,
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
              children: <Widget>[
                widget.teacherProfile != null
                    ? Container(
                        padding: MediaQuery.of(context).orientation == Orientation.landscape
                            ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
                            : const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            _getLeftArrow(),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(child: _getDatePicker()),
                            const SizedBox(
                              width: 10,
                            ),
                            _getRightArrow(),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      )
                    : Container(
                        child: MediaQuery.of(context).orientation == Orientation.landscape
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(child: _sectionPicker()),
                                  if (!_isSectionPickerOpen) Expanded(child: _teacherPicker()),
                                  if (!_isSectionPickerOpen)
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  if (!_isSectionPickerOpen) _getLeftArrow(),
                                  if (!_isSectionPickerOpen)
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  if (!_isSectionPickerOpen) Expanded(child: _getDatePicker()),
                                  if (!_isSectionPickerOpen)
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  if (!_isSectionPickerOpen) _getRightArrow(),
                                  if (!_isSectionPickerOpen)
                                    const SizedBox(
                                      width: 10,
                                    ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: _sectionPicker(),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 25,
                                      ),
                                      Expanded(
                                        child: _teacherPicker(),
                                      ),
                                      const SizedBox(
                                        width: 25,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _getLeftArrow(),
                                      Expanded(child: _getDatePicker()),
                                      _getRightArrow(),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                if (_filteredDiaryList.isEmpty)
                  Container(
                    margin: const EdgeInsets.all(50),
                    child: const Center(
                      child: Text("There seems to be no teachers/subjects assigned at this point.."),
                    ),
                  ),
                for (DiaryEntry eachDiary in _filteredDiaryList) _getDiaryWidget(eachDiary),
              ],
            ),
    );
  }
}
