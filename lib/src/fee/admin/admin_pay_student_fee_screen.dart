import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/basic_fee_stats_widget.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/number_to_words.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminPayStudentFeeScreen extends StatefulWidget {
  const AdminPayStudentFeeScreen({
    Key? key,
    required this.adminProfile,
    required this.studentWiseAnnualFeesBean,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final StudentAnnualFeeBean studentWiseAnnualFeesBean;

  @override
  _AdminPayStudentFeeScreenState createState() => _AdminPayStudentFeeScreenState();
}

class _AdminPayStudentFeeScreenState extends State<AdminPayStudentFeeScreen> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StudentWiseTermFeesBean? studentWiseTermFeesBean;

  late StudentProfile studentProfile;

  late _StudentWiseAnnualTransactionHistory studentWiseAnnualTransactionHistory;

  TextEditingController totalFeeNowPayingEditingController = TextEditingController();
  int totalFeeNowPaying = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      studentId: widget.studentWiseAnnualFeesBean.studentId,
      sectionId: widget.studentWiseAnnualFeesBean.sectionId,
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
      schoolId: widget.adminProfile.schoolId,
      sectionId: widget.studentWiseAnnualFeesBean.sectionId,
      studentId: widget.studentWiseAnnualFeesBean.studentId,
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
    await _parseContent();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _parseContent() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      studentWiseAnnualTransactionHistory = _StudentWiseAnnualTransactionHistory(
        sectionId: studentProfile.sectionId,
        sectionName: studentProfile.sectionName,
        studentTermWiseTransactionHistoryBeans: [],
        studentProfile: studentProfile,
      );
      (studentWiseTermFeesBean?.studentTermFeeMapBeanList ?? [])
          .where((e) => e != null)
          .map((e) => e!)
          .forEach((StudentWiseTermFeeMapBean eachStudentWiseTermFeeMapBean) {
        if (studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans!
            .where((e) => e.termId == eachStudentWiseTermFeeMapBean.termId)
            .isEmpty) {
          studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans!.add(
            _StudentTermWiseTransactionHistory(
              termId: eachStudentWiseTermFeeMapBean.termId,
              termName: eachStudentWiseTermFeeMapBean.termName,
              studentTermWiseFeeTypeTransactionHistoryBeans: [],
            ),
          );
        }
      });
      (studentWiseTermFeesBean?.studentTermFeeMapBeanList ?? [])
          .where((e) => e != null)
          .map((e) => e!)
          .forEach((StudentWiseTermFeeMapBean eachStudentWiseTermFeeMapBean) {
        studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans!
            .where((e) => e.termId == eachStudentWiseTermFeeMapBean.termId)
            .forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
          if (eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans!
              .where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId)
              .isEmpty) {
            eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans!.add(
              _StudentTermWiseFeeTypeTransactionHistory(
                feeTypeId: eachStudentWiseTermFeeMapBean.feeTypeId,
                feeType: eachStudentWiseTermFeeMapBean.feeType,
                totalTermFee: eachStudentWiseTermFeeMapBean.termFee,
                totalAnnualFee: eachStudentWiseTermFeeMapBean.amount,
                studentTermWiseCustomFeeTypeTransactionHistory: [],
                transactions: [],
                termId: eachStudentWiseTermFeeMapBean.termId,
              ),
            );
          }
        });
      });
      (studentWiseTermFeesBean?.studentTermFeeMapBeanList ?? [])
          .where((e) => e != null)
          .map((e) => e!)
          .forEach((StudentWiseTermFeeMapBean eachStudentWiseTermFeeMapBean) {
        studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans!
            .where((e) => e.termId == eachStudentWiseTermFeeMapBean.termId)
            .forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
          eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans!
              .where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId && eachStudentWiseTermFeeMapBean.customFeeTypeId != null)
              .forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
            if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                .where((e) => e.customFeeTypeId == eachStudentWiseTermFeeMapBean.customFeeTypeId)
                .isEmpty) {
              eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.add(
                _StudentTermWiseCustomFeeTypeTransactionHistory(
                  transactions: [],
                  feeTypeId: eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId,
                  feeType: eachStudentTermWiseFeeTypeTransactionHistory.feeType,
                  totalTermFee: eachStudentWiseTermFeeMapBean.termFee,
                  totalAnnualFee: eachStudentWiseTermFeeMapBean.amount,
                  customFeeTypeId: eachStudentWiseTermFeeMapBean.customFeeTypeId,
                  customFeeType: eachStudentWiseTermFeeMapBean.customFeeType,
                  termId: eachStudentWiseTermFeeMapBean.termId,
                ),
              );
            }
          });
        });
      });

      (studentWiseTermFeesBean?.studentTermFeeMapBeanList ?? [])
          .map((e) => e!)
          .where((e) => e.transactionId != null)
          .forEach((StudentWiseTermFeeMapBean eachStudentWiseTermFeeMapBean) {
        studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans!
            .where((e) => e.termId == eachStudentWiseTermFeeMapBean.termId)
            .forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
          eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans!
              .where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId)
              .forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
            if (eachStudentWiseTermFeeMapBean.customFeeTypeId == null) {
              eachStudentTermWiseFeeTypeTransactionHistory.transactions!.add(
                _FeeTypeTransaction(
                  feeTypeId: eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId,
                  feeType: eachStudentTermWiseFeeTypeTransactionHistory.feeType,
                  feePaidId: eachStudentWiseTermFeeMapBean.feeTypeId,
                  transactionAmount: eachStudentWiseTermFeeMapBean.feePaid,
                  transactionId: eachStudentWiseTermFeeMapBean.transactionId,
                  masterTransactionId: eachStudentWiseTermFeeMapBean.masterTransactionId,
                  transactionTime: eachStudentWiseTermFeeMapBean.paymentDate,
                  transactionDescription: eachStudentWiseTermFeeMapBean.transactionDescription,
                  kind: eachStudentWiseTermFeeMapBean.transactionKind,
                  modeOfPayment: eachStudentWiseTermFeeMapBean.modeOfPayment,
                  type: eachStudentWiseTermFeeMapBean.transactionType,
                ),
              );
            } else {
              eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                  .where((e) => e.customFeeTypeId == eachStudentWiseTermFeeMapBean.customFeeTypeId)
                  .forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
                eachStudentTermWiseCustomFeeTypeTransactionHistory.transactions!.add(_CustomFeeTypeTransaction(
                  feeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId,
                  feeType: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeType,
                  customFeeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId,
                  customFeeType: eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeType,
                  transactionAmount: eachStudentWiseTermFeeMapBean.feePaid,
                  feePaidId: eachStudentWiseTermFeeMapBean.feeTypeId,
                  transactionId: eachStudentWiseTermFeeMapBean.transactionId,
                  masterTransactionId: eachStudentWiseTermFeeMapBean.masterTransactionId,
                  transactionTime: eachStudentWiseTermFeeMapBean.paymentDate,
                  transactionDescription: eachStudentWiseTermFeeMapBean.transactionDescription,
                  kind: eachStudentWiseTermFeeMapBean.transactionKind,
                  modeOfPayment: eachStudentWiseTermFeeMapBean.modeOfPayment,
                  type: eachStudentWiseTermFeeMapBean.transactionType,
                ));
              });
            }
          });
        });
      });

      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid =
                eachStudentTermWiseFeeTypeTransactionHistory.transactions!.map((e) => e.transactionAmount ?? 0).sum;
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying = (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0);
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPayingController.text =
                "${((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0)) / 100}";
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid =
                  eachStudentTermWiseCustomFeeTypeTransactionHistory.transactions!.map((e) => e.transactionAmount ?? 0).sum;
              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying =
                  (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                      (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0);
              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPayingController.text =
                  "${((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0)) / 100}";
            });
          }
        });
      });

      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.totalTermFee = eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.map((e) => e.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty
                ? (e.totalTermFee ?? 0)
                : e.studentTermWiseCustomFeeTypeTransactionHistory!.map((c) => c.totalTermFee ?? 0).sum)
            .sum;
        eachStudentTermWiseTransactionHistory.totalTermFeePaid = eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.map((e) => e.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty
                ? (e.totalTermFeePaid ?? 0)
                : e.studentTermWiseCustomFeeTypeTransactionHistory!.map((c) => c.totalTermFeePaid ?? 0).sum)
            .sum;
      });

      studentWiseAnnualTransactionHistory.totalFee =
          studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.map((e) => e.totalTermFee ?? 0).sum;
      studentWiseAnnualTransactionHistory.totalFeePaid =
          studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.map((e) => e.totalTermFeePaid ?? 0).sum;

      studentWiseAnnualTransactionHistory.studentWalletTransactionHistoryBeans =
          (studentWiseTermFeesBean?.studentWalletTransactionBeans ?? []).map((e) => e!).toList();

      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            totalFeeNowPaying += (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0);
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              totalFeeNowPaying += (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                  (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0);
            });
          }
        });
      });
      totalFeeNowPayingEditingController.text = "${totalFeeNowPaying / 100}";
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Fee Management"),
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
          : ListView(
              children: [
                Container(
                  margin: MediaQuery.of(context).orientation == Orientation.portrait
                      ? const EdgeInsets.all(8.0)
                      : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 8, MediaQuery.of(context).size.width / 5, 8),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      BasicFeeStatsReadWidget(
                        studentWiseAnnualFeesBean: widget.studentWiseAnnualFeesBean,
                        context: context,
                        alignMargin: false,
                      ),
                      for (_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory
                          in studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans ?? [])
                        Container(
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
                                children: getTermWiseFeePaidBeans(eachStudentTermWiseTransactionHistory),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Row(
                            children: [
                              Expanded(child: totalAmountPayingTextField()),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: MediaQuery.of(context).orientation == Orientation.portrait
                                ? const EdgeInsets.all(8.0)
                                : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 8, MediaQuery.of(context).size.width / 5, 8),
                            child: totalAmountPayingInNumbers(),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 10, 0, MediaQuery.of(context).size.width / 10, 0),
                            child: payFeeButton(),
                          ),
                        ],
                      )
                    : ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                              // const Expanded(
                              //   child: Text(""),
                              // ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(8.0),
                                  child: totalAmountPayingInNumbers(),
                                ),
                              ),
                              totalAmountPayingTextField(),
                              payFeeButton(),
                              // const Expanded(
                              //   child: Text(""),
                              // ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
    );
  }

  Widget totalAmountPayingInNumbers() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: AutoSizeText(
        "* Paying fee: " + ((totalFeeNowPaying ~/ 100) == 1 ? "One Rupee" : convertIntoWords(totalFeeNowPaying ~/ 100).capitalize() + " Rupees"),
        maxLines: 2,
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> getTermWiseFeePaidBeans(_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
    List<Widget> widgets = [];
    widgets.add(
      const SizedBox(
        height: 15,
      ),
    );
    widgets.add(
      Center(
        child: Text(
          eachStudentTermWiseTransactionHistory.termName ?? "-",
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
    widgets.add(
      const SizedBox(
        height: 15,
      ),
    );
    for (_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory
        in eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans ?? []) {
      if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
        widgets.add(
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(eachStudentTermWiseFeeTypeTransactionHistory.feeType ?? "-"),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee == null
                        ? "-"
                        : INR_SYMBOL + " " + (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee! / 100).toString(),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid == null
                        ? "-"
                        : INR_SYMBOL + " " + (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid! / 100).toString(),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: 100,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: eachStudentTermWiseFeeTypeTransactionHistory.feeNowPayingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                            (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                            (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                        0
                                    ? Colors.blue
                                    : Colors.red,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                            (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                            (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                        0
                                    ? Colors.blue
                                    : Colors.red,
                          ),
                        ),
                        label: Text(
                          ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                      (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                      (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                  0
                              ? "Extra: ${-1 * ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) / 100}"
                              : 'Due: $INR_SYMBOL ${(((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) / 100)}',
                          textAlign: TextAlign.end,
                        ),
                        suffix: Text(INR_SYMBOL),
                        labelStyle: TextStyle(
                          color: ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                      (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                      (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                  0
                              ? Colors.green
                              : ((eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                          (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                          (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                      0
                                  ? Colors.blue
                                  : Colors.red,
                        ),
                        hintText: 'Amount',
                        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                      enabled: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            if (double.parse(text) * 100 > (eachStudentTermWiseFeeTypeTransactionHistory.totalAnnualFee ?? 0)) {
                              return oldValue;
                            }
                            if (double.parse(text) * 100 > _maxFeeValue(eachStudentTermWiseFeeTypeTransactionHistory)) {
                              return oldValue;
                            }
                            return newValue;
                          } catch (e) {
                            debugPrint("Invalid value: $e");
                          }
                          return oldValue;
                        }),
                      ],
                      onChanged: (String e) {
                        setState(() {
                          try {
                            int? previous = eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying;
                            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying = e == "" ? 0 : (double.parse(e) * 100).round();
                            totalFeeNowPaying =
                                totalFeeNowPaying - (previous ?? 0) + (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0);
                            totalFeeNowPayingEditingController.text = "${totalFeeNowPaying / 100}";
                          } catch (e) {
                            debugPrint("Invalid value: $e");
                          }
                        });
                      },
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      autofocus: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        widgets.add(
          const SizedBox(
            height: 15,
          ),
        );
      } else {
        widgets.add(
          Row(
            children: [
              Expanded(
                child: Text(eachStudentTermWiseFeeTypeTransactionHistory.feeType ?? "-"),
              ),
            ],
          ),
        );
        widgets.add(
          const SizedBox(
            height: 15,
          ),
        );
        for (_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory
            in eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory ?? []) {
          widgets.add(
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomVerticalDivider(),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeType ?? "-"),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee == null
                          ? "-"
                          : INR_SYMBOL + " " + (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee! / 100).toString(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid == null
                          ? "-"
                          : INR_SYMBOL + " " + (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid! / 100).toString(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 100,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPayingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                      0
                                  ? Colors.green
                                  : ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                              (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                              (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                          0
                                      ? Colors.blue
                                      : Colors.red,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                      0
                                  ? Colors.green
                                  : ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                              (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                              (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                          0
                                      ? Colors.blue
                                      : Colors.red,
                            ),
                          ),
                          label: Text(
                            ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                        (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                        (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                    0
                                ? "Extra: ${-1 * ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) / 100}"
                                : 'Due: $INR_SYMBOL ${(((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) / 100)}',
                            textAlign: TextAlign.end,
                          ),
                          suffix: Text(INR_SYMBOL),
                          labelStyle: TextStyle(
                            color: ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                        (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                        (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                                            (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0) -
                                            (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) <
                                        0
                                    ? Colors.blue
                                    : Colors.red,
                          ),
                          hintText:
                              '${(eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0)}',
                          contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        ),
                        enabled: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              // if (double.parse(text) * 100 > (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalAnnualFee ?? 0)) {
                              //   return oldValue;
                              // }
                              if (double.parse(text) * 100 > _maxCustomFeeValue(eachStudentTermWiseCustomFeeTypeTransactionHistory)) {
                                return oldValue;
                              }
                              return newValue;
                            } catch (e) {
                              debugPrint("Invalid value: $e");
                            }
                            return oldValue;
                          }),
                        ],
                        onChanged: (String e) {
                          setState(() {
                            try {
                              int? previous = eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying;
                              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying = e == "" ? 0 : (double.parse(e) * 100).round();
                              totalFeeNowPaying =
                                  totalFeeNowPaying - (previous ?? 0) + (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0);
                              totalFeeNowPayingEditingController.text = "${totalFeeNowPaying / 100}";
                            } catch (e) {
                              debugPrint("Invalid value: $e");
                            }
                          });
                        },
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        autofocus: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          widgets.add(
            const SizedBox(
              height: 15,
            ),
          );
        }
      }
    }
    int termWiseDue = ((eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans ?? [])
                .map((e) => e.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty
                    ? (e.totalTermFee ?? 0) - (e.totalTermFeePaid ?? 0) - (e.feeNowPaying ?? 0)
                    : e.studentTermWiseCustomFeeTypeTransactionHistory!
                        .map((c) => (c.totalTermFee ?? 0) - (c.totalTermFeePaid ?? 0) - (c.feeNowPaying ?? 0))
                        .sum)
                .sum /
            100)
        .round();
    if (termWiseDue != 0) {
      widgets.add(
        Row(
          children: [
            const Expanded(child: Text("")),
            Text(
              termWiseDue < 0 ? "Paying Extra: $INR_SYMBOL ${-1 * termWiseDue}" : "Due: $INR_SYMBOL $termWiseDue",
              style: TextStyle(color: termWiseDue < 0 ? Colors.blue : Colors.red),
            ),
          ],
        ),
      );
    }
    widgets.add(
      const SizedBox(
        height: 15,
      ),
    );
    return widgets;
  }

  int _maxFeeValue(_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
    return studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
            ?.map((e) => e.studentTermWiseFeeTypeTransactionHistoryBeans)
            .map((e) => e ?? [])
            .expand((i) => i)
            .where((e) => e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId)
            .map((e) {
          if (e.termId == eachStudentTermWiseFeeTypeTransactionHistory.termId) {
            return (e.totalTermFee ?? 0) - (e.totalTermFeePaid ?? 0);
          } else {
            return (e.totalTermFee ?? 0) - (e.totalTermFeePaid ?? 0) - (e.feeNowPaying ?? 0);
          }
        }).sum ??
        0;
  }

  int _maxCustomFeeValue(_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
    return studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
            ?.map((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) =>
                eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
                    ?.map((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) =>
                        eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                            ?.where((e) => e.customFeeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId)
                            .map((_StudentTermWiseCustomFeeTypeTransactionHistory x) {
                          if (x.termId == eachStudentTermWiseCustomFeeTypeTransactionHistory.termId) {
                            return (x.totalTermFee ?? 0) - (x.totalTermFeePaid ?? 0);
                          } else {
                            return (x.totalTermFee ?? 0) - (x.totalTermFeePaid ?? 0) - (x.feeNowPaying ?? 0);
                          }
                        }).sum ??
                        0)
                    .sum ??
                0)
            .sum ??
        0;
  }

  Widget totalAmountPayingTextField() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      width: 100,
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: TextField(
          controller: totalFeeNowPayingEditingController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: Colors.transparent,
              ),
            ),
            label: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(3),
              child: const Text(
                'Total amount',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            prefix: Text(INR_SYMBOL),
            hintText: 'Total Amount Paying',
            contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
            TextInputFormatter.withFunction((oldValue, newValue) {
              try {
                final text = newValue.text;
                if (text.isNotEmpty) {
                  int x = (double.parse(text) * 100).round();
                  if (x > (widget.studentWiseAnnualFeesBean.totalFee ?? 0) - (widget.studentWiseAnnualFeesBean.totalFeePaid ?? 0)) {
                    return oldValue;
                  }
                }
                return newValue;
              } catch (e) {
                debugPrint("Invalid value: $e");
              }
              return oldValue;
            }),
          ],
          onChanged: (String e) {
            setState(() {
              try {
                totalFeeNowPaying = e == "" ? 0 : (double.parse(e) * 100).round();
                modifyAllNowPayingFees();
              } catch (e) {
                debugPrint("Invalid value: $e");
              }
            });
          },
          style: const TextStyle(
            fontSize: 12,
          ),
          autofocus: true,
        ),
      ),
    );
  }

  Container payFeeButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: GestureDetector(
        onTap: () async {
          await _payFeeAction();
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: Colors.green,
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 5,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                "Pay Fee",
                style: TextStyle(
                  color: totalFeeNowPaying == 0 ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _payFeeAction() async {
    List<StudentWiseTermFeeMapBean> feePayingBeans = [];
    studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
        ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
      eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
          ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
        if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying != 0) {
            feePayingBeans.add(StudentWiseTermFeeMapBean(
              sectionId: studentWiseAnnualTransactionHistory.studentProfile?.sectionId,
              studentId: studentWiseAnnualTransactionHistory.studentProfile?.studentId,
              schoolId: studentWiseAnnualTransactionHistory.studentProfile?.schoolId,
              termId: eachStudentTermWiseTransactionHistory.termId,
              feeTypeId: eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId,
              customFeeTypeId: null,
              modeOfPayment: "CASH",
              amount: eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying,
            ));
          }
        } else {
          eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
              ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
            if (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying != 0) {
              feePayingBeans.add(StudentWiseTermFeeMapBean(
                sectionId: studentWiseAnnualTransactionHistory.studentProfile?.sectionId,
                studentId: studentWiseAnnualTransactionHistory.studentProfile?.studentId,
                schoolId: studentWiseAnnualTransactionHistory.studentProfile?.schoolId,
                termId: eachStudentTermWiseTransactionHistory.termId,
                feeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId,
                customFeeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId,
                modeOfPayment: "CASH",
                amount: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying,
              ));
            }
          });
        }
      });
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Student Fee Management'),
          content: const Text("Are you accept payment?"),
          actions: <Widget>[
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                CreateOrUpdateStudentFeePaidRequest createOrUpdateStudentFeePaidRequest = CreateOrUpdateStudentFeePaidRequest(
                  studentId: widget.studentWiseAnnualFeesBean.studentId,
                  schoolId: widget.adminProfile.schoolId,
                  agent: widget.adminProfile.userId,
                  loadWalletAmount: 0,
                  studentTermFeeMapList: feePayingBeans,
                  studentName: widget.studentWiseAnnualFeesBean.studentName,
                  sectionName: widget.studentWiseAnnualFeesBean.sectionName,
                );
                CreateOrUpdateStudentFeePaidResponse createOrUpdateStudentFeePaidResponse =
                    await createOrUpdateStudentFeePaid(createOrUpdateStudentFeePaidRequest);
                setState(() {
                  _isLoading = false;
                });
                if (createOrUpdateStudentFeePaidResponse.httpStatus != "OK" || createOrUpdateStudentFeePaidResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                } else {
                  _loadData();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> modifyAllNowPayingFees() async {
    setState(() {
      _isLoading = true;
    });
    int totalSupportFee = totalFeeNowPaying;
    List<_SupportClassForFee> supports = [];
    setState(() {
      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            supports.add(_SupportClassForFee(
              termId: eachStudentTermWiseFeeTypeTransactionHistory.termId,
              feeTypeId: eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId,
              customFeeTypeId: null,
              totalFeePaid: eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid,
              totalAnnualFee: eachStudentTermWiseFeeTypeTransactionHistory.totalAnnualFee,
              totalTermFee: eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid,
              feePayable: (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0) -
                  (eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0),
            ));
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              supports.add(_SupportClassForFee(
                termId: eachStudentTermWiseCustomFeeTypeTransactionHistory.termId,
                feeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId,
                customFeeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId,
                totalAnnualFee: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalAnnualFee,
                totalTermFee: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee,
                totalFeePaid: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid,
                feePayable: (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0) -
                    (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0),
              ));
            });
          }
        });
      });
      supports.sort((a, b) => (a.feePayable - b.feePayable));

      supports.where((e) => e.feePayable != 0).forEach((e) {
        if (totalSupportFee >= e.feePayable) {
          e.feePayingNow = e.feePayable;
          totalSupportFee -= e.feePayingNow ?? 0;
        }
      });
      if (totalSupportFee > 0) {
        supports.where((e) => e.feePayable != 0).forEach((e) {
          if (e.feePayable > 0 && totalSupportFee > 0 && (e.feePayingNow ?? 0) < e.feePayable && e.feePayable >= totalSupportFee) {
            e.feePayingNow = totalSupportFee;
            totalSupportFee -= e.feePayingNow ?? 0;
          }
        });
      }

      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying = supports
                .where((e) =>
                    e.termId == eachStudentTermWiseFeeTypeTransactionHistory.termId &&
                    e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId &&
                    e.customFeeTypeId == null)
                .firstOrNull
                ?.feePayingNow;
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPayingController.text =
                eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying == null
                    ? ""
                    : "${eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying! / 100}";
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying = supports
                  .where((e) =>
                      e.termId == eachStudentTermWiseCustomFeeTypeTransactionHistory.termId &&
                      e.feeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId &&
                      e.customFeeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId)
                  .firstOrNull
                  ?.feePayingNow;
              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPayingController.text =
                  eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying == null
                      ? ""
                      : "${eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying! / 100}";
            });
          }
        });
      });
    });
    setState(() {
      int totalTermsFees = studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.map((e) => e.totalTermFee ?? 0).sum ?? 0;
      if (totalTermsFees < (widget.studentWiseAnnualFeesBean.totalFee ?? 0) && totalSupportFee > 0) {
        List<_SupportClassForFee> newSupports = [];
        if ((studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans ?? []).isEmpty) return;
        studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.last.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            int totalPrevTermsFeeForFeeType = studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
                    ?.where((e) => e.termId != studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.last.termId)
                    .map((e) => e.studentTermWiseFeeTypeTransactionHistoryBeans ?? [])
                    .expand((i) => i)
                    .where((e) => e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId)
                    .map((e) => e.totalTermFee ?? 0)
                    .sum ??
                0;
            int totalAnnualFeeForFeeType = eachStudentTermWiseFeeTypeTransactionHistory.totalAnnualFee ?? 0;
            // int lastTermFeeForFeeType = eachStudentTermWiseFeeTypeTransactionHistory.totalTermFee ?? 0;
            // int feePayable = lastTermFeeForFeeType;
            int feePaidForLastTerm = eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid ?? 0;
            int feeNowPaying = eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0;
            // if ((totalAnnualFeeForFeeType - totalPrevTermsFeeForFeeType) < totalSupportFee) {
            //   feePayable = (totalSupportFee - (totalAnnualFeeForFeeType - totalPrevTermsFeeForFeeType));
            //   totalSupportFee = totalSupportFee - (totalAnnualFeeForFeeType - totalPrevTermsFeeForFeeType);
            // } else {
            //   feePayable = totalSupportFee;
            //   totalSupportFee -= totalSupportFee;
            // }
            newSupports.add(_SupportClassForFee(
                termId: eachStudentTermWiseFeeTypeTransactionHistory.termId,
                feeTypeId: eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId,
                customFeeTypeId: null,
                totalFeePaid: eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid,
                totalAnnualFee: eachStudentTermWiseFeeTypeTransactionHistory.totalAnnualFee,
                totalTermFee: eachStudentTermWiseFeeTypeTransactionHistory.totalTermFeePaid,
                feePayable: totalAnnualFeeForFeeType - totalPrevTermsFeeForFeeType - feePaidForLastTerm - feeNowPaying
                // +
                // (supports
                //         .where((e) =>
                //             e.termId == eachStudentTermWiseFeeTypeTransactionHistory.termId &&
                //             e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId &&
                //             e.customFeeTypeId == null)
                //         .firstOrNull
                //         ?.feePayingNow ??
                //     0
                // ),
                ));
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              int totalPrevTermsFeeForCustomFeeType = studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
                      ?.where((e) => e.termId != studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.last.termId)
                      .map((e) => e.studentTermWiseFeeTypeTransactionHistoryBeans ?? [])
                      .expand((i) => i)
                      .where((e) => e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId)
                      .map((e) => e.studentTermWiseCustomFeeTypeTransactionHistory ?? [])
                      .expand((i) => i)
                      .where((e) => e.customFeeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId)
                      .map((e) => e.totalTermFee ?? 0)
                      .sum ??
                  0;
              int totalAnnualFeeForCustomFeeType = eachStudentTermWiseCustomFeeTypeTransactionHistory.totalAnnualFee ?? 0;
              // int lastTermFeeForCustomFeeType = eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFee ?? 0;
              int feePaidForLastTerm = eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid ?? 0;
              int feeNowPaying = eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0;
              // int feePayable = lastTermFeeForCustomFeeType;
              // if ((totalAnnualFeeForCustomFeeType - totalPrevTermsFeeForCustomFeeType) < totalSupportFee) {
              //   feePayable = (totalSupportFee - (totalAnnualFeeForCustomFeeType - totalPrevTermsFeeForCustomFeeType));
              //   totalSupportFee = totalSupportFee - (totalAnnualFeeForCustomFeeType - totalPrevTermsFeeForCustomFeeType);
              // } else {
              //   feePayable = totalSupportFee;
              //   totalSupportFee -= totalSupportFee;
              // }
              newSupports.add(_SupportClassForFee(
                  termId: eachStudentTermWiseCustomFeeTypeTransactionHistory.termId,
                  feeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId,
                  customFeeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId,
                  totalFeePaid: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid,
                  totalAnnualFee: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalAnnualFee,
                  totalTermFee: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalTermFeePaid,
                  feePayable: totalAnnualFeeForCustomFeeType - totalPrevTermsFeeForCustomFeeType - feePaidForLastTerm - feeNowPaying
                  // +
                  // (supports
                  //         .where((e) =>
                  //             e.termId == eachStudentTermWiseCustomFeeTypeTransactionHistory.termId &&
                  //             e.feeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId &&
                  //             e.customFeeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId)
                  //         .firstOrNull
                  //         ?.feePayingNow ??
                  //     0
                  // ),
                  ));
            });
          }
        });
        newSupports.sort((a, b) => (a.feePayable - b.feePayable));
        newSupports.where((e) => e.feePayable != 0).forEach((e) {
          if (totalSupportFee >= e.feePayable) {
            int? oldFeePaying = studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
                ?.where((c) => c.termId == e.termId)
                .map((e) => e.studentTermWiseFeeTypeTransactionHistoryBeans ?? [])
                .expand((i) => i)
                .where((c) => c.feeTypeId == e.feeTypeId)
                .map((c) {
              if (c.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty && e.customFeeTypeId == null) {
                return c.feeNowPaying;
              } else {
                return c.studentTermWiseCustomFeeTypeTransactionHistory!
                    .where((d) => d.customFeeTypeId == e.customFeeTypeId)
                    .firstOrNull
                    ?.feeNowPaying;
              }
            }).first;
            e.feePayingNow = (oldFeePaying ?? 0) + e.feePayable;
            totalSupportFee -= (e.feePayingNow ?? 0) - (oldFeePaying ?? 0);
          }
        });
        if (totalSupportFee > 0) {
          newSupports.where((e) => e.feePayable != 0).forEach((e) {
            int? oldFeePaying = studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
                ?.where((c) => c.termId == e.termId)
                .map((e) => e.studentTermWiseFeeTypeTransactionHistoryBeans ?? [])
                .expand((i) => i)
                .where((c) => c.feeTypeId == e.feeTypeId)
                .map((c) {
              if (c.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty && e.customFeeTypeId == null) {
                return c.feeNowPaying;
              } else {
                return c.studentTermWiseCustomFeeTypeTransactionHistory!
                    .where((d) => d.customFeeTypeId == e.customFeeTypeId)
                    .firstOrNull
                    ?.feeNowPaying;
              }
            }).first;
            if (e.feePayable > 0 && totalSupportFee > 0 && (e.feePayingNow ?? 0) < e.feePayable && e.feePayable >= totalSupportFee) {
              e.feePayingNow = (oldFeePaying ?? 0) + totalSupportFee;
              totalSupportFee -= (e.feePayingNow ?? 0) - (oldFeePaying ?? 0);
            }
          });
        }

        studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.last.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            if (newSupports
                    .where((e) =>
                        e.termId == eachStudentTermWiseFeeTypeTransactionHistory.termId &&
                        e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId &&
                        e.customFeeTypeId == null)
                    .firstOrNull
                    ?.feePayingNow !=
                null) {
              eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying = newSupports
                  .where((e) =>
                      e.termId == eachStudentTermWiseFeeTypeTransactionHistory.termId &&
                      e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId &&
                      e.customFeeTypeId == null)
                  .firstOrNull
                  ?.feePayingNow;
            }
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPayingController.text =
                eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying == null
                    ? ""
                    : "${eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying! / 100}";
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              if (newSupports
                      .where((e) =>
                          e.termId == eachStudentTermWiseCustomFeeTypeTransactionHistory.termId &&
                          e.feeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId &&
                          e.customFeeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId)
                      .firstOrNull
                      ?.feePayingNow !=
                  null) {
                eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying = newSupports
                    .where((e) =>
                        e.termId == eachStudentTermWiseCustomFeeTypeTransactionHistory.termId &&
                        e.feeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId &&
                        e.customFeeTypeId == eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId)
                    .firstOrNull
                    ?.feePayingNow;
              }
              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPayingController.text =
                  eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying == null
                      ? ""
                      : "${eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying! / 100}";
            });
          }
        });
      }
    });
    setState(() {
      _isLoading = false;
    });
  }
}

