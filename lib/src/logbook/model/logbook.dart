import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetLogBookRequest {
/*
{
  "date": 1635445396000,
  "schoolId": 0,
  "sectionId": 0,
  "sectionTimeSlotId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 127
}
*/

  int? date;
  int? schoolId;
  int? sectionId;
  int? sectionTimeSlotId;
  int? subjectId;
  int? tdsId;
  int? teacherId;

  List<int?>? teacherIds;
  int? startDate;
  int? endDate;
  Map<String, dynamic> __origJson = {};

  GetLogBookRequest({
    this.date,
    this.schoolId,
    this.sectionId,
    this.sectionTimeSlotId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
    this.teacherIds,
    this.startDate,
    this.endDate,
  });

  GetLogBookRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = int.tryParse(json["date"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    sectionTimeSlotId = int.tryParse(json["sectionTimeSlotId"]?.toString() ?? '');
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    tdsId = int.tryParse(json["tdsId"]?.toString() ?? '');
    teacherId = int.tryParse(json["teacherId"]?.toString() ?? '');
    if (json['teacherIds'] != null) {
      final v = json['teacherIds'];
      final arr0 = <int?>[];
      v.forEach((v) {
        arr0.add(int.tryParse(v));
      });
      teacherIds = arr0.toList();
    }
    startDate = int.tryParse(json["startDate"]?.toString() ?? '');
    endDate = int.tryParse(json["endDate"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["date"] = date;
    data["schoolId"] = schoolId;
    data["sectionId"] = sectionId;
    data["sectionTimeSlotId"] = sectionTimeSlotId;
    data["subjectId"] = subjectId;
    data["tdsId"] = tdsId;
    data["teacherId"] = teacherId;
    data['teacherIds'] = teacherIds;
    data["startDate"] = startDate;
    data["endDate"] = endDate;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class LogBook {
/*
{
  "agent": "string",
  "date": "string",
  "endTime": "string",
  "id": 0,
  "lastUpdatedTime": "string",
  "notes": "string",
  "sectionId": 0,
  "sectionName": "string",
  "sectionTimeSlotId": 0,
  "startTime": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  String? agent;
  String? date;
  String? endTime;
  int? id;
  String? lastUpdatedTime;
  String? notes;
  int? sectionId;
  String? sectionName;
  int? sectionTimeSlotId;
  String? startTime;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  int? sectionSeqOrder;
  int? subjectSeqOrder;
  Map<String, dynamic> __origJson = {};
  bool isEditMode = false;

  LogBook({
    this.agent,
    this.date,
    this.endTime,
    this.id,
    this.lastUpdatedTime,
    this.notes,
    this.sectionId,
    this.sectionName,
    this.sectionTimeSlotId,
    this.startTime,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
    this.sectionSeqOrder,
    this.subjectSeqOrder,
  });

  LogBook.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json["agent"]?.toString();
    date = json["date"]?.toString();
    endTime = json["endTime"]?.toString();
    id = int.tryParse(json["id"]?.toString() ?? '');
    lastUpdatedTime = json["lastUpdatedTime"]?.toString();
    notes = json["notes"]?.toString();
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    sectionName = json["sectionName"]?.toString();
    sectionTimeSlotId = int.tryParse(json["sectionTimeSlotId"]?.toString() ?? '');
    startTime = json["startTime"]?.toString();
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    subjectName = json["subjectName"]?.toString();
    tdsId = int.tryParse(json["tdsId"]?.toString() ?? '');
    teacherId = int.tryParse(json["teacherId"]?.toString() ?? '');
    teacherName = json["teacherName"]?.toString();
    sectionSeqOrder = int.tryParse(json["sectionSeqOrder"]?.toString() ?? '');
    subjectSeqOrder = int.tryParse(json["subjectSeqOrder"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["date"] = date;
    data["endTime"] = endTime;
    data["id"] = id;
    data["lastUpdatedTime"] = lastUpdatedTime;
    data["notes"] = notes;
    data["sectionId"] = sectionId;
    data["sectionName"] = sectionName;
    data["sectionTimeSlotId"] = sectionTimeSlotId;
    data["startTime"] = startTime;
    data["subjectId"] = subjectId;
    data["subjectName"] = subjectName;
    data["tdsId"] = tdsId;
    data["teacherId"] = teacherId;
    data["teacherName"] = teacherName;
    data["sectionSeqOrder"] = sectionSeqOrder;
    data["subjectSeqOrder"] = subjectSeqOrder;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetLogBookResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "logs": [
    {
      "agent": "string",
      "date": "string",
      "endTime": "string",
      "id": 0,
      "lastUpdatedTime": "string",
      "notes": "string",
      "sectionId": 0,
      "sectionName": "string",
      "sectionTimeSlotId": 0,
      "startTime": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<LogBook?>? logs;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetLogBookResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.logs,
    this.responseStatus,
  });

  GetLogBookResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    if (json["logs"] != null && (json["logs"] is List)) {
      final v = json["logs"];
      final arr0 = <LogBook>[];
      v.forEach((v) {
        arr0.add(LogBook.fromJson(v));
      });
      logs = arr0;
    }
    responseStatus = json["responseStatus"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    if (logs != null) {
      final v = logs;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["logs"] = arr0;
    }
    data["responseStatus"] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetLogBookResponse> getLogBook(GetLogBookRequest getLogBookRequest) async {
  debugPrint("Raising request to getLogBook with request ${jsonEncode(getLogBookRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_LOGBOOK;

  GetLogBookResponse getLogBookResponse = await HttpUtils.post(
    _url,
    getLogBookRequest.toJson(),
    GetLogBookResponse.fromJson,
  );

  debugPrint("GetLogBookResponse ${getLogBookResponse.toJson()}");
  return getLogBookResponse;
}

class CreateOrUpdateLogBookRequest {
/*
{
  "agentId": 0,
  "date": "string",
  "logbookId": 0,
  "notes": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionTimeSlotId": 0,
  "status": "active",
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? agentId;
  String? date;
  int? logbookId;
  String? notes;
  int? schoolId;
  int? sectionId;
  int? sectionTimeSlotId;
  String? status;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateLogBookRequest({
    this.agentId,
    this.date,
    this.logbookId,
    this.notes,
    this.schoolId,
    this.sectionId,
    this.sectionTimeSlotId,
    this.status,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });

  CreateOrUpdateLogBookRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json["agentId"]?.toString() ?? '');
    date = json["date"]?.toString();
    logbookId = int.tryParse(json["logbookId"]?.toString() ?? '');
    notes = json["notes"]?.toString();
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    sectionTimeSlotId = int.tryParse(json["sectionTimeSlotId"]?.toString() ?? '');
    status = json["status"]?.toString();
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    tdsId = int.tryParse(json["tdsId"]?.toString() ?? '');
    teacherId = int.tryParse(json["teacherId"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agentId"] = agentId;
    data["date"] = date;
    data["logbookId"] = logbookId;
    data["notes"] = notes;
    data["schoolId"] = schoolId;
    data["sectionId"] = sectionId;
    data["sectionTimeSlotId"] = sectionTimeSlotId;
    data["status"] = status;
    data["subjectId"] = subjectId;
    data["tdsId"] = tdsId;
    data["teacherId"] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateLogBookResponse {
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

  CreateOrUpdateLogBookResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateLogBookResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateLogBookResponse> createOrUpdateLogBook(CreateOrUpdateLogBookRequest createOrUpdateLogBookRequest) async {
  debugPrint("Raising request to createOrUpdateLogBook with request ${jsonEncode(createOrUpdateLogBookRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_LOGBOOK;

  CreateOrUpdateLogBookResponse createOrUpdateLogBookResponse = await HttpUtils.post(
    _url,
    createOrUpdateLogBookRequest.toJson(),
    CreateOrUpdateLogBookResponse.fromJson,
  );

  debugPrint("createOrUpdateLogBookResponse ${createOrUpdateLogBookResponse.toJson()}");
  return createOrUpdateLogBookResponse;
}

Future<List<int>> getLogBookReport(GetLogBookRequest getLogBookRequest) async {
  debugPrint("Raising request to getLogBook with request ${jsonEncode(getLogBookRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_LOGBOOK_REPORT;
  return await HttpUtils.postToDownloadFile(_url, getLogBookRequest.toJson());
}
