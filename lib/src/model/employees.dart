import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSchoolWiseEmployeesRequest {
/*
{
  "employeeId": 0,
  "schoolId": 0
}
*/

  int? employeeId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseEmployeesRequest({
    this.employeeId,
    this.schoolId,
  });
  GetSchoolWiseEmployeesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    employeeId = json['employeeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SchoolWiseEmployeeBean {
/*
{
  "employeeId": 0,
  "employeeName": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "roles": [
    "string"
  ],
  "schoolDisplayName": "string",
  "schoolId": 0
}
*/

  int? employeeId;
  String? employeeName;
  int? franchiseId;
  String? franchiseName;
  List<String?>? roles;
  String? schoolDisplayName;
  int? schoolId;
  String? photoUrl;
  String? loginId;
  String? emailId;
  String? mobile;
  String? alternateMobile;

  Map<String, dynamic> __origJson = {};

  SchoolWiseEmployeeBean({
    this.employeeId,
    this.employeeName,
    this.franchiseId,
    this.franchiseName,
    this.roles,
    this.schoolDisplayName,
    this.schoolId,
    this.photoUrl,
    this.loginId,
    this.emailId,
    this.mobile,
    this.alternateMobile,
  });
  SchoolWiseEmployeeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    employeeId = json['employeeId']?.toInt();
    employeeName = json['employeeName']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    if (json['roles'] != null) {
      final v = json['roles'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      roles = arr0;
    }
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    photoUrl = json['photoUrl']?.toString();
    loginId = json['loginId']?.toString();
    emailId = json['emailId']?.toString();
    mobile = json['mobile']?.toString();
    alternateMobile = json['alternateMobile']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    data['employeeName'] = employeeName;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    if (roles != null) {
      final v = roles;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['roles'] = arr0;
    }
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['photoUrl'] = photoUrl;
    data['loginId'] = loginId;
    data['emailId'] = emailId;
    data['mobile'] = mobile;
    data['alternateMobile'] = alternateMobile;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetSchoolWiseEmployeesResponse {
/*
{
  "employees": [
    {
      "employeeId": 0,
      "employeeName": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "roles": [
        "string"
      ],
      "schoolDisplayName": "string",
      "schoolId": 0
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<SchoolWiseEmployeeBean?>? employees;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseEmployeesResponse({
    this.employees,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetSchoolWiseEmployeesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['employees'] != null) {
      final v = json['employees'];
      final arr0 = <SchoolWiseEmployeeBean>[];
      v.forEach((v) {
        arr0.add(SchoolWiseEmployeeBean.fromJson(v));
      });
      employees = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (employees != null) {
      final v = employees;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['employees'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSchoolWiseEmployeesResponse> getSchoolWiseEmployees(GetSchoolWiseEmployeesRequest getSchoolWiseEmployeesRequest) async {
  debugPrint("Raising request to getSchoolWiseEmployees with request ${jsonEncode(getSchoolWiseEmployeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOL_WISE_EMPLOYEES;

  GetSchoolWiseEmployeesResponse getSchoolWiseEmployeesResponse = await HttpUtils.post(
    _url,
    getSchoolWiseEmployeesRequest.toJson(),
    GetSchoolWiseEmployeesResponse.fromJson,
  );

  debugPrint("GetSchoolWiseEmployeesResponse ${getSchoolWiseEmployeesResponse.toJson()}");
  return getSchoolWiseEmployeesResponse;
}
