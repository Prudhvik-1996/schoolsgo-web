import 'dart:convert';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/custom_vertical_divider.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/student_annual_fee_bean.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class GetStudentFeeReceiptsRequest {
/*
{
  "customFeeTypeIds": [
    0
  ],
  "feeTypeIds": [
    0
  ],
  "schoolId": 0,
  "sectionIds": [
    0
  ],
  "studentIds": [
    0
  ]
}
*/

  List<int?>? customFeeTypeIds;
  List<int?>? feeTypeIds;
  int? schoolId;
  List<int?>? sectionIds;
  List<int?>? studentIds;
  List<int?>? transactionIds;
  Map<String, dynamic> __origJson = {};

  GetStudentFeeReceiptsRequest({
    this.customFeeTypeIds,
    this.feeTypeIds,
    this.schoolId,
    this.sectionIds,
    this.studentIds,
    this.transactionIds,
  });

  GetStudentFeeReceiptsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['customFeeTypeIds'] != null) {
      final v = json['customFeeTypeIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      customFeeTypeIds = arr0;
    }
    if (json['feeTypeIds'] != null) {
      final v = json['feeTypeIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      feeTypeIds = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    if (json['sectionIds'] != null) {
      final v = json['sectionIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      sectionIds = arr0;
    }
    if (json['studentIds'] != null) {
      final v = json['studentIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      studentIds = arr0;
    }
    if (json['transactionIds'] != null) {
      final v = json['transactionIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      studentIds = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (customFeeTypeIds != null) {
      final v = customFeeTypeIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['customFeeTypeIds'] = arr0;
    }
    if (feeTypeIds != null) {
      final v = feeTypeIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['feeTypeIds'] = arr0;
    }
    data['schoolId'] = schoolId;
    if (sectionIds != null) {
      final v = sectionIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['sectionIds'] = arr0;
    }
    if (studentIds != null) {
      final v = studentIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['studentIds'] = arr0;
    }
    if (transactionIds != null) {
      final v = transactionIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['transactionIds'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TermWiseFeeComponent {
/*
{
  "termId": 0,
  "termName": "string",
  "termNumber": 0,
  "termWiseAmountPaidForTheReceipt": 0
}
*/

  int? termId;
  String? termName;
  int? termNumber;
  int? termWiseAmountPaidForTheReceipt;
  Map<String, dynamic> __origJson = {};

  TermWiseFeeComponent({
    this.termId,
    this.termName,
    this.termNumber,
    this.termWiseAmountPaidForTheReceipt,
  });

  TermWiseFeeComponent.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    termNumber = json['termNumber']?.toInt();
    termWiseAmountPaidForTheReceipt = json['termWiseAmountPaidForTheReceipt']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['termId'] = termId;
    data['termName'] = termName;
    data['termNumber'] = termNumber;
    data['termWiseAmountPaidForTheReceipt'] = termWiseAmountPaidForTheReceipt;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  Widget widget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),
          const CustomVerticalDivider(color: Colors.amber),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(termName ?? "-"),
          ),
          Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((termWiseAmountPaidForTheReceipt ?? 0) / 100.0)} /-")
        ],
      ),
    );
  }
}

class CustomFeeTypeOfReceipt {
/*
{
  "amountPaidForTheReceipt": 0,
  "customFeeType": "string",
  "customFeeTypeId": 0,
  "termWiseFeeComponents": [
    {
      "termId": 0,
      "termName": "string",
      "termNumber": 0,
      "termWiseAmountPaidForTheReceipt": 0
    }
  ]
}
*/

  int? amountPaidForTheReceipt;
  String? customFeeType;
  int? customFeeTypeId;
  List<TermWiseFeeComponent?>? termWiseFeeComponents;
  Map<String, dynamic> __origJson = {};

  CustomFeeTypeOfReceipt({
    this.amountPaidForTheReceipt,
    this.customFeeType,
    this.customFeeTypeId,
    this.termWiseFeeComponents,
  });

