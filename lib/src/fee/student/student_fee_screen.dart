// ignore: implementation_imports
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/basic_fee_stats_widget.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';

class StudentFeeScreen extends StatefulWidget {
  const StudentFeeScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  @override
  State<StudentFeeScreen> createState() => _StudentFeeScreenState();
}

class _StudentFeeScreenState extends State<StudentFeeScreen> {
  bool _isLoading = true;
  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];
  List<StudentWiseAnnualFeesBean> studentWiseAnnualFeesBeans = [];
  List<FeeType> feeTypes = [];
  List<FeeType> feeTypesForSelectedSection = [];
  List<SectionWiseAnnualFeesBean> sectionWiseAnnualFeeBeansList = [];
  StudentWiseTermFeesBean? studentWiseTermFeesBean;

  late StudentProfile studentProfile;

  late _StudentWiseAnnualTransactionHistory studentWiseAnnualTransactionHistory;

  List<String> allMasterTransactionIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetSectionWiseAnnualFeesResponse getSectionWiseAnnualFeesResponse = await getSectionWiseAnnualFees(GetSectionWiseAnnualFeesRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
    ));
    if (getSectionWiseAnnualFeesResponse.httpStatus != "OK" || getSectionWiseAnnualFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        sectionWiseAnnualFeeBeansList = (getSectionWiseAnnualFeesResponse.sectionWiseAnnualFeesBeanList ?? []).map((e) => e!).toList();
      });
    }
    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.studentProfile.schoolId,
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
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
      studentId: widget.studentProfile.studentId,
    ));
    if (getStudentWiseAnnualFeesResponse.httpStatus != "OK" || getStudentWiseAnnualFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentWiseAnnualFeesBeans = getStudentWiseAnnualFeesResponse.studentWiseAnnualFeesBeanList!.map((e) => e!).toList();
      });
    }
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      studentId: widget.studentProfile.studentId,
      sectionId: widget.studentProfile.sectionId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentProfile = getStudentProfileResponse.studentProfiles!.map((e) => e!).toList().first;
      });
    }
    GetStudentWiseTermFeesResponse getStudentWiseTermFeesResponse = await getStudentWiseTermFees(GetStudentWiseTermFeesRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
      studentId: widget.studentProfile.studentId,
    ));
    if (getStudentWiseTermFeesResponse.httpStatus == "OK" && getStudentWiseTermFeesResponse.responseStatus == "success") {
      setState(() {
        studentWiseTermFeesBean = (getStudentWiseTermFeesResponse.studentWiseTermFeesBeanList ?? [])
            .where((StudentWiseTermFeesBean? e) => e != null)
            .map((StudentWiseTermFeesBean? e) => e!)
            .toList()
            .firstOrNull;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong, Please try again later.."),
        ),
      );
    }
    generateStudentMap();
    setState(() {
      _isLoading = false;
    });
  }

  void generateStudentMap() {
    setState(() {
      for (var eachFeeType in feeTypes) {
        if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
          if (sectionWiseAnnualFeeBeansList
              .where((e) => e.sectionId == widget.studentProfile.sectionId)
              .toList()
              .map((e) => e.feeTypeId)
              .contains(eachFeeType.feeTypeId)) {
            feeTypesForSelectedSection.add(eachFeeType);
          }
        } else {
          if (sectionWiseAnnualFeeBeansList
              .where((e) => e.sectionId == widget.studentProfile.sectionId)
              .toList()
              .map((e) => e.feeTypeId)
              .contains(eachFeeType.feeTypeId)) {
            feeTypesForSelectedSection.add(eachFeeType);
            (feeTypesForSelectedSection.last.customFeeTypesList ?? []).where((e) => e != null).map((e) => e!).forEach((eachCustomFeeType) {
              if (!sectionWiseAnnualFeeBeansList
                  .where((e) => e.sectionId == widget.studentProfile.sectionId)
                  .toList()
                  .map((e) => e.customFeeTypeId)
                  .contains(eachCustomFeeType.customFeeTypeId)) {
                (feeTypesForSelectedSection.last.customFeeTypesList ?? []).remove(eachCustomFeeType);
              }
            });
          }
        }
      }
      studentWiseAnnualFeesBeans.sorted((a, b) => ((int.tryParse(a.rollNumber ?? "") ?? 0).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))));
      studentAnnualFeeBeans = [];
      for (StudentWiseAnnualFeesBean eachAnnualFeeBean in studentWiseAnnualFeesBeans) {
        studentAnnualFeeBeans.add(StudentAnnualFeeBean(
          studentId: eachAnnualFeeBean.studentId,
          rollNumber: eachAnnualFeeBean.rollNumber,
          studentName: eachAnnualFeeBean.studentName,
          totalFee: eachAnnualFeeBean.actualFee,
          totalFeePaid: eachAnnualFeeBean.feePaid,
          walletBalance: eachAnnualFeeBean.studentWalletBalance,
          sectionId: eachAnnualFeeBean.sectionId,
          sectionName: eachAnnualFeeBean.sectionName,
          studentBusFeeBean: eachAnnualFeeBean.studentBusFeeBean,
          studentAnnualFeeTypeBeans: feeTypesForSelectedSection
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
                  discount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                      .map((e) => e!)
                      .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                          eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                      .firstOrNull
                      ?.discount,
                  comments: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                      .map((e) => e!)
                      .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                          eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                      .firstOrNull
                      ?.comments,
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
                          discount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                              .map((e) => e!)
                              .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                  eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                  eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                              .firstOrNull
                              ?.discount,
                          comments: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                              .map((e) => e!)
                              .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                                  eachStudentAnnualFeeMapBean.feeTypeId == eachCustomFeeType.feeTypeId &&
                                  eachStudentAnnualFeeMapBean.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
                              .firstOrNull
                              ?.comments,
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
        ));
      }

      setState(() {
        allMasterTransactionIds = studentWiseTermFeesBean?.studentTermFeeMapBeanList
                ?.where((e) => e?.masterTransactionId != null)
                .map((e) => e!.masterTransactionId!)
                .toSet()
                .toList() ??
            [];

        studentWiseAnnualTransactionHistory = _StudentWiseAnnualTransactionHistory(
          sectionId: studentProfile.sectionId,
          sectionName: studentProfile.sectionName,
          masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans: allMasterTransactionIds
              .map((eachMasterTransactionId) => _MasterTransactionIdWiseStudentTermWiseTransactionHistory(
                    masterTransactionId: eachMasterTransactionId,
                    masterTransactionDate: studentWiseTermFeesBean?.studentTermFeeMapBeanList
                        ?.where((e) => e?.masterTransactionId == eachMasterTransactionId)
                        .firstOrNull
                        ?.masterTransactionDate,
                    studentTermWiseTransactionHistory: [],
                  ))
              .toList(),
          studentProfile: studentProfile,
        );

        studentWiseTermFeesBean?.studentTermFeeMapBeanList
            ?.where((e) => e != null)
            .map((e) => e!)
            .forEach((StudentWiseTermFeeMapBean eachStudentWiseTermFeeMapBean) {
          studentWiseAnnualTransactionHistory.masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans
              ?.where((e) => e.masterTransactionId == eachStudentWiseTermFeeMapBean.masterTransactionId)
              .forEach((_MasterTransactionIdWiseStudentTermWiseTransactionHistory eachMasterTransactionIdWiseStudentTermWiseTransactionHistory) {
            if (!eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.studentTermWiseTransactionHistory!
                .map((e) => e.termId)
                .contains(eachStudentWiseTermFeeMapBean.termId)) {
              eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.studentTermWiseTransactionHistory!.add(_StudentTermWiseTransactionHistory(
                termId: eachStudentWiseTermFeeMapBean.termId,
                termName: eachStudentWiseTermFeeMapBean.termName,
                studentTermWiseFeeTypeTransactionHistory: [],
              ));
            }
          });
        });

        studentWiseTermFeesBean?.studentTermFeeMapBeanList
            ?.where((e) => e != null)
            .map((e) => e!)
            .forEach((StudentWiseTermFeeMapBean eachStudentWiseTermFeeMapBean) {
          studentWiseAnnualTransactionHistory.masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans
              ?.where((e) => e.masterTransactionId == eachStudentWiseTermFeeMapBean.masterTransactionId)
              .forEach((_MasterTransactionIdWiseStudentTermWiseTransactionHistory eachMasterTransactionIdWiseStudentTermWiseTransactionHistory) {
            eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.studentTermWiseTransactionHistory
                ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
              if (!eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory!
                  .map((e) => e.feeTypeId)
                  .contains(eachStudentWiseTermFeeMapBean.feeTypeId)) {
                eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory!.add(_StudentTermWiseFeeTypeTransactionHistory(
                  termId: eachStudentWiseTermFeeMapBean.termId,
                  feeTypeId: eachStudentWiseTermFeeMapBean.feeTypeId,
                  feeType: eachStudentWiseTermFeeMapBean.feeType,
                  studentTermWiseCustomFeeTypeTransactionHistory: [],
                  transactions: [],
                ));
              }
              if (eachStudentWiseTermFeeMapBean.customFeeTypeId == null) {
                eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory
                    ?.where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId)
                    .forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
                  eachStudentTermWiseFeeTypeTransactionHistory.transactions!.add(_FeeTypeTransaction(
                    feePaidId: eachStudentWiseTermFeeMapBean.feePaidId,
                    feeTypeId: eachStudentWiseTermFeeMapBean.feeTypeId,
                    feeType: eachStudentWiseTermFeeMapBean.feeType,
                    masterTransactionId: eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.masterTransactionId,
                    transactionId: eachStudentWiseTermFeeMapBean.transactionId,
                    amount: eachStudentWiseTermFeeMapBean.feePaid,
                    modeOfPayment: eachStudentWiseTermFeeMapBean.modeOfPayment,
                    type: eachStudentWiseTermFeeMapBean.transactionType,
                    transactionDescription: eachStudentWiseTermFeeMapBean.transactionDescription,
                    kind: eachStudentWiseTermFeeMapBean.transactionKind,
                    transactionTime: eachStudentWiseTermFeeMapBean.paymentDate,
                  ));
                });
              } else {
                eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory
                    ?.where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId)
                    .forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
                  if (!eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                      .map((e) => e.customFeeTypeId)
                      .contains(eachStudentWiseTermFeeMapBean.customFeeTypeId)) {
                    eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                        ?.add(_StudentTermWiseCustomFeeTypeTransactionHistory(
                      termId: eachStudentWiseTermFeeMapBean.termId,
                      feeTypeId: eachStudentWiseTermFeeMapBean.feeTypeId,
                      feeType: eachStudentWiseTermFeeMapBean.feeType,
                      customFeeTypeId: eachStudentWiseTermFeeMapBean.customFeeTypeId,
                      customFeeType: eachStudentWiseTermFeeMapBean.customFeeType,
                      transactions: [],
                    ));
                  }
                  eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                      ?.where((e) => e.customFeeTypeId == eachStudentWiseTermFeeMapBean.customFeeTypeId)
                      .forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
                    eachStudentTermWiseCustomFeeTypeTransactionHistory.transactions?.add(_CustomFeeTypeTransaction(
                      feePaidId: eachStudentWiseTermFeeMapBean.feePaidId,
                      feeTypeId: eachStudentWiseTermFeeMapBean.feeTypeId,
                      feeType: eachStudentWiseTermFeeMapBean.feeType,
                      customFeeTypeId: eachStudentWiseTermFeeMapBean.customFeeTypeId,
                      customFeeType: eachStudentWiseTermFeeMapBean.customFeeType,
                      masterTransactionId: eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.masterTransactionId,
                      transactionId: eachStudentWiseTermFeeMapBean.transactionId,
                      amount: eachStudentWiseTermFeeMapBean.feePaid,
                      modeOfPayment: eachStudentWiseTermFeeMapBean.modeOfPayment,
                      type: eachStudentWiseTermFeeMapBean.transactionType,
                      transactionDescription: eachStudentWiseTermFeeMapBean.transactionDescription,
                      kind: eachStudentWiseTermFeeMapBean.transactionKind,
                      transactionTime: eachStudentWiseTermFeeMapBean.paymentDate,
                    ));
                  });
                });
              }
            });
          });
        });

        studentWiseAnnualTransactionHistory.masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans
            ?.forEach((_MasterTransactionIdWiseStudentTermWiseTransactionHistory eachMasterTransactionIdWiseStudentTermWiseTransactionHistory) {
          eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.studentTermWiseTransactionHistory
              ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
            eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
              if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
                eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid =
                    eachStudentTermWiseFeeTypeTransactionHistory.transactions?.map((e) => e.amount ?? 0).sum;
              } else {
                eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                    ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
                  eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid =
                      eachStudentTermWiseCustomFeeTypeTransactionHistory.transactions?.map((e) => e.amount ?? 0).sum;
                });
              }
            });
            eachStudentTermWiseTransactionHistory.totalFeePaid = (eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory
                        ?.map((e) => (e.studentTermWiseCustomFeeTypeTransactionHistory ?? []).isEmpty ? (e.totalFeePaid ?? 0) : 0)
                        .sum ??
                    0) +
                (eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory
                        ?.map((e) => (e.studentTermWiseCustomFeeTypeTransactionHistory ?? []).isNotEmpty
                            ? (e.studentTermWiseCustomFeeTypeTransactionHistory?.map((e) => e.totalFeePaid ?? 0).sum) ?? 0
                            : 0)
                        .sum ??
                    0);
          });
          eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.totalFeePaid =
              eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.studentTermWiseTransactionHistory?.map((e) => e.totalFeePaid ?? 0).sum;
        });

        studentWiseAnnualTransactionHistory.studentWalletTransactionHistoryBeans =
            (studentWiseTermFeesBean?.studentWalletTransactionBeans ?? []).map((e) => e!).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("409: ${_dateWiseTransactions().length}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fee"),
        actions: [
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(children: <Widget>[
              ...studentAnnualFeeBeans
                  .map((e) => BasicFeeStatsReadWidget(
                        studentWiseAnnualFeesBean: e,
                        context: context,
                        alignMargin: true,
                      ))
                  .toList(),
              ..._dateWiseTransactions(),
            ]),
    );
  }

  List<Widget> _dateWiseTransactions() {
    List<Widget> widgets = [];
    debugPrint("443: ${allMasterTransactionIds.length}");
    for (String eachMasterTransactionId in allMasterTransactionIds) {
      List<Widget> subList = [];
      for (_MasterTransactionIdWiseStudentTermWiseTransactionHistory eachMasterTransactionIdWiseStudentTermWiseTransactionHistory
          in studentWiseAnnualTransactionHistory.masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans!
              .where((e) => e.masterTransactionId == eachMasterTransactionId)) {
        for (_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory
            in eachMasterTransactionIdWiseStudentTermWiseTransactionHistory.studentTermWiseTransactionHistory ?? []) {
          subList.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const CustomVerticalDivider(
              //   color: Colors.red,
              // ),
              // const SizedBox(
              //   width: 10,
              // ),
              Expanded(
                child: Center(
                  child: Text(
                    eachStudentTermWiseTransactionHistory.termName ?? "-",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ));
          subList.add(
            const SizedBox(
              height: 15,
            ),
          );
          for (_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory
              in eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistory!) {
            if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
              subList.add(buildAmountWidgetForFeeType(eachStudentTermWiseFeeTypeTransactionHistory));
              subList.add(const SizedBox(
                height: 15,
              ));
            } else {
              if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                  .map((e) => e.transactions!)
                  .expand((i) => i)
                  .isNotEmpty) {
                Set<int> customFeeTypeIds = eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                    .map((e) => e.transactions!)
                    .expand((i) => i)
                    .map((e) => e.customFeeTypeId!)
                    .toSet();
                List<_SupportClassForCustomFeeType> supportClassForCustomFeeTypes = customFeeTypeIds.map((int customFeeTypeId) {
                  int amount = eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                      .map((e) => e.transactions!)
                      .expand((i) => i)
                      .where((c) => c.customFeeTypeId == customFeeTypeId)
                      .map((e) => e.amount ?? 0)
                      .sum;
                  String customFeeType = eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                          .where((c) => c.customFeeTypeId == customFeeTypeId)
                          .firstOrNull
                          ?.customFeeType ??
                      "-";
                  return _SupportClassForCustomFeeType(
                    amount: amount,
                    customFeeType: customFeeType,
                  );
                }).toList();
                subList.addAll(buildCustomFeeTypeWidgets(eachStudentTermWiseFeeTypeTransactionHistory));
              }
            }
          }
        }
      }
      int totalPerDay = studentWiseAnnualTransactionHistory.masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans
              ?.where((e) => e.masterTransactionId == eachMasterTransactionId)
              .firstOrNull
              ?.totalFeePaid ??
          0;
      subList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Total: $INR_SYMBOL ${totalPerDay / 100}",
              textAlign: TextAlign.end,
            ),
          ],
        ),
      );
      widgets.add(
        Container(
          margin: MediaQuery.of(context).orientation == Orientation.portrait
              ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
              : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10),
          child: ClayContainer(
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 10,
            depth: 40,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(15),
                        child: Text(
                          convertDateToDDMMMYYYEEEE(studentWiseAnnualTransactionHistory.masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans
                              ?.where((e) => e.masterTransactionId == eachMasterTransactionId)
                              .firstOrNull
                              ?.masterTransactionDate),
                          style: const TextStyle(
                            fontSize: 21,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ] +
                    subList +
                    [
                      const SizedBox(
                        height: 15,
                      ),
                    ],
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget buildAmountWidgetForFeeType(_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
    return Row(
      children: [
        Expanded(
          child: Text(
            eachStudentTermWiseFeeTypeTransactionHistory.feeType ?? "-",
          ),
        ),
        Text(
          eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid == null
              ? "-"
              : INR_SYMBOL + " ${(eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0) / 100}",
        ),
      ],
    );
  }

  List<Widget> buildCustomFeeTypeWidgets(_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
    List<Widget> widgets = [];
    widgets.add(Row(
      children: [
        Expanded(
          child: Text(
            eachStudentTermWiseFeeTypeTransactionHistory.feeType ?? "-",
          ),
        )
      ],
    ));
    widgets.add(const SizedBox(
      height: 15,
    ));
    for (_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory
        in eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory ?? []) {
      widgets.add(Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          const CustomVerticalDivider(),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeType ?? "-",
            ),
          ),
          Text(
            eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid == null
                ? "-"
                : INR_SYMBOL + " ${eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid! / 100}",
          ),
        ],
      ));
      widgets.add(const SizedBox(
        height: 15,
      ));
    }
    return widgets;
  }
}

