import 'dart:typed_data';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class DateWiseReceiptsStatsWidget extends StatefulWidget {
  const DateWiseReceiptsStatsWidget({
    Key? key,
    required this.adminProfile,
    required this.studentFeeReceipts,
    required this.selectedDate,
    required this.routeStopWiseStudents,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentFeeReceipt> studentFeeReceipts;
  final DateTime selectedDate;
  final List<RouteStopWiseStudent> routeStopWiseStudents;

  @override
  State<DateWiseReceiptsStatsWidget> createState() => _DateWiseReceiptsStatsWidgetState();
}

class _DateWiseReceiptsStatsWidgetState extends State<DateWiseReceiptsStatsWidget> {
  bool _isLoading = true;

  List<Section> sections = [];
  bool _isSectionPickerOpen = false;
  bool _showSectionPicker = false;
  List<Section> selectedSectionsList = [];

  List<StudentProfile> studentProfiles = [];
  List<StudentProfile> selectedStudentProfiles = [];

  List<StudentFeeReceipt> filteredReceipts = [];
  final ScrollController _controller = ScrollController();

  List<FeeType> feeTypes = [];
  Map<String, int> feeTypePaymentMap = {};
  Map<String, Map<String, int>> customFeeTypePaymentMap = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      filteredReceipts = widget.studentFeeReceipts.map((e) => e).toList();
      _showSectionPicker = false;
    });
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
      setState(() => studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList());
    }

    GetSectionsResponse getSectionsResponse = await getSections(GetSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        sections = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
        selectedSectionsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
      });
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
      setState(() {
        feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
      });
    }
    setState(() {
      feeTypePaymentMap = <String, int>{};
      for (FeeType feeType in feeTypes) {
        if ((feeType.customFeeTypesList ?? []).isEmpty) {
          feeTypePaymentMap["${feeType.feeType}"] = widget.studentFeeReceipts
              .map((e) => e.feeTypes ?? [])
              .expand((i) => i)
              .where((e) => e?.feeTypeId == feeType.feeTypeId && (feeType.customFeeTypesList ?? []).isEmpty)
              .map((e) => e?.amountPaidForTheReceipt ?? 0)
              .fold(0, (a, b) => a + b);
        }
      }
      customFeeTypePaymentMap = <String, Map<String, int>>{};
      for (CustomFeeType customFeeType in feeTypes.map((e) => e.customFeeTypesList ?? []).expand((i) => i).whereNotNull()) {
        customFeeTypePaymentMap["${customFeeType.feeType}"] ??= {};
        customFeeTypePaymentMap["${customFeeType.feeType}"]!["${customFeeType.customFeeType}"] ??= 0;
        customFeeTypePaymentMap["${customFeeType.feeType}"]!["${customFeeType.customFeeType}"] = widget.studentFeeReceipts
            .map((e) => e.feeTypes ?? [])
            .expand((i) => i)
            .where((e) => e?.feeTypeId == customFeeType.feeTypeId)
            .map((e) => e?.customFeeTypes ?? [])
            .expand((i) => i)
            .where((e) => e?.customFeeTypeId == customFeeType.customFeeTypeId)
            .map((e) => e?.amountPaidForTheReceipt ?? 0)
            .fold(0, (a, b) => a + b);
      }
    });

    setState(() => _isLoading = false);
  }

  void _downloadReport(List<StudentFeeReceipt> studentFeeReceipts) {
    setState(() => _isLoading = true);
    // Create an Excel workbook
    var excel = Excel.createExcel();

    // Add a sheet to the workbook
    Sheet sheet = excel['Receipts'];

    int rowIndex = 0;

    // Append the school name
    sheet.appendRow(["${widget.adminProfile.schoolName}"]);
    // Apply formatting to the school name cell
    CellStyle schoolNameStyle = CellStyle(
      bold: true,
      fontSize: 24,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = schoolNameStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0));
    rowIndex++;

    sheet.appendRow(["Date: ${(convertDateTimeToDDMMYYYYFormat(widget.selectedDate))}"]);
    // Apply formatting to the date cell
    CellStyle dateStyle = CellStyle(
      bold: true,
      fontSize: 18,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = dateStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1), CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1));
    rowIndex++;

    sheet.appendRow(["Sections: ${selectedSectionsList.map((e) => e.sectionName ?? "-").join(", ")}"]);
    // Apply formatting to the sections cell
    CellStyle sectionsStyle = CellStyle(
      bold: false,
      fontSize: 10,
    );
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).cellStyle = sectionsStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2), CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 2));
    rowIndex++;

    // Define the headers for the columns
    sheet.appendRow(['Receipt Number', 'Admission Number', 'Class', 'Roll Number', 'Student Name', 'Amount Paid', 'Mode Of Payment', 'Details']);
    for (int i = 0; i <= 7; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;

    // Add the data rows to the sheet
    for (StudentFeeReceipt receipt in studentFeeReceipts) {
      sheet.appendRow([
        receipt.receiptNumber ?? "-",
        studentProfiles.where((e) => e.studentId == receipt.studentId).firstOrNull?.admissionNo ?? "-",
        receipt.sectionName,
        studentProfiles.where((e) => e.studentId == receipt.studentId).firstOrNull?.rollNumber ?? "-",
        receipt.studentName,
        receipt.getTotalAmountForReceipt() / 100,
        ModeOfPaymentExt.fromString(receipt.modeOfPayment).description,
        getReceiptDescription(receipt).replaceAll("\n\n", "\r\n"),
      ]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).cellStyle = CellStyle(textWrapping: TextWrapping.WrapText);
      rowIndex++;
    }

    // Deleting default sheet
    if (excel.getDefaultSheet() != null) {
      excel.delete(excel.getDefaultSheet()!);
    }

    // Auto fit the columns
    for (var i = 1; i < sheet.maxCols; i++) {
      sheet.setColAutoFit(i);
    }

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["Fee Type", "Amount"]);
    for (int i = 0; i <= 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;
    for (var e in feeTypePaymentMap.entries) {
      sheet.appendRow([
        e.key,
        doubleToStringAsFixedForINR(e.value / 100),
      ]);
      rowIndex++;
    }
    for (var feeTypeMap in customFeeTypePaymentMap.entries) {
      for (var customFeeTypeMap in feeTypeMap.value.entries) {
        sheet.appendRow([
          feeTypeMap.key + ": " + customFeeTypeMap.key,
          doubleToStringAsFixedForINR(customFeeTypeMap.value / 100),
        ]);
        rowIndex++;
      }
    }
    sheet.appendRow([
      "Bus",
      doubleToStringAsFixedForINR((widget.studentFeeReceipts.map((e) => e.busFeePaid ?? 0).fold(0, (int a, int b) => a + b)) / 100),
    ]);
    rowIndex++;

    sheet.appendRow([""]);
    rowIndex++;

    sheet.appendRow(["Mode Of Payment", "Amount"]);
    for (int i = 0; i <= 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FF000000',
        fontColorHex: 'FFFFFFFF',
      );
    }
    rowIndex++;
    final paymentMap = <ModeOfPayment, int>{};
    for (final receipt in studentFeeReceipts) {
      final modeOfPayment = ModeOfPaymentExt.fromString(receipt.modeOfPayment);
      final totalAmount = receipt.getTotalAmountForReceipt();
      paymentMap[modeOfPayment] = (paymentMap[modeOfPayment] ?? 0) + totalAmount;
    }
    paymentMap.forEach((key, value) {
      if (value != 0) {
        sheet.appendRow([key.description, value / 100.0]);
        rowIndex++;
      }
    });

    sheet.appendRow([
      "Total",
      paymentMap.values.sum / 100.0,
    ]);
    for (int i = 0; i <= 1; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).cellStyle = CellStyle(
        backgroundColorHex: 'FFFFFF00',
        fontColorHex: 'FF000000',
      );
    }
    rowIndex++;

    // Generate the Excel file as bytes
    var excelBytes = excel.encode();
    if (excelBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      Uint8List excelUint8List = Uint8List.fromList(excelBytes);

      // Save the Excel file
      FileSaver.instance.saveFile(bytes: excelUint8List, name: 'Fee statistics for ${convertDateTimeToDDMMYYYYFormat(widget.selectedDate)}.xlsx');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fee Statistics"),
        actions: _isLoading || filteredReceipts.isEmpty
            ? []
            : [
                const SizedBox(width: 10),
                Tooltip(
                  message: "Download Report",
                  child: IconButton(
                    onPressed: () {
                      _downloadReport(filteredReceipts);
                    },
                    icon: const Icon(Icons.download),
                  ),
                ),
                const SizedBox(width: 10),
              ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: filteredReceipts.isEmpty
          ? const Center(child: Text("No transactions to display"))
          : _isLoading
              ? Center(
                  child: Image.asset(
                    'assets/images/eis_loader.gif',
                    height: 500,
                    width: 500,
                  ),
                )
              : ListView(
                  children: [
                    if (_showSectionPicker) _sectionPicker(),
                    _totalFeeCollected(filteredReceipts),
                    _studentFeeReceiptsTable(filteredReceipts),
                  ],
                ),
    );
  }

  Widget _studentFeeReceiptsTable(List<StudentFeeReceipt> studentFeeReceipts) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Scrollbar(
            thumbVisibility: true,
            controller: _controller,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Receipt Number')),
                  DataColumn(label: Text('Admission Number')),
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Roll Number')),
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Amount Paid')),
                  DataColumn(label: Text('Mode Of Payment')),
                  DataColumn(label: Text('Details')),
                ],
                rows: studentFeeReceipts.sorted((a, b) => (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0)).map((receipt) {
                  return DataRow(
                    cells: [
                      DataCell(Text("${receipt.receiptNumber ?? "-"}")),
                      DataCell(Text(studentProfiles.where((e) => e.studentId == receipt.studentId).firstOrNull?.admissionNo ?? "-")),
                      DataCell(Text("${receipt.sectionName}")),
                      DataCell(Text(studentProfiles.where((e) => e.studentId == receipt.studentId).firstOrNull?.rollNumber ?? "-")),
                      DataCell(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${receipt.studentName}"),
                            const SizedBox(width: 5),
                            buildBusFeeTooltip(widget.routeStopWiseStudents.where((e) => e.studentId == receipt.studentId).firstOrNull),
                          ],
                        ),
                      ),
                      DataCell(Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(receipt.getTotalAmountForReceipt() / 100)} /-")),
                      DataCell(Text(ModeOfPaymentExt.fromString(receipt.modeOfPayment).description)),
                      DataCell(Text(getReceiptDescription(receipt).split("\n\n").join(", "))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalFeeCollected(List<StudentFeeReceipt> studentFeeReceipts) {
    final modeOfPaymentMap = <ModeOfPayment, int>{};
    for (final receipt in studentFeeReceipts) {
      final modeOfPayment = ModeOfPaymentExt.fromString(receipt.modeOfPayment);
      final totalAmount = receipt.getTotalAmountForReceipt();
      modeOfPaymentMap[modeOfPayment] = (modeOfPaymentMap[modeOfPayment] ?? 0) + totalAmount;
    }
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                MediaQuery.of(context).orientation == Orientation.portrait
                                    ? convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(widget.selectedDate)).replaceAll("\n", " ")
                                    : convertDateToDDMMMYYYY(convertDateTimeToYYYYMMDDFormat(widget.selectedDate)).replaceAll("\n", " "),
                                style: GoogleFonts.archivoBlack(
                                  textStyle: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...feeTypeWiseWidgets(),
                        Divider(
                          thickness: MediaQuery.of(context).orientation == Orientation.landscape ? 2 : 1,
                          color: clayContainerTextColor(context),
                        ),
                        ...modeOfPaymentWiseWidgets(modeOfPaymentMap),
                        Divider(
                          thickness: MediaQuery.of(context).orientation == Orientation.landscape ? 2 : 1,
                          color: clayContainerTextColor(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Text(
                                  "Total:",
                                ),
                              ),
                              Text(
                                  "$INR_SYMBOL ${doubleToStringAsFixedForINR(studentFeeReceipts.map((e) => e.getTotalAmountForReceipt()).sum / 100)} /-"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (MediaQuery.of(context).orientation == Orientation.landscape) const SizedBox(width: 20),
                  if (MediaQuery.of(context).orientation == Orientation.landscape)
                    CustomVerticalDivider(
                      height: 200,
                      width: 1,
                      color: clayContainerTextColor(context),
                    ),
                  const SizedBox(width: 10),
                  if (MediaQuery.of(context).orientation == Orientation.landscape) _modeOfPaymentPieChartWidget(),
                ],
              ),
              if (MediaQuery.of(context).orientation == Orientation.portrait) const SizedBox(height: 10),
              if (MediaQuery.of(context).orientation == Orientation.portrait)
                Divider(
                  thickness: 2,
                  color: clayContainerTextColor(context),
                ),
              if (MediaQuery.of(context).orientation == Orientation.portrait) _modeOfPaymentPieChartWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> feeTypeWiseWidgets() => [
        ...feeTypePaymentMap.entries.map((e) => Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                    ),
                  ),
                  Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(e.value / 100)} /-"),
                ],
              ),
            )),
        ...customFeeTypePaymentMap.entries.map((feeTypeMap) => Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feeTypeMap.key,
                  ),
                  ...feeTypeMap.value.entries.map((MapEntry<String, int> customFeeTypeMap) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 20),
                          Expanded(child: Text(customFeeTypeMap.key)),
                          Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(customFeeTypeMap.value / 100)} /-"),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  "Bus",
                ),
              ),
              Text(
                  "$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.studentFeeReceipts.map((e) => e.busFeePaid ?? 0).fold(0, (int a, int b) => a + b)) / 100)} /-"),
            ],
          ),
        )
      ];

  Iterable<Widget> modeOfPaymentWiseWidgets(Map<ModeOfPayment, int> paymentMap) => paymentMap.entries.map((e) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "${e.key.description}:",
              ),
            ),
            Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(e.value / 100)} /-"),
          ],
        ),
      ));

  Widget _modeOfPaymentPieChartWidget() {
    return SizedBox(
      width: 300, // Replace with the desired width
      height: 200, // Replace with the desired height
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: charts.PieChart<String>(
              generatePieChartData(filteredReceipts),
              animate: true,
              defaultRenderer: charts.ArcRendererConfig(
                arcRendererDecorators: [
                  charts.ArcLabelDecorator(
                    labelPosition: charts.ArcLabelPosition.inside,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ModeOfPayment.values.map((e) => ModeOfPaymentExt.getChartLedgerRow(e)).toList(),
            ),
          ),
        ],
      ),
    );
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
              selectedStudentProfiles.clear();
            } else {
              selectedSectionsList.add(section);
              selectedStudentProfiles.clear();
            }
            filteredReceipts = widget.studentFeeReceipts.where((e) => selectedSectionsList.map((e) => e.sectionId).contains(e.sectionId)).toList();
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
                _showSectionPicker = !_showSectionPicker;
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
                  onTap: () {
                    setState(() {
                      selectedSectionsList.map((e) => e).toList().forEach((e) {
                        selectedSectionsList.remove(e);
                      });
                      selectedSectionsList.addAll(sections.map((e) => e).toList());
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

  String getReceiptDescription(StudentFeeReceipt receipt) {
    List<String> feeTypeWiseDescriptions = [];
    List<String> customFeeTypeWiseDescriptions = [];
    List<String> busFeeTypeWiseDescriptions = [];

    for (FeeTypeOfReceipt eachFeeType in (receipt.feeTypes ?? []).whereNotNull()) {
      if ((eachFeeType.customFeeTypes ?? []).whereNotNull().isEmpty && (eachFeeType.amountPaidForTheReceipt ?? 0) != 0) {
        feeTypeWiseDescriptions.add("${eachFeeType.feeType ?? " - "}: ${(eachFeeType.amountPaidForTheReceipt ?? 0) / 100}");
      } else {
        for (CustomFeeTypeOfReceipt eachCustomFeeType in (eachFeeType.customFeeTypes ?? []).whereNotNull()) {
          if ((eachCustomFeeType.amountPaidForTheReceipt ?? 0) != 0) {
            customFeeTypeWiseDescriptions.add(
                "${eachFeeType.feeType ?? " - "} - ${eachCustomFeeType.customFeeType ?? " - "}: ${(eachCustomFeeType.amountPaidForTheReceipt ?? 0) / 100}");
          }
        }
      }
    }
    if ((receipt.busFeePaid ?? 0) != 0) {
      busFeeTypeWiseDescriptions.add("Bus Fee: ${(receipt.busFeePaid ?? 0) / 100}");
    }

    return [...feeTypeWiseDescriptions, ...customFeeTypeWiseDescriptions, ...busFeeTypeWiseDescriptions].join("\n\n");
  }

  Widget buildBusFeeTooltip(RouteStopWiseStudent? routeStopWiseStudents) {
    if (routeStopWiseStudents == null) return Container();
    return Tooltip(
      message: "Stop: ${routeStopWiseStudents.busStopName}\n"
          "Route: ${routeStopWiseStudents.routeName}",
      child: const SizedBox(
        height: 15,
        width: 15,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(
            Icons.directions_bus_outlined,
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }
}

List<charts.Series<PaymentSummary, String>> generatePieChartData(List<StudentFeeReceipt> studentFeeReceipts) {
  // Create a map to store the total amounts for each mode of payment
  final paymentMap = <ModeOfPayment, int>{};

  // Calculate the total amounts for each mode of payment
  for (final receipt in studentFeeReceipts) {
    final modeOfPayment = ModeOfPaymentExt.fromString(receipt.modeOfPayment);
    final totalAmount = receipt.getTotalAmountForReceipt();
    paymentMap[modeOfPayment] = (paymentMap[modeOfPayment] ?? 0) + totalAmount;
  }

  // Create a list of PaymentSummary objects from the map
  final data = paymentMap.entries.map((entry) {
    final modeOfPayment = entry.key;
    final totalAmount = entry.value;

    return PaymentSummary(
      modeOfPayment.description, // Use the modeOfPayment as the category label
      totalAmount / 100.0, ModeOfPaymentExt.getChartColorForModeOfPayment(modeOfPayment), // Assign a color to each modeOfPayment
    );
  }).toList();

  // Create a series for the pie chart
  return [
    charts.Series<PaymentSummary, String>(
      id: 'PaymentSummary',
      domainFn: (PaymentSummary summary, _) => summary.modeOfPayment,
      measureFn: (PaymentSummary summary, _) => summary.totalAmount,
      colorFn: (PaymentSummary summary, _) => summary.color,
      data: data,
      labelAccessorFn: (PaymentSummary summary, _) => '$INR_SYMBOL ${doubleToStringAsFixedForINR(summary.totalAmount)}',
    ),
  ];
}

class PaymentSummary {
  final String modeOfPayment;
  final double totalAmount;
  final charts.Color color;

  PaymentSummary(this.modeOfPayment, this.totalAmount, this.color);
}
