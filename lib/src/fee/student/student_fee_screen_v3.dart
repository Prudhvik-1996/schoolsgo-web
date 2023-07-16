// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/basic_fee_stats_widget.dart';
import 'package:schoolsgo_web/src/fee/admin/new_student_fee_receipt_widget.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/print_utils.dart';

class StudentFeeScreenV3 extends StatefulWidget {
  const StudentFeeScreenV3({
    Key? key,
    required this.studentProfile,
    required this.adminProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final AdminProfile? adminProfile;

  @override
  State<StudentFeeScreenV3> createState() => _StudentFeeScreenV3State();
}

class _StudentFeeScreenV3State extends State<StudentFeeScreenV3> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<StudentAnnualFeeBean> studentAnnualFeeBeans = [];
  List<FeeType> feeTypes = [];
  List<StudentFeeReceipt> studentFeeReceipts = [];

  bool isAddNew = false;
  ScrollController newReceiptsListViewController = ScrollController();
  List<NewReceipt> newReceipts = [];

  SchoolInfoBean? schoolInfoBean;
  List<Section> sections = [];

  bool isTermWise = false;

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
    GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
      schoolId: widget.studentProfile.schoolId,
      studentIds: [widget.studentProfile.studentId],
    ));
    if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        studentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList();
        studentFeeReceipts.sort((b, a) {
          int dateCom = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
          return (dateCom == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateCom;
        });
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
        studentAnnualFeeBeans = [];
        for (StudentWiseAnnualFeesBean eachAnnualFeeBean in getStudentWiseAnnualFeesResponse.studentWiseAnnualFeesBeanList!.map((e) => e!).toList()) {
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
                    discount: (eachAnnualFeeBean.studentAnnualFeeMapBeanList ?? [])
                        .map((e) => e!)
                        .where((StudentAnnualFeeMapBean eachStudentAnnualFeeMapBean) =>
                            eachStudentAnnualFeeMapBean.feeTypeId == eachFeeType.feeTypeId && eachStudentAnnualFeeMapBean.customFeeTypeId == null)
                        .firstOrNull
                        ?.discount,
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
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getDataReadyToPrint() async {
    setState(() {
      _isLoading = true;
    });
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId,
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
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
    ));
    if (getSectionsResponse.httpStatus != "OK" || getSectionsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      sections = (getSectionsResponse.sections ?? []).where((e) => e != null).map((e) => e!).toList();
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

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> makePdf({int? transactionId}) async {
    bool isAdminCopySelected = true;
    bool isStudentCopySelected = transactionId != null;
    bool proceedPrint = true;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text('Download receipts'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text("Admin Copy"),
                    selected: isAdminCopySelected,
                    value: isAdminCopySelected,
                    onChanged: (bool value) {
                      setState(() => isAdminCopySelected = value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Student Copy"),
                    selected: isStudentCopySelected,
                    value: isStudentCopySelected,
                    onChanged: (bool value) {
                      setState(() => isStudentCopySelected = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Proceed to print"),
              onPressed: () async {
                if (!isAdminCopySelected && !isStudentCopySelected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("At least one in Admin Copy or Student Copy must be selected"),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                setState(() => proceedPrint = false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    if (!proceedPrint) return;

    if (schoolInfoBean == null) await getDataReadyToPrint();
    if (schoolInfoBean == null) return;

    List<StudentFeeReceipt> receiptsToPrint = studentFeeReceipts.where((e) => transactionId == null || e.transactionId == transactionId).toList();
    await printReceipts(
      context,
      schoolInfoBean!,
      receiptsToPrint,
      [widget.studentProfile],
      isTermWise,
      isAdminCopySelected: isAdminCopySelected,
      isStudentCopySelected: isStudentCopySelected,
    );
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

  List<pw.TableRow> childTransactionsPdfWidgets(StudentFeeReceipt receipt, pw.Font font) {
    // return (e.studentFeeChildTransactionList ?? []).map((e) => Container()).toList();
    List<pw.TableRow> childTxnWidgets = [];
    (receipt.feeTypes ?? []).where((e) => e != null).map((e) => e!).forEach((eachFeeType) {
      if ((eachFeeType.customFeeTypes ?? []).isEmpty) {
        childTxnWidgets.add(
          pw.TableRow(
            children: [
              pw.Expanded(
                child: paddedText(eachFeeType.feeType ?? "-", font),
              ),
              !isTermWise || (eachFeeType.termWiseFeeComponents ?? []).isEmpty
                  ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeType.amountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                  : paddedText("", font),
            ],
          ),
        );
        if (isTermWise && (eachFeeType.termWiseFeeComponents ?? []).isNotEmpty) {
          for (TermWiseFeeComponent eachTermComponent in (eachFeeType.termWiseFeeComponents ?? []).where((e) => e != null).map((e) => e!)) {
            childTxnWidgets.add(
              pw.TableRow(
                children: [
                  pw.Expanded(
                    child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                  ),
                  paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.termWiseAmountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                      align: pw.TextAlign.right)
                ],
              ),
            );
          }
        }
      } else {
        childTxnWidgets.add(
          pw.TableRow(
            children: [
              pw.Expanded(
                child: paddedText(eachFeeType.feeType ?? "-", font),
              ),
            ],
          ),
        );
        (eachFeeType.customFeeTypes ?? []).where((e) => e != null).map((e) => e!).forEach((eachCustomFeeType) {
          // eachCustomFeeType
          childTxnWidgets.add(
            pw.TableRow(
              children: [
                pw.Expanded(
                  child: paddedText(eachCustomFeeType.customFeeType ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(8, 6, 6, 6)),
                ),
                !isTermWise || (eachCustomFeeType.termWiseFeeComponents ?? []).isEmpty
                    ? paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeType.amountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                        align: pw.TextAlign.right)
                    : paddedText("", font),
              ],
            ),
          );
          if (isTermWise && (eachCustomFeeType.termWiseFeeComponents ?? []).isNotEmpty) {
            for (TermWiseFeeComponent eachTermComponent in (eachCustomFeeType.termWiseFeeComponents ?? []).where((e) => e != null).map((e) => e!)) {
              childTxnWidgets.add(
                pw.TableRow(
                  children: [
                    pw.Expanded(
                      child: paddedText(eachTermComponent.termName ?? "-", font, padding: const pw.EdgeInsets.fromLTRB(12, 6, 6, 6)),
                    ),
                    paddedText(
                        "$INR_SYMBOL ${doubleToStringAsFixedForINR((eachTermComponent.termWiseAmountPaidForTheReceipt ?? 0) / 100.0)} /-", font,
                        align: pw.TextAlign.right)
                  ],
                ),
              );
            }
          }
        });
      }
    });

    if ((receipt.busFeePaid ?? 0) != 0) {
      childTxnWidgets.add(
        pw.TableRow(
          children: [
            pw.Expanded(
              child: paddedText("Bus Fee", font),
            ),
            paddedText("$INR_SYMBOL ${doubleToStringAsFixedForINR((receipt.busFeePaid ?? 0) / 100.0)} /-", font, align: pw.TextAlign.right),
          ],
        ),
      );
    }

    return childTxnWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : isAddNew
              ? ListView(
                  controller: newReceiptsListViewController,
                  children: [
                    ...newReceipts.where((e) => e.status != "deleted").toList().reversed.map(
                          (e) => NewStudentFeeReceiptWidget(
                            context: _scaffoldKey.currentContext!,
                            setState: setState,
                            feeTypesForSelectedSection: feeTypes,
                            newReceipt: e,
                            schoolInfoBean: schoolInfoBean!,
                            sections: sections,
                            studentProfiles: [widget.studentProfile],
                          ),
                        ),
                    SizedBox(height: MediaQuery.of(context).size.height / 2),
                  ],
                )
              : ListView(
                  children: <Widget>[
                    ...studentAnnualFeeBeans
                        .map((e) => BasicFeeStatsReadWidget(
                              studentWiseAnnualFeesBean: e,
                              context: context,
                              alignMargin: true,
                            ))
                        .toList(),
                    ...studentFeeReceipts.map((e) => e.widget(
                          _scaffoldKey.currentContext ?? context,
                          adminId: widget.adminProfile?.userId,
                          isTermWise: isTermWise,
                          setState: setState,
                          reload: _loadData,
                          makePdf: e.isEditMode
                              ? null
                              : (int? transactionId) async {
                                  makePdf(transactionId: transactionId);
                                },
                        )),
                  ],
                ),
      floatingActionButton: _isLoading || widget.adminProfile == null
          ? null
          : (isAddNew && (newReceipts.isEmpty || newReceipts.map((e) => e.status).contains("inactive")))
              ? buildCloseAddNewReceiptButton(context)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAddNew && newReceipts.map((e) => e.status).contains("active") && !newReceipts.map((e) => e.status).contains("inactive"))
                      buildSubmitReceiptsButton(context),
                    const SizedBox(height: 20),
                    if (isAddNew) buildCloseAddNewReceiptButton(context),
                    const SizedBox(height: 20),
                    buildAddNewReceiptButton(context),
                  ],
                ),
    );
  }

  Widget buildCloseAddNewReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isAddNew = false),
      child: ClayButton(
        surfaceColor: Colors.red[300],
        parentColor: clayContainerColor(context),
        borderRadius: 20,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.close),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    String? errorText;
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
        .where((e) => e.status == "active")
        .map((eachNewReceipt) => NewReceiptBean(
              agentId: widget.adminProfile?.userId,
              date: eachNewReceipt.date,
              receiptNumber: eachNewReceipt.receiptNumber,
              schoolId: eachNewReceipt.schoolId,
              sectionId: eachNewReceipt.sectionId,
              studentId: eachNewReceipt.studentId,
              subBeans: (eachNewReceipt.subBeans ?? [])
                  .where((e) => e != null)
                  .map((e) => e!)
                  .map((eachSubBean) => NewReceiptBeanSubBean(
                        customFeeTypeId: eachSubBean.customFeeTypeId,
                        feePaying: eachSubBean.feePaying,
                        feeTypeId: eachSubBean.feeTypeId,
                      ))
                  .toList(),
              busFeePaidAmount: eachNewReceipt.busFeePaidAmount,
              modeOfPayment: eachNewReceipt.modeOfPayment,
            ))
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
    setState(() => isAddNew = false);
    setState(() => _isLoading = false);
  }

  Widget buildSubmitReceiptsButton(BuildContext context) {
    return GestureDetector(
      onTap: _saveChanges,
      child: ClayButton(
        surfaceColor: Colors.green[300],
        parentColor: clayContainerColor(context),
        borderRadius: 20,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.check),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addNewReceiptAction() async {
    if (schoolInfoBean == null) await getDataReadyToPrint();
    if (!isAddNew) {
      setState(() => isAddNew = true);
      if (newReceipts.isEmpty) {
        addNewReceiptToPayAction();
      }
    } else if (newReceipts.map((e) => e.status).contains("inactive")) {
      return;
    } else {
      addNewReceiptToPayAction();
    }
  }

  GestureDetector buildAddNewReceiptButton(BuildContext context) {
    return GestureDetector(
      onTap: addNewReceiptAction,
      child: ClayButton(
        surfaceColor: Colors.blue[300],
        parentColor: clayContainerColor(context),
        borderRadius: 20,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.add),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Add new"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addNewReceiptToPayAction() {
    setState(() {
      newReceipts.add(NewReceipt(
        schoolId: widget.studentProfile.schoolId,
        agentId: widget.adminProfile?.userId,
        studentId: widget.studentProfile.studentId,
        sectionId: widget.studentProfile.sectionId,
        date: newReceipts.isEmpty
            ? studentFeeReceipts.isEmpty
                ? DateTime.now().millisecondsSinceEpoch
                : convertYYYYMMDDFormatToDateTime(studentFeeReceipts[0].transactionDate).millisecondsSinceEpoch
            : (newReceipts[newReceipts.length - 1].date ?? DateTime.now().millisecondsSinceEpoch),
        modeOfPayment: ModeOfPayment.CASH.name,
      )
        ..studentAnnualFeeBean = newReceipts.isEmpty ? null : newReceipts[0].studentAnnualFeeBean
        ..feeToBePaidList = newReceipts.isEmpty ? [] : newReceipts[0].feeToBePaidList.map((e) => e.replicateWithZeroFeePaying()).toList());
      newReceipts.last.receiptNumber = getNewReceiptNumber();
      newReceipts.last.receiptNumberController.text = "${newReceipts.last.receiptNumber}";
      newReceiptsListViewController.animateTo(
        newReceiptsListViewController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  int getNewReceiptNumber() {
    if (newReceipts.length > 1) {
      return newReceipts.map((e) => e.receiptNumber ?? 0).max + 1;
    }
    if (studentFeeReceipts.isEmpty) return 1;
    DateTime latestDate =
        studentFeeReceipts.where((e) => e.transactionDate != null).map((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate)).max;
    return studentFeeReceipts.where((e) => convertYYYYMMDDFormatToDateTime(e.transactionDate) == latestDate).map((e) => e.receiptNumber ?? 0).max + 1;
  }
}
