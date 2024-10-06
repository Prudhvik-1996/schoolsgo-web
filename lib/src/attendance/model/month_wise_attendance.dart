import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class GetStudentMonthWiseAttendanceRequest {
/*
{
  "isAdminView": "string",
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0
}
*/

  String? isAdminView;
  int? academicYearId;
  int? schoolId;
  int? sectionId;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  GetStudentMonthWiseAttendanceRequest({
    this.isAdminView,
    this.academicYearId,
    this.schoolId,
    this.sectionId,
    this.studentId,
  });

  GetStudentMonthWiseAttendanceRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    isAdminView = json['isAdminView']?.toString();
    academicYearId = json['academicYearId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isAdminView'] = isAdminView;
    data['academicYearId'] = academicYearId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentMonthWiseAttendance {
/*
{
  "absent": 0,
  "month": 0,
  "present": 0,
  "studentId": 0,
  "year": 0
}
*/

  double? absent;
  int? month;
  double? present;
  int? studentId;
  int? year;
  Map<String, dynamic> __origJson = {};

  StudentMonthWiseAttendance({
    this.absent,
    this.month,
    this.present,
    this.studentId,
    this.year,
  });

  StudentMonthWiseAttendance.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    absent = json['absent']?.toDouble();
    month = json['month']?.toInt();
    present = json['present']?.toDouble();
    studentId = json['studentId']?.toInt();
    year = json['year']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['absent'] = absent;
    data['month'] = month;
    data['present'] = present;
    data['studentId'] = studentId;
    data['year'] = year;
    return data;
  }

  String get mmmYYYYString => "${MONTHS[(month ?? 1) - 1].substring(0,3)}-$year";

  double get totalWorkingDays => (present ?? 0) + (absent ?? 0);

  String? get percentage => totalWorkingDays == 0 ? null : doubleToStringAsFixed((present ?? 0) * 100 / totalWorkingDays) + "%";

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentMonthWiseAttendanceResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentMonthWiseAttendanceList": [
    {
      "absent": 0,
      "month": 0,
      "present": 0,
      "studentId": 0,
      "year": 0
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentMonthWiseAttendance?>? studentMonthWiseAttendanceList;
  Map<String, dynamic> __origJson = {};

  GetStudentMonthWiseAttendanceResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentMonthWiseAttendanceList,
  });

  GetStudentMonthWiseAttendanceResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentMonthWiseAttendanceList'] != null) {
      final v = json['studentMonthWiseAttendanceList'];
      final arr0 = <StudentMonthWiseAttendance>[];
      v.forEach((v) {
        arr0.add(StudentMonthWiseAttendance.fromJson(v));
      });
      studentMonthWiseAttendanceList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentMonthWiseAttendanceList != null) {
      final v = studentMonthWiseAttendanceList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentMonthWiseAttendanceList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentMonthWiseAttendanceResponse> getStudentMonthWiseAttendance(
    GetStudentMonthWiseAttendanceRequest getStudentMonthWiseAttendanceRequest) async {
  debugPrint("Raising request to getStudentMonthWiseAttendance with request ${jsonEncode(getStudentMonthWiseAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_MONTH_WISE_STUDENT_ATTENDANCE_BEANS;

  GetStudentMonthWiseAttendanceResponse getStudentMonthWiseAttendanceResponse = await HttpUtils.post(
    _url,
    getStudentMonthWiseAttendanceRequest.toJson(),
    GetStudentMonthWiseAttendanceResponse.fromJson,
  );

  debugPrint("GetStudentMonthWiseAttendanceResponse ${getStudentMonthWiseAttendanceResponse.toJson()}");
  return getStudentMonthWiseAttendanceResponse;
}
class CreateOrUpdateStudentMonthWiseAttendanceRequest {
/*
{
  "agent": 0,
  "schoolId": 0,
  "studentMonthWiseAttendanceBeans": [
    {
      "absent": 0,
      "month": 0,
      "present": 0,
      "studentId": 0,
      "year": 0
    }
  ]
}
*/

  int? agent;
  int? schoolId;
  List<StudentMonthWiseAttendance?>? studentMonthWiseAttendanceBeans;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentMonthWiseAttendanceRequest({
    this.agent,
    this.schoolId,
    this.studentMonthWiseAttendanceBeans,
  });
  CreateOrUpdateStudentMonthWiseAttendanceRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['studentMonthWiseAttendanceBeans'] != null) {
      final v = json['studentMonthWiseAttendanceBeans'];
      final arr0 = <StudentMonthWiseAttendance>[];
      v.forEach((v) {
        arr0.add(StudentMonthWiseAttendance.fromJson(v));
      });
      studentMonthWiseAttendanceBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    if (studentMonthWiseAttendanceBeans != null) {
      final v = studentMonthWiseAttendanceBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentMonthWiseAttendanceBeans'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentMonthWiseAttendanceResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentMonthWiseAttendanceResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateStudentMonthWiseAttendanceResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateStudentMonthWiseAttendanceResponse> createOrUpdateStudentMonthWiseAttendance(CreateOrUpdateStudentMonthWiseAttendanceRequest createOrUpdateStudentMonthWiseAttendanceRequest) async {
  debugPrint("Raising request to createOrUpdateStudentMonthWiseAttendance with request ${jsonEncode(createOrUpdateStudentMonthWiseAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_MONTH_WISE_STUDENT_ATTENDANCE_BEANS;

  CreateOrUpdateStudentMonthWiseAttendanceResponse createOrUpdateStudentMonthWiseAttendanceResponse = await HttpUtils.post(
    _url,
    createOrUpdateStudentMonthWiseAttendanceRequest.toJson(),
    CreateOrUpdateStudentMonthWiseAttendanceResponse.fromJson,
  );

  debugPrint("CreateOrUpdateStudentMonthWiseAttendanceResponse ${createOrUpdateStudentMonthWiseAttendanceResponse.toJson()}");
  return createOrUpdateStudentMonthWiseAttendanceResponse;
}