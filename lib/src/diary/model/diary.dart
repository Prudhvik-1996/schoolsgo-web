import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetDiaryRequest {
/*
{
  "date": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subjectId": 0,
  "teacherId": 0
}
*/

  int? date;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetDiaryRequest({
    this.date,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.teacherId,
  });
  GetDiaryRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = int.tryParse(json['date']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    studentId = int.tryParse(json['studentId']?.toString() ?? '');
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Diary {
/*
{
  "assignment": "string",
  "date": "string",
  "diaryFolderId": 0,
  "diaryId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "teacherFirstName": "string",
  "teacherId": 0,
  "teacherRemarks": "string"
}
*/

  String? assignment;
  String? date;
  int? diaryFolderId;
  int? diaryId;
  int? sectionId;
  String? sectionName;
  int? subjectId;
  String? subjectName;
  String? teacherFirstName;
  int? teacherId;
  String? teacherRemarks;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  Diary({
    this.assignment,
    this.date,
    this.diaryFolderId,
    this.diaryId,
    this.sectionId,
    this.sectionName,
    this.subjectId,
    this.subjectName,
    this.teacherFirstName,
    this.teacherId,
    this.teacherRemarks,
  });
  Diary.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    assignment = json['assignment']?.toString();
    date = json['date']?.toString();
    diaryFolderId = int.tryParse(json['diaryFolderId']?.toString() ?? '');
    diaryId = int.tryParse(json['diaryId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    sectionName = json['sectionName']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    subjectName = json['subjectName']?.toString();
    teacherFirstName = json['teacherFirstName']?.toString();
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherRemarks = json['teacherRemarks']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['assignment'] = assignment;
    data['date'] = date;
    data['diaryFolderId'] = diaryFolderId;
    data['diaryId'] = diaryId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['teacherFirstName'] = teacherFirstName;
    data['teacherId'] = teacherId;
    data['teacherRemarks'] = teacherRemarks;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SectionWiseDiaryBean {
/*
{
  "diaryEntries": [
    {
      "assignment": "string",
      "date": "string",
      "diaryFolderId": 0,
      "diaryId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "teacherFirstName": "string",
      "teacherId": 0,
      "teacherRemarks": "string"
    }
  ],
  "sectionId": 0
}
*/

  List<Diary?>? diaryEntries;
  int? sectionId;
  Map<String, dynamic> __origJson = {};

  SectionWiseDiaryBean({
    this.diaryEntries,
    this.sectionId,
  });
  SectionWiseDiaryBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['diaryEntries'] != null && (json['diaryEntries'] is List)) {
      final v = json['diaryEntries'];
      final arr0 = <Diary>[];
      v.forEach((v) {
        arr0.add(Diary.fromJson(v));
      });
      diaryEntries = arr0;
    }
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (diaryEntries != null) {
      final v = diaryEntries;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['diaryEntries'] = arr0;
    }
    data['sectionId'] = sectionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetDiaryResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "sectionDiaryList": [
    {
      "diaryEntries": [
        {
          "assignment": "string",
          "date": "string",
          "diaryFolderId": 0,
          "diaryId": 0,
          "sectionId": 0,
          "sectionName": "string",
          "subjectId": 0,
          "subjectName": "string",
          "teacherFirstName": "string",
          "teacherId": 0,
          "teacherRemarks": "string"
        }
      ],
      "sectionId": 0
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SectionWiseDiaryBean?>? sectionDiaryList;
  Map<String, dynamic> __origJson = {};

  GetDiaryResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.sectionDiaryList,
  });
  GetDiaryResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['sectionDiaryList'] != null &&
        (json['sectionDiaryList'] is List)) {
      final v = json['sectionDiaryList'];
      final arr0 = <SectionWiseDiaryBean>[];
      v.forEach((v) {
        arr0.add(SectionWiseDiaryBean.fromJson(v));
      });
      sectionDiaryList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (sectionDiaryList != null) {
      final v = sectionDiaryList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['sectionDiaryList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetDiaryResponse> getDiary(GetDiaryRequest getDiaryRequest) async {
  print(
      "Raising request to getDiary with request ${jsonEncode(getDiaryRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_DIARY;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getDiaryRequest.toJson()),
  );

  GetDiaryResponse getDiaryResponse =
      GetDiaryResponse.fromJson(json.decode(response.body));
  print("GetDiaryResponse ${getDiaryResponse.toJson()}");
  return getDiaryResponse;
}

class CreateOrUpdateDiaryRequest {
/*
{
  "agentId": 0,
  "assignment": "string",
  "date": 0,
  "diaryId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "status": "active",
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0,
  "teacherRemarks": "string"
}
*/

  int? agentId;
  String? assignment;
  int? date;
  int? diaryId;
  int? schoolId;
  int? sectionId;
  String? status;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  String? teacherRemarks;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateDiaryRequest({
    this.agentId,
    this.assignment,
    this.date,
    this.diaryId,
    this.schoolId,
    this.sectionId,
    this.status,
    this.subjectId,
    this.tdsId,
    this.teacherId,
    this.teacherRemarks,
  });
  CreateOrUpdateDiaryRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json['agentId']?.toString() ?? '');
    assignment = json['assignment']?.toString();
    date = int.tryParse(json['date']?.toString() ?? '');
    diaryId = int.tryParse(json['diaryId']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    status = json['status']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherRemarks = json['teacherRemarks']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['assignment'] = assignment;
    data['date'] = date;
    data['diaryId'] = diaryId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherRemarks'] = teacherRemarks;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateDiaryResponse {
/*
{
  "diaryId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? diaryId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateDiaryResponse({
    this.diaryId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateDiaryResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    diaryId = int.tryParse(json['diaryId']?.toString() ?? '');
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['diaryId'] = diaryId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateDiaryResponse> createOrUpdateDiary(
    CreateOrUpdateDiaryRequest createOrUpdateDiaryRequest) async {
  print(
      "Raising request to createOrUpdateDiary with request ${jsonEncode(createOrUpdateDiaryRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_DIARY;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateDiaryRequest.toJson()),
  );

  CreateOrUpdateDiaryResponse createOrUpdateDiaryResponse =
      CreateOrUpdateDiaryResponse.fromJson(json.decode(response.body));
  print("createOrUpdateDiaryResponse ${createOrUpdateDiaryResponse.toJson()}");
  return createOrUpdateDiaryResponse;
}
