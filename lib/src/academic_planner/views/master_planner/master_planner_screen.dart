import 'dart:convert';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/academic_planner/views/master_planner/master_planner_creation_screen.dart';
import 'package:schoolsgo_web/src/academic_planner/views/master_planner/planner_list_for_each_tds.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/local_clean_calender/flutter_clean_calendar.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/academic_years.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class MasterPlannerScreen extends StatefulWidget {
  const MasterPlannerScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<MasterPlannerScreen> createState() => _MasterPlannerScreenState();
}

class _MasterPlannerScreenState extends State<MasterPlannerScreen> {
  bool _isLoading = true;
  bool _isEditMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionPickerOpen = false;

  List<TeacherDealingSection> _tdsList = [];
  List<TeacherDealingSection> _filteredTdsList = [];

  Map<int, List<PlannedBeanForTds>> tdsWisePlannerBeans = {};
  Map<int, ScrollController> tdsWiseScrollControllers = {};
  List<PlannerTimeSlot> plannerTimeSlots = [];
  Map<DateTime, List<CleanCalendarEvent>> eventMap = {};

  DateTime selectedDate = DateTime.now();
  final GlobalKey<CalendarState> calenderKey = GlobalKey<CalendarState>();

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }

    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        _sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }

    GetTeacherDealingSectionsRequest getTeacherDealingSectionsRequest = GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(getTeacherDealingSectionsRequest);
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!.map((e) => e).toList();
        for (TeacherDealingSection eachTds in _tdsList) {
          tdsWiseScrollControllers[eachTds.tdsId!] = ScrollController();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');
    GetSchoolWiseAcademicYearsResponse response = await getSchoolWiseAcademicYears(
      GetSchoolWiseAcademicYearsRequest(schoolId: widget.adminProfile.schoolId),
    );

    if (response.httpStatus == "OK" && response.responseStatus == "success") {
      List<AcademicYearBean> academicYears = response.academicYearBeanList?.whereNotNull().toList() ?? [];
      String? startDate;
      String? endDate;

      if (academicYears.isNotEmpty) {
        if (selectedAcademicYearId != null) {
          if (academicYears.any((e) => e.academicYearId == selectedAcademicYearId)) {
            startDate = academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearStartDate;
            endDate = academicYears.where((e) => e.academicYearId == selectedAcademicYearId).first.academicYearEndDate;
          } else {
            startDate = academicYears.last.academicYearStartDate;
            endDate = academicYears.last.academicYearEndDate;
          }
        } else {
          startDate = academicYears.last.academicYearStartDate;
          endDate = academicYears.last.academicYearEndDate;
        }
      }
      GetPlannerTimeSlotsRequest getPlannerTimeSlotsRequest = GetPlannerTimeSlotsRequest(
        schoolId: widget.adminProfile.schoolId,
        startDate: startDate,
        endDate: endDate,
      );
      GetPlannerTimeSlotsResponse getPlannerTimeSlotsResponse = await getPlannerTimeSlots(getPlannerTimeSlotsRequest);
      if (getPlannerTimeSlotsResponse.httpStatus == "OK" && getPlannerTimeSlotsResponse.responseStatus == "success") {
        setState(() {
          plannerTimeSlots = getPlannerTimeSlotsResponse.plannerTimeSlots!.map((e) => e!).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        return;
      }
      GetPlannerResponse getPlannerResponse = await getPlanner(GetPlannerRequest(
        schoolId: widget.adminProfile.schoolId,
        // academicYearId: TODO
      ));
      if (getPlannerResponse.httpStatus == "OK" && getPlannerResponse.responseStatus == "success") {
        setState(() {
          getPlannerResponse.plannerBeans!.map((e) => e!).map((e) {
            int? tdsId = e.tdsId;
            String rawJsonListString = e.plannerBeanJsonString ?? "[]";
            rawJsonListString = rawJsonListString.replaceAll('"[', '[').replaceAll(']"', ']').replaceAll('\\', '');
            List<dynamic> rawJsonList = jsonDecode(rawJsonListString);
            List<PlannedBeanForTds> x = [];
            for (var json in rawJsonList) {
              x.add(PlannedBeanForTds.fromJson(json));
            }
            return MapEntry(tdsId, x);
          }).forEach((entry) {
            int? tdsId = entry.key;
            // print("182: ${entry.key} :: ${entry.value}");
            List<PlannedBeanForTds> list = entry.value;
            if (tdsId != null) {
              tdsWisePlannerBeans[tdsId] = list.whereNotNull().toList();
            }
          });
        });
        updateSlotsForAllBeans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
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

  Future<void> _saveChangesAlert() async {
    tdsWisePlannerBeans.forEach((tdsId, plannerBeans) {
      for (PlannedBeanForTds plannerBean in plannerBeans) {
        String? errorMessage = canSubmit(plannerBean);
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
          continue;
        }
      }
    });
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Academic Planner'),
          content: const Text("Are you sure to save changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.of(context).pop();
                await saveChanges();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                Navigator.of(context).pop();
                _loadData();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveChanges() async {
    setState(() => _isLoading = true);
    tdsWisePlannerBeans.forEach((tdsId, plannerBeans) async {
      TeacherDealingSection tds = _tdsList.firstWhere((e) => e.tdsId == tdsId);
      CreateOrUpdatePlannerResponse createOrUpdatePlannerResponse = await createOrUpdatePlanner(CreateOrUpdatePlannerRequest(
        tdsId: tds.tdsId,
        teacherId: tds.teacherId,
        subjectId: tds.subjectId,
        sectionId: tds.sectionId,
        schoolId: widget.adminProfile.schoolId,
        agent: widget.adminProfile.userId,
        plannerBeanJsonString: jsonEncode("[" + plannerBeans.map((e) => jsonEncode(e.toJson())).join(",") + "]"),
      ));
      if (createOrUpdatePlannerResponse.httpStatus != "OK" || createOrUpdatePlannerResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    });
    await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      _isEditMode = false;
      _isLoading = false;
    });
  }

  Future<void> updateSlotsForAllBeans() async {
    for (int i = 0; i < tdsWisePlannerBeans.keys.length; i++) {
      int tdsId = tdsWisePlannerBeans.keys.elementAt(i);
      TeacherDealingSection tds = _tdsList.firstWhere((e) => e.tdsId == tdsId);
      List<PlannedBeanForTds> plannerBeans = tdsWisePlannerBeans[tdsId]!;
      if (plannerBeans.isEmpty) return;
      List<PlannerTimeSlot> plannerTimeSlotsDup = [...plannerTimeSlots.where((e) => e.tdsId == tdsId)];
      for (var plannerBean in plannerBeans) {
        if ((plannerBean.noOfSlots ?? 0) != 0 && plannerTimeSlotsDup.isNotEmpty) {
          plannerBean.plannerSlots = plannerTimeSlotsDup.sublist(0, plannerBean.noOfSlots!);
          plannerTimeSlotsDup.removeRange(0, plannerBean.noOfSlots!);
        }
      }
      for (PlannedBeanForTds plannerBean in plannerBeans) {
        for (PlannerTimeSlot plannerSlot in (plannerBean.plannerSlots ?? [])) {
          if (!eventMap.containsKey(convertYYYYMMDDFormatToDateTime(plannerSlot.date))) {
            eventMap[convertYYYYMMDDFormatToDateTime(plannerSlot.date)] = [];
          }
          eventMap[convertYYYYMMDDFormatToDateTime(plannerSlot.date)]!.add(CleanCalendarEvent(
            "${tds.sectionName ?? " - "} - ${tds.subjectName ?? " - "}\n${tds.teacherName ?? " - "}",
            description: "${plannerBean.title ?? " - "}\n${plannerBean.description ?? " - "}",
            startTime: plannerSlot.getStartTimeInDate(),
            endTime: plannerSlot.getEndTimeInDate(),
            color: Colors.blue,
            isApproved: plannerBean.approvalStatus == "Approved",
            tds: tds,
          ));
        }
      }
    }
    setState(() => {});
  }

  Future<void> onReorder(int tdsId, List<PlannedBeanForTds> plannerBeans) async => setState(() => tdsWisePlannerBeans[tdsId] = plannerBeans);

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
        clearButton: IconButton(
          onPressed: () {
            setState(() => _selectedTeacher = null);
            _applyFilters();
          },
          icon: const Icon(Icons.clear),
        ),
        enabled: true,
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

  String? canSubmit(PlannedBeanForTds plannerBean) {
    if ((plannerBean.title?.trim() ?? "") == "") {
      return "Title cannot be empty..";
    }
    if ((plannerBean.description?.trim() ?? "") == "") {
      return "Description cannot be empty..";
    }
    if (plannerBean.noOfSlots == null) {
      return "Number of slots cannot be empty..";
    }
    return null;
  }

  Widget _tdsWidget(TeacherDealingSection tds, {double? width}) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      width: width,
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
    );
  }

  void handleMoreOptions(String value) {
    switch (value) {
      case "Planner Creation":
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MasterPlannerCreationScreen(
            adminProfile: widget.adminProfile,
            sections: _sectionsList,
            tdsList: _tdsList,
          );
        })).then((_) => _loadData());
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Master Planner"),
        actions: [
          if (!_isLoading && !_isEditMode)
            PopupMenuButton<String>(
              onSelected: handleMoreOptions,
              itemBuilder: (BuildContext context) {
                return {'Planner Creation'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!_isSectionPickerOpen) const SizedBox(width: 10),
                    Expanded(child: _sectionPicker()),
                    if (!_isSectionPickerOpen) const SizedBox(width: 10),
                    if (!_isSectionPickerOpen) Expanded(child: _teacherPicker()),
                    if (!_isSectionPickerOpen) const SizedBox(width: 30),
                  ],
                ),
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (TeacherDealingSection eachTds in _filteredTdsList)
                          Column(
                            children: [
                              _tdsWidget(eachTds,
                                  width: MediaQuery.of(context).orientation == Orientation.landscape
                                      ? MediaQuery.of(context).size.width / 3
                                      : MediaQuery.of(context).size.width),
                              Expanded(
                                child: PlannerListForEachTds(
                                  adminProfile: widget.adminProfile,
                                  tds: eachTds,
                                  width: MediaQuery.of(context).orientation == Orientation.landscape
                                      ? MediaQuery.of(context).size.width / 3
                                      : MediaQuery.of(context).size.width,
                                  scrollController: tdsWiseScrollControllers[eachTds.tdsId!]!,
                                  plannerBeans: tdsWisePlannerBeans[eachTds.tdsId] ?? [],
                                  actionOnAdd: null,
                                  // TODO
                                  actionOnEdit: null,
                                  // TODO
                                  updateSlotsForAllBeans: updateSlotsForAllBeans,
                                  canSubmit: canSubmit,
                                  onReorder: onReorder,
                                  superSetState: setState,
                                  isEditMode: _isEditMode,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _isLoading
          ? null
          : _isEditMode
              ? fab(
                  const Icon(Icons.check),
                  "Submit",
                  () async {
                    await _saveChangesAlert();
                    setState(() {
                      _isEditMode = false;
                    });
                  },
                  color: Colors.green,
                )
              : fab(
                  const Icon(Icons.edit),
                  "Edit",
                  () {
                    setState(() {
                      _isEditMode = true;
                    });
                  },
                  color: Colors.blue,
                ),
    );
  }

  Widget fab(Icon icon, String text, Function() action, {Function()? postAction, Color? color}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await action();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (postAction != null) {
              await postAction();
            }
          });
        },
        child: ClayButton(
          surfaceColor: color ?? clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 20,
          spread: 2,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
