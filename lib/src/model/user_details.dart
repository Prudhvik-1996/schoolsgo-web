import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetUserDetailsResponse {
  GetUserDetailsResponse({
    required this.errorCode,
    required this.errorMessage,
    required this.httpStatus,
    required this.responseStatus,
    required this.userDetails,
  });
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<UserDetails>? userDetails;

  GetUserDetailsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'] ?? "";
    errorMessage = json['errorMessage'] ?? "";
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
    userDetails = List.from(json['userDetails']).map((e) => UserDetails.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['errorCode'] = errorCode;
    _data['errorMessage'] = errorMessage;
    _data['httpStatus'] = httpStatus;
    _data['responseStatus'] = responseStatus;
    _data['userDetails'] = userDetails!.map((e) => e.toJson()).toList();
    return _data;
  }
}

class UserDetails {
  UserDetails({
    this.firstName,
    this.lastName,
    this.mailId,
    this.status,
    this.userId,
    this.fourDigitPin,
  });
  String? firstName;
  String? lastName;
  String? mailId;
  String? status;
  int? userId;
  String? fourDigitPin;

  UserDetails.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    mailId = json['mailId'];
    status = json['status'];
    userId = json['userId'];
    fourDigitPin = json['fourDigitPin'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['firstName'] = firstName;
    _data['lastName'] = lastName;
    _data['mailId'] = mailId;
    _data['status'] = status;
    _data['userId'] = userId;
    _data['fourDigitPin'] = fourDigitPin;
    return _data;
  }
}

class UpdateUserFourDigitPinRequest {
/*
{
  "agent": 1,
  "newFourDigitPin": "1994",
  "userId": 1
}
*/

  int? agent;
  String? newFourDigitPin;
  int? userId;
  Map<String, dynamic> __origJson = {};

  UpdateUserFourDigitPinRequest({
    this.agent,
    this.newFourDigitPin,
    this.userId,
  });
  UpdateUserFourDigitPinRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    newFourDigitPin = json['newFourDigitPin']?.toString();
    userId = json['userId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['newFourDigitPin'] = newFourDigitPin;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class UpdateUserFourDigitPinResponse {
/*
{
  "responseStatus": "success",
  "errorCode": "null",
  "errorMessage": "null",
  "httpStatus": "OK"
}
*/

  String? responseStatus;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  Map<String, dynamic> __origJson = {};

  UpdateUserFourDigitPinResponse({
    this.responseStatus,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
  });
  UpdateUserFourDigitPinResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    responseStatus = json['responseStatus']?.toString();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['responseStatus'] = responseStatus;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<UpdateUserFourDigitPinResponse> updateUserFourDigitPin(UpdateUserFourDigitPinRequest updateUserFourDigitPinRequest) async {
  debugPrint("Raising request to updateUserFourDigitPin with request ${jsonEncode(updateUserFourDigitPinRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_USER_PIN;

  UpdateUserFourDigitPinResponse updateUserFourDigitPinResponse = await HttpUtils.post(
    _url,
    updateUserFourDigitPinRequest.toJson(),
    UpdateUserFourDigitPinResponse.fromJson,
  );

  debugPrint("UpdateUserFourDigitPinResponse ${updateUserFourDigitPinResponse.toJson()}");
  return updateUserFourDigitPinResponse;
}