class _StudentWiseAnnualTransactionHistory {
  StudentProfile? studentProfile;
  int? sectionId;
  String? sectionName;
  int? totalFee;
  int? totalFeePaid;

  List<StudentWalletTransactionBean>? studentWalletTransactionHistoryBeans;
  List<_MasterTransactionIdWiseStudentTermWiseTransactionHistory>? masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans;

  _StudentWiseAnnualTransactionHistory({
    this.studentProfile,
    this.sectionId,
    this.sectionName,
    this.totalFee,
    this.totalFeePaid,
    this.studentWalletTransactionHistoryBeans,
    this.masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans,
  });

  @override
  String toString() {
    return "{'sectionId': $sectionId, 'sectionName': $sectionName, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'studentWalletTransactionHistoryBeans': $studentWalletTransactionHistoryBeans, 'masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans': $masterTransactionIdWiseStudentTermWiseTransactionHistoryBeans}";
  }
}

class _MasterTransactionIdWiseStudentTermWiseTransactionHistory {
  String? masterTransactionId;
  String? masterTransactionDate;
  int? totalFeePaid;

  List<_StudentTermWiseTransactionHistory>? studentTermWiseTransactionHistory;

  _MasterTransactionIdWiseStudentTermWiseTransactionHistory({
    this.masterTransactionId,
    this.masterTransactionDate,
    this.totalFeePaid,
    this.studentTermWiseTransactionHistory,
  });

