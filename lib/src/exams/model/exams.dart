import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetExamsRequest {
/*
{
  "examId": 0,
  "examType": "SLIP_TEST",
  "schoolId": 0,
  "sectionId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? examId;
  String? examType;
  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetExamsRequest({
    this.examId,
    this.examType,
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });
  GetExamsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examType = json['examType']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['examId'] = examId;
    data['examType'] = examType;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Exam {
/*
{
  "agent": "string",
  "examId": 0,
  "examName": "string",
  "examStartDate": "string",
  "examStatus": "active",
  "examType": "SLIP_TEST",
  "markingAlgorithmId": 0,
  "markingAlgorithmName": "string",
  "markingSchemeCode": "A",
  "schoolId": 0,
  "schoolName": "string"
}
*/

  String? agent;
  int? examId;
  String? examName;
  String? examStartDate;
  String? examStatus;
  String? examType;
  int? markingAlgorithmId;
  String? markingAlgorithmName;
  String? markingSchemeCode;
  int? schoolId;
  String? schoolName;
  Map<String, dynamic> __origJson = {};

  Exam({
    this.agent,
    this.examId,
    this.examName,
    this.examStartDate,
    this.examStatus,
    this.examType,
    this.markingAlgorithmId,
    this.markingAlgorithmName,
    this.markingSchemeCode,
    this.schoolId,
    this.schoolName,
  });
  Exam.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examStartDate = json['examStartDate']?.toString();
    examStatus = json['examStatus']?.toString();
    examType = json['examType']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmName = json['markingAlgorithmName']?.toString();
    markingSchemeCode = json['markingSchemeCode']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examStartDate'] = examStartDate;
    data['examStatus'] = examStatus;
    data['examType'] = examType;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmName'] = markingAlgorithmName;
    data['markingSchemeCode'] = markingSchemeCode;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetExamsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "exams": [
    {
      "agent": "string",
      "examId": 0,
      "examName": "string",
      "examStartDate": "string",
      "examStatus": "active",
      "examType": "SLIP_TEST",
      "markingAlgorithmId": 0,
      "markingAlgorithmName": "string",
      "markingSchemeCode": "A",
      "schoolId": 0,
      "schoolName": "string"
    }
  ],
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  List<Exam?>? exams;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetExamsResponse({
    this.errorCode,
    this.errorMessage,
    this.exams,
    this.httpStatus,
    this.responseStatus,
  });
  GetExamsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['exams'] != null) {
      final v = json['exams'];
      final arr0 = <Exam>[];
      v.forEach((v) {
        arr0.add(Exam.fromJson(v));
      });
      exams = arr0;
    }
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    if (exams != null) {
      final v = exams;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['exams'] = arr0;
    }
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetExamsResponse> getExams(GetExamsRequest getExamsRequest) async {
  print(
      "Raising request to getExams with request ${jsonEncode(getExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EXAMS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getExamsRequest.toJson()),
  );

  GetExamsResponse getExamsResponse =
      GetExamsResponse.fromJson(json.decode(response.body));
  print("GetExamsResponse ${getExamsResponse.toJson()}");
  return getExamsResponse;
}
