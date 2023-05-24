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
  int? discount;
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
    this.discount,
    this.sectionId,
    this.sectionName,
    this.status,
  });

  @override
  String toString() {
    return "\n{\n\t'studentId': $studentId, \n\t'studentName': $studentName, \n\t'rollNumber': $rollNumber, \n\t'studentAnnualFeeTypeBeans': $studentAnnualFeeTypeBeans, \n\t'studentBusFeeBean': $studentBusFeeBean, \n\t'totalFee': $totalFee, \n\t'totalFeePaid': $totalFeePaid,\n\t'walletBalance': $walletBalance}";
  }

  void computeDiscount(List<SectionWiseAnnualFeesBean> sectionWiseAnnualFeeBeansList) {
    List<int> feeTypesIdsToBeConsideredForDiscount = sectionWiseAnnualFeeBeansList
        .where((e) => e.sectionId == sectionId)
        .map((e) => e.feeTypeId == null || e.feeTypeId == -1 || e.amount == null || e.amount == 0 ? null : e.feeTypeId)
        .where((e) => e != null)
        .map((e) => e!)
        .toSet()
        .toList();
    int actualFee = sectionWiseAnnualFeeBeansList
        .where((e) => e.sectionId == sectionId)
        .where((e) => feeTypesIdsToBeConsideredForDiscount.contains(e.feeTypeId))
        .map((e) => e.amount ?? 0)
        .reduce((a, b) => a + b);
    int feeAfterDiscount = (studentAnnualFeeTypeBeans ?? [])
        .where((e) => feeTypesIdsToBeConsideredForDiscount.contains(e.feeTypeId))
        .map((e) => e.amount ?? 0)
        .reduce((a, b) => a + b);
    discount = (actualFee - feeAfterDiscount);
  }
}

class StudentAnnualFeeTypeBean {
  int? feeTypeId;
  String? feeType;
  int? amount;
  int? amountPaid;
  int? studentFeeMapId;
  int? sectionFeeMapId;
  List<StudentAnnualCustomFeeTypeBean>? studentAnnualCustomFeeTypeBeans;

  TextEditingController amountController = TextEditingController();

  StudentAnnualFeeTypeBean({
    this.feeTypeId,
    this.feeType,
    this.amount,
    this.amountPaid,
    this.studentFeeMapId,
    this.sectionFeeMapId,
    this.studentAnnualCustomFeeTypeBeans,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
  }

  @override
  String toString() {
    return "\n{\n\t'feeTypeId': $feeTypeId, \n\t'feeType': $feeType, \n\t'amount': $amount, \n\t'amountPaid': $amountPaid, \n\t'studentFeeMapId': $studentFeeMapId, \n\t'studentAnnualCustomFeeTypeBeans': $studentAnnualCustomFeeTypeBeans \n}";
  }
}

class StudentAnnualCustomFeeTypeBean {
  int? customFeeTypeId;
  String? customFeeType;
  int? amount;
  int? amountPaid;
  int? sectionFeeMapId;
  int? studentFeeMapId;

  TextEditingController amountController = TextEditingController();

  StudentAnnualCustomFeeTypeBean({
    this.customFeeTypeId,
    this.customFeeType,
    this.amount,
    this.amountPaid,
    this.sectionFeeMapId,
    this.studentFeeMapId,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
  }

  @override
  String toString() {
    return "\n{\n\t'customFeeTypeId': $customFeeTypeId, \n\t'customFeeType': $customFeeType, \n\t'amount': $amount, \n\t'amountPaid': $amountPaid, \n\t'studentFeeMapId': $studentFeeMapId \n}";
  }
}
