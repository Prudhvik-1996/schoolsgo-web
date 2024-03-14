import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show AnchorElement;

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/logbook/model/logbook.dart';
import 'package:schoolsgo_web/src/model/teachers.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/stats/constants/date_selection_type.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class TeacherLogbookReportScreen extends StatefulWidget {
  const TeacherLogbookReportScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<TeacherLogbookReportScreen> createState() => _TeacherLogbookReportScreenState();
}

class _TeacherLogbookReportScreenState extends State<TeacherLogbookReportScreen> {
  bool _isLoading = true;
  bool _isFileDownloading = false;

  List<Teacher> _teachersList = [];
  List<int> _selectedTeacherIds = [];

  DateSelectionType _dateSelectionType = DateSelectionType.year;

  int? _startDate;
  int? _endDate;

  int? _selectedMonthYearIndex;
  late int currentMonthYearIndex;

  late int currentMonth;
  late int currentYear;
  late List<String> monthYears;

  late bool _getOnlyAnonymous;

  late String reportName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isFileDownloading = false;
      _getOnlyAnonymous = false;
    });

    GetTeachersRequest getTeachersRequest = GetTeachersRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeachersResponse getTeachersResponse = await getTeachers(getTeachersRequest);

    if (getTeachersResponse.httpStatus == "OK" && getTeachersResponse.responseStatus == "success") {
      setState(() {
        _teachersList = getTeachersResponse.teachers!;
        _selectedTeacherIds = [];
      });
    }

    currentMonth = DateTime.now().month - 1;
    currentYear = DateTime.now().year;
    monthYears = MONTHS.sublist(currentMonth - 1).map((e) => "${e.toLowerCase().capitalize()}, ${currentYear - 1}").toList() +
        MONTHS.sublist(0, currentMonth + 1).map((e) => "${e.toLowerCase().capitalize().substring(0, 3)}, $currentYear").toList();
    currentMonthYearIndex = monthYears.length - 1;
    _selectedMonthYearIndex = currentMonthYearIndex;

    reportName = "TeacherLogBook${DateTime.now().millisecondsSinceEpoch}.xlsx";

    setState(() {
      _isLoading = false;
    });
  }

  Widget _getDateFiltersWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: MediaQuery.of(context).orientation == Orientation.landscape
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: radioListTileForDateSelectionType(DateSelectionType.date),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  flex: 1,
                  child: radioListTileForDateSelectionType(DateSelectionType.month),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  flex: 1,
                  child: radioListTileForDateSelectionType(DateSelectionType.year),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: radioListTileForDateSelectionType(DateSelectionType.date),
                ),
                const SizedBox(
                  width: 15,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: radioListTileForDateSelectionType(DateSelectionType.month),
                ),
                const SizedBox(
                  width: 15,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: radioListTileForDateSelectionType(DateSelectionType.year),
                ),
              ],
            ),
    );
  }

  Widget radioListTileForDateSelectionType(DateSelectionType dateSelectionType) {
    return Center(
      child: RadioListTile<DateSelectionType>(
        value: dateSelectionType,
        groupValue: _dateSelectionType,
        onChanged: (DateSelectionType? value) {
          if (value == null) return;
          setState(() => _dateSelectionType = value);
        },
        title: Text(dateSelectionType == DateSelectionType.date
            ? "By Date"
            : dateSelectionType == DateSelectionType.month
                ? "By Month"
                : "Academic Year"),
      ),
    );
  }

  Widget _startDateAndEndDatePicker() {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Expanded(
          flex: 1,
          child: _getStartDatePicker(),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          flex: 1,
          child: _getEndDatePicker(),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _getStartDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: _startDate == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(_startDate!),
            firstDate: DateTime.now().subtract(const Duration(days: 2 * 365)),
            lastDate: DateTime.now(),
            helpText: "Pick start date",
          );
          if (_newDate == null || _newDate.millisecondsSinceEpoch == _startDate) return;
          setState(() {
            _startDate = _newDate.millisecondsSinceEpoch;
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _startDate == null
                    ? "Start Date: -"
                    : "Start Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(_startDate!))}",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getEndDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () async {
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: _endDate == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(_endDate!),
            firstDate: DateTime(2021),
            lastDate: DateTime(2023),
            helpText: "Pick end date",
          );
          if (_newDate == null || _newDate.millisecondsSinceEpoch == _endDate) return;
          setState(() {
            _endDate = _newDate.millisecondsSinceEpoch;
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _endDate == null ? "End Date: -" : "End Date: ${convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(_endDate!))}",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _monthPicker() {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 21),
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: DropdownButton(
              value: _selectedMonthYearIndex != null ? monthYears[_selectedMonthYearIndex!] : monthYears[currentMonthYearIndex],
              items: monthYears.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (String? selectedE) {
                if (selectedE == null) return;
                setState(() {
                  _selectedMonthYearIndex = monthYears.indexWhere((e) => selectedE == e);
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchableDropdownButtonForTeacher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 21),
      child: ClayButton(
        depth: 40,
        color: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
          child: InputDecorator(
            decoration: const InputDecoration(
              label: Text(
                "Selected teachers",
              ),
              border: InputBorder.none,
            ),
            child: DropdownSearch<Teacher>.multiSelection(
              mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
              items: _teachersList,
              selectedItems: _teachersList.where((e) => _selectedTeacherIds.contains(e.teacherId)).toList()
                ..sort((a, b) => (a.teacherName ?? "").compareTo((b.teacherName ?? ""))),
              itemAsString: (Teacher? teacher) {
                return teacher == null ? "" : teacher.teacherName ?? "";
              },
              showSearchBox: true,
              dropdownBuilder: (BuildContext context, List<Teacher>? teachers) {
                return Column(children: (teachers ?? []).map((e) => _buildTeacherWidget(e)).toList());
              },
              showClearButton: true,
              compareFn: (item, selectedItem) => item?.teacherId == selectedItem?.teacherId,
              dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
              filterFn: (Teacher? teacher, String? key) {
                return teacher!.teacherName!.toLowerCase().contains(key!.toLowerCase());
              },
              onChanged: (List<Teacher> selectedTeachers) {
                setState(() {
                  _selectedTeacherIds = selectedTeachers.map((e) => e.teacherId).where((e) => e != null).map((e) => e!).toSet().toList();
                });
              },
            ),
          ),
        ),
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

  Widget _proceedToGenerateSheetButton() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            _isFileDownloading = true;
          });
          if (_dateSelectionType == DateSelectionType.year) {
            _startDate = null;
            _endDate = null;
          } else if (_dateSelectionType == DateSelectionType.month) {
            DateTime startDateTime = DateTime(int.parse(monthYears[_selectedMonthYearIndex!].split(", ")[1]),
                MONTHS.indexWhere((e) => e.substring(0, 3) == monthYears[_selectedMonthYearIndex!].split(", ")[0].toUpperCase()) + 1, 1);
            DateTime endDateTime = DateTime(startDateTime.year, startDateTime.month + 1, 1);
            _startDate = startDateTime.millisecondsSinceEpoch + 5 * 60 * 60 * 1000 + 30 * 60 * 1000;
            _endDate = endDateTime.millisecondsSinceEpoch + 5 * 60 * 60 * 1000 + 30 * 60 * 1000;
          }

          List<int> bytes = await getLogBookReport(GetLogBookRequest(
            schoolId: widget.adminProfile.schoolId,
            startDate: _startDate,
            endDate: _endDate,
            teacherIds: _selectedTeacherIds,
          ));
          AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
            ..setAttribute("download", reportName)
            ..click();
          setState(() {
            reportName = "TeacherLogBook${DateTime.now().millisecondsSinceEpoch}.xlsx";
            _isFileDownloading = false;
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Download",
              ),
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
        title: const Text("Teacher Log Book Stats"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
        ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : _isFileDownloading
              ? Column(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: Text("Report download in progress"),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        'assets/images/eis_loader.gif',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(reportName),
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    _searchableDropdownButtonForTeacher(),
                    const SizedBox(
                      height: 15,
                    ),
                    _getDateFiltersWidget(),
                    const SizedBox(
                      height: 15,
                    ),
                    if (_dateSelectionType == DateSelectionType.date) _startDateAndEndDatePicker(),
                    if (_dateSelectionType == DateSelectionType.month) _monthPicker(),
                    if ((_dateSelectionType == DateSelectionType.date ? (_startDate != null && _endDate != null) : false) ||
                        (_dateSelectionType == DateSelectionType.month ? (_selectedMonthYearIndex != null) : false) ||
                        (_dateSelectionType == DateSelectionType.year))
                      const SizedBox(
                        height: 15,
                      ),
                    if ((_dateSelectionType == DateSelectionType.date ? (_startDate != null && _endDate != null) : false) ||
                        (_dateSelectionType == DateSelectionType.month ? (_selectedMonthYearIndex != null) : false) ||
                        (_dateSelectionType == DateSelectionType.year))
                      _proceedToGenerateSheetButton()
                  ],
                ),
    );
  }
}
