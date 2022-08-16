import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class GetAdminExpensesRequest {
/*
{
  "agent": 0,
  "franchiseId": 0,
  "schoolId": 0
}
*/

  int? agent;
  int? franchiseId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetAdminExpensesRequest({
    this.agent,
    this.franchiseId,
    this.schoolId,
  });
  GetAdminExpensesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class AdminExpenseReceiptBean {
/*
{
  "adminId": 0,
  "expenseId": 0,
  "franchiseId": 0,
  "mediaId": 0,
  "mediaType": "string",
  "mediaUrl": "string",
  "receiptId": 0,
  "schoolId": 0
}
*/

  int? adminId;
  int? expenseId;
  int? franchiseId;
  int? mediaId;
  String? mediaType;
  String? mediaUrl;
  int? receiptId;
  int? schoolId;
  String? status;

  Map<String, dynamic> __origJson = {};

  AdminExpenseReceiptBean({
    this.adminId,
    this.expenseId,
    this.franchiseId,
    this.mediaId,
    this.mediaType,
    this.mediaUrl,
    this.receiptId,
    this.schoolId,
    this.status,
  });
  AdminExpenseReceiptBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    adminId = json['adminId']?.toInt();
    expenseId = json['expenseId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    mediaId = json['mediaId']?.toInt();
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    receiptId = json['receiptId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminId'] = adminId;
    data['expenseId'] = expenseId;
    data['franchiseId'] = franchiseId;
    data['mediaId'] = mediaId;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['receiptId'] = receiptId;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class AdminExpenseBean {
/*
{
  "adminExpenseId": 0,
  "adminExpenseReceiptsList": [
    {
      "adminId": 0,
      "expenseId": 0,
      "franchiseId": 0,
      "mediaId": 0,
      "mediaType": "string",
      "mediaUrl": "string",
      "receiptId": 0,
      "schoolId": 0
    }
  ],
  "adminId": 0,
  "adminName": "string",
  "adminPhotoUrl": "string",
  "amount": 0,
  "branchCode": "string",
  "description": "string",
  "expenseType": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "status": "active",
  "transactionId": "string",
  "transactionTime": 0
}
*/

  bool isEditMode = false;
  TextEditingController expenseTypeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  int? adminExpenseId;
  List<AdminExpenseReceiptBean?>? adminExpenseReceiptsList;
  int? adminId;
  String? adminName;
  String? adminPhotoUrl;
  int? amount;
  String? branchCode;
  String? description;
  String? expenseType;
  int? franchiseId;
  String? franchiseName;
  int? schoolId;
  String? schoolName;
  String? status;
  String? transactionId;
  int? transactionTime;
  int? agent;
  Map<String, dynamic> __origJson = {};

  AdminExpenseBean({
    this.adminExpenseId,
    this.adminExpenseReceiptsList,
    this.adminId,
    this.adminName,
    this.adminPhotoUrl,
    this.amount,
    this.branchCode,
    this.description,
    this.expenseType,
    this.franchiseId,
    this.franchiseName,
    this.schoolId,
    this.schoolName,
    this.status,
    this.transactionId,
    this.transactionTime,
    this.agent,
  }) {
    expenseTypeController.text = expenseType ?? "";
    descriptionController.text = description ?? "";
    amountController.text = amount == null ? "" : doubleToStringAsFixed(amount! / 100.0, decimalPlaces: 2);
  }

  String? get errorTextForExpenseType {
    if ((expenseType ?? "").trim().isEmpty) {
      return "Expense Type cannot be empty";
    }
    return null;
  }

  String? get errorTextForAmount {
    if ((amountController.text).toString().trim().isEmpty) {
      return "Amount must be greater than 0";
    }
    return null;
  }

  AdminExpenseBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    adminExpenseId = json['adminExpenseId']?.toInt();
    if (json['adminExpenseReceiptsList'] != null) {
      final v = json['adminExpenseReceiptsList'];
      final arr0 = <AdminExpenseReceiptBean>[];
      v.forEach((v) {
        arr0.add(AdminExpenseReceiptBean.fromJson(v));
      });
      adminExpenseReceiptsList = arr0;
    }
    adminId = json['adminId']?.toInt();
    adminName = json['adminName']?.toString();
    adminPhotoUrl = json['adminPhotoUrl']?.toString();
    amount = json['amount']?.toInt();
    amountController.text = amount == null ? "" : doubleToStringAsFixed(amount! / 100.0, decimalPlaces: 2);
    branchCode = json['branchCode']?.toString();
    description = json['description']?.toString();
    descriptionController.text = description ?? "";
    expenseType = json['expenseType']?.toString();
    expenseTypeController.text = expenseType ?? "";
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
    transactionId = json['transactionId']?.toString();
    transactionTime = json['transactionTime']?.toInt();
    agent = json['agent']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminExpenseId'] = adminExpenseId;
    if (adminExpenseReceiptsList != null) {
      final v = adminExpenseReceiptsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['adminExpenseReceiptsList'] = arr0;
    }
    data['adminId'] = adminId;
    data['adminName'] = adminName;
    data['adminPhotoUrl'] = adminPhotoUrl;
    data['amount'] = amount;
    data['branchCode'] = branchCode;
    data['description'] = description;
    data['expenseType'] = expenseType;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    data['transactionId'] = transactionId;
    data['transactionTime'] = transactionTime;
    data['agent'] = agent;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetAdminExpensesResponse {
/*
{
  "adminExpenseBeanList": [
    {
      "adminExpenseId": 0,
      "adminExpenseReceiptsList": [
        {
          "adminId": 0,
          "expenseId": 0,
          "franchiseId": 0,
          "mediaId": 0,
          "mediaType": "string",
          "mediaUrl": "string",
          "receiptId": 0,
          "schoolId": 0
        }
      ],
      "adminId": 0,
      "adminName": "string",
      "adminPhotoUrl": "string",
      "amount": 0,
      "branchCode": "string",
      "description": "string",
      "expenseType": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "schoolId": 0,
      "schoolName": "string",
      "status": "active",
      "transactionId": "string",
      "transactionTime": 0
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<AdminExpenseBean?>? adminExpenseBeanList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetAdminExpensesResponse({
    this.adminExpenseBeanList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetAdminExpensesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['adminExpenseBeanList'] != null) {
      final v = json['adminExpenseBeanList'];
      final arr0 = <AdminExpenseBean>[];
      v.forEach((v) {
        arr0.add(AdminExpenseBean.fromJson(v));
      });
      adminExpenseBeanList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (adminExpenseBeanList != null) {
      final v = adminExpenseBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['adminExpenseBeanList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetAdminExpensesResponse> getAdminExpenses(GetAdminExpensesRequest getAdminExpensesRequest) async {
  debugPrint("Raising request to getAdminExpenses with request ${jsonEncode(getAdminExpensesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ADMIN_EXPENSES;

  GetAdminExpensesResponse getAdminExpensesResponse = await HttpUtils.post(
    _url,
    getAdminExpensesRequest.toJson(),
    GetAdminExpensesResponse.fromJson,
  );

  debugPrint("GetAdminExpensesResponse ${getAdminExpensesResponse.toJson()}");
  return getAdminExpensesResponse;
}

class CreateOrUpdateAdminExpenseRequest extends AdminExpenseBean {}

class CreateOrUpdateAdminExpenseResponse {
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

  CreateOrUpdateAdminExpenseResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateAdminExpenseResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateAdminExpenseResponse> createOrUpdateAdminExpense(CreateOrUpdateAdminExpenseRequest createOrUpdateAdminExpenseRequest) async {
  debugPrint("Raising request to createOrUpdateAdminExpense with request ${jsonEncode(createOrUpdateAdminExpenseRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_ADMIN_EXPENSES;

  CreateOrUpdateAdminExpenseResponse createOrUpdateAdminExpenseResponse = await HttpUtils.post(
    _url,
    createOrUpdateAdminExpenseRequest.toJson(),
    CreateOrUpdateAdminExpenseResponse.fromJson,
  );

  debugPrint("createOrUpdateAdminExpenseResponse ${createOrUpdateAdminExpenseResponse.toJson()}");
  return createOrUpdateAdminExpenseResponse;
}
