import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/logbook/model/logbook.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({Key? key, this.adminProfile, this.teacherProfile}) : super(key: key);

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;

  static const routeName = "/logbook";

  @override
  _LogbookScreenState createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  bool _isLoading = true;

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;

  DateTime _selectedDate = DateTime.now();

  List<LogBook> _logBookList = [];
  List<LogBook> _filteredLogBookList = [];

  bool _isSectionPickerOpen = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isSectionPickerOpen = false;
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

    await _loadLogBook();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLogBook() async {
    setState(() {
      _isLoading = true;
    });
    GetLogBookResponse getLogBookResponse = await getLogBook(GetLogBookRequest(
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
      date: _selectedDate.millisecondsSinceEpoch + 5 * 60 * 60 * 1000 + 30 * 60 * 1000,
    ));

    if (getLogBookResponse.httpStatus == "OK" && getLogBookResponse.responseStatus == "success") {
      setState(() {
        _logBookList = getLogBookResponse.logs!.map((e) => e!).toList();
      });
      _filterLogBookList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _filterLogBookList() async {
    setState(() {
      _isLoading = true;
      _filteredLogBookList = _logBookList;
    });
    if (_selectedTeacher != null) {
      _filteredLogBookList = _filteredLogBookList.where((e) => e.teacherId == _selectedTeacher!.teacherId).toList();
    }
    if (_selectedSection != null) {
      _filteredLogBookList = _filteredLogBookList.where((e) => e.sectionId == _selectedSection!.sectionId).toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _teacherPicker() {
    return _filteredLogBookList.where((e) => e.isEditMode).isNotEmpty
        ? GestureDetector(
            onTap: () {
              LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
              if (editingEntry != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Save changes for the following logbook entry to proceed..\n"
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
        enabled: _filteredLogBookList.where((e) => e.isEditMode).isEmpty,
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
          LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
          if (editingEntry != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for the following logbook entry to proceed..\n"
                    "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
              ),
            );
            return;
          } else {
            setState(() {
              _selectedTeacher = teacher;
            });
            _filterLogBookList();
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
          LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
          if (editingEntry != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for the following logbook entry to proceed..\n"
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
            _filterLogBookList();
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
        LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
        if (editingEntry != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Save changes for the following logbook entry to proceed..\n"
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
          LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
          if (editingEntry != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for the following logbook entry to proceed..\n"
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
          _loadLogBook();
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
        child: InkWell(
          onTap: () {
            LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
            if (editingEntry != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Save changes for the following logbook entry to proceed..\n"
                      "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
                ),
              );
              return;
            }
            if (_selectedDate.millisecondsSinceEpoch == DateTime.now().subtract(const Duration(days: 364)).millisecondsSinceEpoch) return;
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            });
            _loadLogBook();
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
        child: InkWell(
          onTap: () {
            LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
            if (editingEntry != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Save changes for the following logbook entry to proceed..\n"
                      "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
                ),
              );
              return;
            }
            if (_selectedDate.add(const Duration(days: 1)).millisecondsSinceEpoch >= DateTime.now().millisecondsSinceEpoch) return;
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            });
            _loadLogBook();
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

  Future<void> _saveChanges(LogBook logBook) async {
    setState(() {
      _isLoading = true;
    });

    CreateOrUpdateLogBookResponse createOrUpdateLogBookResponse = await createOrUpdateLogBook(CreateOrUpdateLogBookRequest(
      date: convertDateTimeToYYYYMMDDFormat(_selectedDate),
      schoolId: widget.adminProfile == null ? widget.teacherProfile!.schoolId : widget.adminProfile!.schoolId,
      teacherId: logBook.teacherId,
      status: "active",
      agentId: widget.adminProfile == null ? widget.teacherProfile!.teacherId : widget.adminProfile!.userId,
      sectionId: logBook.sectionId,
      subjectId: logBook.subjectId,
      tdsId: logBook.tdsId,
      logbookId: logBook.id,
      notes: logBook.notes,
      sectionTimeSlotId: logBook.sectionTimeSlotId,
    ));

    if (createOrUpdateLogBookResponse.httpStatus != "OK" || createOrUpdateLogBookResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Please try again later.."),
        ),
      );
    }

    await _loadLogBook();

    setState(() {
      _isLoading = false;
    });
  }

  Container _getLogBookWidget(LogBook logBook) {
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
                    child: buildSectionNameWidget(logBook),
                  ),
                  Expanded(
                    child: buildTimeSlotWidget(logBook),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildSubjectNameWidget(logBook),
                  ),
                  Expanded(
                    child: buildTeacherNameWidget(logBook),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: buildNotesWidget(logBook)),
                  (widget.adminProfile != null) ? Container() : buildEditButton(logBook),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Last Updated Time: ${logBook.lastUpdatedTime == null ? "-" : convertDateToDDMMYYYYHHMMSS(logBook.lastUpdatedTime!)}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotesWidget(LogBook logBook) {
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
          child: logBook.isEditMode
              ? TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Notes",
                  ),
                  maxLines: null,
                  initialValue: logBook.notes ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.justify,
                  onChanged: (text) => setState(() {
                    logBook.notes = text;
                  }),
                )
              : Text(
                  logBook.notes ?? "-",
                  textAlign: logBook.notes == null ? TextAlign.center : TextAlign.justify,
                ),
        ),
      ),
    );
  }

  Container buildSubjectNameWidget(LogBook logBook) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Subject: ${logBook.subjectName}"),
    );
  }

  Container buildTeacherNameWidget(LogBook logBook) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Teacher: ${logBook.teacherName}"),
    );
  }

  Container buildTimeSlotWidget(LogBook logBook) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text(
        "${convert24To12HourFormat(logBook.startTime!)} - ${convert24To12HourFormat(logBook.endTime!)}",
      ),
    );
  }

  Container buildSectionNameWidget(LogBook logBook) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text(
        "Section: ${logBook.sectionName}",
      ),
    );
  }

  Container buildEditButton(LogBook logBook) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          LogBook? editingEntry = _filteredLogBookList.where((e) => e.isEditMode).firstOrNull;
          if (editingEntry != null && !logBook.isEditMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Save changes for the following logbook entry to proceed..\n"
                    "${editingEntry.sectionName ?? "-"} - ${editingEntry.subjectName ?? "-"}"),
              ),
            );
            return;
          }
          if (logBook.isEditMode) {
            if (logBook.notes != logBook.origJson()["notes"]) {
              _saveChanges(logBook);
            }
          }
          setState(() {
            logBook.isEditMode = !logBook.isEditMode;
          });
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 50,
          width: 50,
          borderRadius: 50,
          surfaceColor: clayContainerColor(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Icon(logBook.isEditMode ? Icons.check : Icons.edit),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Book"),
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
              children: [
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
                                  width: 1,
                                ),
                                Expanded(child: _getDatePicker()),
                                const SizedBox(
                                  width: 1,
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
                                          width: 1,
                                        ),
                                      if (!_isSectionPickerOpen) Expanded(child: _getDatePicker()),
                                      if (!_isSectionPickerOpen)
                                        const SizedBox(
                                          width: 1,
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
                  ] +
                  _filteredLogBookList.map((e) => _getLogBookWidget(e)).toList(),
            ),
    );
  }
}
