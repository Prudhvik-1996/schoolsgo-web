import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class StudentManagementScreenV2 extends StatefulWidget {
  const StudentManagementScreenV2({
    Key? key,
    this.title,
    required this.adminProfile,
    required this.studentProfiles,
    required this.sectionsList,
  }) : super(key: key);

  final String? title;
  final AdminProfile adminProfile;
  final List<StudentProfile> studentProfiles;
  final List<Section> sectionsList;

  @override
  State<StudentManagementScreenV2> createState() => _StudentManagementScreenV2State();
}

class _StudentManagementScreenV2State extends State<StudentManagementScreenV2> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentProfile> studentProfiles = [];
  List<Section> sectionsList = [];

  @override
  void initState() {
    super.initState();
    studentProfiles = widget.studentProfiles;
    sectionsList = widget.sectionsList;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "Student Management"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: StudentProfileGrid(
                studentProfiles: studentProfiles,
                sectionsList: sectionsList,
              ),
            ),
    );
  }
}

class StudentProfileGrid extends StatefulWidget {
  final List<StudentProfile> studentProfiles;
  final List<Section> sectionsList;

  const StudentProfileGrid({
    Key? key,
    required this.studentProfiles,
    required this.sectionsList,
  }) : super(key: key);

  @override
  _StudentProfileGridState createState() => _StudentProfileGridState();
}

class _StudentProfileGridState extends State<StudentProfileGrid> {
  late _StudentProfileDataSource studentProfileDataSource;
  Map<String, double> columnWidths = {
    "Section": 100,
    "Roll No.": 70,
    "Photo": 70,
    "Student Name": 200,
    "Parent Name": 200,
    "Mobile": 120,
    "Sex": 80,
    "Status": 100,
  };
  Section? selectedSection;
  int _rowsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    studentProfileDataSource = _StudentProfileDataSource(
      widget.studentProfiles,
      widget.sectionsList,
      null,
      _rowsPerPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    int studentsLength = widget.studentProfiles.where((e) => selectedSection?.sectionId == null || e.sectionId == selectedSection?.sectionId).length;
    return Column(
      children: [
        Expanded(
          child: SfDataGridTheme(
            data: SfDataGridThemeData(headerColor: Colors.blue),
            child: SfDataGrid(
              verticalScrollController: ScrollController(),
              verticalScrollPhysics: const BouncingScrollPhysics(),
              isScrollbarAlwaysShown: true,
              allowSwiping: true,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              // onFilterChanging: (DataGridFilterChangeDetails details) {
              //   return true;
              // },
              allowFiltering: false,
              // frozenColumnsCount: 2,
              shrinkWrapRows: false,
              source: studentProfileDataSource,
              horizontalScrollPhysics: const NeverScrollableScrollPhysics(),
              allowColumnsResizing: false,
              // allowColumnsResizing: true,
              // onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
              //   setState(() {
              //     columnWidths[details.column.columnName] = details.width;
              //   });
              //   return true;
              // },
              columns: [
                ...columnWidths.keys.map((e) => buildGridColumn(columnName: e)),
              ],
            ),
          ),
        ),
        if (selectedSection == null)
          SizedBox(
            height: 70,
            child: SfDataPager(
              itemHeight: 50,
              delegate: studentProfileDataSource,
              availableRowsPerPage: [
                if (studentsLength >= 5) 5,
                if (studentsLength >= 10) 10,
                if (studentsLength >= 20) 20,
                if (studentsLength >= 50) 50,
                if (studentsLength >= 100) 100,
                studentsLength
              ],
              onRowsPerPageChanged: (int? rowsPerPage) {
                setState(() {
                  _rowsPerPage = rowsPerPage!;
                  studentProfileDataSource.updateRowsPerPage(_rowsPerPage);
                });
              },
              pageCount: ((studentsLength / _rowsPerPage).ceil()).toDouble(),
              direction: Axis.horizontal,
            ),
          ),
      ],
    );
  }

