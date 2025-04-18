import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/clay_containers.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AdminFeeReceiptsScreen extends StatefulWidget {
  const AdminFeeReceiptsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<AdminFeeReceiptsScreen> createState() => _AdminFeeReceiptsScreenState();
}

class _AdminFeeReceiptsScreenState extends State<AdminFeeReceiptsScreen> {
  bool _isLoading = true;
  bool _isAddNew = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Section> sectionsList = [];

  List<StudentProfile> studentProfiles = [];

  List<StudentFeeDetailsBean> studentFeeDetailsBeans = [];
  List<StudentAnnualFeeSupportBean> studentAnnualFeeBeanBeans = [];
  List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans = [];
  List<StudentMasterTransactionSupportBean> studentMasterTransactionBeans = [];
  List<StudentWiseFeePaidSupportBean> studentWiseFeePaidBeans = [];
  List<StudentBusFeeLogBean> busFeeBeans = [];

  List<StudentFeeDetailsBean> filteredStudentFeeDetailsBeanList = [];

  DateTime? startDate;
  DateTime? endDate;
  List<Section> selectedSection = [];
  _StatFilterType statFilterType = _StatFilterType.daily;
  TextEditingController nController = TextEditingController();
  List<int> selectedFeeTypes = [];
  List<int> selectedCustomFeeTypes = [];
  int totalFeeCollected = 0;

  List<FeeType> feeTypes = [];

  List<_DateWiseTxnAmount> dateWiseTxnAmounts = [];
  List<_MonthWiseTxnAmount> monthWiseTxnAmounts = [];

  List<_NewReceipt> newReceipts = [];
  late int latestReceiptNumberToBeAdded;

