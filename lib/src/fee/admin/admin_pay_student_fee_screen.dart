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

class PayStudentFeeScreen extends StatefulWidget {
  const PayStudentFeeScreen({
    Key? key,
    required this.adminProfile,
    required this.studentWiseAnnualFeesBean,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final StudentAnnualFeeBean studentWiseAnnualFeesBean;

  @override
  _PayStudentFeeScreenState createState() => _PayStudentFeeScreenState();
}

class _PayStudentFeeScreenState extends State<PayStudentFeeScreen> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StudentWiseTermFeesBean? studentWiseTermFeesBean;

  late StudentProfile studentProfile;

  late _StudentWiseAnnualTransactionHistory studentWiseAnnualTransactionHistory;

  TextEditingController totalFeeNowPayingEditingController = TextEditingController();
  int totalFeeNowPaying = 0;
  int? newWalletBalance;

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
      newWalletBalance = studentProfile.balanceAmount;
      studentWiseAnnualTransactionHistory = _StudentWiseAnnualTransactionHistory(
        sectionId: studentProfile.sectionId,
        sectionName: studentProfile.sectionName,
        studentTermWiseTransactionHistoryBeans: [],
        studentProfile: studentProfile,
      );
      (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
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
      (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
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
                totalFee: eachStudentWiseTermFeeMapBean.termFee,
                studentTermWiseCustomFeeTypeTransactionHistory: [],
                transactions: [],
                termId: eachStudentWiseTermFeeMapBean.termId,
              ),
            );
          }
        });
      });
      (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
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
                  totalFee: eachStudentWiseTermFeeMapBean.termFee,
                  customFeeTypeId: eachStudentWiseTermFeeMapBean.customFeeTypeId,
                  customFeeType: eachStudentWiseTermFeeMapBean.customFeeType,
                  termId: eachStudentWiseTermFeeMapBean.termId,
                ),
              );
            }
          });
        });
      });

      (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
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
                  amount: eachStudentWiseTermFeeMapBean.feePaid,
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
                  amount: eachStudentWiseTermFeeMapBean.feePaid,
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
            eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid =
                eachStudentTermWiseFeeTypeTransactionHistory.transactions!.map((e) => e.amount ?? 0).sum;
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying =
                (eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0);
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPayingController.text =
                "${((eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0)) / 100}";
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid =
                  eachStudentTermWiseCustomFeeTypeTransactionHistory.transactions!.map((e) => e.amount ?? 0).sum;
              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying = (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) -
                  (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0);
              eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPayingController.text =
                  "${((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0)) / 100}";
            });
          }
        });
      });

      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.totalFee = eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.map((e) => e.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty
                ? (e.totalFee ?? 0)
                : e.studentTermWiseCustomFeeTypeTransactionHistory!.map((c) => c.totalFee ?? 0).sum)
            .sum;
        eachStudentTermWiseTransactionHistory.totalFeePaid = eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.map((e) => e.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty
                ? (e.totalFeePaid ?? 0)
                : e.studentTermWiseCustomFeeTypeTransactionHistory!.map((c) => c.totalFeePaid ?? 0).sum)
            .sum;
      });

      studentWiseAnnualTransactionHistory.totalFee =
          studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.map((e) => e.totalFee ?? 0).sum;
      studentWiseAnnualTransactionHistory.totalFeePaid =
          studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.map((e) => e.totalFeePaid ?? 0).sum;

      studentWiseAnnualTransactionHistory.studentWalletTransactionHistoryBeans =
          (studentWiseTermFeesBean?.studentWalletTransactionBeans ?? []).map((e) => e!).toList();

      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            totalFeeNowPaying +=
                (eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0);
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              totalFeeNowPaying += (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) -
                  (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0);
            });
          }
        });
      });
    });

    totalFeeNowPayingEditingController.text = "${totalFeeNowPaying / 100}";

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
              child: Image.asset('assets/images/eis_loader.gif'),
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
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: buildWalletBalanceTextBox()),
                              totalAmountPayingTextField(),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: MediaQuery.of(context).orientation == Orientation.portrait
                                ? const EdgeInsets.all(8.0)
                                : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 8, MediaQuery.of(context).size.width / 5, 8),
                            child: totalAmountPayingInNumbers(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 10, 0, MediaQuery.of(context).size.width / 10, 0),
                            child: payFeeButton(),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                              Expanded(
                                child: buildWalletBalanceTextBox(),
                              ),
                              totalAmountPayingTextField(),
                              payFeeButton(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 5,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: MediaQuery.of(context).orientation == Orientation.portrait
                                ? const EdgeInsets.all(8.0)
                                : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 5, 8, MediaQuery.of(context).size.width / 5, 8),
                            child: totalAmountPayingInNumbers(),
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

  Widget buildWalletBalanceTextBox() => Container(
        margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
        child: ClayContainer(
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Text("Wallet Balance: ${newWalletBalance == null ? "-" : (newWalletBalance! / 100)}"),
          ),
        ),
      );

  Widget totalAmountPayingInNumbers() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: Text("* Paying fee: " + convertIntoWords(totalFeeNowPaying ~/ 100).capitalize() + " Rupees"),
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
                    eachStudentTermWiseFeeTypeTransactionHistory.totalFee == null
                        ? "-"
                        : INR_SYMBOL + " " + (eachStudentTermWiseFeeTypeTransactionHistory.totalFee! / 100).toString(),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid == null
                        ? "-"
                        : INR_SYMBOL + " " + (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid! / 100).toString(),
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
                            color: ((eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: ((eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0) -
                                        (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        label: Text(
                          'Due: $INR_SYMBOL ${((eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) / 100}',
                          textAlign: TextAlign.end,
                        ),
                        suffix: Text(INR_SYMBOL),
                        labelStyle: TextStyle(
                          color: ((eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) -
                                      (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0) -
                                      (eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                  0
                              ? Colors.green
                              : Colors.red,
                        ),
                        hintText: 'Amount',
                        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                      enabled: eachStudentTermWiseFeeTypeTransactionHistory.totalFee != eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            if (double.parse(text) * 100 >
                                (eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) -
                                    (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0)) {
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
                      eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee == null
                          ? "-"
                          : INR_SYMBOL + " " + (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee! / 100).toString(),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid == null
                          ? "-"
                          : INR_SYMBOL + " " + (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid! / 100).toString(),
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
                              color: ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                      0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0) -
                                          (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                      0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          label: Text(
                            'Due: $INR_SYMBOL ${((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) / 100}',
                            textAlign: TextAlign.end,
                          ),
                          suffix: Text(INR_SYMBOL),
                          labelStyle: TextStyle(
                            color: ((eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) -
                                        (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0) -
                                        (eachStudentTermWiseCustomFeeTypeTransactionHistory.feeNowPaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : Colors.red,
                          ),
                          hintText:
                              '${(eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0)}',
                          contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        ),
                        enabled: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee !=
                            eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              if (double.parse(text) * 100 >
                                  (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) -
                                      (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0)) {
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
                    ? (e.totalFee ?? 0) - (e.totalFeePaid ?? 0) - (e.feeNowPaying ?? 0)
                    : e.studentTermWiseCustomFeeTypeTransactionHistory!
                        .map((c) => (c.totalFee ?? 0) - (c.totalFeePaid ?? 0) - (c.feeNowPaying ?? 0))
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
              "Due: $INR_SYMBOL $termWiseDue",
              style: const TextStyle(color: Colors.red),
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
        onTap: () {
          // TODO Pay fee
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

  String? get _totalDueAmount {
    if ((widget.studentWiseAnnualFeesBean.totalFee ?? 0) - (widget.studentWiseAnnualFeesBean.totalFeePaid ?? 0) - totalFeeNowPaying > 0) {
      return "Due: $INR_SYMBOL ${((widget.studentWiseAnnualFeesBean.totalFee ?? 0) - (widget.studentWiseAnnualFeesBean.totalFeePaid ?? 0) - totalFeeNowPaying) / 100}";
    }
    return null;
  }

  Future<void> modifyAllNowPayingFees() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      List<_SupportClassForFee> supports = [];
      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            supports.add(_SupportClassForFee(
              termId: eachStudentTermWiseFeeTypeTransactionHistory.termId,
              feeTypeId: eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId,
              customFeeTypeId: null,
              totalFeePaid: eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid,
              totalFee: eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid,
              feePayable:
                  (eachStudentTermWiseFeeTypeTransactionHistory.totalFee ?? 0) - (eachStudentTermWiseFeeTypeTransactionHistory.totalFeePaid ?? 0),
            ));
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              supports.add(_SupportClassForFee(
                termId: eachStudentTermWiseCustomFeeTypeTransactionHistory.termId,
                feeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.feeTypeId,
                customFeeTypeId: eachStudentTermWiseCustomFeeTypeTransactionHistory.customFeeTypeId,
                totalFee: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee,
                totalFeePaid: eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid,
                feePayable: (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFee ?? 0) -
                    (eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid ?? 0),
              ));
            });
          }
        });
      });
      supports.sort((a, b) => (a.feePayable - b.feePayable));

      int totalSupportFee = totalFeeNowPaying;
      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans?.forEach((eachTermBean) {
        supports.where((e) => e.feePayable != 0).forEach((e) {
          if (e.termId == eachTermBean.termId && totalSupportFee >= e.feePayable) {
            e.feePayingNow = e.feePayable;
            totalSupportFee -= e.feePayingNow ?? 0;
          }
        });
        if (totalSupportFee > 0) {
          supports.where((e) => e.feePayable != 0).forEach((e) {
            if (e.termId == eachTermBean.termId &&
                e.feePayable > 0 &&
                totalSupportFee > 0 &&
                (e.feePayingNow ?? 0) < e.feePayable &&
                e.feePayable >= totalSupportFee) {
              e.feePayingNow = totalSupportFee;
              totalSupportFee -= e.feePayingNow ?? 0;
            }
          });
        }
      });

      studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans
          ?.forEach((_StudentTermWiseTransactionHistory eachStudentTermWiseTransactionHistory) {
        eachStudentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans
            ?.forEach((_StudentTermWiseFeeTypeTransactionHistory eachStudentTermWiseFeeTypeTransactionHistory) {
          if (eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            eachStudentTermWiseFeeTypeTransactionHistory.feeNowPaying = supports
                .where((e) => e.feeTypeId == eachStudentTermWiseFeeTypeTransactionHistory.feeTypeId && e.customFeeTypeId == null)
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

      newWalletBalance = (studentProfile.balanceAmount ?? 0) + totalSupportFee;
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
    return "_StudentWiseAnnualTransactionHistory {'sectionId': $sectionId, 'sectionName': $sectionName, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'studentWalletTransactionHistoryBeans': $studentWalletTransactionHistoryBeans, 'studentTermWiseTransactionHistoryBeans': $studentTermWiseTransactionHistoryBeans}";
  }
}

class _StudentTermWiseTransactionHistory {
  int? termId;
  String? termName;
  int? totalFee;
  int? totalFeePaid;

  List<_StudentTermWiseFeeTypeTransactionHistory>? studentTermWiseFeeTypeTransactionHistoryBeans;

  _StudentTermWiseTransactionHistory({
    this.termId,
    this.termName,
    this.totalFee,
    this.totalFeePaid,
    this.studentTermWiseFeeTypeTransactionHistoryBeans,
  });

  @override
  String toString() {
    return "_StudentTermWiseTransactionHistory {'termId': $termId, 'termName': $termName, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'studentTermWiseFeeTypeTransactionHistoryBeans': $studentTermWiseFeeTypeTransactionHistoryBeans}";
  }
}

class _StudentTermWiseFeeTypeTransactionHistory {
  int? feeTypeId;
  String? feeType;
  int? totalFee;
  int? totalFeePaid;
  int? termId;

  int? feeNowPaying;
  TextEditingController feeNowPayingController = TextEditingController();

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
  }) {
    feeNowPaying = (totalFee ?? 0) - (totalFeePaid ?? 0);
    feeNowPayingController.text = "${feeNowPaying! / 100}";
  }

  @override
  String toString() {
    return "_StudentTermWiseFeeTypeTransactionHistory {'feeTypeId': $feeTypeId, 'feeType': $feeType, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'transactions': $transactions, 'studentTermWiseCustomFeeTypeTransactionHistory': $studentTermWiseCustomFeeTypeTransactionHistory}";
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
    return "_FeeTypeTransaction {'amount': $amount, 'transactionId': $transactionId, 'masterTransactionId': $masterTransactionId, 'transactionTime': $transactionTime, 'transactionDescription': $transactionDescription, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'feePaidId': $feePaidId}";
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

  int? feeNowPaying;
  TextEditingController feeNowPayingController = TextEditingController();

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
  }) {
    feeNowPaying = (totalFee ?? 0) - (totalFeePaid ?? 0);
    feeNowPayingController.text = "${feeNowPaying! / 100}";
  }

  @override
  String toString() {
    return "_StudentTermWiseCustomFeeTypeTransactionHistory {'feeTypeId': $feeTypeId, 'feeType': $feeType, 'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'transactions': $transactions}";
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
    return "_CustomFeeTypeTransaction {'amount': $amount, 'transactionId': $transactionId, 'masterTransactionId': $masterTransactionId, 'transactionTime': $transactionTime, 'transactionDescription': $transactionDescription, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'feePaidId': $feePaidId}";
  }
}

class _SupportClassForFee {
  int? termId;
  int? feeTypeId;
  int? customFeeTypeId;
  int? totalFee;
  int? totalFeePaid;
  int? feePayingNow;
  late int feePayable;

  _SupportClassForFee({
    this.termId,
    this.feeTypeId,
    this.customFeeTypeId,
    this.totalFee,
    this.totalFeePaid,
    required this.feePayable,
  });
}
