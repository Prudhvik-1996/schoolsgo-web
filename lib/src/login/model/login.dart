import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class DoLoginRequestOtpBean {
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

  DoLoginRequestOtpBean({
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
  DoLoginRequestOtpBean.fromJson(Map<String, dynamic> json) {
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

class FcmBean {
/*
{
  "fcmToken": "string",
  "fcmTokenId": 0,
  "requestedDevice": "string",
  "status": "active",
  "userId": 0,
  "userName": "string"
}
*/

  String? fcmToken;
  int? fcmTokenId;
  String? requestedDevice;
  String? status;
  int? userId;
  String? userName;
  Map<String, dynamic> __origJson = {};

  FcmBean({
    this.fcmToken,
    this.fcmTokenId,
    this.requestedDevice,
    this.status,
    this.userId,
    this.userName,
  });
  FcmBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    fcmToken = json['fcmToken']?.toString();
    fcmTokenId = json['fcmTokenId']?.toInt();
    requestedDevice = json['requestedDevice']?.toString();
    status = json['status']?.toString();
    userId = json['userId']?.toInt();
    userName = json['userName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fcmToken'] = fcmToken;
    data['fcmTokenId'] = fcmTokenId;
    data['requestedDevice'] = requestedDevice;
    data['status'] = status;
    data['userId'] = userId;
    data['userName'] = userName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateFcmTokenRequest {
/*
{
  "fcmBean": {
    "fcmToken": "string",
    "fcmTokenId": 0,
    "requestedDevice": "string",
    "status": "active",
    "userId": 0,
    "userName": "string"
  }
}
*/

  FcmBean? fcmBean;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateFcmTokenRequest({
    this.fcmBean,
  });
  CreateOrUpdateFcmTokenRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    fcmBean = (json['fcmBean'] != null) ? FcmBean.fromJson(json['fcmBean']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (fcmBean != null) {
      data['fcmBean'] = fcmBean!.toJson();
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DoLoginRequest {
/*
{
  "createOrUpdateFcmTokenRequest": {
    "fcmBean": {
      "fcmToken": "string",
      "fcmTokenId": 0,
      "requestedDevice": "string",
      "status": "active",
      "userId": 0,
      "userName": "string"
    }
  },
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
  }
}
*/

  CreateOrUpdateFcmTokenRequest? createOrUpdateFcmTokenRequest;
  DoLoginRequestOtpBean? otpBean;
  Map<String, dynamic> __origJson = {};

  DoLoginRequest({
    this.createOrUpdateFcmTokenRequest,
    this.otpBean,
  });
  DoLoginRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    createOrUpdateFcmTokenRequest =
        (json['createOrUpdateFcmTokenRequest'] != null) ? CreateOrUpdateFcmTokenRequest.fromJson(json['createOrUpdateFcmTokenRequest']) : null;
    otpBean = (json['otpBean'] != null) ? DoLoginRequestOtpBean.fromJson(json['otpBean']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (createOrUpdateFcmTokenRequest != null) {
      data['createOrUpdateFcmTokenRequest'] = createOrUpdateFcmTokenRequest!.toJson();
    }
    if (otpBean != null) {
      data['otpBean'] = otpBean!.toJson();
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DoLoginResponse {
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

  DoLoginResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  DoLoginResponse.fromJson(Map<String, dynamic> json) {
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

Future<DoLoginResponse> doLogin(DoLoginRequest doLoginRequest) async {
  print("Raising request to doLogin with request ${jsonEncode(doLoginRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + DO_LOGIN;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(doLoginRequest.toJson()),
  );

  DoLoginResponse doLoginResponse = DoLoginResponse.fromJson(json.decode(response.body));
  print("DoLoginResponse ${doLoginResponse.toJson()}");
  return doLoginResponse;
}
