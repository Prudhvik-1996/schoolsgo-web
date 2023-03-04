import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/fee_support_classes.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminFeeReceiptsEachReceiptWidget extends StatefulWidget {
  const AdminFeeReceiptsEachReceiptWidget({
    Key? key,
    required this.studentFeeTransactionBean,
    required this.adminProfile,
    required this.scaffoldKey,
    required this.reasonToDeleteTextController,
    this.studentId,
    this.rollNumber,
    this.studentName,
    this.sectionName,
    required this.isTermWise,
    required this.childTransactions,
    required this.busFeeTransactions,
    required this.superSetState,
  }) : super(key: key);

  final StudentFeeTransactionBean studentFeeTransactionBean;
  final AdminProfile adminProfile;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController reasonToDeleteTextController;
  final int? studentId;
  final String? rollNumber;
  final String? studentName;
  final String? sectionName;
  final bool isTermWise;

  final List<StudentFeeChildTransactionBean> childTransactions;
  final List<StudentFeeChildTransactionBean> busFeeTransactions;

  final Function superSetState;

  @override
  State<AdminFeeReceiptsEachReceiptWidget> createState() => _AdminFeeReceiptsEachReceiptWidgetState();
}

class _AdminFeeReceiptsEachReceiptWidgetState extends State<AdminFeeReceiptsEachReceiptWidget> {
  bool _isLoading = false;
  bool _isEditMode = false;

