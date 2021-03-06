import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

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
  Map<String, dynamic> __origJson = {};

  GetLogBookRequest({
    this.date,
    this.schoolId,
    this.sectionId,
    this.sectionTimeSlotId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });
  GetLogBookRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = int.tryParse(json["date"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    sectionTimeSlotId =
        int.tryParse(json["sectionTimeSlotId"]?.toString() ?? '');
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    tdsId = int.tryParse(json["tdsId"]?.toString() ?? '');
    teacherId = int.tryParse(json["teacherId"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["date"] = date;
    data["schoolId"] = schoolId;
    data["sectionId"] = sectionId;
    data["sectionTimeSlotId"] = sectionTimeSlotId;
    data["subjectId"] = subjectId;
    data["tdsId"] = tdsId;
    data["teacherId"] = teacherId;
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
    sectionTimeSlotId =
        int.tryParse(json["sectionTimeSlotId"]?.toString() ?? '');
    startTime = json["startTime"]?.toString();
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    subjectName = json["subjectName"]?.toString();
    tdsId = int.tryParse(json["tdsId"]?.toString() ?? '');
    teacherId = int.tryParse(json["teacherId"]?.toString() ?? '');
    teacherName = json["teacherName"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    if (logs != null) {
      final v = logs;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["logs"] = arr0;
    }
    data["responseStatus"] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetLogBookResponse> getLogBook(
    GetLogBookRequest getLogBookRequest) async {
  print(
      "Raising request to getLogBook with request ${jsonEncode(getLogBookRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_LOGBOOK;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getLogBookRequest.toJson()),
  );

  GetLogBookResponse getLogBookResponse =
      GetLogBookResponse.fromJson(json.decode(response.body));
  print("GetLogBookResponse ${getLogBookResponse.toJson()}");
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
    sectionTimeSlotId =
        int.tryParse(json["sectionTimeSlotId"]?.toString() ?? '');
    status = json["status"]?.toString();
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    tdsId = int.tryParse(json["tdsId"]?.toString() ?? '');
    teacherId = int.tryParse(json["teacherId"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateLogBookResponse> createOrUpdateLogBook(
    CreateOrUpdateLogBookRequest createOrUpdateLogBookRequest) async {
  print(
      "Raising request to createOrUpdateLogBook with request ${jsonEncode(createOrUpdateLogBookRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_LOGBOOK;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateLogBookRequest.toJson()),
  );

  CreateOrUpdateLogBookResponse createOrUpdateLogBookResponse =
      CreateOrUpdateLogBookResponse.fromJson(json.decode(response.body));
  print(
      "createOrUpdateLogBookResponse ${createOrUpdateLogBookResponse.toJson()}");
  return createOrUpdateLogBookResponse;
}
