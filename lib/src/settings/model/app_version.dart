import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class AppVersion {

  String? agent;
  String? appName;
  String? comment;
  String? createTime;
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
    createTime = json['createTime']?.toString();
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
  debugPrint("Raising request to getLogBook with request $versionName");
  String _url = SCHOOLS_GO_BASE_URL + getAppVersionUrl(null);

  AppVersion? appVersion = await HttpUtils.get(
    _url,
    AppVersion.fromJson,
  );

  debugPrint("AppVersion ${appVersion?.toJson()}");
  return appVersion;
}