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
  List<FeeType> feeTypes = [];
  List<StudentProfile> studentProfiles = [];
  List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];

  Map<String, String> feeTypeHeaderMap = {};

  final PaginatorController _controller = PaginatorController();
  int? selectedIndex;
  bool areColumnsFrozen = false;

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
      body: _isLoading ? const EpsilonDiaryLoadingWidget() : newTable(),
      // floatingActionButton: fab(Icon(Icons.settings), "Filters", () => null),
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
                color: Colors.grey[200],
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
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () async {
            await showFiltersAction();
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
          child: ClayContainer(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 5,
            emboss: false,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Student Fee Stats",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Future<void> showFiltersAction() async {
    //  TODO
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

  bool filterStudents(int i) {
    return true;
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
    feeTypeHeaderMap[totalFeeKey()] = "Total\nFee";
    feeTypeHeaderMap[totalFeeCollectedKey()] = "Total\nCollected";
    feeTypeHeaderMap[totalFeeDueKey()] = "Total\nDue";
    setState(() => _isLoading = false);
  }

  String totalFeeKey() => "-2|-2|fee";

  String totalFeeCollectedKey() => "-2|-2|collected";

  String totalFeeDueKey() => "-2|-2|due";

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
