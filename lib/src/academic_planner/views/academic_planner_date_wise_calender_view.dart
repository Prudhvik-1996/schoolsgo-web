import 'package:calendar_view/calendar_view.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  List<PlannerTimeSlot> _plannerTimeSlots = [];

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
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : Column(
              children: [
                Container(
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
                    (convertDateTimeToYYYYMMDDFormat(_selectedDate) == e.date))
                .map((e) => Card(
                      child: Text("${e.toJson()}"),
                    ))
                .toList(),
          ),
        )
      ],
    );
  }

  Widget calenderWidget() {
    Iterable<PlannerTimeSlot> _filteredPlannerSlots = _plannerTimeSlots.where((e) =>
        (_selectedSection == null || e.sectionId == _selectedSection?.sectionId) &&
        (_selectedTeacher == null || e.teacherId == _selectedTeacher?.teacherId));
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
                    (convertDateTimeToYYYYMMDDFormat(date) == e.date))
                .map(
                  (e) => e.toCalenderEventData(),
                )
                .toList(),
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
}
