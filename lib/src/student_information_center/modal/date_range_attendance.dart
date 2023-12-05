import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudentDateRangeAttendanceRequest {

  int? academicYearId;
  String? endDate;
  bool? isAdminView;
  int? schoolId;
  int? sectionId;
  String? startDate;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  GetStudentDateRangeAttendanceRequest({
    this.academicYearId,
    this.endDate,
    this.isAdminView,
    this.schoolId,
    this.sectionId,
    this.startDate,
    this.studentId,
  });
  GetStudentDateRangeAttendanceRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    endDate = json['endDate']?.toString();
    isAdminView = json['isAdminView'];
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    startDate = json['startDate']?.toString();
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['endDate'] = endDate;
    data['isAdminView'] = isAdminView;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['startDate'] = startDate;
    data['studentId'] = studentId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class StudentDateRangeAttendanceBean {

  double? absentDays;
  double? presentDays;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  StudentDateRangeAttendanceBean({
    this.absentDays,
    this.presentDays,
    this.studentId,
  });
  StudentDateRangeAttendanceBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    absentDays = json['absentDays']?.toDouble();
    presentDays = json['presentDays']?.toDouble();
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['absentDays'] = absentDays;
    data['presentDays'] = presentDays;
    data['studentId'] = studentId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;

  double get totalWorkingDays => (presentDays ?? 0) + (absentDays ?? 0);

  double get attendancePercentage => totalWorkingDays == 0 ? 0 : ((presentDays ?? 0) * 10000 / totalWorkingDays) / 100;
}

class GetStudentDateRangeAttendanceResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentDateRangeAttendanceBean?>? studentDateRangeAttendanceBeanList;
  Map<String, dynamic> __origJson = {};

  GetStudentDateRangeAttendanceResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentDateRangeAttendanceBeanList,
  });
  GetStudentDateRangeAttendanceResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentDateRangeAttendanceBeanList'] != null) {
      final v = json['studentDateRangeAttendanceBeanList'];
      final arr0 = <StudentDateRangeAttendanceBean>[];
      v.forEach((v) {
        arr0.add(StudentDateRangeAttendanceBean.fromJson(v));
      });
      studentDateRangeAttendanceBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentDateRangeAttendanceBeanList != null) {
      final v = studentDateRangeAttendanceBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentDateRangeAttendanceBeanList'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentDateRangeAttendanceResponse> getStudentDateRangeAttendance(
    GetStudentDateRangeAttendanceRequest getStudentDateRangeAttendanceRequest) async {
  debugPrint("Raising request to getStudentDateRangeAttendance with request ${jsonEncode(getStudentDateRangeAttendanceRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_DATE_RANGE_STUDENT_ATTENDANCE_BEANS;

  GetStudentDateRangeAttendanceResponse getStudentDateRangeAttendanceResponse = await HttpUtils.post(
    _url,
    getStudentDateRangeAttendanceRequest.toJson(),
    GetStudentDateRangeAttendanceResponse.fromJson,
  );

  debugPrint("GetStudentDateRangeAttendanceResponse ${getStudentDateRangeAttendanceResponse.toJson()}");
  return getStudentDateRangeAttendanceResponse;
}
