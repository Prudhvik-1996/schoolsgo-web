import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class StudentExamMediaBean {
/*
{
  "agent": 0,
  "comment": "string",
  "marksId": 0,
  "marksMediaId": 0,
  "mediaType": "string",
  "mediaUrl": "string",
  "mediaUrlId": 0,
  "status": "active"
} 
*/

  int? agent;
  String? comment;
  int? marksId;
  int? marksMediaId;
  String? mediaType;
  String? mediaUrl;
  int? mediaUrlId;
  String? status;
  Map<String, dynamic> __origJson = {};

  StudentExamMediaBean({
    this.agent,
    this.comment,
    this.marksId,
    this.marksMediaId,
    this.mediaType,
    this.mediaUrl,
    this.mediaUrlId,
    this.status,
  });
  StudentExamMediaBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    marksId = json['marksId']?.toInt();
    marksMediaId = json['marksMediaId']?.toInt();
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    mediaUrlId = json['mediaUrlId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['comment'] = comment;
    data['marksId'] = marksId;
    data['marksMediaId'] = marksMediaId;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['mediaUrlId'] = mediaUrlId;
    data['status'] = status;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class StudentExamMarks {
/*
{
  "agent": 0,
  "comment": "string",
  "examId": 0,
  "examSectionSubjectMapId": 0,
  "marksId": 0,
  "marksObtained": 0,
  "studentExamMediaBeans": [
    {
      "agent": 0,
      "comment": "string",
      "marksId": 0,
      "marksMediaId": 0,
      "mediaType": "string",
      "mediaUrl": "string",
      "mediaUrlId": 0,
      "status": "active"
    }
  ],
  "studentId": 0
} 
*/

  int? agent;
  String? comment;
  int? examId;
  int? examSectionSubjectMapId;
  int? marksId;
  double? marksObtained;
  String? isAbsent;
  List<StudentExamMediaBean?>? studentExamMediaBeans;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  ScrollController mediaScrollController = ScrollController();

  StudentExamMarks({
    this.agent,
    this.comment,
    this.examId,
    this.examSectionSubjectMapId,
    this.marksId,
    this.marksObtained,
    this.isAbsent,
    this.studentExamMediaBeans,
    this.studentId,
  });
  StudentExamMarks.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    examId = json['examId']?.toInt();
    examSectionSubjectMapId = json['examSectionSubjectMapId']?.toInt();
    marksId = json['marksId']?.toInt();
    marksObtained = json['marksObtained']?.toDouble();
    isAbsent = json['isAbsent']?.toString();
    if (json['studentExamMediaBeans'] != null) {
      final v = json['studentExamMediaBeans'];
      final arr0 = <StudentExamMediaBean>[];
      v.forEach((v) {
        arr0.add(StudentExamMediaBean.fromJson(v));
      });
      studentExamMediaBeans = arr0;
    }
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['comment'] = comment;
    data['examId'] = examId;
    data['examSectionSubjectMapId'] = examSectionSubjectMapId;
    data['marksId'] = marksId;
    data['marksObtained'] = marksObtained;
    data['isAbsent'] = isAbsent;
    if (studentExamMediaBeans != null) {
      final v = studentExamMediaBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentExamMediaBeans'] = arr0;
    }
    data['studentId'] = studentId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateExamMarksRequest {
/*
{
  "agent": 0,
  "examMarks": [
    {
      "agent": 0,
      "comment": "string",
      "examId": 0,
      "examSectionSubjectMapId": 0,
      "marksId": 0,
      "marksObtained": 0,
      "studentExamMediaBeans": [
        {
          "agent": 0,
          "comment": "string",
          "marksId": 0,
          "marksMediaId": 0,
          "mediaType": "string",
          "mediaUrl": "string",
          "mediaUrlId": 0,
          "status": "active"
        }
      ],
      "studentId": 0
    }
  ],
  "schoolId": 0
}
*/

  int? agent;
  List<StudentExamMarks?>? examMarks;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateExamMarksRequest({
    this.agent,
    this.examMarks,
    this.schoolId,
  });
  CreateOrUpdateExamMarksRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['examMarks'] != null) {
      final v = json['examMarks'];
      final arr0 = <StudentExamMarks>[];
      v.forEach((v) {
        arr0.add(StudentExamMarks.fromJson(v));
      });
      examMarks = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (examMarks != null) {
      final v = examMarks;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examMarks'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateExamMarksResponse {
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

  CreateOrUpdateExamMarksResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateExamMarksResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateExamMarksResponse> createOrUpdateExamMarks(CreateOrUpdateExamMarksRequest createOrUpdateExamMarksRequest) async {
  debugPrint("Raising request to createOrUpdateExamMarks with request ${jsonEncode(createOrUpdateExamMarksRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_EXAM_MARKS;

  CreateOrUpdateExamMarksResponse createOrUpdateExamMarksResponse = await HttpUtils.post(
    _url,
    createOrUpdateExamMarksRequest.toJson(),
    CreateOrUpdateExamMarksResponse.fromJson,
  );

  debugPrint("CreateOrUpdateExamMarksResponse ${createOrUpdateExamMarksResponse.toJson()}");
  return createOrUpdateExamMarksResponse;
}
