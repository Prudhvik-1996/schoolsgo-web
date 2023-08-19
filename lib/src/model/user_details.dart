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
    this.mobile,
    this.password,
    this.status,
    this.userId,
    this.fourDigitPin,
  });
  String? firstName;
  String? lastName;
  String? mailId;
  String? mobile;
  String? password;
  String? status;
  int? userId;
  String? fourDigitPin;

  UserDetails.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    mailId = json['mailId'];
    mobile = json['mobile'];
    password = json['password'];
    status = json['status'];
    userId = json['userId'];
    fourDigitPin = json['fourDigitPin'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['firstName'] = firstName;
    _data['lastName'] = lastName;
    _data['mailId'] = mailId;
    _data['mobile'] = mobile;
    _data['password'] = password;
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

class DoLoginWithLoginUserIdAndPasswordRequest {
/*
{
  "password": "string",
  "userLoginId": "string"
}
*/

  String? password;
  String? userLoginId;
  Map<String, dynamic> __origJson = {};

  DoLoginWithLoginUserIdAndPasswordRequest({
    this.password,
    this.userLoginId,
  });
  DoLoginWithLoginUserIdAndPasswordRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    password = json['password']?.toString();
    userLoginId = json['userLoginId']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['password'] = password;
    data['userLoginId'] = userLoginId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DoLoginWithLoginUserIdAndPasswordResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "schoolId": 0,
  "studentId": 0,
  "userId": 0
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? schoolId;
  int? studentId;
  int? userId;
  Map<String, dynamic> __origJson = {};

  DoLoginWithLoginUserIdAndPasswordResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.schoolId,
    this.studentId,
    this.userId,
  });
  DoLoginWithLoginUserIdAndPasswordResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    userId = json['userId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<DoLoginWithLoginUserIdAndPasswordResponse> doLoginWithLoginUserIdAndPassword(
    DoLoginWithLoginUserIdAndPasswordRequest doLoginWithLoginUserIdAndPasswordRequest) async {
  debugPrint("Raising request to doLoginWithLoginUserIdAndPassword with request ${jsonEncode(doLoginWithLoginUserIdAndPasswordRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + DO_LOGIN_WITH_USER_ID_AND_PASSWORD;

  DoLoginWithLoginUserIdAndPasswordResponse doLoginWithLoginUserIdAndPasswordResponse = await HttpUtils.post(
    _url,
    doLoginWithLoginUserIdAndPasswordRequest.toJson(),
    DoLoginWithLoginUserIdAndPasswordResponse.fromJson,
  );

  debugPrint("DoLoginWithLoginUserIdAndPasswordResponse ${doLoginWithLoginUserIdAndPasswordResponse.toJson()}");
  return doLoginWithLoginUserIdAndPasswordResponse;
}

class UpdateLoginCredentialsRequest {
/*
{
  "agentId": 0,
  "newSixDigitPin": "string",
  "schoolId": 0,
  "studentId": 0,
  "userId": 0
}
*/

  int? agentId;
  String? newSixDigitPin;
  int? schoolId;
  int? studentId;
  int? userId;
  Map<String, dynamic> __origJson = {};

  UpdateLoginCredentialsRequest({
    this.agentId,
    this.newSixDigitPin,
    this.schoolId,
    this.studentId,
    this.userId,
  });
  UpdateLoginCredentialsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    newSixDigitPin = json['newSixDigitPin']?.toString();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    userId = json['userId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['newSixDigitPin'] = newSixDigitPin;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class UpdateLoginCredentialsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "schoolId": 0,
  "studentId": 0,
  "userId": 0
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? schoolId;
  int? studentId;
  int? userId;
  Map<String, dynamic> __origJson = {};

  UpdateLoginCredentialsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.schoolId,
    this.studentId,
    this.userId,
  });
  UpdateLoginCredentialsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    userId = json['userId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<UpdateLoginCredentialsResponse> updateLoginCredentials(UpdateLoginCredentialsRequest updateLoginCredentialsRequest) async {
  debugPrint("Raising request to updateLoginCredentials with request ${jsonEncode(updateLoginCredentialsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_LOGIN_CREDENTIALS;

  UpdateLoginCredentialsResponse updateLoginCredentialsResponse = await HttpUtils.post(
    _url,
    updateLoginCredentialsRequest.toJson(),
    UpdateLoginCredentialsResponse.fromJson,
  );

  debugPrint("UpdateLoginCredentialsResponse ${updateLoginCredentialsResponse.toJson()}");
  return updateLoginCredentialsResponse;
}
