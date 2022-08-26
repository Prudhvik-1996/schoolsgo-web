import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class GetMonthsAndYearsForSchoolsRequest {
/*
{
  "schoolId": 91
}
*/

  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetMonthsAndYearsForSchoolsRequest({
    this.schoolId,
  });
  GetMonthsAndYearsForSchoolsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class MonthAndYearForSchoolBean {
/*
{
  "agent": 0,
  "createTime": 0,
  "month": "JANUARY",
  "monthAndYearForSchoolId": 0,
  "noOfWorkingDays": 0,
  "schoolId": 0,
  "status": "active",
  "year": 0
}
*/

  int? agent;
  int? createTime;
  String? month;
  int? monthAndYearForSchoolId;
  int? noOfWorkingDays;
  int? schoolId;
  String? status;
  int? year;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  MonthAndYearForSchoolBean({
    this.agent,
    this.createTime,
    this.month,
    this.monthAndYearForSchoolId,
    this.noOfWorkingDays,
    this.schoolId,
    this.status,
    this.year,
  });
  MonthAndYearForSchoolBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    createTime = json['createTime']?.toInt();
    month = json['month']?.toString();
    monthAndYearForSchoolId = json['monthAndYearForSchoolId']?.toInt();
    noOfWorkingDays = json['noOfWorkingDays']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    year = json['year']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['createTime'] = createTime;
    data['month'] = month;
    data['monthAndYearForSchoolId'] = monthAndYearForSchoolId;
    data['noOfWorkingDays'] = noOfWorkingDays;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['year'] = year;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetMonthsAndYearsForSchoolsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "monthAndYearForSchoolBeans": [
    {
      "agent": 0,
      "createTime": 0,
      "month": "JANUARY",
      "monthAndYearForSchoolId": 0,
      "noOfWorkingDays": 0,
      "schoolId": 0,
      "status": "active",
      "year": 0
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<MonthAndYearForSchoolBean?>? monthAndYearForSchoolBeans;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetMonthsAndYearsForSchoolsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.monthAndYearForSchoolBeans,
    this.responseStatus,
  });
  GetMonthsAndYearsForSchoolsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['monthAndYearForSchoolBeans'] != null) {
      final v = json['monthAndYearForSchoolBeans'];
      final arr0 = <MonthAndYearForSchoolBean>[];
      v.forEach((v) {
        arr0.add(MonthAndYearForSchoolBean.fromJson(v));
      });
      monthAndYearForSchoolBeans = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (monthAndYearForSchoolBeans != null) {
      final v = monthAndYearForSchoolBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['monthAndYearForSchoolBeans'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetMonthsAndYearsForSchoolsResponse> getMonthsAndYearsForSchools(GetMonthsAndYearsForSchoolsRequest getMonthsAndYearsForSchoolsRequest) async {
  debugPrint("Raising request to getMonthsAndYearsForSchools with request ${jsonEncode(getMonthsAndYearsForSchoolsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_MONTHS_AND_YEARS_FOR_SCHOOL;

  GetMonthsAndYearsForSchoolsResponse getMonthsAndYearsForSchoolsResponse = await HttpUtils.post(
    _url,
    getMonthsAndYearsForSchoolsRequest.toJson(),
    GetMonthsAndYearsForSchoolsResponse.fromJson,
  );

  debugPrint("GetMonthsAndYearsForSchoolsResponse ${getMonthsAndYearsForSchoolsResponse.toJson()}");
  return getMonthsAndYearsForSchoolsResponse;
}

class CreateMonthsAndYearsForSchoolsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "monthAndYearForSchoolId": 0,
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  int? monthAndYearForSchoolId;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateMonthsAndYearsForSchoolsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.monthAndYearForSchoolId,
    this.responseStatus,
  });
  CreateMonthsAndYearsForSchoolsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    monthAndYearForSchoolId = json['monthAndYearForSchoolId']?.toInt();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['monthAndYearForSchoolId'] = monthAndYearForSchoolId;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateMonthsAndYearsForSchoolsResponse> createOrUpdateMonthAndYearForSchool(
    MonthAndYearForSchoolBean createOrUpdateMonthAndYearForSchoolRequest) async {
  debugPrint(
      "Raising request to createOrUpdateMonthAndYearForSchoolRequest with request ${jsonEncode(createOrUpdateMonthAndYearForSchoolRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_MONTHS_AND_YEARS_FOR_SCHOOL;

  CreateMonthsAndYearsForSchoolsResponse createMonthsAndYearsForSchoolsResponse = await HttpUtils.post(
    _url,
    createOrUpdateMonthAndYearForSchoolRequest.toJson(),
    CreateMonthsAndYearsForSchoolsResponse.fromJson,
  );

  debugPrint("CreateMonthsAndYearsForSchoolsResponse ${createMonthsAndYearsForSchoolsResponse.toJson()}");
  return createMonthsAndYearsForSchoolsResponse;
}

class GetPayslipComponentsRequest {
/*
{
  "payslipComponentId": 0,
  "schoolId": 0
}
*/

  int? payslipComponentId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetPayslipComponentsRequest({
    this.payslipComponentId,
    this.schoolId,
  });
  GetPayslipComponentsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    payslipComponentId = json['payslipComponentId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['payslipComponentId'] = payslipComponentId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class PayslipComponentBean {
/*
{
  "agent": 0,
  "componentName": "string",
  "componentType": "EARNINGS",
  "payslipComponentId": 0,
  "schoolId": 0,
  "schoolName": "string",
  "status": "active"
}
*/

  int? agent;
  String? componentName;
  String? componentType;
  int? payslipComponentId;
  int? schoolId;
  String? schoolName;
  String? status;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;
  TextEditingController componentNameController = TextEditingController();

  PayslipComponentBean({
    this.agent,
    this.componentName,
    this.componentType,
    this.payslipComponentId,
    this.schoolId,
    this.schoolName,
    this.status,
  }) {
    componentNameController.text = componentName ?? "";
  }
  PayslipComponentBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    componentName = json['componentName']?.toString();
    componentNameController.text = componentName ?? "";
    componentType = json['componentType']?.toString();
    payslipComponentId = json['payslipComponentId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['componentName'] = componentName;
    data['componentType'] = componentType;
    data['payslipComponentId'] = payslipComponentId;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetPayslipComponentsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "payslipComponentBeans": [
    {
      "agent": 0,
      "componentName": "string",
      "componentType": "EARNINGS",
      "payslipComponentId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "status": "active"
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<PayslipComponentBean?>? payslipComponentBeans;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetPayslipComponentsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.payslipComponentBeans,
    this.responseStatus,
  });
  GetPayslipComponentsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['payslipComponentBeans'] != null) {
      final v = json['payslipComponentBeans'];
      final arr0 = <PayslipComponentBean>[];
      v.forEach((v) {
        arr0.add(PayslipComponentBean.fromJson(v));
      });
      payslipComponentBeans = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (payslipComponentBeans != null) {
      final v = payslipComponentBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['payslipComponentBeans'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetPayslipComponentsResponse> getPayslipComponents(GetPayslipComponentsRequest getPayslipComponentsRequest) async {
  debugPrint("Raising request to getPayslipComponents with request ${jsonEncode(getPayslipComponentsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_PAYSLIP_COMPONENTS;

  GetPayslipComponentsResponse getPayslipComponentsResponse = await HttpUtils.post(
    _url,
    getPayslipComponentsRequest.toJson(),
    GetPayslipComponentsResponse.fromJson,
  );

  debugPrint("GetPayslipComponentsResponse ${getPayslipComponentsResponse.toJson()}");
  return getPayslipComponentsResponse;
}

class CreateOrUpdatePayslipComponentsRequest {
/*
{
  "agent": 0,
  "payslipComponents": [
    {
      "agent": 0,
      "componentName": "string",
      "componentType": "EARNINGS",
      "payslipComponentId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "status": "active"
    }
  ],
  "schoolId": 0
}
*/

  int? agent;
  List<PayslipComponentBean?>? payslipComponents;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdatePayslipComponentsRequest({
    this.agent,
    this.payslipComponents,
    this.schoolId,
  });
  CreateOrUpdatePayslipComponentsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['payslipComponents'] != null) {
      final v = json['payslipComponents'];
      final arr0 = <PayslipComponentBean>[];
      v.forEach((v) {
        arr0.add(PayslipComponentBean.fromJson(v));
      });
      payslipComponents = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (payslipComponents != null) {
      final v = payslipComponents;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['payslipComponents'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdatePayslipComponentsResponse {
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

  CreateOrUpdatePayslipComponentsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdatePayslipComponentsResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdatePayslipComponentsResponse> createOrUpdatePayslipComponents(
    CreateOrUpdatePayslipComponentsRequest createOrUpdatePayslipComponentsRequest) async {
  debugPrint("Raising request to createOrUpdatePayslipComponents with request ${jsonEncode(createOrUpdatePayslipComponentsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_PAYSLIP_COMPONENTS;

  CreateOrUpdatePayslipComponentsResponse createOrUpdatePayslipComponentsResponse = await HttpUtils.post(
    _url,
    createOrUpdatePayslipComponentsRequest.toJson(),
    CreateOrUpdatePayslipComponentsResponse.fromJson,
  );

  debugPrint("createOrUpdatePayslipComponentsResponse ${createOrUpdatePayslipComponentsResponse.toJson()}");
  return createOrUpdatePayslipComponentsResponse;
}

class GetPayslipTemplateForEmployeeRequest {
/*
{
  "employeeId": 0,
  "franchiseId": 0,
  "schoolId": 0
}
*/

  int? employeeId;
  int? franchiseId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetPayslipTemplateForEmployeeRequest({
    this.employeeId,
    this.franchiseId,
    this.schoolId,
  });
  GetPayslipTemplateForEmployeeRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
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

  Map<String, dynamic> origJson() => __origJson;
}

class PayslipTemplateComponentBean {
/*
{
  "amount": 0,
  "componentName": "string",
  "employeeId": 0,
  "employeeName": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "payslipComponentId": 0,
  "payslipComponentType": "EARNINGS",
  "roles": "string",
  "schoolDisplayName": "string",
  "schoolId": 0,
  "status": "active",
  "templateComponentId": 0
}
*/

  int? amount;
  String? componentName;
  int? employeeId;
  String? employeeName;
  int? franchiseId;
  String? franchiseName;
  int? payslipComponentId;
  String? payslipComponentType;
  String? roles;
  String? schoolDisplayName;
  int? schoolId;
  String? status;
  int? templateComponentId;
  Map<String, dynamic> __origJson = {};

  TextEditingController amountController = TextEditingController();

  PayslipTemplateComponentBean({
    this.amount,
    this.componentName,
    this.employeeId,
    this.employeeName,
    this.franchiseId,
    this.franchiseName,
    this.payslipComponentId,
    this.payslipComponentType,
    this.roles,
    this.schoolDisplayName,
    this.schoolId,
    this.status,
    this.templateComponentId,
  }) {
    amountController.text = amount == null ? "-" : doubleToStringAsFixed(amount! / 100.0, decimalPlaces: 2);
  }
  PayslipTemplateComponentBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    amountController.text = amount == null ? "-" : doubleToStringAsFixed(amount! / 100.0, decimalPlaces: 2);
    componentName = json['componentName']?.toString();
    employeeId = json['employeeId']?.toInt();
    employeeName = json['employeeName']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    payslipComponentId = json['payslipComponentId']?.toInt();
    payslipComponentType = json['payslipComponentType']?.toString();
    roles = json['roles']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    templateComponentId = json['templateComponentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['componentName'] = componentName;
    data['employeeId'] = employeeId;
    data['employeeName'] = employeeName;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['payslipComponentId'] = payslipComponentId;
    data['payslipComponentType'] = payslipComponentType;
    data['roles'] = roles;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['templateComponentId'] = templateComponentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class PayslipTemplateForEmployeeBean {
/*
{
  "employeeId": 0,
  "employeeName": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "payslipTemplateComponentBeans": [
    {
      "amount": 0,
      "componentName": "string",
      "employeeId": 0,
      "employeeName": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "payslipComponentId": 0,
      "payslipComponentType": "EARNINGS",
      "roles": "string",
      "schoolDisplayName": "string",
      "schoolId": 0,
      "status": "active",
      "templateComponentId": 0
    }
  ],
  "roles": "string",
  "schoolDisplayName": "string",
  "schoolId": 0
}
*/

  int? employeeId;
  String? employeeName;
  int? franchiseId;
  String? franchiseName;
  List<PayslipTemplateComponentBean?>? payslipTemplateComponentBeans;
  String? roles;
  String? schoolDisplayName;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  PayslipTemplateForEmployeeBean({
    this.employeeId,
    this.employeeName,
    this.franchiseId,
    this.franchiseName,
    this.payslipTemplateComponentBeans,
    this.roles,
    this.schoolDisplayName,
    this.schoolId,
  });
  PayslipTemplateForEmployeeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    employeeId = json['employeeId']?.toInt();
    employeeName = json['employeeName']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    if (json['payslipTemplateComponentBeans'] != null) {
      final v = json['payslipTemplateComponentBeans'];
      final arr0 = <PayslipTemplateComponentBean>[];
      v.forEach((v) {
        arr0.add(PayslipTemplateComponentBean.fromJson(v));
      });
      payslipTemplateComponentBeans = arr0;
    }
    roles = json['roles']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    data['employeeName'] = employeeName;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    if (payslipTemplateComponentBeans != null) {
      final v = payslipTemplateComponentBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['payslipTemplateComponentBeans'] = arr0;
    }
    data['roles'] = roles;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetPayslipTemplateForEmployeeResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "payslipTemplateForEmployeeBean": {
    "employeeId": 0,
    "employeeName": "string",
    "franchiseId": 0,
    "franchiseName": "string",
    "payslipTemplateComponentBeans": [
      {
        "amount": 0,
        "componentName": "string",
        "employeeId": 0,
        "employeeName": "string",
        "franchiseId": 0,
        "franchiseName": "string",
        "payslipComponentId": 0,
        "payslipComponentType": "EARNINGS",
        "roles": "string",
        "schoolDisplayName": "string",
        "schoolId": 0,
        "status": "active",
        "templateComponentId": 0
      }
    ],
    "roles": "string",
    "schoolDisplayName": "string",
    "schoolId": 0
  },
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  PayslipTemplateForEmployeeBean? payslipTemplateForEmployeeBean;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetPayslipTemplateForEmployeeResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.payslipTemplateForEmployeeBean,
    this.responseStatus,
  });
  GetPayslipTemplateForEmployeeResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    payslipTemplateForEmployeeBean =
        (json['payslipTemplateForEmployeeBean'] != null) ? PayslipTemplateForEmployeeBean.fromJson(json['payslipTemplateForEmployeeBean']) : null;
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (payslipTemplateForEmployeeBean != null) {
      data['payslipTemplateForEmployeeBean'] = payslipTemplateForEmployeeBean!.toJson();
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetPayslipTemplateForEmployeeResponse> getPayslipTemplateForEmployee(
    GetPayslipTemplateForEmployeeRequest getPayslipTemplateForEmployeeRequest) async {
  debugPrint("Raising request to getPayslipTemplateForEmployee with request ${jsonEncode(getPayslipTemplateForEmployeeRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_PAYSLIP_TEMPLATE_FOR_EMPLOYEE;

  GetPayslipTemplateForEmployeeResponse getPayslipTemplateForEmployeeResponse = await HttpUtils.post(
    _url,
    getPayslipTemplateForEmployeeRequest.toJson(),
    GetPayslipTemplateForEmployeeResponse.fromJson,
  );

  debugPrint("GetPayslipTemplateForEmployeeResponse ${getPayslipTemplateForEmployeeResponse.toJson()}");
  return getPayslipTemplateForEmployeeResponse;
}

class CreateOrUpdatePayslipTemplateForEmployeeBeanRequest {
/*
{
  "agent": 0,
  "payslipTemplateForEmployeeBean": {
    "employeeId": 0,
    "employeeName": "string",
    "franchiseId": 0,
    "franchiseName": "string",
    "payslipTemplateComponentBeans": [
      {
        "amount": 0,
        "componentName": "string",
        "employeeId": 0,
        "employeeName": "string",
        "franchiseId": 0,
        "franchiseName": "string",
        "payslipComponentId": 0,
        "payslipComponentType": "EARNINGS",
        "roles": "string",
        "schoolDisplayName": "string",
        "schoolId": 0,
        "status": "active",
        "templateComponentId": 0
      }
    ],
    "roles": "string",
    "schoolDisplayName": "string",
    "schoolId": 0
  },
  "schoolId": 0
}
*/

  int? agent;
  PayslipTemplateForEmployeeBean? payslipTemplateForEmployeeBean;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdatePayslipTemplateForEmployeeBeanRequest({
    this.agent,
    this.payslipTemplateForEmployeeBean,
    this.schoolId,
  });
  CreateOrUpdatePayslipTemplateForEmployeeBeanRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    payslipTemplateForEmployeeBean =
        (json['payslipTemplateForEmployeeBean'] != null) ? PayslipTemplateForEmployeeBean.fromJson(json['payslipTemplateForEmployeeBean']) : null;
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (payslipTemplateForEmployeeBean != null) {
      data['payslipTemplateForEmployeeBean'] = payslipTemplateForEmployeeBean!.toJson();
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdatePayslipTemplateForEmployeeBeanResponse {
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

  CreateOrUpdatePayslipTemplateForEmployeeBeanResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdatePayslipTemplateForEmployeeBeanResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdatePayslipTemplateForEmployeeBeanResponse> createOrUpdatePayslipTemplateForEmployeeBean(
    CreateOrUpdatePayslipTemplateForEmployeeBeanRequest createOrUpdatePayslipTemplateForEmployeeBeanRequest) async {
  debugPrint(
      "Raising request to createOrUpdatePayslipTemplateForEmployeeBean with request ${jsonEncode(createOrUpdatePayslipTemplateForEmployeeBeanRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_PAYSLIP_TEMPLATE_FOR_EMPLOYEE;

  CreateOrUpdatePayslipTemplateForEmployeeBeanResponse createOrUpdatePayslipTemplateForEmployeeBeanResponse = await HttpUtils.post(
    _url,
    createOrUpdatePayslipTemplateForEmployeeBeanRequest.toJson(),
    CreateOrUpdatePayslipTemplateForEmployeeBeanResponse.fromJson,
  );

  debugPrint("createOrUpdatePayslipTemplateForEmployeeBeanResponse ${createOrUpdatePayslipTemplateForEmployeeBeanResponse.toJson()}");
  return createOrUpdatePayslipTemplateForEmployeeBeanResponse;
}
