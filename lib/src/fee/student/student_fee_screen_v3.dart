// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/basic_fee_stats_widget.dart';
import 'package:schoolsgo_web/src/fee/admin/new_student_fee_receipt_widget.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

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
  List<NewReceipt> newReceipts = [];

  SchoolInfoBean? schoolInfoBean;
  List<Section> sections = [];

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
                  children: [
                    ...newReceipts.where((e) => e.status != "deleted").map(
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
                    ...studentFeeReceipts.map((e) => e.widget(context, adminId: widget.adminProfile?.userId)),
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
                    if (isAddNew)
                      buildCloseAddNewReceiptButton(context),
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
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.close),
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
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.check),
        ),
      ),
    );
  }

  void addNewReceiptAction() async {
    if (schoolInfoBean == null) await getDataReadyToPrint();
    if (!isAddNew) {
      setState(() => isAddNew = true);
      addNewReceiptToPayAction();
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
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 100,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void addNewReceiptToPayAction() {
    setState(() {
      newReceipts.add(NewReceipt(
        schoolId: widget.studentProfile.schoolId,
        agentId: widget.adminProfile?.userId,
        date: DateTime.now().millisecondsSinceEpoch,
        modeOfPayment: ModeOfPayment.CASH.name,
        studentId: widget.studentProfile.studentId,
        sectionId: widget.studentProfile.sectionId,
      ));
    });
  }
}
