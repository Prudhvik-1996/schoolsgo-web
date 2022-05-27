import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetMonthsAndYearsForSchoolsRequest {
/*
{
  "schoolId": 91
}
*/

  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetMonthsAndYearsForSchoolsRequest({
    this.schoolId,
  });
  GetMonthsAndYearsForSchoolsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class MonthAndYearForSchoolBean {
/*
{
  "agent": 0,
  "createTime": 0,
  "month": "JANUARY",
  "monthAndYearForSchoolId": 0,
  "noOfWorkingDays": 0,
  "schoolId": 0,
  "status": "active",
  "year": 0
}
*/

  int? agent;
  int? createTime;
  String? month;
  int? monthAndYearForSchoolId;
  int? noOfWorkingDays;
  int? schoolId;
  String? status;
  int? year;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  MonthAndYearForSchoolBean({
    this.agent,
    this.createTime,
    this.month,
    this.monthAndYearForSchoolId,
    this.noOfWorkingDays,
    this.schoolId,
    this.status,
    this.year,
  });
  MonthAndYearForSchoolBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    createTime = json['createTime']?.toInt();
    month = json['month']?.toString();
    monthAndYearForSchoolId = json['monthAndYearForSchoolId']?.toInt();
    noOfWorkingDays = json['noOfWorkingDays']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    year = json['year']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['createTime'] = createTime;
    data['month'] = month;
    data['monthAndYearForSchoolId'] = monthAndYearForSchoolId;
    data['noOfWorkingDays'] = noOfWorkingDays;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['year'] = year;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetMonthsAndYearsForSchoolsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "monthAndYearForSchoolBeans": [
    {
      "agent": 0,
      "createTime": 0,
      "month": "JANUARY",
      "monthAndYearForSchoolId": 0,
      "noOfWorkingDays": 0,
      "schoolId": 0,
      "status": "active",
      "year": 0
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<MonthAndYearForSchoolBean?>? monthAndYearForSchoolBeans;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetMonthsAndYearsForSchoolsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.monthAndYearForSchoolBeans,
    this.responseStatus,
  });
  GetMonthsAndYearsForSchoolsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['monthAndYearForSchoolBeans'] != null) {
      final v = json['monthAndYearForSchoolBeans'];
      final arr0 = <MonthAndYearForSchoolBean>[];
      v.forEach((v) {
        arr0.add(MonthAndYearForSchoolBean.fromJson(v));
      });
      monthAndYearForSchoolBeans = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (monthAndYearForSchoolBeans != null) {
      final v = monthAndYearForSchoolBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['monthAndYearForSchoolBeans'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetMonthsAndYearsForSchoolsResponse> getMonthsAndYearsForSchools(GetMonthsAndYearsForSchoolsRequest getMonthsAndYearsForSchoolsRequest) async {
  print("Raising request to getMonthsAndYearsForSchools with request ${jsonEncode(getMonthsAndYearsForSchoolsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_MONTHS_AND_YEARS_FOR_SCHOOL;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getMonthsAndYearsForSchoolsRequest.toJson()),
  );

  GetMonthsAndYearsForSchoolsResponse getMonthsAndYearsForSchoolsResponse = GetMonthsAndYearsForSchoolsResponse.fromJson(json.decode(response.body));
  print("GetMonthsAndYearsForSchoolsResponse ${getMonthsAndYearsForSchoolsResponse.toJson()}");
  return getMonthsAndYearsForSchoolsResponse;
}

class CreateMonthsAndYearsForSchoolsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "monthAndYearForSchoolId": 0,
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  int? monthAndYearForSchoolId;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateMonthsAndYearsForSchoolsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.monthAndYearForSchoolId,
    this.responseStatus,
  });
  CreateMonthsAndYearsForSchoolsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    monthAndYearForSchoolId = json['monthAndYearForSchoolId']?.toInt();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['monthAndYearForSchoolId'] = monthAndYearForSchoolId;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateMonthsAndYearsForSchoolsResponse> createOrUpdateMonthAndYearForSchool(
    MonthAndYearForSchoolBean createOrUpdateMonthAndYearForSchoolRequest) async {
  print(
      "Raising request to createOrUpdateMonthAndYearForSchoolRequest with request ${jsonEncode(createOrUpdateMonthAndYearForSchoolRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_MONTHS_AND_YEARS_FOR_SCHOOL;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateMonthAndYearForSchoolRequest.toJson()),
  );

  CreateMonthsAndYearsForSchoolsResponse createMonthsAndYearsForSchoolsResponse =
      CreateMonthsAndYearsForSchoolsResponse.fromJson(json.decode(response.body));
  print("CreateMonthsAndYearsForSchoolsResponse ${createMonthsAndYearsForSchoolsResponse.toJson()}");
  return createMonthsAndYearsForSchoolsResponse;
}