  @override
  String toString() {
    return "{'masterTransactionId': $masterTransactionId, 'masterTransactionDate': $masterTransactionDate, 'totalFeePaid': $totalFeePaid, 'studentTermWiseTransactionHistory': $studentTermWiseTransactionHistory}";
  }
}

class _StudentTermWiseTransactionHistory {
  int? termId;
  String? termName;
  int? totalFee;
  int? totalFeePaid;

  List<_StudentTermWiseFeeTypeTransactionHistory>? studentTermWiseFeeTypeTransactionHistory;

  _StudentTermWiseTransactionHistory({
    this.termId,
    this.termName,
    this.totalFee,
    this.totalFeePaid,
    this.studentTermWiseFeeTypeTransactionHistory,
  });

  @override
  String toString() {
    return "{'termId': $termId, 'termName': $termName, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'studentTermWiseFeeTypeTransactionHistory': $studentTermWiseFeeTypeTransactionHistory}";
  }
}

class _StudentTermWiseFeeTypeTransactionHistory {
  int? feeTypeId;
  String? feeType;
  int? totalFee;
  int? totalFeePaid;
  int? termId;

  List<_FeeTypeTransaction>? transactions;

  List<_StudentTermWiseCustomFeeTypeTransactionHistory>? studentTermWiseCustomFeeTypeTransactionHistory;

