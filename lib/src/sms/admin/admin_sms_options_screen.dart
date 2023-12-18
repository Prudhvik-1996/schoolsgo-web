import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/sms/modal/sms.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AdminSmsOptionsScreen extends StatefulWidget {
  const AdminSmsOptionsScreen({
    super.key,
    required this.adminProfile,
  });

  final AdminProfile adminProfile;
  static const routeName = "/sms";

  @override
  State<AdminSmsOptionsScreen> createState() => _AdminSmsOptionsScreenState();
}

class _AdminSmsOptionsScreenState extends State<AdminSmsOptionsScreen> {
  bool _isLoading = true;
  ScrollController bodyVerticalController = ScrollController();
  ScrollController dataTableHorizontalController = ScrollController();
  ScrollController dataTableVerticalController = ScrollController();

  int smsCount = 0;
  List<SmsCounterLogBean> smsCounterLogList = [];
  List<SmsCategoryBean> smsCategoryList = [];
  List<SmsConfigBean> smsConfigList = [];
  List<SmsTemplateBean> smsTemplates = [];
  List<SmsTemplateWiseLogBean> smsTemplateWiseLogBeans = [];
  late _TemplateWiseLogDataSource templateWiseLogDataSource;
  Map<String, double> columnWidths = {
    'Date': 250,
    'Category': 250,
    'Sms Template': 250,
    'Sms Used': 150,
    'Failure Reason': 500,
  };
  int _rowsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSchoolWiseSmsCounterResponse getSchoolWiseSmsCounterResponse = await getSchoolWiseSmsCounter(GetSchoolWiseSmsCounterRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
    ));
    if (getSchoolWiseSmsCounterResponse.httpStatus != "OK" || getSchoolWiseSmsCounterResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsCounterLogList = getSchoolWiseSmsCounterResponse.smsCounterLogList?.map((e) => e!).toList() ?? [];
      smsCount = getSchoolWiseSmsCounterResponse.schoolWiseCount ?? 0;
    }
    GetSmsCategoriesResponse getSmsCategoriesResponse = await getSmsCategories(GetSmsCategoriesRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
    ));
    if (getSmsCategoriesResponse.httpStatus != "OK" || getSmsCategoriesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsCategoryList = getSmsCategoriesResponse.smsCategoryList?.map((e) => e!).toList() ?? [];
    }
    GetSmsConfigResponse getSmsConfigResponse = await getSmsConfig(GetSmsConfigRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
    ));
    if (getSmsConfigResponse.httpStatus != "OK" || getSmsConfigResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsConfigList = getSmsConfigResponse.smsConfigBeans?.map((e) => e!).toList() ?? [];
    }
    GetSmsTemplatesResponse getSmsTemplatesResponse = await getSmsTemplates(GetSmsTemplatesRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSmsTemplatesResponse.httpStatus != "OK" || getSmsTemplatesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsTemplates = getSmsTemplatesResponse.smsTemplateBeans?.map((e) => e!).toList() ?? [];
    }
    GetSmsTemplateWiseLogResponse getSmsTemplateWiseLogResponse = await getSmsTemplateWiseLog(GetSmsTemplateWiseLogRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
    ));
    if (getSmsTemplateWiseLogResponse.httpStatus != "OK" || getSmsTemplateWiseLogResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      smsTemplateWiseLogBeans = getSmsTemplateWiseLogResponse.smsTemplateWiseLogBeans?.map((e) => e!).toList() ?? [];
      print("113: ${smsTemplateWiseLogBeans.length}");
    }
    templateWiseLogDataSource = _TemplateWiseLogDataSource(smsTemplateWiseLogBeans, smsCategoryList, smsTemplates, _rowsPerPage);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS"),
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
              controller: bodyVerticalController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Sms Left: $smsCount"),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SfDataGrid(
                    frozenColumnsCount: 1,
                    shrinkWrapRows: true,
                    source: templateWiseLogDataSource,
                    allowColumnsResizing: true,
                    onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                      setState(() {
                        columnWidths[details.column.columnName] = details.width;
                      });
                      return true;
                    },
                    isScrollbarAlwaysShown: true,
                    columns: [
                      GridColumn(
                        width: columnWidths["Date"]!,
                        autoFitPadding: const EdgeInsets.all(10.0),
                        label: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text(
                            "Date",
                            softWrap: false,
                          ),
                        ),
                        columnName: 'Date',
                      ),
                      GridColumn(
                        width: columnWidths["Category"]!,
                        autoFitPadding: const EdgeInsets.all(10.0),
                        label: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text(
                            "Category",
                            softWrap: false,
                          ),
                        ),
                        columnName: 'Category',
                      ),
                      GridColumn(
                        width: columnWidths["Sms Template"]!,
                        autoFitPadding: const EdgeInsets.all(10.0),
                        label: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text(
                            "Sms Template",
                            softWrap: false,
                          ),
                        ),
                        columnName: 'Sms Template',
                      ),
                      GridColumn(
                        width: columnWidths["Sms Used"]!,
                        autoFitPadding: const EdgeInsets.all(10.0),
                        label: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text(
                            "Sms Used",
                            softWrap: false,
                          ),
                        ),
                        columnName: 'Sms Used',
                      ),
                      GridColumn(
                        width: columnWidths["Failure Reason"]!,
                        autoFitPadding: const EdgeInsets.all(10.0),
                        label: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text(
                            "Failure Reason",
                            softWrap: false,
                          ),
                        ),
                        columnName: 'Failure Reason',
                      ),
                    ],
                    footerHeight: 100,
                    footer: SfDataPager(
                      itemHeight: 50,
                      delegate: templateWiseLogDataSource,
                      availableRowsPerPage: [
                        if (smsTemplateWiseLogBeans.length >= 5) 5,
                        if (smsTemplateWiseLogBeans.length >= 10) 10,
                        if (smsTemplateWiseLogBeans.length >= 20) 20,
                        if (smsTemplateWiseLogBeans.length >= 50) 50,
                        if (smsTemplateWiseLogBeans.length >= 100) 100,
                        smsTemplateWiseLogBeans.length
                      ],
                      onRowsPerPageChanged: (int? rowsPerPage) {
                        setState(() {
                          _rowsPerPage = rowsPerPage!;
                          templateWiseLogDataSource.updateRowsPerPage(_rowsPerPage);
                        });
                      },
                      pageCount: ((smsTemplateWiseLogBeans.length / _rowsPerPage).ceil()).toDouble(),
                      direction: Axis.horizontal,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TemplateWiseLogDataSource extends DataGridSource {
  _TemplateWiseLogDataSource(
    this.smsTemplateWiseLogBeans,
    this.smsCategoryList,
    this.smsTemplates,
    this.rowsPerPage,
  ) {
    refreshDataGrid();
  }

  void refreshDataGrid() {
    rowsSource = smsTemplateWiseLogBeans.map((SmsTemplateWiseLogBean eachLog) {
      final categoryBean = smsCategoryList.where((ec) => ec.categoryId == eachLog.categoryId).firstOrNull;
      final templateBean = smsTemplates.where((et) => et.templateId == eachLog.templateId).firstOrNull;
      return TemplateWiseLogDataSourceBean(eachLog.createTime ?? " - ", categoryBean?.category ?? "-", templateBean?.textLocalTemplateName ?? "-",
          eachLog.noOfSmsSent ?? 0, eachLog.comments ?? " - ", eachLog.status ?? " - ");
    }).toList();
    _paginatedSource = rowsSource.getRange(0, rowsPerPage).toList(growable: false);
    handlePageChange(0, 0);
    buildPaginatedDataGridRows();
  }

  final List<SmsTemplateWiseLogBean> smsTemplateWiseLogBeans;
  final List<SmsCategoryBean> smsCategoryList;
  final List<SmsTemplateBean> smsTemplates;
  int rowsPerPage;

  List<TemplateWiseLogDataSourceBean> _paginatedSource = [];
  List<TemplateWiseLogDataSourceBean> rowsSource = [];

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: rowColor(row),
      cells: row
          .getCells()
          .map<Widget>(
            (dataGridCell) => Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10.0),
              child: Text(dataGridCell.value.toString()),
            ),
          )
          .toList(),
    );
  }

  Color? rowColor(DataGridRow row) {
    String status = _paginatedSource[rows.indexOf(row)].status;
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
        DataGridCell<String>(columnName: 'createTime', value: parseAndFormatDateString(e.createTime)),
        DataGridCell<String>(columnName: 'category', value: e.category),
        DataGridCell<String>(columnName: 'templateName', value: e.templateName),
        DataGridCell<int>(columnName: 'noOfSmsSent', value: e.noOfSmsSent),
        DataGridCell<String>(columnName: 'comments', value: e.comments),
      ]);
    }).toList(growable: false);
  }

  void updateRowsPerPage(int _rowsPerPage) {
    rowsPerPage = _rowsPerPage;
    refreshDataGrid();
    notifyListeners();
  }
}

class TemplateWiseLogDataSourceBean {
  String createTime;
  String category;
  String templateName;
  int noOfSmsSent;
  String comments;
  String status;

  TemplateWiseLogDataSourceBean(this.createTime, this.category, this.templateName, this.noOfSmsSent, this.comments, this.status);
}
