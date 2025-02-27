import 'dart:convert';
import 'dart:html';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/stats/constants/fee_report_type.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class SectionWiseFeeStats extends StatefulWidget {
  const SectionWiseFeeStats({
    Key? key,
    required this.adminProfile,
    required this.studentFeeReceipts,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentFeeReceipt> studentFeeReceipts;

  @override
  State<SectionWiseFeeStats> createState() => _SectionWiseFeeStatsState();
}

class _SectionWiseFeeStatsState extends State<SectionWiseFeeStats> {
  bool _isLoading = true;
  bool _isCardView = false;
  String studentStatusFilterType = "A"; // "A" - only active students, "-" - all students, "D" - only dropout students
  List<FeeType> feeTypes = [];

  List<Section> sections = [];
  List<StudentProfile> studentProfiles = [];
  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];

  List<StudentFeeReceipt> studentFeeReceipts = [];
  Map<Section, StudentAnnualFeeBean> sectionWiseFeeMap = {};
  Map<Section, Map<String, Map<ModeOfPayment, int>>> sectionWiseModeOfPaymentMap = {};
  Map<String, Map<ModeOfPayment, int>> schoolWiseModeOfPaymentMap = {};

  Map<Section, ScrollController> sectionWiseScrollControllerForTotalFeeTable = {};
  Map<Section, ScrollController> sectionWiseScrollControllerForModeOfPayments = {};
  ScrollController feeTypeScrollControllerForSchool = ScrollController();
  ScrollController modeOfPaymentScrollController = ScrollController();
  final double columnSpacing = 3;
  final double rowHeight = 45;
  final double columnWidth = 90;

  @override
  void initState() {
    super.initState();
    studentFeeReceipts = widget.studentFeeReceipts;
    _loadData();
  }

  Future<void> handleMoreOptions(String value) async {
    switch (value) {
      case 'Switch to table view':
        setState(() => _isCardView = false);
        return;
      case 'Switch to card view':
        setState(() => _isCardView = true);
        return;
      case 'Only dropout students':
        setState(() => studentStatusFilterType = "D");
        generateSectionMap();
        generateModeOfPaymentMap();
        return;
      case 'Only active students':
        setState(() => studentStatusFilterType = "A");
        generateSectionMap();
        generateModeOfPaymentMap();
        return;
      case 'All students':
        setState(() => studentStatusFilterType = "-");
        generateSectionMap();
        generateModeOfPaymentMap();
        return;
      case 'Download report':
        await downloadReport();
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section wise Fee Stats"),
        actions: _isLoading
            ? []
            : [
                PopupMenuButton<String>(
                  onSelected: handleMoreOptions,
                  itemBuilder: (BuildContext context) {
                    return {
                      (_isCardView ? 'Switch to table view' : 'Switch to card view'),
                      'Only dropout students',
                      'Only active students',
                      'All students',
                      // 'Download report',
                    }.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
                const SizedBox(width: 8),
              ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : studentFeeReceipts.isEmpty
              ? const Center(child: Text("No transactions to display"))
              : _isLoading
                  ? const EpsilonDiaryLoadingWidget()
                  : _isCardView
                      ? cardViewWidget()
                      : tableViewListWidget(),
      // : cardViewWidget(),
    );
  }

  Widget tableViewListWidget() {
    return ListView(
      children: [
        schoolWiseTableWidget(),
        ...sections.where((e) => (sectionWiseFeeMap[e]?.totalFee ?? 0) > 0).map((e) => tableViewWidget(e)),
        const SizedBox(height: 200),
      ],
    );
  }

  Widget schoolWiseTableWidget() {
    Map<String, double> schoolWiseTotalFeeMap = {};
    Map<String, double> schoolWiseTotalFeeCollectedMap = {};
    Map<String, double> schoolWiseTotalFeeDueMap = {};
    Map<String, String> feeTypeNameMap = {};
    populateMapForSchool(schoolWiseTotalFeeMap, schoolWiseTotalFeeCollectedMap, schoolWiseTotalFeeDueMap, feeTypeNameMap);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              embossedClayTitleWidget(schoolNameText(widget.adminProfile.schoolName ?? "-")),
              const SizedBox(height: 8),
              schoolWiseStatsFeeTypeTable(schoolWiseTotalFeeMap, schoolWiseTotalFeeCollectedMap, schoolWiseTotalFeeDueMap, feeTypeNameMap),
              const SizedBox(height: 8),
              modeOfPaymentsHeader(),
              schoolWiseStatsModeOfPaymentTable(feeTypeNameMap),
            ],
          ),
        ),
      ),
    );
  }

  Widget schoolWiseStatsModeOfPaymentTable(Map<String, String> feeTypeNameMap) {
    List<String> columnNames = ["", ...feeTypeNameMap.values.toList()];
    Set<ModeOfPayment> modes = schoolWiseModeOfPaymentMap.values.map((e) => e.keys).expand((i) => i).toSet();
    List<List<Widget>> rows = modes
        .map((ModeOfPayment eachModeOfPayment) {
          double totalAmount =
              schoolWiseModeOfPaymentMap.values.map((e) => (e[eachModeOfPayment] ?? 0) / 100.0).fold(0.0, (double? a, b) => (a ?? 0) + b);
          if (totalAmount == 0) return null;
          return [
            eachModeOfPayment.description,
            ...schoolWiseModeOfPaymentMap.values.map((e) {
              double amount = (e[eachModeOfPayment] ?? 0) / 100.0;
              return "$INR_SYMBOL ${(doubleToStringAsFixedForINR(amount))}";
            }),
            "$INR_SYMBOL ${(doubleToStringAsFixedForINR(totalAmount))}",
          ].map((e) => clayCellChild(e)).toList();
        })
        .whereNotNull()
        .toList();
    return clayDataTable(modeOfPaymentScrollController, columnSpacing, rowHeight, columnWidth, columnNames, rows);
  }

  Widget tableViewWidget(Section section) {
    String sectionName = section.sectionName ?? "-";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              embossedClayTitleWidget(schoolNameText(sectionName)),
              const SizedBox(height: 8),
              feeTypeWiseTotalCollectedTable(section),
              const SizedBox(height: 8),
              feeTypeWiseModeOfPaymentTable(section),
            ],
          ),
        ),
      ),
    );
  }

  Padding modeOfPaymentsHeader() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "Mode Of Payments",
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Widget schoolWiseStatsFeeTypeTable(
    Map<String, double> schoolWiseTotalFeeMap,
    Map<String, double> schoolWiseTotalFeeCollectedMap,
    Map<String, double> schoolWiseTotalFeeDueMap,
    Map<String, String> feeTypeNameMap,
  ) {
    List<String> columnNames = ["", ...feeTypeNameMap.values.toList()];
    // schoolWiseTotalFeeMap.keys.mapIndexed((i, e) => schoolWiseTotalFeeMap[e]! == 0 ? null : i).whereNotNull().toList();
    List<Widget> feeRow = [
      "Fee",
      ...schoolWiseTotalFeeMap.values.map((e) => "$INR_SYMBOL ${doubleToStringAsFixedForINR(e)}"),
    ].map((e) => clayCellChild(e)).toList();
    List<Widget> collectedRow = [
      "Collected",
      ...schoolWiseTotalFeeCollectedMap.values.map((e) => "$INR_SYMBOL ${doubleToStringAsFixedForINR(e)}"),
    ].map((e) => clayCellChild(e)).toList();
    List<Widget> dueRow = [
      "Due",
      ...schoolWiseTotalFeeDueMap.values.map((e) => "$INR_SYMBOL ${doubleToStringAsFixedForINR(e)}"),
    ].map((e) => clayCellChild(e)).toList();
    List<List<double>> feeStatsForSection = schoolWiseTotalFeeMap.values.mapIndexed((index, totalFee) {
      double feeCollected = schoolWiseTotalFeeCollectedMap.values.toList()[index];
      double feeDue = schoolWiseTotalFeeDueMap.values.toList()[index];
      return [feeCollected, feeDue];
    }).toList();
    List<Widget> graphsRow = [
      clayCellChild("Graph"),
      ...feeStatsForSection.map((List<double> feeStats) {
        if (feeStats[0] == 0 && feeStats[1] == 0) {
          return clayCellChild("-");
        } else {
          return pieChart(feeStats);
        }
        // return clayCellChild("${feeStats[0]} - ${feeStats[1]} = ${feeStats[2]}");
      }).toList()
    ];
    List<List<Widget>> rows = [feeRow, collectedRow, dueRow];
    return clayDataTable(feeTypeScrollControllerForSchool, columnSpacing, rowHeight, columnWidth, columnNames, rows, graphRow: graphsRow);
  }

  void populateMapForSchool(
    Map<String, double> schoolWiseTotalFeeMap,
    Map<String, double> schoolWiseTotalFeeCollectedMap,
    Map<String, double> schoolWiseTotalFeeDueMap,
    Map<String, String> feeTypeNameMap,
  ) {
    for (FeeType eachFeeType in feeTypes) {
      if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
        String key = "${eachFeeType.feeTypeId}|-";
        schoolWiseTotalFeeMap[key] = 0.0;
        schoolWiseTotalFeeCollectedMap[key] = 0.0;
        schoolWiseTotalFeeDueMap[key] = 0.0;
        feeTypeNameMap[key] = eachFeeType.feeType ?? "-";
      } else {
        for (CustomFeeType eachCustomFeeType in (eachFeeType.customFeeTypesList ?? []).whereNotNull()) {
          String key = "${eachFeeType.feeTypeId}|${eachCustomFeeType.customFeeTypeId}";
          schoolWiseTotalFeeMap[key] = 0.0;
          schoolWiseTotalFeeCollectedMap[key] = 0.0;
          schoolWiseTotalFeeDueMap[key] = 0.0;
          feeTypeNameMap[key] = "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}";
        }
      }
    }
    String busFeeKey = "-|-";
    schoolWiseTotalFeeMap[busFeeKey] = 0.0;
    schoolWiseTotalFeeCollectedMap[busFeeKey] = 0.0;
    schoolWiseTotalFeeDueMap[busFeeKey] = 0.0;
    feeTypeNameMap[busFeeKey] = "Bus";
    String totalKey = "|||";
    schoolWiseTotalFeeMap[totalKey] = 0.0;
    schoolWiseTotalFeeCollectedMap[totalKey] = 0.0;
    schoolWiseTotalFeeDueMap[totalKey] = 0.0;
    feeTypeNameMap[totalKey] = "Total";
    for (int i = 0; i < sections.length; i++) {
      Section section = sections[i];
      StudentBusFeeBean? sectionWiseBusFeeBean = sectionWiseFeeMap[section]!.studentBusFeeBean;
      (sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? []).forEach((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
        if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
          String key = "${sectionAnnualFeeTypeBean.feeTypeId}|-";
          double amount = (sectionAnnualFeeTypeBean.amount ?? 0) / 100.0;
          double amountPaid = (sectionAnnualFeeTypeBean.amountPaid ?? 0) / 100.0;
          double amountDue = amount - amountPaid;
          schoolWiseTotalFeeMap[key] = (schoolWiseTotalFeeMap[key] ?? 0) + amount;
          schoolWiseTotalFeeCollectedMap[key] = (schoolWiseTotalFeeCollectedMap[key] ?? 0) + amountPaid;
          schoolWiseTotalFeeDueMap[key] = (schoolWiseTotalFeeDueMap[key] ?? 0) + amountDue;
          schoolWiseTotalFeeMap["|||"] = (schoolWiseTotalFeeMap["|||"] ?? 0) + amount;
          schoolWiseTotalFeeCollectedMap["|||"] = (schoolWiseTotalFeeCollectedMap["|||"] ?? 0) + amountPaid;
          schoolWiseTotalFeeDueMap["|||"] = (schoolWiseTotalFeeDueMap["|||"] ?? 0) + amountDue;
        } else {
          (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).forEach((StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) {
            String key = "${sectionAnnualFeeTypeBean.feeTypeId}|${sectionAnnualCustomFeeTypeBean.customFeeTypeId}";
            double amount = (sectionAnnualCustomFeeTypeBean.amount ?? 0) / 100.0;
            double amountPaid = (sectionAnnualCustomFeeTypeBean.amountPaid ?? 0) / 100.0;
            double amountDue = amount - amountPaid;
            schoolWiseTotalFeeMap[key] = (schoolWiseTotalFeeMap[key] ?? 0) + amount;
            schoolWiseTotalFeeCollectedMap[key] = (schoolWiseTotalFeeCollectedMap[key] ?? 0) + amountPaid;
            schoolWiseTotalFeeDueMap[key] = (schoolWiseTotalFeeDueMap[key] ?? 0) + amountDue;
            schoolWiseTotalFeeMap["|||"] = (schoolWiseTotalFeeMap["|||"] ?? 0) + amount;
            schoolWiseTotalFeeCollectedMap["|||"] = (schoolWiseTotalFeeCollectedMap["|||"] ?? 0) + amountPaid;
            schoolWiseTotalFeeDueMap["|||"] = (schoolWiseTotalFeeDueMap["|||"] ?? 0) + amountDue;
          });
        }
      });
      String busFeeKey = "-|-";
      double busFee = (sectionWiseFeeMap[section]!.studentBusFeeBean?.fare ?? 0) / 100.0;
      double busFeePaid = (sectionWiseFeeMap[section]!.studentBusFeeBean?.feePaid ?? 0) / 100.0;
      double busFeeDue = busFee - busFeePaid;
      schoolWiseTotalFeeMap[busFeeKey] = (schoolWiseTotalFeeMap[busFeeKey] ?? 0) + busFee;
      schoolWiseTotalFeeCollectedMap[busFeeKey] = (schoolWiseTotalFeeCollectedMap[busFeeKey] ?? 0) + busFeePaid;
      schoolWiseTotalFeeDueMap[busFeeKey] = (schoolWiseTotalFeeDueMap[busFeeKey] ?? 0) + busFeeDue;
      schoolWiseTotalFeeMap["|||"] = (schoolWiseTotalFeeMap["|||"] ?? 0) + busFee;
      schoolWiseTotalFeeCollectedMap["|||"] = (schoolWiseTotalFeeCollectedMap["|||"] ?? 0) + busFeePaid;
      schoolWiseTotalFeeDueMap["|||"] = (schoolWiseTotalFeeDueMap["|||"] ?? 0) + busFeeDue;
    }
    if ((schoolWiseTotalFeeMap["-|-"] ?? 0) <= 0) {
      schoolWiseTotalFeeMap.remove("-|-");
      schoolWiseTotalFeeCollectedMap.remove("-|-");
      schoolWiseTotalFeeDueMap.remove("-|-");
      feeTypeNameMap.remove("-|-");
    }
  }

  Widget feeTypeWiseModeOfPaymentTable(Section section) {
    ScrollController horizontalScrollController = sectionWiseScrollControllerForModeOfPayments[section]!;
    Map<String, Map<ModeOfPayment, int>> feeTypeWiseModeOfPaymentMap = sectionWiseModeOfPaymentMap[section]!;
    Map<ModeOfPayment, int> modeWiseTotal = {};
    ModeOfPayment.values.forEach((eachModeOfPayment) {
      modeWiseTotal[eachModeOfPayment] = 0;
      (sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? []).forEach((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
        if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
          String feeTypeKey = "${sectionAnnualFeeTypeBean.feeTypeId}|-";
          modeWiseTotal[eachModeOfPayment] = modeWiseTotal[eachModeOfPayment]! + feeTypeWiseModeOfPaymentMap[feeTypeKey]![eachModeOfPayment]!;
        } else {
          (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).forEach((StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) {
            String feeTypeKey = "${sectionAnnualFeeTypeBean.feeTypeId}|${sectionAnnualCustomFeeTypeBean.customFeeTypeId}";
            modeWiseTotal[eachModeOfPayment] = modeWiseTotal[eachModeOfPayment]! + feeTypeWiseModeOfPaymentMap[feeTypeKey]![eachModeOfPayment]!;
          });
        }
      });
      modeWiseTotal[eachModeOfPayment] = modeWiseTotal[eachModeOfPayment]! + feeTypeWiseModeOfPaymentMap["-|-"]![eachModeOfPayment]!;
    });
    modeWiseTotal.removeWhere((key, value) => value == 0);
    List<String> columns = getDataTableColumns(section, (sectionWiseFeeMap[section]!.studentBusFeeBean?.fare ?? 0) > 0);
    List<List<Widget>> rows = modeWiseTotal.keys.map((ModeOfPayment eachModeOfPayment) {
      return [
        eachModeOfPayment.description,
        ...(sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? [])
            .map((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
              if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
                String feeTypeKey = "${sectionAnnualFeeTypeBean.feeTypeId}|-";
                return [feeTypeWiseModeOfPaymentMap[feeTypeKey]![eachModeOfPayment]!];
              } else {
                return (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])
                    .map((StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) {
                  String feeTypeKey = "${sectionAnnualFeeTypeBean.feeTypeId}|${sectionAnnualCustomFeeTypeBean.customFeeTypeId}";
                  return feeTypeWiseModeOfPaymentMap[feeTypeKey]![eachModeOfPayment]!;
                });
              }
            })
            .expand((i) => i)
            .map((e) => "$INR_SYMBOL ${(doubleToStringAsFixedForINR(e / 100.0))}")
            .toList(),
        if ((sectionWiseFeeMap[section]!.studentBusFeeBean?.fare ?? 0) > 0)
          "$INR_SYMBOL ${doubleToStringAsFixedForINR(feeTypeWiseModeOfPaymentMap["-|-"]![eachModeOfPayment]! / 100.0)}",
        "$INR_SYMBOL ${(doubleToStringAsFixedForINR(modeWiseTotal[eachModeOfPayment]! / 100.0))}",
      ].map((e) => clayCellChild(e)).toList();
    }).toList();
    if (rows.isEmpty) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        modeOfPaymentsHeader(),
        clayDataTable(horizontalScrollController, columnSpacing, rowHeight, columnWidth, columns, rows),
      ],
    );
  }

  List<String> getDataTableColumns(Section? section, bool showBusFee) {
    if (section == null) {
      return [];
    } else {
      List<String> columns = [
        "",
        ...(sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? []).map((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
          if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
            return [sectionAnnualFeeTypeBean.feeType ?? "-"];
          } else {
            return (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).map(
                (StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) =>
                    "${sectionAnnualFeeTypeBean.feeType ?? "-"} \n ${sectionAnnualCustomFeeTypeBean.customFeeType ?? "-"}");
          }
        }).expand((i) => i),
        if (showBusFee) "Bus",
        "Total",
      ];
      return columns;
    }
  }

  Widget feeTypeWiseTotalCollectedTable(Section section) {
    ScrollController horizontalScrollController = sectionWiseScrollControllerForTotalFeeTable[section]!;
    List<String> columns = getDataTableColumns(section, (sectionWiseFeeMap[section]!.studentBusFeeBean?.fare ?? 0) > 0);
    List<double> sectionWiseTotalFeeRowValues = sectionWiseTotalFeeRow(section);
    List<double> sectionWiseTotalFeeCollectedRowValues = sectionWiseTotalFeeCollectedRow(section);
    List<double> sectionWiseDueRowValues = sectionWiseDueRow(section);
    List<Widget> feeRow = [
      "Fee",
      ...sectionWiseTotalFeeRowValues.map((e) => "$INR_SYMBOL ${doubleToStringAsFixedForINR(e)}"),
    ].map((e) => clayCellChild(e)).toList();
    List<Widget> collectedRow = [
      "Collected",
      ...sectionWiseTotalFeeCollectedRowValues.map((e) => "$INR_SYMBOL ${doubleToStringAsFixedForINR(e)}"),
    ].map((e) => clayCellChild(e)).toList();
    List<Widget> dueRow = [
      "Due",
      ...sectionWiseDueRowValues.map((e) => "$INR_SYMBOL ${doubleToStringAsFixedForINR(e)}"),
    ].map((e) => clayCellChild(e)).toList();
    List<List<double>> feeStatsForSection = sectionWiseTotalFeeRowValues.mapIndexed((index, totalFee) {
      double feeCollected = sectionWiseTotalFeeCollectedRowValues[index];
      double feeDue = sectionWiseDueRowValues[index];
      return [feeCollected, feeDue];
    }).toList();
    List<Widget> graphsRow = [
      clayCellChild("Graph"),
      ...feeStatsForSection.map((List<double> feeStats) {
        if (feeStats[0] == 0 && feeStats[1] == 0) {
          return clayCellChild("-");
        } else {
          return pieChart(feeStats);
        }
        // return clayCellChild("${feeStats[0]} - ${feeStats[1]} = ${feeStats[2]}");
      }).toList()
    ];
    List<List<Widget>> rows = [feeRow, collectedRow, dueRow];
    return clayDataTable(horizontalScrollController, columnSpacing, rowHeight, columnWidth, columns, rows, graphRow: graphsRow);
  }

  List<double> sectionWiseDueRow(Section section) {
    StudentBusFeeBean? sectionWiseBusFeeBean = sectionWiseFeeMap[section]!.studentBusFeeBean;
    return [
      ...(sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? []).map((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
        if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
          double amount = ((sectionAnnualFeeTypeBean.amount ?? 0) - (sectionAnnualFeeTypeBean.amountPaid ?? 0)) / 100.0;
          return [amount];
        } else {
          return (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])
              .map((StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) {
            double amount = ((sectionAnnualCustomFeeTypeBean.amount ?? 0) - (sectionAnnualCustomFeeTypeBean.amountPaid ?? 0)) / 100.0;
            return amount;
          });
        }
      }),
      if ((sectionWiseBusFeeBean?.fare ?? 0) > 0) [((((sectionWiseBusFeeBean?.fare ?? 0) - (sectionWiseBusFeeBean?.feePaid ?? 0)) / 100.0))],
      [
        (((sectionWiseFeeMap[section]!.totalFee ?? 0.0) - (sectionWiseFeeMap[section]!.totalFeePaid ?? 0.0)) / 100.0),
      ],
    ].expand((i) => i).toList();
  }

  List<double> sectionWiseTotalFeeCollectedRow(Section section) {
    StudentBusFeeBean? sectionWiseBusFeeBean = sectionWiseFeeMap[section]!.studentBusFeeBean;
    return [
      ...(sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? []).map((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
        if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
          double amount = (sectionAnnualFeeTypeBean.amountPaid ?? 0) / 100.0;
          return [amount];
        } else {
          return (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])
              .map((StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) {
            double amount = (sectionAnnualCustomFeeTypeBean.amountPaid ?? 0) / 100.0;
            return amount;
          });
        }
      }),
      if ((sectionWiseBusFeeBean?.fare ?? 0) > 0) [(((sectionWiseBusFeeBean?.feePaid ?? 0) / 100.0))],
      [
        ((sectionWiseFeeMap[section]!.totalFeePaid ?? 0.0) / 100.0),
      ],
    ].expand((i) => i).toList();
  }

  List<double> sectionWiseTotalFeeRow(Section section) {
    StudentBusFeeBean? sectionWiseBusFeeBean = sectionWiseFeeMap[section]!.studentBusFeeBean;
    return [
      ...(sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? []).map((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
        if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
          double amount = (sectionAnnualFeeTypeBean.amount ?? 0) / 100.0;
          return [amount];
        } else {
          return (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])
              .map((StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) {
            double amount = (sectionAnnualCustomFeeTypeBean.amount ?? 0) / 100.0;
            return amount;
          });
        }
      }),
      if ((sectionWiseBusFeeBean?.fare ?? 0) > 0) [(((sectionWiseBusFeeBean?.fare ?? 0) / 100.0))],
      [
        ((sectionWiseFeeMap[section]!.totalFee ?? 0.0) / 100.0),
      ],
    ].expand((i) => i).toList();
  }

  Widget pieChart(List<double> feeStats) {
    double feePaid = feeStats[0];
    double feeDue = feeStats[1];
    List<PaymentSummary> paymentSummary = [
      PaymentSummary("Due", feeDue, const charts.Color(r: 241, g: 196, b: 15)),
      PaymentSummary("Collected", feePaid, const charts.Color(r: 46, g: 204, b: 113)),
    ];
    return SizedBox(
      height: 35,
      width: 35,
      child: charts.PieChart<String>(
        [
          charts.Series<PaymentSummary, String>(
            id: 'PaymentSummary',
            domainFn: (PaymentSummary summary, _) => summary.type,
            measureFn: (PaymentSummary summary, _) => summary.amount,
            colorFn: (PaymentSummary summary, _) => summary.color,
            data: paymentSummary,
            labelAccessorFn: (PaymentSummary summary, _) => '$INR_SYMBOL ${doubleToStringAsFixedForINR(summary.amount)}',
          ),
        ],
        layoutConfig: charts.LayoutConfig(
          topMarginSpec: charts.MarginSpec.fromPixel(minPixel: 1),
          bottomMarginSpec: charts.MarginSpec.fromPixel(minPixel: 1),
          leftMarginSpec: charts.MarginSpec.fromPixel(minPixel: 1),
          rightMarginSpec: charts.MarginSpec.fromPixel(minPixel: 1),
        ),
        animate: true,
        defaultRenderer: charts.ArcRendererConfig(
          strokeWidthPx: 0.01,
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.inside,
            ),
          ],
        ),
      ),
    );
  }

  Scrollbar clayDataTable(
    ScrollController horizontalScrollController,
    double columnSpacing,
    double rowHeight,
    double columnWidth,
    List<String> columns,
    List<List<Widget>> rows, {
    List<Widget> graphRow = const [],
  }) {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 8,
      controller: horizontalScrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalScrollController,
        child: SingleChildScrollView(
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: DataTable(
              horizontalMargin: 0,
              dividerThickness: 0,
              columnSpacing: columnSpacing,
              dataRowHeight: rowHeight + 2 * columnSpacing,
              headingRowHeight: rowHeight + 2 * columnSpacing,
              columns: columns.map((e) => DataColumn(label: clayCell(text: e, height: rowHeight, width: columnWidth))).toList(),
              rows: [
                ...rows.map((e) => DataRow(cells: e.map((e) => DataCell(clayCell(child: e, height: rowHeight, width: columnWidth))).toList())),
                if (graphRow.isNotEmpty)
                  DataRow(
                    cells: graphRow
                        .map(
                          (e) => DataCell(
                            clayCell(
                              child: e,
                              height: rowHeight,
                              width: columnWidth,
                              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget clayCell({
    String? text,
    Widget? child,
    EdgeInsetsGeometry margin = const EdgeInsets.all(2),
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
    bool emboss = true,
    TextStyle textStyle = const TextStyle(fontSize: 12),
    double height = 45,
    double width = 90,
    TextAlign alignment = TextAlign.center,
  }) {
    return Container(
      margin: margin,
      child: text != null
          ? Tooltip(
              message: text,
              child: clayCellClayChild(emboss, height, width, padding, text, alignment, child),
            )
          : clayCellClayChild(emboss, height, width, padding, text, alignment, child),
    );
  }

  ClayContainer clayCellClayChild(
      bool emboss, double height, double width, EdgeInsetsGeometry padding, String? text, TextAlign alignment, Widget? child) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 5,
      emboss: emboss,
      height: height,
      width: width,
      child: Padding(
        padding: padding,
        child: text != null ? clayCellChild(text, alignment: alignment) : child!,
      ),
    );
  }

  Widget clayCellChild(
    String text, {
    TextAlign alignment = TextAlign.center,
  }) {
    return Center(
      child: AutoSizeText(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        minFontSize: 7,
        maxFontSize: 12,
        softWrap: true,
        textAlign: alignment,
      ),
    );
  }

  Widget cardViewWidget() {
    int perRowCount = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    return ListView(
      children: [
        for (int i = 0; i < sections.length / perRowCount; i = i + 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int j = 0; j < perRowCount; j++)
                Expanded(
                  child: ((i * perRowCount + j) >= sections.length) ? Container() : sectionCard(sections[(i * perRowCount + j)]),
                ),
            ],
          ),
      ],
    );
  }

  Widget sectionCard(Section section) {
    String sectionName = section.sectionName ?? "-";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              embossedClayTitleWidget(schoolNameText(sectionName)),
              const SizedBox(height: 8),
              ...(sectionWiseFeeMap[section]!.studentAnnualFeeTypeBeans ?? []).map((StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean) {
                if ((sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
                  return feeTypeWiseWidget(
                    sectionAnnualFeeTypeBean,
                    sectionWiseModeOfPaymentMap[section]!,
                  );
                } else {
                  return customFeeTypeWiseWidgets(sectionAnnualFeeTypeBean, sectionWiseModeOfPaymentMap[section]!);
                }
              }).expand((i) => i.whereNotNull()),
              ...busFeeTypeWidget(sectionWiseFeeMap[section]!, sectionWiseModeOfPaymentMap[section]!).whereNotNull(),
            ],
          ),
        ),
      ),
    );
  }

  Widget embossedClayTitleWidget(Widget child) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      emboss: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Text schoolNameText(String sectionName) {
    return Text(
      sectionName,
      style: GoogleFonts.archivoBlack(
        textStyle: const TextStyle(
          fontSize: 24,
          color: Colors.blue,
        ),
      ),
    );
  }

  List<Widget?> busFeeTypeWidget(
    StudentAnnualFeeBean sectionAnnualFeeBean,
    Map<String, Map<ModeOfPayment, int>> modeOfPaymentMap,
  ) {
    String feeTypeKey = "-|-";
    String feeType = "Bus";
    double totalAmount = (sectionAnnualFeeBean.studentBusFeeBean?.fare ?? 0) / 100.0;
    double totalAmountPaid = (sectionAnnualFeeBean.studentBusFeeBean?.feePaid ?? 0) / 100.0;
    double totalAmountToBePaid =
        ((sectionAnnualFeeBean.studentBusFeeBean?.fare ?? 0) - (sectionAnnualFeeBean.studentBusFeeBean?.feePaid ?? 0)) / 100.0;
    if (totalAmount == 0) return [null];
    return [
      feeTypeWiseAmountPaidWidgetForSection(
        feeType,
        totalAmount,
        totalAmountPaid,
        totalAmountToBePaid,
        feeTypeKey,
        modeOfPaymentMap[feeTypeKey]!,
      )
    ];
  }

  List<Widget?> customFeeTypeWiseWidgets(
    StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean,
    Map<String, Map<ModeOfPayment, int>> modeOfPaymentMap,
  ) {
    return (sectionAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? []).map((StudentAnnualCustomFeeTypeBean sectionAnnualCustomFeeTypeBean) {
      String feeTypeKey = "${sectionAnnualFeeTypeBean.feeTypeId}|${sectionAnnualCustomFeeTypeBean.customFeeTypeId}";
      String feeType = "${sectionAnnualFeeTypeBean.feeType} : ${sectionAnnualCustomFeeTypeBean.customFeeType ?? " - "}";
      double totalAmount = (sectionAnnualCustomFeeTypeBean.amount ?? 0) / 100.0;
      double totalAmountPaid = (sectionAnnualCustomFeeTypeBean.amountPaid ?? 0) / 100.0;
      double totalAmountToBePaid = ((sectionAnnualCustomFeeTypeBean.amount ?? 0) - (sectionAnnualCustomFeeTypeBean.amountPaid ?? 0)) / 100.0;
      if (totalAmount == 0) return null;
      return feeTypeWiseAmountPaidWidgetForSection(
        feeType,
        totalAmount,
        totalAmountPaid,
        totalAmountToBePaid,
        feeTypeKey,
        modeOfPaymentMap[feeTypeKey]!,
      );
    }).toList();
  }

  List<Widget?> feeTypeWiseWidget(
    StudentAnnualFeeTypeBean sectionAnnualFeeTypeBean,
    Map<String, Map<ModeOfPayment, int>> modeOfPaymentMap,
  ) {
    String feeTypeKey = "${sectionAnnualFeeTypeBean.feeTypeId}|-";
    String feeType = sectionAnnualFeeTypeBean.feeType ?? "-";
    double totalAmount = (sectionAnnualFeeTypeBean.amount ?? 0) / 100.0;
    double totalAmountPaid = (sectionAnnualFeeTypeBean.amountPaid ?? 0) / 100.0;
    double totalAmountToBePaid = ((sectionAnnualFeeTypeBean.amount ?? 0) - (sectionAnnualFeeTypeBean.amountPaid ?? 0)) / 100.0;
    if (totalAmount == 0) return [null];
    return [
      feeTypeWiseAmountPaidWidgetForSection(
        feeType,
        totalAmount,
        totalAmountPaid,
        totalAmountToBePaid,
        feeTypeKey,
        modeOfPaymentMap[feeTypeKey]!,
      )
    ];
  }

  Widget feeTypeWiseAmountPaidWidgetForSection(
    String feeType,
    double totalAmount,
    double totalAmountPaid,
    double totalAmountToBePaid,
    String feeTypeKey,
    Map<ModeOfPayment, int> modeOfPaymentMap,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(feeType),
              ),
              const SizedBox(height: 8),
              feePaidAndToBePaidWidget(totalAmount, totalAmountPaid, totalAmountToBePaid),
              const SizedBox(height: 8),
              ClayContainer(
                depth: 40,
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ...modeOfPaymentMap.keys.map((ModeOfPayment modeOfPayment) {
                        double amount = (modeOfPaymentMap[modeOfPayment] ?? 0) / 100.0;
                        if (amount == 0) return null;
                        return modeOfPaymentWiseAmountPaidWidget(modeOfPayment, amount);
                      }).whereNotNull(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget feePaidAndToBePaidWidget(double totalAmount, double totalAmountPaid, double totalAmountToBePaid) {
    return ClayContainer(
      depth: 40,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 1,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Total",
                    style: TextStyle(color: Colors.blue, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 4),
                Text("-"),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Collected",
                    style: TextStyle(color: Colors.green, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 4),
                Text("="),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Due",
                    style: TextStyle(color: Colors.red, fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 4),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalAmount)}",
                    style: const TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
                const Text("-"),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalAmountPaid)}",
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
                const Text("="),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalAmountToBePaid)}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Padding modeOfPaymentWiseAmountPaidWidget(ModeOfPayment modeOfPayment, double amount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              modeOfPayment.description,
              style: const TextStyle(
                // color: ModeOfPaymentExt.getColorForModeOfPayment(modeOfPayment),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR(amount)}",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget oldDownloadButton() {
    return GestureDetector(
      onTap: () async {
        await downloadReport();
      },
      child: const Icon(Icons.download),
    );
  }

  Future<void> downloadReport() async {
    setState(() => _isLoading = true);
    List<int> bytes = await detailedFeeReport(
      GetStudentWiseAnnualFeesRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
      FeeReportType.sectionWiseTermWiseForAllStudents,
    );
    AnchorElement(href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "Section wise due report")
      ..click();
    setState(() => _isLoading = false);
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
      sections.forEach((eachSection) {
        sectionWiseScrollControllerForTotalFeeTable[eachSection] = ScrollController();
        sectionWiseScrollControllerForModeOfPayments[eachSection] = ScrollController();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    if (studentFeeReceipts.isEmpty) {
      GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
        schoolId: widget.adminProfile.schoolId,
      ));
      if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        studentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).where((er) => er.status == "active").toList();
        studentFeeReceipts.sort((b, a) {
          int dateCom = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
          return (dateCom == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateCom;
        });
      }
    }
    await generateStudentMap();
    generateSectionMap();
    generateModeOfPaymentMap();
    setState(() => _isLoading = false);
  }

  void generateModeOfPaymentMap() {
    setState(() => _isLoading = true);
    sectionWiseModeOfPaymentMap = {};
    for (Section eachSection in sections) {
      List<StudentFeeReceipt> sectionWiseReceipts = studentFeeReceipts.where((e) {
        return e.sectionId == eachSection.sectionId && filterStudents(e.studentId ?? -1);
      }).toList();
      Map<ModeOfPayment, Map<String, int>> x = {};
      ModeOfPayment.values.forEach((eachModeOfPayment) {
        x[eachModeOfPayment] = {};
        feeTypes.forEach((eachFeeType) {
          if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
            String key = "${eachFeeType.feeTypeId}|-";
            x[eachModeOfPayment]![key] = 0;
          } else {
            (eachFeeType.customFeeTypesList ?? []).forEach((eachCustomFeeType) {
              String key = "${eachFeeType.feeTypeId}|${eachCustomFeeType?.customFeeTypeId}";
              x[eachModeOfPayment]![key] = 0;
            });
          }
        });
        x[eachModeOfPayment]!["-|-"] = 0;
      });
      sectionWiseReceipts.forEach((eachReceipt) {
        ModeOfPayment modeOfPayment = ModeOfPaymentExt.fromString(eachReceipt.modeOfPayment);
        (eachReceipt.feeTypes ?? []).forEach((eachFeeType) {
          if ((eachFeeType?.customFeeTypes ?? []).isEmpty) {
            String key = "${eachFeeType?.feeTypeId}|-";
            x[modeOfPayment]![key] = x[modeOfPayment]![key]! + (eachFeeType?.amountPaidForTheReceipt ?? 0);
          } else {
            (eachFeeType?.customFeeTypes ?? []).forEach((eachCustomFeeType) {
              String key = "${eachFeeType?.feeTypeId}|${eachCustomFeeType?.customFeeTypeId}";
              x[modeOfPayment]![key] = x[modeOfPayment]![key]! + (eachCustomFeeType?.amountPaidForTheReceipt ?? 0);
            });
          }
        });
        x[modeOfPayment]!["-|-"] = x[modeOfPayment]!["-|-"]! + (eachReceipt.busFeePaid ?? 0);
      });
      sectionWiseModeOfPaymentMap[eachSection] = transformMap(x);
    }
    sectionWiseModeOfPaymentMap.forEach((_, sectionMap) {
      sectionMap.forEach((feeTypeKey, modeOfPaymentMap) {
        if (!schoolWiseModeOfPaymentMap.containsKey(feeTypeKey)) {
          schoolWiseModeOfPaymentMap[feeTypeKey] = {};
        }
        modeOfPaymentMap.forEach((modeOfPayment, amount) {
          schoolWiseModeOfPaymentMap[feeTypeKey]![modeOfPayment] = (schoolWiseModeOfPaymentMap[feeTypeKey]![modeOfPayment] ?? 0) + amount;
        });
      });
    });
    double busFee = 0.0;
    for (int i = 0; i < sections.length; i++) {
      Section section = sections[i];
      StudentBusFeeBean? sectionWiseBusFeeBean = sectionWiseFeeMap[section]!.studentBusFeeBean;
      busFee += (sectionWiseBusFeeBean?.fare ?? 0) / 100.0;
    }
    if (busFee == 0) {
      schoolWiseModeOfPaymentMap.remove("-|-");
    }
    setState(() => _isLoading = false);
  }

  bool filterStudents(int studentId) {
    // return true;
    StudentProfile? es = studentProfiles.firstWhereOrNull((es) => es.studentId == studentId);
    bool studentsStatusFilter = studentStatusFilterType == "A"
        ? es?.status == "active"
        : studentStatusFilterType == "D"
            ? es?.status == "inactive"
            : true;
    return studentsStatusFilter;
  }

  Map<String, Map<ModeOfPayment, int>> transformMap(Map<ModeOfPayment, Map<String, int>> inputMap) {
    // Create the result map
    Map<String, Map<ModeOfPayment, int>> resultMap = {};

    // Iterate through the outer map
    inputMap.forEach((modeOfPayment, sectionMap) {
      sectionMap.forEach((section, value) {
        // Get the map for the section from the result map or create a new one
        resultMap.putIfAbsent(section, () => {});
        // Add the value to the corresponding ModeOfPayment in the section
        resultMap[section]![modeOfPayment] = (resultMap[section]![modeOfPayment] ?? 0) + value;
      });
    });

    return resultMap;
  }

  void generateSectionMap() {
    setState(() => _isLoading = true);
    for (Section eachSection in sections) {
      List<StudentAnnualFeeBean> sectionWiseStudentsList = studentAnnualFeeBeans.where((e) {
        bool sectionFilter = e.sectionId == eachSection.sectionId;
        bool studentsStatusFilter = filterStudents(e.studentId ?? -1);
        return sectionFilter && studentsStatusFilter;
      }).toList();
      List<StudentAnnualFeeTypeBean> feeTypeWiseFeePaidList = [];
      for (FeeType eachFeeType in feeTypes) {
        List<StudentAnnualCustomFeeTypeBean> customFeeTypeWiseFeePaidList = [];
        if ((eachFeeType.customFeeTypesList ?? []).isNotEmpty) {
          List<StudentAnnualCustomFeeTypeBean> customFeeTypeList = sectionWiseStudentsList
              .map((e) => e.studentAnnualFeeTypeBeans ?? [])
              .expand((i) => i)
              .where((e) => e.feeTypeId == eachFeeType.feeTypeId)
              .map((e) => e.studentAnnualCustomFeeTypeBeans ?? [])
              .expand((i) => i)
              .toList();
          for (CustomFeeType eachCustomFeeType in (eachFeeType.customFeeTypesList ?? []).whereNotNull()) {
            customFeeTypeWiseFeePaidList.add(StudentAnnualCustomFeeTypeBean(
              customFeeTypeId: eachCustomFeeType.customFeeTypeId,
              customFeeType: eachCustomFeeType.customFeeType,
              amount: customFeeTypeList
                  .where((e) => e.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                  .map((e) => e.amount ?? 0)
                  .fold(0, (int? a, b) => (a ?? 0) + b),
              amountPaid: customFeeTypeList
                  .where((e) => e.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                  .map((e) => e.amountPaid ?? 0)
                  .fold(0, (int? a, b) => (a ?? 0) + b),
              discount: customFeeTypeList
                  .where((e) => e.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                  .map((e) => e.discount ?? 0)
                  .fold(0, (int? a, b) => (a ?? 0) + b),
            ));
          }
        }
        feeTypeWiseFeePaidList.add(StudentAnnualFeeTypeBean(
          feeTypeId: eachFeeType.feeTypeId,
          feeType: eachFeeType.feeType,
          amount: sectionWiseStudentsList
              .map((e) => e.studentAnnualFeeTypeBeans ?? [])
              .expand((i) => i)
              .where((e) => e.feeTypeId == eachFeeType.feeTypeId)
              .map((e) => e.amount ?? 0)
              .fold(0, (int? a, b) => (a ?? 0) + b),
          amountPaid: sectionWiseStudentsList
              .map((e) => e.studentAnnualFeeTypeBeans ?? [])
              .expand((i) => i)
              .where((e) => e.feeTypeId == eachFeeType.feeTypeId)
              .map((e) => e.amountPaid ?? 0)
              .fold(0, (int? a, b) => (a ?? 0) + b),
          discount: sectionWiseStudentsList
              .map((e) => e.studentAnnualFeeTypeBeans ?? [])
              .expand((i) => i)
              .where((e) => e.feeTypeId == eachFeeType.feeTypeId)
              .map((e) => e.discount ?? 0)
              .fold(0, (int? a, b) => (a ?? 0) + b),
          studentAnnualCustomFeeTypeBeans: customFeeTypeWiseFeePaidList,
        ));
      }
      sectionWiseFeeMap[eachSection] = StudentAnnualFeeBean(
        sectionId: eachSection.sectionId,
        status: 'computed',
        studentAnnualFeeTypeBeans: feeTypeWiseFeePaidList,
        studentBusFeeBean: StudentBusFeeBean(
          fare: sectionWiseStudentsList.map((e) => e.studentBusFeeBean).whereNotNull().map((e) => e.fare ?? 0).fold(0, (int? a, b) => (a ?? 0) + b),
          feePaid:
              sectionWiseStudentsList.map((e) => e.studentBusFeeBean).whereNotNull().map((e) => e.feePaid ?? 0).fold(0, (int? a, b) => (a ?? 0) + b),
        ),
        totalFee: sectionWiseStudentsList.map((e) => e.totalFee ?? 0).fold(0, (int? a, b) => (a ?? 0) + b),
        totalFeePaid: sectionWiseStudentsList.map((e) => e.totalFeePaid ?? 0).fold(0, (int? a, b) => (a ?? 0) + b),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> generateStudentMap() async {
    List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
    setState(() {
      _isLoading = true;
    });
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
      studentProfiles = studentWiseAnnualFeesBeans
          .map((e) => StudentProfile(
                studentId: e.studentId,
                studentFirstName: e.studentName,
                sectionId: e.sectionId,
                sectionName: e.sectionName,
                status: e.status,
                rollNumber: e.rollNumber,
              ))
          .toList();
    }
    studentAnnualFeeBeans = [];
    studentWiseAnnualFeesBeans.sort((a, b) => ((int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))));
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
    // studentAnnualFeeBeans = studentAnnualFeeBeans.where((e) => e.status != "inactive").toList();
    studentAnnualFeeBeans.sort(
      (a, b) => (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0),
    );
    setState(() {
      _isLoading = false;
    });
  }
}

class PaymentSummary {
  final String type;
  final double amount;
  final charts.Color color;

  PaymentSummary(this.type, this.amount, this.color);
}
