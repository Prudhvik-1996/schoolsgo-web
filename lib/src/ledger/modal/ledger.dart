import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetTransactionsRequest {
/*
{
  "franchiseId": 0,
  "schoolId": 0
}
*/

  int? franchiseId;
  int? schoolId;

  int? startDate;
  int? endDate;

  Map<String, dynamic> __origJson = {};

  GetTransactionsRequest({
    this.franchiseId,
    this.schoolId,
    this.startDate,
    this.endDate,
  });
  GetTransactionsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    startDate = json['startDate']?.toInt();
    endDate = json['endDate']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TransactionBean {
/*
{
  "agent": 0,
  "amount": 0,
  "branchCode": "string",
  "childTransactions": [
    {
      "agent": 0,
      "amount": 0,
      "branchCode": "string",
      "description": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "parentTransactionId": "string",
      "schoolId": 0,
      "schoolName": "string",
      "status": "active",
      "transactionId": "string",
      "transactionKind": "CR",
      "transactionStatus": "SUCCESS",
      "transactionTime": 0,
      "transactionType": "FEE"
    }
  ],
  "description": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "parentTransactionId": "string",
  "schoolId": 0,
  "schoolName": "string",
  "status": "active",
  "transactionId": "string",
  "transactionKind": "CR",
  "transactionStatus": "SUCCESS",
  "transactionTime": 0,
  "transactionType": "FEE"
}
*/

  bool showMoreDetails = false;

  int? agent;
  int? amount;
  String? branchCode;
  List<TransactionBean?>? childTransactions;
  String? description;
  String? comments;
  int? franchiseId;
  String? franchiseName;
  String? parentTransactionId;
  int? schoolId;
  String? schoolName;
  String? status;
  String? transactionId;
  String? transactionKind;
  String? transactionStatus;
  int? transactionTime;
  String? transactionType;
  Map<String, dynamic> __origJson = {};

  bool isExpanded = false;

  TransactionBean({
    this.agent,
    this.amount,
    this.branchCode,
    this.childTransactions,
    this.description,
    this.comments,
    this.franchiseId,
    this.franchiseName,
    this.parentTransactionId,
    this.schoolId,
    this.schoolName,
    this.status,
    this.transactionId,
    this.transactionKind,
    this.transactionStatus,
    this.transactionTime,
    this.transactionType,
  });
  TransactionBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    amount = json['amount']?.toInt();
    branchCode = json['branchCode']?.toString();
    if (json['childTransactions'] != null) {
      final v = json['childTransactions'];
      final arr0 = <TransactionBean>[];
      v.forEach((v) {
        arr0.add(TransactionBean.fromJson(v));
      });
      childTransactions = arr0;
    }
    description = json['description']?.toString();
    comments = json['comments']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    parentTransactionId = json['parentTransactionId']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
    transactionId = json['transactionId']?.toString();
    transactionKind = json['transactionKind']?.toString();
    transactionStatus = json['transactionStatus']?.toString();
    transactionTime = json['transactionTime']?.toInt();
    transactionType = json['transactionType']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['amount'] = amount;
    data['branchCode'] = branchCode;
    if (childTransactions != null) {
      final v = childTransactions;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['childTransactions'] = arr0;
    }
    data['description'] = description;
    data['comments'] = comments;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['parentTransactionId'] = parentTransactionId;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    data['transactionId'] = transactionId;
    data['transactionKind'] = transactionKind;
    data['transactionStatus'] = transactionStatus;
    data['transactionTime'] = transactionTime;
    data['transactionType'] = transactionType;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetTransactionsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "transactionList": [
    {
      "agent": 0,
      "amount": 0,
      "branchCode": "string",
      "childTransactions": [
        {
          "agent": 0,
          "amount": 0,
          "branchCode": "string",
          "description": "string",
          "franchiseId": 0,
          "franchiseName": "string",
          "parentTransactionId": "string",
          "schoolId": 0,
          "schoolName": "string",
          "status": "active",
          "transactionId": "string",
          "transactionKind": "CR",
          "transactionStatus": "SUCCESS",
          "transactionTime": 0,
          "transactionType": "FEE"
        }
      ],
      "description": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "parentTransactionId": "string",
      "schoolId": 0,
      "schoolName": "string",
      "status": "active",
      "transactionId": "string",
      "transactionKind": "CR",
      "transactionStatus": "SUCCESS",
      "transactionTime": 0,
      "transactionType": "FEE"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<TransactionBean?>? transactionList;
  Map<String, dynamic> __origJson = {};

  GetTransactionsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.transactionList,
  });
  GetTransactionsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['transactionList'] != null) {
      final v = json['transactionList'];
      final arr0 = <TransactionBean>[];
      v.forEach((v) {
        arr0.add(TransactionBean.fromJson(v));
      });
      transactionList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (transactionList != null) {
      final v = transactionList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['transactionList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetTransactionsResponse> getTransactions(GetTransactionsRequest getTransactionsRequest) async {
  debugPrint("Raising request to getTransactions with request ${jsonEncode(getTransactionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TRANSACTIONS;

  GetTransactionsResponse getTransactionsResponse = await HttpUtils.post(
    _url,
    getTransactionsRequest.toJson(),
    GetTransactionsResponse.fromJson,
  );

  debugPrint("GetTransactionsResponse ${getTransactionsResponse.toJson()}");
  return getTransactionsResponse;
}

Future<List<int>> getTransactionsReport(GetTransactionsRequest getTransactionsRequest) async {
  debugPrint("Raising request to getTransactions with request ${jsonEncode(getTransactionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_LEDGER_REPORT;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getTransactionsRequest.toJson()),
  );

  List<int> getTransactionBytesResponse = response.bodyBytes;
  return getTransactionBytesResponse;
}
