import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetDiaryRequest {
/*
{
  "date": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subjectId": 0,
  "teacherId": 0
}
*/

  String? date;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetDiaryRequest({
    this.date,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.teacherId,
  });
  GetDiaryRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    studentId = int.tryParse(json['studentId']?.toString() ?? '');
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DiaryEntry {
/*
{
  "assignment": "string",
  "date": "string",
  "diaryFolderId": 0,
  "diaryId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "teacherFirstName": "string",
  "teacherId": 0,
  "teacherRemarks": "string"
}
*/

  String? assignment;
  String? date;
  int? diaryFolderId;
  int? diaryId;
  int? sectionId;
  String? sectionName;
  int? subjectId;
  String? subjectName;
  String? teacherFirstName;
  int? teacherId;
  String? teacherRemarks;
  int? sectionSeqOrder;
  int? subjectSeqOrder;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  DiaryEntry({
    this.assignment,
    this.date,
    this.diaryFolderId,
    this.diaryId,
    this.sectionId,
    this.sectionName,
    this.subjectId,
    this.subjectName,
    this.teacherFirstName,
    this.teacherId,
    this.teacherRemarks,
    this.sectionSeqOrder,
    this.subjectSeqOrder,
  });
  DiaryEntry.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    assignment = json['assignment']?.toString();
    date = json['date']?.toString();
    diaryFolderId = json['diaryFolderId']?.toInt();
    diaryId = json['diaryId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    teacherFirstName = json['teacherFirstName']?.toString();
    teacherId = json['teacherId']?.toInt();
    teacherRemarks = json['teacherRemarks']?.toString();
    sectionSeqOrder = json['sectionSeqOrder']?.toInt();
    subjectSeqOrder = json['subjectSeqOrder']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['assignment'] = assignment;
    data['date'] = date;
    data['diaryFolderId'] = diaryFolderId;
    data['diaryId'] = diaryId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['teacherFirstName'] = teacherFirstName;
    data['teacherId'] = teacherId;
    data['teacherRemarks'] = teacherRemarks;
    data['sectionSeqOrder'] = sectionSeqOrder;
    data['subjectSeqOrder'] = subjectSeqOrder;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentDiaryResponse {
/*
{
  "diaryEntries": [
    {
      "assignment": "string",
      "date": "string",
      "diaryFolderId": 0,
      "diaryId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "teacherFirstName": "string",
      "teacherId": 0,
      "teacherRemarks": "string"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<DiaryEntry?>? diaryEntries;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetStudentDiaryResponse({
    this.diaryEntries,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetStudentDiaryResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['diaryEntries'] != null) {
      final v = json['diaryEntries'];
      final arr0 = <DiaryEntry>[];
      v.forEach((v) {
        arr0.add(DiaryEntry.fromJson(v));
      });
      diaryEntries = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (diaryEntries != null) {
      final v = diaryEntries;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['diaryEntries'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentDiaryResponse> getDiary(GetDiaryRequest getDiaryRequest) async {
  debugPrint("Raising request to getDiary with request ${jsonEncode(getDiaryRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_DIARY;

  GetStudentDiaryResponse getDiaryResponse = await HttpUtils.post(
    _url,
    getDiaryRequest.toJson(),
    GetStudentDiaryResponse.fromJson,
  );

  debugPrint("GetDiaryResponse ${getDiaryResponse.toJson()}");
  return getDiaryResponse;
}

class CreateOrUpdateDiaryRequest {
/*
{
  "agentId": 0,
  "assignment": "string",
  "date": 0,
  "diaryId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "status": "active",
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0,
  "teacherRemarks": "string"
}
*/

  int? agentId;
  String? assignment;
  String? date;
  int? diaryId;
  int? schoolId;
  int? sectionId;
  String? status;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  String? teacherRemarks;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateDiaryRequest({
    this.agentId,
    this.assignment,
    this.date,
    this.diaryId,
    this.schoolId,
    this.sectionId,
    this.status,
    this.subjectId,
    this.tdsId,
    this.teacherId,
    this.teacherRemarks,
  });
  CreateOrUpdateDiaryRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json['agentId']?.toString() ?? '');
    assignment = json['assignment']?.toString();
    date = json['date']?.toString();
    diaryId = int.tryParse(json['diaryId']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    status = json['status']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherRemarks = json['teacherRemarks']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['assignment'] = assignment;
    data['date'] = date;
    data['diaryId'] = diaryId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherRemarks'] = teacherRemarks;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateDiaryResponse {
/*
{
  "diaryId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? diaryId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateDiaryResponse({
    this.diaryId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateDiaryResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    diaryId = int.tryParse(json['diaryId']?.toString() ?? '');
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['diaryId'] = diaryId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateDiaryResponse> createOrUpdateDiary(CreateOrUpdateDiaryRequest createOrUpdateDiaryRequest) async {
  debugPrint("Raising request to createOrUpdateDiary with request ${jsonEncode(createOrUpdateDiaryRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_DIARY;

  CreateOrUpdateDiaryResponse createOrUpdateDiaryResponse = await HttpUtils.post(
    _url,
    createOrUpdateDiaryRequest.toJson(),
    CreateOrUpdateDiaryResponse.fromJson,
  );

  debugPrint("createOrUpdateDiaryResponse ${createOrUpdateDiaryResponse.toJson()}");
  return createOrUpdateDiaryResponse;
}