  TextEditingController reasonToDeleteTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      reasonToDeleteTextController.text = "";
      _isLoading = true;
    });
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
      sectionsList = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
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
      setState(() {
        feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
        selectedFeeTypes = feeTypes.where((e) => e.customFeeTypesList?.isEmpty ?? true).map((e) => e.feeTypeId ?? 0).toList() + [-1];
        selectedCustomFeeTypes = feeTypes
            .where((e) => e.customFeeTypesList?.isNotEmpty ?? false)
            .map((e) => e.customFeeTypesList ?? [])
            .expand((i) => i)
            .map((e) => e?.customFeeTypeId ?? 0)
            .toList();
      });
    }
    // GetStudentFeeDetailsResponse getStudentFeeDetailsResponse = await getStudentFeeDetails(GetStudentFeeDetailsRequest(
    //   schoolId: widget.adminProfile.schoolId,
    // ));
    // if (getStudentFeeDetailsResponse.httpStatus != "OK" || getStudentFeeDetailsResponse.responseStatus != "success") {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Something went wrong! Try again later.."),
    //     ),
    //   );
    // } else {
    //   studentFeeDetailsBeanList = (getStudentFeeDetailsResponse.studentFeeDetailsBeanList ?? []).where((e) => e != null).map((e) => e!).toList();
    // }
    GetStudentFeeDetailsSupportClassesResponse getStudentFeeDetailsSupportClassesResponse =
        await getStudentFeeDetailsSupportClasses(GetStudentFeeDetailsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getStudentFeeDetailsSupportClassesResponse.httpStatus != "OK" || getStudentFeeDetailsSupportClassesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentFeeDetailsBeans = studentFeeDetailsBeans;
      studentAnnualFeeBeanBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentAnnualFeeBeanBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      studentTermWiseFeeBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentTermWiseFeeBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      studentMasterTransactionBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentMasterTransactionBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      studentWiseFeePaidBeans =
          (getStudentFeeDetailsSupportClassesResponse.studentWiseFeePaidBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      busFeeBeans = (getStudentFeeDetailsSupportClassesResponse.busFeeBeans ?? []).where((e) => e != null).map((e) => e!).toList();
      mergeAndGetStudentFeeDetailsBeans();
      try {
        latestReceiptNumberToBeAdded = (getStudentFeeDetailsSupportClassesResponse.studentMasterTransactionBeans ?? [])
                .where((e) => e != null)
                .map((e) => e!.receiptId ?? 0)
                .reduce(max) +
            1;
      } catch (e) {
        latestReceiptNumberToBeAdded = 1;
      }
    }
    _isAddNew = false;
    newReceipts = [];
    newReceipts.add(_NewReceipt(
      context: _scaffoldKey.currentContext!,
      notifyParent: setState,
      receiptNumber: latestReceiptNumberToBeAdded,
      selectedDate: DateTime.now(),
      sectionsList: sectionsList,
      studentProfiles: studentProfiles,
      studentFeeDetails: studentFeeDetailsBeans.map((e) => StudentFeeDetailsBean.fromJson(e.toJson())).toList(),
      studentTermWiseFeeBeans: studentTermWiseFeeBeans,
      feeTypes: feeTypes,
      totalBusFee: null,
      busFeePaid: null,
      busFeeBeans: busFeeBeans,
    ));
    await _filterData();
    setState(() => _isLoading = false);
  }

  List<StudentFeeDetailsBean> mergeAndGetStudentFeeDetailsBeans() {
    for (var studentAnnualFeeBean in studentAnnualFeeBeanBeans) {
      if (studentFeeDetailsBeans.where((studentFeeDetailsBean) => studentFeeDetailsBean.studentId == studentAnnualFeeBean.studentId).isEmpty) {
        StudentFeeDetailsBean newStudentBean = StudentFeeDetailsBean();
        newStudentBean.studentId = studentAnnualFeeBean.studentId;
        newStudentBean.rollNumber = studentAnnualFeeBean.rollNumber;
        newStudentBean.studentName = studentAnnualFeeBean.studentName;
        newStudentBean.sectionId = studentAnnualFeeBean.sectionId;
        newStudentBean.sectionName = studentAnnualFeeBean.sectionName;
        newStudentBean.schoolId = studentAnnualFeeBean.schoolId;
        newStudentBean.schoolName = studentAnnualFeeBean.schoolDisplayName;
        newStudentBean.studentWiseFeeTypeDetailsList = [];
        newStudentBean.studentFeeTransactionList = [];
        studentFeeDetailsBeans.add(newStudentBean);
      }
    }
    for (var studentFeeDetailsBean in studentFeeDetailsBeans) {
      studentAnnualFeeBeanBeans
          .where((studentAnnualFeeBean) => studentAnnualFeeBean.studentId == studentFeeDetailsBean.studentId)
          .forEach((studentAnnualFeeBean) => {
                studentFeeDetailsBean.totalAnnualFee = studentAnnualFeeBean.amount,
                studentFeeDetailsBean.totalFeePaid = studentAnnualFeeBean.amountPaid,
                studentFeeDetailsBean.sectionId = studentAnnualFeeBean.sectionId,
                studentFeeDetailsBean.sectionName = studentAnnualFeeBean.sectionName,
                studentFeeDetailsBean.studentName = studentAnnualFeeBean.studentName,
                studentFeeDetailsBean.studentWiseFeeTypeDetailsList = [],
                studentFeeDetailsBean.studentFeeTransactionList = [],
              });
    }
    for (var studentFeeDetailsBean in studentFeeDetailsBeans) {
      studentMasterTransactionBeans
          .where((studentMasterTransactionBean) => (studentMasterTransactionBean.studentId == studentFeeDetailsBean.studentId))
          .forEach((studentMasterTransactionBean) => {
                studentFeeDetailsBean.studentFeeTransactionList!.add(StudentFeeTransactionBean(
                  studentId: studentMasterTransactionBean.studentId,
                  studentName: studentMasterTransactionBean.studentName,
                  masterTransactionId: studentMasterTransactionBean.transactionId,
                  transactionDate: studentMasterTransactionBean.transactionTime,
                  transactionAmount: studentMasterTransactionBean.amount,
                  receiptId: studentMasterTransactionBean.receiptId,
                  studentFeeChildTransactionList: [],
                )),
              });
    }
    studentFeeDetailsBeans
        .forEach((studentFeeDetailsBean) => (studentFeeDetailsBean.studentFeeTransactionList ?? []).forEach((studentFeeTransactionBean) {
              studentFeeTransactionBean?.studentFeeChildTransactionList ??= [];
              studentFeeTransactionBean?.studentFeeChildTransactionList = (studentWiseFeePaidBeans.where(
                      (studentWiseFeePaidBean) => (studentWiseFeePaidBean.masterTransactionId == studentFeeTransactionBean.masterTransactionId)))
                  .map((studentWiseFeePaidBean) {
                return StudentFeeChildTransactionBean(
                  studentId: studentWiseFeePaidBean.studentId,
                  studentName: studentWiseFeePaidBean.studentName,
                  masterTransactionId: studentWiseFeePaidBean.masterTransactionId,
                  transactionId: studentWiseFeePaidBean.transactionId,
                  transactionDate: studentWiseFeePaidBean.transactionDate,
                  feePaidAmount: studentWiseFeePaidBean.amount,
                  feeTypeId: studentWiseFeePaidBean.feeTypeId,
                  feeType: studentWiseFeePaidBean.feeType,
                  customFeeTypeId: studentWiseFeePaidBean.customFeeTypeId,
                  customFeeType: studentWiseFeePaidBean.customFeeType,
                );
              }).toList();
            }));
    studentFeeDetailsBeans.forEach((eachStudentFeeDetails) {
      busFeeBeans.where((eachBusFee) => eachBusFee.studentId == eachStudentFeeDetails.studentId).forEach((eachBusFee) {
        eachStudentFeeDetails.busFee = eachBusFee.fare;
      });
    });
    return studentFeeDetailsBeans;
  }

  Future<void> _filterData() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      filteredStudentFeeDetailsBeanList = studentFeeDetailsBeans.map((e) => StudentFeeDetailsBean.fromJson(e.toJson())).toList();
    });
    if (startDate != null) {
      setState(() {
        for (var eachStudentDetails in filteredStudentFeeDetailsBeanList) {
          eachStudentDetails.studentFeeTransactionList = eachStudentDetails.studentFeeTransactionList
              ?.where((e) => convertYYYYMMDDFormatToDateTime(e?.transactionDate).compareTo(startDate!) >= 0)
              .toList();
        }
      });
    }
    if (endDate != null) {
      setState(() {
        for (var eachStudentDetails in filteredStudentFeeDetailsBeanList) {
          eachStudentDetails.studentFeeTransactionList = eachStudentDetails.studentFeeTransactionList
              ?.where((e) => convertYYYYMMDDFormatToDateTime(e?.transactionDate).compareTo(endDate!) <= 0)
              .toList();
        }
      });
    }
    setState(() {
      for (var eachStudentDetails in filteredStudentFeeDetailsBeanList) {
        eachStudentDetails.studentFeeTransactionList =
            (eachStudentDetails.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!).where((eachMasterTxn) {
          List<int?> feeTypeTxns = (eachMasterTxn.studentFeeChildTransactionList ?? [])
              .where((e) => e != null)
              .map((e) => e!)
              .where((e) => (e.customFeeTypeId ?? 0) == 0)
              .map((e) => e.feeTypeId)
              .toSet()
              .toList();
          List<int?> customFeeTypeTxns = (eachMasterTxn.studentFeeChildTransactionList ?? [])
              .where((e) => e != null)
              .map((e) => e!)
              .where((e) => (e.customFeeTypeId ?? 0) != 0)
              .map((e) => e.customFeeTypeId)
              .toSet()
              .toList();
          return feeTypeTxns.map((e) => selectedFeeTypes.contains(e)).contains(true) ||
              customFeeTypeTxns.map((e) => selectedCustomFeeTypes.contains(e)).contains(true);
        }).toList();
      }
    });
    setState(() {
      totalFeeCollected = 0;
      filteredStudentFeeDetailsBeanList
          .map((e) => e.studentFeeTransactionList ?? [])
          .expand((i) => i)
          .where((e) => e != null)
          .map((e) => e!)
          .map((e) => e.studentFeeChildTransactionList ?? [])
          .expand((i) => i)
          .where((e) => e != null)
          .map((e) => e!)
          .where((e) => selectedFeeTypes.contains(e.feeTypeId) || selectedCustomFeeTypes.contains(e.customFeeTypeId))
          .map((e) => e.feePaidAmount ?? 0)
          .forEach((e) {
        totalFeeCollected += e;
      });
    });
    setState(() {
      dateWiseTxnAmounts = [];
      List<DateTime> txnDates = filteredStudentFeeDetailsBeanList
          .map((e) => e.studentFeeTransactionList ?? [])
          .expand((i) => i)
          .where((e) => e != null)
          .map((e) => e!)
          .where((e) => e.transactionDate != null)
          .map((e) => e.transactionDate)
          .map((e) => convertYYYYMMDDFormatToDateTime(e))
          .toList();
      txnDates.sorted((a, b) => a.compareTo(b));
      DateTime leastDate = txnDates.firstOrNull ?? DateTime.now();
      if (statFilterType == _StatFilterType.lastNDays) {
        for (DateTime eachDate =
                int.tryParse(nController.text) == null ? leastDate : DateTime.now().subtract(Duration(days: int.parse(nController.text)));
            eachDate.compareTo(DateTime.now()) <= 0;
            eachDate = eachDate.add(const Duration(days: 1))) {
          int dateWiseTxnAmount = 0;
          filteredStudentFeeDetailsBeanList
              .map((e) => e.studentFeeTransactionList ?? [])
              .expand((i) => i)
              .where((e) => e != null)
              .map((e) => e!)
              .where((e) => e.transactionDate == convertDateTimeToYYYYMMDDFormat(eachDate))
              .forEach((eachStudentMasterTxnForDate) {
            List<int?> eachChildTxnAmounts = (eachStudentMasterTxnForDate.studentFeeChildTransactionList ?? [])
                .where((e) => e != null)
                .map((e) => e!)
                .where((e) => selectedFeeTypes.contains(e.feeTypeId) || selectedCustomFeeTypes.contains(e.customFeeTypeId))
                .map((e) => e.feePaidAmount)
                .toList();
            for (int? eachChildTxnAmount in eachChildTxnAmounts) {
              dateWiseTxnAmount += eachChildTxnAmount ?? 0;
            }
          });
          dateWiseTxnAmounts.add(_DateWiseTxnAmount(eachDate, dateWiseTxnAmount, context));
        }
      } else {
        for (DateTime eachDate = leastDate; eachDate.compareTo(DateTime.now()) <= 0; eachDate = eachDate.add(const Duration(days: 1))) {
          int dateWiseTxnAmount = 0;
          filteredStudentFeeDetailsBeanList
              .map((e) => e.studentFeeTransactionList ?? [])
              .expand((i) => i)
              .where((e) => e != null)
              .map((e) => e!)
              .where((e) => e.transactionDate == convertDateTimeToYYYYMMDDFormat(eachDate))
              .forEach((eachStudentMasterTxnForDate) {
            List<int?> eachChildTxnAmounts = (eachStudentMasterTxnForDate.studentFeeChildTransactionList ?? [])
                .where((e) => e != null)
                .map((e) => e!)
                .where((e) => selectedFeeTypes.contains(e.feeTypeId) || selectedCustomFeeTypes.contains(e.customFeeTypeId))
                .map((e) => e.feePaidAmount)
                .toList();
            for (int? eachChildTxnAmount in eachChildTxnAmounts) {
              dateWiseTxnAmount += eachChildTxnAmount ?? 0;
            }
          });
          dateWiseTxnAmounts.add(_DateWiseTxnAmount(eachDate, dateWiseTxnAmount, context));
        }
      }
    });
    monthWiseTxnAmounts = [];
    if (statFilterType == _StatFilterType.monthly) {
      for (_DateWiseTxnAmount eachDateWiseTxn in dateWiseTxnAmounts) {
        int month = eachDateWiseTxn.dateTime.month;
        int year = eachDateWiseTxn.dateTime.year;
        _MonthWiseTxnAmount? monthWiseTxnAmount =
            monthWiseTxnAmounts.where((eachMonthWiseBean) => eachMonthWiseBean.month == month && eachMonthWiseBean.year == year).firstOrNull;
        if (monthWiseTxnAmount == null) {
          monthWiseTxnAmount = _MonthWiseTxnAmount(
            month,
            year,
            eachDateWiseTxn.amount,
            context,
          );
          monthWiseTxnAmounts.add(monthWiseTxnAmount);
        } else {
          monthWiseTxnAmount.amount += eachDateWiseTxn.amount;
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    String? errorText;
    for (_NewReceipt eachNewReceipt in newReceipts.where((e) => e.status != "deleted")) {
      if (eachNewReceipt.selectedStudent == null || eachNewReceipt.selectedSection == null) {
        errorText = "Select a student and enter the details to proceed adding a new receipt";
      }
    }
    if (errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    List<NewReceiptBean> newReceiptsToBePaid = newReceipts
        .where((e) => e.status != "deleted")
        .map((eachNewReceipt) => NewReceiptBean(
              busFeePaidAmount:
                  int.tryParse(eachNewReceipt.busFeeController.text) == null ? null : int.parse(eachNewReceipt.busFeeController.text) * 100,
              studentId: eachNewReceipt.selectedStudent!.studentId!,
              sectionId: eachNewReceipt.selectedSection!.sectionId!,
              receiptNumber: int.parse(eachNewReceipt.receiptNumberController.text),
              date: DateTime(eachNewReceipt.selectedDate.year, eachNewReceipt.selectedDate.month, eachNewReceipt.selectedDate.day, 12, 30)
                  .millisecondsSinceEpoch,
              agentId: widget.adminProfile.userId,
              schoolId: widget.adminProfile.schoolId,
              subBeans: eachNewReceipt.termWiseFeeToBePaidBeans
                  .map((eachTermWiseFeeToBePaid) {
                    List<NewReceiptBeanSubBean> subBeans = [];
                    if ((eachTermWiseFeeToBePaid.termWiseFeeTypes ?? []).isNotEmpty) {
                      for (_TermWiseFeeType eachTermWiseFeeType in (eachTermWiseFeeToBePaid.termWiseFeeTypes ?? [])) {
                        if ((eachTermWiseFeeType.termWiseCustomFeeTypes ?? []).isEmpty) {
                          if (eachTermWiseFeeType.isChecked &&
                              eachTermWiseFeeType.feePayingController.text.trim().isNotEmpty &&
                              eachTermWiseFeeType.feePayingController.text != "0") {
                            subBeans.add(NewReceiptBeanSubBean(
                              // termId: eachTermWiseFeeToBePaid.termId!,
                              feeTypeId: eachTermWiseFeeType.feeTypeId!,
                              customFeeTypeId: null,
                              feePaying: int.parse(eachTermWiseFeeType.feePayingController.text.replaceAll(",", "")) * 100,
                            ));
                          }
                        } else {
                          for (_TermWiseCustomFeeType eachTermWiseCustomFeeType in (eachTermWiseFeeType.termWiseCustomFeeTypes ?? [])) {
                            if (eachTermWiseCustomFeeType.isChecked &&
                                eachTermWiseCustomFeeType.feePayingController.text.trim().isNotEmpty &&
                                eachTermWiseCustomFeeType.feePayingController.text != "0") {
                              subBeans.add(NewReceiptBeanSubBean(
                                // termId: eachTermWiseCustomFeeType.termId!,
                                feeTypeId: eachTermWiseCustomFeeType.feeTypeId!,
                                customFeeTypeId: eachTermWiseCustomFeeType.customFeeTypeId,
                                feePaying: int.parse(eachTermWiseCustomFeeType.feePayingController.text.replaceAll(",", "")) * 100,
                              ));
                            }
                          }
                        }
                      }
                    }
                    return subBeans;
                  })
                  .expand((i) => i)
                  .toList(),
            ))
        .where((e) => (e.subBeans ?? []).isNotEmpty || e.busFeePaidAmount != null)
        .toList();
    if (newReceiptsToBePaid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please check all the necessary details correctly"),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    CreateNewReceiptsResponse createNewReceiptsResponse = await createNewReceipts(CreateNewReceiptsRequest(
      newReceiptBeans: newReceiptsToBePaid,
    ));
    if (createNewReceiptsResponse.httpStatus != "OK" || createNewReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Receipts submitted successfully, Please wait while we load your data.."),
        ),
      );
      await _loadData();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Fee Receipts"),
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : AdminAppDrawer(
              adminProfile: widget.adminProfile,
            ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : _isAddNew
              ? Column(
                  children: [
                    Expanded(
                      child: newReceiptWidget(),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (newReceipts.where((e) => e.status != "deleted").map((e) => e.selectedStudent).contains(null)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Select a student and enter the details to proceed adding a new receipt"),
                                      ),
                                    );
                                    return;
                                  }
                                  newReceipts = [
                                    _NewReceipt(
                                      context: _scaffoldKey.currentContext!,
                                      notifyParent: setState,
                                      receiptNumber:
                                          newReceipts.where((e) => e.status != "deleted").map((e) => e.receiptNumber ?? 0).toList().reduce(max) + 1,
                                      selectedDate: newReceipts.where((e) => e.status != "deleted").firstOrNull?.selectedDate ?? DateTime.now(),
                                      sectionsList: sectionsList,
                                      studentProfiles: studentProfiles,
                                      studentFeeDetails: studentFeeDetailsBeans,
                                      studentTermWiseFeeBeans: studentTermWiseFeeBeans,
                                      feeTypes: feeTypes,
                                      totalBusFee: null,
                                      busFeePaid: null,
                                      busFeeBeans: busFeeBeans,
                                    ),
                                    ...newReceipts,
                                  ];
                                });
                              },
                              child: ClayButton(
                                color: clayContainerColor(context),
                                borderRadius: 10,
                                spread: 2,
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Text(
                                      "Add New Receipt",
                                      style: TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: _scaffoldKey.currentContext!,
                                  builder: (currentContext) {
                                    return AlertDialog(
                                      title: const Text("Fee Receipts"),
                                      content: const Text("Are you sure you want to save changes?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _saveChanges();
                                            // _loadData();
                                          },
                                          child: const Text("YES"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {
                                              _isAddNew = false;
                                            });
                                          },
                                          child: const Text("NO"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: ClayButton(
                                color: clayContainerColor(context),
                                borderRadius: 10,
                                spread: 2,
                                child: const Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              : ListView(
                  children: [
                    statsWidget(),
                    filtersWidget(),
                    ...(filteredStudentFeeDetailsBeanList
                            .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
                            .expand((i) => i)
                            .toList()
                          ..sort(
                            (b, a) => (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                                ? convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) ==
                                        0
                                    ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                                    : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate))
                                : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0),
                          ))
                        .map((e) => studentFeeTransactionWidget(e))
                        .toList(),
                  ],
                ),
      floatingActionButton: _isLoading || _isAddNew
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAddNew = !_isAddNew;
                });
              },
              child: _isAddNew ? const Icon(Icons.check) : const Icon(Icons.add),
            ),
    );
  }

  Widget newReceiptWidget() {
    return ListView(
      children: [
        ...newReceipts.where((e) => e.status == "active").map((e) => e.widget()).toList(),
      ],
    );
  }

  Widget studentFeeTransactionWidget(StudentFeeTransactionBean e) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.all(10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Text(
                      "Receipt No.:${MediaQuery.of(context).orientation == Orientation.landscape ? " " : "\n"}${(e.receiptId ?? 0) == 0 ? "" : e.receiptId}",
                      textAlign: MediaQuery.of(context).orientation == Orientation.landscape ? TextAlign.start : TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Tooltip(
                      message: convertDateToDDMMMYYYEEEE(e.transactionDate),
                      child: Text(
                        "Date:${MediaQuery.of(context).orientation == Orientation.landscape ? " " : "\n"}${convertDateToDDMMMYYY(e.transactionDate)}",
                        textAlign: TextAlign.end,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      //  TODO
                      await showDialog(
                        context: _scaffoldKey.currentContext!,
                        builder: (BuildContext dialogueContext) {
                          return AlertDialog(
                            title: const Text('Are you sure you want to delete the receipt?'),
                            content: TextField(
                              onChanged: (value) {},
                              controller: reasonToDeleteTextController,
                              decoration: InputDecoration(
                                hintText: "Reason to delete",
                                errorText: reasonToDeleteTextController.text.trim() == "" ? "Reason cannot be empty!" : "",
                              ),
                              autofocus: true,
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("Yes"),
                                onPressed: () async {
                                  if (reasonToDeleteTextController.text.trim() == "") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Reason to delete cannot be empty.."),
                                      ),
                                    );
                                    Navigator.pop(context);
                                    return;
                                  }
                                  Navigator.pop(context);
                                  setState(() => _isLoading = true);
                                  DeleteReceiptRequest deleteReceiptRequest = DeleteReceiptRequest(
                                    schoolId: widget.adminProfile.schoolId,
                                    agentId: widget.adminProfile.userId,
                                    masterTransactionId: e.masterTransactionId,
                                    comments: reasonToDeleteTextController.text.trim(),
                                  );
                                  DeleteReceiptResponse deleteReceiptResponse = await deleteReceipt(deleteReceiptRequest);
                                  if (deleteReceiptResponse.httpStatus != "OK" || deleteReceiptResponse.responseStatus != "success") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Something went wrong! Try again later.."),
                                      ),
                                    );
                                  } else {
                                    _loadData();
                                  }
                                  setState(() => _isLoading = false);
                                },
                              ),
                              TextButton(
                                child: const Text("No"),
                                onPressed: () async {
                                  setState(() {
                                    reasonToDeleteTextController.text = "";
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: ClayButton(
                      color: clayContainerColor(context),
                      height: 20,
                      width: 20,
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      child: const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Container(
              //   margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              //   child: ClayContainer(
              //     surfaceColor: clayContainerColor(context),
              //     parentColor: clayContainerColor(context),
              //     spread: 1,
              //     borderRadius: 10,
              //     depth: 40,
              //     emboss: true,
              //     child: Padding(
              //       padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              //       child: Row(
              //         children: [
              //           const SizedBox(
              //             width: 10,
              //           ),
              //           const Text("Section:"),
              //           const SizedBox(
              //             width: 10,
              //           ),
              //           Expanded(
              //             child: Text("${(e.sectionName)}"),
              //           ),
              //           const SizedBox(
              //             width: 10,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Container(
              //   margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              //   child: ClayContainer(
              //     surfaceColor: clayContainerColor(context),
              //     parentColor: clayContainerColor(context),
              //     spread: 1,
              //     borderRadius: 10,
              //     depth: 40,
              //     emboss: true,
              //     child: Padding(
              //       padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              //       child: Row(
              //         children: [
              //           const SizedBox(
              //             width: 10,
              //           ),
              //           const Text("Student:"),
              //           const SizedBox(
              //             width: 10,
              //           ),
              //           Expanded(
              //             child: Text("${(e.studentName)}"),
              //           ),
              //           const SizedBox(
              //             width: 10,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: InputDecorator(
                        isFocused: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          label: Text(
                            "Student",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        child: Text(
                          "${filteredStudentFeeDetailsBeanList.where((eachStudent) => eachStudent.studentId == e.studentId).firstOrNull?.rollNumber}. ${e.studentName ?? " "}",
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      flex: 1,
                      child: InputDecorator(
                        isFocused: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          label: Text(
                            "Section",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        child: Center(
                            child: Text(
                          e.sectionName ?? studentFeeDetailsBeans.where((e1) => e.studentId == e1.studentId).firstOrNull?.sectionName ?? "",
                        )),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ...childTransactionsWidget(e),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Total: $INR_SYMBOL ${doubleToStringAsFixedForINR((e.transactionAmount ?? 0) / 100.0)} /-",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> childTransactionsWidget(StudentFeeTransactionBean e) {
    // return (e.studentFeeChildTransactionList ?? []).map((e) => Container()).toList();
    List<Widget> childTxnWidgets = [];
    List<StudentFeeChildTransactionBean> childTxns =
        (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) => e.feeTypeId != null).toList();
    List<StudentFeeChildTransactionBean> busFeeTxns =
        (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) => e.feeTypeId == null).toList();
    List<_FeeTypeTxn> feeTypeTxns = [];
    for (StudentFeeChildTransactionBean eachChildTxn in childTxns) {
      if (!feeTypeTxns.map((e) => e.feeTypeId).contains(eachChildTxn.feeTypeId)) {
        feeTypeTxns.add(_FeeTypeTxn(eachChildTxn.feeTypeId, eachChildTxn.feeType, null, null, []));
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in childTxns) {
      if (eachChildTxn.customFeeTypeId != null && eachChildTxn.customFeeTypeId != 0) {
        feeTypeTxns.where((e) => e.feeTypeId == eachChildTxn.feeTypeId).forEach((eachFeeTypeTxn) {
          eachFeeTypeTxn.customFeeTypeTxns?.add(
              _CustomFeeTypeTxn(eachChildTxn.customFeeTypeId, eachChildTxn.customFeeType, eachChildTxn.feePaidAmount, eachFeeTypeTxn.transactionId));
        });
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in busFeeTxns) {
      if (!feeTypeTxns.map((e) => e.feeTypeId).contains(eachChildTxn.feeTypeId)) {
        feeTypeTxns.add(_FeeTypeTxn(eachChildTxn.feeTypeId, "Bus Fee", eachChildTxn.feePaidAmount, eachChildTxn.transactionId, []));
      }
    }
    feeTypeTxns.sort(
      (a, b) => a.feeType == "Bus Fee"
          ? -2
          : (a.customFeeTypeTxns ?? []).isEmpty
              ? -1
              : 1,
    );
    for (_FeeTypeTxn eachFeeTypeTxn in feeTypeTxns.where((e) => e.feeTypeId != null)) {
      if (eachFeeTypeTxn.customFeeTypeTxns?.isEmpty ?? true) {
        eachFeeTypeTxn.feePaidAmount =
            childTxns.where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId).map((e) => e.feePaidAmount).reduce((c1, c2) => (c1 ?? 0) + (c2 ?? 0));
        eachFeeTypeTxn.transactionId = childTxns.where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId).map((e) => e.transactionId).firstOrNull;
      } else {
        eachFeeTypeTxn.feePaidAmount = eachFeeTypeTxn.customFeeTypeTxns?.map((e) => e.feePaidAmount).reduce((c1, c2) => (c1 ?? 0) + (c2 ?? 0));
      }
    }
    for (_FeeTypeTxn eachFeeTypeTxn in feeTypeTxns) {
      if ((eachFeeTypeTxn.customFeeTypeTxns ?? []).isEmpty) {
        childTxnWidgets.add(Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Row(
            children: [
              Expanded(
                child: Text(eachFeeTypeTxn.feeType ?? "-"),
              ),
              Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-")
            ],
          ),
        ));
        childTxnWidgets.add(const SizedBox(
          height: 5,
        ));
      } else {
        childTxnWidgets.add(Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Row(
            children: [
              Expanded(
                child: Text(eachFeeTypeTxn.feeType ?? "-"),
              ),
            ],
          ),
        ));
        childTxnWidgets.add(const SizedBox(
          height: 5,
        ));
        for (var eachCustomFeeTypeTxn in (eachFeeTypeTxn.customFeeTypeTxns ?? [])) {
          childTxnWidgets.add(Container(
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                const CustomVerticalDivider(),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(eachCustomFeeTypeTxn.customFeeType ?? "-"),
                ),
                Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-")
              ],
            ),
          ));
          childTxnWidgets.add(const SizedBox(
            height: 5,
          ));
        }
      }
    }

    return childTxnWidgets;
  }

  Widget filtersWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: ClayButton(
              color: clayContainerColor(context),
              borderRadius: 10,
              spread: 2,
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text("Date"),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ClayButton(
              color: clayContainerColor(context),
              borderRadius: 10,
              spread: 2,
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text("Section"),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }

  Widget statsWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: ClayContainer(
        color: clayContainerColor(context),
        borderRadius: 10,
        spread: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Stats",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // if (MediaQuery.of(context).orientation == Orientation.landscape)
              //   Row(
              //     children: [
              //       const SizedBox(
              //         width: 10,
              //       ),
              //       Expanded(
              //         child: dailyStatRadioButton(),
              //       ),
              //       const SizedBox(
              //         width: 10,
              //       ),
              //       Expanded(
              //         child: monthlyStatRadioButton(),
              //       ),
              //       const SizedBox(
              //         width: 10,
              //       ),
              //       Expanded(
              //         child: lastNDatesStatRadioButton(),
              //       ),
              //     ],
              //   ),
              const SizedBox(height: 10),
              if (MediaQuery.of(context).orientation == Orientation.landscape)
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          dailyStatRadioButton(),
                          const SizedBox(height: 10),
                          monthlyStatRadioButton(),
                          const SizedBox(height: 10),
                          lastNDatesStatRadioButton(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: feeTypeFilter(),
                    ),
                  ],
                ),
              if (MediaQuery.of(context).orientation == Orientation.portrait)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    dailyStatRadioButton(),
                    const SizedBox(height: 10),
                    monthlyStatRadioButton(),
                    const SizedBox(height: 10),
                    lastNDatesStatRadioButton(),
                    const SizedBox(height: 10),
                    feeTypeFilter(),
                    const SizedBox(height: 10),
                    busFeeTypeFilter(),
                  ],
                ),
              const SizedBox(height: 10),
              SizedBox(
                height: 75,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: statFilterType == _StatFilterType.monthly
                      ? monthWiseTxnAmounts.map((e) => e.widget()).toList()
                      : dateWiseTxnAmounts.map((e) => e.widget()).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                const SizedBox(width: 10),
                const Expanded(
                  child: Text("Total Fee Collected = "),
                ),
                const SizedBox(width: 10),
                Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((totalFeeCollected) / 100.0)} /-"),
                const SizedBox(width: 10),
              ]),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  ListTile lastNDatesStatRadioButton() {
    return ListTile(
      leading: Radio(
        value: _StatFilterType.lastNDays,
        groupValue: statFilterType,
        onChanged: (_StatFilterType? value) {
          if (value != null) {
            setState(() {
              statFilterType = value;
              startDate = null;
              endDate = null;
            });
            _filterData();
          }
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Last"),
          const SizedBox(width: 5),
          SizedBox(
            width: 50,
            height: 25,
            child: TextField(
              controller: nController,
              keyboardType: TextInputType.number,
              maxLines: 1,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              ),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    if (newValue.text == "") return newValue;
                    final text = newValue.text;
                    if (text.isNotEmpty) int.parse(text);
                    if (double.parse(text) > 0) {
                      return newValue;
                    } else {
                      return oldValue;
                    }
                  } catch (e) {
                    return oldValue;
                  }
                }),
              ],
              autofocus: false,
              enabled: statFilterType == _StatFilterType.lastNDays,
              onChanged: (String e) {
                int? n = int.tryParse(e);
                if (n != null) {
                  DateTime now = DateTime.now();
                  setState(() {
                    endDate = now;
                    startDate = now.subtract(Duration(days: n));
                  });
                } else {
                  setState(() {
                    endDate = null;
                    startDate = null;
                  });
                }
                _filterData();
              },
            ),
          ),
          const SizedBox(width: 5),
          const Text("days"),
        ],
      ),
    );
  }

  ListTile monthlyStatRadioButton() {
    return ListTile(
      leading: Radio(
        value: _StatFilterType.monthly,
        groupValue: statFilterType,
        onChanged: (_StatFilterType? value) {
          if (value != null) {
            setState(() {
              statFilterType = value;
              startDate = null;
              endDate = null;
              nController.text = "";
            });
            _filterData();
          }
        },
      ),
      title: const Text("Monthly"),
    );
  }

  ListTile dailyStatRadioButton() {
    return ListTile(
      leading: Radio(
        value: _StatFilterType.daily,
        groupValue: statFilterType,
        onChanged: (_StatFilterType? value) {
          if (value != null) {
            setState(() {
              statFilterType = value;
              startDate = null;
              endDate = null;
              nController.text = "";
            });
            _filterData();
          }
        },
      ),
      title: const Text("Daily"),
    );
  }

  Widget feeTypeFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      width: 150,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [...feeTypes.map((e) => feeTypeWidget(e)).toList()] +
            [
              busFeeTypeFilter(),
            ],
      ),
    );
  }

  Widget busFeeTypeFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    onChanged: (bool? value) {
                      if (value == null) return;
                      if (value) {
                        setState(() {
                          selectedFeeTypes.add(-1);
                        });
                        _filterData();
                      } else {
                        setState(() {
                          selectedFeeTypes.remove(-1);
                        });
                        _filterData();
                      }
                    },
                    value: selectedFeeTypes.contains(-1),
                  ),
                  const Expanded(
                    child: Text(
                      "Bus Fee",
                      style: TextStyle(
                        fontSize: 18,
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

  Widget feeTypeWidget(FeeType feeType) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (feeType.customFeeTypesList?.map((e) => e?.customFeeTypeId).where((e) => e != null).isEmpty ?? false)
                        Checkbox(
                          onChanged: (bool? value) {
                            if (value == null) return;
                            if (value) {
                              setState(() {
                                selectedFeeTypes.add(feeType.feeTypeId!);
                              });
                              _filterData();
                            } else {
                              setState(() {
                                selectedFeeTypes.remove(feeType.feeTypeId!);
                              });
                              _filterData();
                            }
                          },
                          value: selectedFeeTypes.contains(feeType.feeTypeId!),
                        ),
                      Expanded(
                        child: Text(
                          (feeType.feeType ?? "-").capitalize(),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((feeType.customFeeTypesList ?? []).isNotEmpty)
                    const SizedBox(
                      height: 5,
                    ),
                ] +
                (feeType.customFeeTypesList ?? [])
                    .map((e) => e!)
                    .where((e) => (e.customFeeTypeStatus != null && e.customFeeTypeStatus == "active"))
                    .map((e) => customFeeTypeWidget(feeType, (feeType.customFeeTypesList ?? []).indexOf(e)))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget customFeeTypeWidget(FeeType feeType, int index) {
    int customFeeTypeId = (feeType.customFeeTypesList ?? [])[index]?.customFeeTypeId ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: [
          const CustomVerticalDivider(),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Row(
              children: [
                Checkbox(
                  onChanged: (bool? value) {
                    if (value == null) return;
                    if (value) {
                      setState(() {
                        selectedCustomFeeTypes.add(customFeeTypeId);
                      });
                      _filterData();
                    } else {
                      setState(() {
                        selectedCustomFeeTypes.remove(customFeeTypeId);
                      });
                      _filterData();
                    }
                  },
                  value: selectedCustomFeeTypes.contains(customFeeTypeId),
                ),
                Expanded(
                  child: Text(
                    ((feeType.customFeeTypesList ?? [])[index]!.customFeeType ?? "-").capitalize(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeTypeTxn {
  int? feeTypeId;
  String? feeType;
  int? feePaidAmount;
  int? transactionId;
  List<_CustomFeeTypeTxn>? customFeeTypeTxns;

  _FeeTypeTxn(this.feeTypeId, this.feeType, this.feePaidAmount, this.transactionId, this.customFeeTypeTxns);
}

class _CustomFeeTypeTxn {
  int? customFeeTypeId;
  String? customFeeType;
  int? feePaidAmount;
  int? transactionId;

  _CustomFeeTypeTxn(this.customFeeTypeId, this.customFeeType, this.feePaidAmount, this.transactionId);
}

enum _StatFilterType { daily, monthly, lastNDays }

class _DateWiseTxnAmount {
  DateTime dateTime;
  int amount;
  BuildContext context;

  _DateWiseTxnAmount(this.dateTime, this.amount, this.context);

  @override
  String toString() {
    return """_DateWiseTxnAmount {"dateTime": "${convertDateTimeToYYYYMMDDFormat(dateTime)}", "amount": ${doubleToStringAsFixedForINR(amount / 100.0)}}""";
  }

  Widget widget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          emboss: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "${convertDateTimeToDDMMYYYYFormat(dateTime)}\n",
                  children: [
                    TextSpan(
                      text: "$INR_SYMBOL ${doubleToStringAsFixedForINR(amount / 100.0)} /-",
                      style: const TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    color: clayContainerTextColor(context),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthWiseTxnAmount {
  int month;
  int year;
  int amount;
  BuildContext context;

  _MonthWiseTxnAmount(this.month, this.year, this.amount, this.context);

  @override
  String toString() {
    return '_MonthWiseTxnAmount{month: $month, year: $year, amount: $amount, context: $context}';
  }

  Widget widget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          emboss: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "${MONTHS[month - 1].toLowerCase().capitalize()} - $year\n",
                  children: [
                    TextSpan(
                      text: "$INR_SYMBOL ${doubleToStringAsFixedForINR(amount / 100.0)} /-",
                      style: const TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    color: clayContainerTextColor(context),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewReceiptWidget extends StatefulWidget {
  const NewReceiptWidget({
    Key? key,
    required this.newReceipt,
  }) : super(key: key);

  final _NewReceipt newReceipt;

  @override
  State<NewReceiptWidget> createState() => _NewReceiptWidgetState();
}

class _NewReceiptWidgetState extends State<NewReceiptWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.all(10),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "New Receipt",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _deleteReceiptButton(context),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _receiptTextField(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _getDatePicker(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _studentSearchableDropDown(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _sectionSearchableDropDown(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.newReceipt.termWiseFeeToBePaidBeans.map((e) => termWiseWidget(e)).toList(),
              const SizedBox(height: 10),
              if (widget.newReceipt.selectedStudent != null && (widget.newReceipt.totalBusFee ?? 0) != 0) buildBusFeePayableWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Container buildBusFeePayableWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            children: [
              Checkbox(
                onChanged: (bool? value) {
                  if (value == null) return;
                  if (value) {
                    widget.newReceipt.notifyParent(() {
                      widget.newReceipt.isBusFeeChecked = value;
                      widget.newReceipt.busFeeController.text =
                          doubleToStringAsFixedForINR(((widget.newReceipt.totalBusFee ?? 0) - (widget.newReceipt.busFeePaid ?? 0)) / 100.0);
                    });
                  } else {
                    widget.newReceipt.notifyParent(() {
                      widget.newReceipt.isBusFeeChecked = value;
                      widget.newReceipt.busFeeController.text = "";
                    });
                  }
                },
                value: widget.newReceipt.isBusFeeChecked,
              ),
              const SizedBox(width: 5),
              const SizedBox(width: 15),
              const CustomVerticalDivider(),
              const SizedBox(width: 15),
              const Expanded(
                child: Text("Bus Fee"),
              ),
              const SizedBox(width: 10),
              Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.newReceipt.totalBusFee ?? 0) / 100)} /-"),
              const SizedBox(width: 20),
              _feePayingTextField(),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _feePayingTextField() {
    return SizedBox(
      width: 100,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.newReceipt.busFeePaid ?? 0) / 100)} /-",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          enabled: (widget.newReceipt.totalBusFee ?? 0) - (widget.newReceipt.busFeePaid ?? 0) != 0,
          onTap: () {
            widget.newReceipt.busFeeController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: widget.newReceipt.busFeeController.text.length,
            );
          },
          controller: widget.newReceipt.busFeeController,
          keyboardType: TextInputType.number,
          textAlignVertical: TextAlignVertical.center,
          maxLines: 1,
          onChanged: (String e) {
            if (e.isNotEmpty) {
              widget.newReceipt.notifyParent(() {
                widget.newReceipt.isBusFeeChecked = true;
              });
            } else {
              widget.newReceipt.notifyParent(() {
                widget.newReceipt.isBusFeeChecked = false;
              });
            }
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Amount",
          ),
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                double payingAmount = double.parse(text);
                if (payingAmount * 100 > (widget.newReceipt.totalBusFee ?? 0) - (widget.newReceipt.busFeePaid ?? 0)) {
                  return oldValue;
                }
                return newValue;
              } catch (e) {
                return oldValue;
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget termWiseWidget(_TermWiseFeeToBePaid termWiseFeeToBePaid) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      termWiseFeeToBePaid.termName ?? "-",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                      onTap: () {
                        if (termWiseFeeToBePaid.isExpanded == null) {
                          setState(() {
                            termWiseFeeToBePaid.isExpanded = true;
                          });
                          widget.newReceipt.notifyParent(() {});
                        } else if (termWiseFeeToBePaid.isExpanded!) {
                          setState(() {
                            termWiseFeeToBePaid.isExpanded = false;
                          });
                          widget.newReceipt.notifyParent(() {});
                        } else {
                          setState(() {
                            termWiseFeeToBePaid.isExpanded = true;
                          });
                          widget.newReceipt.notifyParent(() {});
                        }
                      },
                      child: (termWiseFeeToBePaid.isExpanded ?? false) ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              if (termWiseFeeToBePaid.isExpanded ?? false) ...(termWiseFeeToBePaid.termWiseFeeTypes ?? []).map((e) => e.widget(context)).toList(),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _deleteReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await showDialog<void>(
          context: widget.newReceipt.context,
          builder: (currentContext) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: const Text("Fee Receipts"),
                content: const Text("Are you sure you want to delete the receipt?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => widget.newReceipt.status = "deleted");
                      widget.newReceipt.notifyParent(() {});
                    },
                    child: const Text("YES"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("NO"),
                  ),
                ],
              );
            });
          },
        );
      },
      child: ClayButton(
        color: clayContainerColor(context),
        borderRadius: 100,
        spread: 2,
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Center(
            child: Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ),
    );
  }

  SizedBox _receiptTextField() {
    return SizedBox(
      width: 50,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "Receipt",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          controller: widget.newReceipt.receiptNumberController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 12),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Receipt No.",
          ),
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                if (text.isNotEmpty) int.parse(text);
                if (double.parse(text) > 0) {
                  return newValue;
                } else {
                  return oldValue;
                }
              } catch (e) {
                return oldValue;
              }
            }),
          ],
          onChanged: (String e) {
            widget.newReceipt.receiptNumber = int.tryParse(e);
          },
        ),
      ),
    );
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              setState(() => widget.newReceipt.selectedDate = widget.newReceipt.selectedDate.subtract(const Duration(days: 1)));
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 20,
              width: 20,
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_left),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: widget.newReceipt.selectedDate,
                  firstDate: DateTime(2021),
                  lastDate: DateTime.now(),
                  helpText: "Pick  date to mark attendance",
                );
                setState(() {
                  widget.newReceipt.selectedDate = _newDate ?? widget.newReceipt.selectedDate;
                });
              },
              child: ClayButton(
                color: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            convertDateTimeToDDMMYYYYFormat(widget.newReceipt.selectedDate),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              if (convertDateTimeToDDMMYYYYFormat(widget.newReceipt.selectedDate) == convertDateTimeToDDMMYYYYFormat(DateTime.now())) return;
              setState(() => widget.newReceipt.selectedDate = widget.newReceipt.selectedDate.add(const Duration(days: 1)));
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 20,
              width: 20,
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_right),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentSearchableDropDown() {
    return InputDecorator(
      isFocused: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        label: Text(
          "Student",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<StudentProfile>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: widget.newReceipt.selectedStudent,
          items: widget.newReceipt.studentProfiles
              .where((e) => widget.newReceipt.selectedSection == null || widget.newReceipt.selectedSection?.sectionId == e.sectionId)
              .toList(),
          itemAsString: (StudentProfile? student) {
            return student == null
                ? ""
                : [
                      ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                      student.studentFirstName ?? "",
                      student.studentMiddleName ?? "",
                      student.studentLastName ?? ""
                    ].where((e) => e != "").join(" ").trim() +
                    " - ${student.sectionName}";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, StudentProfile? student) {
            return buildStudentWidget(student ?? StudentProfile());
          },
          onChanged: (StudentProfile? student) {
            setState(() {
              widget.newReceipt.selectedSection = widget.newReceipt.sectionsList.where((e) => e.sectionId == student?.sectionId).firstOrNull;
            });
            widget.newReceipt.updatedSelectedStudent(student, setState);
          },
          showClearButton: false,
          compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (StudentProfile? student, String? key) {
            return ([
                      ((student?.rollNumber ?? "") == "" ? "" : student!.rollNumber! + "."),
                      student?.studentFirstName ?? "",
                      student?.studentMiddleName ?? "",
                      student?.studentLastName ?? ""
                    ].where((e) => e != "").join(" ") +
                    " - ${student?.sectionName ?? ""}")
                .toLowerCase()
                .trim()
                .contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }

  Widget buildStudentWidget(StudentProfile e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListTile(
        leading: MediaQuery.of(context).orientation == Orientation.portrait
            ? null
            : Container(
                width: 50,
                padding: const EdgeInsets.all(5),
                child: e.studentPhotoUrl == null
                    ? Image.asset(
                        "assets/images/avatar.png",
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        e.studentPhotoUrl!,
                        fit: BoxFit.contain,
                      ),
              ),
        title: AutoSizeText(
          ((e.rollNumber ?? "") == "" ? "" : e.rollNumber! + ". ") +
              ([e.studentFirstName ?? "", e.studentMiddleName ?? "", e.studentLastName ?? ""].where((e) => e != "").join(" ") +
                      " - ${e.sectionName ?? ""}")
                  .trim(),
          style: const TextStyle(
            fontSize: 14,
          ),
          overflow: TextOverflow.visible,
          maxLines: 3,
          minFontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionSearchableDropDown() {
    return InputDecorator(
      isFocused: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(15, 0, 5, 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        label: Text(
          "Section",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<Section>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: widget.newReceipt.selectedSection,
          items: widget.newReceipt.sectionsList,
          itemAsString: (Section? section) {
            return section == null ? "" : section.sectionName ?? "-";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, Section? section) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(widget.newReceipt.selectedSection?.sectionName ?? "-"),
            );
          },
          onChanged: (Section? section) {
            setState(() {
              widget.newReceipt.selectedSection = section;
            });
            widget.newReceipt.updatedSelectedStudent(null, setState);
          },
          showClearButton: false,
          compareFn: (item, selectedItem) => item?.sectionId == selectedItem?.sectionId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (Section? section, String? key) {
            return (section?.sectionName ?? "").toLowerCase().contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }
}

class _NewReceipt {
  BuildContext context;
  TextEditingController receiptNumberController = TextEditingController();

  int? receiptNumber;
  DateTime selectedDate;

  List<Section> sectionsList;
  List<StudentProfile> studentProfiles;
  List<StudentFeeDetailsBean> studentFeeDetails;
  List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans;
  List<FeeType> feeTypes;

  Section? selectedSection;
  StudentProfile? selectedStudent;

  String status = "active";
  final Function notifyParent;

  List<_TermWiseFeeToBePaid> termWiseFeeToBePaidBeans = [];
  TextEditingController busFeeController = TextEditingController();
  bool isBusFeeChecked = false;

  int? totalBusFee;
  int? busFeePaid;
  late List<StudentBusFeeLogBean> busFeeBeans;

  _NewReceipt({
    required this.context,
    required this.notifyParent,
    required this.receiptNumber,
    required this.selectedDate,
    required this.sectionsList,
    required this.studentProfiles,
    required this.studentFeeDetails,
    required this.studentTermWiseFeeBeans,
    required this.feeTypes,
    required this.totalBusFee,
    required this.busFeePaid,
    required this.busFeeBeans,
  }) {
    receiptNumberController.text = receiptNumber?.toString() ?? "";
    studentProfiles.sort((a, b) => ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0)) != 0
        ? ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0))
        : ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0)) != 0
            ? ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))
            : (((a.studentFirstName ?? ""))).compareTo(((b.studentFirstName ?? ""))));
  }

  void updatedSelectedStudent(StudentProfile? newStudent, Function setState) {
    setState(() {
      selectedStudent = newStudent;
      populateStudentTermWiseFeeDetails(selectedStudentId: newStudent?.studentId);
      termWiseFeeToBePaidBeans = getTermWiseFees();
    });
    notifyParent(() {});
  }

  void populateStudentTermWiseFeeDetails({int? selectedStudentId}) {
    if (selectedStudentId == null) return;
    for (var studentTermWiseFeeBean in studentTermWiseFeeBeans.where((e) => e.studentId == selectedStudentId)) {
      var filteredStudentFeeDetailsBeans = studentFeeDetails.where((studentFeeDetailsBean) =>
          studentFeeDetailsBean.studentId == selectedStudentId &&
          (studentFeeDetailsBean.studentWiseFeeTypeDetailsList ?? [])
              .where((studentWiseFeeTypeDetailsBean) =>
                  studentTermWiseFeeBean.studentId == studentWiseFeeTypeDetailsBean?.studentId &&
                  studentTermWiseFeeBean.feeTypeId == studentWiseFeeTypeDetailsBean?.feeTypeId &&
                  (studentTermWiseFeeBean.customFeeTypeId == null ||
                      studentTermWiseFeeBean.customFeeTypeId == studentWiseFeeTypeDetailsBean?.customFeeTypeId))
              .isEmpty);
      for (var studentFeeDetailsBean in filteredStudentFeeDetailsBeans.where((e) => e.studentId == selectedStudentId)) {
        studentFeeDetailsBean.studentWiseFeeTypeDetailsList!.add(StudentWiseFeeTypeDetailsBean(
          studentId: studentTermWiseFeeBean.studentId,
          sectionId: studentTermWiseFeeBean.sectionId,
          schoolId: studentTermWiseFeeBean.schoolId,
          feeTypeId: studentTermWiseFeeBean.feeTypeId,
          feeType: studentTermWiseFeeBean.feeType,
          customFeeTypeId: studentTermWiseFeeBean.customFeeTypeId,
          customFeeType: studentTermWiseFeeBean.customFeeType,
          studentTermWiseFeeTypeDetailsList: [],
        ));
      }
    }
    for (var studentTermWiseFeeBean in studentTermWiseFeeBeans.where((e) => e.studentId == selectedStudentId)) {
      for (var studentFeeDetailsBean
          in studentFeeDetails.where((studentFeeDetailsBean) => (studentTermWiseFeeBean.studentId == studentFeeDetailsBean.studentId))) {
        for (var studentWiseFeeTypeDetailsBean in (studentFeeDetailsBean.studentWiseFeeTypeDetailsList ?? [])) {
          if ((studentWiseFeeTypeDetailsBean?.feeTypeId == studentTermWiseFeeBean.feeTypeId) &&
              (studentTermWiseFeeBean.customFeeTypeId == null ||
                  (studentTermWiseFeeBean.customFeeTypeId == studentWiseFeeTypeDetailsBean?.customFeeTypeId))) {
            studentWiseFeeTypeDetailsBean?.studentTermWiseFeeTypeDetailsList!.add(
              StudentTermWiseFeeTypeDetailsBean(
                studentId: studentTermWiseFeeBean.studentId,
                sectionId: studentTermWiseFeeBean.sectionId,
                schoolId: studentTermWiseFeeBean.schoolId,
                feeTypeId: studentTermWiseFeeBean.feeTypeId,
                customFeeTypeId: studentTermWiseFeeBean.customFeeTypeId,
                termId: studentTermWiseFeeBean.termId,
                termName: studentTermWiseFeeBean.termName,
                termWiseTotalFee: studentTermWiseFeeBean.termWiseAmount,
                termWiseTotalFeePaid: studentTermWiseFeeBean.termWiseAmountPaid,
              ),
            );
          }
        }
      }
    }
    totalBusFee = studentFeeDetails.where((e) => e.studentId == selectedStudentId).map((e) => e.busFee).firstOrNull;
    busFeePaid = studentFeeDetails
        .where((e) => e.studentId == selectedStudentId)
        .map((e) => e.studentFeeTransactionList ?? [])
        .expand((i) => i)
        .map((e) => e?.studentFeeChildTransactionList ?? [])
        .expand((i) => i)
        .where((e) => e?.feeTypeId == null)
        .firstOrNull
        ?.feePaidAmount;
  }

  Widget widget() {
    return NewReceiptWidget(
      newReceipt: this,
    );
  }

  List<_TermWiseFeeToBePaid> getTermWiseFees() {
    if (selectedStudent == null) return [];
    StudentFeeDetailsBean? feeDetails = studentFeeDetails.where((e) => e.studentId == selectedStudent?.studentId).firstOrNull;
    if (feeDetails == null) return [];
    List<_Term> terms = (feeDetails.studentWiseFeeTypeDetailsList ?? [])
        .where((e) => e != null)
        .map((e) => e!)
        .map((e) => e.studentTermWiseFeeTypeDetailsList ?? [])
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .map((e) => _Term(e.termId, e.termName))
        .toSet()
        .toList();
    List<_TermWiseFeeToBePaid> termWiseFees = [];
    for (var eachTerm in terms) {
      termWiseFees.add(_TermWiseFeeToBePaid(
        context,
        notifyParent,
        eachTerm.termId,
        eachTerm.termName,
        selectedStudent?.studentId,
        [selectedStudent?.studentFirstName ?? "", selectedStudent?.studentMiddleName ?? "", selectedStudent?.studentLastName ?? ""]
            .where((e) => e != "")
            .join(" "),
        null,
        null,
        null,
      ));
    }

    for (var eachTermWiseFee in termWiseFees) {
      eachTermWiseFee.termWiseFeeTypes = feeTypes.map((eachFeeType) {
        return _TermWiseFeeType(
          eachTermWiseFee.termId,
          eachFeeType.feeTypeId,
          eachFeeType.feeType,
          null,
          null,
          (eachFeeType.customFeeTypesList ?? [])
              .where((e) => e != null)
              .map((e) => e!)
              .map((eachCustomFeeType) => _TermWiseCustomFeeType(
                    eachTermWiseFee.termId,
                    eachCustomFeeType.feeTypeId,
                    eachCustomFeeType.customFeeTypeId,
                    eachCustomFeeType.customFeeType,
                    null,
                    null,
                    notifyParent,
                  ))
              .toList(),
          notifyParent,
        );
      }).toList();
    }

    for (_TermWiseFeeToBePaid eachTermWiseFee in termWiseFees) {
      for (_TermWiseFeeType eachTermWiseFeeTypeFee in (eachTermWiseFee.termWiseFeeTypes ?? [])) {
        if ((eachTermWiseFeeTypeFee.termWiseCustomFeeTypes ?? []).isNotEmpty) {
          for (_TermWiseCustomFeeType eachTermWiseCustomFeeTypeFee in (eachTermWiseFeeTypeFee.termWiseCustomFeeTypes ?? [])) {
            StudentTermWiseFeeTypeDetailsBean? studentWiseCustomFeeTypeDetails = ((feeDetails.studentWiseFeeTypeDetailsList ?? [])
                        .where((e) => e != null)
                        .map((e) => e!)
                        .where((e) =>
                            e.feeTypeId == eachTermWiseFeeTypeFee.feeTypeId && e.customFeeTypeId == eachTermWiseCustomFeeTypeFee.customFeeTypeId)
                        .firstOrNull
                        ?.studentTermWiseFeeTypeDetailsList ??
                    [])
                .where((e) => e != null)
                .map((e) => e!)
                .where((e) => e.termId == eachTermWiseCustomFeeTypeFee.termId)
                .firstOrNull;
            eachTermWiseCustomFeeTypeFee.termWiseFee = studentWiseCustomFeeTypeDetails?.termWiseTotalFee;
            eachTermWiseCustomFeeTypeFee.termWiseFeePaid = studentWiseCustomFeeTypeDetails?.termWiseTotalFeePaid;
          }
        } else {
          StudentTermWiseFeeTypeDetailsBean? studentWiseFeeTypeDetails = ((feeDetails.studentWiseFeeTypeDetailsList ?? [])
                      .where((e) => e != null)
                      .map((e) => e!)
                      .where((e) => e.feeTypeId == eachTermWiseFeeTypeFee.feeTypeId)
                      .firstOrNull
                      ?.studentTermWiseFeeTypeDetailsList ??
                  [])
              .where((e) => e != null)
              .map((e) => e!)
              .where((e) => e.termId == eachTermWiseFeeTypeFee.termId)
              .firstOrNull;
          eachTermWiseFeeTypeFee.termWiseFee = studentWiseFeeTypeDetails?.termWiseTotalFee;
          eachTermWiseFeeTypeFee.termWiseFeePaid = studentWiseFeeTypeDetails?.termWiseTotalFeePaid;
        }
      }
    }

    for (var eachTermWiseFee in termWiseFees) {
      eachTermWiseFee.termWiseTotalFee = (eachTermWiseFee.termWiseFeeTypes ?? [])
          .map((e) => (e.termWiseCustomFeeTypes ?? []).isEmpty
              ? e.termWiseFee
              : (e.termWiseCustomFeeTypes ?? []).map((e) => e.termWiseFee).reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0)))
          .reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0));
      eachTermWiseFee.termWiseTotalFeesPaid = (eachTermWiseFee.termWiseFeeTypes ?? [])
          .map((e) => (e.termWiseCustomFeeTypes ?? []).isEmpty
              ? e.termWiseFeePaid
              : (e.termWiseCustomFeeTypes ?? []).map((e) => e.termWiseFeePaid).reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0)))
          .reduce((a1, a2) => (a1 ?? 0) + (a2 ?? 0));
    }

    for (_TermWiseFeeToBePaid eachTerm in termWiseFees) {
      if ((eachTerm.termWiseTotalFee ?? 0) > (eachTerm.termWiseTotalFeesPaid ?? 0)) {
        eachTerm.isExpanded = true;
        break;
      }
    }

    return termWiseFees;
  }

  @override
  String toString() {
    return """{"studentId": ${selectedStudent?.studentId}, "receiptNumber": $receiptNumber, "termWiseFeeToBePaidBeans": $termWiseFeeToBePaidBeans}""";
  }
}