class _StudentWiseAnnualTransactionHistory {
  int? sectionId;
  String? sectionName;
  int? totalFee;
  int? totalFeePaid;

  StudentProfile? studentProfile;
  int? totalWalletBalance;
  TextEditingController totalWalletBalanceEditingController = TextEditingController();

  List<StudentWalletTransactionBean>? studentWalletTransactionHistoryBeans;
  List<_StudentTermWiseTransactionHistory>? studentTermWiseTransactionHistoryBeans;

  _StudentWiseAnnualTransactionHistory({
    this.studentProfile,
    this.sectionId,
    this.sectionName,
    this.totalFee,
    this.totalFeePaid,
    this.studentWalletTransactionHistoryBeans,
    this.studentTermWiseTransactionHistoryBeans,
  }) {
    totalWalletBalance = studentProfile?.balanceAmount;
    totalWalletBalanceEditingController.text = totalWalletBalance == null ? "" : "$totalWalletBalance";
  }

  @override
  String toString() {
    return "{'studentProfile': $studentProfile, 'sectionId': $sectionId, 'sectionName': $sectionName, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'studentWalletTransactionHistoryBeans': $studentWalletTransactionHistoryBeans, 'studentTermWiseTransactionHistoryBeans': $studentTermWiseTransactionHistoryBeans}";
  }
}

