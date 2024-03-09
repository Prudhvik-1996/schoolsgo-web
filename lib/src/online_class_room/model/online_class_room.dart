import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/time_table/modal/section_wise_time_slots.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetOnlineClassRoomsRequest {
/*
{
  "date": "string",
  "endTime": 0,
  "meetingUrl": "string",
  "schoolId": 0,
  "sectionId": 0,
  "startTime": 0,
  "status": "active",
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0,
  "weekId": 0
}
*/

  String? date;
  int? endTime;
  String? meetingUrl;
  int? schoolId;
  int? sectionId;
  int? startTime;
  String? status;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  int? weekId;
  int? academicYearId;
  Map<String, dynamic> __origJson = {};

  GetOnlineClassRoomsRequest({
    this.date,
    this.endTime,
    this.meetingUrl,
    this.schoolId,
    this.sectionId,
    this.startTime,
    this.status,
    this.subjectId,
    this.tdsId,
    this.teacherId,
    this.weekId,
    this.academicYearId,
  });

  GetOnlineClassRoomsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    endTime = int.tryParse(json['endTime']?.toString() ?? '');
    meetingUrl = json['meetingUrl']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    startTime = int.tryParse(json['startTime']?.toString() ?? '');
    status = json['status']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    weekId = int.tryParse(json['weekId']?.toString() ?? '');
    academicYearId = int.tryParse(json['academicYearId']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['endTime'] = endTime;
    data['meetingUrl'] = meetingUrl;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['startTime'] = startTime;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['weekId'] = weekId;
    data['academicYearId'] = academicYearId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class OnlineClassRoom {
/*
{
  "agent": 0,
  "createTime": "",
  "date": "string",
  "endTime": "",
  "lastUpdated": "",
  "ocrId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "sectionWiseTimeSlotId": 0,
  "startTime": "",
  "status": "active",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string",
  "week": "string",
  "weekId": 0
}
*/

  int? agent;
  String? createTime;
  String? date;
  String? endTime;
  String? lastUpdated;
  int? ocrId;
  int? sectionId;
  String? sectionName;
  int? sectionWiseTimeSlotId;
  String? startTime;
  String? status;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  String? week;
  int? weekId;
  Map<String, dynamic> __origJson = {};

  OnlineClassRoom({
    this.agent,
    this.createTime,
    this.date,
    this.endTime,
    this.lastUpdated,
    this.ocrId,
    this.sectionId,
    this.sectionName,
    this.sectionWiseTimeSlotId,
    this.startTime,
    this.status,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
    this.week,
    this.weekId,
  });

  OnlineClassRoom clone() {
    return OnlineClassRoom(
      agent: agent,
      createTime: createTime,
      date: date,
      endTime: endTime,
      lastUpdated: lastUpdated,
      ocrId: ocrId,
      sectionId: sectionId,
      sectionName: sectionName,
      sectionWiseTimeSlotId: sectionWiseTimeSlotId,
      startTime: startTime,
      status: status,
      subjectId: subjectId,
      subjectName: subjectName,
      tdsId: tdsId,
      teacherId: teacherId,
      teacherName: teacherName,
      week: week,
      weekId: weekId,
    );
  }

  SectionWiseTimeSlotBean toSectionWiseTimeSlotBean() {
    return SectionWiseTimeSlotBean(
      sectionId: sectionId,
      subjectName: subjectName,
      subjectId: subjectId,
      week: week,
      startTime: startTime,
      endTime: endTime,
      teacherId: teacherId,
      teacherName: teacherName,
      agent: agent,
      sectionName: sectionName,
      status: status,
      tdsId: tdsId,
      date: date,
      lastUpdated: lastUpdated,
      createTime: createTime,
      weekId: weekId,
    )..isOcr = true;
  }

  OnlineClassRoom.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = int.tryParse(json['agent']?.toString() ?? '');
    createTime = json['createTime']?.toString();
    date = json['date']?.toString();
    endTime = json['endTime']?.toString();
    lastUpdated = json['lastUpdated']?.toString();
    ocrId = int.tryParse(json['ocrId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    sectionName = json['sectionName']?.toString();
    sectionWiseTimeSlotId = int.tryParse(json['sectionWiseTimeSlotId']?.toString() ?? '');
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    subjectName = json['subjectName']?.toString();
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherName = json['teacherName']?.toString();
    week = json['week']?.toString();
    weekId = int.tryParse(json['weekId']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['createTime'] = createTime;
    data['date'] = date;
    data['endTime'] = endTime;
    data['lastUpdated'] = lastUpdated;
    data['ocrId'] = ocrId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sectionWiseTimeSlotId'] = sectionWiseTimeSlotId;
    data['startTime'] = startTime;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['week'] = week;
    data['weekId'] = weekId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "OnlineClassRoom{'agent': $agent, 'createTime': $createTime, 'date': $date, 'endTime': $endTime, 'lastUpdated': $lastUpdated, 'ocrId': $ocrId, 'sectionId': $sectionId, 'sectionName': $sectionName, 'sectionWiseTimeSlotId': $sectionWiseTimeSlotId, 'startTime': $startTime, 'status': $status, 'subjectId': $subjectId, 'subjectName': $subjectName, 'tdsId': $tdsId, 'teacherId': $teacherId, 'teacherName': $teacherName, 'week': $week, 'weekId': $weekId}\n";
  }

  @override
  bool operator ==(Object other) {
    return toString() == other.toString();
  }

  int compareTo(OnlineClassRoom other) {
    if (date != null && other.date != null) {
      int dateComp = convertYYYYMMDDFormatToDateTime(date).compareTo(convertYYYYMMDDFormatToDateTime(other.date));
      if (dateComp != 0) return dateComp;
    }
    int timeComp =
        getSecondsEquivalentOfTimeFromWHHMMSS(startTime!, weekId).compareTo(getSecondsEquivalentOfTimeFromWHHMMSS(other.startTime!, other.weekId));
    return timeComp;
  }

  @override
  int get hashCode => toString().hashCode;
}

class GetOnlineClassRoomsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "onlineClassRooms": [
    {
      "agent": 0,
      "createTime": "",
      "date": "string",
      "endTime": "",
      "lastUpdated": "",
      "ocrId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "sectionWiseTimeSlotId": 0,
      "startTime": "",
      "status": "active",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string",
      "week": "string",
      "weekId": 0
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<OnlineClassRoom?>? onlineClassRooms;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetOnlineClassRoomsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.onlineClassRooms,
    this.responseStatus,
  });

  GetOnlineClassRoomsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['onlineClassRooms'] != null && (json['onlineClassRooms'] is List)) {
      final v = json['onlineClassRooms'];
      final arr0 = <OnlineClassRoom>[];
      v.forEach((v) {
        arr0.add(OnlineClassRoom.fromJson(v));
      });
      onlineClassRooms = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (onlineClassRooms != null) {
      final v = onlineClassRooms;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['onlineClassRooms'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetOnlineClassRoomsResponse> getOnlineClassRooms(GetOnlineClassRoomsRequest getOnlineClassRoomsRequest) async {
  debugPrint("Raising request to getOnlineClassRooms with request ${jsonEncode(getOnlineClassRoomsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ONLINE_CLASS_ROOMS;

  GetOnlineClassRoomsResponse getOnlineClassRoomsResponse = await HttpUtils.post(
    _url,
    getOnlineClassRoomsRequest.toJson(),
    GetOnlineClassRoomsResponse.fromJson,
  );

  debugPrint("GetOnlineClassRoomsResponse ${getOnlineClassRoomsResponse.toJson()}");
  return getOnlineClassRoomsResponse;
}

class UpdateOcrAsPerTtRequest {
/*
{
  "agent": 0,
  "ocrAsPerTt": true,
  "schoolId": 0,
  "sectionId": 0
}
*/

  int? agent;
  bool? ocrAsPerTt;
  int? schoolId;
  int? sectionId;
  Map<String, dynamic> __origJson = {};

  UpdateOcrAsPerTtRequest({
    this.agent,
    this.ocrAsPerTt,
    this.schoolId,
    this.sectionId,
  });

  UpdateOcrAsPerTtRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = int.tryParse(json['agent']?.toString() ?? '');
    ocrAsPerTt = json['ocrAsPerTt'];
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['ocrAsPerTt'] = ocrAsPerTt;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class UpdateOcrAsPerTtResponse {
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

  UpdateOcrAsPerTtResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  UpdateOcrAsPerTtResponse.fromJson(Map<String, dynamic> json) {
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

Future<UpdateOcrAsPerTtResponse> updateOcrAsPerTtRooms(UpdateOcrAsPerTtRequest updateOcrAsPerTtRoomsRequest) async {
  debugPrint("Raising request to updateOcrAsPerTtRooms with request ${jsonEncode(updateOcrAsPerTtRoomsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_OCR_AS_PER_TT;

  UpdateOcrAsPerTtResponse updateOcrAsPerTtRoomsResponse = await HttpUtils.post(
    _url,
    updateOcrAsPerTtRoomsRequest.toJson(),
    UpdateOcrAsPerTtResponse.fromJson,
  );

  debugPrint("UpdateOcrAsPerTtResponse ${updateOcrAsPerTtRoomsResponse.toJson()}");
  return updateOcrAsPerTtRoomsResponse;
}

class CreateOrUpdateCustomOcrRequest {
/*
{
  "agent": 0,
  "date": "string",
  "endTime": "",
  "ocrId": 0,
  "schoolId": 0,
  "startTime": "",
  "status": "active",
  "tdsId": 0
}
*/

  int? agent;
  String? date;
  String? endTime;
  int? ocrId;
  int? schoolId;
  String? startTime;
  String? status;
  int? tdsId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateCustomOcrRequest({
    this.agent,
    this.date,
    this.endTime,
    this.ocrId,
    this.schoolId,
    this.startTime,
    this.status,
    this.tdsId,
  });

  CreateOrUpdateCustomOcrRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = int.tryParse(json['agent']?.toString() ?? '');
    date = json['date']?.toString();
    endTime = json['endTime']?.toString();
    ocrId = int.tryParse(json['ocrId']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    startTime = json['startTime']?.toString();
    status = json['status']?.toString();
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['date'] = date;
    data['endTime'] = endTime;
    data['ocrId'] = ocrId;
    data['schoolId'] = schoolId;
    data['startTime'] = startTime;
    data['status'] = status;
    data['tdsId'] = tdsId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateCustomOcrResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "ocrId": 0,
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  int? ocrId;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateCustomOcrResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.ocrId,
    this.responseStatus,
  });

  CreateOrUpdateCustomOcrResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    ocrId = int.tryParse(json['ocrId']?.toString() ?? '');
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['ocrId'] = ocrId;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateCustomOcrResponse> createOrUpdateCustomOcrRooms(CreateOrUpdateCustomOcrRequest createOrUpdateCustomOcrRoomsRequest) async {
  debugPrint("Raising request to createOrUpdateCustomOcrRooms with request ${jsonEncode(createOrUpdateCustomOcrRoomsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_ONLINE_CLASS_ROOMS;

  CreateOrUpdateCustomOcrResponse createOrUpdateCustomOcrRoomsResponse = await HttpUtils.post(
    _url,
    createOrUpdateCustomOcrRoomsRequest.toJson(),
    CreateOrUpdateCustomOcrResponse.fromJson,
  );

  debugPrint("CreateOrUpdateCustomOcrResponse ${createOrUpdateCustomOcrRoomsResponse.toJson()}");
  return createOrUpdateCustomOcrRoomsResponse;
}
