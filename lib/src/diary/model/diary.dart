import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

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

  String? date;
  String? startDate;
  String? endDate;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? teacherId;
  List<int>? sectionIds;
  int? academicYearId;
  Map<String, dynamic> __origJson = {};

  GetDiaryRequest({
    this.date,
    this.startDate,
    this.endDate,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.teacherId,
    this.sectionIds,
    this.academicYearId,
  });

  GetDiaryRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    startDate = json['startDate']?.toString();
    endDate = json['endDate']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    studentId = int.tryParse(json['studentId']?.toString() ?? '');
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    academicYearId = int.tryParse(json['academicYearId']?.toString() ?? '');
    if (json['sectionIds'] != null) {
      final v = json['sectionIds'];
      final arr0 = <int?>[];
      v.forEach((v) {
        arr0.add(int.tryParse(v));
      });
      sectionIds = arr0.where((e) => e != null).map((e) => e!).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['teacherId'] = teacherId;
    data['sectionIds'] = sectionIds;
    data['academicYearId'] = academicYearId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DiaryEntry {
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
  int? sectionSeqOrder;
  int? subjectSeqOrder;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  DiaryEntry({
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
    this.sectionSeqOrder,
    this.subjectSeqOrder,
  });

  DiaryEntry.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    assignment = json['assignment']?.toString();
    date = json['date']?.toString();
    diaryFolderId = json['diaryFolderId']?.toInt();
    diaryId = json['diaryId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    teacherFirstName = json['teacherFirstName']?.toString();
    teacherId = json['teacherId']?.toInt();
    teacherRemarks = json['teacherRemarks']?.toString();
    sectionSeqOrder = json['sectionSeqOrder']?.toInt();
    subjectSeqOrder = json['subjectSeqOrder']?.toInt();
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
    data['sectionSeqOrder'] = sectionSeqOrder;
    data['subjectSeqOrder'] = subjectSeqOrder;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentDiaryResponse {
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
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<DiaryEntry?>? diaryEntries;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetStudentDiaryResponse({
    this.diaryEntries,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetStudentDiaryResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['diaryEntries'] != null) {
      final v = json['diaryEntries'];
      final arr0 = <DiaryEntry>[];
      v.forEach((v) {
        arr0.add(DiaryEntry.fromJson(v));
      });
      diaryEntries = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
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
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentDiaryResponse> getDiary(GetDiaryRequest getDiaryRequest) async {
  debugPrint("Raising request to getDiary with request ${jsonEncode(getDiaryRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_DIARY;

  GetStudentDiaryResponse getDiaryResponse = await HttpUtils.post(
    _url,
    getDiaryRequest.toJson(),
    GetStudentDiaryResponse.fromJson,
  );

  debugPrint("GetDiaryResponse ${getDiaryResponse.toJson()}");
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
  String? date;
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
    date = json['date']?.toString();
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

Future<CreateOrUpdateDiaryResponse> createOrUpdateDiary(CreateOrUpdateDiaryRequest createOrUpdateDiaryRequest) async {
  debugPrint("Raising request to createOrUpdateDiary with request ${jsonEncode(createOrUpdateDiaryRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_DIARY;

  CreateOrUpdateDiaryResponse createOrUpdateDiaryResponse = await HttpUtils.post(
    _url,
    createOrUpdateDiaryRequest.toJson(),
    CreateOrUpdateDiaryResponse.fromJson,
  );

  debugPrint("createOrUpdateDiaryResponse ${createOrUpdateDiaryResponse.toJson()}");
  return createOrUpdateDiaryResponse;
}

Future<List<int>> getDiaryReport(GetDiaryRequest getDiaryRequest) async {
  debugPrint("Raising request to getDiary with request ${jsonEncode(getDiaryRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_DIARY_REPORT;
  return await HttpUtils.postToDownloadFile(_url, getDiaryRequest.toJson());
}

class GetDiaryTopicsRequest {
  int? schoolId;
  int? sectionId;
  int? subjectId;

  GetDiaryTopicsRequest({
    this.schoolId,
    this.sectionId,
    this.subjectId,
  });

  GetDiaryTopicsRequest.fromJson(Map<String, dynamic> json) {
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    return data;
  }
}

class DiaryTopicBean {
  int? agentId;
  int? diaryTopicId;
  int? schoolId;
  int? sectionId;
  String? status;
  int? subjectId;
  String? topicName;

  DiaryTopicBean({
    this.agentId,
    this.diaryTopicId,
    this.schoolId,
    this.sectionId,
    this.status,
    this.subjectId,
    this.topicName,
  });

  DiaryTopicBean.fromJson(Map<String, dynamic> json) {
    agentId = json['agentId']?.toInt();
    diaryTopicId = json['diaryTopicId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    status = json['status']?.toString();
    subjectId = json['subjectId']?.toInt();
    topicName = json['topicName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['diaryTopicId'] = diaryTopicId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['topicName'] = topicName;
    return data;
  }
}

class GetDiaryTopicsResponse {
  List<DiaryTopicBean?>? diaryTopicBeans;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  GetDiaryTopicsResponse({
    this.diaryTopicBeans,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetDiaryTopicsResponse.fromJson(Map<String, dynamic> json) {
    if (json['diaryTopicBeans'] != null) {
      final v = json['diaryTopicBeans'];
      final arr0 = <DiaryTopicBean>[];
      v.forEach((v) {
        arr0.add(DiaryTopicBean.fromJson(v));
      });
      diaryTopicBeans = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (diaryTopicBeans != null) {
      final v = diaryTopicBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['diaryTopicBeans'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<GetDiaryTopicsResponse> getDiaryTopics(GetDiaryTopicsRequest getDiaryTopicsRequest) async {
  debugPrint("Raising request to getDiaryTopics with request ${jsonEncode(getDiaryTopicsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_DIARY_TOPICS;

  GetDiaryTopicsResponse getDiaryTopicsResponse = await HttpUtils.post(
    _url,
    getDiaryTopicsRequest.toJson(),
    GetDiaryTopicsResponse.fromJson,
  );

  debugPrint("GetDiaryTopicsResponse ${getDiaryTopicsResponse.toJson()}");
  return getDiaryTopicsResponse;
}

class GetDiaryIssuesRequest {
  String? date;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? topicId;

  GetDiaryIssuesRequest({
    this.date,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.topicId,
  });

  GetDiaryIssuesRequest.fromJson(Map<String, dynamic> json) {
    date = json['date']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    topicId = json['topicId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['topicId'] = topicId;
    return data;
  }
}

class DiaryIssueMediaBean {
  String? agentId;
  int? createdTime;
  int? diaryIssueId;
  int? diaryIssueMediaId;
  int? lastUpdatedTime;
  int? mediaId;
  String? mediaType;
  String? mediaUrl;
  String? status;
  String? thumbnailUrl;

  DiaryIssueMediaBean({
    this.agentId,
    this.createdTime,
    this.diaryIssueId,
    this.diaryIssueMediaId,
    this.lastUpdatedTime,
    this.mediaId,
    this.mediaType,
    this.mediaUrl,
    this.status,
    this.thumbnailUrl,
  });

  DiaryIssueMediaBean.fromJson(Map<String, dynamic> json) {
    agentId = json['agentId']?.toString();
    createdTime = json['createdTime']?.toInt();
    diaryIssueId = json['diaryIssueId']?.toInt();
    diaryIssueMediaId = json['diaryIssueMediaId']?.toInt();
    lastUpdatedTime = json['lastUpdatedTime']?.toInt();
    mediaId = json['mediaId']?.toInt();
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    status = json['status']?.toString();
    thumbnailUrl = json['thumbnailUrl']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['createdTime'] = createdTime;
    data['diaryIssueId'] = diaryIssueId;
    data['diaryIssueMediaId'] = diaryIssueMediaId;
    data['lastUpdatedTime'] = lastUpdatedTime;
    data['mediaId'] = mediaId;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['status'] = status;
    data['thumbnailUrl'] = thumbnailUrl;
    return data;
  }
}

class DiaryIssueBean {
  int? agentId;
  String? date;
  int? diaryIssueId;
  List<DiaryIssueMediaBean?>? diaryIssueMediaBeans;
  String? topicName;
  String? issue;
  String? resolution;
  int? schoolId;
  int? sectionId;
  String? status;
  int? studentId;
  int? subjectId;
  int? topicId;

  TextEditingController topicNameEditingController = TextEditingController();
  TextEditingController issueEditingController = TextEditingController();
  TextEditingController resolutionEditingController = TextEditingController();

  DiaryIssueBean({
    this.agentId,
    this.date,
    this.diaryIssueId,
    this.diaryIssueMediaBeans,
    this.topicName,
    this.issue,
    this.resolution,
    this.schoolId,
    this.sectionId,
    this.status,
    this.studentId,
    this.subjectId,
    this.topicId,
  }) {
    topicNameEditingController.text = topicName ?? "";
    issueEditingController.text = issue ?? "";
    resolutionEditingController.text = resolution ?? "";
  }

  DiaryIssueBean.fromJson(Map<String, dynamic> json) {
    agentId = json['agentId']?.toInt();
    date = json['date']?.toString();
    diaryIssueId = json['diaryIssueId']?.toInt();
    if (json['diaryIssueMediaBeans'] != null) {
      final v = json['diaryIssueMediaBeans'];
      final arr0 = <DiaryIssueMediaBean>[];
      v.forEach((v) {
        arr0.add(DiaryIssueMediaBean.fromJson(v));
      });
      diaryIssueMediaBeans = arr0;
    }
    topicName = json['topicName']?.toString();
    issue = json['issue']?.toString();
    resolution = json['resolution']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    status = json['status']?.toString();
    studentId = json['studentId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    topicId = json['topicId']?.toInt();
    topicNameEditingController.text = topicName ?? "";
    issueEditingController.text = issue ?? "";
    resolutionEditingController.text = resolution ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['date'] = date;
    data['diaryIssueId'] = diaryIssueId;
    if (diaryIssueMediaBeans != null) {
      final v = diaryIssueMediaBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['diaryIssueMediaBeans'] = arr0;
    }
    data['topicName'] = topicName;
    data['issue'] = issue;
    data['resolution'] = resolution;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['status'] = status;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['topicId'] = topicId;
    return data;
  }

  void populateFromTextControllers() {
    topicName = topicNameEditingController.text.trim();
    issue = issueEditingController.text.trim();
    resolution = resolutionEditingController.text.trim();
  }
}

class GetDiaryIssuesResponse {
  List<DiaryIssueBean?>? diaryIssueBeans;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  GetDiaryIssuesResponse({
    this.diaryIssueBeans,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetDiaryIssuesResponse.fromJson(Map<String, dynamic> json) {
    if (json['diaryIssueBeans'] != null) {
      final v = json['diaryIssueBeans'];
      final arr0 = <DiaryIssueBean>[];
      v.forEach((v) {
        arr0.add(DiaryIssueBean.fromJson(v));
      });
      diaryIssueBeans = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (diaryIssueBeans != null) {
      final v = diaryIssueBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['diaryIssueBeans'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<GetDiaryIssuesResponse> getDiaryIssues(GetDiaryIssuesRequest getDiaryIssuesRequest) async {
  debugPrint("Raising request to getDiaryIssues with request ${jsonEncode(getDiaryIssuesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_DIARY_ISSUES;

  GetDiaryIssuesResponse getDiaryIssuesResponse = await HttpUtils.post(
    _url,
    getDiaryIssuesRequest.toJson(),
    GetDiaryIssuesResponse.fromJson,
  );

  debugPrint("GetDiaryIssuesResponse ${getDiaryIssuesResponse.toJson()}");
  return getDiaryIssuesResponse;
}