  GridColumn buildGridColumn({
    String columnName = "Date",
    bool softWrap = false,
    Alignment alignment = Alignment.centerLeft,
  }) {
    if (columnName == "Section") {
      return GridColumn(
        width: columnWidth(columnName),
        allowFiltering: false,
        autoFitPadding: const EdgeInsets.all(10.0),
        label: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(10.0),
          child: DropdownButton<Section?>(
            hint: const Center(child: Text("Select Section")),
            underline: Container(),
            isExpanded: true,
            value: selectedSection,
            onChanged: (Section? section) {
              studentProfileDataSource.refreshDataGrid(refreshSelectedSection: section);
              setState(() {
                selectedSection = section;
              });
            },
            items: [null, ...widget.sectionsList]
                .map(
                  (e) => DropdownMenuItem<Section?>(
                    value: e,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            e?.sectionName ?? "Section",
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
          ),
        ),
        columnName: columnName,
      );
    }
    return GridColumn(
      filterIconPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      filterPopupMenuOptions: const FilterPopupMenuOptions(
        filterMode: FilterMode.checkboxFilter,
        canShowSortingOptions: false,
        canShowClearFilterOption: false,
      ),
      width: columnWidth(columnName),
      autoFitPadding: const EdgeInsets.all(10.0),
      label: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(10.0),
        child: Text(
          columnName,
          softWrap: false,
        ),
      ),
      columnName: columnName,
      allowFiltering: columnName != "Photo",
    );
  }

  double columnWidth(String columnName) => columnWidths[columnName]!;
}

class _StudentProfileDataSource extends DataGridSource {
  _StudentProfileDataSource(
    this.studentProfiles,
    this.sections,
    this.selectedSection,
    this.rowsPerPage,
  ) {
    refreshDataGrid(refreshSelectedSection: selectedSection);
  }

  void refreshDataGrid({Section? refreshSelectedSection}) {
    selectedSection = refreshSelectedSection;
    rowsSource = studentProfiles
        .where((e) => selectedSection?.sectionId == null || e.sectionId == selectedSection?.sectionId)
        .map((StudentProfile eachStudent) {
      return StudentProfileDataSourceBean(
        eachStudent.sectionId,
        eachStudent.sectionName,
        int.tryParse(eachStudent.rollNumber ?? ""),
        eachStudent.studentPhotoUrl,
        eachStudent.studentFirstName,
        eachStudent.gaurdianFirstName,
        eachStudent.gaurdianMobile,
        eachStudent.sex,
        eachStudent.status,
        null,
      );
    }).toList();
    if (selectedSection != null) {
      rowsPerPage = rowsSource.length;
    }
    _paginatedSource = rowsSource.getRange(0, min(rowsSource.length, rowsPerPage)).toList(growable: false); // range error fix
    handlePageChange(0, 0);
    buildPaginatedDataGridRows();
  }

  final List<StudentProfile> studentProfiles;
  final List<Section> sections;
  Section? selectedSection;
  int rowsPerPage;