class _Term {
  int? termId;
  String? termName;

  _Term(this.termId, this.termName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _Term && runtimeType == other.runtimeType && termId == other.termId && termName == other.termName;

  @override
  int get hashCode => termId.hashCode ^ termName.hashCode;
}

class _TermWiseFeeToBePaid {
  BuildContext context;
  Function notifyParent;
  int? termId;
  String? termName;
  int? studentId;
  String? studentName;
  int? termWiseTotalFee;
  int? termWiseTotalFeesPaid;

  List<_TermWiseFeeType>? termWiseFeeTypes;

  bool? isExpanded;

  _TermWiseFeeToBePaid(
    this.context,
    this.notifyParent,
    this.termId,
    this.termName,
    this.studentId,
    this.studentName,
    this.termWiseTotalFee,
    this.termWiseTotalFeesPaid,
    this.termWiseFeeTypes,
  );

  @override
  String toString() {
    return '{termId: $termId, termName: $termName, studentId: $studentId, studentName: $studentName, termWiseTotalFee: $termWiseTotalFee, termWiseTotalFeesPaid: $termWiseTotalFeesPaid, termWiseFeeTypes: $termWiseFeeTypes}';
  }
}

class _TermWiseFeeType {
  int? termId;
  int? feeTypeId;
  String? feeType;
  int? termWiseFee;
  int? termWiseFeePaid;
  List<_TermWiseCustomFeeType>? termWiseCustomFeeTypes;
  Function notifyParent;

