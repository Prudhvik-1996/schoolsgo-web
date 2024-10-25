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

  bool get hasAdminRole => roles?.contains("ADMIN") ?? false;
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

class CreateUserAndAssignRolesRequest {
  bool? isAdmin;
  int? agent;
  String? alternateMobile;
  String? firstName;
  String? lastName;
  String? mailId;
  String? middleName;
  String? mobile;
  int? schoolId;
  String? status;
  bool? isTeacher;
  bool? isNonTeachingStaff;
  bool? isBusDriver;
  bool? isReceptionist;
  int? userId;
  Map<String, dynamic> __origJson = {};

  CreateUserAndAssignRolesRequest({
    this.isAdmin,
    this.agent,
    this.alternateMobile,
    this.firstName,
    this.lastName,
    this.mailId,
    this.middleName,
    this.mobile,
    this.schoolId,
    this.status,
    this.isTeacher,
    this.isNonTeachingStaff,
    this.isBusDriver,
    this.isReceptionist,
    this.userId,
  });

  CreateUserAndAssignRolesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    isAdmin = json['isAdmin'];
    agent = json['agent']?.toInt();
    alternateMobile = json['alternateMobile']?.toString();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    mailId = json['mailId']?.toString();
    middleName = json['middleName']?.toString();
    mobile = json['mobile']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    isTeacher = json['isTeacher'];
    isNonTeachingStaff = json['isNonTeachingStaff'];
    isBusDriver = json['isBusDriver'];
    isReceptionist = json['isReceptionist'];
    userId = json['userId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['admin'] = isAdmin;
    data['agent'] = agent;
    data['alternateMobile'] = alternateMobile;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['mailId'] = mailId;
    data['middleName'] = middleName;
    data['mobile'] = mobile;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['teacher'] = isTeacher;
    data['nonTeachingStaff'] = isNonTeachingStaff;
    data['busDriver'] = isBusDriver;
    data['receptionist'] = isReceptionist;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateUserAndAssignRolesResponse {
  SchoolWiseEmployeeBean? employeeBean;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateUserAndAssignRolesResponse({
    this.employeeBean,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateUserAndAssignRolesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    employeeBean = (json['employeeBean'] != null) ? SchoolWiseEmployeeBean.fromJson(json['employeeBean']) : null;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (employeeBean != null) {
      data['employeeBean'] = employeeBean!.toJson();
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateUserAndAssignRolesResponse> createUserAndAssignRoles(CreateUserAndAssignRolesRequest createUserAndAssignRolesRequest) async {
  debugPrint("Raising request to createUserAndAssignRoles with request ${jsonEncode(createUserAndAssignRolesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_USER_AND_ASSIGN_ROLES;

  CreateUserAndAssignRolesResponse createUserAndAssignRolesResponse = await HttpUtils.post(
    _url,
    createUserAndAssignRolesRequest.toJson(),
    CreateUserAndAssignRolesResponse.fromJson,
  );

  debugPrint("CreateUserAndAssignRolesResponse ${createUserAndAssignRolesResponse.toJson()}");
  return createUserAndAssignRolesResponse;
}

class AssignUserWithRolesRequest {
  int? agent;
  List<String?>? roles;
  int? schoolId;
  int? userId;
  Map<String, dynamic> __origJson = {};

  AssignUserWithRolesRequest({
    this.agent,
    this.roles,
    this.schoolId,
    this.userId,
  });

  AssignUserWithRolesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['roles'] != null) {
      final v = json['roles'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      roles = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    userId = json['userId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (roles != null) {
      final v = roles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['roles'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class AssignUserWithRolesResponse {
  SchoolWiseEmployeeBean? employeeBean;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  AssignUserWithRolesResponse({
    this.employeeBean,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  AssignUserWithRolesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    employeeBean = (json['employeeBean'] != null) ? SchoolWiseEmployeeBean.fromJson(json['employeeBean']) : null;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (employeeBean != null) {
      data['employeeBean'] = employeeBean!.toJson();
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<AssignUserWithRolesResponse> assignUserWithRoles(AssignUserWithRolesRequest assignUserWithRolesRequest) async {
  debugPrint("Raising request to assignUserWithRoles with request ${jsonEncode(assignUserWithRolesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + ASSIGN_USER_WITH_ROLES;

  AssignUserWithRolesResponse assignUserWithRolesResponse = await HttpUtils.post(
    _url,
    assignUserWithRolesRequest.toJson(),
    AssignUserWithRolesResponse.fromJson,
  );

  debugPrint("AssignUserWithRolesResponse ${assignUserWithRolesResponse.toJson()}");
  return assignUserWithRolesResponse;
}
