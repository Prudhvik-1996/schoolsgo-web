import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudyMaterialRequest {
/*
{
  "assignmentAndStudyMaterialId": 0,
  "limit": 0,
  "offset": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? assignmentAndStudyMaterialId;
  int? limit;
  int? offset;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetStudyMaterialRequest({
    this.assignmentAndStudyMaterialId,
    this.limit,
    this.offset,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });
  GetStudyMaterialRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    assignmentAndStudyMaterialId = int.tryParse(json['assignmentAndStudyMaterialId']?.toString() ?? '');
    limit = int.tryParse(json['limit']?.toString() ?? '');
    offset = int.tryParse(json['offset']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    studentId = int.tryParse(json['studentId']?.toString() ?? '');
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['assignmentAndStudyMaterialId'] = assignmentAndStudyMaterialId;
    data['limit'] = limit;
    data['offset'] = offset;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudyMaterialMedia {
/*
{
  "agentId": "string",
  "assignmentAndStudyMaterialId": 0,
  "assignmentAndStudyMaterialMediaId": 0,
  "assignmentAndStudyMaterialMediaStatus": "active",
  "createdTime": 0,
  "description": "string",
  "lastUpdatedTime": 0,
  "mediaId": 0,
  "mediaType": "string",
  "mediaUrl": "string",
  "status": "active"
}
*/

  String? agentId;
  int? assignmentAndStudyMaterialId;
  int? assignmentAndStudyMaterialMediaId;
  String? assignmentAndStudyMaterialMediaStatus;
  int? createdTime;
  String? description;
  int? lastUpdatedTime;
  int? mediaId;
  String? mediaType;
  String? mediaUrl;
  String? status;
  Map<String, dynamic> __origJson = {};

  StudyMaterialMedia({
    this.agentId,
    this.assignmentAndStudyMaterialId,
    this.assignmentAndStudyMaterialMediaId,
    this.assignmentAndStudyMaterialMediaStatus,
    this.createdTime,
    this.description,
    this.lastUpdatedTime,
    this.mediaId,
    this.mediaType,
    this.mediaUrl,
    this.status,
  });
  StudyMaterialMedia.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toString();
    assignmentAndStudyMaterialId = int.tryParse(json['assignmentAndStudyMaterialId']?.toString() ?? '');
    assignmentAndStudyMaterialMediaId = int.tryParse(json['assignmentAndStudyMaterialMediaId']?.toString() ?? '');
    assignmentAndStudyMaterialMediaStatus = json['assignmentAndStudyMaterialMediaStatus']?.toString();
    createdTime = int.tryParse(json['createdTime']?.toString() ?? '');
    description = json['description']?.toString();
    lastUpdatedTime = int.tryParse(json['lastUpdatedTime']?.toString() ?? '');
    mediaId = int.tryParse(json['mediaId']?.toString() ?? '');
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['assignmentAndStudyMaterialId'] = assignmentAndStudyMaterialId;
    data['assignmentAndStudyMaterialMediaId'] = assignmentAndStudyMaterialMediaId;
    data['assignmentAndStudyMaterialMediaStatus'] = assignmentAndStudyMaterialMediaStatus;
    data['createdTime'] = createdTime;
    data['description'] = description;
    data['lastUpdatedTime'] = lastUpdatedTime;
    data['mediaId'] = mediaId;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudyMaterial {
/*
{
  "agentId": "string",
  "assignmentAndStudyMaterialId": 0,
  "createdTime": 0,
  "description": "string",
  "dueDate": 0,
  "lastUpdated": 0,
  "mediaList": [
    {
      "agentId": "string",
      "assignmentAndStudyMaterialId": 0,
      "assignmentAndStudyMaterialMediaId": 0,
      "assignmentAndStudyMaterialMediaStatus": "active",
      "createdTime": 0,
      "description": "string",
      "lastUpdatedTime": 0,
      "mediaId": 0,
      "mediaType": "string",
      "mediaUrl": "string",
      "status": "active"
    }
  ],
  "sectionId": 0,
  "sectionName": "string",
  "status": "active",
  "studyMaterialType": "ASSIGNMENT",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  String? agentId;
  int? assignmentAndStudyMaterialId;
  int? createdTime;
  String? description;
  int? dueDate;
  int? lastUpdated;
  List<StudyMaterialMedia?>? mediaList;
  int? sectionId;
  String? sectionName;
  String? status;
  String? studyMaterialType;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;
  DateTime createTime = DateTime.now();

  StudyMaterial({
    this.agentId,
    this.assignmentAndStudyMaterialId,
    this.createdTime,
    this.description,
    this.dueDate,
    this.lastUpdated,
    this.mediaList,
    this.sectionId,
    this.sectionName,
    this.status,
    this.studyMaterialType,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  });
  StudyMaterial.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toString();
    assignmentAndStudyMaterialId = int.tryParse(json['assignmentAndStudyMaterialId']?.toString() ?? '');
    createdTime = int.tryParse(json['createdTime']?.toString() ?? '');
    DateTime x = createdTime == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(createdTime!);
    createTime = DateTime(
      x.year,
      x.month,
      x.day,
    );
    description = json['description']?.toString();
    dueDate = int.tryParse(json['dueDate']?.toString() ?? '');
    lastUpdated = int.tryParse(json['lastUpdated']?.toString() ?? '');
    if (json['mediaList'] != null && (json['mediaList'] is List)) {
      final v = json['mediaList'];
      final arr0 = <StudyMaterialMedia>[];
      v.forEach((v) {
        arr0.add(StudyMaterialMedia.fromJson(v));
      });
      mediaList = arr0;
    }
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    studyMaterialType = json['studyMaterialType']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    subjectName = json['subjectName']?.toString();
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherName = json['teacherName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['assignmentAndStudyMaterialId'] = assignmentAndStudyMaterialId;
    data['createdTime'] = createdTime;
    data['description'] = description;
    data['dueDate'] = dueDate;
    data['lastUpdated'] = lastUpdated;
    if (mediaList != null) {
      final v = mediaList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['mediaList'] = arr0;
    }
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['studyMaterialType'] = studyMaterialType;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudyMaterialResponse {
/*
{
  "assignmentsAndStudyMaterialBeans": [
    {
      "agentId": "string",
      "assignmentAndStudyMaterialId": 0,
      "createdTime": 0,
      "description": "string",
      "dueDate": 0,
      "lastUpdated": 0,
      "mediaList": [
        {
          "agentId": "string",
          "assignmentAndStudyMaterialId": 0,
          "assignmentAndStudyMaterialMediaId": 0,
          "assignmentAndStudyMaterialMediaStatus": "active",
          "createdTime": 0,
          "description": "string",
          "lastUpdatedTime": 0,
          "mediaId": 0,
          "mediaType": "string",
          "mediaUrl": "string",
          "status": "active"
        }
      ],
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "studyMaterialType": "ASSIGNMENT",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "totalAssignmentsAndStudyMaterialBeans": 0
}
*/

  List<StudyMaterial?>? assignmentsAndStudyMaterialBeans;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? totalAssignmentsAndStudyMaterialBeans;
  Map<String, dynamic> __origJson = {};

  GetStudyMaterialResponse({
    this.assignmentsAndStudyMaterialBeans,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.totalAssignmentsAndStudyMaterialBeans,
  });
  GetStudyMaterialResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['assignmentsAndStudyMaterialBeans'] != null && (json['assignmentsAndStudyMaterialBeans'] is List)) {
      final v = json['assignmentsAndStudyMaterialBeans'];
      final arr0 = <StudyMaterial>[];
      v.forEach((v) {
        arr0.add(StudyMaterial.fromJson(v));
      });
      assignmentsAndStudyMaterialBeans = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    totalAssignmentsAndStudyMaterialBeans = int.tryParse(json['totalAssignmentsAndStudyMaterialBeans']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (assignmentsAndStudyMaterialBeans != null) {
      final v = assignmentsAndStudyMaterialBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['assignmentsAndStudyMaterialBeans'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['totalAssignmentsAndStudyMaterialBeans'] = totalAssignmentsAndStudyMaterialBeans;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudyMaterialResponse> getStudyMaterial(GetStudyMaterialRequest getStudyMaterialRequest) async {
  debugPrint("Raising request to getStudyMaterial with request ${jsonEncode(getStudyMaterialRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDY_MATERIAL;

  GetStudyMaterialResponse getStudyMaterialResponse = await HttpUtils.post(
    _url,
    getStudyMaterialRequest.toJson(),
    GetStudyMaterialResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("GetStudyMaterialResponse ${getStudyMaterialResponse.toJson()}");
  return getStudyMaterialResponse;
}

class CreateOrUpdateStudyMaterialRequest {
/*
{
  "agentId": 0,
  "assignmentsAndStudyMaterialId": 0,
  "description": "string",
  "dueDate": 0,
  "schoolId": 0,
  "status": "active",
  "studyMaterialType": "ASSIGNMENT",
  "tdsId": 0
}
*/

  int? agentId;
  int? assignmentsAndStudyMaterialId;
  String? description;
  int? dueDate;
  int? schoolId;
  String? status;
  String? studyMaterialType;
  int? tdsId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudyMaterialRequest({
    this.agentId,
    this.assignmentsAndStudyMaterialId,
    this.description,
    this.dueDate,
    this.schoolId,
    this.status,
    this.studyMaterialType,
    this.tdsId,
  });
  CreateOrUpdateStudyMaterialRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json['agentId']?.toString() ?? '');
    assignmentsAndStudyMaterialId = int.tryParse(json['assignmentsAndStudyMaterialId']?.toString() ?? '');
    description = json['description']?.toString();
    dueDate = int.tryParse(json['dueDate']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    status = json['status']?.toString();
    studyMaterialType = json['studyMaterialType']?.toString();
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['assignmentsAndStudyMaterialId'] = assignmentsAndStudyMaterialId;
    data['description'] = description;
    data['dueDate'] = dueDate;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['studyMaterialType'] = studyMaterialType;
    data['tdsId'] = tdsId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudyMaterialResponse {
/*
{
  "assignmentAndStudyMaterialId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? assignmentAndStudyMaterialId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudyMaterialResponse({
    this.assignmentAndStudyMaterialId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateStudyMaterialResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    assignmentAndStudyMaterialId = int.tryParse(json['assignmentAndStudyMaterialId']?.toString() ?? '');
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['assignmentAndStudyMaterialId'] = assignmentAndStudyMaterialId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateStudyMaterialResponse> createOrUpdateStudyMaterial(CreateOrUpdateStudyMaterialRequest createOrUpdateStudyMaterialRequest) async {
  debugPrint("Raising request to createOrUpdateStudyMaterial with request ${jsonEncode(createOrUpdateStudyMaterialRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDY_MATERIAL;

  CreateOrUpdateStudyMaterialResponse createOrUpdateStudyMaterialResponse = await HttpUtils.post(
    _url,
    createOrUpdateStudyMaterialRequest.toJson(),
    CreateOrUpdateStudyMaterialResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("createOrUpdateStudyMaterialResponse ${createOrUpdateStudyMaterialResponse.toJson()}");
  return createOrUpdateStudyMaterialResponse;
}

class CreateOrUpdateStudyMaterialMediaMapRequest {
/*
{
  "agentId": 0,
  "mediaList": [
    {
      "agentId": "string",
      "assignmentAndStudyMaterialId": 0,
      "assignmentAndStudyMaterialMediaId": 0,
      "assignmentAndStudyMaterialMediaStatus": "active",
      "createdTime": 0,
      "description": "string",
      "lastUpdatedTime": 0,
      "mediaId": 0,
      "mediaType": "string",
      "mediaUrl": "string",
      "status": "active"
    }
  ],
  "schoolId": 0
}
*/

  int? agentId;
  List<StudyMaterialMedia?>? mediaList;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudyMaterialMediaMapRequest({
    this.agentId,
    this.mediaList,
    this.schoolId,
  });
  CreateOrUpdateStudyMaterialMediaMapRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json['agentId']?.toString() ?? '');
    if (json['mediaList'] != null && (json['mediaList'] is List)) {
      final v = json['mediaList'];
      final arr0 = <StudyMaterialMedia>[];
      v.forEach((v) {
        arr0.add(StudyMaterialMedia.fromJson(v));
      });
      mediaList = arr0;
    }
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    if (mediaList != null) {
      final v = mediaList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['mediaList'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudyMaterialMediaMapResponse {
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

  CreateOrUpdateStudyMaterialMediaMapResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateStudyMaterialMediaMapResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateStudyMaterialMediaMapResponse> createOrUpdateStudyMaterialMediaMap(
    CreateOrUpdateStudyMaterialMediaMapRequest createOrUpdateStudyMaterialMediaMapRequest) async {
  debugPrint(
      "Raising request to createOrUpdateStudyMaterialMediaMap with request ${jsonEncode(createOrUpdateStudyMaterialMediaMapRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDY_MATERIAL_MEDIA_MAP;

  CreateOrUpdateStudyMaterialMediaMapResponse createOrUpdateStudyMaterialMediaMapResponse = await HttpUtils.post(
    _url,
    createOrUpdateStudyMaterialMediaMapRequest.toJson(),
    CreateOrUpdateStudyMaterialMediaMapResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("createOrUpdateStudyMaterialMediaMapResponse ${createOrUpdateStudyMaterialMediaMapResponse.toJson()}");
  return createOrUpdateStudyMaterialMediaMapResponse;
}

enum StudyMaterialType { ASSIGNMENT, STUDY_MATERIAL, QUESTION_PAPER }
