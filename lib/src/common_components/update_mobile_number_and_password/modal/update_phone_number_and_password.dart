import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class UpdatePhoneNumberPasswordRequest {
  int? agent;
  String? newPassword;
  String? newPhoneNumber;
  String? oldPhoneNumber;
  int? userId;
  Map<String, dynamic> __origJson = {};

  UpdatePhoneNumberPasswordRequest({
    this.agent,
    this.newPassword,
    this.newPhoneNumber,
    this.oldPhoneNumber,
    this.userId,
  });

  UpdatePhoneNumberPasswordRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    newPassword = json['newPassword']?.toString();
    newPhoneNumber = json['newPhoneNumber']?.toString();
    oldPhoneNumber = json['oldPhoneNumber']?.toString();
    userId = json['userId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['newPassword'] = newPassword;
    data['newPhoneNumber'] = newPhoneNumber;
    data['oldPhoneNumber'] = oldPhoneNumber;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class UpdatePhoneNumberPasswordResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  UpdatePhoneNumberPasswordResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  UpdatePhoneNumberPasswordResponse.fromJson(Map<String, dynamic> json) {
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

Future<UpdatePhoneNumberPasswordResponse> updatePhoneNumberPassword(UpdatePhoneNumberPasswordRequest updatePhoneNumberPasswordRequest) async {
  debugPrint("Raising request to updatePhoneNumberPassword with request ${jsonEncode(updatePhoneNumberPasswordRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_MOBILE_AND_PASSWORD;

  UpdatePhoneNumberPasswordResponse updatePhoneNumberPasswordResponse = await HttpUtils.post(
    _url,
    updatePhoneNumberPasswordRequest.toJson(),
    UpdatePhoneNumberPasswordResponse.fromJson,
  );

  debugPrint("UpdatePhoneNumberPasswordResponse ${updatePhoneNumberPasswordResponse.toJson()}");
  return updatePhoneNumberPasswordResponse;
}
