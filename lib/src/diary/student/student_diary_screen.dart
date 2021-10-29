import 'package:clay_containers/widgets/clay_container.dart';
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

class StudentDiaryScreen extends StatefulWidget {
  const StudentDiaryScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/diary";

  @override
  _StudentDiaryScreenState createState() => _StudentDiaryScreenState();
}

class _StudentDiaryScreenState extends State<StudentDiaryScreen> {
  bool _isLoading = true;

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;

  List<TeacherDealingSection> _tdsList = [];
  List<TeacherDealingSection> _filteredTdsList = [];

  DateTime _selectedDate = DateTime.now();

  List<Diary> _diaryList = [];
  List<Diary> _filteredDiaryList = [];

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
      schoolId: widget.studentProfile.schoolId,
    );
    GetTeachersResponse getTeachersResponse =
        await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" &&
        getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachersList = getTeachersResponse.teachers!;
        if (_teachersList.length == 1) {
          _selectedTeacher = _teachersList[0];
        } else {
          _teachersList.sort((a, b) =>
              (a.teacherName ?? "-").compareTo((b.teacherName ?? "-")));
        }
      });
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
    );
    GetSectionsResponse getSectionsResponse =
        await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" &&
        getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
        if (_sectionsList.length == 1) {
          _selectedSection = _sectionsList[0];
        } else {
          _sectionsList
              .sort((b, a) => (a.sectionId ?? 0).compareTo((b.sectionId ?? 0)));
        }
      });
    }

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse =
        await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" &&
        getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
        _filteredTdsList =
            getTeacherDealingSectionsResponse.teacherDealingSections!;
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

    GetDiaryResponse getDiaryResponse = await getDiary(
      GetDiaryRequest(
        schoolId: widget.studentProfile.schoolId,
        sectionId: widget.studentProfile.sectionId,
        studentId: widget.studentProfile.studentId,
        date: _selectedDate.millisecondsSinceEpoch,
      ),
    );
    if (getDiaryResponse.httpStatus == "OK" &&
        getDiaryResponse.responseStatus == "success") {
      setState(() {
        _diaryList = getDiaryResponse.sectionDiaryList!
            .map((e) => e!.diaryEntries!.map((e) => e!))
            .expand((e) => e)
            .toList();
        _diaryList
            .sort((b, a) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0));
        _filteredDiaryList = getDiaryResponse.sectionDiaryList!
            .map((e) => e!.diaryEntries!.map((e) => e!))
            .expand((e) => e)
            .toList();
        _filteredDiaryList
            .sort((b, a) => (a.sectionId ?? 0).compareTo(b.sectionId ?? 0));
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
        _filteredTdsList = _filteredTdsList
            .where((e) => e.teacherId == _selectedTeacher!.teacherId)
            .toList();
        _filteredDiaryList = _filteredDiaryList
            .where((e) => e.teacherId == _selectedTeacher!.teacherId)
            .toList();
      });
    }
    if (_selectedSection != null) {
      setState(() {
        _filteredTdsList = _filteredTdsList
            .where((e) => e.sectionId == _selectedSection!.sectionId)
            .toList();
        _filteredDiaryList = _filteredDiaryList
            .where((e) => e.sectionId == _selectedSection!.sectionId)
            .toList();
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
          .where((teacher) => _filteredTdsList
              .map((tds) => tds.teacherId)
              .contains(teacher.teacherId))
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
          .where((section) => _filteredTdsList
              .map((tds) => tds.sectionId)
              .contains(section.sectionId))
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
          _loadDiary();
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
            if (_selectedDate.millisecondsSinceEpoch ==
                DateTime.now()
                    .subtract(const Duration(days: 364))
                    .millisecondsSinceEpoch) return;
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
        child: InkWell(
          onTap: () {
            if (_selectedDate.millisecondsSinceEpoch ==
                DateTime.now().millisecondsSinceEpoch) return;
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

  Container _getDiaryWidget(Diary diary) {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20,
              MediaQuery.of(context).size.width / 4, 20)
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAssignmentWidget(Diary diary) {
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
          child: Text(
            diary.assignment ?? "-",
            textAlign:
                diary.assignment == null ? TextAlign.center : TextAlign.justify,
          ),
        ),
      ),
    );
  }

  Container buildSubjectNameWidget(Diary diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Subject: ${diary.subjectName!.capitalize()}"),
    );
  }

  Container buildTeacherNameWidget(Diary diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text("Teacher: ${diary.teacherFirstName!.capitalize()}"),
    );
  }

  Container buildSectionNameWidget(Diary diary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Text(
        "Section: ${diary.sectionName}",
      ),
    );
  }

  Container buildEditButton(Diary diary) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          if (diary.isEditMode) {
            if (diary.assignment != diary.origJson()["assignment"]) {
              // _saveChanges(diary);
            }
          }
          setState(() {
            diary.isEditMode = !diary.isEditMode;
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
            child: Icon(diary.isEditMode ? Icons.check : Icons.edit),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diary"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.studentProfile,
          ),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: <Widget>[
                    Container(
                      child: MediaQuery.of(context).orientation ==
                              Orientation.landscape
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
                  _filteredDiaryList.map((e) => _getDiaryWidget(e)).toList(),
            ),
    );
  }
}
