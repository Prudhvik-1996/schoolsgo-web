import 'dart:convert';

import 'package:calendar_view/calendar_view.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_for_tds_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
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

class AcademicPlannerDateWiseCalenderView extends StatefulWidget {
  const AcademicPlannerDateWiseCalenderView({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AcademicPlannerDateWiseCalenderView> createState() => _AcademicPlannerDateWiseCalenderViewState();
}

class _AcademicPlannerDateWiseCalenderViewState extends State<AcademicPlannerDateWiseCalenderView> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Teacher> _teachersList = [];
  Teacher? _selectedTeacher;

  List<Section> _sectionsList = [];
  Section? _selectedSection;
  bool _isSectionPickerOpen = false;

  DateTime _selectedDate = DateTime.now();

  List<TeacherDealingSection> _tdsList = [];
  TeacherDealingSection? selectedTds;

  List<PlannerTimeSlot> _plannerTimeSlots = [];

  Map<int, List<PlannedBeanForTds>> tdsWisePlannerBeans = {};

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
          _plannerTimeSlots = getPlannerTimeSlotsResponse.plannerTimeSlots!.map((e) => e!).toList();
        });
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

    setState(() {
      _isLoading = false;
    });
  }

  void updateSlotsForAllBeans(TeacherDealingSection tds) {
    if ((tdsWisePlannerBeans[tds.tdsId] ?? []).isEmpty) return;
    List<PlannerTimeSlot> plannerTimeSlotsDup = [..._plannerTimeSlots.where((e) => e.tdsId == tds.tdsId)];
    for (var plannerBean in tdsWisePlannerBeans[tds.tdsId]!) {
      if ((plannerBean.noOfSlots ?? 0) != 0) {
        plannerBean.plannerSlots = plannerTimeSlotsDup.sublist(0, plannerBean.noOfSlots!);
        plannerTimeSlotsDup.removeRange(0, plannerBean.noOfSlots!);
      }
    }
  }

  Future<void> _loadPlannerForTds(TeacherDealingSection tds) async {
    setState(() => _isLoading = true);
    GetPlannerResponse getPlannerResponse = await getPlanner(GetPlannerRequest(
      tdsId: tds.tdsId,
      teacherId: tds.teacherId,
      subjectId: tds.subjectId,
      sectionId: tds.sectionId,
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
          List<PlannedBeanForTds> list = entry.value;
          if (tdsId != null) {
            tdsWisePlannerBeans[tdsId] = list.whereNotNull().toList();
          }
        });
      });
      updateSlotsForAllBeans(tds);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Academic Planner"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
        ],
      ),
      drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              children: [
                // Container(
                //   child: MediaQuery.of(context).orientation == Orientation.landscape
                //       ? Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Expanded(child: _sectionPicker()),
                //             if (!_isSectionPickerOpen) Expanded(child: _teacherPicker()),
                //             if (!_isSectionPickerOpen)
                //               const SizedBox(
                //                 width: 10,
                //               ),
                //           ],
                //         )
                //       : Column(
                //           children: [
                //             Row(
                //               children: [
                //                 const SizedBox(
                //                   width: 5,
                //                 ),
                //                 Expanded(
                //                   child: _sectionPicker(),
                //                 ),
                //                 const SizedBox(
                //                   width: 5,
                //                 ),
                //               ],
                //             ),
                //             Row(
                //               children: [
                //                 const SizedBox(
                //                   width: 25,
                //                 ),
                //                 Expanded(
                //                   child: _teacherPicker(),
                //                 ),
                //                 const SizedBox(
                //                   width: 25,
                //                 ),
                //               ],
                //             ),
                //           ],
                //         ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(child: _tdsDropDown()),
                    ],
                  ),
                ),
                _showCalenderWidget()
                    ? Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: calenderWidget(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: selectedDateWidget(),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      )
                    : const Expanded(child: Center(child: Text("Nothing to show.."))),
              ],
            ),
    );
  }

  Widget selectedDateWidget() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                convertDateToDDMMMYYYEEEE(convertDateTimeToYYYYMMDDFormat(_selectedDate)),
                style: GoogleFonts.archivoBlack(
                  textStyle: TextStyle(
                    fontSize: 36,
                    color: clayContainerTextColor(context),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: _plannerTimeSlots
                .where((e) =>
                    (_selectedSection == null || e.sectionId == _selectedSection?.sectionId) &&
                    (_selectedTeacher == null || e.teacherId == _selectedTeacher?.teacherId) &&
                    (selectedTds?.tdsId == e.tdsId) &&
                    (convertDateTimeToYYYYMMDDFormat(_selectedDate) == e.date))
                .map((e) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${e.timeStringEq()}\n${combineDataForDate(e)}".trim()),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  String combineDataForDate(PlannerTimeSlot e) {
    for (PlannedBeanForTds plannedBean in tdsWisePlannerBeans[selectedTds!.tdsId!] ?? []) {
      for (PlannerTimeSlot timeSlot in plannedBean.plannerSlots!) {
        if (timeSlot == e) {
          return ("${plannedBean.title}, ${plannedBean.description}, ${plannedBean.approvalStatus}");
        }
      }
    }
    return "";
  }

  PlannedBeanForTds? plannedBeanForTdsForDate(PlannerTimeSlot e) {
    for (PlannedBeanForTds plannedBean in tdsWisePlannerBeans[selectedTds!.tdsId!] ?? []) {
      for (PlannerTimeSlot timeSlot in plannedBean.plannerSlots!) {
        if (timeSlot == e) {
          return plannedBean;
        }
      }
    }
    return null;
  }

  Widget calenderWidget() {
    Iterable<PlannerTimeSlot> _filteredPlannerSlots = _plannerTimeSlots.where((e) =>
        (_selectedSection == null || e.sectionId == _selectedSection?.sectionId) &&
        (_selectedTeacher == null || e.teacherId == _selectedTeacher?.teacherId) &&
        selectedTds?.tdsId == e.tdsId);
    return Container(
      color: clayContainerColor(context),
      child: CalendarControllerProvider<PlannerTimeSlot>(
        controller: EventController<PlannerTimeSlot>()
          ..addAll(
            _filteredPlannerSlots
                .map(
                  (e) => e.toCalenderEventData(),
                )
                .toList(),
          ),
        child: MonthView<PlannerTimeSlot>(
          borderColor: clayContainerTextColor(context),
          width: double.infinity,
          minMonth: _filteredPlannerSlots.sorted((a, b) => a.getStartTimeInDate().compareTo(b.getStartTimeInDate())).first.getStartTimeInDate(),
          maxMonth: _filteredPlannerSlots.sorted((a, b) => a.getEndTimeInDate().compareTo(b.getEndTimeInDate())).last.getEndTimeInDate(),
          initialMonth: DateTime.now(),
          headerStyle: HeaderStyle(
            leftIcon: Icon(
              Icons.arrow_left,
              color: clayContainerTextColor(context),
            ),
            rightIcon: Icon(
              Icons.arrow_right,
              color: clayContainerTextColor(context),
            ),
            decoration: BoxDecoration(
              color: clayContainerColor(context),
            ),
            headerTextStyle: TextStyle(
              color: clayContainerTextColor(context),
            ),
          ),
          headerStringBuilder: (DateTime headerDate, {DateTime? secondaryDate}) {
            return "${MONTHS[headerDate.month - 1].toLowerCase().capitalize()}, ${headerDate.year}";
          },
          startDay: WeekDays.sunday,
          onCellTap: (List<CalendarEventData<PlannerTimeSlot>> eventData, DateTime date) {
            setState(() {
              _selectedDate = date;
            });
          },
          cellBuilder: (date, event, isToday, isInMonth) => FilledCell<PlannerTimeSlot>(
            date: date,
            shouldHighlight: convertDateTimeToYYYYMMDDFormat(date) == convertDateTimeToYYYYMMDDFormat(_selectedDate),
            backgroundColor: clayContainerColor(context),
            events: _plannerTimeSlots
                .where((e) =>
                    (_selectedSection == null || e.sectionId == _selectedSection?.sectionId) &&
                    (_selectedTeacher == null || e.teacherId == _selectedTeacher?.teacherId) &&
                    (convertDateTimeToYYYYMMDDFormat(date) == e.date) &&
                    selectedTds?.tdsId == e.tdsId)
                .map(
              (e) {
                PlannedBeanForTds? x = plannedBeanForTdsForDate(e);
                return e.toCalenderEventData(
                  title: x?.title,
                  description: x?.description,
                );
              },
            ).toList(),
            onTileTap: (CalendarEventData<PlannerTimeSlot> event, DateTime date) {
              setState(() {
                _selectedDate = date;
              });
              showDialog(
                context: _scaffoldKey.currentContext!,
                builder: (currentContext) {
                  return AlertDialog(
                    title: Text(
                      event.title,
                      style: event.titleStyle,
                    ),
                    content: Text(
                      event.description,
                      style: event.descriptionStyle,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // _saveChanges();
                          // _loadData();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            },
            isInMonth: isInMonth,
            dateStringBuilder: (DateTime date, {DateTime? secondaryDate}) {
              return "${date.day}";
            },
            tileColor: clayContainerTextColor(context),
          ),
        ),
      ),
    );
  }

  bool _showCalenderWidget() {
    if (selectedTds != null) return true;
    if (_selectedSection == null && _selectedTeacher == null) return false;
    if (_selectedSection != null &&
        _selectedTeacher != null &&
        _tdsList.where((e) => e.teacherId == _selectedTeacher?.teacherId && e.sectionId == _selectedSection?.sectionId).isEmpty) return false;
    return true;
  }

  Widget _teacherPicker() {
    return _buildSearchableTeacherDropdown();
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
          if (_isLoading) return;
          setState(() {
            _selectedTeacher = teacher;
          });
          // if (!_plannerTimeSlots
          //     .where((e) =>
          //         (_selectedSection == null || e.sectionId == _selectedSection?.sectionId) &&
          //         (_selectedTeacher == null || e.teacherId == _selectedTeacher?.teacherId))
          //     .any((e) => e.getDate() == _selectedDate)) {
          //   _selectedDate = _plannerTimeSlots
          //       .where((e) =>
          //           (_selectedSection == null || e.sectionId == _selectedSection?.sectionId) &&
          //           (_selectedTeacher == null || e.teacherId == _selectedTeacher?.teacherId))
          //       .sorted((a, b) => a.getStartTimeInDate().compareTo(b.getStartTimeInDate()))
          //       .first
          //       .getStartTimeInDate();
          // }
          //  TODO
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
          if (_isLoading) return;
          setState(() {
            if (_selectedSection != null && _selectedSection!.sectionId == section.sectionId) {
              _selectedSection = null;
            } else {
              _selectedSection = section;
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
          GestureDetector(
            onTap: () {
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
        if (_isLoading) return;
        setState(() {
          _isSectionPickerOpen = !_isSectionPickerOpen;
        });
        //  TODO
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

  Widget _tdsDropDown() {
    return ClayButton(
      depth: 40,
      parentColor: clayContainerColor(context),
      surfaceColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      height: 60,
      width: 60,
      child: DropdownSearch<TeacherDealingSection>(
        enabled: true,
        mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
        selectedItem: selectedTds,
        items: _tdsList.where((e) => e.status == 'active').toList(),
        itemAsString: (TeacherDealingSection? tds) {
          return tds == null ? "" : "${tds.sectionName ?? "-"}\n${tds.subjectName ?? "-"}\n${tds.teacherName ?? "-"}";
        },
        showSearchBox: true,
        dropdownBuilder: (BuildContext context, TeacherDealingSection? tds) {
          return _buildTeacherDealingSectionWidget(tds);
        },
        onChanged: (TeacherDealingSection? tds) {
          if (_isLoading) return;
          setState(() {
            selectedTds = tds;
          });
          if (tds != null) {
            _loadPlannerForTds(tds);
          } else {
            setState(() {
              tdsWisePlannerBeans.clear();
            });
          }
        },
        showClearButton: true,
        compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
        dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
        filterFn: (TeacherDealingSection? tds, String? key) {
          return (tds == null ? "" : "${tds.sectionName ?? "-"}${tds.subjectName ?? "-"}${tds.teacherName ?? "-"}")
              .toLowerCase()
              .contains(key!.toLowerCase());
        },
      ),
    );
  }

  Widget _buildTeacherDealingSectionWidget(TeacherDealingSection? e) {
    Teacher? teacher = e == null ? null : _teachersList.where((et) => et.teacherId == e.teacherId).firstOrNull;
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
            child: teacher?.teacherPhotoUrl == null
                ? Image.asset(
                    "assets/images/avatar.png",
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    teacher!.teacherPhotoUrl!,
                    fit: BoxFit.contain,
                  ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                e == null ? "Select" : "${e.sectionName ?? "-"}\n${e.subjectName ?? "-"}\n${e.teacherName ?? "-"}",
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
}
