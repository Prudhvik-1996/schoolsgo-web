import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetHostelsRequest {
  String? date;
  int? hostelId;
  int? schoolId;
  int? userId;
  Map<String, dynamic> __origJson = {};

  GetHostelsRequest({
    this.date,
    this.hostelId,
    this.schoolId,
    this.userId,
  });

  GetHostelsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    hostelId = json['hostelId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    userId = json['userId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['hostelId'] = hostelId;
    data['schoolId'] = schoolId;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentBedInfo {
/*
{
  "bedInfo": "string",
  "hostelId": 0,
  "hostelName": "string",
  "roomId": 0,
  "roomName": "string",
  "studentId": 0,
  "wardenId": 0
}
*/

  String? bedInfo;
  int? hostelId;
  String? hostelName;
  int? roomId;
  String? roomName;
  int? studentId;
  int? wardenId;
  Map<String, dynamic> __origJson = {};

  TextEditingController bedInfoTextEditor = TextEditingController();

  StudentBedInfo({
    this.bedInfo,
    this.hostelId,
    this.hostelName,
    this.roomId,
    this.roomName,
    this.studentId,
    this.wardenId,
  }) {
    bedInfoTextEditor.text = bedInfo ?? "";
  }

  StudentBedInfo.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    bedInfo = json['bedInfo']?.toString();
    bedInfoTextEditor.text = bedInfo ?? "";
    hostelId = json['hostelId']?.toInt();
    hostelName = json['hostelName']?.toString();
    roomId = json['roomId']?.toInt();
    roomName = json['roomName']?.toString();
    studentId = json['studentId']?.toInt();
    wardenId = json['wardenId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bedInfo'] = bedInfo;
    data['hostelId'] = hostelId;
    data['hostelName'] = hostelName;
    data['roomId'] = roomId;
    data['roomName'] = roomName;
    data['studentId'] = studentId;
    data['wardenId'] = wardenId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class HostelRoom {
/*
{
  "comment": "string",
  "hostelId": 0,
  "hostelName": "string",
  "roomId": 0,
  "roomName": "string",
  "status": "active",
  "studentBedInfoList": [
    {
      "bedInfo": "string",
      "hostelId": 0,
      "hostelName": "string",
      "roomId": 0,
      "roomName": "string",
      "studentId": 0,
      "wardenId": 0
    }
  ],
  "wardenId": 0
}
*/

  String? comment;
  int? hostelId;
  String? hostelName;
  int? roomId;
  String? roomName;
  String? status;
  List<StudentBedInfo?>? studentBedInfoList;
  int? wardenId;
  Map<String, dynamic> __origJson = {};

  HostelRoom({
    this.comment,
    this.hostelId,
    this.hostelName,
    this.roomId,
    this.roomName,
    this.status,
    this.studentBedInfoList,
    this.wardenId,
  });

  HostelRoom.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    comment = json['comment']?.toString();
    hostelId = json['hostelId']?.toInt();
    hostelName = json['hostelName']?.toString();
    roomId = json['roomId']?.toInt();
    roomName = json['roomName']?.toString();
    status = json['status']?.toString();
    if (json['studentBedInfoList'] != null) {
      final v = json['studentBedInfoList'];
      final arr0 = <StudentBedInfo>[];
      v.forEach((v) {
        arr0.add(StudentBedInfo.fromJson(v));
      });
      studentBedInfoList = arr0;
    }
    wardenId = json['wardenId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['comment'] = comment;
    data['hostelId'] = hostelId;
    data['hostelName'] = hostelName;
    data['roomId'] = roomId;
    data['roomName'] = roomName;
    data['status'] = status;
    if (studentBedInfoList != null) {
      final v = studentBedInfoList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentBedInfoList'] = arr0;
    }
    data['wardenId'] = wardenId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Hostel {
/*
{
  "comment": "string",
  "hostelId": 0,
  "hostelInchargeId": 0,
  "hostelName": "string",
  "rooms": [
    {
      "comment": "string",
      "hostelId": 0,
      "hostelName": "string",
      "roomId": 0,
      "roomName": "string",
      "status": "active",
      "studentBedInfoList": [
        {
          "bedInfo": "string",
          "hostelId": 0,
          "hostelName": "string",
          "roomId": 0,
          "roomName": "string",
          "studentId": 0,
          "wardenId": 0
        }
      ],
      "wardenId": 0
    }
  ],
  "status": "active"
}
*/

  String? comment;
  int? hostelId;
  int? hostelInchargeId;
  String? hostelName;
  List<HostelRoom?>? rooms;
  String? status;
  Map<String, dynamic> __origJson = {};

  Hostel({
    this.comment,
    this.hostelId,
    this.hostelInchargeId,
    this.hostelName,
    this.rooms,
    this.status,
  });

  Hostel.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    comment = json['comment']?.toString();
    hostelId = json['hostelId']?.toInt();
    hostelInchargeId = json['hostelInchargeId']?.toInt();
    hostelName = json['hostelName']?.toString();
    if (json['rooms'] != null) {
      final v = json['rooms'];
      final arr0 = <HostelRoom>[];
      v.forEach((v) {
        arr0.add(HostelRoom.fromJson(v));
      });
      rooms = arr0;
    }
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['comment'] = comment;
    data['hostelId'] = hostelId;
    data['hostelInchargeId'] = hostelInchargeId;
    data['hostelName'] = hostelName;
    if (rooms != null) {
      final v = rooms;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['rooms'] = arr0;
    }
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetHostelsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "hostelsList": [
    {
      "comment": "string",
      "hostelId": 0,
      "hostelInchargeId": 0,
      "hostelName": "string",
      "rooms": [
        {
          "comment": "string",
          "hostelId": 0,
          "hostelName": "string",
          "roomId": 0,
          "roomName": "string",
          "status": "active",
          "studentBedInfoList": [
            {
              "bedInfo": "string",
              "hostelId": 0,
              "hostelName": "string",
              "roomId": 0,
              "roomName": "string",
              "studentId": 0,
              "wardenId": 0
            }
          ],
          "wardenId": 0
        }
      ],
      "status": "active"
    }
  ],
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  List<Hostel?>? hostelsList;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetHostelsResponse({
    this.errorCode,
    this.errorMessage,
    this.hostelsList,
    this.httpStatus,
    this.responseStatus,
  });

  GetHostelsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['hostelsList'] != null) {
      final v = json['hostelsList'];
      final arr0 = <Hostel>[];
      v.forEach((v) {
        arr0.add(Hostel.fromJson(v));
      });
      hostelsList = arr0;
    }
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    if (hostelsList != null) {
      final v = hostelsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['hostelsList'] = arr0;
    }
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetHostelsResponse> getHostels(GetHostelsRequest getHostelsRequest) async {
  debugPrint("Raising request to getHostels with request ${jsonEncode(getHostelsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_HOSTELS;

  GetHostelsResponse getHostelsResponse = await HttpUtils.post(
    _url,
    getHostelsRequest.toJson(),
    GetHostelsResponse.fromJson,
  );

  debugPrint("GetHostelsResponse ${getHostelsResponse.toJson()}");
  return getHostelsResponse;
}