  _TermWiseFeeType(
    this.termId,
    this.feeTypeId,
    this.feeType,
    this.termWiseFee,
    this.termWiseFeePaid,
    this.termWiseCustomFeeTypes,
    this.notifyParent,
  );

  TextEditingController feePayingController = TextEditingController();
  bool isChecked = false;

  Widget widget(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            (termWiseCustomFeeTypes ?? []).isEmpty
                ? Checkbox(
                    onChanged: (bool? value) {
                      if (value == null) return;
                      if (value) {
                        notifyParent(() {
                          isChecked = value;
                          feePayingController.text = doubleToStringAsFixedForINR(((termWiseFee ?? 0) - (termWiseFeePaid ?? 0)) / 100.0);
                        });
                      } else {
                        notifyParent(() {
                          isChecked = value;
                          feePayingController.text = "";
                        });
                      }
                    },
                    value: isChecked,
                  )
                : Container(),
            (termWiseCustomFeeTypes ?? []).isEmpty ? const SizedBox(width: 10) : Container(),
            Expanded(
              child: Text(feeType ?? "-"),
            ),
            const SizedBox(width: 10),
            (termWiseCustomFeeTypes ?? []).isEmpty
                ? Text(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR((termWiseFee ?? 0) / 100)} /-",
                  )
                : Container(),
            const SizedBox(width: 20),
            (termWiseCustomFeeTypes ?? []).isEmpty ? _feePayingTextField(context) : Container(),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ...(termWiseCustomFeeTypes ?? []).map((e) => e.widget(context)).toList(),
      ],
    );
  }

  SizedBox _feePayingTextField(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR((termWiseFeePaid ?? 0) / 100)} /-",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          enabled: (termWiseFee ?? 0) - (termWiseFeePaid ?? 0) != 0,
          onTap: () {
            feePayingController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: feePayingController.text.length,
            );
          },
          controller: feePayingController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Amount",
          ),
          onChanged: (String e) {
            if (e.isNotEmpty) {
              notifyParent(() {
                isChecked = true;
              });
            } else {
              notifyParent(() {
                isChecked = false;
              });
            }
          },
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                double payingAmount = double.parse(text);
                if (payingAmount * 100 > (termWiseFee ?? 0) - (termWiseFeePaid ?? 0)) {
                  return oldValue;
                }
                return newValue;
              } catch (e) {
                return oldValue;
              }
            }),
          ],
        ),
      ),
    );
  }

  @override
  String toString() {
    if ((termWiseCustomFeeTypes ?? []).isEmpty && feePayingController.text.trim().isNotEmpty && feePayingController.text.trim() != "0") {
      return """{"termId": $termId, "feeTypeId": $feeTypeId, "feeType": "$feeType", "customFeeTypeId": null, "customFeeType": null, "feePaying": ${feePayingController.text}}""";
    }
    if ((termWiseCustomFeeTypes ?? []).isNotEmpty) {
      return termWiseCustomFeeTypes?.map((e) => e.toString()).join(",") ?? "";
    }
    // return '_TermWiseFeeType{termId: $termId, feeTypeId: $feeTypeId, feeType: $feeType, termWiseFee: $termWiseFee, termWiseFeePaid: $termWiseFeePaid, termWiseCustomFeeTypes: $termWiseCustomFeeTypes, feePayingController: $feePayingController}';
    return "";
  }
}