class _StudentTermWiseTransactionHistory {
  int? termId;
  String? termName;
  int? totalTermFee;
  int? totalTermFeePaid;
  int? totalAnnualFee;

  List<_StudentTermWiseFeeTypeTransactionHistory>? studentTermWiseFeeTypeTransactionHistoryBeans;

  _StudentTermWiseTransactionHistory({
    this.termId,
    this.termName,
    this.totalTermFee,
    this.totalTermFeePaid,
    this.totalAnnualFee,
    this.studentTermWiseFeeTypeTransactionHistoryBeans,
  });

  @override
  String toString() {
    return "{'termId': $termId, 'termName': $termName, 'totalTermFee': $totalTermFee, 'totalTermFeePaid': $totalTermFeePaid, 'totalAnnualFee': $totalAnnualFee, 'studentTermWiseFeeTypeTransactionHistoryBeans': $studentTermWiseFeeTypeTransactionHistoryBeans}";
  }
}

class _StudentTermWiseFeeTypeTransactionHistory {
  int? feeTypeId;
  String? feeType;
  int? totalTermFee;
  int? totalTermFeePaid;
  int? termId;
  int? totalAnnualFee;

  int? feeNowPaying;
  TextEditingController feeNowPayingController = TextEditingController();

  List<_FeeTypeTransaction>? transactions;

