import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetExamTopicsRequest {
/*
{
  "academicYearId": 0,
  "schoolId": 0,
  "tdsId": 0,
  "topicId": 0
}
*/

  int? academicYearId;
  int? schoolId;
  int? tdsId;
  int? topicId;
  Map<String, dynamic> __origJson = {};

  GetExamTopicsRequest({
    this.academicYearId,
    this.schoolId,
    this.tdsId,
    this.topicId,
  });
  GetExamTopicsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    topicId = json['topicId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['schoolId'] = schoolId;
    data['tdsId'] = tdsId;
    data['topicId'] = topicId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class ExamTopic {
/*
{
  "academicYearId": 0,
  "agent": 0,
  "comment": "string",
  "status": "active",
  "tdsId": 0,
  "topicId": 0,
  "topicName": "string"
}
*/

  int? academicYearId;
  int? agent;
  String? comment;
  String? status;
  int? tdsId;
  int? topicId;
  String? topicName;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  ExamTopic({
    this.academicYearId,
    this.agent,
    this.comment,
    this.status,
    this.tdsId,
    this.topicId,
    this.topicName,
  });
  ExamTopic.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    status = json['status']?.toString();
    tdsId = json['tdsId']?.toInt();
    topicId = json['topicId']?.toInt();
    topicName = json['topicName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['agent'] = agent;
    data['comment'] = comment;
    data['status'] = status;
    data['tdsId'] = tdsId;
    data['topicId'] = topicId;
    data['topicName'] = topicName;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;


}

class GetExamTopicsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "examTopics": [
    {
      "academicYearId": 0,
      "agent": 0,
      "comment": "string",
      "status": "active",
      "tdsId": 0,
      "topicId": 0,
      "topicName": "string"
    }
  ],
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  List<ExamTopic?>? examTopics;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetExamTopicsResponse({
    this.errorCode,
    this.errorMessage,
    this.examTopics,
    this.httpStatus,
    this.responseStatus,
  });
  GetExamTopicsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['examTopics'] != null) {
      final v = json['examTopics'];
      final arr0 = <ExamTopic>[];
      v.forEach((v) {
        arr0.add(ExamTopic.fromJson(v));
      });
      examTopics = arr0;
    }
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    if (examTopics != null) {
      final v = examTopics;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examTopics'] = arr0;
    }
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetExamTopicsResponse> getExamTopics(GetExamTopicsRequest getExamTopicsRequest) async {
  debugPrint("Raising request to getExamTopics with request ${jsonEncode(getExamTopicsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EXAM_TOPICS;

  GetExamTopicsResponse getExamTopicsResponse = await HttpUtils.post(
    _url,
    getExamTopicsRequest.toJson(),
    GetExamTopicsResponse.fromJson,
  );

  debugPrint("GetExamTopicsResponse ${getExamTopicsResponse.toJson()}");
  return getExamTopicsResponse;
}

class CreateOrUpdateExamTopicsRequest {
/*
{
  "agent": 0,
  "examTopics": [
    {
      "academicYearId": 0,
      "agent": 0,
      "comment": "string",
      "status": "active",
      "tdsId": 0,
      "topicId": 0,
      "topicName": "string"
    }
  ],
  "schoolId": 0
}
*/

  int? agent;
  List<ExamTopic?>? examTopics;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateExamTopicsRequest({
    this.agent,
    this.examTopics,
    this.schoolId,
  });
  CreateOrUpdateExamTopicsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['examTopics'] != null) {
      final v = json['examTopics'];
      final arr0 = <ExamTopic>[];
      v.forEach((v) {
        arr0.add(ExamTopic.fromJson(v));
      });
      examTopics = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (examTopics != null) {
      final v = examTopics;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examTopics'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateExamTopicsResponse {
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

  CreateOrUpdateExamTopicsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateExamTopicsResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateExamTopicsResponse> createOrUpdateExamTopics(CreateOrUpdateExamTopicsRequest createOrUpdateExamTopicsRequest) async {
  debugPrint("Raising request to createOrUpdateExamTopics with request ${jsonEncode(createOrUpdateExamTopicsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_EXAM_TOPICS;

  CreateOrUpdateExamTopicsResponse createOrUpdateExamTopicsResponse = await HttpUtils.post(
    _url,
    createOrUpdateExamTopicsRequest.toJson(),
    CreateOrUpdateExamTopicsResponse.fromJson,
  );

  debugPrint("CreateOrUpdateExamTopicsResponse ${createOrUpdateExamTopicsResponse.toJson()}");
  return createOrUpdateExamTopicsResponse;
}