class _TermWiseCustomFeeType {
  int? termId;
  int? feeTypeId;
  int? customFeeTypeId;
  String? customFeeType;
  int? termWiseFee;
  int? termWiseFeePaid;
  Function notifyParent;

  _TermWiseCustomFeeType(
    this.termId,
    this.feeTypeId,
    this.customFeeTypeId,
    this.customFeeType,
    this.termWiseFee,
    this.termWiseFeePaid,
    this.notifyParent,
  );

  TextEditingController feePayingController = TextEditingController();
  bool isChecked = false;

  Widget widget(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              onChanged: (bool? value) {
                if (value == null) return;
                if (value) {
                  notifyParent(() {
                    isChecked = value;
                    feePayingController.text = doubleToStringAsFixedForINR(((termWiseFee ?? 0) - (termWiseFeePaid ?? 0)) / 100.0);
                  });
                } else {
                  notifyParent(() {
                    isChecked = value;
                    feePayingController.text = "";
                  });
                }
              },
              value: isChecked,
            ),
            const SizedBox(width: 5),
            const SizedBox(width: 15),
            const CustomVerticalDivider(),
            const SizedBox(width: 15),
            Expanded(
              child: Text(customFeeType ?? "-"),
            ),
            const SizedBox(width: 10),
            Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((termWiseFee ?? 0) / 100)} /-"),
            const SizedBox(width: 20),
            _feePayingTextField(context),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  SizedBox _feePayingTextField(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 40,
      child: InputDecorator(
        isFocused: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR((termWiseFeePaid ?? 0) / 100)} /-",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          enabled: (termWiseFee ?? 0) - (termWiseFeePaid ?? 0) != 0,
          onTap: () {
            feePayingController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: feePayingController.text.length,
            );
          },
          controller: feePayingController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Amount",
          ),
          textAlign: TextAlign.center,
          onChanged: (String e) {
            if (e.isNotEmpty) {
              notifyParent(() {
                isChecked = true;
              });
            } else {
              notifyParent(() {
                isChecked = false;
              });
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                if (newValue.text == "") return newValue;
                final text = newValue.text;
                double payingAmount = double.parse(text);
                if (payingAmount * 100 > (termWiseFee ?? 0) - (termWiseFeePaid ?? 0)) {
                  return oldValue;
                }
                return newValue;
              } catch (e) {
                return oldValue;
              }
            }),
          ],
        ),
      ),
    );
  }

  @override
  String toString() {
    if (feePayingController.text.trim().isNotEmpty && feePayingController.text.trim() != "0") {
      return """{"termId": $termId, "feeTypeId": $feeTypeId, "feeType": null, "customFeeTypeId": $customFeeTypeId, "customFeeType": "$customFeeType", "feePaying": ${feePayingController.text}}""";
    }
    // return '_TermWiseCustomFeeType{termId: $termId, feeTypeId: $feeTypeId, customFeeTypeId: $customFeeTypeId, customFeeType: $customFeeType, termWiseFee: $termWiseFee, termWiseFeePaid: $termWiseFeePaid, feePayingController: $feePayingController}';
    return "";
  }
}
