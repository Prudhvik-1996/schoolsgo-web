import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/new_receipt_widget.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/fee_support_classes.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminStudentWiseFeeReceiptsScreen extends StatefulWidget {
  const AdminStudentWiseFeeReceiptsScreen({Key? key, required this.adminProfile, required this.studentAnnualFeeBean}) : super(key: key);

  final AdminProfile adminProfile;
  final StudentAnnualFeeBean studentAnnualFeeBean;

  @override
  State<AdminStudentWiseFeeReceiptsScreen> createState() => _AdminStudentWiseFeeReceiptsScreenState();
}

class _AdminStudentWiseFeeReceiptsScreenState extends State<AdminStudentWiseFeeReceiptsScreen> {
  bool _isLoading = true;
  bool _isTermWise = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late SchoolInfoBean schoolInfoBean;

  List<StudentProfile> studentProfiles = [];
  List<FeeType> feeTypes = [];
  List<StudentFeeDetailsBean> studentFeeDetailsBeans = [];
  List<StudentAnnualFeeSupportBean> studentAnnualFeeBeanBeans = [];
  List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans = [];
  List<StudentMasterTransactionSupportBean> studentMasterTransactionBeans = [];
  List<StudentWiseFeePaidSupportBean> studentWiseFeePaidBeans = [];
  List<StudentBusFeeLogBean> busFeeBeans = [];

