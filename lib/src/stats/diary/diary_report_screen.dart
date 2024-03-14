import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show AnchorElement;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/diary/model/diary.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/stats/constants/date_selection_type.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class DiaryReportScreen extends StatefulWidget {
  const DiaryReportScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<DiaryReportScreen> createState() => _DiaryReportScreenState();
}

class _DiaryReportScreenState extends State<DiaryReportScreen> {
  bool _isLoading = true;
  bool _isFileDownloading = false;

  List<Section> sectionsList = [];
  List<Section> selectedSectionsList = [];
  bool _isSectionPickerOpen = false;

  DateSelectionType _dateSelectionType = DateSelectionType.date;

  int? _startDate;
  int? _endDate;

  int? _selectedMonthYearIndex;
  late int currentMonthYearIndex;

  late int currentMonth;
  late int currentYear;
  late List<String> monthYears;

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
    });
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);

    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      setState(() {
        sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      });
    }

    currentMonth = DateTime.now().month - 1;
    currentYear = DateTime.now().year;
    monthYears = MONTHS.sublist(currentMonth - 1).map((e) => "${e.toLowerCase().capitalize()}, ${currentYear - 1}").toList() +
        MONTHS.sublist(0, currentMonth + 1).map((e) => "${e.toLowerCase().capitalize().substring(0, 3)}, $currentYear").toList();
    currentMonthYearIndex = monthYears.length - 1;
    _selectedMonthYearIndex = currentMonthYearIndex;

    reportName = "StudentDiaryReport${DateTime.now().millisecondsSinceEpoch}.xlsx";

    setState(() {
      _isLoading = false;
    });
  }

  Widget _sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: _isSectionPickerOpen ? 750 : 500),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: _isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: _selectSectionExpanded(),
                ),
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
            if (selectedSectionsList.map((e) => e.sectionId!).contains(section.sectionId)) {
              selectedSectionsList.removeWhere((e) => e.sectionId == section.sectionId);
            } else {
              selectedSectionsList.add(section);
            }
            // _isSectionPickerOpen = false;
          });
        },
        child: ClayButton(
          depth: 40,
          spread: selectedSectionsList.map((e) => e.sectionId!).contains(section.sectionId) ? 0 : 2,
          surfaceColor:
              selectedSectionsList.map((e) => e.sectionId!).contains(section.sectionId) ? Colors.blue.shade300 : clayContainerColor(context),
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
          InkWell(
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
                      selectedSectionsList.isEmpty
                          ? "Select a section"
                          : "Selected sections: ${selectedSectionsList.map((e) => e.sectionName ?? "-").join(", ")}",
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
            children: sectionsList.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSectionsList.map((e) => e).toList().forEach((e) {
                        selectedSectionsList.remove(e);
                      });
                      selectedSectionsList.addAll(sectionsList.map((e) => e).toList());
                      _isSectionPickerOpen = false;
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Select All"),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSectionsList = [];
                      _isSectionPickerOpen = false;
                    });
                  },
                  child: ClayButton(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 25,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: const Text("Clear"),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          if (_isLoading) return;
          setState(() {
            _isSectionPickerOpen = !_isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      selectedSectionsList.isEmpty
                          ? "Select Section"
                          : "Selected sections: ${selectedSectionsList.map((e) => e.sectionName ?? "-").join(", ")}",
                    ),
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
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

          List<int> bytes = await getDiaryReport(GetDiaryRequest(
            schoolId: widget.adminProfile.schoolId,
            startDate: _startDate == null ? null : convertDateTimeToYYYYMMDDFormat(DateTime.fromMillisecondsSinceEpoch(_startDate!)),
            endDate: _endDate == null ? null : convertDateTimeToYYYYMMDDFormat(DateTime.fromMillisecondsSinceEpoch(_endDate!)),
            sectionIds: selectedSectionsList.map((e) => e.sectionId).where((e) => e != null).map((e) => e!).toList(),
          ));
          AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
            ..setAttribute("download", reportName)
            ..click();
          setState(() {
            reportName = "StudentDiaryReport${DateTime.now().millisecondsSinceEpoch}.xlsx";
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
        title: const Text("Diary Stats"),
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
                    _sectionPicker(),
                    const SizedBox(
                      height: 15,
                    ),
                    if (selectedSectionsList.isNotEmpty) _getDateFiltersWidget(),
                    if (selectedSectionsList.isNotEmpty)
                      const SizedBox(
                        height: 15,
                      ),
                    if (selectedSectionsList.isNotEmpty && _dateSelectionType == DateSelectionType.date) _startDateAndEndDatePicker(),
                    if (selectedSectionsList.isNotEmpty && _dateSelectionType == DateSelectionType.month) _monthPicker(),
                    if (selectedSectionsList.isNotEmpty &&
                        ((_dateSelectionType == DateSelectionType.date ? (_startDate != null && _endDate != null) : false) ||
                            (_dateSelectionType == DateSelectionType.month ? (_selectedMonthYearIndex != null) : false) ||
                            (_dateSelectionType == DateSelectionType.year)))
                      const SizedBox(
                        height: 15,
                      ),
                    if (selectedSectionsList.isNotEmpty &&
                        ((_dateSelectionType == DateSelectionType.date ? (_startDate != null && _endDate != null) : false) ||
                            (_dateSelectionType == DateSelectionType.month ? (_selectedMonthYearIndex != null) : false) ||
                            (_dateSelectionType == DateSelectionType.year)))
                      _proceedToGenerateSheetButton()
                  ],
                ),
    );
  }
}
