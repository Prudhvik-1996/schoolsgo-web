import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GenerateOtpRequest {
/*
{
  "channel": "ANDROID",
  "deviceName": "string",
  "otpType": "LOGIN",
  "requestedEmail": "string",
  "requestedPhone": "string",
  "userId": 0
}
*/

  String? channel;
  String? deviceName;
  String? otpType;
  String? requestedEmail;
  String? requestedPhone;
  int? userId;
  Map<String, dynamic> __origJson = {};

  GenerateOtpRequest({
    this.channel,
    this.deviceName,
    this.otpType,
    this.requestedEmail,
    this.requestedPhone,
    this.userId,
  });

  GenerateOtpRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    channel = json['channel']?.toString();
    deviceName = json['deviceName']?.toString();
    otpType = json['otpType']?.toString();
    requestedEmail = json['requestedEmail']?.toString();
    requestedPhone = json['requestedPhone']?.toString();
    userId = json['userId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['channel'] = channel;
    data['deviceName'] = deviceName;
    data['otpType'] = otpType;
    data['requestedEmail'] = requestedEmail;
    data['requestedPhone'] = requestedPhone;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class OtpBean {
/*
{
  "createdTime": 0,
  "deviceName": "string",
  "otpId": 0,
  "otpType": "LOGIN",
  "otpValue": "string",
  "requestedChannelType": "ANDROID",
  "requestedUser": 0,
  "requestedUserEmail": "string",
  "requestedUserMobile": "string",
  "status": "active",
  "ttl": 0
}
*/

  int? createdTime;
  String? deviceName;
  int? otpId;
  String? otpType;
  String? otpValue;
  String? requestedChannelType;
  int? requestedUser;
  String? requestedUserEmail;
  String? requestedUserMobile;
  String? status;
  int? ttl;
  Map<String, dynamic> __origJson = {};

  OtpBean({
    this.createdTime,
    this.deviceName,
    this.otpId,
    this.otpType,
    this.otpValue,
    this.requestedChannelType,
    this.requestedUser,
    this.requestedUserEmail,
    this.requestedUserMobile,
    this.status,
    this.ttl,
  });

  OtpBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    createdTime = json['createdTime']?.toInt();
    deviceName = json['deviceName']?.toString();
    otpId = json['otpId']?.toInt();
    otpType = json['otpType']?.toString();
    otpValue = json['otpValue']?.toString();
    requestedChannelType = json['requestedChannelType']?.toString();
    requestedUser = json['requestedUser']?.toInt();
    requestedUserEmail = json['requestedUserEmail']?.toString();
    requestedUserMobile = json['requestedUserMobile']?.toString();
    status = json['status']?.toString();
    ttl = json['ttl']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['createdTime'] = createdTime;
    data['deviceName'] = deviceName;
    data['otpId'] = otpId;
    data['otpType'] = otpType;
    data['otpValue'] = otpValue;
    data['requestedChannelType'] = requestedChannelType;
    data['requestedUser'] = requestedUser;
    data['requestedUserEmail'] = requestedUserEmail;
    data['requestedUserMobile'] = requestedUserMobile;
    data['status'] = status;
    data['ttl'] = ttl;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GenerateOtpResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "otpBean": {
    "createdTime": 0,
    "deviceName": "string",
    "otpId": 0,
    "otpType": "LOGIN",
    "otpValue": "string",
    "requestedChannelType": "ANDROID",
    "requestedUser": 0,
    "requestedUserEmail": "string",
    "requestedUserMobile": "string",
    "status": "active",
    "ttl": 0
  },
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  OtpBean? otpBean;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GenerateOtpResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.otpBean,
    this.responseStatus,
  });

  GenerateOtpResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    otpBean = (json['otpBean'] != null) ? OtpBean.fromJson(json['otpBean']) : null;
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (otpBean != null) {
      data['otpBean'] = otpBean!.toJson();
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GenerateOtpResponse> generateOtp(GenerateOtpRequest generateOtpRequest) async {
  debugPrint("Raising request to generateOtp with request ${jsonEncode(generateOtpRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + REQUEST_OTP;

  GenerateOtpResponse generateOtpResponse = await HttpUtils.post(
    _url,
    generateOtpRequest.toJson(),
    GenerateOtpResponse.fromJson,
  );

  debugPrint("GenerateOtpResponse ${generateOtpResponse.toJson()}");
  return generateOtpResponse;
}

class SendEmailRequest {
/*
{
  "attachment": "string",
  "msgBody": "string",
  "recipient": "string",
  "subject": "string"
}
*/

  String? attachment;
  String? msgBody;
  String? recipient;
  String? subject;
  Map<String, dynamic> __origJson = {};

  SendEmailRequest({
    this.attachment,
    this.msgBody,
    this.recipient,
    this.subject,
  });

  SendEmailRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    attachment = json['attachment']?.toString();
    msgBody = json['msgBody']?.toString();
    recipient = json['recipient']?.toString();
    subject = json['subject']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attachment'] = attachment;
    data['msgBody'] = msgBody;
    data['recipient'] = recipient;
    data['subject'] = subject;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<String> sendEmail(SendEmailRequest sendEmailRequest) async {
  debugPrint("Raising request to sendEmail with request ${jsonEncode(sendEmailRequest.toJson())}");
  String _url = SCHOOLS_GO_MESSAGING_SERVICE_BASE_URL + SEND_EMAIL;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(sendEmailRequest.toJson()),
  );
  String sendEmailResponse = response.body;

  debugPrint("SendEmailResponse $sendEmailResponse");
  return sendEmailResponse;
}
