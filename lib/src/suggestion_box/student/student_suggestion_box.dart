import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/suggestion_box/model/suggestion_box.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentSuggestionBoxView extends StatefulWidget {
  const StudentSuggestionBoxView({Key? key, required this.studentProfile}) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/suggestion_box";

  @override
  _StudentSuggestionBoxViewState createState() => _StudentSuggestionBoxViewState();
}

class _StudentSuggestionBoxViewState extends State<StudentSuggestionBoxView> {
  bool _isLoading = true;
  bool _isEditMode = false;

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<TeacherDealingSection> _tdsList = [];
  List<TeacherDealingSection> _filteredTdsList = [];

  DateTime? _selectedDate;

  List<Suggestion> _suggestions = [];
  List<Suggestion> _filteredSuggestions = [];

  String? _selectedComplainStatus;

  final ItemScrollController _itemScrollController = ItemScrollController();

  bool _isAddNew = false;
  late Suggestion newSuggestion;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      newSuggestion = Suggestion(
        postingStudentId: widget.studentProfile.studentId,
        status: "active",
        agent: widget.studentProfile.studentId,
        sectionId: widget.studentProfile.sectionId,
        sectionName: widget.studentProfile.sectionName,
      );
      _selectedTeacher = null;
      _isAddNew = false;
    });

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.studentProfile.schoolId,
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

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.studentProfile.schoolId,
      status: "active",
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
        _filteredTdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }

    GetSuggestionBoxResponse getSuggestionBoxResponse = await getSuggestionBox(GetSuggestionBoxRequest(
      schoolId: widget.studentProfile.schoolId,
      postingStudentId: widget.studentProfile.studentId,
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
      _filteredTdsList = _tdsList.where((e) => e.sectionId == widget.studentProfile.sectionId).toList();
      _filteredSuggestions = _suggestions;
    });
    if (_selectedComplainStatus != null) {
      setState(() {
        _filteredSuggestions = _filteredSuggestions.where((e) => e.complainStatus == _selectedComplainStatus).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
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
                        Text(
                          "${suggestion.complainStatus}",
                          textAlign: TextAlign.end,
                          style: TextStyle(color: suggestion.complainStatus == "INITIATED" ? Colors.red : Colors.green),
                        ),
                        if (_isEditMode && suggestion.complainStatus != "RESOLVED")
                          const SizedBox(
                            width: 15,
                          ),
                        _isEditMode && suggestion.complainStatus != "RESOLVED" ? buildDeleteButton(suggestion) : Container(),
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
                    child: Text(
                      suggestion.anonymous! ? "" : "Student Name: ${suggestion.postingStudentName}",
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Raised Against: " + (suggestion.teacherId == null ? "${widget.studentProfile.schoolName}" : "${suggestion.teacherName}"),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                child: ClayContainer(
                  depth: 10,
                  color: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
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

  Future<void> _deleteSuggestion(Suggestion suggestion) async {
    setState(() {
      _isLoading = true;
    });

    UpdateSuggestionResponse updateSuggestionResponse = await updateSuggestion(
      UpdateSuggestionRequest(
        schoolId: widget.studentProfile.schoolId,
        agent: widget.studentProfile.studentId,
        complaintId: suggestion.complaintId,
        status: "inactive",
      ),
    );

    if (updateSuggestionResponse.httpStatus != "OK" || updateSuggestionResponse.responseStatus != "success") {
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

  Container buildDeleteButton(Suggestion suggestion) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: InkWell(
        onTap: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Suggestion Box'),
                content: const Text("Are you sure to delete the suggestion?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteSuggestion(suggestion);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 35,
          width: 35,
          borderRadius: 35,
          surfaceColor: clayContainerColor(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: const FittedBox(
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              fit: BoxFit.scaleDown,
            ),
          ),
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
                      style: TextStyle(
                        color: e == "INITIATED" ? Colors.red : Colors.green,
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
          if (_filteredSuggestions.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Suggestions not found"),
              ),
            );
            return;
          }
          DateTime? _newDate = await showDatePicker(
            context: context,
            selectableDayPredicate: (DateTime val) {
              return _filteredSuggestions
                  .map((e) {
                    DateTime x = DateTime.fromMillisecondsSinceEpoch(e.createTime!);
                    return DateTime(x.year, x.month, x.day);
                  })
                  .toList()
                  .contains(val);
            },
            initialDate: _filteredSuggestions
                .map((e) {
                  DateTime x = DateTime.fromMillisecondsSinceEpoch(e.createTime!);
                  return DateTime(x.year, x.month, x.day);
                })
                .toList()
                .first,
            firstDate: _filteredSuggestions
                .map((e) {
                  DateTime x = DateTime.fromMillisecondsSinceEpoch(e.createTime!);
                  return DateTime(x.year, x.month, x.day);
                })
                .toList()
                .last,
            lastDate: _filteredSuggestions
                .map((e) {
                  DateTime x = DateTime.fromMillisecondsSinceEpoch(e.createTime!);
                  return DateTime(x.year, x.month, x.day);
                })
                .toList()
                .first,
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            _selectedDate = _newDate;
            _itemScrollController.scrollTo(
              index: _filteredSuggestions
                  .map((e) {
                    DateTime x = DateTime.fromMillisecondsSinceEpoch(e.createTime!);
                    return DateTime(x.year, x.month, x.day);
                  })
                  .toList()
                  .indexOf(_selectedDate!),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutCubic,
            );
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: const Color(0xFFC9EDF8),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 50,
          height: 60,
          width: 60,
          child: const Center(
            child: Icon(
              Icons.calendar_today_rounded,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectStatus() {
    return Container(
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

  Widget buildEditButton() {
    return Tooltip(
      message: 'Edit',
      child: InkWell(
        onTap: () async {
          setState(() {
            _isEditMode = !_isEditMode;
          });
        },
        child: ClayButton(
          color: clayContainerColor(context),
          height: 60,
          width: 60,
          borderRadius: 50,
          surfaceColor: clayContainerColor(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: FittedBox(
              child: Icon(
                _isEditMode ? Icons.check : Icons.edit,
              ),
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectTeacher() {
    return _teachersList.length != 1 && _selectedTeacher != null
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
                      newSuggestion.teacherId = null;
                    });
                    _applyFilters();
                  },
                  child: const Icon(Icons.close),
                ),
              ),
            ],
          )
        : dropdownButtonForTeacher();
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
          newSuggestion.teacherId = teacher.teacherId;
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

  Widget _buildNewSuggestionWidget() {
    return Center(
      child: Container(
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
                        "Section: ${widget.studentProfile.sectionName}",
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: const Text(
                              "Raise against:",
                              textAlign: TextAlign.start,
                            ),
                          ),
                          DropdownButton(
                            items: ["School", "Teacher"]
                                .map((e) => DropdownMenuItem(
                                      child: Text(e),
                                      value: e,
                                    ))
                                .toList(),
                            value: newSuggestion.isEditMode ? "School" : "Teacher",
                            onChanged: (String? newValue) {
                              setState(() {
                                newSuggestion.isEditMode = (newValue ?? "School") == "School";
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text("Student Name: ${widget.studentProfile.studentFirstName}"),
                    ),
                    Expanded(
                      child: newSuggestion.isEditMode
                          ? Text(
                              ("${widget.studentProfile.schoolName}"),
                              textAlign: TextAlign.end,
                            )
                          : _selectTeacher(),
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
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Title",
                            ),
                            maxLines: 1,
                            initialValue: newSuggestion.title ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.justify,
                            onChanged: (text) => setState(() {
                              newSuggestion.title = text;
                            }),
                          )
                        ],
                      ),
                    ),
                  ),
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
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Description",
                            ),
                            maxLines: null,
                            initialValue: newSuggestion.description ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.justify,
                            onChanged: (text) => setState(() {
                              newSuggestion.description = text;
                            }),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: newSuggestion.anonymous ?? false,
                            onChanged: (bool? newValue) {
                              setState(() {
                                newSuggestion.anonymous = newValue!;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text("Mark the box to drop the suggestion anonymously"),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      child: const Text("Submit"),
                      onPressed: () {
                        if (newSuggestion.isEditMode == false && newSuggestion.teacherId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Select a teacher to proceed"),
                            ),
                          );
                          return;
                        }
                        if (newSuggestion.title == null || newSuggestion.title!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Enter a title to the suggestion"),
                            ),
                          );
                          return;
                        }
                        if (newSuggestion.description == null || newSuggestion.description!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Write a detailed description to the suggestion"),
                            ),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Suggestion Box'),
                              content: const Text("Are you sure to drop the suggestion?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    CreateSuggestionResponse createSuggestionResponse = await createSuggestion(CreateSuggestionRequest(
                                      agent: newSuggestion.agent,
                                      postingStudentId: newSuggestion.postingStudentId,
                                      schoolId: widget.studentProfile.schoolId,
                                      description: newSuggestion.description,
                                      title: newSuggestion.title,
                                      againstTeacherId: newSuggestion.teacherId,
                                      anonymous: newSuggestion.anonymous,
                                      postingUserId: widget.studentProfile.gaurdianId,
                                    ));

                                    if (createSuggestionResponse.httpStatus != "OK" || createSuggestionResponse.responseStatus != "success") {
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
                                  },
                                  child: const Text(
                                    "Proceed",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ],
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
            widget.studentProfile,
          ),
        ],
      ),
      drawer: StudentAppDrawer(studentProfile: widget.studentProfile),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : _isAddNew
              ? _buildNewSuggestionWidget()
              : Column(
                  children: [
                    Container(
                      padding: MediaQuery.of(context).orientation == Orientation.landscape
                          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 5, MediaQuery.of(context).size.width / 4, 5)
                          : const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _selectStatus(),
                          ),
                          Row(
                            children: [
                              _getDatePicker(),
                              buildEditButton(),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        itemCount: _filteredSuggestions.length,
                        itemBuilder: (context, index) => _getSuggestionWidget(_filteredSuggestions[index]),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              child: _isAddNew ? const Icon(Icons.close) : const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _isAddNew = !_isAddNew;
                });
              },
            ),
    );
  }
}
