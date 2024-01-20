import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudentPocketMoneyRequest {
  int? schoolId;
  int? sectionId;
  String? status;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  GetStudentPocketMoneyRequest({
    this.schoolId,
    this.sectionId,
    this.status,
    this.studentId,
  });

  GetStudentPocketMoneyRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    status = json['status']?.toString();
    studentId = json['studentId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['status'] = status;
    data['studentId'] = studentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class LoadOrDebitStudentPocketMoneyTransactionBean {
  int? amount;
  String? comment;
  String? modeOfPayment;
  String? pocketMoneyStatus;
  String? rollNumber;
  int? schoolId;
  int? studentId;
  String? studentName;
  String? gaurdianName;
  String? sectionName;
  int? studentPocketMoneyId;
  String? studentStatus;
  String? transactionDate;
  String? transactionDescription;
  int? transactionId;
  String? transactionKind;
  String? transactionType;
  String? txnStatus;
  String? status;
  int? agent;
  Map<String, dynamic> __origJson = {};

  TextEditingController amountController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController reasonToDeleteController = TextEditingController();

  LoadOrDebitStudentPocketMoneyTransactionBean({
    this.amount,
    this.comment,
    this.modeOfPayment,
    this.pocketMoneyStatus,
    this.rollNumber,
    this.schoolId,
    this.studentId,
    this.studentName,
    this.gaurdianName,
    this.sectionName,
    this.studentPocketMoneyId,
    this.studentStatus,
    this.transactionDate,
    this.transactionDescription,
    this.transactionId,
    this.transactionKind,
    this.transactionType,
    this.txnStatus,
    this.status,
    this.agent,
  }) {
    amountController.text = amount == null ? "" : "${amount! / 100}";
    commentController.text = comment ?? "";
  }

  LoadOrDebitStudentPocketMoneyTransactionBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    amountController.text = amount == null ? "" : "${amount! / 100}";
    comment = json['comment']?.toString();
    commentController.text = comment ?? "";
    modeOfPayment = json['modeOfPayment']?.toString();
    pocketMoneyStatus = json['pocketMoneyStatus']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    gaurdianName = json['gaurdianName']?.toString();
    sectionName = json['sectionName']?.toString();
    studentPocketMoneyId = json['studentPocketMoneyId']?.toInt();
    studentStatus = json['studentStatus']?.toString();
    transactionDate = json['transactionDate']?.toString();
    transactionDescription = json['transactionDescription']?.toString();
    transactionId = json['transactionId']?.toInt();
    transactionKind = json['transactionKind']?.toString();
    transactionType = json['transactionType']?.toString();
    txnStatus = json['txnStatus']?.toString();
    status = json['status']?.toString();
    agent = json['agent']?.toInt();
  }

  void populateFromControllers() {
    amount = ((double.tryParse(amountController.text) ?? 0) * 100).floor();
    comment = commentController.text;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['comment'] = comment;
    data['modeOfPayment'] = modeOfPayment;
    data['pocketMoneyStatus'] = pocketMoneyStatus;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['gaurdianName'] = gaurdianName;
    data['sectionName'] = sectionName;
    data['studentPocketMoneyId'] = studentPocketMoneyId;
    data['studentStatus'] = studentStatus;
    data['transactionDate'] = transactionDate;
    data['transactionDescription'] = transactionDescription;
    data['transactionId'] = transactionId;
    data['transactionKind'] = transactionKind;
    data['transactionType'] = transactionType;
    data['txnStatus'] = txnStatus;
    data['status'] = status;
    data['agent'] = agent;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentPocketMoneyBean {
  List<LoadOrDebitStudentPocketMoneyTransactionBean?>? loadOrDebitStudentPocketMoneyTransactionBeans;
  int? pocketMoney;
  String? rollNumber;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  int? studentId;
  String? studentName;
  Map<String, dynamic> __origJson = {};

  StudentPocketMoneyBean({
    this.loadOrDebitStudentPocketMoneyTransactionBeans,
    this.pocketMoney,
    this.rollNumber,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.studentId,
    this.studentName,
  });

  StudentPocketMoneyBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['loadOrDebitStudentPocketMoneyTransactionBeans'] != null) {
      final v = json['loadOrDebitStudentPocketMoneyTransactionBeans'];
      final arr0 = <LoadOrDebitStudentPocketMoneyTransactionBean>[];
      v.forEach((v) {
        arr0.add(LoadOrDebitStudentPocketMoneyTransactionBean.fromJson(v));
      });
      loadOrDebitStudentPocketMoneyTransactionBeans = arr0;
    }
    pocketMoney = json['pocketMoney']?.toInt();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (loadOrDebitStudentPocketMoneyTransactionBeans != null) {
      final v = loadOrDebitStudentPocketMoneyTransactionBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['loadOrDebitStudentPocketMoneyTransactionBeans'] = arr0;
    }
    data['pocketMoney'] = pocketMoney;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentPocketMoneyResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentPocketMoneyBean?>? studentPocketMoneyBeans;
  Map<String, dynamic> __origJson = {};

  GetStudentPocketMoneyResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentPocketMoneyBeans,
  });

  GetStudentPocketMoneyResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentPocketMoneyBeans'] != null) {
      final v = json['studentPocketMoneyBeans'];
      final arr0 = <StudentPocketMoneyBean>[];
      v.forEach((v) {
        arr0.add(StudentPocketMoneyBean.fromJson(v));
      });
      studentPocketMoneyBeans = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentPocketMoneyBeans != null) {
      final v = studentPocketMoneyBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentPocketMoneyBeans'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentPocketMoneyResponse> getStudentPocketMoney(GetStudentPocketMoneyRequest getStudentPocketMoneyRequest) async {
  debugPrint("Raising request to getStudentPocketMoney with request ${jsonEncode(getStudentPocketMoneyRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_POCKET_MONEY;

  GetStudentPocketMoneyResponse getStudentPocketMoneyResponse = await HttpUtils.post(
    _url,
    getStudentPocketMoneyRequest.toJson(),
    GetStudentPocketMoneyResponse.fromJson,
  );

  debugPrint("GetStudentPocketMoneyResponse ${getStudentPocketMoneyResponse.toJson()}");
  return getStudentPocketMoneyResponse;
}

class LoadOrDebitStudentPocketMoneyRequest {
  int? agent;
  List<LoadOrDebitStudentPocketMoneyTransactionBean?>? loadOrDebitStudentPocketMoneyTransactionBeans;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  LoadOrDebitStudentPocketMoneyRequest({
    this.agent,
    this.loadOrDebitStudentPocketMoneyTransactionBeans,
    this.schoolId,
  });

  LoadOrDebitStudentPocketMoneyRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['loadOrDebitStudentPocketMoneyTransactionBeans'] != null) {
      final v = json['loadOrDebitStudentPocketMoneyTransactionBeans'];
      final arr0 = <LoadOrDebitStudentPocketMoneyTransactionBean>[];
      v.forEach((v) {
        arr0.add(LoadOrDebitStudentPocketMoneyTransactionBean.fromJson(v));
      });
      loadOrDebitStudentPocketMoneyTransactionBeans = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (loadOrDebitStudentPocketMoneyTransactionBeans != null) {
      final v = loadOrDebitStudentPocketMoneyTransactionBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['loadOrDebitStudentPocketMoneyTransactionBeans'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class LoadOrDebitStudentPocketMoneyResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  LoadOrDebitStudentPocketMoneyResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  LoadOrDebitStudentPocketMoneyResponse.fromJson(Map<String, dynamic> json) {
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

Future<LoadOrDebitStudentPocketMoneyResponse> loadOrDebitStudentPocketMoney(
    LoadOrDebitStudentPocketMoneyRequest loadOrDebitStudentPocketMoneyRequest) async {
  debugPrint("Raising request to loadOrDebitStudentPocketMoney with request ${jsonEncode(loadOrDebitStudentPocketMoneyRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + LOAD_OR_DEBIT_STUDENT_POCKET_MONEY;

  LoadOrDebitStudentPocketMoneyResponse loadOrDebitStudentPocketMoneyResponse = await HttpUtils.post(
    _url,
    loadOrDebitStudentPocketMoneyRequest.toJson(),
    LoadOrDebitStudentPocketMoneyResponse.fromJson,
  );

  debugPrint("LoadOrDebitStudentPocketMoneyResponse ${loadOrDebitStudentPocketMoneyResponse.toJson()}");
  return loadOrDebitStudentPocketMoneyResponse;
}
