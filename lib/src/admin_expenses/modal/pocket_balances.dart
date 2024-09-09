import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetPocketBalancesRequest {
  int? employeeId;
  int? franchiseId;
  int? schoolId;

  GetPocketBalancesRequest({
    this.employeeId,
    this.franchiseId,
    this.schoolId,
  });

  GetPocketBalancesRequest.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    return data;
  }
}

class PocketBalanceBean {
  int? balanceAmount;
  int? employeeId;
  String? employeeName;
  int? lastTransactionDate;
  int? schoolId;

  PocketBalanceBean({
    this.balanceAmount,
    this.employeeId,
    this.employeeName,
    this.lastTransactionDate,
    this.schoolId,
  });

  PocketBalanceBean.fromJson(Map<String, dynamic> json) {
    balanceAmount = json['balanceAmount']?.toInt();
    employeeId = json['employeeId']?.toInt();
    employeeName = json['employeeName']?.toString();
    lastTransactionDate = json['lastTransactionDate']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['balanceAmount'] = balanceAmount;
    data['employeeId'] = employeeId;
    data['employeeName'] = employeeName;
    data['lastTransactionDate'] = lastTransactionDate;
    data['schoolId'] = schoolId;
    return data;
  }
}

class GetPocketBalancesResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<PocketBalanceBean?>? pocketBalanceBeanList;
  String? responseStatus;

  GetPocketBalancesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.pocketBalanceBeanList,
    this.responseStatus,
  });

  GetPocketBalancesResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['pocketBalanceBeanList'] != null) {
      final v = json['pocketBalanceBeanList'];
      final arr0 = <PocketBalanceBean>[];
      v.forEach((v) {
        arr0.add(PocketBalanceBean.fromJson(v));
      });
      pocketBalanceBeanList = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (pocketBalanceBeanList != null) {
      final v = pocketBalanceBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['pocketBalanceBeanList'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<GetPocketBalancesResponse> getPocketBalances(GetPocketBalancesRequest getPocketBalancesRequest) async {
  debugPrint("Raising request to getPocketBalances with request ${jsonEncode(getPocketBalancesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_POCKET_BALANCES;

  GetPocketBalancesResponse getPocketBalancesResponse = await HttpUtils.post(
    _url,
    getPocketBalancesRequest.toJson(),
    GetPocketBalancesResponse.fromJson,
  );

  debugPrint("GetPocketBalancesResponse ${getPocketBalancesResponse.toJson()}");
  return getPocketBalancesResponse;
}

class GetPocketTransactionsRequest {
  int? employeeId;
  String? endDate;
  int? franchiseId;
  int? schoolId;
  String? startDate;

  GetPocketTransactionsRequest({
    this.employeeId,
    this.endDate,
    this.franchiseId,
    this.schoolId,
    this.startDate,
  });

  GetPocketTransactionsRequest.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId']?.toInt();
    endDate = json['endDate']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    startDate = json['startDate']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    data['endDate'] = endDate;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['startDate'] = startDate;
    return data;
  }
}

class PocketTransactionBean {
  int? agent;
  int? amount;
  String? comments;
  int? date;
  int? employeeId;
  String? modeOfPayment;
  int? pocketTransactionId;
  String? pocketTransactionType;
  int? receiptId;
  int? schoolId;
  String? status;
  int? transactionId;

  Map<String, dynamic> __origJson = {};

  TextEditingController amountController = TextEditingController();
  TextEditingController commentsController = TextEditingController();

  PocketTransactionBean({
    this.agent,
    this.amount,
    this.comments,
    this.date,
    this.employeeId,
    this.modeOfPayment,
    this.pocketTransactionId,
    this.pocketTransactionType,
    this.receiptId,
    this.schoolId,
    this.status,
    this.transactionId,
  }) {
    amountController.text = "${amount ?? ""}";
    commentsController.text = comments ?? "";
  }

  PocketTransactionBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    amount = json['amount']?.toInt();
    comments = json['comments']?.toString();
    date = json['date']?.toInt();
    employeeId = json['employeeId']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
    pocketTransactionId = json['pocketTransactionId']?.toInt();
    pocketTransactionType = json['pocketTransactionType']?.toString();
    receiptId = json['receiptId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    transactionId = json['transactionId']?.toInt();
    amountController.text = "${amount ?? ""}";
    commentsController.text = comments ?? "";
  }

  String get errorTextForAmount => (amount ?? 0) == 0 ? "Amount must be greater than 0" : "";

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['amount'] = amount;
    data['comments'] = comments;
    data['date'] = date;
    data['employeeId'] = employeeId;
    data['modeOfPayment'] = modeOfPayment;
    data['pocketTransactionId'] = pocketTransactionId;
    data['pocketTransactionType'] = pocketTransactionType;
    data['receiptId'] = receiptId;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['transactionId'] = transactionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetPocketTransactionsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<PocketTransactionBean?>? pocketTransactionsList;
  String? responseStatus;

  GetPocketTransactionsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.pocketTransactionsList,
    this.responseStatus,
  });

  GetPocketTransactionsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['pocketTransactionsList'] != null) {
      final v = json['pocketTransactionsList'];
      final arr0 = <PocketTransactionBean>[];
      v.forEach((v) {
        arr0.add(PocketTransactionBean.fromJson(v));
      });
      pocketTransactionsList = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (pocketTransactionsList != null) {
      final v = pocketTransactionsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['pocketTransactionsList'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<GetPocketTransactionsResponse> getPocketTransactions(GetPocketTransactionsRequest getPocketTransactionsRequest) async {
  debugPrint("Raising request to getPocketTransactions with request ${jsonEncode(getPocketTransactionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_POCKET_TRANSACTIONS;

  GetPocketTransactionsResponse getPocketTransactionsResponse = await HttpUtils.post(
    _url,
    getPocketTransactionsRequest.toJson(),
    GetPocketTransactionsResponse.fromJson,
  );

  debugPrint("GetPocketTransactionsResponse ${getPocketTransactionsResponse.toJson()}");
  return getPocketTransactionsResponse;
}

class CreateOrUpdatePocketTransactionRequest {
  int? agent;
  int? amount;
  String? comments;
  int? date;
  int? employeeId;
  String? modeOfPayment;
  int? pocketTransactionId;
  String? pocketTransactionType;
  int? receiptId;
  int? schoolId;
  String? status;
  int? transactionId;

  CreateOrUpdatePocketTransactionRequest({
    this.agent,
    this.amount,
    this.comments,
    this.date,
    this.employeeId,
    this.modeOfPayment,
    this.pocketTransactionId,
    this.pocketTransactionType,
    this.receiptId,
    this.schoolId,
    this.status,
    this.transactionId,
  });

  CreateOrUpdatePocketTransactionRequest.fromJson(Map<String, dynamic> json) {
    agent = json['agent']?.toInt();
    amount = json['amount']?.toInt();
    comments = json['comments']?.toString();
    date = json['date']?.toInt();
    employeeId = json['employeeId']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
    pocketTransactionId = json['pocketTransactionId']?.toInt();
    pocketTransactionType = json['pocketTransactionType']?.toString();
    receiptId = json['receiptId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    transactionId = json['transactionId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['amount'] = amount;
    data['comments'] = comments;
    data['date'] = date;
    data['employeeId'] = employeeId;
    data['modeOfPayment'] = modeOfPayment;
    data['pocketTransactionId'] = pocketTransactionId;
    data['pocketTransactionType'] = pocketTransactionType;
    data['receiptId'] = receiptId;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['transactionId'] = transactionId;
    return data;
  }
}

class CreateOrUpdatePocketTransactionResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  int? pocketTransactionId;
  String? responseStatus;

  CreateOrUpdatePocketTransactionResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.pocketTransactionId,
    this.responseStatus,
  });

  CreateOrUpdatePocketTransactionResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    pocketTransactionId = json['pocketTransactionId']?.toInt();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['pocketTransactionId'] = pocketTransactionId;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdatePocketTransactionResponse> createOrUpdatePocketTransaction(
    CreateOrUpdatePocketTransactionRequest createOrUpdatePocketTransactionRequest) async {
  debugPrint("Raising request to createOrUpdatePocketTransaction with request ${jsonEncode(createOrUpdatePocketTransactionRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_POCKET_TRANSACTION;

  CreateOrUpdatePocketTransactionResponse createOrUpdatePocketTransactionResponse = await HttpUtils.post(
    _url,
    createOrUpdatePocketTransactionRequest.toJson(),
    CreateOrUpdatePocketTransactionResponse.fromJson,
  );

  debugPrint("CreateOrUpdatePocketTransactionResponse ${createOrUpdatePocketTransactionResponse.toJson()}");
  return createOrUpdatePocketTransactionResponse;
}
