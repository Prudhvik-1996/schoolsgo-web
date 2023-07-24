import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/model/student_exam_marks.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetTopicWiseExamsRequest {
/*
{
  "academicYearId": 0,
  "schoolId": 0,
  "tdsId": 0,
  "topicId": 0
}
*/

  int? academicYearId;
  int? schoolId;
  int? tdsId;
  int? topicId;
  Map<String, dynamic> __origJson = {};

  GetTopicWiseExamsRequest({
    this.academicYearId,
    this.schoolId,
    this.tdsId,
    this.topicId,
  });

  GetTopicWiseExamsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    topicId = json['topicId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['schoolId'] = schoolId;
    data['tdsId'] = tdsId;
    data['topicId'] = topicId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TopicWiseExam {
/*
{
  "academicYearId": 0,
  "agent": 0,
  "authorisedAgent": 0,
  "comment": "string",
  "date": "string",
  "endTime": "string",
  "examId": 0,
  "examName": "string",
  "examSectionSubjectMapId": 0,
  "examType": "SLIP_TEST",
  "maxMarks": 0,
  "schoolId": 0,
  "sectionId": 0,
  "startTime": "string",
  "status": "active",
  "studentExamMarksList": [
    {
      "agent": 0,
      "comment": "string",
      "examId": 0,
      "examSectionSubjectMapId": 0,
      "marksObtained": 0,
      "studentId": 0
    }
  ],
  "subjectId": 0,
  "topicId": 0,
  "topicName": "string"
}
*/

  int? academicYearId;
  int? agent;
  int? authorisedAgent;
  String? comment;
  String? date;
  String? endTime;
  int? examId;
  String? examName;
  int? examSectionSubjectMapId;
  String? examType;
  double? maxMarks;
  int? schoolId;
  int? sectionId;
  String? startTime;
  String? status;
  List<StudentExamMarks?>? studentExamMarksList;
  int? subjectId;
  int? topicId;
  String? topicName;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  TopicWiseExam({
    this.academicYearId,
    this.agent,
    this.authorisedAgent,
    this.comment,
    this.date,
    this.endTime,
    this.examId,
    this.examName,
    this.examSectionSubjectMapId,
    this.examType,
    this.maxMarks,
    this.schoolId,
    this.sectionId,
    this.startTime,
    this.status,
    this.studentExamMarksList,
    this.subjectId,
    this.topicId,
    this.topicName,
  });

  TopicWiseExam.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    agent = json['agent']?.toInt();
    authorisedAgent = json['authorisedAgent']?.toInt();
    comment = json['comment']?.toString();
    date = json['date']?.toString();
    endTime = json['endTime']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examSectionSubjectMapId = json['examSectionSubjectMapId']?.toInt();
    examType = json['examType']?.toString();
    maxMarks = json['maxMarks']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    if (json['studentExamMarksList'] != null) {
      final v = json['studentExamMarksList'];
      final arr0 = <StudentExamMarks>[];
      v.forEach((v) {
        arr0.add(StudentExamMarks.fromJson(v));
      });
      studentExamMarksList = arr0;
    }
    subjectId = json['subjectId']?.toInt();
    topicId = json['topicId']?.toInt();
    topicName = json['topicName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['agent'] = agent;
    data['authorisedAgent'] = authorisedAgent;
    data['comment'] = comment;
    data['date'] = date;
    data['endTime'] = endTime;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examSectionSubjectMapId'] = examSectionSubjectMapId;
    data['examType'] = examType;
    data['maxMarks'] = maxMarks;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['startTime'] = startTime;
    data['status'] = status;
    if (studentExamMarksList != null) {
      final v = studentExamMarksList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentExamMarksList'] = arr0;
    }
    data['subjectId'] = subjectId;
    data['topicId'] = topicId;
    data['topicName'] = topicName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  double? get classAverage => (studentExamMarksList ?? []).where((e) => e?.marksObtained != null).isEmpty
      ? null
      : (((studentExamMarksList ?? [])
                          .where((e) => e?.marksObtained != null)
                          .map((e) => e?.marksObtained ?? 0.0)
                          .fold<double>(0.0, (double a, double b) => a + b) /
                      (studentExamMarksList ?? []).where((e) => e?.marksObtained != null).length) *
                  100)
              .toInt() /
          100.0;

  String get examDate => date == null ? "-" : convertDateTimeToDDMMYYYYFormat(convertYYYYMMDDFormatToDateTime(date));

  String get examTimeSlot =>
      "${startTime == null ? "-" : convert24To12HourFormat(startTime!)} - ${endTime == null ? "-" : convert24To12HourFormat(endTime!)}";

  String get startTimeSlot => startTime == null ? "-" : convert24To12HourFormat(startTime!);

  String get endTimeSlot => endTime == null ? "-" : convert24To12HourFormat(endTime!);
}

class GetTopicWiseExamsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "topicWiseExams": [
    {
      "academicYearId": 0,
      "agent": 0,
      "authorisedAgent": 0,
      "comment": "string",
      "date": "string",
      "endTime": "string",
      "examId": 0,
      "examName": "string",
      "examSectionSubjectMapId": 0,
      "examType": "SLIP_TEST",
      "maxMarks": 0,
      "schoolId": 0,
      "sectionId": 0,
      "startTime": "string",
      "status": "active",
      "studentExamMarksList": [
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
      "subjectId": 0,
      "topicId": 0,
      "topicName": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<TopicWiseExam?>? topicWiseExams;
  Map<String, dynamic> __origJson = {};

  GetTopicWiseExamsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.topicWiseExams,
  });

  GetTopicWiseExamsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
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

Future<GetTopicWiseExamsResponse> getTopicWiseExams(GetTopicWiseExamsRequest getTopicWiseExamsRequest) async {
  debugPrint("Raising request to getTopicWiseExams with request ${jsonEncode(getTopicWiseExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TOPICS_WISE_EXAMS;

  GetTopicWiseExamsResponse getTopicWiseExamsResponse = await HttpUtils.post(
    _url,
    getTopicWiseExamsRequest.toJson(),
    GetTopicWiseExamsResponse.fromJson,
  );

  debugPrint("GetTopicWiseExamsResponse ${getTopicWiseExamsResponse.toJson()}");
  return getTopicWiseExamsResponse;
}

class CreateOrUpdateTopicWiseExamRequest {
/*
{
  "academicYearId": 0,
  "agent": 0,
  "authorisedAgent": 0,
  "comment": "string",
  "date": "string",
  "endTime": "string",
  "examId": 0,
  "examName": "string",
  "examSectionSubjectMapId": 0,
  "examType": "TOPIC",
  "maxMarks": 0,
  "schoolId": 0,
  "sectionId": 0,
  "startTime": "string",
  "status": "active",
  "subjectId": 0,
  "topicId": 0,
  "topicName": "string"
}
*/

  int? academicYearId;
  int? agent;
  int? authorisedAgent;
  String? comment;
  String? date;
  String? endTime;
  int? examId;
  String? examName;
  int? examSectionSubjectMapId;
  String? examType;
  double? maxMarks;
  int? schoolId;
  int? sectionId;
  String? startTime;
  String? status;
  int? subjectId;
  int? topicId;
  String? topicName;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTopicWiseExamRequest({
    this.academicYearId,
    this.agent,
    this.authorisedAgent,
    this.comment,
    this.date,
    this.endTime,
    this.examId,
    this.examName,
    this.examSectionSubjectMapId,
    this.examType,
    this.maxMarks,
    this.schoolId,
    this.sectionId,
    this.startTime,
    this.status,
    this.subjectId,
    this.topicId,
    this.topicName,
  });

  CreateOrUpdateTopicWiseExamRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    agent = json['agent']?.toInt();
    authorisedAgent = json['authorisedAgent']?.toInt();
    comment = json['comment']?.toString();
    date = json['date']?.toString();
    endTime = json['endTime']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examSectionSubjectMapId = json['examSectionSubjectMapId']?.toInt();
    examType = json['examType']?.toString();
    maxMarks = json['maxMarks']?.toDouble();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    subjectId = json['subjectId']?.toInt();
    topicId = json['topicId']?.toInt();
    topicName = json['topicName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['agent'] = agent;
    data['authorisedAgent'] = authorisedAgent;
    data['comment'] = comment;
    data['date'] = date;
    data['endTime'] = endTime;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examSectionSubjectMapId'] = examSectionSubjectMapId;
    data['examType'] = examType;
    data['maxMarks'] = maxMarks;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['startTime'] = startTime;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['topicId'] = topicId;
    data['topicName'] = topicName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateTopicWiseExamResponse {
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

  CreateOrUpdateTopicWiseExamResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateTopicWiseExamResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateTopicWiseExamResponse> createOrUpdateTopicWiseExam(CreateOrUpdateTopicWiseExamRequest createOrUpdateTopicWiseExamRequest) async {
  debugPrint("Raising request to createOrUpdateTopicWiseExam with request ${jsonEncode(createOrUpdateTopicWiseExamRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TOPICS_WISE_EXAMS;

  CreateOrUpdateTopicWiseExamResponse createOrUpdateTopicWiseExamResponse = await HttpUtils.post(
    _url,
    createOrUpdateTopicWiseExamRequest.toJson(),
    CreateOrUpdateTopicWiseExamResponse.fromJson,
  );

  debugPrint("CreateOrUpdateTopicWiseExamResponse ${createOrUpdateTopicWiseExamResponse.toJson()}");
  return createOrUpdateTopicWiseExamResponse;
}
