import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetEmployeeAttendanceRequest {
  int? attendanceId;
  String? date;
  int? employeeId;
  String? endDate;
  int? franchiseId;
  int? schoolId;
  String? startDate;
  Map<String, dynamic> __origJson = {};

  GetEmployeeAttendanceRequest({
    this.attendanceId,
    this.date,
    this.employeeId,
    this.endDate,
    this.franchiseId,
    this.schoolId,
    this.startDate,
  });

  GetEmployeeAttendanceRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    attendanceId = json['attendanceId']?.toInt();
    date = json['date']?.toString();
    employeeId = json['employeeId']?.toInt();
    endDate = json['endDate']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    startDate = json['startDate']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attendanceId'] = attendanceId;
    data['date'] = date;
    data['employeeId'] = employeeId;
    data['endDate'] = endDate;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['startDate'] = startDate;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DateWiseEmployeeAttendanceDetailsBean {
  int? agent;
  int? attendanceId;
  bool? clockedIn;
  int? clockedTime;
  String? comment;
  String? qr;
  int? employeeId;
  int? latitude;
  int? longitude;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  DateWiseEmployeeAttendanceDetailsBean({
    this.agent,
    this.attendanceId,
    this.clockedIn,
    this.clockedTime,
    this.comment,
    this.qr,
    this.employeeId,
    this.latitude,
    this.longitude,
    this.schoolId,
    this.status,
  });

  DateWiseEmployeeAttendanceDetailsBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    attendanceId = json['attendanceId']?.toInt();
    clockedIn = json['clockedIn'];
    clockedTime = json['clockedTime']?.toInt();
    comment = json['comment']?.toString();
    qr = json['qr']?.toString();
    employeeId = json['employeeId']?.toInt();
    latitude = json['latitude']?.toInt();
    longitude = json['longitude']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['attendanceId'] = attendanceId;
    data['clockedIn'] = clockedIn;
    data['clockedTime'] = clockedTime;
    data['comment'] = comment;
    data['qr'] = qr;
    data['employeeId'] = employeeId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DateWiseEmployeeAttendanceBean {
  String? date;
  List<DateWiseEmployeeAttendanceDetailsBean?>? dateWiseEmployeeAttendanceDetailsBeans;
  int? employeeId;
  String? isPresent;
  Map<String, dynamic> __origJson = {};

  DateWiseEmployeeAttendanceBean({
    this.date,
    this.dateWiseEmployeeAttendanceDetailsBeans,
    this.employeeId,
    this.isPresent,
  });

  DateWiseEmployeeAttendanceBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    if (json['dateWiseEmployeeAttendanceDetailsBeans'] != null) {
      final v = json['dateWiseEmployeeAttendanceDetailsBeans'];
      final arr0 = <DateWiseEmployeeAttendanceDetailsBean>[];
      v.forEach((v) {
        arr0.add(DateWiseEmployeeAttendanceDetailsBean.fromJson(v));
      });
      dateWiseEmployeeAttendanceDetailsBeans = arr0;
    }
    employeeId = json['employeeId']?.toInt();
    isPresent = json['isPresent']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    if (dateWiseEmployeeAttendanceDetailsBeans != null) {
      final v = dateWiseEmployeeAttendanceDetailsBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['dateWiseEmployeeAttendanceDetailsBeans'] = arr0;
    }
    data['employeeId'] = employeeId;
    data['isPresent'] = isPresent;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class EmployeeAttendanceBean {
  String? alternateMobile;
  List<DateWiseEmployeeAttendanceBean?>? dateWiseEmployeeAttendanceBeanList;
  String? emailId;
  int? employeeId;
  String? employeeName;
  int? franchiseId;
  String? franchiseName;
  String? loginId;
  String? mobile;
  String? photoUrl;
  List<String?>? roles;
  String? schoolDisplayName;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  EmployeeAttendanceBean({
    this.alternateMobile,
    this.dateWiseEmployeeAttendanceBeanList,
    this.emailId,
    this.employeeId,
    this.employeeName,
    this.franchiseId,
    this.franchiseName,
    this.loginId,
    this.mobile,
    this.photoUrl,
    this.roles,
    this.schoolDisplayName,
    this.schoolId,
  });

  EmployeeAttendanceBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    alternateMobile = json['alternateMobile']?.toString();
    if (json['dateWiseEmployeeAttendanceBeanList'] != null) {
      final v = json['dateWiseEmployeeAttendanceBeanList'];
      final arr0 = <DateWiseEmployeeAttendanceBean>[];
      v.forEach((v) {
        arr0.add(DateWiseEmployeeAttendanceBean.fromJson(v));
      });
      dateWiseEmployeeAttendanceBeanList = arr0;
    }
    emailId = json['emailId']?.toString();
    employeeId = json['employeeId']?.toInt();
    employeeName = json['employeeName']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    loginId = json['loginId']?.toString();
    mobile = json['mobile']?.toString();
    photoUrl = json['photoUrl']?.toString();
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
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['alternateMobile'] = alternateMobile;
    if (dateWiseEmployeeAttendanceBeanList != null) {
      final v = dateWiseEmployeeAttendanceBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['dateWiseEmployeeAttendanceBeanList'] = arr0;
    }
    data['emailId'] = emailId;
    data['employeeId'] = employeeId;
    data['employeeName'] = employeeName;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['loginId'] = loginId;
    data['mobile'] = mobile;
    data['photoUrl'] = photoUrl;
    if (roles != null) {
      final v = roles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['roles'] = arr0;
    }
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetEmployeeAttendanceResponse {
  List<EmployeeAttendanceBean?>? employeeAttendanceBeanList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetEmployeeAttendanceResponse({
    this.employeeAttendanceBeanList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetEmployeeAttendanceResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['employeeAttendanceBeanList'] != null) {
      final v = json['employeeAttendanceBeanList'];
      final arr0 = <EmployeeAttendanceBean>[];
      v.forEach((v) {
        arr0.add(EmployeeAttendanceBean.fromJson(v));
      });
      employeeAttendanceBeanList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (employeeAttendanceBeanList != null) {
      final v = employeeAttendanceBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['employeeAttendanceBeanList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetEmployeeAttendanceResponse> getEmployeeAttendance(GetEmployeeAttendanceRequest getEmployeeAttendanceRequest) async {
  debugPrint("Raising request to getEmployeeAttendance with request ${jsonEncode(getEmployeeAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EMPLOYEE_ATTENDANCE;

  GetEmployeeAttendanceResponse getEmployeeAttendanceResponse = await HttpUtils.post(
    _url,
    getEmployeeAttendanceRequest.toJson(),
    GetEmployeeAttendanceResponse.fromJson,
  );

  debugPrint("GetEmployeeAttendanceResponse ${getEmployeeAttendanceResponse.toJson()}");
  return getEmployeeAttendanceResponse;
}

class CreateOrUpdateEmployeeAttendanceClockRequest {
  int? agent;
  int? attendanceId;
  bool? clockedIn;
  int? clockedTime;
  String? comment;
  int? employeeId;
  int? latitude;
  int? longitude;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateEmployeeAttendanceClockRequest({
    this.agent,
    this.attendanceId,
    this.clockedIn,
    this.clockedTime,
    this.comment,
    this.employeeId,
    this.latitude,
    this.longitude,
    this.schoolId,
    this.status,
  });

  CreateOrUpdateEmployeeAttendanceClockRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    attendanceId = json['attendanceId']?.toInt();
    clockedIn = json['clockedIn'];
    clockedTime = json['clockedTime']?.toInt();
    comment = json['comment']?.toString();
    employeeId = json['employeeId']?.toInt();
    latitude = json['latitude']?.toInt();
    longitude = json['longitude']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['attendanceId'] = attendanceId;
    data['clockedIn'] = clockedIn;
    data['clockedTime'] = clockedTime;
    data['comment'] = comment;
    data['employeeId'] = employeeId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateEmployeeAttendanceClockResponse {
  int? attendanceId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateEmployeeAttendanceClockResponse({
    this.attendanceId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateEmployeeAttendanceClockResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    attendanceId = json['attendanceId']?.toInt();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attendanceId'] = attendanceId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateEmployeeAttendanceClockResponse> createOrUpdateEmployeeAttendanceClock(
    CreateOrUpdateEmployeeAttendanceClockRequest createOrUpdateEmployeeAttendanceRequest) async {
  debugPrint("Raising request to createOrUpdateEmployeeAttendanceClock with request ${jsonEncode(createOrUpdateEmployeeAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_EMPLOYEE_ATTENDANCE_CLOCK;

  CreateOrUpdateEmployeeAttendanceClockResponse createOrUpdateEmployeeAttendanceClockResponse = await HttpUtils.post(
    _url,
    createOrUpdateEmployeeAttendanceRequest.toJson(),
    CreateOrUpdateEmployeeAttendanceClockResponse.fromJson,
  );

  debugPrint("createOrUpdateEmployeeAttendanceClockResponse ${createOrUpdateEmployeeAttendanceClockResponse.toJson()}");
  return createOrUpdateEmployeeAttendanceClockResponse;
}

class CreateOrUpdateEmployeesAttendanceRequest {

  int? agentId;
  List<DateWiseEmployeeAttendanceBean?>? dateWiseEmployeeAttendanceBeans;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateEmployeesAttendanceRequest({
    this.agentId,
    this.dateWiseEmployeeAttendanceBeans,
    this.schoolId,
  });
  CreateOrUpdateEmployeesAttendanceRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    if (json['dateWiseEmployeeAttendanceBeans'] != null) {
      final v = json['dateWiseEmployeeAttendanceBeans'];
      final arr0 = <DateWiseEmployeeAttendanceBean>[];
      v.forEach((v) {
        arr0.add(DateWiseEmployeeAttendanceBean.fromJson(v));
      });
      dateWiseEmployeeAttendanceBeans = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    if (dateWiseEmployeeAttendanceBeans != null) {
      final v = dateWiseEmployeeAttendanceBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['dateWiseEmployeeAttendanceBeans'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateEmployeesAttendanceResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateEmployeesAttendanceResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateEmployeesAttendanceResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateEmployeesAttendanceResponse> createOrUpdateEmployeesAttendance(
    CreateOrUpdateEmployeesAttendanceRequest createOrUpdateEmployeeAttendanceRequest) async {
  debugPrint("Raising request to createOrUpdateEmployeesAttendance with request ${jsonEncode(createOrUpdateEmployeeAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_EMPLOYEES_ATTENDANCE;

  CreateOrUpdateEmployeesAttendanceResponse createOrUpdateEmployeesAttendanceResponse = await HttpUtils.post(
    _url,
    createOrUpdateEmployeeAttendanceRequest.toJson(),
    CreateOrUpdateEmployeesAttendanceResponse.fromJson,
  );

  debugPrint("createOrUpdateEmployeesAttendanceResponse ${createOrUpdateEmployeesAttendanceResponse.toJson()}");
  return createOrUpdateEmployeesAttendanceResponse;
}
