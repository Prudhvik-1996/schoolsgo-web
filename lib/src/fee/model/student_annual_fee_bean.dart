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
  });

  @override
  String toString() {
    return "\n{\n\t'studentId': $studentId, \n\t'studentName': $studentName, \n\t'rollNumber': $rollNumber, \n\t'studentAnnualFeeTypeBeans': $studentAnnualFeeTypeBeans, \n\t'studentBusFeeBean': $studentBusFeeBean, \n\t'totalFee': $totalFee, \n\t'totalFeePaid': $totalFeePaid,\n\t'walletBalance': $walletBalance}";
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
  int? amountPaid;
  int? studentFeeMapId;
  int? sectionFeeMapId;
  List<StudentAnnualCustomFeeTypeBean>? studentAnnualCustomFeeTypeBeans;

  TextEditingController amountController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  StudentAnnualFeeTypeBean({
    this.feeTypeId,
    this.feeType,
    this.amount,
    this.discount,
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
    return "\n{\n\t'feeTypeId': $feeTypeId, \n\t'feeType': $feeType, \n\t'amount': $amount, \n\t'discount': $discount, \n\t'amountPaid': $amountPaid, \n\t'studentFeeMapId': $studentFeeMapId, \n\t'studentAnnualCustomFeeTypeBeans': $studentAnnualCustomFeeTypeBeans \n}";
  }
}

class StudentAnnualCustomFeeTypeBean {
  int? customFeeTypeId;
  String? customFeeType;
  int? amount;
  int? discount;
  int? amountPaid;
  int? sectionFeeMapId;
  int? studentFeeMapId;

  TextEditingController amountController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  StudentAnnualCustomFeeTypeBean({
    this.customFeeTypeId,
    this.customFeeType,
    this.amount,
    this.discount,
    this.amountPaid,
    this.sectionFeeMapId,
    this.studentFeeMapId,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
    discountController.text = discount == null ? "" : "${discount! / 100}";
  }

  @override
  String toString() {
    return "\n{\n\t'customFeeTypeId': $customFeeTypeId, \n\t'customFeeType': $customFeeType, \n\t'amount': $amount, \n\t'discount': $discount, \n\t'amountPaid': $amountPaid, \n\t'studentFeeMapId': $studentFeeMapId \n}";
  }
}
