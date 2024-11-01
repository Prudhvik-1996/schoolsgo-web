import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class AppVersion {
  String? agent;
  String? appName;
  String? comment;
  int? createTime;
  String? description;
  String? status;
  String? versionName;
  Map<String, dynamic> __origJson = {};

  AppVersion({
    this.agent,
    this.appName,
    this.comment,
    this.createTime,
    this.description,
    this.status,
    this.versionName,
  });

  AppVersion.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    appName = json['appName']?.toString();
    comment = json['comment']?.toString();
    createTime = int.tryParse(json['createTime']?.toString() ?? "");
    description = json['description']?.toString();
    status = json['status']?.toString();
    versionName = json['versionName']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['appName'] = appName;
    data['comment'] = comment;
    data['createTime'] = createTime;
    data['description'] = description;
    data['status'] = status;
    data['versionName'] = versionName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<AppVersion?> getAppVersion(String? versionName) async {
  debugPrint("Raising request to getAppVersion with request $versionName");
  String _url = SCHOOLS_GO_BASE_URL + getAppVersionUrl(null);

  AppVersion? appVersion = await HttpUtils.get(
    _url,
    AppVersion.fromJson,
  );

  debugPrint("AppVersion ${appVersion?.toJson()}");
  return appVersion;
}

class GetAppUpdateLogResponse {
/*
{
  "appVersionBeans": [
    {
      "agent": "string",
      "appName": "string",
      "comment": "string",
      "createTime": 10,
      "description": "string",
      "status": "string",
      "versionName": "string"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<AppVersion>? appVersionBeans;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  GetAppUpdateLogResponse({
    this.appVersionBeans,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetAppUpdateLogResponse.fromJson(Map<String, dynamic> json) {
    if (json['appVersionBeans'] != null) {
      final v = json['appVersionBeans'];
      final arr0 = <AppVersion>[];
      v.forEach((v) {
        arr0.add(AppVersion.fromJson(v));
      });
      appVersionBeans = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (appVersionBeans != null) {
      final v = appVersionBeans ?? [];
      final arr0 = [];
      for (var v in v) {
        arr0.add(v.toJson());
      }
      data['appVersionBeans'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<GetAppUpdateLogResponse?> getAppUpdateLog() async {
  debugPrint("Raising request to getAppUpdateLog");
  String _url = SCHOOLS_GO_BASE_URL + GET_APP_UPDATE_LOG_URL;

  GetAppUpdateLogResponse? getAppUpdateLogResponse = await HttpUtils.get(
    _url,
    GetAppUpdateLogResponse.fromJson,
  );

  debugPrint("GetAppUpdateLogResponse ${getAppUpdateLogResponse?.toJson()}");
  return getAppUpdateLogResponse;
}
