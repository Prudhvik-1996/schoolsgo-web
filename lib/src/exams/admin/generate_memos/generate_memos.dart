import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class MergeSubjectsForMemoBean {
  int? subjectId;
  List<int?>? childrenSubjectIds;
  Map<String, dynamic> __origJson = {};

  ScrollController scrollController = ScrollController();

  MergeSubjectsForMemoBean({
    this.subjectId,
    this.childrenSubjectIds,
  });

  MergeSubjectsForMemoBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    subjectId = json['subjectId']?.toInt();
    if (json['childrenSubjectIds'] != null) {
      final v = json['childrenSubjectIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      childrenSubjectIds = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['subjectId'] = subjectId;
    if (childrenSubjectIds != null) {
      final v = childrenSubjectIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['childrenSubjectIds'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

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
  List<String?>? monthYearsForAttendance;
  String? studentPhotoSize;
  List<MergeSubjectsForMemoBean?>? mergeSubjectsForMemoBeans;
  List<int?>? otherSubjectIds;
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
    this.monthYearsForAttendance,
    this.studentPhotoSize,
    this.mergeSubjectsForMemoBeans,
    this.otherSubjectIds,
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
    if (json['monthYearsForAttendance'] != null) {
      final v = json['monthYearsForAttendance'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      monthYearsForAttendance = arr0;
    }
    studentPhotoSize = json['studentPhotoSize'];
    if (json['mergeSubjectsForMemoBeans'] != null) {
      final v = json['mergeSubjectsForMemoBeans'];
      final arr0 = <MergeSubjectsForMemoBean>[];
      v.forEach((v) {
        arr0.add(MergeSubjectsForMemoBean.fromJson(v));
      });
      mergeSubjectsForMemoBeans = arr0;
    }
    if (json['otherSubjectIds'] != null) {
      final v = json['otherSubjectIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      otherSubjectIds = arr0;
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
    if (monthYearsForAttendance != null) {
      final v = monthYearsForAttendance;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['monthYearsForAttendance'] = arr0;
    }
    data['studentPhotoSize'] = studentPhotoSize;
    if (mergeSubjectsForMemoBeans != null) {
      final v = mergeSubjectsForMemoBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['mergeSubjectsForMemoBeans'] = arr0;
    }
    if (otherSubjectIds != null) {
      final v = otherSubjectIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['otherSubjectIds'] = arr0;
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

Future<List<int>> downloadExamSummaryForStudent(GenerateStudentMemosRequest getStudentMemosRequest) async {
  debugPrint("Raising request to downloadExamSummaryForStudent with request ${jsonEncode(getStudentMemosRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + DOWNLOAD_STUDENT_EXAM_SUMAMRY;
  return await HttpUtils.postToDownloadFile(_url, getStudentMemosRequest.toJson());
}

class GetCustomExamsForStudentsSummaryResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<CustomExam?>? mainExams;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetCustomExamsForStudentsSummaryResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.mainExams,
    this.responseStatus,
  });

  GetCustomExamsForStudentsSummaryResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['mainExams'] != null) {
      final v = json['mainExams'];
      final arr0 = <CustomExam>[];
      v.forEach((v) {
        arr0.add(CustomExam.fromJson(v));
      });
      mainExams = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (mainExams != null) {
      final v = mainExams;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['mainExams'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetCustomExamsForStudentsSummaryResponse> getExamsForStudentsSummary(GenerateStudentMemosRequest getExamsForStudentsSummary) async {
  debugPrint("Raising request to getFeeTypes with request ${jsonEncode(getExamsForStudentsSummary.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EXAMS_FOR_STUDENTS_SUMMARY;

  GetCustomExamsForStudentsSummaryResponse getFeeTypesResponse = await HttpUtils.post(
    _url,
    getExamsForStudentsSummary.toJson(),
    GetCustomExamsForStudentsSummaryResponse.fromJson,
  );

  debugPrint("GetCustomExamsForStudentsSummaryResponse ${getFeeTypesResponse.toJson()}");
  return getFeeTypesResponse;
}
