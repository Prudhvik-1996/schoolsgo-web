import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/fee_support_classes.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AdminFeeReceiptsStatsScreen extends StatefulWidget {
  const AdminFeeReceiptsStatsScreen({
    Key? key,
    required this.adminProfile,
    required this.studentFeeDetailsBeanList,
    required this.feeTypes,
    required this.studentTermWiseFeeBeans,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final List<StudentFeeDetailsBean> studentFeeDetailsBeanList;
  final List<FeeType> feeTypes;
  final List<StudentTermWiseFeeSupportBean> studentTermWiseFeeBeans;

  @override
  State<AdminFeeReceiptsStatsScreen> createState() => _AdminFeeReceiptsStatsScreenState();
}

class _AdminFeeReceiptsStatsScreenState extends State<AdminFeeReceiptsStatsScreen> {
  bool _isLoading = false;

  DateTime? startDate;
  DateTime? endDate;
  List<Section> selectedSection = [];
  StatFilterType statFilterType = StatFilterType.daily;
  TextEditingController nController = TextEditingController();
  List<int> selectedFeeTypes = [];
  List<int> selectedCustomFeeTypes = [];
  int totalFeeCollected = 0;

  List<DateWiseTxnAmount> dateWiseTxnAmounts = [];
  List<MonthWiseTxnAmount> monthWiseTxnAmounts = [];

  List<StudentFeeDetailsBean> filteredStudentFeeDetailsBeanList = [];

  @override
  void initState() {
    super.initState();
    filteredStudentFeeDetailsBeanList = widget.studentFeeDetailsBeanList;
    selectedFeeTypes = widget.feeTypes.where((e) => e.customFeeTypesList?.isEmpty ?? true).map((e) => e.feeTypeId ?? 0).toList() + [-1];
    selectedCustomFeeTypes = widget.feeTypes
        .where((e) => e.customFeeTypesList?.isNotEmpty ?? false)
        .map((e) => e.customFeeTypesList ?? [])
        .expand((i) => i)
        .map((e) => e?.customFeeTypeId ?? 0)
        .toList();
    _filterData();
  }

  Future<void> _filterData() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      filteredStudentFeeDetailsBeanList = widget.studentFeeDetailsBeanList.map((e) => StudentFeeDetailsBean.fromJson(e.toJson())).toList();
    });
    populateTermTxnWiseComponents();
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
      if (statFilterType == StatFilterType.lastNDays) {
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
          dateWiseTxnAmounts.add(DateWiseTxnAmount(eachDate, dateWiseTxnAmount, context));
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
          dateWiseTxnAmounts.add(DateWiseTxnAmount(eachDate, dateWiseTxnAmount, context));
        }
      }
    });
    monthWiseTxnAmounts = [];
    if (statFilterType == StatFilterType.monthly) {
      for (DateWiseTxnAmount eachDateWiseTxn in dateWiseTxnAmounts) {
        int month = eachDateWiseTxn.dateTime.month;
        int year = eachDateWiseTxn.dateTime.year;
        MonthWiseTxnAmount? monthWiseTxnAmount =
            monthWiseTxnAmounts.where((eachMonthWiseBean) => eachMonthWiseBean.month == month && eachMonthWiseBean.year == year).firstOrNull;
        if (monthWiseTxnAmount == null) {
          monthWiseTxnAmount = MonthWiseTxnAmount(month, year, eachDateWiseTxn.amount, context);
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

  void populateTermTxnWiseComponents() {
    for (StudentFeeDetailsBean eachStudentFeeDetailsBean in filteredStudentFeeDetailsBeanList) {
      List<StudentTermWiseFeeSupportBean> studentWiseTermFeeTypes = (widget.studentTermWiseFeeBeans)
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

  Widget feePaidGrid() {
    double screenWidth = MediaQuery.of(context).size.width;
    double eachWidgetHeight = 50;
    double eachWidgetWidth = MediaQuery.of(context).orientation == Orientation.portrait ? 100 : 150;
    List<Widget> rows = [];
    int index = 0;
    List txnAmounts = statFilterType == StatFilterType.monthly ? monthWiseTxnAmounts : dateWiseTxnAmounts;
    double horizontalPadding = MediaQuery.of(context).orientation == Orientation.portrait ? 7.5 : 15;
    double verticalPadding = MediaQuery.of(context).orientation == Orientation.portrait ? 7.5 : 15;
    while (index < txnAmounts.length) {
      List<Widget> eachRowChildren = [];
      double remainingWidth = screenWidth;
      while (remainingWidth > (eachWidgetWidth) && index < txnAmounts.length) {
        eachRowChildren.add(Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
          child: txnAmounts[index].widget(height: eachWidgetHeight - 2 * verticalPadding, width: eachWidgetWidth - 2 * horizontalPadding),
        ));
        remainingWidth -= (eachWidgetWidth);
        index += 1;
      }
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: eachRowChildren,
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fee Stats"),
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : ListView(
              children: [
                statsWidget(),
                feePaidGrid(),
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
                  ],
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
        value: StatFilterType.lastNDays,
        groupValue: statFilterType,
        onChanged: (StatFilterType? value) {
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
                FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
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
              enabled: statFilterType == StatFilterType.lastNDays,
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
        value: StatFilterType.monthly,
        groupValue: statFilterType,
        onChanged: (StatFilterType? value) {
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
        value: StatFilterType.daily,
        groupValue: statFilterType,
        onChanged: (StatFilterType? value) {
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
        children: [...widget.feeTypes.map((e) => feeTypeWidget(e)).toList()] +
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
