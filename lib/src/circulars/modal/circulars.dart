import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetCircularsRequest {
/*
{
  "circularId": 0,
  "franchiseId": 0,
  "schoolId": 0
}
*/

  int? circularId;
  int? franchiseId;
  int? schoolId;
  String? role;
  Map<String, dynamic> __origJson = {};

  GetCircularsRequest({
    this.circularId,
    this.franchiseId,
    this.schoolId,
    this.role,
  });
  GetCircularsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    circularId = json['circularId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    role = json['role']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['circularId'] = circularId;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['role'] = role;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CircularMediaBean {
/*
{
  "agentId": 0,
  "circularId": 0,
  "circularMediaMapId": 0,
  "createTime": 0,
  "mediaId": 0,
  "mediaType": "string",
  "mediaUrl": "string",
  "status": "active"
}
*/

  int? agentId;
  int? circularId;
  int? circularMediaMapId;
  int? createTime;
  int? mediaId;
  String? mediaType;
  String? mediaUrl;
  String? status;
  Map<String, dynamic> __origJson = {};

  CircularMediaBean({
    this.agentId,
    this.circularId,
    this.circularMediaMapId,
    this.createTime,
    this.mediaId,
    this.mediaType,
    this.mediaUrl,
    this.status,
  });
  CircularMediaBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    circularId = json['circularId']?.toInt();
    circularMediaMapId = json['circularMediaMapId']?.toInt();
    createTime = json['createTime']?.toInt();
    mediaId = json['mediaId']?.toInt();
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['circularId'] = circularId;
    data['circularMediaMapId'] = circularMediaMapId;
    data['createTime'] = createTime;
    data['mediaId'] = mediaId;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CircularBean {
/*
{
  "agentId": 0,
  "circularId": 0,
  "circularMediaBeans": [
    {
      "agentId": 0,
      "circularId": 0,
      "circularMediaMapId": 0,
      "createTime": 0,
      "mediaId": 0,
      "mediaType": "string",
      "mediaUrl": "string",
      "status": "active"
    }
  ],
  "circularType": "A",
  "createTime": 0,
  "description": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "status": "active",
  "title": "string"
}
*/

  int? agentId;
  int? circularId;
  List<CircularMediaBean?>? circularMediaBeans;
  String? circularType;
  int? createTime;
  String? description;
  int? franchiseId;
  String? franchiseName;
  int? schoolId;
  String? schoolName;
  String? branchCode;
  String? status;
  String? title;
  Map<String, dynamic> origJson = {};

  bool isEditMode = false;
  bool showSentTo = false;

  CircularBean({
    this.agentId,
    this.circularId,
    this.circularMediaBeans,
    this.circularType,
    this.createTime,
    this.description,
    this.franchiseId,
    this.franchiseName,
    this.schoolId,
    this.schoolName,
    this.branchCode,
    this.status,
    this.title,
  });
  CircularBean.fromJson(Map<String, dynamic> json) {
    origJson = json;
    agentId = json['agentId']?.toInt();
    circularId = json['circularId']?.toInt();
    if (json['circularMediaBeans'] != null) {
      final v = json['circularMediaBeans'];
      final arr0 = <CircularMediaBean>[];
      v.forEach((v) {
        arr0.add(CircularMediaBean.fromJson(v));
      });
      circularMediaBeans = arr0;
    }
    circularType = json['circularType']?.toString();
    createTime = json['createTime']?.toInt();
    description = json['description']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    branchCode = json['branchCode']?.toString();
    status = json['status']?.toString();
    title = json['title']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['circularId'] = circularId;
    if (circularMediaBeans != null) {
      final v = circularMediaBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['circularMediaBeans'] = arr0;
    }
    data['circularType'] = circularType;
    data['createTime'] = createTime;
    data['description'] = description;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['branchCode'] = branchCode;
    data['status'] = status;
    data['title'] = title;
    return data;
  }
}

class GetCircularsResponse {
/*
{
  "circulars": [
    {
      "agentId": 0,
      "circularId": 0,
      "circularMediaBeans": [
        {
          "agentId": 0,
          "circularId": 0,
          "circularMediaMapId": 0,
          "createTime": 0,
          "mediaId": 0,
          "mediaType": "string",
          "mediaUrl": "string",
          "status": "active"
        }
      ],
      "circularType": "A",
      "createTime": 0,
      "description": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "schoolId": 0,
      "schoolName": "string",
      "status": "active",
      "title": "string"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<CircularBean?>? circulars;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetCircularsResponse({
    this.circulars,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetCircularsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['circulars'] != null) {
      final v = json['circulars'];
      final arr0 = <CircularBean>[];
      v.forEach((v) {
        arr0.add(CircularBean.fromJson(v));
      });
      circulars = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (circulars != null) {
      final v = circulars;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['circulars'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetCircularsResponse> getCirculars(GetCircularsRequest getCircularsRequest) async {
  debugPrint("Raising request to getCirculars with request ${jsonEncode(getCircularsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_CIRCULARS;

  GetCircularsResponse getCircularsResponse = await HttpUtils.post(
    _url,
    getCircularsRequest.toJson(),
    GetCircularsResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("GetCircularsResponse ${getCircularsResponse.toJson()}");
  return getCircularsResponse;
}

class CreateOrUpdateCircularRequest extends CircularBean {}

class CreateOrUpdateCircularResponse {
/*
{
  "circularId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? circularId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateCircularResponse({
    this.circularId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateCircularResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    circularId = json['circularId']?.toInt();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['circularId'] = circularId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateCircularResponse> createOrUpdateCircular(CreateOrUpdateCircularRequest createOrUpdateCircularRequest) async {
  debugPrint("Raising request to createOrUpdateCircular with request ${jsonEncode(createOrUpdateCircularRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_CIRCULAR;

  CreateOrUpdateCircularResponse createOrUpdateCircularResponse = await HttpUtils.post(
    _url,
    createOrUpdateCircularRequest.toJson(),
    CreateOrUpdateCircularResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("CreateOrUpdateCircularResponse ${createOrUpdateCircularResponse.toJson()}");
  return createOrUpdateCircularResponse;
}
