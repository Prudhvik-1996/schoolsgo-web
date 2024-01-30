import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSchoolWiseSmsCounterRequest {
/*
{
  "franchiseId": 1,
  "schoolId": 91
}
*/

  int? franchiseId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseSmsCounterRequest({
    this.franchiseId,
    this.schoolId,
  });
  GetSchoolWiseSmsCounterRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class SmsCounterLogBean {

  int? id;
  int? franchiseId;
  int? schoolId;
  int? count;
  String? comment;
  String? status;
  int? agent;
  String? createTime;
  Map<String, dynamic> __origJson = {};

  SmsCounterLogBean({
    this.id,
    this.franchiseId,
    this.schoolId,
    this.count,
    this.comment,
    this.status,
    this.agent,
    this.createTime,
  });
  SmsCounterLogBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    id = json['id']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    count = json['count']?.toInt();
    comment = json['comment']?.toString();
    status = json['status']?.toString();
    agent = json['agent']?.toInt();
    createTime = json['createTime']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['count'] = count;
    data['comment'] = comment;
    data['status'] = status;
    data['agent'] = agent;
    data['createTime'] = createTime;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetSchoolWiseSmsCounterResponse {

  String? responseStatus;
  String? httpStatus;
  int? schoolWiseCount;
  List<SmsCounterLogBean?>? smsCounterLogList;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseSmsCounterResponse({
    this.responseStatus,
    this.httpStatus,
    this.schoolWiseCount,
    this.smsCounterLogList,
  });
  GetSchoolWiseSmsCounterResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    responseStatus = json['responseStatus']?.toString();
    httpStatus = json['httpStatus']?.toString();
    schoolWiseCount = json['schoolWiseCount']?.toInt();
    if (json['smsCounterLogList'] != null) {
      final v = json['smsCounterLogList'];
      final arr0 = <SmsCounterLogBean>[];
      v.forEach((v) {
        arr0.add(SmsCounterLogBean.fromJson(v));
      });
      smsCounterLogList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['responseStatus'] = responseStatus;
    data['httpStatus'] = httpStatus;
    data['schoolWiseCount'] = schoolWiseCount;
    if (smsCounterLogList != null) {
      final v = smsCounterLogList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsCounterLogList'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSchoolWiseSmsCounterResponse> getSchoolWiseSmsCounter(GetSchoolWiseSmsCounterRequest getSchoolWiseSmsCounterRequest) async {
  debugPrint("Raising request to getSchoolWiseSmsCounter with request ${jsonEncode(getSchoolWiseSmsCounterRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOL_WISE_SMS_COUNTER;

  GetSchoolWiseSmsCounterResponse getSchoolWiseSmsCounterResponse = await HttpUtils.post(
    _url,
    getSchoolWiseSmsCounterRequest.toJson(),
    GetSchoolWiseSmsCounterResponse.fromJson,
  );

  debugPrint("GetSchoolWiseSmsCounterResponse ${getSchoolWiseSmsCounterResponse.toJson()}");
  return getSchoolWiseSmsCounterResponse;
}

class GetSmsCategoriesRequest {

  int? categoryId;
  int? franchiseId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSmsCategoriesRequest({
    this.categoryId,
    this.franchiseId,
    this.schoolId,
  });
  GetSmsCategoriesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    categoryId = json['categoryId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class SmsCategoryBean {
/*
{
  "agent": 0,
  "category": "string",
  "categoryId": 0,
  "defaultTemplateId": 0,
  "mustHaveDefaultTemplate": true,
  "schoolId": 0,
  "status": "initiated",
  "subCategory": "string"
}
*/

  int? agent;
  String? category;
  int? categoryId;
  int? defaultTemplateId;
  bool? mustHaveDefaultTemplate;
  int? schoolId;
  String? status;
  String? subCategory;
  Map<String, dynamic> __origJson = {};

  SmsCategoryBean({
    this.agent,
    this.category,
    this.categoryId,
    this.defaultTemplateId,
    this.mustHaveDefaultTemplate,
    this.schoolId,
    this.status,
    this.subCategory,
  });
  SmsCategoryBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    category = json['category']?.toString();
    categoryId = json['categoryId']?.toInt();
    defaultTemplateId = json['defaultTemplateId']?.toInt();
    mustHaveDefaultTemplate = json['mustHaveDefaultTemplate'];
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    subCategory = json['subCategory']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['category'] = category;
    data['categoryId'] = categoryId;
    data['defaultTemplateId'] = defaultTemplateId;
    data['mustHaveDefaultTemplate'] = mustHaveDefaultTemplate;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['subCategory'] = subCategory;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetSmsCategoriesResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SmsCategoryBean?>? smsCategoryList;
  Map<String, dynamic> __origJson = {};

  GetSmsCategoriesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.smsCategoryList,
  });
  GetSmsCategoriesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['smsCategoryList'] != null) {
      final v = json['smsCategoryList'];
      final arr0 = <SmsCategoryBean>[];
      v.forEach((v) {
        arr0.add(SmsCategoryBean.fromJson(v));
      });
      smsCategoryList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (smsCategoryList != null) {
      final v = smsCategoryList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsCategoryList'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSmsCategoriesResponse> getSmsCategories(GetSmsCategoriesRequest getSmsCategoriesRequest) async {
  debugPrint("Raising request to getSmsCategories with request ${jsonEncode(getSmsCategoriesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SMS_CATEGORIES;

  GetSmsCategoriesResponse getSmsCategoriesResponse = await HttpUtils.post(
    _url,
    getSmsCategoriesRequest.toJson(),
    GetSmsCategoriesResponse.fromJson,
  );

  debugPrint("GetSmsCategoriesResponse ${getSmsCategoriesResponse.toJson()}");
  return getSmsCategoriesResponse;
}

class GetSmsConfigRequest {

  int? categoryId;
  int? franchiseId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSmsConfigRequest({
    this.categoryId,
    this.franchiseId,
    this.schoolId,
  });
  GetSmsConfigRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    categoryId = json['categoryId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class SmsConfigBean {

  int? agent;
  bool? automatic;
  int? categoryId;
  bool? enabled;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  SmsConfigBean({
    this.agent,
    this.automatic,
    this.categoryId,
    this.enabled,
    this.schoolId,
    this.status,
  });
  SmsConfigBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    automatic = json['automatic'];
    categoryId = json['categoryId']?.toInt();
    enabled = json['enabled'];
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['automatic'] = automatic;
    data['categoryId'] = categoryId;
    data['enabled'] = enabled;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetSmsConfigResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SmsConfigBean?>? smsConfigBeans;
  Map<String, dynamic> __origJson = {};

  GetSmsConfigResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.smsConfigBeans,
  });
  GetSmsConfigResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['smsConfigBeans'] != null) {
      final v = json['smsConfigBeans'];
      final arr0 = <SmsConfigBean>[];
      v.forEach((v) {
        arr0.add(SmsConfigBean.fromJson(v));
      });
      smsConfigBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (smsConfigBeans != null) {
      final v = smsConfigBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsConfigBeans'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSmsConfigResponse> getSmsConfig(GetSmsConfigRequest getSmsConfigRequest) async {
  debugPrint("Raising request to getSmsConfig with request ${jsonEncode(getSmsConfigRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SMS_CONFIG;

  GetSmsConfigResponse getSmsConfigResponse = await HttpUtils.post(
    _url,
    getSmsConfigRequest.toJson(),
    GetSmsConfigResponse.fromJson,
  );

  debugPrint("GetSmsConfigResponse ${getSmsConfigResponse.toJson()}");
  return getSmsConfigResponse;
}

class UpdateSmsConfigRequest {

  int? agent;
  bool? automatic;
  int? categoryId;
  bool? enabled;
  int? franchiseId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  UpdateSmsConfigRequest({
    this.agent,
    this.automatic,
    this.categoryId,
    this.enabled,
    this.franchiseId,
    this.schoolId,
  });
  UpdateSmsConfigRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    automatic = json['automatic'];
    categoryId = json['categoryId']?.toInt();
    enabled = json['enabled'];
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['automatic'] = automatic;
    data['categoryId'] = categoryId;
    data['enabled'] = enabled;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class UpdateSmsConfigResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  UpdateSmsConfigResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  UpdateSmsConfigResponse.fromJson(Map<String, dynamic> json) {
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

Future<UpdateSmsConfigResponse> updateSmsConfig(UpdateSmsConfigRequest updateSmsConfigRequest) async {
  debugPrint("Raising request to updateSmsConfig with request ${jsonEncode(updateSmsConfigRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_SMS_CONFIG;

  UpdateSmsConfigResponse updateSmsConfigResponse = await HttpUtils.post(
    _url,
    updateSmsConfigRequest.toJson(),
    UpdateSmsConfigResponse.fromJson,
  );

  debugPrint("UpdateSmsConfigResponse ${updateSmsConfigResponse.toJson()}");
  return updateSmsConfigResponse;
}

class GetSmsLogsRequest {

  int? categoryId;
  int? franchiseId;
  String? fromDate;
  int? schoolId;
  int? templateId;
  int? templateWiseLogId;
  String? toDate;
  Map<String, dynamic> __origJson = {};

  GetSmsLogsRequest({
    this.categoryId,
    this.franchiseId,
    this.fromDate,
    this.schoolId,
    this.templateId,
    this.templateWiseLogId,
    this.toDate,
  });
  GetSmsLogsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    categoryId = json['categoryId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    fromDate = json['fromDate']?.toString();
    schoolId = json['schoolId']?.toInt();
    templateId = json['templateId']?.toInt();
    templateWiseLogId = json['templateWiseLogId']?.toInt();
    toDate = json['toDate']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['franchiseId'] = franchiseId;
    data['fromDate'] = fromDate;
    data['schoolId'] = schoolId;
    data['templateId'] = templateId;
    data['templateWiseLogId'] = templateWiseLogId;
    data['toDate'] = toDate;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class SmsLogBean {

  int? agent;
  String? createTime;
  String? failureReason;
  String? message;
  String? phone;
  int? smsLogId;
  int? smsTemplateWiseLogId;
  String? status;
  int? studentId;
  int? userId;
  Map<String, dynamic> __origJson = {};

  SmsLogBean({
    this.agent,
    this.createTime,
    this.failureReason,
    this.message,
    this.phone,
    this.smsLogId,
    this.smsTemplateWiseLogId,
    this.status,
    this.studentId,
    this.userId,
  });
  SmsLogBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    createTime = json['createTime']?.toString();
    failureReason = json['failureReason']?.toString();
    message = json['message']?.toString();
    phone = json['phone']?.toString();
    smsLogId = json['smsLogId']?.toInt();
    smsTemplateWiseLogId = json['smsTemplateWiseLogId']?.toInt();
    status = json['status']?.toString();
    studentId = json['studentId']?.toInt();
    userId = json['userId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['createTime'] = createTime;
    data['failureReason'] = failureReason;
    data['message'] = message;
    data['phone'] = phone;
    data['smsLogId'] = smsLogId;
    data['smsTemplateWiseLogId'] = smsTemplateWiseLogId;
    data['status'] = status;
    data['studentId'] = studentId;
    data['userId'] = userId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetSmsLogsResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SmsLogBean?>? smsLogBeans;
  Map<String, dynamic> __origJson = {};

  GetSmsLogsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.smsLogBeans,
  });
  GetSmsLogsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['smsLogBeans'] != null) {
      final v = json['smsLogBeans'];
      final arr0 = <SmsLogBean>[];
      v.forEach((v) {
        arr0.add(SmsLogBean.fromJson(v));
      });
      smsLogBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (smsLogBeans != null) {
      final v = smsLogBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsLogBeans'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSmsLogsResponse> getSmsLogs(GetSmsLogsRequest getSmsLogsRequest) async {
  debugPrint("Raising request to getSmsLogs with request ${jsonEncode(getSmsLogsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SMS_LOGS;

  GetSmsLogsResponse getSmsLogsResponse = await HttpUtils.post(
    _url,
    getSmsLogsRequest.toJson(),
    GetSmsLogsResponse.fromJson,
  );

  debugPrint("GetSmsLogsResponse ${getSmsLogsResponse.toJson()}");
  return getSmsLogsResponse;
}

class GetSmsTemplatesRequest {

  int? categoryId;
  int? franchiseId;
  int? schoolId;
  int? templateId;
  Map<String, dynamic> __origJson = {};

  GetSmsTemplatesRequest({
    this.categoryId,
    this.franchiseId,
    this.schoolId,
    this.templateId,
  });
  GetSmsTemplatesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    categoryId = json['categoryId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    templateId = json['templateId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['templateId'] = templateId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class SmsTemplateBean {

  int? agent;
  int? categoryId;
  bool? isDefault;
  String? dltTemplateId;
  int? franchiseId;
  String? message;
  int? schoolId;
  String? status;
  int? templateId;
  String? textLocalStatus;
  String? textLocalTemplateId;
  String? textLocalTemplateName;
  String? variablesList;
  Map<String, dynamic> __origJson = {};

  SmsTemplateBean({
    this.agent,
    this.categoryId,
    this.isDefault,
    this.dltTemplateId,
    this.franchiseId,
    this.message,
    this.schoolId,
    this.status,
    this.templateId,
    this.textLocalStatus,
    this.textLocalTemplateId,
    this.textLocalTemplateName,
    this.variablesList,
  });
  SmsTemplateBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    categoryId = json['categoryId']?.toInt();
    isDefault = json['isDefault'];
    dltTemplateId = json['dltTemplateId']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    message = json['message']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    templateId = json['templateId']?.toInt();
    textLocalStatus = json['textLocalStatus']?.toString();
    textLocalTemplateId = json['textLocalTemplateId']?.toString();
    textLocalTemplateName = json['textLocalTemplateName']?.toString();
    variablesList = json['variablesList']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['categoryId'] = categoryId;
    data['isDefault'] = isDefault;
    data['dltTemplateId'] = dltTemplateId;
    data['franchiseId'] = franchiseId;
    data['message'] = message;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['templateId'] = templateId;
    data['textLocalStatus'] = textLocalStatus;
    data['textLocalTemplateId'] = textLocalTemplateId;
    data['textLocalTemplateName'] = textLocalTemplateName;
    data['variablesList'] = variablesList;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetSmsTemplatesResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SmsTemplateBean?>? smsTemplateBeans;
  Map<String, dynamic> __origJson = {};

  GetSmsTemplatesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.smsTemplateBeans,
  });
  GetSmsTemplatesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['smsTemplateBeans'] != null) {
      final v = json['smsTemplateBeans'];
      final arr0 = <SmsTemplateBean>[];
      v.forEach((v) {
        arr0.add(SmsTemplateBean.fromJson(v));
      });
      smsTemplateBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (smsTemplateBeans != null) {
      final v = smsTemplateBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsTemplateBeans'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSmsTemplatesResponse> getSmsTemplates(GetSmsTemplatesRequest getSmsTemplatesRequest) async {
  debugPrint("Raising request to getSmsTemplates with request ${jsonEncode(getSmsTemplatesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SMS_TEMPLATES;

  GetSmsTemplatesResponse getSmsTemplatesResponse = await HttpUtils.post(
    _url,
    getSmsTemplatesRequest.toJson(),
    GetSmsTemplatesResponse.fromJson,
  );

  debugPrint("GetSmsTemplatesResponse ${getSmsTemplatesResponse.toJson()}");
  return getSmsTemplatesResponse;
}

class GetSmsTemplateWiseLogRequest {

  int? categoryId;
  int? franchiseId;
  String? fromDate;
  int? schoolId;
  int? templateId;
  String? toDate;
  Map<String, dynamic> __origJson = {};

  GetSmsTemplateWiseLogRequest({
    this.categoryId,
    this.franchiseId,
    this.fromDate,
    this.schoolId,
    this.templateId,
    this.toDate,
  });
  GetSmsTemplateWiseLogRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    categoryId = json['categoryId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    fromDate = json['fromDate']?.toString();
    schoolId = json['schoolId']?.toInt();
    templateId = json['templateId']?.toInt();
    toDate = json['toDate']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['franchiseId'] = franchiseId;
    data['fromDate'] = fromDate;
    data['schoolId'] = schoolId;
    data['templateId'] = templateId;
    data['toDate'] = toDate;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class SmsTemplateWiseLogBean {

  int? agent;
  int? categoryId;
  String? createTime;
  int? franchiseId;
  int? noOfSmsSent;
  int? schoolId;
  String? status;
  String? comments;
  int? templateId;
  int? templateWiseLogId;
  Map<String, dynamic> __origJson = {};

  SmsTemplateWiseLogBean({
    this.agent,
    this.categoryId,
    this.createTime,
    this.franchiseId,
    this.noOfSmsSent,
    this.schoolId,
    this.status,
    this.comments,
    this.templateId,
    this.templateWiseLogId,
  });
  SmsTemplateWiseLogBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    categoryId = json['categoryId']?.toInt();
    createTime = json['createTime']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    noOfSmsSent = json['noOfSmsSent']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    comments = json['comments']?.toString();
    templateId = json['templateId']?.toInt();
    templateWiseLogId = json['templateWiseLogId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['categoryId'] = categoryId;
    data['createTime'] = createTime;
    data['franchiseId'] = franchiseId;
    data['noOfSmsSent'] = noOfSmsSent;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['comments'] = comments;
    data['templateId'] = templateId;
    data['templateWiseLogId'] = templateWiseLogId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetSmsTemplateWiseLogResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SmsTemplateWiseLogBean?>? smsTemplateWiseLogBeans;
  Map<String, dynamic> __origJson = {};

  GetSmsTemplateWiseLogResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.smsTemplateWiseLogBeans,
  });
  GetSmsTemplateWiseLogResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['smsTemplateWiseLogBeans'] != null) {
      final v = json['smsTemplateWiseLogBeans'];
      final arr0 = <SmsTemplateWiseLogBean>[];
      v.forEach((v) {
        arr0.add(SmsTemplateWiseLogBean.fromJson(v));
      });
      smsTemplateWiseLogBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (smsTemplateWiseLogBeans != null) {
      final v = smsTemplateWiseLogBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsTemplateWiseLogBeans'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSmsTemplateWiseLogResponse> getSmsTemplateWiseLog(GetSmsTemplateWiseLogRequest getSmsTemplateWiseLogRequest) async {
  debugPrint("Raising request to getSmsTemplateWiseLog with request ${jsonEncode(getSmsTemplateWiseLogRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SMS_TEMPLATE_WISE_LOGS;

  GetSmsTemplateWiseLogResponse getSmsTemplateWiseLogResponse = await HttpUtils.post(
    _url,
    getSmsTemplateWiseLogRequest.toJson(),
    GetSmsTemplateWiseLogResponse.fromJson,
  );

  debugPrint("GetSmsTemplateWiseLogResponse ${getSmsTemplateWiseLogResponse.toJson()}");
  return getSmsTemplateWiseLogResponse;
}

class SendSmsRequest {

  int? agent;
  int? categoryId;
  int? franchiseId;
  int? schoolId;
  String? comments;
  List<SmsLogBean?>? smsLogBeans;
  int? templateId;
  Map<String, dynamic> __origJson = {};

  SendSmsRequest({
    this.agent,
    this.categoryId,
    this.franchiseId,
    this.schoolId,
    this.comments,
    this.smsLogBeans,
    this.templateId,
  });
  SendSmsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    categoryId = json['categoryId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    comments = json['comments'];
    if (json['smsLogBeans'] != null) {
      final v = json['smsLogBeans'];
      final arr0 = <SmsLogBean>[];
      v.forEach((v) {
        arr0.add(SmsLogBean.fromJson(v));
      });
      smsLogBeans = arr0;
    }
    templateId = json['templateId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['categoryId'] = categoryId;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['comments'] = comments;
    if (smsLogBeans != null) {
      final v = smsLogBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsLogBeans'] = arr0;
    }
    data['templateId'] = templateId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class SendSmsResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SmsLogBean?>? smsLogBeans;
  Map<String, dynamic> __origJson = {};

  SendSmsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.smsLogBeans,
  });
  SendSmsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['smsLogBeans'] != null) {
      final v = json['smsLogBeans'];
      final arr0 = <SmsLogBean>[];
      v.forEach((v) {
        arr0.add(SmsLogBean.fromJson(v));
      });
      smsLogBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (smsLogBeans != null) {
      final v = smsLogBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['smsLogBeans'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<SendSmsResponse> sendSms(SendSmsRequest sendSmsRequest) async {
  debugPrint("Raising request to sendSms with request ${jsonEncode(sendSmsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + SEND_SMS;

  SendSmsResponse sendSmsResponse = await HttpUtils.post(
    _url,
    sendSmsRequest.toJson(),
    SendSmsResponse.fromJson,
  );

  debugPrint("SendSmsResponse ${sendSmsResponse.toJson()}");
  return sendSmsResponse;
}