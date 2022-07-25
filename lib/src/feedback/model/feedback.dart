import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudentToTeacherFeedbackRequest {
/*
{
  "adminView": true,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0,
  "teacherWiseAverageRating": true
}
*/

  bool? adminView;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  bool? teacherWiseAverageRating;
  Map<String, dynamic> __origJson = {};

  GetStudentToTeacherFeedbackRequest({
    this.adminView,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
    this.teacherWiseAverageRating,
  });
  GetStudentToTeacherFeedbackRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    adminView = json['adminView'];
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    studentId = int.tryParse(json['studentId']?.toString() ?? '');
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherWiseAverageRating = json['teacherWiseAverageRating'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminView'] = adminView;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherWiseAverageRating'] = teacherWiseAverageRating;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentToTeacherFeedback {
/*
{
  "anonymus": true,
  "createTime": 0,
  "feedbackId": 0,
  "lastUpdated": 0,
  "rating": 0,
  "review": "string",
  "schoolId": 0,
  "schoolName": "string",
  "sectionId": 0,
  "sectionName": "string",
  "status": "active",
  "studentId": 0,
  "studentName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  bool? anonymus;
  int? createTime;
  int? feedbackId;
  int? lastUpdated;
  double? rating;
  String? review;
  int? schoolId;
  String? schoolName;
  int? sectionId;
  String? sectionName;
  String? status;
  int? studentId;
  String? studentName;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  double? averageRating;
  Map<String, dynamic> __origJson = {};

  bool isEdited = false;

  StudentToTeacherFeedback({
    this.anonymus,
    this.createTime,
    this.feedbackId,
    this.lastUpdated,
    this.rating,
    this.review,
    this.schoolId,
    this.schoolName,
    this.sectionId,
    this.sectionName,
    this.status,
    this.studentId,
    this.studentName,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
    this.averageRating,
  });
  StudentToTeacherFeedback.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    anonymus = json['anonymus'];
    createTime = int.tryParse(json['createTime']?.toString() ?? '');
    feedbackId = int.tryParse(json['feedbackId']?.toString() ?? '');
    lastUpdated = int.tryParse(json['lastUpdated']?.toString() ?? '');
    rating = double.tryParse(json['rating']?.toString() ?? '');
    review = json['review']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    schoolName = json['schoolName']?.toString();
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    studentId = int.tryParse(json['studentId']?.toString() ?? '');
    studentName = json['studentName']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    subjectName = json['subjectName']?.toString();
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherName = json['teacherName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['anonymus'] = anonymus;
    data['createTime'] = createTime;
    data['feedbackId'] = feedbackId;
    data['lastUpdated'] = lastUpdated;
    data['rating'] = rating;
    data['review'] = review;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentToTeacherFeedbackResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "feedbackBeans": [
    {
      "anonymus": true,
      "createTime": 0,
      "feedbackId": 0,
      "lastUpdated": 0,
      "rating": 0,
      "review": "string",
      "schoolId": 0,
      "schoolName": "string",
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "studentId": 0,
      "studentName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  List<StudentToTeacherFeedback?>? feedbackBeans;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetStudentToTeacherFeedbackResponse({
    this.errorCode,
    this.errorMessage,
    this.feedbackBeans,
    this.httpStatus,
    this.responseStatus,
  });
  GetStudentToTeacherFeedbackResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['feedbackBeans'] != null && (json['feedbackBeans'] is List)) {
      final v = json['feedbackBeans'];
      final arr0 = <StudentToTeacherFeedback>[];
      v.forEach((v) {
        arr0.add(StudentToTeacherFeedback.fromJson(v));
      });
      feedbackBeans = arr0;
    }
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    if (feedbackBeans != null) {
      final v = feedbackBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['feedbackBeans'] = arr0;
    }
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentToTeacherFeedbackResponse> getStudentToTeacherFeedback(GetStudentToTeacherFeedbackRequest getStudentToTeacherFeedbackRequest) async {
  debugPrint("Raising request to getStudentToTeacherFeedback with request ${jsonEncode(getStudentToTeacherFeedbackRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_TO_TEACHER_FEEDBACK;

  GetStudentToTeacherFeedbackResponse getStudentToTeacherFeedbackResponse = await HttpUtils.post(
    _url,
    getStudentToTeacherFeedbackRequest.toJson(),
    GetStudentToTeacherFeedbackResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("GetStudentToTeacherFeedbackResponse ${getStudentToTeacherFeedbackResponse.toJson()}");
  return getStudentToTeacherFeedbackResponse;
}

class CreateOrUpdateStudentToTeacherFeedbackRequest {
/*
{
  "feedbackBeans": [
    {
      "anonymus": true,
      "createTime": 0,
      "feedbackId": 0,
      "lastUpdated": 0,
      "rating": 0,
      "review": "string",
      "schoolId": 0,
      "schoolName": "string",
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "studentId": 0,
      "studentName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "schoolId": 0
}
*/

  List<StudentToTeacherFeedback?>? feedbackBeans;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentToTeacherFeedbackRequest({
    this.feedbackBeans,
    this.schoolId,
  });
  CreateOrUpdateStudentToTeacherFeedbackRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['feedbackBeans'] != null && (json['feedbackBeans'] is List)) {
      final v = json['feedbackBeans'];
      final arr0 = <StudentToTeacherFeedback>[];
      v.forEach((v) {
        arr0.add(StudentToTeacherFeedback.fromJson(v));
      });
      feedbackBeans = arr0;
    }
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (feedbackBeans != null) {
      final v = feedbackBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['feedbackBeans'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentToTeacherFeedbackResponse {
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

  CreateOrUpdateStudentToTeacherFeedbackResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateStudentToTeacherFeedbackResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateStudentToTeacherFeedbackResponse> createOrUpdateStudentToTeacherFeedback(
    CreateOrUpdateStudentToTeacherFeedbackRequest createStudentToTeacherFeedbackRequest) async {
  debugPrint("Raising request to createStudentToTeacherFeedback with request ${jsonEncode(createStudentToTeacherFeedbackRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_TO_TEACHER_FEEDBACK;

  CreateOrUpdateStudentToTeacherFeedbackResponse createStudentToTeacherFeedbackResponse = await HttpUtils.post(
    _url,
    createStudentToTeacherFeedbackRequest.toJson(),
    CreateOrUpdateStudentToTeacherFeedbackResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("createStudentToTeacherFeedbackResponse ${createStudentToTeacherFeedbackResponse.toJson()}");
  return createStudentToTeacherFeedbackResponse;
}
