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
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminPayFeeScreen extends StatefulWidget {
  const AdminPayFeeScreen({
    Key? key,
    required this.adminProfile,
    required this.studentWiseAnnualFeesBean,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final StudentAnnualFeeBean studentWiseAnnualFeesBean;

  @override
  _AdminPayFeeScreenState createState() => _AdminPayFeeScreenState();
}

class _AdminPayFeeScreenState extends State<AdminPayFeeScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TermBean> terms = [];

  StudentWiseTermFeesBean? studentWiseTermFeesBean;

  late StudentProfile studentProfile;
  List<_StudentFeePaidBean> studentFeePaidBeans = [];
  int walletBalance = 0;
  TextEditingController totalAmountPayingController = TextEditingController();
  int? totalAmountPaying;
  int totalFee = 0;
  int minTotalAmountPayable = 0;

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
        walletBalance = studentProfile.balanceAmount ?? 0;
      });
    }
    GetTermsResponse getTermsResponse = await getTerms(GetTermsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getTermsResponse.httpStatus != "OK" || getTermsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        terms = getTermsResponse.termBeanList!.map((e) => e!).toList();
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
    _parseContent();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _parseContent() async {
    setState(() {
      _isLoading = true;
    });
    if (studentWiseTermFeesBean == null) return;
    for (TermBean eachTerm in terms) {
      List<_StudentFeePaidForFeeTypeBean> list = [];
      (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
          .where((e) => e != null)
          .map((e) => e!)
          .where((e) => e.termId == eachTerm.termId)
          .forEach((StudentWiseTermFeeMapBean eachStudentWiseTermFeeMapBean) {
        if (eachStudentWiseTermFeeMapBean.customFeeTypeId == null) {
          if (list.where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId).isEmpty) {
            list.add(_StudentFeePaidForFeeTypeBean(
              studentId: studentWiseTermFeesBean?.studentId,
              feeTypeId: eachStudentWiseTermFeeMapBean.feeTypeId,
              feeType: eachStudentWiseTermFeeMapBean.feeType,
            ));
          }
        } else {
          if (list.where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId).isEmpty) {
            list.add(_StudentFeePaidForFeeTypeBean(
                studentId: studentWiseTermFeesBean?.studentId,
                feeTypeId: eachStudentWiseTermFeeMapBean.feeTypeId,
                feeType: eachStudentWiseTermFeeMapBean.feeType,
                studentFeePaidForCustomFeeTypeBeans: [
                  _StudentFeePaidForCustomFeeTypeBean(
                    studentId: studentWiseTermFeesBean?.studentId,
                    customFeeTypeId: eachStudentWiseTermFeeMapBean.customFeeTypeId,
                    customFeeType: eachStudentWiseTermFeeMapBean.customFeeType,
                  )
                ]));
          } else {
            if (list
                .map((e) => e.studentFeePaidForCustomFeeTypeBeans ?? [])
                .expand((i) => i)
                .where((e) => e.customFeeTypeId == eachStudentWiseTermFeeMapBean.customFeeTypeId)
                .isNotEmpty) return;
            list
                .where((e) => e.feeTypeId == eachStudentWiseTermFeeMapBean.feeTypeId)
                .first
                .studentFeePaidForCustomFeeTypeBeans
                ?.add(_StudentFeePaidForCustomFeeTypeBean(
                  studentId: studentWiseTermFeesBean?.studentId,
                  customFeeTypeId: eachStudentWiseTermFeeMapBean.customFeeTypeId,
                  customFeeType: eachStudentWiseTermFeeMapBean.customFeeType,
                ));
          }
        }
      });
      for (_StudentFeePaidForFeeTypeBean eachStudentFeePaidForFeeTypeBean in list) {
        if ((eachStudentFeePaidForFeeTypeBean.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty) {
          int feePaid = (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
              .where((e) => e?.termId == eachTerm.termId && e?.feeTypeId == eachStudentFeePaidForFeeTypeBean.feeTypeId)
              .map((e) => e?.feePaid ?? 0)
              .sum;
          eachStudentFeePaidForFeeTypeBean.feePaid = feePaid;
          int fee = (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
                  .where((e) => e?.termId == eachTerm.termId && e?.feeTypeId == eachStudentFeePaidForFeeTypeBean.feeTypeId)
                  .first
                  ?.termFee ??
              0;
          eachStudentFeePaidForFeeTypeBean.fee = fee;
          List<_Transaction> transactions = (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
              .where((e) => e?.termId == eachTerm.termId && e?.feeTypeId == eachStudentFeePaidForFeeTypeBean.feeTypeId && e?.transactionId != null)
              .map((e) => _Transaction(
                    amount: e?.feePaid,
                    transactionId: e?.transactionId == null ? "-" : e?.transactionId.toString(),
                    transactionTime: e?.paymentDate,
                  ))
              .toList();
          eachStudentFeePaidForFeeTypeBean.transactionsList = transactions.isEmpty ? null : transactions;
          eachStudentFeePaidForFeeTypeBean.feePaying = (fee - feePaid);
          eachStudentFeePaidForFeeTypeBean.feePayingController.text = "${(fee - feePaid) / 100}";
        } else {
          for (_StudentFeePaidForCustomFeeTypeBean eachStudentFeePaidForCustomFeeTypeBean
              in (eachStudentFeePaidForFeeTypeBean.studentFeePaidForCustomFeeTypeBeans ?? [])) {
            int feePaid = (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
                .where((e) =>
                    e?.termId == eachTerm.termId &&
                    e?.feeTypeId == eachStudentFeePaidForFeeTypeBean.feeTypeId &&
                    e?.customFeeTypeId == eachStudentFeePaidForCustomFeeTypeBean.customFeeTypeId)
                .map((e) => e?.feePaid ?? 0)
                .sum;
            eachStudentFeePaidForCustomFeeTypeBean.feePaid = feePaid;
            int fee = (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
                    .where((e) =>
                        e?.termId == eachTerm.termId &&
                        e?.feeTypeId == eachStudentFeePaidForFeeTypeBean.feeTypeId &&
                        e?.customFeeTypeId == eachStudentFeePaidForCustomFeeTypeBean.customFeeTypeId)
                    .first
                    ?.termFee ??
                0;
            eachStudentFeePaidForCustomFeeTypeBean.fee = fee;
            List<_Transaction> transactions = (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
                .where((e) =>
                    e?.termId == eachTerm.termId &&
                    e?.feeTypeId == eachStudentFeePaidForFeeTypeBean.feeTypeId &&
                    e?.customFeeTypeId == eachStudentFeePaidForCustomFeeTypeBean.customFeeTypeId &&
                    e?.transactionId != null)
                .map((e) => _Transaction(
                      amount: e?.feePaid,
                      transactionId: e?.transactionId == null ? "-" : e?.transactionId.toString(),
                      transactionTime: e?.paymentDate,
                    ))
                .toList();
            eachStudentFeePaidForCustomFeeTypeBean.transactionsList = transactions.isEmpty ? null : transactions;
            eachStudentFeePaidForCustomFeeTypeBean.feePaying = (fee - feePaid);
            eachStudentFeePaidForCustomFeeTypeBean.feePayingController.text = "${(fee - feePaid) / 100}";
          }
        }
      }
      int totalFeePaid = list
          .map((e) => (e.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty
              ? (e.feePaid ?? 0)
              : (e.studentFeePaidForCustomFeeTypeBeans!.map((c) => c.feePaid ?? 0).toList().sum))
          .toList()
          .sum;
      int totalFee = list
          .map((e) => (e.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty
              ? (e.fee ?? 0)
              : (e.studentFeePaidForCustomFeeTypeBeans!.map((c) => c.fee ?? 0).toList().sum))
          .toList()
          .sum;
      studentFeePaidBeans.add(_StudentFeePaidBean(
        studentId: studentWiseTermFeesBean?.studentId,
        termId: eachTerm.termId,
        termName: eachTerm.termName,
        studentFeePaidForFeeTypeBeans: list,
        totalFeePaid: totalFeePaid,
        totalFee: totalFee,
      ));
    }
    for (TermBean eachTerm in terms) {
      for (_StudentFeePaidBean eachStudentFeePaidBean in studentFeePaidBeans.where((e) => e.termId == eachTerm.termId)) {
        totalFee += (eachStudentFeePaidBean.studentFeePaidForFeeTypeBeans ?? [])
            .map((e) => (e.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty
                ? e.fee ?? 0
                : (e.studentFeePaidForCustomFeeTypeBeans ?? []).map((c) => c.fee ?? 0).toList().sum)
            .toList()
            .sum;
        minTotalAmountPayable += (eachStudentFeePaidBean.studentFeePaidForFeeTypeBeans ?? [])
            .map((e) => (e.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty
                ? e.feePaying ?? 0
                : (e.studentFeePaidForCustomFeeTypeBeans ?? []).map((c) => c.feePaying ?? 0).toList().sum)
            .toList()
            .sum;
      }
    }
    totalAmountPayingController.text = "${(totalAmountPaying ?? minTotalAmountPayable) / 100}";
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Assign Fee Types To Sections"),
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
                BasicFeeStatsReadWidget(
                  studentWiseAnnualFeesBean: widget.studentWiseAnnualFeesBean,
                  context: context,
                ),
                // SelectableText("$studentFeePaidBeans"),
                for (_StudentFeePaidBean eachStudentFeePaid in studentFeePaidBeans)
                  if ((eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? []).isNotEmpty) buildTermWiseWidget(eachStudentFeePaid),
                //  TODO VIEW_RECEIPT
                showReceiptsButton(),
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          walletBalanceWidget(),
                          totalAmountPayableEditor(),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: walletBalanceWidget(),
                          ),
                          Expanded(
                            child: totalAmountPayableEditor(),
                          )
                        ],
                      )
              ],
            ),
    );
  }

  Widget showReceiptsButton() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.portrait
          ? const EdgeInsets.fromLTRB(25, 10, 25, 10)
          : EdgeInsets.fromLTRB(25, 10, 3 * MediaQuery.of(context).size.width / 4, 10),
      child: GestureDetector(
        onTap: () {
          // TODO Go to receipt page
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 5,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              child: const Text(
                "Receipts",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget walletBalanceWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text("Wallet Balance: ${walletBalance == 0 ? "-" : "$INR_SYMBOL ${walletBalance / 100}"}"),
          ),
        ],
      ),
    );
  }

  Widget totalAmountPayableEditor() {
    int totalDue = totalFee - minTotalAmountPayable;
    String? _errorText;
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Total amount paying: "),
          SizedBox(
            width: 100,
            child: TextField(
              controller: totalAmountPayingController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                errorText: _errorText,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                label: totalDue == 0
                    ? null
                    : Text(
                        'Due: $INR_SYMBOL ${totalDue / 100}',
                        textAlign: TextAlign.end,
                      ),
                suffix: Text(INR_SYMBOL),
                // floatingLabelAlignment: FloatingLabelAlignment.center,
                labelStyle: const TextStyle(
                  color: Colors.red,
                ),
                hintText: 'Amount',
                contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    final text = newValue.text;
                    if (text.isNotEmpty) double.parse(text);
                    return newValue;
                  } catch (e) {}
                  return oldValue;
                }),
              ],
              onChanged: (String e) {
                setState(() {
                  try {
                    if (double.parse(e) * 100 < minTotalAmountPayable) {
                      _errorText = "Cannot reduce below declared fields";
                      return;
                    } else {
                      _errorText = null;
                    }
                    // TODO change wallet balance here
                    setState(() {
                      totalAmountPaying = (double.parse(e) * 100).toInt();
                    });
                    if (double.parse(e) * 100 > totalFee) {
                      setState(() {
                        walletBalance += (double.parse(e) * 100).round() - totalFee;
                      });
                    }
                  } catch (e) {}
                });
              },
              style: const TextStyle(
                fontSize: 12,
              ),
              autofocus: true,
            ),
          ),
        ],
      ),
    );
  }

  Container buildTermWiseWidget(_StudentFeePaidBean eachStudentFeePaid) {
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                eachStudentFeePaid.termName ?? "-",
                style: const TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 15,
              ),
              if ((eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? []).isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Fee Type",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Term Fee",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Fee Paid",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Fee Paying",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if ((eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? []).isNotEmpty)
                const SizedBox(
                  height: 15,
                ),
              for (_StudentFeePaidForFeeTypeBean eachStudentFeePaidForFeeTypeBean in eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? [])
                studentFeePaidForFeeTypeBean(eachStudentFeePaidForFeeTypeBean),
              if ((eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? []).isNotEmpty)
                const SizedBox(
                  height: 15,
                ),
              if ((eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? []).isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "",
                          children: [
                            TextSpan(
                              text: "Total Fee Paying:  ",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor == Colors.blue ? Colors.black : Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: INR_SYMBOL +
                                  " " +
                                  ((((eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? []).map((e) =>
                                                  (e.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty
                                                      ? e.feePaying ?? 0
                                                      : (e.studentFeePaidForCustomFeeTypeBeans ?? []).map((c) => c.feePaying ?? 0).toList().sum))
                                              .toList()
                                              .sum) /
                                          100)
                                      .toString(),
                              style: TextStyle(
                                color: (eachStudentFeePaid.totalFee ?? 0) - (eachStudentFeePaid.totalFeePaid ?? 0) ==
                                        (((eachStudentFeePaid.studentFeePaidForFeeTypeBeans ?? []).map((e) =>
                                                (e.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty
                                                    ? e.feePaying ?? 0
                                                    : (e.studentFeePaidForCustomFeeTypeBeans ?? []).map((c) => c.feePaying ?? 0).toList().sum))
                                            .toList()
                                            .sum)
                                    ? Colors.green
                                    : Theme.of(context).primaryColor == Colors.blue
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget studentFeePaidForFeeTypeBean(_StudentFeePaidForFeeTypeBean eachStudentFeePaidForFeeTypeBean) {
    List<Widget> widgets = [];
    if ((eachStudentFeePaidForFeeTypeBean.studentFeePaidForCustomFeeTypeBeans ?? []).isEmpty) {
      widgets.add(Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(eachStudentFeePaidForFeeTypeBean.feeType ?? "-"),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                eachStudentFeePaidForFeeTypeBean.fee == null ? "-" : INR_SYMBOL + " " + (eachStudentFeePaidForFeeTypeBean.fee! / 100).toString(),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                eachStudentFeePaidForFeeTypeBean.feePaid == null
                    ? "-"
                    : INR_SYMBOL + " " + (eachStudentFeePaidForFeeTypeBean.feePaid! / 100).toString(),
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
                  controller: eachStudentFeePaidForFeeTypeBean.feePayingController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: ((eachStudentFeePaidForFeeTypeBean.fee ?? 0) -
                                    (eachStudentFeePaidForFeeTypeBean.feePaid ?? 0) -
                                    (eachStudentFeePaidForFeeTypeBean.feePaying ?? 0)) ==
                                0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: ((eachStudentFeePaidForFeeTypeBean.fee ?? 0) -
                                    (eachStudentFeePaidForFeeTypeBean.feePaid ?? 0) -
                                    (eachStudentFeePaidForFeeTypeBean.feePaying ?? 0)) ==
                                0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    label: Text(
                      'Due: $INR_SYMBOL ${((eachStudentFeePaidForFeeTypeBean.fee ?? 0) - (eachStudentFeePaidForFeeTypeBean.feePaid ?? 0) - (eachStudentFeePaidForFeeTypeBean.feePaying ?? 0)) / 100}',
                      textAlign: TextAlign.end,
                    ),
                    suffix: Text(INR_SYMBOL),
                    // floatingLabelAlignment: FloatingLabelAlignment.center,
                    labelStyle: TextStyle(
                      color: ((eachStudentFeePaidForFeeTypeBean.fee ?? 0) -
                                  (eachStudentFeePaidForFeeTypeBean.feePaid ?? 0) -
                                  (eachStudentFeePaidForFeeTypeBean.feePaying ?? 0)) ==
                              0
                          ? Colors.green
                          : Colors.red,
                    ),
                    hintText: 'Amount',
                    contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      try {
                        final text = newValue.text;
                        if (text.isNotEmpty) double.parse(text);
                        if (double.parse(text) * 100 >
                            (eachStudentFeePaidForFeeTypeBean.fee ?? 0) - (eachStudentFeePaidForFeeTypeBean.feePaid ?? 0)) {
                          return oldValue;
                        }
                        return newValue;
                      } catch (e) {}
                      return oldValue;
                    }),
                  ],
                  onChanged: (String e) {
                    setState(() {
                      try {
                        eachStudentFeePaidForFeeTypeBean.feePaying = (double.parse(e) * 100).round();
                      } catch (e) {}
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
      ));
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
              child: Text(eachStudentFeePaidForFeeTypeBean.feeType ?? "-"),
            ),
          ],
        ),
      );
      widgets.add(
        const SizedBox(
          height: 15,
        ),
      );
      for (_StudentFeePaidForCustomFeeTypeBean eachStudentFeePaidForCustomFeeTypeBean
          in eachStudentFeePaidForFeeTypeBean.studentFeePaidForCustomFeeTypeBeans ?? []) {
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
                    Text(eachStudentFeePaidForCustomFeeTypeBean.customFeeType ?? "-"),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    eachStudentFeePaidForCustomFeeTypeBean.fee == null
                        ? "-"
                        : INR_SYMBOL + " " + (eachStudentFeePaidForCustomFeeTypeBean.fee! / 100).toString(),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    eachStudentFeePaidForCustomFeeTypeBean.feePaid == null
                        ? "-"
                        : INR_SYMBOL + " " + (eachStudentFeePaidForCustomFeeTypeBean.feePaid! / 100).toString(),
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
                      controller: eachStudentFeePaidForCustomFeeTypeBean.feePayingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: ((eachStudentFeePaidForCustomFeeTypeBean.fee ?? 0) -
                                        (eachStudentFeePaidForCustomFeeTypeBean.feePaid ?? 0) -
                                        (eachStudentFeePaidForCustomFeeTypeBean.feePaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: ((eachStudentFeePaidForCustomFeeTypeBean.fee ?? 0) -
                                        (eachStudentFeePaidForCustomFeeTypeBean.feePaid ?? 0) -
                                        (eachStudentFeePaidForCustomFeeTypeBean.feePaying ?? 0)) ==
                                    0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        label: Text(
                          'Due: $INR_SYMBOL ${((eachStudentFeePaidForCustomFeeTypeBean.fee ?? 0) - (eachStudentFeePaidForCustomFeeTypeBean.feePaid ?? 0) - (eachStudentFeePaidForCustomFeeTypeBean.feePaying ?? 0)) / 100}',
                          textAlign: TextAlign.end,
                        ),
                        suffix: Text(INR_SYMBOL),
                        // floatingLabelAlignment: FloatingLabelAlignment.center,
                        labelStyle: TextStyle(
                          color: ((eachStudentFeePaidForCustomFeeTypeBean.fee ?? 0) -
                                      (eachStudentFeePaidForCustomFeeTypeBean.feePaid ?? 0) -
                                      (eachStudentFeePaidForCustomFeeTypeBean.feePaying ?? 0)) ==
                                  0
                              ? Colors.green
                              : Colors.red,
                        ),
                        hintText: '${(eachStudentFeePaidForCustomFeeTypeBean.fee ?? 0) - (eachStudentFeePaidForCustomFeeTypeBean.feePaid ?? 0)}',
                        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            if (double.parse(text) * 100 >
                                (eachStudentFeePaidForCustomFeeTypeBean.fee ?? 0) - (eachStudentFeePaidForCustomFeeTypeBean.feePaid ?? 0)) {
                              return oldValue;
                            }
                            return newValue;
                          } catch (e) {}
                          return oldValue;
                        }),
                      ],
                      onChanged: (String e) {
                        setState(() {
                          try {
                            eachStudentFeePaidForCustomFeeTypeBean.feePaying = (double.parse(e) * 100).round();
                          } catch (e) {}
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

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: widgets,
      ),
    );
  }
}

class BasicFeeStatsReadWidget extends StatelessWidget {
  const BasicFeeStatsReadWidget({
    Key? key,
    required this.studentWiseAnnualFeesBean,
    required this.context,
  }) : super(key: key);

  final StudentAnnualFeeBean studentWiseAnnualFeesBean;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(
      Row(
        children: [
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              "${studentWiseAnnualFeesBean.rollNumber ?? "-"}. ${studentWiseAnnualFeesBean.studentName}",
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              studentWiseAnnualFeesBean.sectionName ?? "-",
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(
            width: 15,
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
    for (StudentAnnualFeeTypeBean eachStudentAnnualFeeTypeBean in (studentWiseAnnualFeesBean.studentAnnualFeeTypeBeans ?? [])) {
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
                    : Text("$INR_SYMBOL ${(eachStudentAnnualFeeTypeBean.amount! / 100).toString()}"),
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
                      : Text("$INR_SYMBOL ${(eachStudentAnnualCustomFeeTypeBean.amount! / 100).toString()}"),
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
            studentWiseAnnualFeesBean.totalFee == null ? "-" : "$INR_SYMBOL ${((studentWiseAnnualFeesBean.totalFee ?? 0) / 100).toString()}",
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
            studentWiseAnnualFeesBean.totalFeePaid == null ? "-" : "$INR_SYMBOL ${((studentWiseAnnualFeesBean.totalFeePaid ?? 0) / 100).toString()}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text(
              "Wallet Balance:",
            ),
          ),
          Text(
            "$INR_SYMBOL ${((studentWiseAnnualFeesBean.walletBalance ?? 0) / 100).toString()}",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
    feeStats.add(
      Row(
        children: [
          const Expanded(
            child: Text(
              "Fee to be paid:",
            ),
          ),
          Text(
            "$INR_SYMBOL ${(((studentWiseAnnualFeesBean.totalFee ?? 0) - (studentWiseAnnualFeesBean.totalFeePaid ?? 0) - (studentWiseAnnualFeesBean.walletBalance ?? 0)) / 100).toString()}",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: ((studentWiseAnnualFeesBean.totalFee ?? 0) -
                          (studentWiseAnnualFeesBean.totalFeePaid ?? 0) -
                          (studentWiseAnnualFeesBean.walletBalance ?? 0)) ==
                      0
                  ? null
                  : const Color(0xffff5733),
            ),
          ),
        ],
      ),
    );

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
}

class _StudentFeePaidBean {
  int? studentId;
  int? termId;
  String? termName;
  int? totalFee;
  int? totalFeePaid;
  List<_StudentFeePaidForFeeTypeBean>? studentFeePaidForFeeTypeBeans;

  _StudentFeePaidBean({
    this.studentId,
    this.termId,
    this.termName,
    this.totalFee,
    this.totalFeePaid,
    this.studentFeePaidForFeeTypeBeans,
  });

  @override
  String toString() {
    return "{'studentId': $studentId, 'termId': $termId, 'termName': $termName, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid, 'studentFeePaidForFeeTypeBeans': $studentFeePaidForFeeTypeBeans}";
  }
}

class _StudentFeePaidForFeeTypeBean {
  int? studentId;
  int? feeTypeId;
  String? feeType;
  int? feePaid;
  int? fee;
  int? feePaying;
  TextEditingController feePayingController = TextEditingController();
  List<_Transaction>? transactionsList;
  List<_StudentFeePaidForCustomFeeTypeBean>? studentFeePaidForCustomFeeTypeBeans;

  _StudentFeePaidForFeeTypeBean({
    this.studentId,
    this.feeTypeId,
    this.feeType,
    this.feePaid,
    this.fee,
    this.transactionsList,
    this.studentFeePaidForCustomFeeTypeBeans,
  });

  @override
  String toString() {
    return "{'studentId': $studentId, 'feeTypeId': $feeTypeId, 'feeType': $feeType, 'feePaid': $feePaid, 'fee': $fee, 'transactionsList': $transactionsList, 'studentFeePaidForCustomFeeTypeBeans': $studentFeePaidForCustomFeeTypeBeans}";
  }
}

class _StudentFeePaidForCustomFeeTypeBean {
  int? studentId;
  int? customFeeTypeId;
  String? customFeeType;
  int? feePaid;
  int? fee;
  int? feePaying;
  TextEditingController feePayingController = TextEditingController();
  List<_Transaction>? transactionsList;

  _StudentFeePaidForCustomFeeTypeBean({
    this.studentId,
    this.customFeeTypeId,
    this.customFeeType,
    this.feePaid,
    this.fee,
    this.transactionsList,
  });

  @override
  String toString() {
    return "{'studentId': $studentId, 'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'feePaid': $feePaid, 'fee': $fee, 'transactionsList': $transactionsList}";
  }
}

class _Transaction {
  int? amount;
  String? transactionId;
  String? transactionTime;

  _Transaction({
    this.amount,
    this.transactionId,
    this.transactionTime,
  });

  @override
  String toString() {
    return "{'amount': $amount, 'transactionId': $transactionId, 'transactionTime': $transactionTime}";
  }
}