  List<_StudentTermWiseCustomFeeTypeTransactionHistory>? studentTermWiseCustomFeeTypeTransactionHistory;

  _StudentTermWiseFeeTypeTransactionHistory({
    this.feeTypeId,
    this.feeType,
    this.totalTermFee,
    this.totalTermFeePaid,
    this.transactions,
    this.studentTermWiseCustomFeeTypeTransactionHistory,
    this.termId,
    this.totalAnnualFee,
  }) {
    feeNowPaying = (totalTermFee ?? 0) - (totalTermFeePaid ?? 0);
    feeNowPayingController.text = "${feeNowPaying! / 100}";
  }

  @override
  String toString() {
    return "{'feeNowPaying': $feeNowPaying, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'totalTermFee': $totalTermFee, 'totalTermFeePaid': $totalTermFeePaid, 'transactions': $transactions, 'studentTermWiseCustomFeeTypeTransactionHistory': $studentTermWiseCustomFeeTypeTransactionHistory, 'termId': $termId, 'totalAnnualFee': $totalAnnualFee}";
  }
}

class _FeeTypeTransaction {
  int? transactionAmount;
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
    this.transactionAmount,
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
    return "{'transactionAmount': $transactionAmount, 'transactionId': $transactionId, 'masterTransactionId': $masterTransactionId, 'transactionTime': $transactionTime, 'transactionDescription': $transactionDescription, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'feePaidId': $feePaidId, 'modeOfPayment': $modeOfPayment, 'type': $type, 'kind': $kind}";
  }
}

