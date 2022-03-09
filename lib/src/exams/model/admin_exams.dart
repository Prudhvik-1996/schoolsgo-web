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
  double? internalsWeightage;
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
  TextEditingController internalsWeightageEditingController = TextEditingController();
  bool isExpanded = false;

  ExamTdsMapBean({
    this.endTime,
    this.examId,
    this.examName,
    this.examTdsDate,
    this.examTdsMapId,
    this.internalExamTdsMapBeanList,
    this.internalsComputationCode,
    this.internalsWeightage,
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
    internalsWeightageEditingController.text = "${internalsWeightage ?? ""}";
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
    internalsWeightage = json['internalsWeightage']?.toDouble();
    internalsWeightageEditingController.text = "${internalsWeightage ?? ""}";
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
    data['internalsWeightage'] = internalsWeightage;
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

  bool isEditMode = false;
  TextEditingController examNameEditingController = TextEditingController();

  AdminExamBean({
    this.agent,
    this.examId,
    this.examName,
    this.examSectionMapBeanList,
    this.examStartDate,
    this.examType,
    this.schoolId,
    this.status,
  }) {
    examNameEditingController.text = examName ?? '';
  }

  AdminExamBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examNameEditingController.text = examName ?? '';
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

class CreateOrUpdateExamResponse {
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

  CreateOrUpdateExamResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateExamResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateExamResponse> createOrUpdateExam(AdminExamBean createOrUpdateExamRequest) async {
  print("Raising request to createOrUpdateExam with request ${jsonEncode(createOrUpdateExamRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_ADMIN_EXAMS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateExamRequest.toJson()),
  );

  CreateOrUpdateExamResponse createOrUpdateExamResponse = CreateOrUpdateExamResponse.fromJson(json.decode(response.body));
  print("createOrUpdateExamResponse ${createOrUpdateExamResponse.toJson()}");
  return createOrUpdateExamResponse;
}

class GetStudentExamMarksDetailsRequest {
/*
{
  "examId": 0,
  "examType": "SLIP_TEST",
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? examId;
  String? examType;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetStudentExamMarksDetailsRequest({
    this.examId,
    this.examType,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });

  GetStudentExamMarksDetailsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examType = json['examType']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
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
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentInternalExamMarksDetailsBean {
/*
{
  "examId": 0,
  "examName": "string",
  "examTdsMapId": 0,
  "examType": "SLIP_TEST",
  "internalExamId": 0,
  "internalExamName": "string",
  "internalExamType": "SLIP_TEST",
  "internalTdsId": 0,
  "internalTdsMapId": 0,
  "internalsComputationCode": "A",
  "internalsDate": "string",
  "internalsEndTime": "",
  "internalsMarksObtained": 0,
  "internalsMaxMarks": 0,
  "internalsSectionId": 0,
  "internalsSectionName": "string",
  "internalsStartTime": "",
  "internalsSubjectId": 0,
  "internalsSubjectName": "string",
  "internalsTeacherId": 0,
  "internalsTeacherName": "string",
  "rollNumber": "string",
  "schoolId": 0,
  "studentId": 0,
  "studentName": "string"
}
*/

  int? examId;
  String? examName;
  int? examTdsMapId;
  String? examType;
  int? internalExamId;
  String? internalExamName;
  String? internalExamType;
  int? internalTdsId;
  int? internalTdsMapId;
  String? internalsComputationCode;
  String? internalsDate;
  String? internalsEndTime;
  int? internalsMarksObtained;
  int? internalsMaxMarks;
  int? internalsSectionId;
  String? internalsSectionName;
  String? internalsStartTime;
  int? internalsSubjectId;
  String? internalsSubjectName;
  int? internalsTeacherId;
  String? internalsTeacherName;
  String? rollNumber;
  int? schoolId;
  int? studentId;
  String? studentName;
  int? internalNumber;
  Map<String, dynamic> __origJson = {};

  StudentInternalExamMarksDetailsBean({
    this.examId,
    this.examName,
    this.examTdsMapId,
    this.examType,
    this.internalExamId,
    this.internalExamName,
    this.internalExamType,
    this.internalTdsId,
    this.internalTdsMapId,
    this.internalsComputationCode,
    this.internalsDate,
    this.internalsEndTime,
    this.internalsMarksObtained,
    this.internalsMaxMarks,
    this.internalsSectionId,
    this.internalsSectionName,
    this.internalsStartTime,
    this.internalsSubjectId,
    this.internalsSubjectName,
    this.internalsTeacherId,
    this.internalsTeacherName,
    this.rollNumber,
    this.schoolId,
    this.studentId,
    this.studentName,
    this.internalNumber,
  });

  StudentInternalExamMarksDetailsBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examTdsMapId = json['examTdsMapId']?.toInt();
    examType = json['examType']?.toString();
    internalExamId = json['internalExamId']?.toInt();
    internalExamName = json['internalExamName']?.toString();
    internalExamType = json['internalExamType']?.toString();
    internalTdsId = json['internalTdsId']?.toInt();
    internalTdsMapId = json['internalTdsMapId']?.toInt();
    internalsComputationCode = json['internalsComputationCode']?.toString();
    internalsDate = json['internalsDate']?.toString();
    internalsEndTime = json['internalsEndTime']?.toString();
    internalsMarksObtained = json['internalsMarksObtained']?.toInt();
    internalsMaxMarks = json['internalsMaxMarks']?.toInt();
    internalsSectionId = json['internalsSectionId']?.toInt();
    internalsSectionName = json['internalsSectionName']?.toString();
    internalsStartTime = json['internalsStartTime']?.toString();
    internalsSubjectId = json['internalsSubjectId']?.toInt();
    internalsSubjectName = json['internalsSubjectName']?.toString();
    internalsTeacherId = json['internalsTeacherId']?.toInt();
    internalsTeacherName = json['internalsTeacherName']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    internalNumber = json['internalNumber']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['examId'] = examId;
    data['examName'] = examName;
    data['examTdsMapId'] = examTdsMapId;
    data['examType'] = examType;
    data['internalExamId'] = internalExamId;
    data['internalExamName'] = internalExamName;
    data['internalExamType'] = internalExamType;
    data['internalTdsId'] = internalTdsId;
    data['internalTdsMapId'] = internalTdsMapId;
    data['internalsComputationCode'] = internalsComputationCode;
    data['internalsDate'] = internalsDate;
    data['internalsEndTime'] = internalsEndTime;
    data['internalsMarksObtained'] = internalsMarksObtained;
    data['internalsMaxMarks'] = internalsMaxMarks;
    data['internalsSectionId'] = internalsSectionId;
    data['internalsSectionName'] = internalsSectionName;
    data['internalsStartTime'] = internalsStartTime;
    data['internalsSubjectId'] = internalsSubjectId;
    data['internalsSubjectName'] = internalsSubjectName;
    data['internalsTeacherId'] = internalsTeacherId;
    data['internalsTeacherName'] = internalsTeacherName;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['internalNumber'] = internalNumber;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentExamMarksDetailsBean {
/*
{
  "date": "string",
  "endTime": "",
  "examId": 0,
  "examName": "string",
  "examTdsMapId": 0,
  "examType": "SLIP_TEST",
  "internalsComputationCode": "A",
  "marksObtained": 0,
  "maxMarks": 0,
  "rollNumber": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "startTime": "",
  "studentId": 0,
  "studentInternalExamMarksDetailsBeanList": [
    {
      "examId": 0,
      "examName": "string",
      "examTdsMapId": 0,
      "examType": "SLIP_TEST",
      "internalExamId": 0,
      "internalExamName": "string",
      "internalExamType": "SLIP_TEST",
      "internalTdsId": 0,
      "internalTdsMapId": 0,
      "internalsComputationCode": "A",
      "internalsDate": "string",
      "internalsEndTime": "",
      "internalsMarksObtained": 0,
      "internalsMaxMarks": 0,
      "internalsSectionId": 0,
      "internalsSectionName": "string",
      "internalsStartTime": "",
      "internalsSubjectId": 0,
      "internalsSubjectName": "string",
      "internalsTeacherId": 0,
      "internalsTeacherName": "string",
      "rollNumber": "string",
      "schoolId": 0,
      "studentId": 0,
      "studentName": "string"
    }
  ],
  "studentName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  String? date;
  String? endTime;
  int? examId;
  String? examName;
  int? examTdsMapId;
  String? examType;
  String? internalsComputationCode;
  double? internalsWeightage;
  int? marksObtained;
  int? maxMarks;
  String? rollNumber;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  String? startTime;
  int? studentId;
  List<StudentInternalExamMarksDetailsBean?>? studentInternalExamMarksDetailsBeanList;
  String? studentName;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;

  bool isMarksEditable = false;
  TextEditingController marksEditingController = TextEditingController();

  Map<String, dynamic> __origJson = {};

  double? gpa;
  String? grade;
  double? internalsGpa;
  String? internalsGrade;

  StudentExamMarksDetailsBean({
    this.date,
    this.endTime,
    this.examId,
    this.examName,
    this.examTdsMapId,
    this.examType,
    this.internalsComputationCode,
    this.internalsWeightage,
    this.marksObtained,
    this.maxMarks,
    this.rollNumber,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.startTime,
    this.studentId,
    this.studentInternalExamMarksDetailsBeanList,
    this.studentName,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  }) {
    _adjustTextController();
  }

  void _adjustTextController() {
    if (marksObtained == null || marksObtained == -1) {
      marksEditingController.text = "";
    } else if (marksObtained == -2) {
      marksEditingController.text = "A";
    } else {
      marksEditingController.text = "${marksObtained ?? ""}";
    }
  }

  StudentExamMarksDetailsBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    endTime = json['endTime']?.toString();
    examId = json['examId']?.toInt();
    examName = json['examName']?.toString();
    examTdsMapId = json['examTdsMapId']?.toInt();
    examType = json['examType']?.toString();
    internalsComputationCode = json['internalsComputationCode']?.toString();
    internalsWeightage = json['internalsWeightage']?.toDouble();
    marksObtained = json['marksObtained']?.toInt();
    _adjustTextController();
    maxMarks = json['maxMarks']?.toInt();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    startTime = json['startTime']?.toString();
    studentId = json['studentId']?.toInt();
    if (json['studentInternalExamMarksDetailsBeanList'] != null) {
      final v = json['studentInternalExamMarksDetailsBeanList'];
      final arr0 = <StudentInternalExamMarksDetailsBean>[];
      v.forEach((v) {
        arr0.add(StudentInternalExamMarksDetailsBean.fromJson(v));
      });
      studentInternalExamMarksDetailsBeanList = arr0;
    }
    studentName = json['studentName']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['endTime'] = endTime;
    data['examId'] = examId;
    data['examName'] = examName;
    data['examTdsMapId'] = examTdsMapId;
    data['examType'] = examType;
    data['internalsComputationCode'] = internalsComputationCode;
    data['internalsWeightage'] = internalsWeightage;
    data['marksObtained'] = marksObtained;
    data['maxMarks'] = maxMarks;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['startTime'] = startTime;
    data['studentId'] = studentId;
    if (studentInternalExamMarksDetailsBeanList != null) {
      final v = studentInternalExamMarksDetailsBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentInternalExamMarksDetailsBeanList'] = arr0;
    }
    data['studentName'] = studentName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  void setMarks(int? newMarks, MarkingAlgorithmBean? markingAlgorithm) {
    marksObtained = newMarks;
    if (markingAlgorithm != null) computeGrades(markingAlgorithm);
  }

  void computeGrades(MarkingAlgorithmBean markingAlgorithm) {
    if (marksObtained == null || maxMarks == null) return;
    double percentage = (marksObtained! * 100) / maxMarks!;
    for (MarkingAlgorithmRangeBean eachRangeBean in (markingAlgorithm.markingAlgorithmRangeBeanList ?? []).map((e) => e!)) {
      if (eachRangeBean.startRange! < percentage && percentage < eachRangeBean.endRange!) {
        gpa = eachRangeBean.gpa;
        grade = eachRangeBean.grade;
      }
    }
    if ((studentInternalExamMarksDetailsBeanList ?? []).isEmpty) return;
    double? percentageForInternals = (internalsComputationCode ?? "C") == "B"
        ? studentInternalExamMarksDetailsBeanList!
            .map((e) => e!)
            .where((e) => e.internalsMarksObtained != null && e.internalsMaxMarks != null)
            .map((e) => (e.internalsMaxMarks! * 100) / (e.internalsMaxMarks!))
            .reduce((max, element) {
            if (max > element) {
              return max;
            } else {
              return element;
            }
          })
        : (internalsComputationCode ?? "C") == "A"
            ? studentInternalExamMarksDetailsBeanList!
                    .map((e) => e!)
                    .where((e) => e.internalsMarksObtained != null && e.internalsMaxMarks != null)
                    .map((e) => (e.internalsMaxMarks! * 100) / (e.internalsMaxMarks!))
                    .reduce((a, b) => a + b) /
                studentInternalExamMarksDetailsBeanList!
                    .map((e) => e!)
                    .where((e) => e.internalsMarksObtained != null && e.internalsMaxMarks != null)
                    .length
            : null;

    if (percentageForInternals != null) {}
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class GetStudentExamMarksDetailsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentExamMarksDetailsList": [
    {
      "date": "string",
      "endTime": "",
      "examId": 0,
      "examName": "string",
      "examTdsMapId": 0,
      "examType": "SLIP_TEST",
      "internalsComputationCode": "A",
      "marksObtained": 0,
      "maxMarks": 0,
      "rollNumber": "string",
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "startTime": "",
      "studentId": 0,
      "studentInternalExamMarksDetailsBeanList": [
        {
          "examId": 0,
          "examName": "string",
          "examTdsMapId": 0,
          "examType": "SLIP_TEST",
          "internalExamId": 0,
          "internalExamName": "string",
          "internalExamType": "SLIP_TEST",
          "internalTdsId": 0,
          "internalTdsMapId": 0,
          "internalsComputationCode": "A",
          "internalsDate": "string",
          "internalsEndTime": "",
          "internalsMarksObtained": 0,
          "internalsMaxMarks": 0,
          "internalsSectionId": 0,
          "internalsSectionName": "string",
          "internalsStartTime": "",
          "internalsSubjectId": 0,
          "internalsSubjectName": "string",
          "internalsTeacherId": 0,
          "internalsTeacherName": "string",
          "rollNumber": "string",
          "schoolId": 0,
          "studentId": 0,
          "studentName": "string"
        }
      ],
      "studentName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentExamMarksDetailsBean?>? studentExamMarksDetailsList;
  Map<String, dynamic> __origJson = {};

  GetStudentExamMarksDetailsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentExamMarksDetailsList,
  });

  GetStudentExamMarksDetailsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentExamMarksDetailsList'] != null) {
      final v = json['studentExamMarksDetailsList'];
      final arr0 = <StudentExamMarksDetailsBean>[];
      v.forEach((v) {
        arr0.add(StudentExamMarksDetailsBean.fromJson(v));
      });
      studentExamMarksDetailsList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentExamMarksDetailsList != null) {
      final v = studentExamMarksDetailsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentExamMarksDetailsList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentExamMarksDetailsResponse> getStudentExamMarksDetails(GetStudentExamMarksDetailsRequest getStudentExamMarksDetailsRequest) async {
  print("Raising request to getStudentExamMarksDetails with request ${jsonEncode(getStudentExamMarksDetailsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_EXAM_MARKS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentExamMarksDetailsRequest.toJson()),
  );

  GetStudentExamMarksDetailsResponse getStudentExamMarksDetailsResponse = GetStudentExamMarksDetailsResponse.fromJson(json.decode(response.body));
  print("GetStudentExamMarksDetailsResponse ${getStudentExamMarksDetailsResponse.toJson()}");
  return getStudentExamMarksDetailsResponse;
}

class StudentMarksUpdateBean {
/*
{
  "studentId": 1,
  "examId": 1,
  "examTdsMapId": 1,
  "marksObtained": 1
}
*/

  int? studentId;
  int? examId;
  int? examTdsMapId;
  int? marksObtained;
  Map<String, dynamic> __origJson = {};

  StudentMarksUpdateBean({
    this.studentId,
    this.examId,
    this.examTdsMapId,
    this.marksObtained,
  });

  StudentMarksUpdateBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    studentId = json['studentId']?.toInt();
    examId = json['examId']?.toInt();
    examTdsMapId = json['examTdsMapId']?.toInt();
    marksObtained = json['marksObtained']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['studentId'] = studentId;
    data['examId'] = examId;
    data['examTdsMapId'] = examTdsMapId;
    data['marksObtained'] = marksObtained;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentExamMarksRequest {
/*
{
  "agentId": 1,
  "schoolId": 1,
  "studentExamMarksDetailsList": [
    {
      "studentId": 1,
      "examId": 1,
      "examTdsMapId": 1,
      "marksObtained": 1
    }
  ]
}
*/

  int? agentId;
  int? schoolId;
  List<StudentMarksUpdateBean?>? studentExamMarksDetailsList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentExamMarksRequest({
    this.agentId,
    this.schoolId,
    this.studentExamMarksDetailsList,
  });

  CreateOrUpdateStudentExamMarksRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['studentExamMarksDetailsList'] != null) {
      final v = json['studentExamMarksDetailsList'];
      final arr0 = <StudentMarksUpdateBean>[];
      v.forEach((v) {
        arr0.add(StudentMarksUpdateBean.fromJson(v));
      });
      studentExamMarksDetailsList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['schoolId'] = schoolId;
    if (studentExamMarksDetailsList != null) {
      final v = studentExamMarksDetailsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentExamMarksDetailsList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentExamMarksResponse {
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

  CreateOrUpdateStudentExamMarksResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateStudentExamMarksResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateStudentExamMarksResponse> createOrUpdateStudentExamMarks(
    CreateOrUpdateStudentExamMarksRequest createOrUpdateStudentExamMarksRequest) async {
  print("Raising request to createOrUpdateStudentExamMarks with request ${jsonEncode(createOrUpdateStudentExamMarksRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_EXAM_MARKS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateStudentExamMarksRequest.toJson()),
  );

  CreateOrUpdateStudentExamMarksResponse createOrUpdateStudentExamMarksResponse =
      CreateOrUpdateStudentExamMarksResponse.fromJson(json.decode(response.body));
  print("createOrUpdateStudentExamMarksResponse ${createOrUpdateStudentExamMarksResponse.toJson()}");
  return createOrUpdateStudentExamMarksResponse;
}
