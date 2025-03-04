import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSubjectsRequest {
/*
{
  "schoolId": 0,
  "subjectId": 0
}
*/

  int? schoolId;
  int? subjectId;
  int? academicYearId;
  Map<String, dynamic> __origJson = {};

  GetSubjectsRequest({
    this.schoolId,
    this.subjectId,
    this.academicYearId,
  });

  GetSubjectsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    academicYearId = int.tryParse(json["academicYearId"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["schoolId"] = schoolId;
    data["subjectId"] = subjectId;
    data["academicYearId"] = academicYearId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Subject {
/*
{
  "subjectId": 0,
  "schoolId": 0,
  "subjectName": "",
  "description": "",
  "agent": ""
}
*/

  int? subjectId;
  int? schoolId;
  String? subjectName;
  String? description;
  int? seqOrder;
  String? agent;
  Map<String, dynamic> __origJson = {};

  Subject({
    this.subjectId,
    this.schoolId,
    this.subjectName,
    this.description,
    this.seqOrder,
    this.agent,
  });

  Subject.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    subjectName = json["subjectName"]?.toString();
    description = json["description"]?.toString();
    seqOrder = int.tryParse(json["seqOrder"]?.toString() ?? '');
    agent = json["agent"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["subjectId"] = subjectId;
    data["schoolId"] = schoolId;
    data["subjectName"] = subjectName;
    data["description"] = description;
    data["seqOrder"] = seqOrder;
    data["agent"] = agent;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  int compareTo(other) {
    return subjectId!.compareTo(other.subjectId);
  }

  @override
  int get hashCode => subjectId ?? 0;

  @override
  bool operator ==(other) {
    return compareTo(other) == 0;
  }

  @override
  String toString() {
    return "Subject: {'subjectId': $subjectId, 'subjectName: $subjectName}";
  }
}

class GetSubjectsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "subjects": [
    {
      "subjectId": 0,
      "schoolId": 0,
      "subjectName": "",
      "description": "",
      "agent": ""
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<Subject?>? subjects;
  Map<String, dynamic> __origJson = {};

  GetSubjectsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.subjects,
  });

  GetSubjectsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
    if (json["subjects"] != null && (json["subjects"] is List)) {
      final v = json["subjects"];
      final arr0 = <Subject>[];
      v.forEach((v) {
        arr0.add(Subject.fromJson(v));
      });
      subjects = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    if (subjects != null) {
      final v = subjects;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["subjects"] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSubjectsResponse> getSubjects(GetSubjectsRequest getSubjectsRequest) async {
  debugPrint("Raising request to getSubjects with request ${jsonEncode(getSubjectsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SUBJECTS;

  GetSubjectsResponse getSubjectsResponse = await HttpUtils.post(
    _url,
    getSubjectsRequest.toJson(),
    GetSubjectsResponse.fromJson,
  );

  debugPrint("GetSubjectsResponse ${getSubjectsResponse.toJson()}");
  return getSubjectsResponse;
}

class CreateOrUpdateSubjectRequest {
/*
{
  "agent": "string",
  "description": "string",
  "schoolId": 0,
  "seqOrder": 0,
  "subjectId": 0,
  "subjectName": "string"
}
*/

  String? agent;
  String? description;
  int? schoolId;
  int? seqOrder;
  int? subjectId;
  String? subjectName;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateSubjectRequest({
    this.agent,
    this.description,
    this.schoolId,
    this.seqOrder,
    this.subjectId,
    this.subjectName,
  });

  CreateOrUpdateSubjectRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    description = json['description']?.toString();
    schoolId = json['schoolId']?.toInt();
    seqOrder = json['seqOrder']?.toInt();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['description'] = description;
    data['schoolId'] = schoolId;
    data['seqOrder'] = seqOrder;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSubjectResponse {
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

  CreateOrUpdateSubjectResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateSubjectResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateSubjectResponse> createOrUpdateSubject(CreateOrUpdateSubjectRequest createOrUpdateSubjectRequest) async {
  debugPrint("Raising request to createOrUpdateSubject with request ${jsonEncode(createOrUpdateSubjectRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SUBJECT;

  CreateOrUpdateSubjectResponse createOrUpdateSubjectResponse = await HttpUtils.post(
    _url,
    createOrUpdateSubjectRequest.toJson(),
    CreateOrUpdateSubjectResponse.fromJson,
  );

  debugPrint("CreateOrUpdateSubjectResponse ${createOrUpdateSubjectResponse.toJson()}");
  return createOrUpdateSubjectResponse;
}

class CreateOrUpdateSubjectsRequest {
/*
{
  "agentId": 0,
  "schoolId": 0,
  "subjectsList": [
    {
      "agent": "string",
      "description": "string",
      "schoolId": 0,
      "seqOrder": 0,
      "subjectId": 0,
      "subjectName": "string"
    }
  ]
}
*/

  int? agentId;
  int? schoolId;
  List<Subject?>? subjectsList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateSubjectsRequest({
    this.agentId,
    this.schoolId,
    this.subjectsList,
  });

  CreateOrUpdateSubjectsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['subjectsList'] != null) {
      final v = json['subjectsList'];
      final arr0 = <Subject>[];
      v.forEach((v) {
        arr0.add(Subject.fromJson(v));
      });
      subjectsList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['schoolId'] = schoolId;
    if (subjectsList != null) {
      final v = subjectsList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['subjectsList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSubjectsResponse {
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

  CreateOrUpdateSubjectsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateSubjectsResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateSubjectsResponse> createOrUpdateSubjects(CreateOrUpdateSubjectsRequest createOrUpdateSubjectsRequest) async {
  debugPrint("Raising request to createOrUpdateSubjects with request ${jsonEncode(createOrUpdateSubjectsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SUBJECTS;

  CreateOrUpdateSubjectsResponse createOrUpdateSubjectsResponse = await HttpUtils.post(
    _url,
    createOrUpdateSubjectsRequest.toJson(),
    CreateOrUpdateSubjectsResponse.fromJson,
  );

  debugPrint("CreateOrUpdateSubjectsResponse ${createOrUpdateSubjectsResponse.toJson()}");
  return createOrUpdateSubjectsResponse;
}
