import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/exams/topic_wise_exams/model/topic_wise_exams.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudentWiseExamsRequest {
  int? academicYearId;
  int? schoolId;
  List<int?>? studentIds;
  Map<String, dynamic> __origJson = {};

  GetStudentWiseExamsRequest({
    this.academicYearId,
    this.schoolId,
    this.studentIds,
  });

  GetStudentWiseExamsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['studentIds'] != null) {
      final v = json['studentIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      studentIds = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['schoolId'] = schoolId;
    if (studentIds != null) {
      final v = studentIds;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['studentIds'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentWiseExamsResponse {
  List<CustomExam?>? customExams;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<TopicWiseExam?>? topicWiseExams;
  Map<String, dynamic> __origJson = {};

  GetStudentWiseExamsResponse({
    this.customExams,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.topicWiseExams,
  });

  GetStudentWiseExamsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['customExams'] != null) {
      final v = json['customExams'];
      final arr0 = <CustomExam>[];
      v.forEach((v) {
        arr0.add(CustomExam.fromJson(v));
      });
      customExams = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['topicWiseExams'] != null) {
      final v = json['topicWiseExams'];
      final arr0 = <TopicWiseExam>[];
      v.forEach((v) {
        arr0.add(TopicWiseExam.fromJson(v));
      });
      topicWiseExams = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (customExams != null) {
      final v = customExams;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['customExams'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (topicWiseExams != null) {
      final v = topicWiseExams;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['topicWiseExams'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentWiseExamsResponse> getStudentWiseExams(GetStudentWiseExamsRequest getStudentWiseExamsRequest) async {
  debugPrint("Raising request to getStudentWiseExams with request ${jsonEncode(getStudentWiseExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_WISE_EXAMS;

  GetStudentWiseExamsResponse getStudentWiseExamsResponse = await HttpUtils.post(
    _url,
    getStudentWiseExamsRequest.toJson(),
    GetStudentWiseExamsResponse.fromJson,
  );

  debugPrint("GetStudentWiseExamsResponse ${getStudentWiseExamsResponse.toJson()}");
  return getStudentWiseExamsResponse;
}
