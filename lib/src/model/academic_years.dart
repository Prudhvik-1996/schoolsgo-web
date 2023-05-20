import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSchoolWiseAcademicYearsRequest {
/*
{
  "academicYearId": 0,
  "schoolId": 0
}
*/

  int? academicYearId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseAcademicYearsRequest({
    this.academicYearId,
    this.schoolId,
  });

  GetSchoolWiseAcademicYearsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class AcademicYearBean {
/*
{
  "academicYearEndDate": "string",
  "academicYearId": 0,
  "academicYearStartDate": "string",
  "schoolId": 0,
  "status": "active"
}
*/

  String? academicYearEndDate;
  int? academicYearId;
  String? academicYearStartDate;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  AcademicYearBean({
    this.academicYearEndDate,
    this.academicYearId,
    this.academicYearStartDate,
    this.schoolId,
    this.status,
  });

  AcademicYearBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearEndDate = json['academicYearEndDate']?.toString();
    academicYearId = json['academicYearId']?.toInt();
    academicYearStartDate = json['academicYearStartDate']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearEndDate'] = academicYearEndDate;
    data['academicYearId'] = academicYearId;
    data['academicYearStartDate'] = academicYearStartDate;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  String formattedString() {
    return "${(convertYYYYMMDDFormatToDateTime(academicYearStartDate).year)} - ${(convertYYYYMMDDFormatToDateTime(academicYearEndDate).year)}";
  }
}

class GetSchoolWiseAcademicYearsResponse {
/*
{
  "academicYearBeanList": [
    {
      "academicYearEndDate": "string",
      "academicYearId": 0,
      "academicYearStartDate": "string",
      "schoolId": 0,
      "status": "active"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<AcademicYearBean?>? academicYearBeanList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetSchoolWiseAcademicYearsResponse({
    this.academicYearBeanList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  GetSchoolWiseAcademicYearsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['academicYearBeanList'] != null) {
      final v = json['academicYearBeanList'];
      final arr0 = <AcademicYearBean>[];
      v.forEach((v) {
        arr0.add(AcademicYearBean.fromJson(v));
      });
      academicYearBeanList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (academicYearBeanList != null) {
      final v = academicYearBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['academicYearBeanList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSchoolWiseAcademicYearsResponse> getSchoolWiseAcademicYears(GetSchoolWiseAcademicYearsRequest getSchoolWiseAcademicYearsRequest) async {
  debugPrint("Raising request to getSchoolWiseAcademicYears with request ${jsonEncode(getSchoolWiseAcademicYearsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOL_WISE_ACADEMIC_YEARS;

  GetSchoolWiseAcademicYearsResponse getSchoolWiseAcademicYearsResponse = await HttpUtils.post(
    _url,
    getSchoolWiseAcademicYearsRequest.toJson(),
    GetSchoolWiseAcademicYearsResponse.fromJson,
  );

  debugPrint("GetSchoolWiseAcademicYearsResponse ${getSchoolWiseAcademicYearsResponse.toJson()}");
  return getSchoolWiseAcademicYearsResponse;
}