  _StudentTermWiseFeeTypeTransactionHistory({
    this.feeTypeId,
    this.feeType,
    this.totalFee,
    this.totalFeePaid,
    this.transactions,
    this.studentTermWiseCustomFeeTypeTransactionHistory,
    this.termId,
  });

  @override
  String toString() {
    return "{'feeTypeId': $feeTypeId, 'feeType': $feeType, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'transactions': $transactions, 'studentTermWiseCustomFeeTypeTransactionHistory': $studentTermWiseCustomFeeTypeTransactionHistory}";
  }
}

class _FeeTypeTransaction {
  int? amount;
  String? transactionId;
  String? masterTransactionId;
  String? transactionTime;
  String? transactionDescription;
  int? feeTypeId;
  String? feeType;
  int? feePaidId;
  String? modeOfPayment;
  String? type;
  String? kind;

  _FeeTypeTransaction({
    this.amount,
    this.transactionId,
    this.masterTransactionId,
    this.transactionTime,
    this.transactionDescription,
    this.feeTypeId,
    this.feeType,
    this.feePaidId,
    this.modeOfPayment,
    this.type,
    this.kind,
  });

  @override
  String toString() {
    return "{'amount': $amount, 'transactionId': $transactionId, 'masterTransactionId': $masterTransactionId, 'transactionTime': $transactionTime, 'transactionDescription': $transactionDescription, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'feePaidId': $feePaidId, 'modeOfPayment': $modeOfPayment, 'type': $type, 'kind': $kind}";
  }
}

