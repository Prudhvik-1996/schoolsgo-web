import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSuggestionBoxRequest {
/*
{
  "anonymous": true,
  "postingSectionId": 0,
  "postingStudentId": 0,
  "postingUserId": 0,
  "schoolId": 0,
  "teacherId": 0
}
*/

  bool? anonymous;
  int? postingSectionId;
  int? postingStudentId;
  int? postingUserId;
  int? schoolId;
  int? teacherId;
  int? franchiseId;
  Map<String, dynamic> __origJson = {};

  GetSuggestionBoxRequest({
    this.anonymous,
    this.postingSectionId,
    this.postingStudentId,
    this.postingUserId,
    this.schoolId,
    this.franchiseId,
    this.teacherId,
  });
  GetSuggestionBoxRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    anonymous = json['anonymous'];
    postingSectionId = int.tryParse(json['postingSectionId']?.toString() ?? '');
    postingStudentId = int.tryParse(json['postingStudentId']?.toString() ?? '');
    postingUserId = int.tryParse(json['postingUserId']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    franchiseId = int.tryParse(json['franchiseId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['anonymous'] = anonymous;
    data['postingSectionId'] = postingSectionId;
    data['postingStudentId'] = postingStudentId;
    data['postingUserId'] = postingUserId;
    data['schoolId'] = schoolId;
    data['franchiseId'] = franchiseId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Suggestion {
/*
{
  "agent": 0,
  "anonymous": true,
  "complainStatus": "INITIATED",
  "complaintId": 0,
  "createTime": 0,
  "description": "string",
  "lastUpdated": 0,
  "postingStudentId": 0,
  "postingStudentName": "string",
  "postingUserId": 0,
  "postingUserName": "string",
  "sectionId": 0,
  "sectionName": "string",
  "status": "active",
  "teacherId": 0,
  "teacherName": "string",
  "title": "string"
}
*/

  int? agent;
  bool? anonymous;
  String? complainStatus;
  int? complaintId;
  int? createTime;
  String? description;
  int? lastUpdated;
  int? postingStudentId;
  String? postingStudentName;
  int? postingUserId;
  String? postingUserName;
  int? sectionId;
  String? sectionName;
  String? status;
  int? teacherId;
  String? teacherName;
  String? title;
  int? schoolId;
  String? schoolName;
  int? franchiseId;
  String? franchiseName;
  String? branchCode;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  Suggestion({
    this.agent,
    this.anonymous,
    this.complainStatus,
    this.complaintId,
    this.createTime,
    this.description,
    this.lastUpdated,
    this.postingStudentId,
    this.postingStudentName,
    this.postingUserId,
    this.postingUserName,
    this.sectionId,
    this.sectionName,
    this.status,
    this.teacherId,
    this.teacherName,
    this.title,
    this.schoolId,
    this.schoolName,
    this.franchiseId,
    this.franchiseName,
    this.branchCode,
  });
  Suggestion.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = int.tryParse(json['agent']?.toString() ?? '');
    anonymous = json['anonymous'] ?? false;
    complainStatus = json['complainStatus']?.toString();
    complaintId = int.tryParse(json['complaintId']?.toString() ?? '');
    createTime = int.tryParse(json['createTime']?.toString() ?? '');
    description = json['description']?.toString();
    lastUpdated = int.tryParse(json['lastUpdated']?.toString() ?? '');
    postingStudentId = int.tryParse(json['postingStudentId']?.toString() ?? '');
    postingStudentName = json['postingStudentName']?.toString();
    postingUserId = int.tryParse(json['postingUserId']?.toString() ?? '');
    postingUserName = json['postingUserName']?.toString();
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherName = json['teacherName']?.toString();
    title = json['title']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    branchCode = json['branchCode']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['anonymous'] = anonymous;
    data['complainStatus'] = complainStatus;
    data['complaintId'] = complaintId;
    data['createTime'] = createTime;
    data['description'] = description;
    data['lastUpdated'] = lastUpdated;
    data['postingStudentId'] = postingStudentId;
    data['postingStudentName'] = postingStudentName;
    data['postingUserId'] = postingUserId;
    data['postingUserName'] = postingUserName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['title'] = title;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['branchCode'] = branchCode;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetSuggestionBoxResponse {
/*
{
  "agent": "string",
  "complaintBeans": [
    {
      "agent": 0,
      "anonymous": true,
      "complainStatus": "INITIATED",
      "complaintId": 0,
      "createTime": 0,
      "description": "string",
      "lastUpdated": 0,
      "postingStudentId": 0,
      "postingStudentName": "string",
      "postingUserId": 0,
      "postingUserName": "string",
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "teacherId": 0,
      "teacherName": "string",
      "title": "string"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "schoolId": 0
}
*/

  String? agent;
  List<Suggestion?>? complaintBeans;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSuggestionBoxResponse({
    this.agent,
    this.complaintBeans,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.schoolId,
  });
  GetSuggestionBoxResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    if (json['complaintBeans'] != null && (json['complaintBeans'] is List)) {
      final v = json['complaintBeans'];
      final arr0 = <Suggestion>[];
      v.forEach((v) {
        arr0.add(Suggestion.fromJson(v));
      });
      complaintBeans = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (complaintBeans != null) {
      final v = complaintBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['complaintBeans'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSuggestionBoxResponse> getSuggestionBox(GetSuggestionBoxRequest getSuggestionBoxRequest) async {
  debugPrint("Raising request to getSuggestionBox with request ${jsonEncode(getSuggestionBoxRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SUGGESTION_BOX;

  GetSuggestionBoxResponse getSuggestionBoxResponse = await HttpUtils.post(
    _url,
    getSuggestionBoxRequest.toJson(),
    GetSuggestionBoxResponse.fromJson,
  );

  debugPrint("GetSuggestionBoxResponse ${getSuggestionBoxResponse.toJson()}");
  return getSuggestionBoxResponse;
}

class CreateSuggestionRequest {
/*
{
  "againstTeacherId": 0,
  "agent": 0,
  "anonymous": true,
  "description": "string",
  "postingStudentId": 0,
  "postingUserId": 0,
  "schoolId": 0,
  "title": "string"
}
*/

  int? againstTeacherId;
  String? againstTeacherName;
  int? agent;
  bool? anonymous;
  String? description;
  int? postingStudentId;
  int? postingUserId;
  int? schoolId;
  String? title;
  Map<String, dynamic> __origJson = {};

  CreateSuggestionRequest({
    this.againstTeacherId,
    this.againstTeacherName,
    this.agent,
    this.anonymous,
    this.description,
    this.postingStudentId,
    this.postingUserId,
    this.schoolId,
    this.title,
  });
  CreateSuggestionRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    againstTeacherId = int.tryParse(json['againstTeacherId']?.toString() ?? '');
    againstTeacherName = json['againstTeacherId']?.toString() ?? '';
    agent = int.tryParse(json['agent']?.toString() ?? '');
    anonymous = json['anonymous'];
    description = json['description']?.toString();
    postingStudentId = int.tryParse(json['postingStudentId']?.toString() ?? '');
    postingUserId = int.tryParse(json['postingUserId']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    title = json['title']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['againstTeacherId'] = againstTeacherId;
    data['againstTeacherName'] = againstTeacherName;
    data['agent'] = agent;
    data['anonymous'] = anonymous;
    data['description'] = description;
    data['postingStudentId'] = postingStudentId;
    data['postingUserId'] = postingUserId;
    data['schoolId'] = schoolId;
    data['title'] = title;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateSuggestionResponse {
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

  CreateSuggestionResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateSuggestionResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateSuggestionResponse> createSuggestion(CreateSuggestionRequest createSuggestionRequest) async {
  debugPrint("Raising request to createSuggestion with request ${jsonEncode(createSuggestionRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_SUGGESTION;

  CreateSuggestionResponse createSuggestionResponse = await HttpUtils.post(
    _url,
    createSuggestionRequest.toJson(),
    CreateSuggestionResponse.fromJson,
  );

  debugPrint("createSuggestionResponse ${createSuggestionResponse.toJson()}");
  return createSuggestionResponse;
}

class UpdateSuggestionRequest {
/*
{
  "agent": 0,
  "complaintId": 0,
  "complaintStatus": "INITIATED",
  "schoolId": 0
}
*/

  int? agent;
  int? complaintId;
  String? complaintStatus;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  UpdateSuggestionRequest({
    this.agent,
    this.complaintId,
    this.complaintStatus,
    this.status,
    this.schoolId,
  });
  UpdateSuggestionRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = int.tryParse(json['agent']?.toString() ?? '');
    complaintId = int.tryParse(json['complaintId']?.toString() ?? '');
    complaintStatus = json['complaintStatus']?.toString();
    status = json['status']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['complaintId'] = complaintId;
    data['complaintStatus'] = complaintStatus;
    data['status'] = status;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class UpdateSuggestionResponse {
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

  UpdateSuggestionResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  UpdateSuggestionResponse.fromJson(Map<String, dynamic> json) {
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

Future<UpdateSuggestionResponse> updateSuggestion(UpdateSuggestionRequest updateSuggestionRequest) async {
  debugPrint("Raising request to updateSuggestion with request ${jsonEncode(updateSuggestionRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_SUGGESTION;

  UpdateSuggestionResponse updateSuggestionResponse = await HttpUtils.post(
    _url,
    updateSuggestionRequest.toJson(),
    UpdateSuggestionResponse.fromJson,
  );

  debugPrint("updateSuggestionResponse ${updateSuggestionResponse.toJson()}");
  return updateSuggestionResponse;
}