  bool _isAddNew = false;
  List<NewReceipt> newReceipts = [];
  late int latestReceiptNumberToBeAdded;
  TextEditingController reasonToDeleteTextController = TextEditingController();
  Uint8List? pdfInBytes;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
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
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile.schoolId,
      studentId: widget.studentAnnualFeeBean.studentId,
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
      studentIds: [widget.studentAnnualFeeBean.studentId],
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
    newReceipts.add(
      NewReceipt(
        context: _scaffoldKey.currentContext!,
        notifyParent: setState,
        receiptNumber: latestReceiptNumberToBeAdded,
        selectedDate: convertYYYYMMDDFormatToDateTime(
            (getStudentFeeDetailsSupportClassesResponse.studentMasterTransactionBeans ?? []).reversed.firstOrNull?.transactionTime),
        sectionsList: [
          Section(
            sectionId: widget.studentAnnualFeeBean.sectionId,
            sectionName: widget.studentAnnualFeeBean.sectionName,
            schoolId: widget.adminProfile.schoolId,
          )
        ],
        studentProfiles: studentProfiles,
        studentFeeDetails: studentFeeDetailsBeans.map((e) => StudentFeeDetailsBean.fromJson(e.toJson())).toList(),
        studentTermWiseFeeBeans: studentTermWiseFeeBeans,
        studentAnnualFeeBeanBeans: studentAnnualFeeBeanBeans,
        feeTypes: feeTypes,
        totalBusFee: null,
        busFeePaid: null,
        busFeeBeans: busFeeBeans,
      )
        ..selectedStudent = studentProfiles[0]
        ..selectedSection = Section(
          sectionId: widget.studentAnnualFeeBean.sectionId,
          sectionName: widget.studentAnnualFeeBean.sectionName,
          schoolId: widget.adminProfile.schoolId,
        )
        ..updatedSelectedStudent(studentProfiles[0], setState),
    );
    setState(() {
      _isLoading = false;
    });
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
                  termComponents: [],
                );
              }).toList();
            }));
    for (var eachStudentFeeDetails in studentFeeDetailsBeans) {
      busFeeBeans.where((eachBusFee) => eachBusFee.studentId == eachStudentFeeDetails.studentId).forEach((eachBusFee) {
        eachStudentFeeDetails.busFee = eachBusFee.fare;
      });
    }
    populateTermTxnWiseComponents();
    return studentFeeDetailsBeans;
  }

  void populateTermTxnWiseComponents() {
    for (StudentFeeDetailsBean eachStudentFeeDetailsBean in studentFeeDetailsBeans) {
      List<StudentTermWiseFeeSupportBean> studentWiseTermFeeTypes = (studentTermWiseFeeBeans)
          .where((e) => e.studentId == eachStudentFeeDetailsBean.studentId)
          .map((e) => StudentTermWiseFeeSupportBean.fromJson(e.origJson()))
          .toList();
      studentWiseTermFeeTypes.sort((a, b) => (a.termId ?? 0).compareTo((b.termId ?? 0)));
      (eachStudentFeeDetailsBean.studentFeeTransactionList ?? []).forEach((StudentFeeTransactionBean? eachStudentFeeTransactionBean) {
        (eachStudentFeeTransactionBean?.studentFeeChildTransactionList ?? []).forEach((StudentFeeChildTransactionBean? eachChildTxn) {
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

  Widget buildStudentWiseAnnualFeeMapCard() {
    List<Widget> rows = [];
    rows.add(
      Row(
        children: [
          Expanded(
            child: Text(
              "${widget.studentAnnualFeeBean.rollNumber ?? "-"}. ${widget.studentAnnualFeeBean.studentName}",
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
    rows.add(
      const SizedBox(
        height: 15,
      ),
    );
    List<Widget> feeStats = [];
    for (StudentAnnualFeeTypeBean eachStudentAnnualFeeTypeBean in (widget.studentAnnualFeeBean.studentAnnualFeeTypeBeans ?? [])) {
      feeStats.add(
        Row(
          children: [
            Expanded(
              child: Text(eachStudentAnnualFeeTypeBean.feeType ?? "-"),
            ),
            eachStudentAnnualFeeTypeBean.amount == null
                ? Container()
                : eachStudentAnnualFeeTypeBean.amount == null || eachStudentAnnualFeeTypeBean.amount == 0
                    ? Container()
                    : Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(eachStudentAnnualFeeTypeBean.amount! / 100)}"),
          ],
        ),
      );
      feeStats.add(
        const SizedBox(
          height: 15,
        ),
      );
      for (StudentAnnualCustomFeeTypeBean eachStudentAnnualCustomFeeTypeBean
          in (eachStudentAnnualFeeTypeBean.studentAnnualCustomFeeTypeBeans ?? [])) {
        feeStats.add(
          Row(
            children: [
              const CustomVerticalDivider(),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(eachStudentAnnualCustomFeeTypeBean.customFeeType ?? "-"),
              ),
              eachStudentAnnualCustomFeeTypeBean.amount == null
                  ? Container()
                  : eachStudentAnnualCustomFeeTypeBean.amount == null || eachStudentAnnualCustomFeeTypeBean.amount == 0
                      ? Container()
                      : Text("$INR_SYMBOL ${doubleToStringAsFixedForINR(eachStudentAnnualCustomFeeTypeBean.amount! / 100)}"),
            ],
          ),
        );
        feeStats.add(
          const SizedBox(
            height: 15,
          ),
        );
      }
    }

    if (widget.studentAnnualFeeBean.studentBusFeeBean != null && (widget.studentAnnualFeeBean.studentBusFeeBean?.fare ?? 0) != 0) {
      feeStats.add(Row(
        children: [
          const Expanded(child: Text("Bus Fee")),
          const SizedBox(
            width: 10,
          ),
          Text(
            widget.studentAnnualFeeBean.studentBusFeeBean?.fare == null
                ? "-"
                : INR_SYMBOL + " " + doubleToStringAsFixedForINR(widget.studentAnnualFeeBean.studentBusFeeBean!.fare! / 100),
          ),
        ],
      ));
      feeStats.add(
        const SizedBox(
          height: 15,
        ),
      );
    }

    feeStats.add(
      const Divider(
        thickness: 1,
      ),
    );

    feeStats.add(
      const SizedBox(
        height: 7.5,
      ),
    );

    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text("Total:"),
          ),
          Text(
            widget.studentAnnualFeeBean.totalFee == null
                ? "-"
                : "$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.studentAnnualFeeBean.totalFee ?? 0) / 100)}",
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text("Total Fee Paid:"),
          ),
          Text(
            widget.studentAnnualFeeBean.totalFeePaid == null
                ? "-"
                : "$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.studentAnnualFeeBean.totalFeePaid ?? 0) / 100)}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
    // feeStats.add(
    //   Row(
    //     children: [
    //       const Expanded(
    //         child: Text(
    //           "Wallet Balance:",
    //         ),
    //       ),
    //       Text(
    //         "$INR_SYMBOL ${((studentWiseAnnualFeesBean.walletBalance ?? 0) / 100).toStringAsFixed(2)}",
    //         textAlign: TextAlign.end,
    //         style: const TextStyle(
    //           color: Colors.blue,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text(
              "Fee to be paid:",
            ),
          ),
          Text(
            "$INR_SYMBOL ${doubleToStringAsFixedForINR(((widget.studentAnnualFeeBean.totalFee ?? 0) - (widget.studentAnnualFeeBean.totalFeePaid ?? 0) - (widget.studentAnnualFeeBean.walletBalance ?? 0)) / 100)}",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: ((widget.studentAnnualFeeBean.totalFee ?? 0) -
                          (widget.studentAnnualFeeBean.totalFeePaid ?? 0) -
                          (widget.studentAnnualFeeBean.walletBalance ?? 0)) ==
                      0
                  ? null
                  : const Color(0xffff5733),
            ),
          ),
        ],
      ),
    );

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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: rows +
                [
                  Container(
                    margin: const EdgeInsets.all(4),
                    child: ClayContainer(
                      surfaceColor: clayContainerColor(context),
                      parentColor: clayContainerColor(context),
                      spread: 1,
                      borderRadius: 10,
                      depth: 40,
                      emboss: true,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: feeStats,
                        ),
                      ),
                    ),
                  ),
                ],
          ),
        ),
      ),
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
                          "${studentFeeDetailsBeans.where((eachStudent) => eachStudent.studentId == e.studentId).firstOrNull?.rollNumber}. ${e.studentName ?? " "}",
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
          Container(
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(eachFeeTypeTxn.feeType ?? "-"),
                ),
                !_isTermWise || (eachFeeTypeTxn.termComponents).isEmpty
                    ? Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-")
                    : const Text(""),
              ],
            ),
          ),
        );
        if (_isTermWise && (eachFeeTypeTxn.termComponents).isNotEmpty) {
          for (TermComponent eachTermComponent in eachFeeTypeTxn.termComponents) {
            childTxnWidgets.add(
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const CustomVerticalDivider(color: Colors.amber),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(eachTermComponent.termName ?? "-"),
                    ),
                    Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.feePaid ?? 0) / 100.0)} /-")
                  ],
                ),
              ),
            );
          }
        }
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
                !_isTermWise || (eachCustomFeeTypeTxn.termComponents).isEmpty
                    ? Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-")
                    : const Text(""),
              ],
            ),
          ));
          if (_isTermWise && (eachCustomFeeTypeTxn.termComponents).isNotEmpty) {
            for (TermComponent eachTermComponent in eachCustomFeeTypeTxn.termComponents) {
              childTxnWidgets.add(
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      const CustomVerticalDivider(color: Colors.amber),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(eachTermComponent.termName ?? "-"),
                      ),
                      Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.feePaid ?? 0) / 100.0)} /-")
                    ],
                  ),
                ),
              );
            }
          }
          childTxnWidgets.add(const SizedBox(
            height: 5,
          ));
        }
      }
    }

    return childTxnWidgets;
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
      _isLoading = true;
    });
    final pdf = pw.Document();
    final schoolNameFont = await PdfGoogleFonts.acmeRegular();
    final font = await PdfGoogleFonts.merriweatherRegular();

    // pw.ImageProvider logoImageProvider;
    //
    // try {
    //   logoImageProvider = await networkImage(
    //     schoolInfoBean.logoPictureUrl! ?? "https://storage.googleapis.com/storage-schools-go/Episilon%20infinity.jpg",
    //   );
    // } catch (e) {
    //   logoImageProvider = pw.MemoryImage(
    //     (await rootBundle.load('images/EISlogo.png')).buffer.asUint8List(),
    //   );
    // }

    (studentFeeDetailsBeans.map((e) => (e.studentFeeTransactionList ?? []).where((e) => e != null).map((e) => e!)).expand((i) => i).toList()
          ..sort(
            (b, a) => convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)) == 0
                ? (a.receiptId ?? 0) == 0 || (b.receiptId ?? 0) == 0 || (a.receiptId ?? 0).compareTo(b.receiptId ?? 0) == 0
                    ? (a.masterTransactionId ?? 0).compareTo((b.masterTransactionId ?? 0))
                    : (a.receiptId ?? 0).compareTo(b.receiptId ?? 0)
                : convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate)),
          ))
        .forEach((eachTransaction) {
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
    });

    var x = await pdf.save();
    setState(() {
      pdfInBytes = x;
    });

    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    // html.AnchorElement anchorElement = html.AnchorElement(href: url);
    // anchorElement.download = "fileName.pdf";
    // anchorElement.click();
    setState(() {
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

  ClayContainer termWiseFilter() {
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
            FlutterSwitch(
              value: _isTermWise,
              onToggle: (bool value) {
                setState(() {
                  _isTermWise = !_isTermWise;
                });
              },
              activeText: "",
              inactiveText: "",
              showOnOff: true,
              width: 30,
              height: 15,
              toggleSize: 15,
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text("Term Wise")),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Student Fee Receipts"),
        ),
        drawer: AdminAppDrawer(
          adminProfile: widget.adminProfile,
        ),
        body: Center(
          child: Image.asset(
            'assets/images/eis_loader.gif',
            height: 500,
            width: 500,
          ),
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Student Fee Management"),
        actions: _isLoading
            ? []
            : [
                pdfInBytes == null
                    ? IconButton(
                        onPressed: () {
                          makePdf();
                        },
                        icon: const Icon(Icons.print),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            pdfInBytes = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
              ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: pdfInBytes != null
          ? PdfPreview(
              build: (format) => pdfInBytes!,
              pdfFileName: "Fee Receipts [${widget.studentAnnualFeeBean.studentName} - ${widget.studentAnnualFeeBean.sectionName}]",
            )
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
                                  newReceipts.add(
                                    NewReceipt(
                                      context: _scaffoldKey.currentContext!,
                                      notifyParent: setState,
                                      receiptNumber: newReceipts.isEmpty
                                          ? studentMasterTransactionBeans.isEmpty
                                              ? 1
                                              : studentMasterTransactionBeans[studentMasterTransactionBeans.length - 1].receiptId
                                          : (newReceipts[newReceipts.length - 1].receiptNumber ?? 0) + 1,
                                      // newReceipts.where((e) => e.status != "deleted").map((e) => e.receiptNumber ?? 0).toList().reduce(max) + 1,
                                      selectedDate: newReceipts.isEmpty
                                          ? studentMasterTransactionBeans.isEmpty
                                              ? DateTime.now()
                                              : convertYYYYMMDDFormatToDateTime(
                                                  studentMasterTransactionBeans[studentMasterTransactionBeans.length - 1].transactionTime)
                                          : (newReceipts[newReceipts.length - 1].selectedDate),
                                      sectionsList: [
                                        Section(
                                          sectionId: widget.studentAnnualFeeBean.sectionId,
                                          sectionName: widget.studentAnnualFeeBean.sectionName,
                                          schoolId: widget.adminProfile.schoolId,
                                        )
                                      ],
                                      studentProfiles: studentProfiles,
                                      studentFeeDetails: studentFeeDetailsBeans,
                                      studentTermWiseFeeBeans: studentTermWiseFeeBeans,
                                      studentAnnualFeeBeanBeans: studentAnnualFeeBeanBeans,
                                      feeTypes: feeTypes,
                                      totalBusFee: null,
                                      busFeePaid: null,
                                      busFeeBeans: busFeeBeans,
                                    )
                                      ..selectedStudent = studentProfiles[0]
                                      ..selectedSection = Section(
                                        sectionId: widget.studentAnnualFeeBean.sectionId,
                                        sectionName: widget.studentAnnualFeeBean.sectionName,
                                        schoolId: widget.adminProfile.schoolId,
                                      )
                                      ..updatedSelectedStudent(studentProfiles[0], setState),
                                  );
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
                    buildStudentWiseAnnualFeeMapCard(),
                    Container(
                      margin: MediaQuery.of(context).orientation == Orientation.landscape
                          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
                          : const EdgeInsets.all(10),
                      child: termWiseFilter(),
                    ),
                    ...(studentFeeDetailsBeans
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
                        .map((e) => studentFeeTransactionWidget(e))
                        .toList(),
                  ],
                ),
      floatingActionButton: _isLoading || _isAddNew || pdfInBytes != null
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
        ...newReceipts.reversed.where((e) => e.status == "active").map((e) => e.widget()).toList(),
      ],
    );
  }
}
