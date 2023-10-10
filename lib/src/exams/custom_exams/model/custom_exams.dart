import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/model/exam_section_subject_map.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetCustomExamsRequest {
  int? academicYearId;
  int? customExamId;
  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetCustomExamsRequest({
    this.academicYearId,
    this.customExamId,
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.teacherId,
  });

  GetCustomExamsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    customExamId = json['customExamId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['customExamId'] = customExamId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CustomExam {
  int? academicYearId;
  int? agent;
  String? comment;
  int? customExamId;
  String? customExamName;
  String? date;
  List<ExamSectionSubjectMap?>? examSectionSubjectMapList;
  String? examType;
  int? markingAlgorithmId;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  CustomExam({
    this.academicYearId,
    this.agent,
    this.comment,
    this.customExamId,
    this.customExamName,
    this.date,
    this.examSectionSubjectMapList,
    this.examType,
    this.markingAlgorithmId,
    this.schoolId,
    this.status,
  });

  CustomExam.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    customExamId = json['customExamId']?.toInt();
    customExamName = json['customExamName']?.toString();
    date = json['date']?.toString();
    if (json['examSectionSubjectMapList'] != null) {
      final v = json['examSectionSubjectMapList'];
      final arr0 = <ExamSectionSubjectMap>[];
      v.forEach((v) {
        arr0.add(ExamSectionSubjectMap.fromJson(v));
      });
      examSectionSubjectMapList = arr0;
    }
    examType = json['examType']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['agent'] = agent;
    data['comment'] = comment;
    data['customExamId'] = customExamId;
    data['customExamName'] = customExamName;
    data['date'] = date;
    if (examSectionSubjectMapList != null) {
      final v = examSectionSubjectMapList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['examSectionSubjectMapList'] = arr0;
    }
    data['examType'] = examType;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  double? get average {
    double totalMarksObtained = (examSectionSubjectMapList ?? [])
        .map((e) => (e?.studentExamMarksList ?? []).map((e) => e?.isAbsent != "N" ? null : e?.marksObtained))
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .fold<double>(0.0, (double a, double b) => a + b);
    double totalMaxMarks = (examSectionSubjectMapList ?? [])
        .map((e) => e?.maxMarks)
        .where((e) => e != null)
        .map((e) => e!)
        .fold<double>(0.0, (double a, double b) => a + b);
    return totalMaxMarks == 0 ? null : ((totalMarksObtained * 100 / totalMaxMarks) * 100).toInt() / 100.0;
  }

  double? getPercentage(int studentId) {
    double totalMarksObtained = (examSectionSubjectMapList ?? [])
        .map((e) => (e?.studentExamMarksList ?? []).where((e) => e?.studentId == studentId).map((e) => e?.isAbsent == "Y" ? null : e?.marksObtained))
        .expand((i) => i)
        .where((e) => e != null)
        .map((e) => e!)
        .fold<double>(0.0, (double a, double b) => a + b);
    double totalMaxMarks = (examSectionSubjectMapList ?? [])
        .map((e) => e?.maxMarks)
        .where((e) => e != null)
        .map((e) => e!)
        .fold<double>(0.0, (double a, double b) => a + b);
    return totalMaxMarks == 0 ? null : double.parse(((totalMarksObtained / totalMaxMarks) * 100).toStringAsFixed(2));
  }
}

class GetCustomExamsResponse {
  List<CustomExam?>? customExamsList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetCustomExamsResponse({
    this.customExamsList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetCustomExamsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['customExamsList'] != null) {
      final v = json['customExamsList'];
      final arr0 = <CustomExam>[];
      v.forEach((v) {
        arr0.add(CustomExam.fromJson(v));
      });
      customExamsList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (customExamsList != null) {
      final v = customExamsList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['customExamsList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetCustomExamsResponse> getCustomExams(GetCustomExamsRequest getCustomExamsRequest) async {
  debugPrint("Raising request to getCustomExams with request ${jsonEncode(getCustomExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_CUSTOM_EXAMS;

  GetCustomExamsResponse getCustomExamsResponse = await HttpUtils.post(
    _url,
    getCustomExamsRequest.toJson(),
    GetCustomExamsResponse.fromJson,
  );

  debugPrint("GetCustomExamsResponse ${getCustomExamsResponse.toJson()}");
  return getCustomExamsResponse;
}

class CreateOrUpdateCustomExamRequest {
  int? academicYearId;
  int? agent;
  String? comment;
  int? customExamId;
  String? customExamName;
  String? date;
  List<ExamSectionSubjectMap?>? examSectionSubjectMapList;
  String? examType;
  int? markingAlgorithmId;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateCustomExamRequest({
    this.academicYearId,
    this.agent,
    this.comment,
    this.customExamId,
    this.customExamName,
    this.date,
    this.examSectionSubjectMapList,
    this.examType,
    this.markingAlgorithmId,
    this.schoolId,
    this.status,
  });

  CreateOrUpdateCustomExamRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    customExamId = json['customExamId']?.toInt();
    customExamName = json['customExamName']?.toString();
    date = json['date']?.toString();
    if (json['examSectionSubjectMapList'] != null) {
      final v = json['examSectionSubjectMapList'];
      final arr0 = <ExamSectionSubjectMap>[];
      v.forEach((v) {
        arr0.add(ExamSectionSubjectMap.fromJson(v));
      });
      examSectionSubjectMapList = arr0;
    }
    examType = json['examType']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['agent'] = agent;
    data['comment'] = comment;
    data['customExamId'] = customExamId;
    data['customExamName'] = customExamName;
    data['date'] = date;
    if (examSectionSubjectMapList != null) {
      final v = examSectionSubjectMapList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examSectionSubjectMapList'] = arr0;
    }
    data['examType'] = examType;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateCustomExamResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateCustomExamResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateCustomExamResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateCustomExamResponse> createOrUpdateCustomExam(CreateOrUpdateCustomExamRequest createOrUpdateCustomExamRequest) async {
  debugPrint("Raising request to createOrUpdateCustomExam with request ${jsonEncode(createOrUpdateCustomExamRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_CUSTOM_EXAMS;

  CreateOrUpdateCustomExamResponse createOrUpdateCustomExamResponse = await HttpUtils.post(
    _url,
    createOrUpdateCustomExamRequest.toJson(),
    CreateOrUpdateCustomExamResponse.fromJson,
  );

  debugPrint("createOrUpdateCustomExamResponse ${createOrUpdateCustomExamResponse.toJson()}");
  return createOrUpdateCustomExamResponse;
}
