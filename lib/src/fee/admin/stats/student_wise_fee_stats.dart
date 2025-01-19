import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

import 'custom_pager.dart';
import 'student_wise_fee_stats_data_source.dart';

class StudentWiseFeeStats extends StatefulWidget {
  const StudentWiseFeeStats({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<StudentWiseFeeStats> createState() => _StudentWiseFeeStatsState();
}

class _StudentWiseFeeStatsState extends State<StudentWiseFeeStats> {
  bool _isLoading = true;
  bool _showFilter = false;
  bool _isBusFeeApplicable = false;

  List<Section> sections = [];
  List<Section> selectedSectionsList = [];
  bool _isSectionPickerOpen = false;
  final Set<String> _selectedAccommodationTypes = {"D", "R", "S"}; // "D" - Day Scholars, "R" - Residential, "S" - Semi Residential
  Map<String, bool> selectedFeeTypeKeysMap = {};
  Map<String, String> selectedFeeTypeValueMap = {};
  Set<String> selectedFeeKinds = {"fee", "collected", "due"};
  bool applyBusFilter = false;
  Map<int, Map<int, bool>> selectedRouteStopMap = {};
  Map<int, bool> routeExpandedMap = {};
  Map<int, String> routeNamesMap = {};
  Map<int, String> stopNamesMap = {};

  List<FeeType> feeTypes = [];
  List<StudentProfile> studentProfiles = [];
  List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];

  Map<String, String> feeTypeHeaderMap = {};
  Map<String, String> feeTypeValueMapForOverallStats = {};
  Map<String, double> feeTypeTotalFeeMapForOverallStats = {};
  Map<String, double> feeTypeTotalCollectedMapForOverallStats = {};
  Map<String, double> feeTypeTotalDueMapForOverallStats = {};
  ScrollController statsHorizontalScrollController = ScrollController();

  final PaginatorController _controller = PaginatorController();
  int? selectedIndex;
  bool areColumnsFrozen = false;
  bool _showStats = false;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student wise Fee Stats"),
        actions: _isLoading ? [] : [],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : _showStats
              ? statsWidget()
              : _showFilter
                  ? filtersWidget()
                  : newTable(),
      // floatingActionButton: _showFilter ? applyUnapplyFiltersRow() : null,
    );
  }

  Widget statsWidget() {
    return ListView(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 5,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Stats for applied filters"),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              child: ClayButton(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 100,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(Icons.close),
                  ),
                ),
              ),
              onTap: () => setState(() => _showStats = false),
            ),
            const SizedBox(width: 8),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClayContainer(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 8,
                controller: statsHorizontalScrollController,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: statsHorizontalScrollController,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: ["", "Fee", "Collected", "Due"]
                          .map(
                            (e) => DataColumn(
                              label: Text(e),
                            ),
                          )
                          .toList(),
                      rows: [
                        ...feeTypeValueMapForOverallStats.keys.map(
                          (e) => DataRow(
                            cells: [
                              feeTypeValueMapForOverallStats[e] ?? "-",
                              "$INR_SYMBOL ${doubleToStringAsFixedForINR((feeTypeTotalFeeMapForOverallStats[e] ?? 0))}",
                              "$INR_SYMBOL ${doubleToStringAsFixedForINR((feeTypeTotalCollectedMapForOverallStats[e] ?? 0))}",
                              "$INR_SYMBOL ${doubleToStringAsFixedForINR((feeTypeTotalDueMapForOverallStats[e] ?? 0))}"
                            ]
                                .map(
                                  (e) => DataCell(
                                    FittedBox(fit: BoxFit.scaleDown, child: Text(e)),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget filtersWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          _sectionPicker(),
          const SizedBox(height: 8),
          _accommodationTypeFilter(),
          const SizedBox(height: 8),
          _feeTypeFilter(),
          const SizedBox(height: 8),
          _busWiseFilter(),
          const SizedBox(height: 8),
          applyUnapplyFiltersRow(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _busWiseFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: applyBusFilter,
                onChanged: (bool? newSelection) {
                  setState(() => applyBusFilter = newSelection ?? false);
                },
                title: const Text("Filter by Bus"),
                secondary: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedRouteStopMap.keys.forEach((eachRouteId) =>
                            selectedRouteStopMap[eachRouteId]?.keys.forEach((eachStopId) => selectedRouteStopMap[eachRouteId]![eachStopId] = true))),
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
                        onTap: () => setState(() => selectedRouteStopMap.keys.forEach((eachRouteId) =>
                            selectedRouteStopMap[eachRouteId]?.keys.forEach((eachStopId) => selectedRouteStopMap[eachRouteId]![eachStopId] = false))),
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
              ),
              ...routeNamesMap.keys
                  .map(
                    (eachRouteId) => [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 2, 2, 2),
                        child: CheckboxListTile(
                          secondary: IconButton(
                            icon: (routeExpandedMap[eachRouteId] ?? false) ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
                            onPressed: () => setState(
                              () => routeExpandedMap[eachRouteId] = !(routeExpandedMap[eachRouteId] ?? false),
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(routeNamesMap[eachRouteId]!),
                          value: !selectedRouteStopMap[eachRouteId]!.values.contains(false),
                          enabled: applyBusFilter,
                          onChanged: (bool? newSelection) => setState(() {
                            Map<int, bool> stopMap = selectedRouteStopMap[eachRouteId]!;
                            for (int eachStopKey in stopMap.keys) {
                              stopMap[eachStopKey] = newSelection ?? false;
                            }
                          }),
                        ),
                      ),
                      if (routeExpandedMap[eachRouteId] ?? false)
                        ...selectedRouteStopMap[eachRouteId]!.keys.map(
                              (eachStopId) => Padding(
                                padding: const EdgeInsets.fromLTRB(20, 2, 2, 2),
                                child: CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: Text(stopNamesMap[eachStopId]!),
                                  value: selectedRouteStopMap[eachRouteId]![eachStopId] ?? false,
                                  enabled: applyBusFilter,
                                  onChanged: (bool? newSelection) => setState(() {
                                    selectedRouteStopMap[eachRouteId]![eachStopId] = newSelection ?? false;
                                  }),
                                ),
                              ),
                            ),
                    ],
                  )
                  .expand((i) => i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feeTypeFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Filter by fee types"),
              ),
              ...selectedFeeTypeValueMap.keys.map(
                (e) => Padding(
                  padding: const EdgeInsets.all(2),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(selectedFeeTypeValueMap[e] ?? " - "),
                    value: selectedFeeTypeKeysMap[e] ?? false,
                    onChanged: (bool? newSelection) => setState(() => selectedFeeTypeKeysMap[e] = newSelection ?? false),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Filter by kind"),
              ),
              Row(
                children: [
                  ...["fee", "collected", "due"].map(
                    (e) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(e.capitalize()),
                          value: selectedFeeKinds.contains(e),
                          onChanged: (bool? newSelection) =>
                              setState(() => newSelection ?? false ? selectedFeeKinds.add(e) : selectedFeeKinds.remove(e)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accommodationTypeFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        emboss: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Filter by accommodation"),
              ),
              ...["D", "R", "S"].map(
                (e) => Padding(
                  padding: const EdgeInsets.all(2),
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(StudentProfile().getAccommodationType(e: e)),
                    value: _selectedAccommodationTypes.contains(e),
                    onChanged: (bool? newSelection) =>
                        setState(() => newSelection ?? false ? _selectedAccommodationTypes.add(e) : _selectedAccommodationTypes.remove(e)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget applyUnapplyFiltersRow() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.end,
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            generateSectionMap();
            setState(() => _showFilter = false);
          },
          child: ClayButton(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      Icons.filter_list,
                      size: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Apply Filters",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() {
            _showFilter = false;
            _showStats = false;
          }),
          child: ClayButton(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 5,
            child: Container(
              width: 75,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      Icons.filter_list,
                      size: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Cancel",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget newTable() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 36),
          child: PaginatedDataTable2(
            header: tableHeader(),
            controller: _controller,
            hidePaginator: true,
            smRatio: 0.5,
            lmRatio: 2,
            horizontalMargin: 0,
            columnSpacing: 20,
            wrapInCard: false,
            renderEmptyRowsInTheEnd: true,
            fixedLeftColumns: areColumnsFrozen ? 2 : 0,
            fixedTopRows: 1,
            minWidth: 2400,
            dataRowHeight: 30,
            fit: FlexFit.loose,
            autoRowsToHeight: true,
            border: tableBorder(),
            empty: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Text('No data'),
              ),
            ),
            columns: getTableColumns(),
            source: getStudentsDataSource(),
          ),
        ),
        Positioned(
          bottom: 0,
          child: CustomPager(_controller),
        ),
      ],
    );
  }

  StudentRowDataSource getStudentsDataSource() {
    return StudentRowDataSource(
      context,
      studentAnnualFeeBeans.map((eachStudentAnnualFeeBean) {
        StudentProfile? eachStudent = studentProfiles.firstWhereOrNull((es) => eachStudentAnnualFeeBean.studentId == es.studentId);
        Map<String, String> studentMap = {};
        studentMap["Section"] = eachStudentAnnualFeeBean.sectionName ?? "-";
        studentMap["Student Name"] = "${eachStudentAnnualFeeBean.rollNumber ?? "-"}. ${eachStudentAnnualFeeBean.studentName ?? " - "}";
        for (String eachKey in feeTypeHeaderMap.keys) {
          int? feeTypeId = int.tryParse(eachKey.split("|")[0]);
          int? customFeeTypeId = int.tryParse(eachKey.split("|")[1]);
          String kind = eachKey.split("|")[2];
          studentMap[eachKey] = getStudentFeeDetail(eachStudentAnnualFeeBean, feeTypeId, customFeeTypeId, kind);
        }
        return StudentWiseFeeStatsMap(eachStudent, studentMap, eachStudentAnnualFeeBean.studentBusFeeBean);
      }).toList(),
      (int index) => setState(() => selectedIndex == index ? selectedIndex = null : selectedIndex = index),
      selectedIndex,
      false,
      true,
    );
  }

  List<DataColumn2> getTableColumns() {
    return [
      "Section",
      "Student Name",
      ...feeTypeHeaderMap.values,
    ]
        .mapIndexed(
          (i, e) => DataColumn2(
            size: i == 0
                ? ColumnSize.S
                : i == 1
                    ? ColumnSize.L
                    : ColumnSize.M,
            label: Padding(
              padding: const EdgeInsets.all(4.0),
              child: i == 1
                  ? Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                e,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.push_pin,
                            color: areColumnsFrozen ? Colors.blue : Colors.grey,
                            size: 12,
                          ),
                          onPressed: () => setState(() => areColumnsFrozen = !areColumnsFrozen),
                        ),
                      ],
                    )
                  : Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          e,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
            ),
          ),
        )
        .toList();
  }

  TableBorder tableBorder() {
    return const TableBorder(
      top: BorderSide(color: Colors.grey, width: 1),
      bottom: BorderSide(color: Colors.grey, width: 1),
      left: BorderSide(color: Colors.grey, width: 1),
      right: BorderSide(color: Colors.grey, width: 1),
      verticalInside: BorderSide(color: Colors.grey, width: 1),
      horizontalInside: BorderSide(color: Colors.grey, width: 1),
    );
  }

  Widget tableHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showFilter = true),
          child: ClayButton(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      Icons.filter_list,
                      size: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Filter",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showStats = true),
            child: ClayButton(
              depth: 40,
              surfaceColor: clayContainerColor(context),
              parentColor: clayContainerColor(context),
              spread: 1,
              borderRadius: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        "Student Fee Stats",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.info_outline, size: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getStudentFeeDetail(StudentAnnualFeeBean eachStudent, int? feeTypeId, int? customFeeTypeId, String kind) {
    double amount = 0.0;
    if (feeTypeId == -2 && customFeeTypeId == -2) {
      switch (kind) {
        case "fee":
          amount = (eachStudent.totalFee ?? 0) / 100.0;
          break;
        case "collected":
          amount = (eachStudent.totalFeePaid ?? 0) / 100.0;
          break;
        case "due":
          amount = ((eachStudent.totalFee ?? 0) - (eachStudent.totalFeePaid ?? 0)) / 100.0;
          break;
      }
    } else if (feeTypeId == null && customFeeTypeId == null) {
      switch (kind) {
        case "fee":
          amount = (eachStudent.studentBusFeeBean?.fare ?? 0) / 100.0;
          break;
        case "collected":
          amount = (eachStudent.studentBusFeeBean?.feePaid ?? 0) / 100.0;
          break;
        case "due":
          amount = ((eachStudent.studentBusFeeBean?.fare ?? 0) - (eachStudent.studentBusFeeBean?.feePaid ?? 0)) / 100.0;
          break;
      }
    } else if (customFeeTypeId == null) {
      StudentAnnualFeeTypeBean? annualFeeTypeBean = (eachStudent.studentAnnualFeeTypeBeans ?? [])
          .firstWhereOrNull((eft) => eft.feeTypeId == feeTypeId && (eft.studentAnnualCustomFeeTypeBeans ?? []).isEmpty);
      int fee = annualFeeTypeBean?.amount ?? 0;
      int feeCollected = annualFeeTypeBean?.amountPaid ?? 0;
      int due = fee - feeCollected;
      switch (kind) {
        case "fee":
          amount = fee / 100.0;
          break;
        case "collected":
          amount = feeCollected / 100.0;
          break;
        case "due":
          amount = due / 100.0;
          break;
      }
    } else {
      StudentAnnualFeeTypeBean? annualFeeTypeBean = (eachStudent.studentAnnualFeeTypeBeans ?? [])
          .firstWhereOrNull((eft) => eft.feeTypeId == feeTypeId && (eft.studentAnnualCustomFeeTypeBeans ?? []).isNotEmpty);
      StudentAnnualCustomFeeTypeBean? annualCustomFeeTypeBean =
          (annualFeeTypeBean?.studentAnnualCustomFeeTypeBeans ?? []).firstWhereOrNull((ect) => ect.customFeeTypeId == customFeeTypeId);
      int fee = annualCustomFeeTypeBean?.amount ?? 0;
      int feeCollected = annualCustomFeeTypeBean?.amountPaid ?? 0;
      int due = fee - feeCollected;
      switch (kind) {
        case "fee":
          amount = fee / 100.0;
          break;
        case "collected":
          amount = feeCollected / 100.0;
          break;
        case "due":
          amount = due / 100.0;
          break;
      }
    }
    return "$INR_SYMBOL ${doubleToStringAsFixedForINR(amount)}";
  }

  Widget clayCell({
    Widget? child,
    EdgeInsetsGeometry? margin = const EdgeInsets.all(4),
    EdgeInsetsGeometry? padding = const EdgeInsets.all(8),
    bool emboss = false,
    double height = double.infinity,
    double width = double.infinity,
  }) {
    return Container(
      margin: margin,
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: emboss,
        child: Container(
          padding: padding,
          height: height,
          width: width,
          child: child,
        ),
      ),
    );
  }

  void filterStudents() {
    String? selectedStudentStatus = 'active';
    studentAnnualFeeBeans.removeWhere((e) {
      StudentProfile eachStudent = studentProfiles.firstWhere((es) => es.studentId == e.studentId);
      bool studentsStatusFilter = e.status == selectedStudentStatus;
      bool selectedSectionStatus = selectedSectionsList.map((e) => e.sectionId).contains(e.sectionId);
      bool accommodationTypeFilter = _selectedAccommodationTypes.contains(eachStudent.studentAccommodationType);
      bool busStopFilter = applyBusFilter ? (selectedRouteStopMap[e.studentBusFeeBean?.routeId]?[e.studentBusFeeBean?.stopId] ?? false) : true;
      bool result = studentsStatusFilter && selectedSectionStatus && accommodationTypeFilter && busStopFilter;
      return !result;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      sections = getSectionsResponse.sections!.map((e) => e!).toList();
      selectedSectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
    }
    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getFeeTypesResponse.httpStatus != "OK" || getFeeTypesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
      selectedFeeTypeKeysMap = {};
      for (FeeType eachFeeType in feeTypes) {
        if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
          selectedFeeTypeKeysMap[feeTypeKey(eachFeeType.feeTypeId, null)] = true;
          selectedFeeTypeValueMap[feeTypeKey(eachFeeType.feeTypeId, null)] = eachFeeType.feeType ?? " - ";
        } else {
          for (CustomFeeType eachCustomFeeType in eachFeeType.customFeeTypesList!.whereNotNull()) {
            selectedFeeTypeKeysMap[feeTypeKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] = true;
            selectedFeeTypeValueMap[feeTypeKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] =
                "${eachFeeType.feeType ?? " - "} - ${eachCustomFeeType.customFeeType ?? " - "}";
          }
        }
      }
      selectedFeeTypeKeysMap[feeTypeKey(null, null)] = true;
      selectedFeeTypeValueMap[feeTypeKey(null, null)] = "Bus";
    }
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.adminProfile.schoolId,
      // studentId: 101,
    ));
    if (getStudentWiseAnnualFeesResponse.httpStatus != "OK" || getStudentWiseAnnualFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentWiseAnnualFeesBeans = getStudentWiseAnnualFeesResponse.studentWiseAnnualFeesBeanList!.map((e) => e!).toList();
      studentWiseAnnualFeesBeans.sort((a, b) => ((int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))));
      studentWiseAnnualFeesBeans.map((e) => e.studentBusFeeBean).whereNotNull().forEach((eachStudentBusBean) {
        if (eachStudentBusBean.routeId != null) {
          selectedRouteStopMap[eachStudentBusBean.routeId!] ??= {};
          routeExpandedMap[eachStudentBusBean.routeId!] = false;
          routeNamesMap[eachStudentBusBean.routeId!] = eachStudentBusBean.routeName ?? " - ";
          if (eachStudentBusBean.stopId != null) {
            selectedRouteStopMap[eachStudentBusBean.routeId!]![eachStudentBusBean.stopId!] = true;
            stopNamesMap[eachStudentBusBean.stopId!] = eachStudentBusBean.stopName ?? " - ";
          }
        }
      });
    }
    generateSectionMap();
    setState(() => _isLoading = false);
  }

  void generateSectionMap() {
    setState(() => _isLoading = true);
    studentAnnualFeeBeans = [];
    for (StudentWiseAnnualFeesBean eachAnnualFeeBean in studentWiseAnnualFeesBeans) {
      studentAnnualFeeBeans.add(
        StudentAnnualFeeBean(
          studentId: eachAnnualFeeBean.studentId,
          rollNumber: eachAnnualFeeBean.rollNumber,
          studentName: eachAnnualFeeBean.studentName,
          totalFee: eachAnnualFeeBean.actualFee,
          totalFeePaid: eachAnnualFeeBean.feePaid,
          walletBalance: eachAnnualFeeBean.studentWalletBalance,
          sectionId: eachAnnualFeeBean.sectionId,
          sectionName: eachAnnualFeeBean.sectionName,
          status: eachAnnualFeeBean.status,
          studentBusFeeBean: eachAnnualFeeBean.studentBusFeeBean ??
              StudentBusFeeBean(
                schoolId: widget.adminProfile.schoolId,
                studentId: eachAnnualFeeBean.studentId,
              ),
          studentAnnualFeeTypeBeans: feeTypes
              .map(
                (eachFeeType) => StudentAnnualFeeTypeBean(
                  feeTypeId: eachFeeType.feeTypeId,
                  feeType: eachFeeType.feeType,
                  studentFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                      .map((e) => e!)
                      .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                          eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                      .firstOrNull
                      ?.studentFeeMapId,
                  sectionFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                      .map((e) => e!)
                      .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                          eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                      .firstOrNull
                      ?.sectionFeeMapId,
                  amount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                      .map((e) => e!)
                      .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                          eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                      .firstOrNull
                      ?.amount,
                  amountPaid: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                      .map((e) => e!)
                      .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                          eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                      .firstOrNull
                      ?.amountPaid,
                  studentAnnualCustomFeeTypeBeans: (eachFeeType.customFeeTypesList ?? [])
                      .where((eachCustomFeeType) => eachCustomFeeType != null)
                      .map((eachCustomFeeType) => eachCustomFeeType!)
                      .map(
                        (eachCustomFeeType) => StudentAnnualCustomFeeTypeBean(
                          customFeeTypeId: eachCustomFeeType.customFeeTypeId,
                          customFeeType: eachCustomFeeType.customFeeType,
                          studentFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                              .map((e) => e!)
                              .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                  eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                  eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                              .firstOrNull
                              ?.studentFeeMapId,
                          sectionFeeMapId: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                              .map((e) => e!)
                              .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                  eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                  eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                              .firstOrNull
                              ?.sectionFeeMapId,
                          amount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                              .map((e) => e!)
                              .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                  eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                  eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                              .firstOrNull
                              ?.amount,
                          amountPaid: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                              .map((e) => e!)
                              .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                  eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                  eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                              .firstOrNull
                              ?.amountPaid,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      );
    }
    filterStudents();
    // studentAnnualFeeBeans = studentAnnualFeeBeans.where((e) => e.status != "inactive").toList();
    studentAnnualFeeBeans.sort(
      (a, b) {
        int aSectionSeqOrder = sections.firstWhere((e) => e.sectionId == a.sectionId).seqOrder ?? 0;
        int bSectionSeqOrder = sections.firstWhere((e) => e.sectionId == b.sectionId).seqOrder ?? 0;
        if (aSectionSeqOrder.compareTo(bSectionSeqOrder) != 0) return aSectionSeqOrder.compareTo(bSectionSeqOrder);
        int aRollNo = int.tryParse(a.rollNumber ?? "") ?? 0;
        int bRollNo = int.tryParse(b.rollNumber ?? "") ?? 0;
        return aRollNo.compareTo(bRollNo);
      },
    );
    feeTypeHeaderMap = {};
    _isBusFeeApplicable = (studentAnnualFeeBeans.map((e) => e.studentBusFeeBean?.fare ?? 0).fold(0, (int? a, b) => (a ?? 0) + b)) > 0;
    for (FeeType eachFeeType in feeTypes) {
      if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
        String eachFeeTypeKey = feeTypeKey(eachFeeType.feeTypeId, null);
        if (selectedFeeTypeKeysMap[eachFeeTypeKey] ?? false) {
          if (selectedFeeKinds.contains("fee")) {
            feeTypeHeaderMap[feeKey(eachFeeType.feeTypeId, null)] = eachFeeType.feeType ?? "-";
          }
          if (selectedFeeKinds.contains("collected")) {
            feeTypeHeaderMap[collectedKey(eachFeeType.feeTypeId, null)] = "${eachFeeType.feeType ?? " - "}\nCollected";
          }
          if (selectedFeeKinds.contains("due")) {
            feeTypeHeaderMap[dueKey(eachFeeType.feeTypeId, null)] = "${eachFeeType.feeType ?? " - "}\nDue";
          }
        }
      } else {
        for (CustomFeeType eachCustomFeeType in (eachFeeType.customFeeTypesList ?? []).whereNotNull()) {
          String eachCustomFeeTypeKey = feeTypeKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId);
          if (selectedFeeTypeKeysMap[eachCustomFeeTypeKey] ?? false) {
            if (selectedFeeKinds.contains("fee")) {
              feeTypeHeaderMap[feeKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] =
                  "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}";
            }
            if (selectedFeeKinds.contains("collected")) {
              feeTypeHeaderMap[collectedKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] =
                  "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}\nCollected";
            }
            if (selectedFeeKinds.contains("due")) {
              feeTypeHeaderMap[dueKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] =
                  "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}\nDue";
            }
          }
        }
      }
    }
    if (_isBusFeeApplicable && (selectedFeeTypeKeysMap[feeTypeKey(null, null)] ?? false)) {
      if (selectedFeeKinds.contains("fee")) {
        feeTypeHeaderMap[feeKey(null, null)] = "Bus Fee";
      }
      if (selectedFeeKinds.contains("collected")) {
        feeTypeHeaderMap[collectedKey(null, null)] = "Bus Fee\nCollected";
      }
      if (selectedFeeKinds.contains("due")) {
        feeTypeHeaderMap[dueKey(null, null)] = "Bus Fee\nDue";
      }
    }
    if (selectedFeeKinds.contains("fee")) {
      feeTypeHeaderMap[totalFeeKey()] = "Total\nFee";
    }
    if (selectedFeeKinds.contains("collected")) {
      feeTypeHeaderMap[totalFeeCollectedKey()] = "Total\nCollected";
    }
    if (selectedFeeKinds.contains("due")) {
      feeTypeHeaderMap[totalFeeDueKey()] = "Total\nDue";
    }
    refreshStatsMap();
    setState(() => _isLoading = false);
  }

  void refreshStatsMap() {
    feeTypeValueMapForOverallStats.clear();
    feeTypeTotalFeeMapForOverallStats.clear();
    feeTypeTotalCollectedMapForOverallStats.clear();
    feeTypeTotalDueMapForOverallStats.clear();
    for (FeeType eachFeeType in feeTypes) {
      if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
        feeTypeValueMapForOverallStats["${eachFeeType.feeTypeId}|-"] = eachFeeType.feeType ?? "-";
      } else {
        for (CustomFeeType eachCustomFeeType in (eachFeeType.customFeeTypesList ?? []).whereNotNull()) {
          feeTypeValueMapForOverallStats["${eachFeeType.feeTypeId}|${eachCustomFeeType.customFeeTypeId}"] =
              "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}";
        }
      }
    }
    if (_isBusFeeApplicable) {
      feeTypeValueMapForOverallStats["-|-"] = "Bus";
    }
    feeTypeValueMapForOverallStats["-2|-2"] = "Total";
    for (StudentAnnualFeeBean eachStudent in studentAnnualFeeBeans) {
      for (String eachKey in feeTypeValueMapForOverallStats.keys) {
        int? feeTypeId = int.tryParse(eachKey.split("|")[0]);
        int? customFeeTypeId = int.tryParse(eachKey.split("|")[1]);
        if (feeTypeId == -2 && customFeeTypeId == -2) {
          double totalFee = (eachStudent.totalFee ?? 0) / 100.0;
          double totalFeeCollected = (eachStudent.totalFeePaid ?? 0) / 100.0;
          double totalFeeDue = totalFee = totalFeeCollected;
          feeTypeTotalFeeMapForOverallStats[eachKey] = (feeTypeTotalFeeMapForOverallStats[eachKey] ?? 0) + totalFee;
          feeTypeTotalCollectedMapForOverallStats[eachKey] = (feeTypeTotalCollectedMapForOverallStats[eachKey] ?? 0) + totalFeeCollected;
          feeTypeTotalDueMapForOverallStats[eachKey] = (feeTypeTotalDueMapForOverallStats[eachKey] ?? 0) + totalFeeDue;
        } else if (feeTypeId == null && customFeeTypeId == null) {
          double totalFee = (eachStudent.studentBusFeeBean?.fare ?? 0) / 100.0;
          double totalFeeCollected = (eachStudent.studentBusFeeBean?.feePaid ?? 0) / 100.0;
          double totalFeeDue = totalFee = totalFeeCollected;
          feeTypeTotalFeeMapForOverallStats[eachKey] = (feeTypeTotalFeeMapForOverallStats[eachKey] ?? 0) + totalFee;
          feeTypeTotalCollectedMapForOverallStats[eachKey] = (feeTypeTotalCollectedMapForOverallStats[eachKey] ?? 0) + totalFeeCollected;
          feeTypeTotalDueMapForOverallStats[eachKey] = (feeTypeTotalDueMapForOverallStats[eachKey] ?? 0) + totalFeeDue;
        } else if (customFeeTypeId == null) {
          StudentAnnualFeeTypeBean? annualFeeTypeBean = (eachStudent.studentAnnualFeeTypeBeans ?? [])
              .firstWhereOrNull((eft) => eft.feeTypeId == feeTypeId && (eft.studentAnnualCustomFeeTypeBeans ?? []).isEmpty);
          double fee = (annualFeeTypeBean?.amount ?? 0) / 100.0;
          double feeCollected = (annualFeeTypeBean?.amountPaid ?? 0) / 100.0;
          double due = fee - feeCollected;
          feeTypeTotalFeeMapForOverallStats[eachKey] = (feeTypeTotalFeeMapForOverallStats[eachKey] ?? 0) + fee;
          feeTypeTotalCollectedMapForOverallStats[eachKey] = (feeTypeTotalCollectedMapForOverallStats[eachKey] ?? 0) + feeCollected;
          feeTypeTotalDueMapForOverallStats[eachKey] = (feeTypeTotalDueMapForOverallStats[eachKey] ?? 0) + due;
        } else {
          StudentAnnualFeeTypeBean? annualFeeTypeBean = (eachStudent.studentAnnualFeeTypeBeans ?? [])
              .firstWhereOrNull((eft) => eft.feeTypeId == feeTypeId && (eft.studentAnnualCustomFeeTypeBeans ?? []).isNotEmpty);
          StudentAnnualCustomFeeTypeBean? annualCustomFeeTypeBean =
              (annualFeeTypeBean?.studentAnnualCustomFeeTypeBeans ?? []).firstWhereOrNull((ect) => ect.customFeeTypeId == customFeeTypeId);
          double fee = (annualCustomFeeTypeBean?.amount ?? 0) / 100.0;
          double feeCollected = (annualCustomFeeTypeBean?.amountPaid ?? 0) / 100.0;
          double due = fee - feeCollected;
          feeTypeTotalFeeMapForOverallStats[eachKey] = (feeTypeTotalFeeMapForOverallStats[eachKey] ?? 0) + fee;
          feeTypeTotalCollectedMapForOverallStats[eachKey] = (feeTypeTotalCollectedMapForOverallStats[eachKey] ?? 0) + feeCollected;
          feeTypeTotalDueMapForOverallStats[eachKey] = (feeTypeTotalDueMapForOverallStats[eachKey] ?? 0) + due;
        }
      }
    }
  }

  String totalFeeKey() => "-2|-2|fee";

  String totalFeeCollectedKey() => "-2|-2|collected";

  String totalFeeDueKey() => "-2|-2|due";

  String feeTypeKey(int? feeTypeId, int? customFeeTypeId) {
    return feeTypeId == null && customFeeTypeId == null ? "-|-" : "${feeTypeId ?? "-"}|${customFeeTypeId ?? "-"}";
  }

  String feeKey(int? feeTypeId, int? customFeeTypeId) {
    return feeTypeId == null && customFeeTypeId == null ? "-|-|fee" : "${feeTypeId ?? "-"}|${customFeeTypeId ?? "-"}|fee";
  }

  String collectedKey(int? feeTypeId, int? customFeeTypeId) {
    return feeTypeId == null && customFeeTypeId == null ? "-|-|collected" : "${feeTypeId ?? "-"}|${customFeeTypeId ?? "-"}|collected";
  }

  String dueKey(int? feeTypeId, int? customFeeTypeId) {
    return feeTypeId == null && customFeeTypeId == null ? "-|-|due" : "${feeTypeId ?? "-"}|${customFeeTypeId ?? "-"}|due";
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
          });
          // filterStudents();
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
                          : "Selected sections: ${selectedSectionsList.length == sections.length ? "All" : selectedSectionsList.map((e) => e.sectionName ?? "-").join(", ")}",
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
            children: sections.map((e) => _buildSectionCheckBox(e)).toList(),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: GestureDetector(
                  onTap: () => setState(() {
                    selectedSectionsList.clear();
                    selectedSectionsList.addAll(sections.map((e) => e).toList());
                  }),
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
                  onTap: () => setState(() => selectedSectionsList = []),
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
}

class StudentWiseFeeStatsMap {
  StudentProfile? studentProfile;
  Map<String, String> values;
  StudentBusFeeBean? studentBusFeeBean;

  StudentWiseFeeStatsMap(
    this.studentProfile,
    this.values,
    this.studentBusFeeBean,
  );
}
