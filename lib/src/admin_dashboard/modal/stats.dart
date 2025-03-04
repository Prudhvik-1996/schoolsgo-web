import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSchoolWiseStatsRequest {
/*
{
  "date": "string",
  "schoolId": 0
}
*/

  String? date;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseStatsRequest({
    this.date,
    this.schoolId,
  });

  GetSchoolWiseStatsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetSchoolWiseStatsResponse {
/*
{
  "date": "string",
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "totalAcademicFee": 0,
  "totalAcademicFeeCollected": 0,
  "totalBusFee": 0,
  "totalBusFeeCollected": 0,
  "totalFeeCollectedForTheDay": 0,
  "totalNoOfStudents": 0,
  "totalNoOfStudentsMarkedForAttendance": 0,
  "totalNoOfStudentsPresent": 0
}
*/

  String? date;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? totalAcademicFee;
  int? totalAcademicFeeCollected;
  int? totalBusFee;
  int? totalBusFeeCollected;
  int? totalFeeCollectedForTheDay;
  int? totalNoOfStudents;
  int? totalNoOfStudentsMarkedForAttendance;
  int? totalNoOfStudentsPresent;
  int? totalNoOfEmployees;
  int? totalNoOfEmployeesPresent;
  int? totalNoOfEmployeesMarkedForAttendance;
  int? totalExpensesForTheDay;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseStatsResponse({
    this.date,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.totalAcademicFee,
    this.totalAcademicFeeCollected,
    this.totalBusFee,
    this.totalBusFeeCollected,
    this.totalFeeCollectedForTheDay,
    this.totalNoOfStudents,
    this.totalNoOfStudentsMarkedForAttendance,
    this.totalNoOfStudentsPresent,
    this.totalNoOfEmployees,
    this.totalNoOfEmployeesPresent,
    this.totalNoOfEmployeesMarkedForAttendance,
    this.totalExpensesForTheDay,
  });

  GetSchoolWiseStatsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    date = json['date']?.toString();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    totalAcademicFee = json['totalAcademicFee']?.toInt();
    totalAcademicFeeCollected = json['totalAcademicFeeCollected']?.toInt();
    totalBusFee = json['totalBusFee']?.toInt();
    totalBusFeeCollected = json['totalBusFeeCollected']?.toInt();
    totalFeeCollectedForTheDay = json['totalFeeCollectedForTheDay']?.toInt();
    totalNoOfStudents = json['totalNoOfStudents']?.toInt();
    totalNoOfStudentsMarkedForAttendance = json['totalNoOfStudentsMarkedForAttendance']?.toInt();
    totalNoOfStudentsPresent = json['totalNoOfStudentsPresent']?.toInt();
    totalNoOfEmployees = json['totalNoOfEmployees']?.toInt();
    totalNoOfEmployeesPresent = json['totalNoOfEmployeesPresent']?.toInt();
    totalNoOfEmployeesMarkedForAttendance = json['totalNoOfEmployeesMarkedForAttendance']?.toInt();
    totalExpensesForTheDay = json['totalExpensesForTheDay']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['totalAcademicFee'] = totalAcademicFee;
    data['totalAcademicFeeCollected'] = totalAcademicFeeCollected;
    data['totalBusFee'] = totalBusFee;
    data['totalBusFeeCollected'] = totalBusFeeCollected;
    data['totalFeeCollectedForTheDay'] = totalFeeCollectedForTheDay;
    data['totalNoOfStudents'] = totalNoOfStudents;
    data['totalNoOfStudentsMarkedForAttendance'] = totalNoOfStudentsMarkedForAttendance;
    data['totalNoOfStudentsPresent'] = totalNoOfStudentsPresent;
    data['totalNoOfEmployees'] = totalNoOfEmployees;
    data['totalNoOfEmployeesPresent'] = totalNoOfEmployeesPresent;
    data['totalNoOfEmployeesMarkedForAttendance'] = totalNoOfEmployeesMarkedForAttendance;
    data['totalExpensesForTheDay'] = totalExpensesForTheDay;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSchoolWiseStatsResponse> getSchoolWiseStats(GetSchoolWiseStatsRequest getSchoolWiseStatsRequest) async {
  debugPrint("Raising request to getSchoolWiseStats with request ${jsonEncode(getSchoolWiseStatsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOL_WISE_STATS;

  GetSchoolWiseStatsResponse getSchoolWiseStatsResponse = await HttpUtils.post(
    _url,
    getSchoolWiseStatsRequest.toJson(),
    GetSchoolWiseStatsResponse.fromJson,
  );

  debugPrint("GetSchoolWiseStatsResponse ${getSchoolWiseStatsResponse.toJson()}");
  return getSchoolWiseStatsResponse;
}