  CustomFeeTypeOfReceipt.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amountPaidForTheReceipt = json['amountPaidForTheReceipt']?.toInt();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    if (json['termWiseFeeComponents'] != null) {
      final v = json['termWiseFeeComponents'];
      final arr0 = <TermWiseFeeComponent>[];
      v.forEach((v) {
        arr0.add(TermWiseFeeComponent.fromJson(v));
      });
      termWiseFeeComponents = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amountPaidForTheReceipt'] = amountPaidForTheReceipt;
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    if (termWiseFeeComponents != null) {
      final v = termWiseFeeComponents;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['termWiseFeeComponents'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  Widget widget({bool isTermWise = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 5,
            ),
            const CustomVerticalDivider(),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(customFeeType ?? "-"),
            ),
            !isTermWise || (termWiseFeeComponents ?? []).isEmpty
                ? Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((amountPaidForTheReceipt ?? 0) / 100.0)} /-")
                : const Text(""),
          ],
        ),
        if (isTermWise) const SizedBox(height: 10),
        if (isTermWise) ...(termWiseFeeComponents ?? []).map((e) => e == null ? Container() : e.widget()),
      ],
    );
  }
}

class FeeTypeOfReceipt {
/*
{
  "amountPaidForTheReceipt": 0,
  "customFeeTypes": [
    {
      "amountPaidForTheReceipt": 0,
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "termWiseFeeComponents": [
        {
          "termId": 0,
          "termName": "string",
          "termNumber": 0,
          "termWiseAmountPaidForTheReceipt": 0
        }
      ]
    }
  ],
  "feeType": "string",
  "feeTypeId": 0,
  "termWiseFeeComponents": [
    {
      "termId": 0,
      "termName": "string",
      "termNumber": 0,
      "termWiseAmountPaidForTheReceipt": 0
    }
  ]
}
*/

  int? amountPaidForTheReceipt;
  List<CustomFeeTypeOfReceipt?>? customFeeTypes;
  String? feeType;
  int? feeTypeId;
  List<TermWiseFeeComponent?>? termWiseFeeComponents;
  Map<String, dynamic> __origJson = {};

  FeeTypeOfReceipt({
    this.amountPaidForTheReceipt,
    this.customFeeTypes,
    this.feeType,
    this.feeTypeId,
    this.termWiseFeeComponents,
  });