  List<StudentProfileDataSourceBean> _paginatedSource = [];
  List<StudentProfileDataSourceBean> rowsSource = [];

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row
          .getCells()
          .map<Widget>(
            (DataGridCell dataGridCell) => Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10.0),
              child: buildDataGridCell(dataGridCell, row),
            ),
          )
          .toList(),
    );
  }

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    final String? value1 = a?.getCells().firstWhereOrNull((element) => element.columnName == "Section")?.value;
    final String? value2 = b?.getCells().firstWhereOrNull((element) => element.columnName == "Section")?.value;
    final int rollNumber1 = int.tryParse(a?.getCells().firstWhereOrNull((element) => element.columnName == "Roll No.")?.value ?? "") ?? 0;
    final int rollNumber2 = int.tryParse(b?.getCells().firstWhereOrNull((element) => element.columnName == "Roll No.")?.value ?? "") ?? 0;
    if (sortColumn.name == "Section") {
      int aSectionSeqOrder = sections.firstWhereOrNull((e) => e.sectionName == value1)?.seqOrder ?? 0;
      int bSectionSeqOrder = sections.firstWhereOrNull((e) => e.sectionName == value2)?.seqOrder ?? 0;
      if (aSectionSeqOrder == bSectionSeqOrder) {
        return rollNumber1.compareTo(rollNumber2);
      } else {
        return aSectionSeqOrder.compareTo(bSectionSeqOrder);
      }
    } else if (sortColumn.name == "Roll No.") {
      return rollNumber1.compareTo(rollNumber2);
    }
    return 0;
  }

  Widget buildDataGridCell(DataGridCell<dynamic> dataGridCell, DataGridRow row) {
    return dataGridCell.columnName.toLowerCase() == "photo"
        ? SizedBox(
            width: 60,
            height: 60,
            child: extractPhoto(dataGridCell.value),
          )
        : dataGridCell.columnName.toLowerCase() == "status"
            ? Text(
                dataGridCell.value,
                style: TextStyle(
                  color: statusColor(row),
                ),
              )
            : AutoSizeText(
                dataGridCell.value.toString(),
                overflow: TextOverflow.ellipsis,
                minFontSize: 8,
                maxLines: maxLines(dataGridCell),
              );
  }

  Image extractPhoto(String? photoUrl) {
    try {
      return photoUrl == null
          ? Image.asset(
              "assets/images/avatar.png",
              fit: BoxFit.contain,
            )
          : Image.network(
              photoUrl,
              fit: BoxFit.contain,
            );
    } catch (_) {
      return Image.asset(
        "assets/images/avatar.png",
        fit: BoxFit.contain,
      );
    }
  }

  Color? statusColor(DataGridRow row) {
    String? status = !rows.contains(row) ? null : _paginatedSource[rows.indexOf(row)].status;
    switch (status) {
      case "active":
        return Colors.green[400];
      case "failed":
        return Colors.red[400];
      case "pending":
        return Colors.grey;
      default:
        return null;
    }
  }

  int maxLines(DataGridCell dataGridCell) {
    String columnName = dataGridCell.columnName;
    switch (columnName) {
      case "Section":
        return 1;
      case "Roll No.":
        return 1;
      case "Student Name":
        return 1;
      case "Parent Name":
        return 1;
      case "Mobile":
        return 1;
      case "Sex":
        return 1;
      case "Status":
        return 1;
      default:
        return 1;
    }
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    int startIndex = newPageIndex * rowsPerPage;
    int endIndex = startIndex + rowsPerPage;
    _paginatedSource = rowsSource.getRange(startIndex, min(endIndex, rowsSource.length)).toList(growable: false);
    buildPaginatedDataGridRows();
    notifyListeners();
    return true;
  }

  void buildPaginatedDataGridRows() {
    dataGridRows = _paginatedSource.map<DataGridRow>((e) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'Section', value: e.sectionName ?? " - "),
        DataGridCell<String>(columnName: 'Roll No.', value: e.rollNumber?.toString() ?? " - "),
        DataGridCell<String>(columnName: 'Photo', value: e.studentPhotoUrl),
        DataGridCell<String>(columnName: 'Student Name', value: e.studentName ?? " - "),
        DataGridCell<String>(columnName: 'Parent Name', value: e.gaurdianName ?? " - "),
        DataGridCell<String>(columnName: 'Mobile', value: e.gaurdianMobile ?? " - "),
        DataGridCell<String>(columnName: 'Sex', value: e.sex ?? " - "),
        DataGridCell<String>(columnName: 'Status', value: buildStatusMessage(e)),
      ]);
    }).toList(growable: false);
  }

  String buildStatusMessage(StudentProfileDataSourceBean e) => e.status == "active" ? "Active" : e.status?.capitalize() ?? " - ";

  void updateRowsPerPage(int _rowsPerPage) {
    rowsPerPage = _rowsPerPage;
    refreshDataGrid(refreshSelectedSection: selectedSection);
    refreshDataGrid(refreshSelectedSection: selectedSection);
    notifyListeners();
  }
}

class StudentProfileDataSourceBean {
  int? sectionSeqOrder;
  String? sectionName;
  int? rollNumber;
  String? studentPhotoUrl;
  String? studentName;
  String? gaurdianName;
  String? gaurdianMobile;
  String? sex;
  String? status;
  DateTime? lastUpdatedOn;

  StudentProfileDataSourceBean(
    this.sectionSeqOrder,
    this.sectionName,
    this.rollNumber,
    this.studentPhotoUrl,
    this.studentName,
    this.gaurdianName,
    this.gaurdianMobile,
    this.sex,
    this.status,
    this.lastUpdatedOn,
  );
}
