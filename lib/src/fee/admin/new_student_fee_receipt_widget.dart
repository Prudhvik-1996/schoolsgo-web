import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

import 'admin_student_fee_management_screen.dart';

class NewStudentFeeReceiptWidget extends StatefulWidget {
  const NewStudentFeeReceiptWidget({
    Key? key,
    required this.context,
    required this.newReceipt,
    required this.studentProfiles,
    required this.sections,
    required this.schoolInfoBean,
    required this.feeTypesForSelectedSection,
    required this.setState,
  }) : super(key: key);

  final BuildContext context;
  final NewReceipt newReceipt;
  final List<StudentProfile> studentProfiles;
  final List<Section> sections;
  final SchoolInfoBean schoolInfoBean;
  final List<FeeType> feeTypesForSelectedSection;
  final Function setState;

  @override
  State<NewStudentFeeReceiptWidget> createState() => _NewStudentFeeReceiptWidgetState();
}

class _NewStudentFeeReceiptWidgetState extends State<NewStudentFeeReceiptWidget> {
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    if (widget.newReceipt.studentId!=null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (widget.newReceipt.studentId == null || widget.newReceipt.sectionId == null) {
      setState(() {
        widget.newReceipt.studentAnnualFeeBean = null;
      });
      return;
    }
    if (widget.newReceipt.studentAnnualFeeBean != null) return;
    setState(() {
      _isLoading = true;
    });
    GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest(
      schoolId: widget.schoolInfoBean.schoolId,
      sectionId: widget.newReceipt.sectionId,
      studentId: widget.newReceipt.studentId,
    ));
    if (getStudentWiseAnnualFeesResponse.httpStatus != "OK" || getStudentWiseAnnualFeesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        StudentWiseAnnualFeesBean eachAnnualFeeBean = getStudentWiseAnnualFeesResponse.studentWiseAnnualFeesBeanList!.map((e) => e!).toList().first;
        widget.newReceipt.studentAnnualFeeBean = StudentAnnualFeeBean(
          studentId: eachAnnualFeeBean.studentId,
          rollNumber: eachAnnualFeeBean.rollNumber,
          studentName: eachAnnualFeeBean.studentName,
          totalFee: eachAnnualFeeBean.actualFee,
          totalFeePaid: eachAnnualFeeBean.feePaid,
          walletBalance: eachAnnualFeeBean.studentWalletBalance,
          sectionId: eachAnnualFeeBean.sectionId,
          sectionName: eachAnnualFeeBean.sectionName,
          studentBusFeeBean: eachAnnualFeeBean.studentBusFeeBean,
          studentAnnualFeeTypeBeans: widget.feeTypesForSelectedSection
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
        );
        if (widget.newReceipt.feeToBePaidList.isEmpty) {
          widget.newReceipt.feeToBePaidList = (widget.newReceipt.studentAnnualFeeBean?.studentAnnualFeeTypeBeans ?? [])
              .map((eachFeeType) {
                if ((eachFeeType.studentAnnualCustomFeeTypeBeans ?? []).isEmpty) {
                  return [
                    FeeToBePaid(
                      feeTypeId: eachFeeType.feeTypeId,
                      feeType: eachFeeType.feeType,
                      customFeeTypeId: null,
                      customFeeType: null,
                      totalAmountToBePaid: eachFeeType.amount,
                      remainingAmountToBePaid: (eachFeeType.amount ?? 0) - (eachFeeType.amountPaid ?? 0),
                    )
                  ];
                } else {
                  return (eachFeeType.studentAnnualCustomFeeTypeBeans ?? [])
                      .map((eachCustomFeeType) => FeeToBePaid(
                            feeTypeId: eachFeeType.feeTypeId,
                            feeType: eachFeeType.feeType,
                            customFeeTypeId: eachCustomFeeType.customFeeTypeId,
                            customFeeType: eachCustomFeeType.customFeeType,
                            totalAmountToBePaid: eachCustomFeeType.amount,
                            remainingAmountToBePaid: (eachCustomFeeType.amount ?? 0) - (eachCustomFeeType.amountPaid ?? 0),
                          ))
                      .toList();
                }
              })
              .expand((i) => i)
              .toList();
        }
      });
      widget.setState(() {});
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return newFeeReceiptWidget();
  }

  Widget newFeeReceiptWidget() {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.all(10),
      child: Stack(
        children: [
          ClayContainer(
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 10,
            depth: 40,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "New Receipt",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      _deleteReceiptButton(),
                      const SizedBox(width: 15),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _receiptTextField(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _getDatePicker(),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _studentSearchableDropDown(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _sectionSearchableDropDown(),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...feeToBePaidBeans(),
                  const SizedBox(height: 10),
                  if (widget.newReceipt.studentId != null &&
                      ((widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.fare ?? 0) >
                          (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.feePaid ?? 0)))
                    buildBusFeePayableWidget(),
                  if (widget.newReceipt.studentId != null &&
                      ((widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.fare ?? 0) >
                          (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.feePaid ?? 0)))
                    const SizedBox(height: 10),
                  if (widget.newReceipt.studentId != null) totalFeePayingWidget(),
                  if (widget.newReceipt.studentId != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: buildModeOfPayment(),
                        ),
                        proceedToAddNew(),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }

  Widget totalFeePayingWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Expanded(
          child: Text("Total Fee Paying:"),
        ),
        Text(
          "$INR_SYMBOL ${doubleToStringAsFixedForINR(totalFeePaying() / 100)} /-",
        )
      ],
    );
  }

  int totalFeePaying() {
    return 100 *
        ((int.tryParse(widget.newReceipt.busFeePayingController.text) ?? 0) +
            (widget.newReceipt.feeToBePaidList.isEmpty
                ? 0
                : widget.newReceipt.feeToBePaidList.map((e) => int.tryParse(e.amountPayingController.text) ?? 0).reduce((a, b) => a + b)));
  }

  Widget proceedToAddNew() {
    if (widget.newReceipt.status == "active") return const SizedBox();
    return GestureDetector(
      onTap: () {
        if (totalFeePaying() == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fee Paying cannot be 0"),
            ),
          );
          return;
        }
        widget.newReceipt.busFeePaidAmount = (int.tryParse(widget.newReceipt.busFeePayingController.text) ?? 0) * 100;
        widget.newReceipt.subBeans = widget.newReceipt.feeToBePaidList
            .where((e) => (int.tryParse(e.amountPayingController.text) ?? 0) != 0)
            .map((e) => NewReceiptSubBean(
                  feeTypeId: e.feeTypeId,
                  customFeeTypeId: e.customFeeTypeId,
                  feePaying: (int.tryParse(e.amountPayingController.text) ?? 0) * 100,
                ))
            .toList();
        widget.newReceipt.status = "active";
        widget.setState(() {});
      },
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

  Widget buildBusFeePayableWidget() {
    return Row(
      children: [
        const SizedBox(width: 10),
        Checkbox(
          value: widget.newReceipt.isBusChecked,
          onChanged: (value) {
            widget.newReceipt.isBusChecked = value ?? false;
            if (widget.newReceipt.isBusChecked) {
              setState(() {
                widget.newReceipt.busFeePayingController.text =
                    "${((widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.fare ?? 0) - (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.feePaid ?? 0)) / 100}";
              });
            }
          },
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text("Bus Fee"),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          height: 40,
          child: InputDecorator(
            isFocused: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              label: Text(
                "$INR_SYMBOL ${doubleToStringAsFixedForINR(((widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.fare ?? 0) - (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.feePaid ?? 0)) / 100)} /-",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            child: TextField(
              enabled: (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.fare ?? 0) -
                      (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.feePaid ?? 0) !=
                  0,
              onTap: () {
                widget.newReceipt.busFeePayingController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: widget.newReceipt.busFeePayingController.text.length,
                );
              },
              controller: widget.newReceipt.busFeePayingController,
              keyboardType: TextInputType.number,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Amount",
              ),
              onChanged: (String txt) {
                if (txt.isNotEmpty) {
                  setState(() {
                    widget.newReceipt.isBusChecked = true;
                  });
                } else {
                  setState(() {
                    widget.newReceipt.isBusChecked = false;
                  });
                }
              },
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    if (newValue.text == "") return newValue;
                    final text = newValue.text;
                    double payingAmount = double.parse(text);
                    if (payingAmount * 100 >
                        (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.fare ?? 0) -
                            (widget.newReceipt.studentAnnualFeeBean?.studentBusFeeBean?.feePaid ?? 0)) {
                      return oldValue;
                    }
                    return newValue;
                  } catch (e) {
                    return oldValue;
                  }
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  List<Widget> feeToBePaidBeans() {
    if (widget.newReceipt.studentAnnualFeeBean == null) {
      return [];
    }
    List<Widget> feePayingWidgets = [];
    for (var eachFeeType in widget.feeTypesForSelectedSection) {
      if ((eachFeeType.customFeeTypesList ?? []).isEmpty) {
        feePayingWidgets.addAll(
          widget.newReceipt.feeToBePaidList
              .where((e) => e.feeTypeId == eachFeeType.feeTypeId && e.customFeeTypeId == null)
              .map((e) => [
                    feeToBePaidTextField(e),
                    const SizedBox(height: 10),
                  ])
              .expand((i) => i),
        );
      } else {
        feePayingWidgets.addAll([Text(eachFeeType.feeType ?? ""), const SizedBox(height: 10)]);
        (eachFeeType.customFeeTypesList ?? []).where((e) => e != null).map((e) => e!).forEach((eachCustomFeeType) {
          feePayingWidgets.addAll(widget.newReceipt.feeToBePaidList
              .where((e) => e.feeTypeId == eachFeeType.feeTypeId && e.customFeeTypeId == eachCustomFeeType.customFeeTypeId)
              .map((e) => [feeToBePaidTextField(e), const SizedBox(height: 10)])
              .expand((i) => i));
        });
      }
    }
    return feePayingWidgets;
  }

  Row feeToBePaidTextField(FeeToBePaid e) {
    return Row(
      children: [
        const SizedBox(width: 10),
        if (e.customFeeTypeId != null) const SizedBox(width: 10),
        if (e.customFeeTypeId != null) const CustomVerticalDivider(),
        if (e.customFeeTypeId != null) const SizedBox(width: 10),
        Checkbox(
          value: e.isChecked,
          onChanged: (value) {
            setState(() {
              e.isChecked = value ?? false;
              if (e.isChecked) {
                e.amountPayingController.text = "${(e.remainingAmountToBePaid ?? 0) / 100}";
              }
            });
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(e.customFeeType ?? e.feeType ?? "-"),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          height: 40,
          child: InputDecorator(
            isFocused: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              label: Text(
                "$INR_SYMBOL ${doubleToStringAsFixedForINR((e.remainingAmountToBePaid ?? 0) / 100)} /-",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            child: TextField(
              enabled: e.remainingAmountToBePaid != 0,
              onTap: () {
                e.amountPayingController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: e.amountPayingController.text.length,
                );
              },
              controller: e.amountPayingController,
              keyboardType: TextInputType.number,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Amount",
              ),
              onChanged: (String txt) {
                if (txt.isNotEmpty) {
                  setState(() {
                    e.isChecked = true;
                  });
                } else {
                  setState(() {
                    e.isChecked = false;
                  });
                }
              },
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    if (newValue.text == "") return newValue;
                    final text = newValue.text;
                    double payingAmount = double.parse(text);
                    if (payingAmount * 100 > (e.remainingAmountToBePaid ?? 0)) {
                      return oldValue;
                    }
                    return newValue;
                  } catch (e) {
                    return oldValue;
                  }
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  GestureDetector _deleteReceiptButton() {
    return GestureDetector(
      onTap: () async {
        await showDialog<void>(
          context: widget.context,
          builder: (currentContext) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: const Text("Fee Receipts"),
                content: const Text("Are you sure you want to delete the receipt?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => widget.newReceipt.status = "deleted");
                      widget.setState(() {});
                    },
                    child: const Text("YES"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("NO"),
                  ),
                ],
              );
            });
          },
        );
      },
      child: ClayButton(
        color: clayContainerColor(context),
        borderRadius: 100,
        spread: 2,
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Center(
            child: Icon(Icons.delete, color: Colors.red),
          ),
        ),
      ),
    );
  }

  SizedBox _receiptTextField() {
    return SizedBox(
      width: 50,
      height: 40,
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
            borderSide: BorderSide(color: Colors.blue),
          ),
          label: Text(
            "Receipt",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        child: TextField(
          controller: widget.newReceipt.receiptNumberController,
          keyboardType: TextInputType.number,
          maxLines: 1,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 12),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Receipt No.",
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
          onChanged: (String e) {
            widget.newReceipt.receiptNumber = int.tryParse(e);
          },
        ),
      ),
    );
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              setState(() =>
                  widget.newReceipt.date = convertEpochToDateTime(widget.newReceipt.date!).subtract(const Duration(days: 1)).microsecondsSinceEpoch);
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 20,
              width: 20,
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_left),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: convertEpochToDateTime(widget.newReceipt.date!),
                  firstDate: DateTime(2021),
                  lastDate: DateTime.now(),
                  helpText: "Pick  date to mark attendance",
                );
                setState(() {
                  widget.newReceipt.date = _newDate?.millisecondsSinceEpoch ?? widget.newReceipt.date;
                });
              },
              child: ClayButton(
                color: clayContainerColor(context),
                spread: 1,
                borderRadius: 10,
                depth: 40,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            convertDateTimeToDDMMYYYYFormat(convertEpochToDateTime(widget.newReceipt.date!)),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () async {
              setState(
                  () => widget.newReceipt.date = convertEpochToDateTime(widget.newReceipt.date!).add(const Duration(days: 1)).microsecondsSinceEpoch);
            },
            child: ClayButton(
              color: clayContainerColor(context),
              height: 20,
              width: 20,
              spread: 1,
              borderRadius: 10,
              depth: 40,
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(Icons.arrow_right),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentSearchableDropDown() {
    return InputDecorator(
      isFocused: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
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
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<StudentProfile>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: widget.newReceipt.studentId == null
              ? null
              : widget.studentProfiles.where((e) => e.studentId == widget.newReceipt.studentId).firstOrNull,
          items: widget.studentProfiles.where((e) => widget.newReceipt.sectionId == null || widget.newReceipt.sectionId == e.sectionId).toList(),
          itemAsString: (StudentProfile? student) {
            return student == null
                ? ""
                : [
                      ((student.rollNumber ?? "") == "" ? "" : student.rollNumber! + "."),
                      student.studentFirstName ?? "",
                      student.studentMiddleName ?? "",
                      student.studentLastName ?? ""
                    ].where((e) => e != "").join(" ").trim() +
                    " - ${student.sectionName}";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, StudentProfile? student) {
            return buildStudentWidget(student ?? StudentProfile());
          },
          onChanged: (StudentProfile? student) {
            setState(() {
              widget.newReceipt.sectionId = student?.sectionId;
              widget.newReceipt.studentId = student?.studentId;
            });
            _loadData();
          },
          showClearButton: false,
          compareFn: (item, selectedItem) => item?.studentId == selectedItem?.studentId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (StudentProfile? student, String? key) {
            return ([
                      ((student?.rollNumber ?? "") == "" ? "" : student!.rollNumber! + "."),
                      student?.studentFirstName ?? "",
                      student?.studentMiddleName ?? "",
                      student?.studentLastName ?? ""
                    ].where((e) => e != "").join(" ") +
                    " - ${student?.sectionName ?? ""}")
                .toLowerCase()
                .trim()
                .contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }

  Widget buildStudentWidget(StudentProfile e) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListTile(
        leading: MediaQuery.of(context).orientation == Orientation.portrait
            ? null
            : Container(
                width: 50,
                padding: const EdgeInsets.all(5),
                child: e.studentPhotoUrl == null
                    ? Image.asset(
                        "assets/images/avatar.png",
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        e.studentPhotoUrl!,
                        fit: BoxFit.contain,
                      ),
              ),
        title: AutoSizeText(
          ((e.rollNumber ?? "") == "" ? "" : e.rollNumber! + ". ") +
              ([e.studentFirstName ?? "", e.studentMiddleName ?? "", e.studentLastName ?? ""].where((e) => e != "").join(" ") +
                      " - ${e.sectionName ?? ""}")
                  .trim(),
          style: const TextStyle(
            fontSize: 14,
          ),
          overflow: TextOverflow.visible,
          maxLines: 3,
          minFontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionSearchableDropDown() {
    return InputDecorator(
      isFocused: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(15, 0, 5, 0),
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
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: DropdownSearch<Section>(
          mode: MediaQuery.of(context).orientation == Orientation.portrait ? Mode.BOTTOM_SHEET : Mode.MENU,
          selectedItem: widget.sections.where((e) => e.sectionId == widget.newReceipt.sectionId).firstOrNull,
          items: widget.sections,
          itemAsString: (Section? section) {
            return section == null ? "" : section.sectionName ?? "-";
          },
          showSearchBox: true,
          dropdownBuilder: (BuildContext context, Section? section) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(widget.sections.where((e) => e.sectionId == widget.newReceipt.sectionId).firstOrNull?.sectionName ?? "-"),
            );
          },
          onChanged: (Section? section) {
            setState(() {
              widget.newReceipt.sectionId = section?.sectionId;
              widget.newReceipt.studentId = null;
            });
            _loadData();
          },
          showClearButton: false,
          compareFn: (item, selectedItem) => item?.sectionId == selectedItem?.sectionId,
          dropdownSearchDecoration: const InputDecoration(border: InputBorder.none),
          filterFn: (Section? section, String? key) {
            return (section?.sectionName ?? "").toLowerCase().contains(key!.toLowerCase());
          },
        ),
      ),
    );
  }

  Container buildModeOfPayment() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        emboss: true,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Expanded(child: Text("Mode Of Payment:")),
              const SizedBox(width: 20),
              DropdownButton<String>(
                value: widget.newReceipt.modeOfPayment,
                items: [
                  ModeOfPayment.CASH,
                  ModeOfPayment.PHONEPE,
                  ModeOfPayment.GPAY,
                  ModeOfPayment.PAYTM,
                  ModeOfPayment.NETBANKING,
                  ModeOfPayment.CHEQUE
                ]
                    .map((e) => DropdownMenuItem<String>(
                          value: e.name,
                          child: Text(e.description),
                          onTap: () {
                            setState(() {
                              widget.newReceipt.modeOfPayment = e.name;
                            });
                          },
                        ))
                    .toList(),
                onChanged: (String? e) {
                  setState(() {
                    widget.newReceipt.modeOfPayment = e ?? ModeOfPayment.CASH.name;
                  });
                },
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
