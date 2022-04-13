import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/basic_fee_stats_widget.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AdminStudentReceiptsScreen extends StatefulWidget {
  const AdminStudentReceiptsScreen({
    Key? key,
    required this.adminProfile,
    required this.studentWiseAnnualFeesBean,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final StudentAnnualFeeBean studentWiseAnnualFeesBean;

  @override
  _AdminStudentReceiptsScreenState createState() => _AdminStudentReceiptsScreenState();
}

class _AdminStudentReceiptsScreenState extends State<AdminStudentReceiptsScreen> {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StudentWiseTermFeesBean? studentWiseTermFeesBean;

  late StudentProfile studentProfile;

  late _StudentWiseAnnualTransactionHistory studentWiseAnnualTransactionHistory;

  List<DateTime> txnDates = [];

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
          } else {
            eachStudentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory
                ?.forEach((_StudentTermWiseCustomFeeTypeTransactionHistory eachStudentTermWiseCustomFeeTypeTransactionHistory) {
              eachStudentTermWiseCustomFeeTypeTransactionHistory.totalFeePaid =
                  eachStudentTermWiseCustomFeeTypeTransactionHistory.transactions!.map((e) => e.amount ?? 0).sum;
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
    });

    setState(() {
      txnDates = ((studentWiseTermFeesBean?.studentWalletTransactionBeans ?? [])
                  .where((e) => e != null && e.transactionId != null)
                  .map((e) => e!)
                  .map((e) => convertYYYYMMDDFormatToDateTime(e.date))
                  .toSet()
                  .toList() +
              (studentWiseTermFeesBean?.studentWiseTermFeeMapBeanList ?? [])
                  .where((e) => e != null && e.transactionId != null)
                  .map((e) => e!)
                  .map((e) => convertYYYYMMDDFormatToDateTime(e.paymentDate))
                  .toSet()
                  .toList())
          .toSet()
          .toList();
      txnDates.sort();
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
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: [
                SelectableText(
                  "$studentWiseAnnualTransactionHistory",
                ),
                BasicFeeStatsReadWidget(
                  studentWiseAnnualFeesBean: widget.studentWiseAnnualFeesBean,
                  context: context,
                  alignMargin: true,
                ),
                ..._dateWiseTransactions(),
                walletWidget(),
              ],
            ),
    );
  }

  List<Widget> _dateWiseTransactions() {
    List<Widget> widgets = [];
    for (DateTime dateTime in txnDates) {
      List<Widget> subList = [];
      for (_StudentTermWiseTransactionHistory studentTermWiseTransactionHistory
          in studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans!) {
        for (_StudentTermWiseFeeTypeTransactionHistory studentTermWiseFeeTypeTransactionHistory
            in studentTermWiseTransactionHistory.studentTermWiseFeeTypeTransactionHistoryBeans!) {
          if (studentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty) {
            int totalFeeTypeAmountPerDate = studentTermWiseFeeTypeTransactionHistory.transactions!
                .where((e) => convertYYYYMMDDFormatToDateTime(e.transactionTime).millisecondsSinceEpoch == dateTime.millisecondsSinceEpoch)
                .map((e) => e.amount ?? 0)
                .sum;
            subList.add(buildAmountWidgetForFeeType(studentTermWiseFeeTypeTransactionHistory.feeType ?? "-", totalFeeTypeAmountPerDate));
            subList.add(const SizedBox(
              height: 15,
            ));
          } else {
            if (studentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                .map((e) => e.transactions!)
                .expand((i) => i)
                .where((e) => convertYYYYMMDDFormatToDateTime(e.transactionTime).millisecondsSinceEpoch == dateTime.millisecondsSinceEpoch)
                .isNotEmpty) {
              Set<int> customFeeTypeIds = studentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                  .map((e) => e.transactions!)
                  .expand((i) => i)
                  .where((e) => convertYYYYMMDDFormatToDateTime(e.transactionTime).millisecondsSinceEpoch == dateTime.millisecondsSinceEpoch)
                  .map((e) => e.customFeeTypeId!)
                  .toSet();
              List<_SupportClassForCustomFeeType> supportClassForCustomFeeTypes = customFeeTypeIds.map((int customFeeTypeId) {
                int amount = studentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                    .map((e) => e.transactions!)
                    .expand((i) => i)
                    .where((e) => convertYYYYMMDDFormatToDateTime(e.transactionTime).millisecondsSinceEpoch == dateTime.millisecondsSinceEpoch)
                    .where((c) => c.customFeeTypeId == customFeeTypeId)
                    .map((e) => e.amount ?? 0)
                    .sum;
                String customFeeType = studentTermWiseFeeTypeTransactionHistory.studentTermWiseCustomFeeTypeTransactionHistory!
                        .where((c) => c.customFeeTypeId == customFeeTypeId)
                        .firstOrNull
                        ?.customFeeType ??
                    "-";
                return _SupportClassForCustomFeeType(
                  amount: amount,
                  customFeeType: customFeeType,
                );
              }).toList();
              subList.addAll(buildCustomFeeTypeWidgets(studentTermWiseFeeTypeTransactionHistory.feeType ?? "-", supportClassForCustomFeeTypes));
            }
          }
        }
      }
      int totalPerDay = studentWiseAnnualTransactionHistory.studentTermWiseTransactionHistoryBeans!
          .map((e) => e.studentTermWiseFeeTypeTransactionHistoryBeans!
              .map((e) => e.studentTermWiseCustomFeeTypeTransactionHistory!.isEmpty
                  ? e.transactions!
                      .where((t) => convertYYYYMMDDFormatToDateTime(t.transactionTime).millisecondsSinceEpoch == dateTime.millisecondsSinceEpoch)
                      .map((t) => t.amount ?? 0)
                      .sum
                  : e.studentTermWiseCustomFeeTypeTransactionHistory!
                      .map((c) => c.transactions!)
                      .expand((i) => i)
                      .where((t) => convertYYYYMMDDFormatToDateTime(t.transactionTime).millisecondsSinceEpoch == dateTime.millisecondsSinceEpoch)
                      .map((t) => t.amount ?? 0)
                      .sum)
              .sum)
          .sum;
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
                          convertDateToDDMMMYYYEEEE(
                            convertDateTimeToYYYYMMDDFormat(dateTime),
                          ),
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

  Widget buildAmountWidgetForFeeType(String feeType, int amount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            feeType,
          ),
        ),
        Text(
          INR_SYMBOL + " ${amount / 100}",
        ),
      ],
    );
  }

  List<Widget> buildCustomFeeTypeWidgets(String feeType, List<_SupportClassForCustomFeeType> customFeeTypes) {
    List<Widget> widgets = [];
    widgets.add(Row(
      children: [
        Expanded(
          child: Text(
            feeType,
          ),
        )
      ],
    ));
    widgets.add(const SizedBox(
      height: 15,
    ));
    for (_SupportClassForCustomFeeType eachCustomFeeTypeHistoryTransaction in customFeeTypes) {
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
              eachCustomFeeTypeHistoryTransaction.customFeeType ?? "-",
            ),
          ),
          Text(
            eachCustomFeeTypeHistoryTransaction.amount == null ? "-" : INR_SYMBOL + " ${eachCustomFeeTypeHistoryTransaction.amount! / 100}",
          ),
        ],
      ));
      widgets.add(const SizedBox(
        height: 15,
      ));
    }
    return widgets;
  }

  Widget walletWidget() {
    if ((studentWiseAnnualTransactionHistory.studentWalletTransactionHistoryBeans ?? []).isEmpty) return Container();
    return Container(
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
                  const Text(
                    "Wallet",
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.blue,
                    ),
                  )
                ] +
                (studentWiseAnnualTransactionHistory.studentWalletTransactionHistoryBeans ?? [])
                    .map((e) => [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  convertDateToDDMMMYYYEEEE(
                                    e.date,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: "",
                                  children: [
                                    TextSpan(
                                      text: "$INR_SYMBOL ${e.amount! / 100}",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor == Colors.blue ? Colors.black : Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " ${e.transactionKind}",
                                      style: TextStyle(
                                        color: e.transactionKind == "CR" ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ])
                    .expand((i) => i)
                    .toList(),
          ),
        ),
      ),
    );
  }
}

class _StudentWiseAnnualTransactionHistory {
  StudentProfile? studentProfile;
  int? sectionId;
  String? sectionName;
  int? totalFee;
  int? totalFeePaid;

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
  });

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

class _SupportClassForCustomFeeType {
  String? customFeeType;
  int? amount;

  _SupportClassForCustomFeeType({this.customFeeType, this.amount});
}
