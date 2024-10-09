import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GenerateStudentMemosRequest {

  int? mainExamId;
  List<int?>? otherExamIds;
  int? schoolId;
  int? sectionId;
  bool? showAttendanceTable;
  bool? showBlankAttendance;
  bool? showGraph;
  bool? showHeader;
  bool? showOnlyCumulativeExams;
  bool? showRemarks;
  List<int?>? studentIds;
  Map<String, dynamic> __origJson = {};

  String? mainExamType;

  GenerateStudentMemosRequest({
    this.mainExamId,
    this.otherExamIds,
    this.schoolId,
    this.sectionId,
    this.showAttendanceTable,
    this.showBlankAttendance,
    this.showGraph,
    this.showHeader,
    this.showOnlyCumulativeExams,
    this.showRemarks,
    this.studentIds,
    this.mainExamType,
  });
  GenerateStudentMemosRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    mainExamId = json['mainExamId']?.toInt();
    if (json['otherExamIds'] != null) {
      final v = json['otherExamIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      otherExamIds = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    showAttendanceTable = json['showAttendanceTable'];
    showBlankAttendance = json['showBlankAttendance'];
    showGraph = json['showGraph'];
    showHeader = json['showHeader'];
    showOnlyCumulativeExams = json['showOnlyCumulativeExams'];
    showRemarks = json['showRemarks'];
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
    data['mainExamId'] = mainExamId;
    if (otherExamIds != null) {
      final v = otherExamIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['otherExamIds'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['showAttendanceTable'] = showAttendanceTable;
    data['showBlankAttendance'] = showBlankAttendance;
    data['showGraph'] = showGraph;
    data['showHeader'] = showHeader;
    data['showOnlyCumulativeExams'] = showOnlyCumulativeExams;
    data['showRemarks'] = showRemarks;
    if (studentIds != null) {
      final v = studentIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['studentIds'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<List<int>> downloadMemosForMainExamWithInternals(GenerateStudentMemosRequest getStudentMemosRequest) async {
  debugPrint("Raising request to downloadMemosForMainExamWithInternals with request ${jsonEncode(getStudentMemosRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + DOWNLOAD_MEMOS_FOR_MAIN_EXAM_WITH_INTERNALS;
  return await HttpUtils.postToDownloadFile(_url, getStudentMemosRequest.toJson());
}

Future<List<int>> downloadMemosForMainExamWithoutInternals(GenerateStudentMemosRequest getStudentMemosRequest) async {
  debugPrint("Raising request to downloadMemosForMainExamWithoutInternals with request ${jsonEncode(getStudentMemosRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + DOWNLOAD_MEMOS_FOR_MAIN_EXAM_WITH_OUT_INTERNALS;
  return await HttpUtils.postToDownloadFile(_url, getStudentMemosRequest.toJson());
}

Future<GetCustomExamsResponse> getAllExams(GetCustomExamsRequest getCustomExamsRequest) async {
  debugPrint("Raising request to getCustomExams with request ${jsonEncode(getCustomExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ALL_EXAMS;

  GetCustomExamsResponse getCustomExamsResponse = await HttpUtils.post(
    _url,
    getCustomExamsRequest.toJson(),
    GetCustomExamsResponse.fromJson,
  );

  debugPrint("GetCustomExamsResponse ${getCustomExamsResponse.toJson()}");
  return getCustomExamsResponse;
}