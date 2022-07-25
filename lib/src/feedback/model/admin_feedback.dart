import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudentToTeacherFeedbackAdminViewRequest {
/*
{
  "schoolId": 0,
  "sectionId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetStudentToTeacherFeedbackAdminViewRequest({
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });

  GetStudentToTeacherFeedbackAdminViewRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DateWiseFeedbackBean {
/*
{
  "avgRating": 0,
  "date": "string",
  "noOfStudents": 0,
  "schoolId": 0,
  "schoolName": "string",
  "sectionId": 0,
  "sectionName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  double? avgRating;
  String? date;
  int? noOfStudents;
  int? schoolId;
  String? schoolName;
  int? sectionId;
  String? sectionName;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  DateWiseFeedbackBean({
    this.avgRating,
    this.date,
    this.noOfStudents,
    this.schoolId,
    this.schoolName,
    this.sectionId,
    this.sectionName,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  });

  DateWiseFeedbackBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    avgRating = json['avgRating']?.toDouble();
    date = json['date']?.toString();
    noOfStudents = json['noOfStudents']?.toInt();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['avgRating'] = avgRating;
    data['date'] = date;
    data['noOfStudents'] = noOfStudents;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "{'date': $date, 'tdsId': $tdsId, 'avgRating': $avgRating, 'noOfStudents': $noOfStudents}";
  }
}

class FeedbackPlotBean {
/*
{
  "cumulativeAverageRating": 0,
  "dateWiseFeedbackBeans": [
    {
      "avgRating": 0,
      "date": "string",
      "noOfStudents": 0,
      "schoolId": 0,
      "schoolName": "string",
      "sectionId": 0,
      "sectionName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "sectionId": 0,
  "sectionName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  double? cumulativeAverageRating;
  List<DateWiseFeedbackBean?>? dateWiseFeedbackBeans;
  int? sectionId;
  String? sectionName;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  FeedbackPlotBean({
    this.cumulativeAverageRating,
    this.dateWiseFeedbackBeans,
    this.sectionId,
    this.sectionName,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  });

  FeedbackPlotBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    cumulativeAverageRating = json['cumulativeAverageRating']?.toDouble();
    if (json['dateWiseFeedbackBeans'] != null) {
      final v = json['dateWiseFeedbackBeans'];
      final arr0 = <DateWiseFeedbackBean>[];
      v.forEach((v) {
        arr0.add(DateWiseFeedbackBean.fromJson(v));
      });
      dateWiseFeedbackBeans = arr0;
    }
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cumulativeAverageRating'] = cumulativeAverageRating;
    if (dateWiseFeedbackBeans != null) {
      final v = dateWiseFeedbackBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['dateWiseFeedbackBeans'] = arr0;
    }
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentToTeacherFeedbackAdminViewResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "feedbackPlotBeans": [
    {
      "cumulativeAverageRating": 0,
      "dateWiseFeedbackBeans": [
        {
          "avgRating": 0,
          "date": "string",
          "noOfStudents": 0,
          "schoolId": 0,
          "schoolName": "string",
          "sectionId": 0,
          "sectionName": "string",
          "subjectId": 0,
          "subjectName": "string",
          "tdsId": 0,
          "teacherId": 0,
          "teacherName": "string"
        }
      ],
      "sectionId": 0,
      "sectionName": "string",
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
  List<FeedbackPlotBean?>? allTdsWiseFeedbackPlotBeans;
  List<FeedbackPlotBean?>? allTeacherWiseFeedbackPlotBeans;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetStudentToTeacherFeedbackAdminViewResponse({
    this.errorCode,
    this.errorMessage,
    this.allTdsWiseFeedbackPlotBeans,
    this.allTeacherWiseFeedbackPlotBeans,
    this.httpStatus,
    this.responseStatus,
  });

  GetStudentToTeacherFeedbackAdminViewResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['allTdsWiseFeedbackPlotBeans'] != null) {
      final v = json['allTdsWiseFeedbackPlotBeans'];
      final arr0 = <FeedbackPlotBean>[];
      v.forEach((v) {
        arr0.add(FeedbackPlotBean.fromJson(v));
      });
      allTdsWiseFeedbackPlotBeans = arr0;
    }
    if (json['allTeacherWiseFeedbackPlotBeans'] != null) {
      final v = json['allTeacherWiseFeedbackPlotBeans'];
      final arr0 = <FeedbackPlotBean>[];
      v.forEach((v) {
        arr0.add(FeedbackPlotBean.fromJson(v));
      });
      allTeacherWiseFeedbackPlotBeans = arr0;
    }
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    if (allTdsWiseFeedbackPlotBeans != null) {
      final v = allTdsWiseFeedbackPlotBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['allTdsWiseFeedbackPlotBeans'] = arr0;
    }
    if (allTeacherWiseFeedbackPlotBeans != null) {
      final v = allTeacherWiseFeedbackPlotBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['allTeacherWiseFeedbackPlotBeans'] = arr0;
    }
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentToTeacherFeedbackAdminViewResponse> getStudentToTeacherFeedbackAdminView(
    GetStudentToTeacherFeedbackAdminViewRequest getStudentToTeacherFeedbackAdminViewRequest) async {
  debugPrint(
      "Raising request to getStudentToTeacherFeedbackAdminView with request ${jsonEncode(getStudentToTeacherFeedbackAdminViewRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_TO_TEACHER_FEEDBACK_ADMIN_VIEW;

  GetStudentToTeacherFeedbackAdminViewResponse getStudentToTeacherFeedbackAdminViewResponse = await HttpUtils.post(
    _url,
    getStudentToTeacherFeedbackAdminViewRequest.toJson(),
    GetStudentToTeacherFeedbackAdminViewResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("GetStudentToTeacherFeedbackAdminViewResponse ${getStudentToTeacherFeedbackAdminViewResponse.toJson()}");
  return getStudentToTeacherFeedbackAdminViewResponse;
}
