import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';

class StudentAnnualFeeBean {
  int? studentId;
  String? studentName;
  String? rollNumber;
  List<StudentAnnualFeeTypeBean>? studentAnnualFeeTypeBeans;
  StudentBusFeeBean? studentBusFeeBean;
  int? totalFee;
  int? totalFeePaid;
  int? walletBalance;
  int? sectionId;
  String? sectionName;
  String? status;

  StudentAnnualFeeBean({
    this.studentId,
    this.studentName,
    this.rollNumber,
    this.studentAnnualFeeTypeBeans,
    this.studentBusFeeBean,
    this.totalFee,
    this.totalFeePaid,
    this.walletBalance,
    this.sectionId,
    this.sectionName,
    this.status,
  }) {
    try {
      totalFee = ((studentAnnualFeeTypeBeans ?? [])
                  .map((e) => (e.studentAnnualCustomFeeTypeBeans ?? []).isEmpty
                      ? [e.amount]
                      : (e.studentAnnualCustomFeeTypeBeans ?? []).map((e) => e.amount).toList())
                  .expand((i) => i)
                  .reduce((a, b) => (a ?? 0) + (b ?? 0)) ??
              0) +
          (studentBusFeeBean?.fare ?? 0);
      totalFeePaid = ((studentAnnualFeeTypeBeans ?? [])
                  .map((e) => (e.studentAnnualCustomFeeTypeBeans ?? []).isEmpty
                      ? [e.amountPaid]
                      : (e.studentAnnualCustomFeeTypeBeans ?? []).map((e) => e.amountPaid).toList())
                  .expand((i) => i)
                  .reduce((a, b) => (a ?? 0) + (b ?? 0)) ??
              0) +
          (studentBusFeeBean?.feePaid ?? 0);
    } catch (_, e) {
      debugPrintStack(label: "Could not compute totalFee and totalFeePaid", stackTrace: e);
    }
  }

  @override
  String toString() {
    return "{'studentId': $studentId, 'studentName': $studentName, 'rollNumber': $rollNumber, 'studentAnnualFeeTypeBeans': $studentAnnualFeeTypeBeans, 'studentBusFeeBean': $studentBusFeeBean, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid,'walletBalance': $walletBalance}";
  }

  String moddedToStringForSection() {
    return "{'studentAnnualFeeTypeBeans': $studentAnnualFeeTypeBeans, 'studentBusFeeBean': $studentBusFeeBean, 'totalFee': $totalFee, 'totalFeePaid': $totalFeePaid,'walletBalance': $walletBalance}";
  }

  int get discount =>
      (studentAnnualFeeTypeBeans ?? []).map((e) => e.discount ?? 0).toList().fold(0, (int? a, b) => (a ?? 0) + b) +
      (studentAnnualFeeTypeBeans ?? [])
          .map((e) => (e.studentAnnualCustomFeeTypeBeans ?? []).map((e) => e.discount ?? 0).toList().fold(0, (int? a, b) => (a ?? 0) + b))
          .toList()
          .fold(0, (int? a, b) => (a ?? 0) + b);
}

class StudentAnnualFeeTypeBean {
  int? feeTypeId;
  String? feeType;
  int? amount;
  int? discount;
  String? comments;
  int? amountPaid;
  int? studentFeeMapId;
  int? sectionFeeMapId;
  List<StudentAnnualCustomFeeTypeBean>? studentAnnualCustomFeeTypeBeans;

  TextEditingController amountController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  int? actualAmount;

  StudentAnnualFeeTypeBean({
    this.feeTypeId,
    this.feeType,
    this.amount,
    this.discount,
    this.comments,
    this.amountPaid,
    this.studentFeeMapId,
    this.sectionFeeMapId,
    this.studentAnnualCustomFeeTypeBeans,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
    discountController.text = discount == null ? "" : "${discount! / 100}";
  }

  @override
  String toString() {
    return "{'feeTypeId': $feeTypeId, 'feeType': $feeType, 'amount': $amount, 'discount': $discount, 'amountPaid': $amountPaid, 'studentFeeMapId': $studentFeeMapId, 'studentAnnualCustomFeeTypeBeans': $studentAnnualCustomFeeTypeBeans }";
  }
}

class StudentAnnualCustomFeeTypeBean {
  int? customFeeTypeId;
  String? customFeeType;
  int? amount;
  int? discount;
  String? comments;
  int? amountPaid;
  int? sectionFeeMapId;
  int? studentFeeMapId;

  TextEditingController amountController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  int? actualAmount;

  StudentAnnualCustomFeeTypeBean({
    this.customFeeTypeId,
    this.customFeeType,
    this.amount,
    this.discount,
    this.comments,
    this.amountPaid,
    this.sectionFeeMapId,
    this.studentFeeMapId,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
    discountController.text = discount == null ? "" : "${discount! / 100}";
  }

  @override
  String toString() {
    return "{'customFeeTypeId': $customFeeTypeId, 'customFeeType': $customFeeType, 'amount': $amount, 'discount': $discount, 'amountPaid': $amountPaid, 'studentFeeMapId': $studentFeeMapId }";
  }
}