  FeeTypeOfReceipt.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amountPaidForTheReceipt = json['amountPaidForTheReceipt']?.toInt();
    if (json['customFeeTypes'] != null) {
      final v = json['customFeeTypes'];
      final arr0 = <CustomFeeTypeOfReceipt>[];
      v.forEach((v) {
        arr0.add(CustomFeeTypeOfReceipt.fromJson(v));
      });
      customFeeTypes = arr0;
    }
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    if (json['termWiseFeeComponents'] != null) {
      final v = json['termWiseFeeComponents'];
      final arr0 = <TermWiseFeeComponent>[];
      v.forEach((v) {
        arr0.add(TermWiseFeeComponent.fromJson(v));
      });
      termWiseFeeComponents = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amountPaidForTheReceipt'] = amountPaidForTheReceipt;
    if (customFeeTypes != null) {
      final v = customFeeTypes;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['customFeeTypes'] = arr0;
    }
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    if (termWiseFeeComponents != null) {
      final v = termWiseFeeComponents;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['termWiseFeeComponents'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  Widget widget(BuildContext context, bool isTermWise) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(feeType ?? "-"),
              ),
              (!isTermWise || (termWiseFeeComponents ?? []).isEmpty) && (customFeeTypes ?? []).isEmpty
                  ? Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((amountPaidForTheReceipt ?? 0) / 100.0)} /-")
                  : const Text(""),
            ],
          ),
          const SizedBox(height: 10),
          if (isTermWise && (customFeeTypes ?? []).isEmpty) ...(termWiseFeeComponents ?? []).map((e) => e == null ? Container() : e.widget()),
          if (isTermWise && (customFeeTypes ?? []).isEmpty) const SizedBox(height: 10),
          if ((customFeeTypes ?? []).isNotEmpty) ...(customFeeTypes ?? []).map((e) => e == null ? Container() : e.widget(isTermWise: isTermWise)),
          if ((customFeeTypes ?? []).isNotEmpty) const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class StudentFeeReceipt {
/*
{
  "busFeePaid": 0,
  "feeTypes": [
    {
      "amountPaidForTheReceipt": 0,
      "customFeeTypes": [
        {
          "amountPaidForTheReceipt": 0,
          "customFeeType": "string",
          "customFeeTypeId": 0,
          "termWiseFeeComponents": [
            {
              "termId": 0,
              "termName": "string",
              "termNumber": 0,
              "termWiseAmountPaidForTheReceipt": 0
            }
          ]
        }
      ],
      "feeType": "string",
      "feeTypeId": 0,
      "termWiseFeeComponents": [
        {
          "termId": 0,
          "termName": "string",
          "termNumber": 0,
          "termWiseAmountPaidForTheReceipt": 0
        }
      ]
    }
  ],
  "modeOfPayment": "CASH",
  "receiptNumber": 0,
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "studentId": 0,
  "studentName": "string",
  "transactionDate": "string",
  "transactionId": 0
}
*/

  int? busFeePaid;
  List<FeeTypeOfReceipt?>? feeTypes;
  String? modeOfPayment;
  int? receiptNumber;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  int? studentId;
  String? studentName;
  String? gaurdianName;
  String? transactionDate;
  int? transactionId;
  String? comments;
  String? status;
  int? noOfTimesNotified;
  Map<String, dynamic> __origJson = {};

  TextEditingController newReceiptNumberController = TextEditingController();
  TextEditingController reasonToDeleteTextController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  StudentFeeReceipt({
    this.busFeePaid,
    this.feeTypes,
    this.modeOfPayment,
    this.receiptNumber,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.studentId,
    this.studentName,
    this.gaurdianName,
    this.transactionDate,
    this.transactionId,
    this.comments,
    this.status,
    this.noOfTimesNotified,
  }) {
    newReceiptNumberController.text = "${receiptNumber ?? ""}";
  }

  StudentFeeReceipt.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    busFeePaid = json['busFeePaid']?.toInt();
    if (json['feeTypes'] != null) {
      final v = json['feeTypes'];
      final arr0 = <FeeTypeOfReceipt>[];
      v.forEach((v) {
        arr0.add(FeeTypeOfReceipt.fromJson(v));
      });
      feeTypes = arr0;
    }
    modeOfPayment = json['modeOfPayment']?.toString();
    receiptNumber = json['receiptNumber']?.toInt();
    newReceiptNumberController.text = "${receiptNumber ?? ""}";
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    gaurdianName = json['gaurdianName']?.toString();
    transactionDate = json['transactionDate']?.toString();
    transactionId = json['transactionId']?.toInt();
    comments = json['comments']?.toString();
    status = json['status']?.toString();
    noOfTimesNotified = json['noOfTimesNotified']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['busFeePaid'] = busFeePaid;
    if (feeTypes != null) {
      final v = feeTypes;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['feeTypes'] = arr0;
    }
    data['modeOfPayment'] = modeOfPayment;
    data['receiptNumber'] = receiptNumber;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['gaurdianName'] = gaurdianName;
    data['transactionDate'] = transactionDate;
    data['transactionId'] = transactionId;
    data['comments'] = comments;
    data['status'] = status;
    data['noOfTimesNotified'] = noOfTimesNotified;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  bool isLoading = false;
  bool isEditMode = false;

  Widget widget(
    BuildContext context, {
    int? adminId,
    bool isTermWise = false,
    Function? setState,
    Function? reload,
    bool canSendSms = false,
    Function? sendSms,
    Function(int?)? sendReceiptSms,
    Function(int?)? makePdf,
    Function(String?)? updateModeOfPayment,
    RouteStopWiseStudent? routeStopWiseStudent,
  }) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 10, MediaQuery.of(context).size.width / 4, 10)
          : const EdgeInsets.all(10),
      child: AbsorbPointer(
        absorbing: isLoading || status == "deleted",
        child: ClayContainer(
          surfaceColor: status == "deleted" ? Colors.brown : clayContainerColor(context),
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
                        Expanded(child: receiptNumberWidget(context)),
                        const SizedBox(width: 10),
                        receiptDateWidget(context, setState),
                        const SizedBox(width: 10),
                        if (status != "deleted" && makePdf != null) printReceiptButton(context, makePdf),
                        if (status != "deleted" && makePdf != null) const SizedBox(width: 5),
                        if (adminId != null && canSendSms) noOfTimesNotifiedWidget(context, sendReceiptSms),
                        if (adminId != null && canSendSms) const SizedBox(width: 5),
                        if (status != "deleted" && adminId != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              editReceiptButton(context, setState, reload, adminId: adminId),
                              const SizedBox(width: 5),
                              deleteReceiptButton(context, setState, reload, adminId: adminId),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: sectionDetailsWidget(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    guardianNameWidget(),
                    const SizedBox(height: 10),
                    if ((feeTypes ?? []).isNotEmpty) ...feeTypes!.map((e) => e == null ? Container() : e.widget(context, isTermWise)),
                    const SizedBox(height: 10),
                    if ((busFeePaid ?? 0) != 0) busFeePaidWidget(routeStopWiseStudent),
                    if ((busFeePaid ?? 0) != 0) const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: receiptTotalWidget(updateModeOfPayment),
                    ),
                    if (!isEditMode && comments != null) const SizedBox(height: 10),
                    commentsWidget(),
                    const SizedBox(height: 10),
                  ],
                ),
                if (isLoading)
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
      ),
    );
  }

  Widget noOfTimesNotifiedWidget(BuildContext context, Function(int?)? sendReceiptSms) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext dialogueContext) {
                  return AlertDialog(
                    title: const Text('Send receipt SMS'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () async {
                          if (sendReceiptSms != null) sendReceiptSms(transactionId);
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text("No"),
                        onPressed: () async {
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
                      Icons.notifications_active,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if ((noOfTimesNotified ?? 0) != 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(100),
              ),
              height: 12,
              width: 12,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  (noOfTimesNotified ?? 0).toString(),
                  style: const TextStyle(
                    color: Colors.white, fontSize: 10, // Adjust the font size as needed
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget commentsWidget() => !isEditMode && comments == null
      ? Container()
      : Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: !isEditMode
                  ? SelectableText("Comments: ${comments ?? "-"}")
                  : TextFormField(
                      initialValue: comments,
                      onChanged: (String newValue) => comments = newValue,
                    ),
            ),
            const SizedBox(width: 10),
          ],
        );

  int getTotalAmountForReceipt() {
    int busFee = busFeePaid ?? 0;
    int feeTypesAmount = (feeTypes ?? []).isEmpty ? 0 : (feeTypes ?? []).map((e) => e?.amountPaidForTheReceipt ?? 0).sum;
    List<int> customFeeTypeAmount =
        (feeTypes ?? []).map((e) => e?.customFeeTypes ?? []).expand((i) => i).map((e) => e?.amountPaidForTheReceipt ?? 0).toList();
    int customFeeTypesAmount = customFeeTypeAmount.isEmpty ? 0 : customFeeTypeAmount.sum;
    return busFee + feeTypesAmount + customFeeTypesAmount;
  }

  Row receiptTotalWidget(Function(String? e)? updateModeOfPayment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isEditMode) Expanded(child: Text(modeOfPayment ?? "")),
        if (isEditMode)
          DropdownButton<String>(
            value: modeOfPayment,
            items: ModeOfPayment.values
                .map((e) => DropdownMenuItem<String>(
                      value: e.name,
                      child: Text(e.description),
                      onTap: () {
                        if (updateModeOfPayment != null) updateModeOfPayment(e.name);
                      },
                    ))
                .toList(),
            onChanged: (String? e) {
              if (updateModeOfPayment != null) updateModeOfPayment(e ?? ModeOfPayment.CASH.name);
            },
          ),
        if (isEditMode) const Expanded(child: Text("")),
        const SizedBox(width: 10),
        Text(
          "Total: $INR_SYMBOL ${doubleToStringAsFixedForINR((getTotalAmountForReceipt()) / 100.0)} /-",
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Row busFeePaidWidget(RouteStopWiseStudent? routeStopWiseStudent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bus Fee"),
              if (routeStopWiseStudent != null) const SizedBox(height: 5),
              if (routeStopWiseStudent != null) Text("[${routeStopWiseStudent.busStopName ?? " - "} - ${routeStopWiseStudent.routeName ?? " - "}]")
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text("$INR_SYMBOL ${doubleToStringAsFixedForINR((busFeePaid ?? 0) / 100.0)} /-"),
        const SizedBox(width: 10),
      ],
    );
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
        studentName ?? "-",
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
          sectionName ?? "-",
        ),
      ),
    );
  }

  Future<void> deleteReceiptAction(BuildContext context, Function? setState, Function? reload, {int? adminId}) async {
    if (isLoading) return;
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
    isLoading = true;
    if (setState != null) setState(() {});
    DeleteReceiptRequest deleteReceiptRequest = DeleteReceiptRequest(
      schoolId: schoolId,
      agentId: adminId,
      masterTransactionId: transactionId,
      comments: reasonToDeleteTextController.text.trim(),
    );
    DeleteReceiptResponse deleteReceiptResponse = await deleteReceipt(deleteReceiptRequest);
    if (deleteReceiptResponse.httpStatus != "OK" || deleteReceiptResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      if (reload != null) reload();
    }
    isLoading = false;
    isEditMode = false;
    if (setState != null) setState(() {});
  }

  Widget deleteReceiptButton(BuildContext context, Function? setState, Function? reload, {int? adminId}) {
    return GestureDetector(
      onTap: () async {
        await showDialog(
          context: context,
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
                  onPressed: () async => deleteReceiptAction(context, setState, reload, adminId: adminId),
                ),
                TextButton(
                  child: const Text("No"),
                  onPressed: () async {
                    reasonToDeleteTextController.text = "";
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

  Future<void> updateReceiptAction(BuildContext context, Function? setState, Function? reload, {int? adminId}) async {
    if (isLoading) return;
    Navigator.pop(context);
    isLoading = true;
    if (setState != null) setState(() {});
    if (receiptNumber != StudentFeeReceipt.fromJson(origJson()).receiptNumber ||
        transactionDate != StudentFeeReceipt.fromJson(origJson()).transactionDate ||
        comments != StudentFeeReceipt.fromJson(origJson()).comments ||
        modeOfPayment != StudentFeeReceipt.fromJson(origJson()).modeOfPayment) {
      UpdateReceiptResponse updateReceiptResponse = await updateReceipt(UpdateReceiptRequest(
        transactionId: transactionId,
        receiptId: receiptNumber,
        modeOfPayment: modeOfPayment,
        comments: comments,
        date: transactionDate,
        agent: adminId,
        schoolId: schoolId,
      ));
      if (updateReceiptResponse.httpStatus != "OK" || updateReceiptResponse.responseStatus != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong! Try again later.."),
          ),
        );
        return;
      }
    } else {
      if (reload != null) reload();
    }
    isLoading = false;
    isEditMode = false;
    if (setState != null) setState(() {});
  }

  Widget editReceiptButton(BuildContext context, Function? setState, Function? reload, {int? adminId}) {
    return GestureDetector(
      onTap: () async {
        if (isLoading) return;
        if (isEditMode) {
          await showDialog(
            context: context,
            builder: (BuildContext dialogueContext) {
              return AlertDialog(
                title: const Text('Are you sure you want to update the receipt?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () async => updateReceiptAction(context, setState, reload, adminId: adminId),
                  ),
                  TextButton(
                    child: const Text("No"),
                    onPressed: () async {
                      Navigator.pop(context);
                      isEditMode = false;
                      if (setState != null) setState(() {});
                    },
                  ),
                ],
              );
            },
          );
        } else {
          isEditMode = true;
          if (setState != null) setState(() {});
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
                isEditMode ? Icons.check : Icons.edit,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget guardianNameWidget() {
    if (studentId == null) return Container();
    if (gaurdianName == "") return Container();
    return Row(
      children: [
        const SizedBox(width: 10),
        const Text("Parent Name:", style: TextStyle(color: Colors.blue)),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(gaurdianName ?? "-"),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget printReceiptButton(BuildContext context, Function(int?) printReceiptAction) {
    return GestureDetector(
      onTap: () async {
        printReceiptAction(transactionId);
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
              child: Icon(Icons.print),
            ),
          ),
        ),
      ),
    );
  }

  Padding receiptDateWidget(BuildContext context, Function? setState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: isEditMode
          ? GestureDetector(
              onTap: () async {
                HapticFeedback.vibrate();
                DateTime? _newDate = await showDatePicker(
                  context: context,
                  initialDate: convertYYYYMMDDFormatToDateTime(transactionDate),
                  firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  helpText: "Select a date",
                );
                if (_newDate == null) return;
                _newDate = DateTime.fromMillisecondsSinceEpoch(_newDate.millisecondsSinceEpoch + 23400000);
                transactionDate = convertDateTimeToYYYYMMDDFormat(_newDate);
                if (setState != null) setState(() {});
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
                    (MediaQuery.of(context).orientation == Orientation.landscape ? "Date: " : "") + convertDateToDDMMMYYY(transactionDate),
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            )
          : Tooltip(
              message: convertDateToDDMMMYYYEEEE(transactionDate),
              child: Text(
                (MediaQuery.of(context).orientation == Orientation.landscape ? "Date: " : "") + convertDateToDDMMMYYY(transactionDate),
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
    );
  }

  Padding receiptNumberWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: isEditMode
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
                      receiptNumber = int.tryParse(value);
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
              "Receipt No. ${receiptNumber ?? ""}",
              textAlign: MediaQuery.of(context).orientation == Orientation.landscape ? TextAlign.start : TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
    );
  }
}

class GetStudentFeeReceiptsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "schoolId": 0,
  "schoolName": "string",
  "studentFeeReceipts": [
    {
      "busFeePaid": 0,
      "feeTypes": [
        {
          "amountPaidForTheReceipt": 0,
          "customFeeTypes": [
            {
              "amountPaidForTheReceipt": 0,
              "customFeeType": "string",
              "customFeeTypeId": 0,
              "termWiseFeeComponents": [
                {
                  "termId": 0,
                  "termName": "string",
                  "termNumber": 0,
                  "termWiseAmountPaidForTheReceipt": 0
                }
              ]
            }
          ],
          "feeType": "string",
          "feeTypeId": 0,
          "termWiseFeeComponents": [
            {
              "termId": 0,
              "termName": "string",
              "termNumber": 0,
              "termWiseAmountPaidForTheReceipt": 0
            }
          ]
        }
      ],
      "modeOfPayment": "CASH",
      "receiptNumber": 0,
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "studentId": 0,
      "studentName": "string",
      "transactionDate": "string",
      "transactionId": 0
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? schoolId;
  String? schoolName;
  List<StudentFeeReceipt?>? studentFeeReceipts;
  Map<String, dynamic> __origJson = {};

  GetStudentFeeReceiptsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.schoolId,
    this.schoolName,
    this.studentFeeReceipts,
  });

  GetStudentFeeReceiptsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    if (json['studentFeeReceipts'] != null) {
      final v = json['studentFeeReceipts'];
      final arr0 = <StudentFeeReceipt>[];
      v.forEach((v) {
        arr0.add(StudentFeeReceipt.fromJson(v));
      });
      studentFeeReceipts = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    if (studentFeeReceipts != null) {
      final v = studentFeeReceipts;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentFeeReceipts'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentFeeReceiptsResponse> getStudentFeeReceipts(GetStudentFeeReceiptsRequest getStudentFeeReceiptsRequest) async {
  debugPrint("Raising request to getStudentFeeReceipts with request ${jsonEncode(getStudentFeeReceiptsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_FEE_RECEIPTS;

  GetStudentFeeReceiptsResponse getStudentFeeReceiptsResponse = await HttpUtils.post(
    _url,
    getStudentFeeReceiptsRequest.toJson(),
    GetStudentFeeReceiptsResponse.fromJson,
  );

  debugPrint("GetStudentFeeReceiptsResponse ${getStudentFeeReceiptsResponse.toJson()}");
  return getStudentFeeReceiptsResponse;
}

class NewReceiptSubBean {
/*
{
  "customFeeTypeId": 0,
  "feePaying": 0,
  "feeTypeId": 0,
  "termId": 0
}
*/

  int? customFeeTypeId;
  int? feePaying;
  int? feeTypeId;
  Map<String, dynamic> __origJson = {};

  bool? isPayable;

  NewReceiptSubBean({
    this.customFeeTypeId,
    this.feePaying,
    this.feeTypeId,
    this.isPayable,
  });

  NewReceiptSubBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feePaying = json['feePaying']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feePaying'] = feePaying;
    data['feeTypeId'] = feeTypeId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class NewReceipt {
/*
{
  "agentId": 0,
  "date": 0,
  "receiptNumber": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subBeans": [
    {
      "customFeeTypeId": 0,
      "feePaying": 0,
      "feeTypeId": 0,
      "termId": 0
    }
  ]
}
*/

  int? agentId;
  int? date;
  int? receiptNumber;
  int? schoolId;
  int? sectionId;
  int? studentId;
  List<NewReceiptSubBean?>? subBeans;
  int? busFeePaidAmount;
  String? modeOfPayment;
  String? comments;
  Map<String, dynamic> __origJson = {};

  String status = "inactive";
  StudentAnnualFeeBean? studentAnnualFeeBean;
  List<FeeToBePaid> feeToBePaidList = [];

  bool isBusChecked = false;
  TextEditingController busFeePayingController = TextEditingController();

  TextEditingController commentsController = TextEditingController();

  NewReceipt({
    this.agentId,
    this.date,
    this.receiptNumber,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subBeans,
    this.busFeePaidAmount,
    this.modeOfPayment,
    this.comments,
  }) {
    receiptNumberController.text = "${receiptNumber ?? ""}";
    busFeePayingController.text = "${busFeePaidAmount ?? ""}";
    commentsController.text = comments ?? "";
  }

  NewReceipt.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    date = json['date']?.toInt();
    receiptNumber = json['receiptNumber']?.toInt();
    receiptNumberController.text = "${receiptNumber ?? ""}";
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    if (json['subBeans'] != null) {
      final v = json['subBeans'];
      final arr0 = <NewReceiptSubBean>[];
      v.forEach((v) {
        arr0.add(NewReceiptSubBean.fromJson(v));
      });
      subBeans = arr0;
    }
    busFeePaidAmount = json['busFeePaidAmount']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
    comments = json['comments']?.toString();
  }

  TextEditingController receiptNumberController = TextEditingController();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['date'] = date;
    data['receiptNumber'] = receiptNumber;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    if (subBeans != null) {
      final v = subBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['subBeans'] = arr0;
    }
    data['busFeePaidAmount'] = busFeePaidAmount;
    data['modeOfPayment'] = modeOfPayment;
    data['comments'] = comments;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class FeeToBePaid {
  int? feeTypeId;
  String? feeType;
  int? customFeeTypeId;
  String? customFeeType;
  int? totalAmountToBePaid;
  int? remainingAmountToBePaid;
  int? amountPaying;

  TextEditingController amountPayingController = TextEditingController();
  bool isChecked = false;

  FeeToBePaid({
    this.feeTypeId,
    this.feeType,
    this.customFeeTypeId,
    this.customFeeType,
    this.totalAmountToBePaid,
    this.remainingAmountToBePaid,
    this.amountPaying,
  }) {
    amountPayingController.text = "${amountPaying ?? ""}";
  }

  FeeToBePaid replicateWithZeroFeePaying() {
    return FeeToBePaid(
      feeTypeId: feeTypeId,
      feeType: feeType,
      customFeeTypeId: customFeeTypeId,
      customFeeType: customFeeType,
      totalAmountToBePaid: totalAmountToBePaid,
      remainingAmountToBePaid: remainingAmountToBePaid,
      amountPaying: 0,
    )..amountPayingController.text = "0";
  }
}

class SendFeeReceiptSmsRequest {
/*
{
  "agentId": 127,
  "bothDateAndTime": false,
  "masterTransactionId": 1653146783553,
  "schoolId": 91
}
*/

  int? agentId;
  bool? bothDateAndTime;
  int? masterTransactionId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  SendFeeReceiptSmsRequest({
    this.agentId,
    this.bothDateAndTime,
    this.masterTransactionId,
    this.schoolId,
  });

  SendFeeReceiptSmsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    bothDateAndTime = json['bothDateAndTime'];
    masterTransactionId = json['masterTransactionId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['bothDateAndTime'] = bothDateAndTime;
    data['masterTransactionId'] = masterTransactionId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SendFeeReceiptSmsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  SendFeeReceiptSmsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  SendFeeReceiptSmsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<SendFeeReceiptSmsResponse> sendFeeReceiptSms(SendFeeReceiptSmsRequest sendFeeReceiptSmsRequest) async {
  debugPrint("Raising request to sendFeeReceiptSms with request ${jsonEncode(sendFeeReceiptSmsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + SEND_FEE_RECEIPT_SMS;

  SendFeeReceiptSmsResponse sendFeeReceiptSmsResponse = await HttpUtils.post(
    _url,
    sendFeeReceiptSmsRequest.toJson(),
    SendFeeReceiptSmsResponse.fromJson,
  );

  debugPrint("SendFeeReceiptSmsResponse ${sendFeeReceiptSmsResponse.toJson()}");
  return sendFeeReceiptSmsResponse;
}