class _StudentTermWiseCustomFeeTypeTransactionHistory {
  int? feeTypeId;
  String? feeType;
  int? customFeeTypeId;
  String? customFeeType;
  int? totalFee;
  int? totalFeePaid;
  int? termId;

  List<_CustomFeeTypeTransaction>? transactions;

  _StudentTermWiseCustomFeeTypeTransactionHistory({
    this.feeTypeId,
    this.feeType,
    this.customFeeTypeId,
    this.customFeeType,
    this.totalFee,
    this.totalFeePaid,
    this.transactions,
    this.termId,
  });

  @override
  String toString() {
    return "{'feeTypeId': $feeTypeId, 'feeType': $feeType, 'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'transactions': $transactions}";
  }
}

class _CustomFeeTypeTransaction {
  int? amount;
  String? transactionId;
  String? masterTransactionId;
  String? transactionTime;
  String? transactionDescription;
  int? feeTypeId;
  String? feeType;
  int? customFeeTypeId;
  String? customFeeType;
  int? feePaidId;
  String? modeOfPayment;
  String? type;
  String? kind;

  _CustomFeeTypeTransaction({
    this.amount,
    this.transactionId,
    this.masterTransactionId,
    this.transactionTime,
    this.transactionDescription,
    this.feeTypeId,
    this.feeType,
    this.customFeeTypeId,
    this.customFeeType,
    this.feePaidId,
    this.modeOfPayment,
    this.type,
    this.kind,
  });

  @override
  String toString() {
    return "{'amount': $amount, 'transactionId': $transactionId, 'masterTransactionId': $masterTransactionId, 'transactionTime': $transactionTime, 'transactionDescription': $transactionDescription, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'feePaidId': $feePaidId, 'modeOfPayment': $modeOfPayment, 'type': $type, 'kind': $kind}";
  }
}

class _SupportClassForCustomFeeType {
  String? customFeeType;
  int? amount;

  _SupportClassForCustomFeeType({this.customFeeType, this.amount});
}
