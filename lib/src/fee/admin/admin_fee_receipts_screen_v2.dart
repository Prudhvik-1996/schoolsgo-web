import 'dart:html' as html;
import 'dart:math';

import 'package:clay_containers/clay_containers.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_fee_receipts_each_receipt_widget.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_fee_receipts_stats_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/fee_receipts_search_widget.dart';
import 'package:schoolsgo_web/src/fee/admin/new_receipt_widget.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/fee_support_classes.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  bool _isTermWise = true;
  String? _renderingReceiptText;
  double _loadingReceiptPercentage = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ItemScrollController _itemScrollController = ItemScrollController();
  late SchoolInfoBean schoolInfoBean;

  List<Section> sectionsList = [];

  List<StudentProfile> studentProfiles = [];

  List<StudentFeeDetailsBean> studentFeeDetailsBeans = [];
  List<StudentAnnualFeeSupportBean> studentAnnualFeeBeanBeans = [];
  List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans = [];
  List<StudentMasterTransactionSupportBean> studentMasterTransactionBeans = [];
  List<StudentWiseFeePaidSupportBean> studentWiseFeePaidBeans = [];
  List<StudentBusFeeLogBean> busFeeBeans = [];

  List<StudentFeeDetailsBean> filteredStudentFeeDetailsBeanList = [];

  List<int> selectedFeeTypes = [];
  List<int> selectedCustomFeeTypes = [];
  List<FeeType> feeTypes = [];

  List<NewReceipt> newReceipts = [];
  late int latestReceiptNumberToBeAdded;

  TextEditingController reasonToDeleteTextController = TextEditingController();
  Uint8List? pdfInBytes;

  int offset = 0;
  int limit = 5;
  bool isSearchBarSelected = false;
  bool isFilterPressed = false;
  final NumberPaginatorController paginationController = NumberPaginatorController();

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
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfoBean = getSchoolsResponse.schoolInfo!;
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
      studentFeeDetailsBeans = mergeAndGetStudentFeeDetailsBeans();
      try {
        // TODO discuss a logic to figure out latest
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
    newReceipts.add(NewReceipt(
      context: _scaffoldKey.currentContext!,
      notifyParent: setState,
      receiptNumber: latestReceiptNumberToBeAdded,
      selectedDate: DateTime.now(),
      sectionsList: sectionsList,
      studentProfiles: studentProfiles,
      studentFeeDetails: studentFeeDetailsBeans.map((e) => StudentFeeDetailsBean.fromJson(e.toJson())).toList(),
      studentTermWiseFeeBeans: studentTermWiseFeeBeans,
      studentAnnualFeeBeanBeans: studentAnnualFeeBeanBeans,
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
                  modeOfPayment: studentMasterTransactionBean.modeOfPayment,
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
                  termComponents: [],
                );
              }).toList();
            }));
    for (var eachStudentFeeDetails in studentFeeDetailsBeans) {
      busFeeBeans.where((eachBusFee) => eachBusFee.studentId == eachStudentFeeDetails.studentId).forEach((eachBusFee) {
        eachStudentFeeDetails.busFee = eachBusFee.fare;
      });
    }
    return studentFeeDetailsBeans;
  }

  Future<void> _filterData() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      filteredStudentFeeDetailsBeanList = studentFeeDetailsBeans.map((e) => StudentFeeDetailsBean.fromJson(e.toJson())).toList();
    });
    populateTermTxnWiseComponents();
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
      _isLoading = false;
    });
  }

  void populateTermTxnWiseComponents() {
    for (StudentFeeDetailsBean eachStudentFeeDetailsBean in filteredStudentFeeDetailsBeanList) {
      List<StudentTermWiseFeeSupportBean> studentWiseTermFeeTypes = (studentTermWiseFeeBeans)
          .where((e) => e.studentId == eachStudentFeeDetailsBean.studentId)
          .map((e) => StudentTermWiseFeeSupportBean.fromJson(e.origJson()))
          .toList();
      studentWiseTermFeeTypes.sort((a, b) => (a.termId ?? 0).compareTo((b.termId ?? 0)));
      (eachStudentFeeDetailsBean.studentFeeTransactionList ?? []).forEach((StudentFeeTransactionBean? eachStudentFeeTransactionBean) {
        if (eachStudentFeeTransactionBean == null) return;
        (eachStudentFeeTransactionBean.studentFeeChildTransactionList ?? []).forEach((StudentFeeChildTransactionBean? eachChildTxn) {
          if (eachChildTxn == null) return;
          int paidAmountDec = eachChildTxn.feePaidAmount ?? 0;
          while (paidAmountDec != 0) {
            StudentTermWiseFeeSupportBean? x = studentWiseTermFeeTypes
                .where((e) =>
                    e.feeTypeId == eachChildTxn.feeTypeId &&
                    (eachChildTxn.customFeeTypeId == null || eachChildTxn.customFeeTypeId == e.customFeeTypeId))
                .where((e) => (e.termWiseAmount ?? 0) > 0)
                .firstOrNull;
            if (x == null) {
              break;
            }
            int amountPaidForTerm = 0;
            int termFee = x.termWiseAmount ?? 0;
            if ((x.termWiseAmount ?? 0) > paidAmountDec) {
              amountPaidForTerm = paidAmountDec;
              x.termWiseAmount = termFee - paidAmountDec;
              paidAmountDec = 0;
            } else {
              amountPaidForTerm = termFee;
              paidAmountDec = paidAmountDec - termFee;
              x.termWiseAmount = 0;
            }
            eachChildTxn.termComponents ??= [];
            eachChildTxn.termComponents!.add(TermComponent(x.termId, x.termName, amountPaidForTerm, termFee));
          }
        });
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    String? errorText;
    for (NewReceipt eachNewReceipt in newReceipts.where((e) => e.status != "deleted")) {
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
              subBeans: eachNewReceipt.feeToBePaidBeans
                  .map((eachTermWiseFeeToBePaid) {
                    List<NewReceiptBeanSubBean> subBeans = [];
                    if ((eachTermWiseFeeToBePaid.feeTypes ?? []).isNotEmpty) {
                      for (FeeTypeForNewReceipt eachTermWiseFeeType in (eachTermWiseFeeToBePaid.feeTypes ?? [])) {
                        if ((eachTermWiseFeeType.customFeeTypes ?? []).isEmpty) {
                          if (eachTermWiseFeeType.isChecked &&
                              eachTermWiseFeeType.feePayingController.text.trim().isNotEmpty &&
                              eachTermWiseFeeType.feePayingController.text != "0") {
                            subBeans.add(NewReceiptBeanSubBean(
                              feeTypeId: eachTermWiseFeeType.feeTypeId!,
                              customFeeTypeId: null,
                              feePaying: int.parse(eachTermWiseFeeType.feePayingController.text.replaceAll(",", "")) * 100,
                            ));
                          }
                        } else {
                          for (CustomFeeTypeForNewReceipt eachTermWiseCustomFeeType in (eachTermWiseFeeType.customFeeTypes ?? [])) {
                            if (eachTermWiseCustomFeeType.isChecked &&
                                eachTermWiseCustomFeeType.feePayingController.text.trim().isNotEmpty &&
                                eachTermWiseCustomFeeType.feePayingController.text != "0") {
                              subBeans.add(NewReceiptBeanSubBean(
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
              modeOfPayment: eachNewReceipt.modeOfPayment.name,
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

  pw.Widget paddedText(
    final String text,
    final pw.Font font, {
    final pw.EdgeInsets padding = const pw.EdgeInsets.all(6),
    final pw.TextAlign align = pw.TextAlign.left,
    final double fontSize = 16,
    final pw.FontWeight fontWeight = pw.FontWeight.normal,
  }) =>
      pw.Padding(
        padding: padding,
        child: pw.Text(
          text,
          textAlign: align,
          style: pw.TextStyle(
            font: font,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      );

  Future<void> makePdf() async {
    setState(() {
      _renderingReceiptText = "Preparing receipts";
    });
    final pdf = pw.Document();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();
    final font = await PdfGoogleFonts.merriweatherRegular();

    // pw.ImageProvider logoImageProvider;
    //
    // try {
    //   logoImageProvider = await networkImage(
    //     schoolInfoBean.logoPictureUrl ?? "https://storage.googleapis.com/storage-schools-go/Episilon%20infinity.jpg",
    //   );
    // } catch (e) {
    //   logoImageProvider = pw.MemoryImage(
    //     (await rootBundle.load('images/EISlogo.png')).buffer.asUint8List(),
    //   );
    // }

    List<StudentFeeTransactionBean> txns =
        (studentFeeDetailsBeans.map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!)).expand((i) => i).toList()
          ..sort(
            (b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) == 0
                ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                    ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                    : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
                : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
          ));

    for (int i = 0; i < txns.length; i++) {
      StudentFeeTransactionBean eachTransaction = txns[i];
      setState(() {
        _renderingReceiptText = "Rendering receipt ${eachTransaction.receiptId}";
        _loadingReceiptPercentage = 100.0 * (i / txns.length);
      });
      List<pw.Widget> widgets = [];
      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            // pw.Padding(
            //   padding: const pw.EdgeInsets.fromLTRB(5, 5, 5, 5),
            //   child: pw.Image(
            //     logoImageProvider,
            //     width: 60,
            //     height: 60,
            //   ),
            // ),
            // pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    schoolInfoBean.schoolDisplayName ?? "-",
                    style: pw.TextStyle(font: schoolNameFont, fontSize: 30, color: PdfColors.blue),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    schoolInfoBean.detailedAddress ?? "-",
                    style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey900),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      pw.Container eachTxnContainer = pw.Container(
        // decoration: pw.BoxDecoration(
        //   border: pw.Border.all(color: PdfColors.black),
        // ),
        padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
        child: pw.Column(
          children: [
            pw.SizedBox(
              height: 10,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    "Fee Receipt",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 18,
                      decoration: pw.TextDecoration.underline,
                      color: PdfColors.black,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                    flex: 3,
                    child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
                      pw.Text(
                        "Receipt No.: ",
                        style: pw.TextStyle(font: font, fontSize: 16),
                        textAlign: pw.TextAlign.left,
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          " ${eachTransaction.receiptId ?? "-"}",
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 16,
                            color: PdfColors.red,
                          ),
                          textAlign: pw.TextAlign.left,
                        ),
                      ),
                    ])),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    "Date: ${convertDateToDDMMMYYY(eachTransaction.transactionDate)}",
                    style: pw.TextStyle(font: font, fontSize: 16),
                  ),
                ),
              ],
            ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    "Student Name: ${eachTransaction.studentName ?? "-"}",
                    style: pw.TextStyle(font: font, fontSize: 18),
                  ),
                ),
              ],
            ),
            if (studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.fatherName != null)
              pw.SizedBox(
                height: 10,
              ),
            if (studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.fatherName != null)
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      "S/o / D/o: ${studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.fatherName ?? "-"}",
                      style: pw.TextStyle(font: font, fontSize: 16),
                    ),
                  ),
                ],
              ),
            pw.SizedBox(
              height: 10,
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    "Section: ${studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.sectionName ?? "-"}",
                    style: pw.TextStyle(font: font, fontSize: 16),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    "Roll No.: ${studentProfiles.where((e) => e.studentId == eachTransaction.studentId).firstOrNull?.rollNumber ?? "-"}",
                    style: pw.TextStyle(font: font, fontSize: 16),
                  ),
                ),
              ],
            ),
            pw.SizedBox(
              height: 10,
            ),
          ],
        ),
      );
      widgets.add(eachTxnContainer);
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black),
            children: [
              pw.TableRow(
                children: [
                  pw.Expanded(
                    child: paddedText(
                      "Particulars",
                      font,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.center,
                    ),
                  ),
                  paddedText(
                    "Amount",
                    font,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    align: pw.TextAlign.center,
                  ),
                ],
              ),
              ...childTransactionsPdfWidgets(eachTransaction, font),
              pw.TableRow(
                children: [
                  pw.Expanded(
                    child: paddedText(
                      "Total",
                      font,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      align: pw.TextAlign.center,
                    ),
                  ),
                  paddedText(
                    "$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTransaction.transactionAmount ?? 0) / 100)} /-",
                    font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(50, 10, 50, 10),
          child: pw.Row(
            children: [
              paddedText(
                "Mode Of Payment: ${eachTransaction.modeOfPayment ?? "CASH"}",
                font,
                fontSize: 14,
                align: pw.TextAlign.left,
              ),
              pw.Expanded(
                child: paddedText(
                  "Signature",
                  font,
                  fontSize: 16,
                  align: pw.TextAlign.right,
                  padding: const pw.EdgeInsets.fromLTRB(6, 60, 6, 6),
                ),
              ),
            ],
          ),
        ),
      );
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return widgets;
        },
      ));
    }

    var x = await pdf.save();
    setState(() {
      pdfInBytes = x;
    });

    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = "Receipts.pdf";
    anchorElement.click();
    setState(() {
      _renderingReceiptText = null;
      _isLoading = false;
    });
  }

  List<pw.TableRow> childTransactionsPdfWidgets(StudentFeeTransactionBean e, pw.Font font) {
    // return (e.studentFeeChildTransactionList ?? []).map((e) => Container()).toList();
    List<pw.TableRow> childTxnWidgets = [];
    List<StudentFeeChildTransactionBean> childTxns =
        (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) => e.feeTypeId != null).toList();
    List<StudentFeeChildTransactionBean> busFeeTxns =
        (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) => e.feeTypeId == null).toList();
    List<FeeTypeTxn> feeTypeTxns = [];
    for (StudentFeeChildTransactionBean eachChildTxn in childTxns) {
      if (eachChildTxn.customFeeTypeId == null) {
        feeTypeTxns.add(FeeTypeTxn(eachChildTxn.feeTypeId, eachChildTxn.feeType, null, null, [], eachChildTxn.termComponents ?? []));
      } else {
        if (!feeTypeTxns.map((e) => e.feeTypeId).contains(eachChildTxn.feeTypeId)) {
          feeTypeTxns.add(FeeTypeTxn(eachChildTxn.feeTypeId, eachChildTxn.feeType, null, null, [], eachChildTxn.termComponents ?? []));
        }
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in childTxns) {
      if (eachChildTxn.customFeeTypeId != null && eachChildTxn.customFeeTypeId != 0) {
        feeTypeTxns.where((e) => e.feeTypeId == eachChildTxn.feeTypeId).forEach((eachFeeTypeTxn) {
          eachFeeTypeTxn.customFeeTypeTxns?.add(CustomFeeTypeTxn(eachChildTxn.customFeeTypeId, eachChildTxn.customFeeType, eachChildTxn.feePaidAmount,
              eachFeeTypeTxn.transactionId, eachChildTxn.termComponents ?? []));
        });
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in busFeeTxns) {
      if (!feeTypeTxns.map((e) => e.feeTypeId).contains(eachChildTxn.feeTypeId)) {
        feeTypeTxns.add(FeeTypeTxn(
            eachChildTxn.feeTypeId, "Bus Fee", eachChildTxn.feePaidAmount, eachChildTxn.transactionId, [], eachChildTxn.termComponents ?? []));
      }
    }
    feeTypeTxns.sort(
      (a, b) => a.feeType == "Bus Fee"
          ? -2
          : (a.customFeeTypeTxns ?? []).isEmpty
              ? -1
              : 1,
    );
    for (FeeTypeTxn eachFeeTypeTxn in feeTypeTxns.where((e) => e.feeTypeId != null)) {
      if (eachFeeTypeTxn.customFeeTypeTxns?.isEmpty ?? true) {
        eachFeeTypeTxn.feePaidAmount =
            childTxns.where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId).map((e) => e.feePaidAmount).reduce((c1, c2) => (c1 ?? 0) + (c2 ?? 0));
        eachFeeTypeTxn.transactionId = childTxns.where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId).map((e) => e.transactionId).firstOrNull;
      } else {
        eachFeeTypeTxn.feePaidAmount = eachFeeTypeTxn.customFeeTypeTxns?.map((e) => e.feePaidAmount).reduce((c1, c2) => (c1 ?? 0) + (c2 ?? 0));
      }
    }
    for (FeeTypeTxn eachFeeTypeTxn in feeTypeTxns.toSet()) {
      if ((eachFeeTypeTxn.customFeeTypeTxns ?? []).isEmpty) {
        childTxnWidgets.add(
          pw.TableRow(
            children: [
              pw.Expanded(
                child: paddedText(eachFeeTypeTxn.feeType ?? "-", font),
              ),
              !_isTermWise || (eachFeeTypeTxn.termComponents).isEmpty
                  ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                  : paddedText("", font),
            ],
          ),
        );
        if (_isTermWise && (eachFeeTypeTxn.termComponents).isNotEmpty) {
          for (TermComponent eachTermComponent in eachFeeTypeTxn.termComponents) {
            childTxnWidgets.add(
              pw.TableRow(
                children: [
                  pw.Expanded(
                    child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                  ),
                  paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.feePaid ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                ],
              ),
            );
          }
        }
      } else {
        childTxnWidgets.add(pw.TableRow(
          children: [
            pw.Expanded(
              child: paddedText(eachFeeTypeTxn.feeType ?? "-", font),
            ),
          ],
        ));
        for (var eachCustomFeeTypeTxn in (eachFeeTypeTxn.customFeeTypeTxns ?? [])) {
          childTxnWidgets.add(pw.TableRow(
            children: [
              pw.Expanded(
                child: paddedText(eachCustomFeeTypeTxn.customFeeType ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(8, 6, 6, 6)),
              ),
              !_isTermWise || (eachCustomFeeTypeTxn.termComponents).isEmpty
                  ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                  : paddedText("", font),
            ],
          ));
          if (_isTermWise && (eachCustomFeeTypeTxn.termComponents).isNotEmpty) {
            for (TermComponent eachTermComponent in eachCustomFeeTypeTxn.termComponents) {
              childTxnWidgets.add(
                pw.TableRow(
                  children: [
                    pw.Expanded(
                      child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                    ),
                    paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.feePaid ?? 0) / 100.0)} /-", font,
                        align: pw.TextAlign.right)
                  ],
                ),
              );
            }
          }
        }
      }
    }

    return childTxnWidgets;
  }

  Future<void> handleClick(String choice) async {
    if (choice == "Go to date") {
      await goToDateAction();
    } else if (choice == "Term Wise") {
      setState(() => _isTermWise = !_isTermWise);
    } else if (choice == "Print") {
      makePdf();
    } else {
      debugPrint("Clicked on $choice");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AdminFeeReceiptsStatsScreen(
          adminProfile: widget.adminProfile,
          studentFeeDetailsBeanList: studentFeeDetailsBeans,
          feeTypes: feeTypes,
          studentTermWiseFeeBeans: studentTermWiseFeeBeans,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Fee Receipts"),
        actions: _isLoading ||
                filteredStudentFeeDetailsBeanList
                    .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
                    .expand((i) => i)
                    .isEmpty
            ? []
            : [
                pdfInBytes != null
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            pdfInBytes = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      )
                    : Container(),
                if (pdfInBytes == null)
                  IconButton(
                    icon: Icon(isFilterPressed ? Icons.clear : Icons.filter_alt_sharp),
                    onPressed: () => setState(() {
                      isFilterPressed = !isFilterPressed;
                      isSearchBarSelected = false;
                    }),
                  ),
                if (pdfInBytes == null && !isSearchBarSelected)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: SearchWidget(
                      isSearchBarSelectedByDefault: false,
                      onComplete: scrollToReceiptNumber,
                      receiptNumbers: (filteredStudentFeeDetailsBeanList
                              .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
                              .expand((i) => i)
                              .toList()
                            ..sort(
                              (b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate)
                                          .compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) ==
                                      0
                                  ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                                      ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                                      : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
                                  : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
                            ))
                          .map((e) => (e.receiptId ?? "-").toString())
                          .toList(),
                      isSearchButtonSelected: isSearchButtonSelected,
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (String choice) async => await handleClick(choice),
                  itemBuilder: (BuildContext context) {
                    return {"Go to date", "Term Wise", "Stats", "Print"}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: choice == "Term Wise"
                            ? _isTermWise
                                ? const Text("Disable Term Wise")
                                : const Text("Enable Term Wise")
                            : Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : _renderingReceiptText != null
              ? buildRenderingReceiptsWidget()
              : pdfInBytes != null
                  ? buildPdfPreviewWidget()
                  : _isAddNew
                      ? buildNewReceiptWidget(context)
                      : buildFilteredReceiptsListView(),
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

  void scrollToReceiptNumber(int e) {
    if (e == -1) return;
    setState(() {
      offset = (e / limit).floor() * limit;
    });
    _itemScrollController.scrollTo(
      index: e - offset + 2,
      duration: const Duration(milliseconds: 1),
      curve: Curves.linear,
    );
    paginationController.navigateToPage((offset / limit).floor());
  }

  Widget buildFilteredReceiptsListView() {
    List filteredList = filteredStudentFeeDetailsBeanList
        .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
        .expand((i) => i)
        .toList()
      ..sort(
        (b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) == 0
            ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
            : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
      );
    if (filteredList.isEmpty) {
      return ListView(
        children: const [
          // statsWidget(),
          // filtersWidget(),
          SizedBox(height: 20),
          Center(
            child: Text(
              "No Transactions to display",
            ),
          ),
          SizedBox(height: 150),
        ],
      );
    }
    return Stack(
      children: [
        ScrollablePositionedList.builder(
          initialScrollIndex: filteredList.isNotEmpty ? 2 : 0,
          physics: const BouncingScrollPhysics(),
          itemScrollController: _itemScrollController,
          itemCount: filteredList.sublist(offset).length > limit ? limit + 3 : filteredList.sublist(offset).length + 3,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              // return statsWidget();
              return Container();
            } else if (index == 1) {
              // return filtersWidget();
              return Container();
            } else if ((filteredList.sublist(offset).length > limit ? limit + 2 : filteredList.sublist(offset).length + 2) == index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(50, 5, 50, 150),
                child: NumberPaginator(
                  controller: paginationController,
                  numberPages: (filteredList.length / limit).ceil(),
                  onPageChange: (int pageIndex) {
                    setState(() {
                      offset = pageIndex * limit;
                    });
                  },
                  initialPage: (offset / limit).floor(),
                  config: NumberPaginatorUIConfig(
                    height: 48,
                    mode: MediaQuery.of(context).orientation == Orientation.landscape ? ContentDisplayMode.numbers : ContentDisplayMode.dropdown,
                    buttonShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    buttonSelectedForegroundColor: Colors.white,
                    buttonUnselectedForegroundColor: Colors.white,
                    buttonUnselectedBackgroundColor: MediaQuery.of(context).orientation == Orientation.landscape ? Colors.grey : Colors.blue,
                    buttonSelectedBackgroundColor: Colors.blue,
                  ),
                ),
              );
            } else {
              int studentIndex = offset + index - 2;
              StudentFeeTransactionBean e = filteredList[studentIndex];
              return AdminFeeReceiptsEachReceiptWidget(
                studentFeeTransactionBean: e,
                adminProfile: widget.adminProfile,
                scaffoldKey: _scaffoldKey,
                reasonToDeleteTextController: reasonToDeleteTextController,
                studentId: e.studentId,
                rollNumber:
                    "${filteredStudentFeeDetailsBeanList.where((eachStudent) => eachStudent.studentId == e.studentId).firstOrNull?.rollNumber}",
                studentName: e.studentName ?? " ",
                sectionName: e.sectionName ?? studentFeeDetailsBeans.where((e1) => e.studentId == e1.studentId).firstOrNull?.sectionName ?? "",
                isTermWise: _isTermWise,
                childTransactions: (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) => e.feeTypeId != null).toList(),
                busFeeTransactions: (e.studentFeeChildTransactionList ?? []).map((e) => e!).where((e) => e.feeTypeId == null).toList(),
                superSetState: stateUpdate,
              );
            }
          },
        ),
        if (isSearchBarSelected)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 75,
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: Container(
                color: clayContainerColor(context),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: SearchWidget(
                  isSearchBarSelectedByDefault: true,
                  onComplete: scrollToReceiptNumber,
                  receiptNumbers: (filteredStudentFeeDetailsBeanList
                          .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
                          .expand((i) => i)
                          .toList()
                        ..sort(
                          (b, a) =>
                              convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) == 0
                                  ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                                      ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                                      : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
                                  : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
                        ))
                      .map((e) => (e.receiptId ?? "-").toString())
                      .toList(),
                  isSearchButtonSelected: isSearchButtonSelected,
                ),
              ),
            ),
          ),
        if (isFilterPressed)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.25
                  : MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * 0.35,
              color: clayContainerColor(context),
              child: ListView(
                children: [
                  feeTypeFilter(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void isSearchButtonSelected(bool isSelected) {
    setState(() {
      isSearchBarSelected = isSelected;
      if (isSelected) {
        isFilterPressed = false;
      }
    });
  }

  void stateUpdate() => setState(() {});

  Column buildNewReceiptWidget(BuildContext context) {
    return Column(
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
                        NewReceipt(
                          context: _scaffoldKey.currentContext!,
                          notifyParent: setState,
                          receiptNumber: newReceipts.where((e) => e.status != "deleted").map((e) => e.receiptNumber ?? 0).toList().reduce(max) + 1,
                          selectedDate: newReceipts.where((e) => e.status != "deleted").firstOrNull?.selectedDate ?? DateTime.now(),
                          sectionsList: sectionsList,
                          studentProfiles: studentProfiles,
                          studentFeeDetails: studentFeeDetailsBeans,
                          studentTermWiseFeeBeans: studentTermWiseFeeBeans,
                          studentAnnualFeeBeanBeans: studentAnnualFeeBeanBeans,
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
    );
  }

  PdfPreview buildPdfPreviewWidget() {
    return PdfPreview(
      build: (format) => pdfInBytes!,
      pdfFileName: "Fee Receipts",
    );
  }

  Column buildRenderingReceiptsWidget() {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: Center(
            child: Text("Generating PDF"),
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
            child: Text(_renderingReceiptText!),
          ),
        ),
        Expanded(
          child: Center(
            child: LinearPercentIndicator(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              alignment: MainAxisAlignment.center,
              width: 140.0,
              lineHeight: 14.0,
              percent: _loadingReceiptPercentage,
              center: Text(
                "${_loadingReceiptPercentage.toStringAsFixed(2)} %",
                style: const TextStyle(fontSize: 12.0),
              ),
              leading: const Icon(Icons.file_upload),
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
          ),
        )
      ],
    );
  }

  Widget newReceiptWidget() {
    return ListView(
      children: [
        ...newReceipts.where((e) => e.status == "active").map((e) => e.widget()).toList(),
      ],
    );
  }

  Future<void> goToDateAction() async {
    if (filteredStudentFeeDetailsBeanList
        .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
        .expand((i) => i)
        .isEmpty) return;
    Set<DateTime> transactionDatesSet = filteredStudentFeeDetailsBeanList
        .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
        .expand((i) => i)
        .toList()
        .sorted(
          (b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) == 0
              ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                  ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                  : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
              : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
        )
        .map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate))
        .toSet();
    DateTime? _newDate = await showDatePicker(
      context: context,
      initialDate: transactionDatesSet.firstOrNull ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: "Select a date",
      initialEntryMode: DatePickerEntryMode.calendar,
      selectableDayPredicate: (DateTime? eachDate) {
        return transactionDatesSet.contains(eachDate);
      },
    );
    if (_newDate == null) return;
    int newIndex = filteredStudentFeeDetailsBeanList
        .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
        .expand((i) => i)
        .toList()
        .sorted(
          (b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) == 0
              ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                  ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                  : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
              : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
        )
        .indexWhere((e) => convertDateTimeToYYYYMMDDFormat(_newDate) == e.transactionDate);
    setState(() {
      offset = (newIndex / limit).floor() * limit;
    });
    _itemScrollController.scrollTo(
      index: newIndex - offset + 2,
      duration: const Duration(milliseconds: 1),
      curve: Curves.linear,
    );
    paginationController.navigateToPage((offset / limit).floor());
  }

  Widget perPageTransactionsWidget() {
    return ClayContainer(
      color: clayContainerColor(context),
      borderRadius: 10,
      spread: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 10),
            const Expanded(child: Text("No. of receipts per page")),
            const SizedBox(width: 10),
            DropdownButton<String>(
              isExpanded: false,
              value: limit == -1 ? "All" : limit.toString(),
              items: [
                (filteredStudentFeeDetailsBeanList
                        .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
                        .expand((i) => i)
                        .toList())
                    .length,
                5,
                10,
                20,
                50,
                100,
                200
              ]
                  .map((e) => DropdownMenuItem<String>(
                        child: Text(e == -1 ||
                                e ==
                                    (filteredStudentFeeDetailsBeanList
                                            .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
                                            .expand((i) => i)
                                            .toList())
                                        .length
                            ? "All"
                            : "$e"),
                        value: "$e",
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                if (newValue == "-1") {
                  setState(() {
                    offset = 0;
                    limit = (filteredStudentFeeDetailsBeanList
                            .map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!))
                            .expand((i) => i)
                            .toList())
                        .length;
                  });
                } else {
                  setState(() {
                    limit = int.tryParse(newValue) ?? limit;
                    offset = (offset / limit).floor();
                  });
                }
              },
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
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
    );
  }

  Widget feeTypeWidget(FeeType feeType) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
