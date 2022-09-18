import 'package:clay_containers/clay_containers.dart';
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
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
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

  List<SectionWiseTimeSlotBean> _sectionWiseTimeSlots = [];

  DateTime _selectedDate = DateTime.now();

  List<LogBook> _logBookList = [];
  List<LogBook> _filteredLogBookList = [];

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

    GetSectionWiseTimeSlotsResponse getSectionWiseTimeSlotsResponse = await getSectionWiseTimeSlots(GetSectionWiseTimeSlotsRequest(
      schoolId: widget.teacherProfile == null ? widget.adminProfile!.schoolId : widget.teacherProfile!.schoolId,
      status: "active",
    ));
    if (getSectionWiseTimeSlotsResponse.httpStatus == "OK" && getSectionWiseTimeSlotsResponse.responseStatus == "success") {
      setState(() {
        _sectionWiseTimeSlots = getSectionWiseTimeSlotsResponse.sectionWiseTimeSlotBeanList!;

        _sectionWiseTimeSlots.sort((a, b) =>
            getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime!, a.weekId!).compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime!, b.weekId!)));
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
    _filteredLogBookList.sort(
      (a, b) => getSecondsEquivalentOfTimeFromWHHMMSS(a.startTime!, 1).compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(b.startTime!, 1)),
    );
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
                        _filterLogBookList();
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
        _filterLogBookList();
      },
      items: _teachersList
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
                        _filterLogBookList();
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
        _filterLogBookList();
      },
      items: _sectionsList
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

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: InkWell(
        onTap: () async {
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
          color: const Color(0xFFC9EDF8),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 50,
          height: 60,
          width: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  convertDateTimeToDDMMYYYYFormat(_selectedDate),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.blueGrey,
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
            if (_selectedDate.millisecondsSinceEpoch == DateTime.now().millisecondsSinceEpoch) return;
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
                  (widget.adminProfile != null && widget.adminProfile!.isMegaAdmin) ? Container() : buildEditButton(logBook),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Last Updated Time: ${logBook.lastUpdatedTime ?? "-"}",
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
                    Container(
                      child: MediaQuery.of(context).orientation == Orientation.landscape
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(child: _selectSection()),
                                Expanded(child: _selectTeacher()),
                                Expanded(child: _getDatePicker()),
                                _getLeftArrow(),
                                _getRightArrow(),
                              ],
                            )
                          : Column(
                              children: [
                                _selectSection(),
                                _selectTeacher(),
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
