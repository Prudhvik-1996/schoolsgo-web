import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetAdminExamsRequest {
/*
{
  "examId": 0,
  "schoolId": 0,
  "examType": "TERM/SLIP_TEST"
}
*/

  int? examId;
  String? examType;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetAdminExamsRequest({
    this.examId,
    this.examType,
    this.schoolId,
  });
  GetAdminExamsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examType = json['examType']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['examId'] = examId;
    data['examType'] = examType;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class InternalExamTdsMapBean {
/*
{
  "endTime": "",
  "examId": 0,
  "examName": "string",
  "examTdsDate": "string",
  "examTdsMapId": 0,
  "internalExamId": 0,
  "internalExamMapTdsId": 0,
  "internalExamName": "string",
  "internalNumber": 0,
  "maxMarks": 0,
  "sectionId": 0,
  "sectionName": "string",
  "startTime": "",
  "status": "active",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  String? endTime;
  int? examId;
  String? examName;
  String? examTdsDate;
  int? examTdsMapId;
  int? internalExamId;
  int? internalExamMapTdsId;
  String? internalExamName;
  int? internalNumber;
  int? maxMarks;
  int? sectionId;
  String? sectionName;
  String? startTime;
  String? status;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  InternalExamTdsMapBean({
    this.endTime,
    this.examId,
    this.examName,
    this.examTdsDate,
    this.examTdsMapId,
    this.internalExamId,
    this.internalExamMapTdsId,
    this.internalExamName,
    this.internalNumber,
    this.maxMarks,
    this.sectionId,
    this.sectionName,
    this.startTime,
    this.status,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  });
  InternalExamTdsMapBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    endTime = json['endTime']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examTdsDate = json['examTdsDate']?.toString();
    examTdsMapId = json['examTdsMapId']?.toInt();
    internalExamId = json['internalExamId']?.toInt();
    internalExamMapTdsId = json['internalExamMapTdsId']?.toInt();
    internalExamName = json['internalExamName']?.toString();
    internalNumber = json['internalNumber']?.toInt();
    maxMarks = json['maxMarks']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['endTime'] = endTime;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examTdsDate'] = examTdsDate;
    data['examTdsMapId'] = examTdsMapId;
    data['internalExamId'] = internalExamId;
    data['internalExamMapTdsId'] = internalExamMapTdsId;
    data['internalExamName'] = internalExamName;
    data['internalNumber'] = internalNumber;
    data['maxMarks'] = maxMarks;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['startTime'] = startTime;
    data['status'] = status;
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
    return json.encode(toJson());
  }
}

class ExamTdsMapBean {
/*
{
  "endTime": "",
  "examId": 0,
  "examName": "string",
  "examTdsDate": "string",
  "examTdsMapId": 0,
  "internalExamTdsMapBeanList": [
    {
      "endTime": "",
      "examId": 0,
      "examName": "string",
      "examTdsDate": "string",
      "examTdsMapId": 0,
      "internalExamId": 0,
      "internalExamMapTdsId": 0,
      "internalExamName": "string",
      "internalNumber": 0,
      "maxMarks": 0,
      "sectionId": 0,
      "sectionName": "string",
      "startTime": "",
      "status": "active",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "internalsComputationCode": "A",
  "maxMarks": 0,
  "sectionId": 0,
  "sectionName": "string",
  "startTime": "",
  "status": "active",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  String? endTime;
  int? examId;
  String? examName;
  String? examTdsDate;
  int? examTdsMapId;
  List<InternalExamTdsMapBean?>? internalExamTdsMapBeanList;
  String? internalsComputationCode;
  int? maxMarks;
  int? sectionId;
  String? sectionName;
  String? startTime;
  String? status;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  TextEditingController maxMarksEditingController = TextEditingController();

  ExamTdsMapBean({
    this.endTime,
    this.examId,
    this.examName,
    this.examTdsDate,
    this.examTdsMapId,
    this.internalExamTdsMapBeanList,
    this.internalsComputationCode,
    this.maxMarks,
    this.sectionId,
    this.sectionName,
    this.startTime,
    this.status,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  }) {
    maxMarksEditingController.text = "${maxMarks ?? ""}";
  }

  ExamTdsMapBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    endTime = json['endTime']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examTdsDate = json['examTdsDate']?.toString();
    examTdsMapId = json['examTdsMapId']?.toInt();
    if (json['internalExamTdsMapBeanList'] != null) {
      final v = json['internalExamTdsMapBeanList'];
      final arr0 = <InternalExamTdsMapBean>[];
      v.forEach((v) {
        arr0.add(InternalExamTdsMapBean.fromJson(v));
      });
      internalExamTdsMapBeanList = arr0;
    }
    internalsComputationCode = json['internalsComputationCode']?.toString();
    maxMarks = json['maxMarks']?.toInt();
    maxMarksEditingController.text = "${maxMarks ?? ""}";
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['endTime'] = endTime;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examTdsDate'] = examTdsDate;
    data['examTdsMapId'] = examTdsMapId;
    if (internalExamTdsMapBeanList != null) {
      final v = internalExamTdsMapBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['internalExamTdsMapBeanList'] = arr0;
    }
    data['internalsComputationCode'] = internalsComputationCode;
    data['maxMarks'] = maxMarks;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['startTime'] = startTime;
    data['status'] = status;
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
    return json.encode(toJson());
  }
}

class ExamSectionMapBean {
/*
{
  "examId": 0,
  "examName": "string",
  "examSectionMapId": 0,
  "examTdsMapBeanList": [
    {
      "endTime": "",
      "examId": 0,
      "examName": "string",
      "examTdsDate": "string",
      "examTdsMapId": 0,
      "internalExamTdsMapBeanList": [
        {
          "endTime": "",
          "examId": 0,
          "examName": "string",
          "examTdsDate": "string",
          "examTdsMapId": 0,
          "internalExamId": 0,
          "internalExamMapTdsId": 0,
          "internalExamName": "string",
          "internalNumber": 0,
          "maxMarks": 0,
          "sectionId": 0,
          "sectionName": "string",
          "startTime": "",
          "status": "active",
          "subjectId": 0,
          "subjectName": "string",
          "tdsId": 0,
          "teacherId": 0,
          "teacherName": "string"
        }
      ],
      "internalsComputationCode": "A",
      "maxMarks": 0,
      "sectionId": 0,
      "sectionName": "string",
      "startTime": "",
      "status": "active",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "markingAlgorithmId": 0,
  "markingAlgorithmName": "string",
  "markingAlgorithmRangeBeanList": [
    {
      "algorithmName": "string",
      "endRange": 0,
      "gpa": 0,
      "grade": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "startRange": 0,
      "status": "active"
    }
  ],
  "markingSchemeCode": "A",
  "sectionId": 0,
  "sectionName": "string",
  "status": "active"
}
*/

  int? examId;
  String? examName;
  int? examSectionMapId;
  List<ExamTdsMapBean?>? examTdsMapBeanList;
  int? markingAlgorithmId;
  String? markingAlgorithmName;
  List<MarkingAlgorithmRangeBean?>? markingAlgorithmRangeBeanList;
  String? markingSchemeCode;
  int? sectionId;
  String? sectionName;
  String? status;
  Map<String, dynamic> __origJson = {};

  ExamSectionMapBean({
    this.examId,
    this.examName,
    this.examSectionMapId,
    this.examTdsMapBeanList,
    this.markingAlgorithmId,
    this.markingAlgorithmName,
    this.markingAlgorithmRangeBeanList,
    this.markingSchemeCode,
    this.sectionId,
    this.sectionName,
    this.status,
  });
  ExamSectionMapBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examSectionMapId = json['examSectionMapId']?.toInt();
    if (json['examTdsMapBeanList'] != null) {
      final v = json['examTdsMapBeanList'];
      final arr0 = <ExamTdsMapBean>[];
      v.forEach((v) {
        arr0.add(ExamTdsMapBean.fromJson(v));
      });
      examTdsMapBeanList = arr0;
    }
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmName = json['markingAlgorithmName']?.toString();
    if (json['markingAlgorithmRangeBeanList'] != null) {
      final v = json['markingAlgorithmRangeBeanList'];
      final arr0 = <MarkingAlgorithmRangeBean>[];
      v.forEach((v) {
        arr0.add(MarkingAlgorithmRangeBean.fromJson(v));
      });
      markingAlgorithmRangeBeanList = arr0;
    }
    markingSchemeCode = json['markingSchemeCode']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['examId'] = examId;
    data['examName'] = examName;
    data['examSectionMapId'] = examSectionMapId;
    if (examTdsMapBeanList != null) {
      final v = examTdsMapBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examTdsMapBeanList'] = arr0;
    }
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmName'] = markingAlgorithmName;
    if (markingAlgorithmRangeBeanList != null) {
      final v = markingAlgorithmRangeBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmRangeBeanList'] = arr0;
    }
    data['markingSchemeCode'] = markingSchemeCode;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class AdminExamBean {
/*
{
  "agent": 0,
  "examId": 0,
  "examName": "string",
  "examSectionMapBeanList": [
    {
      "examId": 0,
      "examName": "string",
      "examSectionMapId": 0,
      "examTdsMapBeanList": [
        {
          "endTime": "",
          "examId": 0,
          "examName": "string",
          "examTdsDate": "string",
          "examTdsMapId": 0,
          "internalExamTdsMapBeanList": [
            {
              "endTime": "",
              "examId": 0,
              "examName": "string",
              "examTdsDate": "string",
              "examTdsMapId": 0,
              "internalExamId": 0,
              "internalExamMapTdsId": 0,
              "internalExamName": "string",
              "internalNumber": 0,
              "maxMarks": 0,
              "sectionId": 0,
              "sectionName": "string",
              "startTime": "",
              "status": "active",
              "subjectId": 0,
              "subjectName": "string",
              "tdsId": 0,
              "teacherId": 0,
              "teacherName": "string"
            }
          ],
          "internalsComputationCode": "A",
          "maxMarks": 0,
          "sectionId": 0,
          "sectionName": "string",
          "startTime": "",
          "status": "active",
          "subjectId": 0,
          "subjectName": "string",
          "tdsId": 0,
          "teacherId": 0,
          "teacherName": "string"
        }
      ],
      "markingAlgorithmId": 0,
      "markingAlgorithmName": "string",
      "markingAlgorithmRangeBeanList": [
        {
          "algorithmName": "string",
          "endRange": 0,
          "gpa": 0,
          "grade": "string",
          "markingAlgorithmId": 0,
          "markingAlgorithmRangeId": 0,
          "schoolId": 0,
          "schoolName": "string",
          "startRange": 0,
          "status": "active"
        }
      ],
      "markingSchemeCode": "A",
      "sectionId": 0,
      "sectionName": "string",
      "status": "active"
    }
  ],
  "examStartDate": "string",
  "examType": "SLIP_TEST",
  "schoolId": 0,
  "status": "active"
}
*/

  int? agent;
  int? examId;
  String? examName;
  List<ExamSectionMapBean?>? examSectionMapBeanList;
  String? examStartDate;
  String? examType;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  AdminExamBean({
    this.agent,
    this.examId,
    this.examName,
    this.examSectionMapBeanList,
    this.examStartDate,
    this.examType,
    this.schoolId,
    this.status,
  });
  AdminExamBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    if (json['examSectionMapBeanList'] != null) {
      final v = json['examSectionMapBeanList'];
      final arr0 = <ExamSectionMapBean>[];
      v.forEach((v) {
        arr0.add(ExamSectionMapBean.fromJson(v));
      });
      examSectionMapBeanList = arr0;
    }
    examStartDate = json['examStartDate']?.toString();
    examType = json['examType']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['examId'] = examId;
    data['examName'] = examName;
    if (examSectionMapBeanList != null) {
      final v = examSectionMapBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['examSectionMapBeanList'] = arr0;
    }
    data['examStartDate'] = examStartDate;
    data['examType'] = examType;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class GetAdminExamsResponse {
/*
{
  "adminExamBeanList": [
    {
      "agent": 0,
      "examId": 0,
      "examName": "string",
      "examSectionMapBeanList": [
        {
          "examId": 0,
          "examName": "string",
          "examSectionMapId": 0,
          "examTdsMapBeanList": [
            {
              "endTime": "",
              "examId": 0,
              "examName": "string",
              "examTdsDate": "string",
              "examTdsMapId": 0,
              "internalExamTdsMapBeanList": [
                {
                  "endTime": "",
                  "examId": 0,
                  "examName": "string",
                  "examTdsDate": "string",
                  "examTdsMapId": 0,
                  "internalExamId": 0,
                  "internalExamMapTdsId": 0,
                  "internalExamName": "string",
                  "internalNumber": 0,
                  "maxMarks": 0,
                  "sectionId": 0,
                  "sectionName": "string",
                  "startTime": "",
                  "status": "active",
                  "subjectId": 0,
                  "subjectName": "string",
                  "tdsId": 0,
                  "teacherId": 0,
                  "teacherName": "string"
                }
              ],
              "internalsComputationCode": "A",
              "maxMarks": 0,
              "sectionId": 0,
              "sectionName": "string",
              "startTime": "",
              "status": "active",
              "subjectId": 0,
              "subjectName": "string",
              "tdsId": 0,
              "teacherId": 0,
              "teacherName": "string"
            }
          ],
          "markingAlgorithmId": 0,
          "markingAlgorithmName": "string",
          "markingAlgorithmRangeBeanList": [
            {
              "algorithmName": "string",
              "endRange": 0,
              "gpa": 0,
              "grade": "string",
              "markingAlgorithmId": 0,
              "markingAlgorithmRangeId": 0,
              "schoolId": 0,
              "schoolName": "string",
              "startRange": 0,
              "status": "active"
            }
          ],
          "markingSchemeCode": "A",
          "sectionId": 0,
          "sectionName": "string",
          "status": "active"
        }
      ],
      "examStartDate": "string",
      "examType": "SLIP_TEST",
      "schoolId": 0,
      "status": "active"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<AdminExamBean?>? adminExamBeanList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetAdminExamsResponse({
    this.adminExamBeanList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetAdminExamsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['adminExamBeanList'] != null) {
      final v = json['adminExamBeanList'];
      final arr0 = <AdminExamBean>[];
      v.forEach((v) {
        arr0.add(AdminExamBean.fromJson(v));
      });
      adminExamBeanList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (adminExamBeanList != null) {
      final v = adminExamBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['adminExamBeanList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetAdminExamsResponse> getAdminExams(GetAdminExamsRequest getAdminExamsRequest) async {
  print("Raising request to getAdminExams with request ${jsonEncode(getAdminExamsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ADMIN_EXAMS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getAdminExamsRequest.toJson()),
  );

  GetAdminExamsResponse getAdminExamsResponse = GetAdminExamsResponse.fromJson(json.decode(response.body));
  print("GetAdminExamsResponse ${getAdminExamsResponse.toJson()}");
  return getAdminExamsResponse;
}

class GetMarkingAlgorithmsRequest {
/*
{
  "markingAlgorithmId": 0,
  "schoolId": 0
}
*/

  int? markingAlgorithmId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetMarkingAlgorithmsRequest({
    this.markingAlgorithmId,
    this.schoolId,
  });
  GetMarkingAlgorithmsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class MarkingAlgorithmRangeBean {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "endRange": 0,
  "gpa": 0,
  "grade": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeId": 0,
  "schoolId": 0,
  "schoolName": "string",
  "startRange": 0,
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  int? endRange;
  TextEditingController endRangeController = TextEditingController();
  double? gpa;
  TextEditingController gpaController = TextEditingController();
  String? grade;
  TextEditingController gradeController = TextEditingController();
  int? markingAlgorithmId;
  int? markingAlgorithmRangeId;
  int? schoolId;
  String? schoolName;
  int? startRange;
  TextEditingController startRangeController = TextEditingController();
  String? status;
  Map<String, dynamic> __origJson = {};

  MarkingAlgorithmRangeBean({
    this.agent,
    this.algorithmName,
    this.endRange,
    this.gpa,
    this.grade,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeId,
    this.schoolId,
    this.schoolName,
    this.startRange,
    this.status,
  }) {
    endRangeController.text = '${endRange ?? ''}';
    startRangeController.text = '${startRange ?? ''}';
    gpaController.text = '${gpa ?? ""}';
    gradeController.text = grade ?? "";
  }

  MarkingAlgorithmRangeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    endRange = json['endRange']?.toInt();
    endRangeController.text = '${endRange ?? ''}';
    gpa = json['gpa']?.toInt();
    gpaController.text = '${gpa ?? ""}';
    grade = json['grade']?.toString();
    gradeController.text = grade ?? "";
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmRangeId = json['markingAlgorithmRangeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    startRange = json['startRange']?.toInt();
    startRangeController.text = '${startRange ?? ''}';
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['endRange'] = endRange;
    data['gpa'] = gpa;
    data['grade'] = grade;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmRangeId'] = markingAlgorithmRangeId;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['startRange'] = startRange;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class MarkingAlgorithmBean {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeBeanList": [
    {
      "agent": 0,
      "algorithmName": "string",
      "endRange": 0,
      "gpa": 0,
      "grade": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "startRange": 0,
      "status": "active"
    }
  ],
  "schoolId": 0,
  "schoolName": "string",
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  TextEditingController algorithmNameController = TextEditingController();
  int? markingAlgorithmId;
  List<MarkingAlgorithmRangeBean?>? markingAlgorithmRangeBeanList;
  int? schoolId;
  String? schoolName;
  String? status;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  MarkingAlgorithmBean({
    this.agent,
    this.algorithmName,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeBeanList,
    this.schoolId,
    this.schoolName,
    this.status,
  }) {
    algorithmNameController.text = algorithmName ?? "";
  }

  MarkingAlgorithmBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    algorithmNameController.text = algorithmName ?? "";
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    if (json['markingAlgorithmRangeBeanList'] != null) {
      final v = json['markingAlgorithmRangeBeanList'];
      final arr0 = <MarkingAlgorithmRangeBean>[];
      v.forEach((v) {
        arr0.add(MarkingAlgorithmRangeBean.fromJson(v));
      });
      markingAlgorithmRangeBeanList = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['markingAlgorithmId'] = markingAlgorithmId;
    if (markingAlgorithmRangeBeanList != null) {
      final v = markingAlgorithmRangeBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmRangeBeanList'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetMarkingAlgorithmsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "markingAlgorithmBeanList": [
    {
      "agent": 0,
      "algorithmName": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeBeanList": [
        {
          "agent": 0,
          "algorithmName": "string",
          "endRange": 0,
          "gpa": 0,
          "grade": "string",
          "markingAlgorithmId": 0,
          "markingAlgorithmRangeId": 0,
          "schoolId": 0,
          "schoolName": "string",
          "startRange": 0,
          "status": "active"
        }
      ],
      "schoolId": 0,
      "schoolName": "string",
      "status": "active"
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<MarkingAlgorithmBean?>? markingAlgorithmBeanList;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetMarkingAlgorithmsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.markingAlgorithmBeanList,
    this.responseStatus,
  });
  GetMarkingAlgorithmsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['markingAlgorithmBeanList'] != null) {
      final v = json['markingAlgorithmBeanList'];
      final arr0 = <MarkingAlgorithmBean>[];
      v.forEach((v) {
        arr0.add(MarkingAlgorithmBean.fromJson(v));
      });
      markingAlgorithmBeanList = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (markingAlgorithmBeanList != null) {
      final v = markingAlgorithmBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmBeanList'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetMarkingAlgorithmsResponse> getMarkingAlgorithms(GetMarkingAlgorithmsRequest getMarkingAlgorithmsRequest) async {
  print("Raising request to getMarkingAlgorithms with request ${jsonEncode(getMarkingAlgorithmsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_MARKING_ALGORITHMS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getMarkingAlgorithmsRequest.toJson()),
  );

  GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = GetMarkingAlgorithmsResponse.fromJson(json.decode(response.body));
  print("GetMarkingAlgorithmsResponse ${getMarkingAlgorithmsResponse.toJson()}");
  return getMarkingAlgorithmsResponse;
}

class CreateOrUpdateMarkingAlgorithmRequest {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeBeanList": [
    {
      "agent": 0,
      "algorithmName": "string",
      "endRange": 0,
      "gpa": 0,
      "grade": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "startRange": 0,
      "status": "active"
    }
  ],
  "schoolId": 0,
  "schoolName": "string",
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  int? markingAlgorithmId;
  List<MarkingAlgorithmRangeBean?>? markingAlgorithmRangeBeanList;
  int? schoolId;
  String? schoolName;
  String? status;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateMarkingAlgorithmRequest({
    this.agent,
    this.algorithmName,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeBeanList,
    this.schoolId,
    this.schoolName,
    this.status,
  });
  CreateOrUpdateMarkingAlgorithmRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    if (json['markingAlgorithmRangeBeanList'] != null) {
      final v = json['markingAlgorithmRangeBeanList'];
      final arr0 = <MarkingAlgorithmRangeBean>[];
      v.forEach((v) {
        arr0.add(MarkingAlgorithmRangeBean.fromJson(v));
      });
      markingAlgorithmRangeBeanList = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['markingAlgorithmId'] = markingAlgorithmId;
    if (markingAlgorithmRangeBeanList != null) {
      final v = markingAlgorithmRangeBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmRangeBeanList'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateMarkingAlgorithmResponse {
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

  CreateOrUpdateMarkingAlgorithmResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateMarkingAlgorithmResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateMarkingAlgorithmResponse> createOrUpdateMarkingAlgorithm(
    CreateOrUpdateMarkingAlgorithmRequest createOrUpdateMarkingAlgorithmRequest) async {
  print("Raising request to createOrUpdateMarkingAlgorithm with request ${jsonEncode(createOrUpdateMarkingAlgorithmRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_MARKING_ALGORITHM;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateMarkingAlgorithmRequest.toJson()),
  );

  CreateOrUpdateMarkingAlgorithmResponse createOrUpdateMarkingAlgorithmResponse =
      CreateOrUpdateMarkingAlgorithmResponse.fromJson(json.decode(response.body));
  print("createOrUpdateMarkingAlgorithmResponse ${createOrUpdateMarkingAlgorithmResponse.toJson()}");
  return createOrUpdateMarkingAlgorithmResponse;
}
