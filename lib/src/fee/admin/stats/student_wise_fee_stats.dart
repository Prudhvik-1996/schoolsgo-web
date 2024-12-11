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
import 'package:table_sticky_headers/table_sticky_headers.dart';

import 'new.dart';

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
  List<FeeType> feeTypes = [];
  List<StudentProfile> studentProfiles = [];
  List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];

  Map<String, String> feeTypeHeaderMap = {};

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
          : Column(
              children: [
                if (_showFilter && !_isLoading) filterWidget(),
                Expanded(
                  // child: studentFeeDetailsTable(),
                  child: newTable(),
                ),
              ],
            ),
      // floatingActionButton: fab(Icon(Icons.settings), "Filters", () => null),
    );
  }

  Widget newTable() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PaginatedDataTable2(
        smRatio: 0.5,
        lmRatio: 2,
        horizontalMargin: 0,
        columnSpacing: 20,
        wrapInCard: false,
        renderEmptyRowsInTheEnd: false,
        fixedLeftColumns: 2,
        fixedTopRows: 1,
        minWidth: 2400,
        dataRowHeight: 30,
        fit: FlexFit.loose,
        autoRowsToHeight: true,
        border: TableBorder(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
          left: BorderSide(color: Colors.grey[300]!),
          right: BorderSide(color: Colors.grey[300]!),
          verticalInside: BorderSide(color: Colors.grey[300]!),
          horizontalInside: const BorderSide(color: Colors.grey, width: 1),
        ),
        columns: [
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      e,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        source: StudentRowDataSource(
          context,
          studentAnnualFeeBeans.map((e) {
            Map<String, String> studentMap = {};
            studentMap["Section"] = e.sectionName ?? "-";
            studentMap["Student Name"] = "${e.rollNumber ?? "-"}. ${e.studentName ?? " - "}";
            for (String eachKey in feeTypeHeaderMap.keys) {
              int? feeTypeId = int.tryParse(eachKey.split("|")[0]);
              int? customFeeTypeId = int.tryParse(eachKey.split("|")[1]);
              String kind = eachKey.split("|")[2];
              studentMap[eachKey] = getStudentFeeDetail(e, feeTypeId, customFeeTypeId, kind);
            }
            return studentMap;
          }).toList(),
          false,
          true,
        ),
      ),
    );
  }

  Widget studentFeeDetailsTable() {
    List<String> feeTypeKeys = feeTypeHeaderMap.keys.toList();
    List<String> columnNames = ["Section", ...feeTypeHeaderMap.values];
    double marksObtainedCellWidth = 150;
    double legendCellWidth = MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 150;
    double stickyLegendHeight = 80;
    double defaultCellHeight = 40;
    List<StudentAnnualFeeBean> studentsToShow = studentAnnualFeeBeans.getRange(0, 10).toList();
    return StickyHeadersTable(
      cellDimensions: CellDimensions.variableColumnWidth(
        columnWidths: [...columnNames.map((e) => marksObtainedCellWidth)],
        contentCellHeight: defaultCellHeight,
        stickyLegendWidth: legendCellWidth,
        stickyLegendHeight: stickyLegendHeight,
      ),
      showHorizontalScrollbar: true,
      showVerticalScrollbar: true,
      columnsLength: columnNames.length,
      rowsLength: studentsToShow.length + 1,
      legendCell: clayCell(
        child: const Center(
          child: Text(
            "Student",
            style: TextStyle(fontSize: 12),
          ),
        ),
        emboss: true,
      ),
      columnsTitleBuilder: (int colIndex) => clayCell(
        child: Center(
          child: Text(
            columnNames[colIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        emboss: true,
      ),
      rowsTitleBuilder: (int rowIndex) {
        if (rowIndex == studentsToShow.length) {
          return const Text("");
        }
        StudentAnnualFeeBean eachStudent = studentsToShow[rowIndex];
        return clayCell(
          emboss: true,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text("${eachStudent.rollNumber}. ${eachStudent.studentName}")),
              ],
            ),
          ),
        );
      },
      contentCellBuilder: (int columnIndex, int rowIndex) {
        if (rowIndex == studentsToShow.length) {
          return const Text("");
        }
        StudentAnnualFeeBean eachStudent = studentsToShow[rowIndex];
        if (columnIndex == 0) {
          return clayCell(
            emboss: true,
            child: Center(
              child: Text(eachStudent.sectionName ?? "-"),
            ),
          );
        }
        String feeTypeKeyIndex = feeTypeKeys[columnIndex - 1];
        int? feeTypeId = int.tryParse(feeTypeKeyIndex.split("|")[0]);
        int? customFeeTypeId = int.tryParse(feeTypeKeyIndex.split("|")[1]);
        String kind = feeTypeKeyIndex.split("|")[2];
        return clayCell(
          emboss: true,
          child: Center(
            child: Text(
              getStudentFeeDetail(eachStudent, feeTypeId, customFeeTypeId, kind),
            ),
          ),
        );
      },
    );
  }

  String getStudentFeeDetail(StudentAnnualFeeBean eachStudent, int? feeTypeId, int? customFeeTypeId, String kind) {
    double amount = 0.0;
    if (feeTypeId == null && customFeeTypeId == null) {
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

  Widget filterWidget() => Container();

  bool filterStudents(int i) {
    return true;
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSectionsResponse getSectionsResponse = await getSections(
      GetSectionsRequest(
        schoolId: widget.adminProfile.schoolId,
      ),
    );
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      sections = getSectionsResponse.sections!.map((e) => e!).toList();
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
    studentAnnualFeeBeans.removeWhere((e) {
      bool studentsStatusFilter = e.status == 'active' && filterStudents(e.studentId ?? -1);
      return !studentsStatusFilter;
    });
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
    _isBusFeeApplicable = (studentAnnualFeeBeans.map((e) => e.studentBusFeeBean?.fare ?? 0).fold(0, (int? a, b) => (a ?? 0) + b)) > 0;
    // feeTypeHeaderMap
    for (FeeType eachFeeType in feeTypes) {
      if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
        feeTypeHeaderMap[feeKey(eachFeeType.feeTypeId, null)] = eachFeeType.feeType ?? "-";
        feeTypeHeaderMap[collectedKey(eachFeeType.feeTypeId, null)] = "${eachFeeType.feeType ?? " - "}\nCollected";
        feeTypeHeaderMap[dueKey(eachFeeType.feeTypeId, null)] = "${eachFeeType.feeType ?? " - "}\nDue";
      } else {
        for (CustomFeeType eachCustomFeeType in (eachFeeType.customFeeTypesList ?? []).whereNotNull()) {
          feeTypeHeaderMap[feeKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] =
              "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}";
          feeTypeHeaderMap[collectedKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] =
              "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}\nCollected";
          feeTypeHeaderMap[dueKey(eachFeeType.feeTypeId, eachCustomFeeType.customFeeTypeId)] =
              "${eachFeeType.feeType ?? " - "}\n${eachCustomFeeType.customFeeType ?? " - "}\nDue";
        }
      }
    }
    if (_isBusFeeApplicable) {
      feeTypeHeaderMap[feeKey(null, null)] = "Bus Fee";
      feeTypeHeaderMap[collectedKey(null, null)] = "Bus Fee\nCollected";
      feeTypeHeaderMap[dueKey(null, null)] = "Bus Fee\nDue";
    }
    setState(() => _isLoading = false);
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
}