class _StudentTermWiseCustomFeeTypeTransactionHistory {
  int? feeTypeId;
  String? feeType;
  int? customFeeTypeId;
  String? customFeeType;
  int? totalTermFee;
  int? totalTermFeePaid;
  int? totalAnnualFee;
  int? termId;

  int? feeNowPaying;
  TextEditingController feeNowPayingController = TextEditingController();

  List<_CustomFeeTypeTransaction>? transactions;

  _StudentTermWiseCustomFeeTypeTransactionHistory({
    this.feeTypeId,
    this.feeType,
    this.customFeeTypeId,
    this.customFeeType,
    this.totalTermFee,
    this.totalTermFeePaid,
    this.totalAnnualFee,
    this.transactions,
    this.termId,
  }) {
    feeNowPaying = (totalTermFee ?? 0) - (totalTermFeePaid ?? 0);
    feeNowPayingController.text = "${feeNowPaying! / 100}";
  }

  @override
  String toString() {
    return "{'feeNowPaying': $feeNowPaying, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'totalTermFee': $totalTermFee, 'totalTermFeePaid': $totalTermFeePaid, 'totalAnnualFee': $totalAnnualFee, 'transactions': $transactions, 'termId': $termId}";
  }
}

class _CustomFeeTypeTransaction {
  int? transactionAmount;
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
    this.transactionAmount,
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
    return "{'transactionAmount': $transactionAmount, 'transactionId': $transactionId, 'masterTransactionId': $masterTransactionId, 'transactionTime': $transactionTime, 'transactionDescription': $transactionDescription, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'feePaidId': $feePaidId, 'modeOfPayment': $modeOfPayment, 'type': $type, 'kind': $kind}";
  }
}

class _SupportClassForFee {
  int? termId;
  int? feeTypeId;
  int? customFeeTypeId;
  int? totalTermFee;
  int? totalFeePaid;
  int? totalAnnualFee;
  int? feePayingNow;
  late int feePayable;

  _SupportClassForFee({
    this.termId,
    this.feeTypeId,
    this.customFeeTypeId,
    this.totalTermFee,
    this.totalFeePaid,
    this.totalAnnualFee,
    required this.feePayable,
  });
}
