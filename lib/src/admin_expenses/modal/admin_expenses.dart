import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

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

class AdminExpenseBean {
/*
{
  "adminExpenseId": 0,
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

  int? adminExpenseId;
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
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  AdminExpenseBean({
    this.adminExpenseId,
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
  });
  AdminExpenseBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    adminExpenseId = json['adminExpenseId']?.toInt();
    adminId = json['adminId']?.toInt();
    adminName = json['adminName']?.toString();
    adminPhotoUrl = json['adminPhotoUrl']?.toString();
    amount = json['amount']?.toInt();
    branchCode = json['branchCode']?.toString();
    description = json['description']?.toString();
    expenseType = json['expenseType']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
    transactionId = json['transactionId']?.toString();
    transactionTime = json['transactionTime']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminExpenseId'] = adminExpenseId;
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
  print("Raising request to getAdminExpenses with request ${jsonEncode(getAdminExpensesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ADMIN_EXPENSES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getAdminExpensesRequest.toJson()),
  );

  GetAdminExpensesResponse getAdminExpensesResponse = GetAdminExpensesResponse.fromJson(json.decode(response.body));
  print("GetAdminExpensesResponse ${getAdminExpensesResponse.toJson()}");
  return getAdminExpensesResponse;
}