  TextEditingController newReceiptNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    newReceiptNumberController.text = "${widget.studentFeeTransactionBean.receiptId ?? ""}";
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
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Stack(
            children: [
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: receiptNumberWidget()),
                      const SizedBox(
                        width: 10,
                      ),
                      receiptDateWidget(),
                      const SizedBox(
                        width: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          editReceiptButton(),
                          const SizedBox(
                            width: 5,
                          ),
                          deleteReceiptButton(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: studentDetailsWidget(),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 1,
                          child: sectionDetailsWidget(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ...childTransactionsWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: receiptTotalWidget(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              if (_isLoading)
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/gear-loader.gif',
                    fit: BoxFit.scaleDown,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Padding receiptNumberWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: _isEditMode
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Receipt No.: "),
                SizedBox(
                  height: 50,
                  width: 100,
                  child: TextField(
                    onChanged: (value) {
                      widget.studentFeeTransactionBean.receiptId = int.tryParse(value);
                    },
                    controller: newReceiptNumberController,
                    decoration: const InputDecoration(
                      hintText: "Receipt Number",
                    ),
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          if (newValue.text == "") return newValue;
                          final text = newValue.text;
                          if (text.isNotEmpty) int.parse(text);
                          if (int.parse(text) > 0) {
                            return newValue;
                          } else {
                            return oldValue;
                          }
                        } catch (e) {
                          return oldValue;
                        }
                      }),
                    ],
                  ),
                ),
              ],
            )
          : SelectableText(
              "Receipt No. ${(widget.studentFeeTransactionBean.receiptId ?? 0) == 0 ? "" : widget.studentFeeTransactionBean.receiptId}",
              textAlign: MediaQuery.of(context).orientation == Orientation.landscape ? TextAlign.start : TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
    );
  }

  Widget editReceiptButton() {
    return GestureDetector(
      onTap: () async {
        if (_isLoading) return;
        if (_isEditMode) {
          await showDialog(
            context: widget.scaffoldKey.currentContext!,
            builder: (BuildContext dialogueContext) {
              return AlertDialog(
                title: const Text('Are you sure you want to update the receipt?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () async => updateReceiptAction(),
                  ),
                  TextButton(
                    child: const Text("No"),
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        _isEditMode = false;
                      });
                    },
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            _isEditMode = true;
          });
        }
      },
      child: ClayButton(
        color: clayContainerColor(context),
        height: 20,
        width: 20,
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                _isEditMode ? Icons.check : Icons.edit,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateReceiptAction() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    Navigator.pop(context);
    if (widget.studentFeeTransactionBean.receiptId != StudentFeeTransactionBean.fromJson(widget.studentFeeTransactionBean.origJson()).receiptId ||
        widget.studentFeeTransactionBean.transactionDate !=
            StudentFeeTransactionBean.fromJson(widget.studentFeeTransactionBean.origJson()).transactionDate) {
      UpdateReceiptResponse updateReceiptResponse = await updateReceipt(UpdateReceiptRequest(
        transactionId: widget.studentFeeTransactionBean.masterTransactionId,
        receiptId: widget.studentFeeTransactionBean.receiptId,
        date: widget.studentFeeTransactionBean.transactionDate,
        agent: widget.adminProfile.userId,
        schoolId: widget.adminProfile.schoolId,
      ));
      if (updateReceiptResponse.httpStatus != "OK" || updateReceiptResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
      } else {
        widget.superSetState();
      }
    }
    setState(() {
      _isLoading = false;
      _isEditMode = false;
    });
  }

  Widget deleteReceiptButton() {
    return GestureDetector(
      onTap: () async {
        await showDialog(
          context: widget.scaffoldKey.currentContext!,
          builder: (BuildContext dialogueContext) {
            return AlertDialog(
              title: const Text('Are you sure you want to delete the receipt?'),
              content: TextField(
                onChanged: (value) {},
                controller: widget.reasonToDeleteTextController,
                decoration: InputDecoration(
                  hintText: "Reason to delete",
                  errorText: widget.reasonToDeleteTextController.text.trim() == "" ? "Reason cannot be empty!" : "",
                ),
                autofocus: true,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () async => deleteReceiptAction(),
                ),
                TextButton(
                  child: const Text("No"),
                  onPressed: () async {
                    setState(() {
                      widget.reasonToDeleteTextController.text = "";
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
    );
  }

  Future<void> deleteReceiptAction() async {
    if (_isLoading) return;
    if (widget.reasonToDeleteTextController.text.trim() == "") {
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
      masterTransactionId: widget.studentFeeTransactionBean.masterTransactionId,
      comments: widget.reasonToDeleteTextController.text.trim(),
    );
    DeleteReceiptResponse deleteReceiptResponse = await deleteReceipt(deleteReceiptRequest);
    if (deleteReceiptResponse.httpStatus != "OK" || deleteReceiptResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      widget.superSetState();
    }
    setState(() => _isLoading = false);
  }

  InputDecorator studentDetailsWidget() {
    return InputDecorator(
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
        // "${filteredStudentFeeDetailsBeanList.where((eachStudent) => eachStudent.studentId == e.studentId).firstOrNull?.rollNumber}. ${e.studentName ?? " "}",
        widget.studentName ?? "-",
      ),
    );
  }

  InputDecorator sectionDetailsWidget() {
    return InputDecorator(
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
          // e.sectionName ?? studentFeeDetailsBeans.where((e1) => e.studentId == e1.studentId).firstOrNull?.sectionName ?? "",
          widget.sectionName ?? "-",
        ),
      ),
    );
  }

  List<Widget> childTransactionsWidget() {
    // return (e.studentFeeChildTransactionList ?? []).map((e) => Container()).toList();
    List<Widget> childTxnWidgets = [];
    List<FeeTypeTxn> feeTypeTxns = [];
    for (StudentFeeChildTransactionBean eachChildTxn in widget.childTransactions) {
      if (eachChildTxn.customFeeTypeId == null) {
        feeTypeTxns.add(FeeTypeTxn(eachChildTxn.feeTypeId, eachChildTxn.feeType, null, null, [], eachChildTxn.termComponents ?? []));
      } else {
        if (!feeTypeTxns.map((e) => e.feeTypeId).contains(eachChildTxn.feeTypeId)) {
          feeTypeTxns.add(FeeTypeTxn(eachChildTxn.feeTypeId, eachChildTxn.feeType, null, null, [], eachChildTxn.termComponents ?? []));
        }
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in widget.childTransactions) {
      if (eachChildTxn.customFeeTypeId != null && eachChildTxn.customFeeTypeId != 0) {
        feeTypeTxns.where((e) => e.feeTypeId == eachChildTxn.feeTypeId).forEach((eachFeeTypeTxn) {
          eachFeeTypeTxn.customFeeTypeTxns?.add(CustomFeeTypeTxn(eachChildTxn.customFeeTypeId, eachChildTxn.customFeeType, eachChildTxn.feePaidAmount,
              eachFeeTypeTxn.transactionId, eachChildTxn.termComponents ?? []));
        });
      }
    }
    for (StudentFeeChildTransactionBean eachChildTxn in widget.busFeeTransactions) {
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
        eachFeeTypeTxn.feePaidAmount = widget.childTransactions
            .where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId)
            .map((e) => e.feePaidAmount)
            .reduce((c1, c2) => (c1 ?? 0) + (c2 ?? 0));
        eachFeeTypeTxn.transactionId =
            widget.childTransactions.where((e) => e.feeTypeId == eachFeeTypeTxn.feeTypeId).map((e) => e.transactionId).firstOrNull;
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
                !widget.isTermWise || (eachFeeTypeTxn.termComponents).isEmpty
                    ? Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-")
                    : const Text(""),
              ],
            ),
          ),
        );
        if (widget.isTermWise && (eachFeeTypeTxn.termComponents).isNotEmpty) {
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
                !widget.isTermWise || (eachCustomFeeTypeTxn.termComponents).isEmpty
                    ? Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((eachCustomFeeTypeTxn.feePaidAmount ?? 0) / 100.0)} /-")
                    : const Text(""),
              ],
            ),
          ));
          if (widget.isTermWise && (eachCustomFeeTypeTxn.termComponents).isNotEmpty) {
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

  Padding receiptDateWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: _isEditMode
          ? GestureDetector(
              onTap: () async {
                HapticFeedback.vibrate();
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: convertYYYYMMDDFormatToDateTime(widget.studentFeeTransactionBean.transactionDate),
                  firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  helpText: "Select a date",
                );
                if (_newDate == null) return;
                setState(() {
                  widget.studentFeeTransactionBean.transactionDate = convertDateTimeToYYYYMMDDFormat(_newDate);
                });
              },
              child: ClayButton(
                surfaceColor: clayContainerColor(context),
                parentColor: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Text(
                    "Date:${MediaQuery.of(context).orientation == Orientation.landscape ? " " : "\n"}${convertDateToDDMMMYYY(widget.studentFeeTransactionBean.transactionDate)}",
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            )
          : Tooltip(
              message: convertDateToDDMMMYYYEEEE(widget.studentFeeTransactionBean.transactionDate),
              child: Text(
                "Date:${MediaQuery.of(context).orientation == Orientation.landscape ? " " : "\n"}${convertDateToDDMMMYYY(widget.studentFeeTransactionBean.transactionDate)}",
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
    );
  }

  Row receiptTotalWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Total: $INR_SYMBOL ${doubleToStringAsFixedForINR((widget.studentFeeTransactionBean.transactionAmount ?? 0) / 100.0)} /-",
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
