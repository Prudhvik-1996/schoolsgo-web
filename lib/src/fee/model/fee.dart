import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class GetFeeTypesRequest {
/*
{
  "customFeeTypeId": 0,
  "feeTypeId": 0,
  "schoolId": 0
}
*/

  int? customFeeTypeId;
  int? feeTypeId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetFeeTypesRequest({
    this.customFeeTypeId,
    this.feeTypeId,
    this.schoolId,
  });

  GetFeeTypesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CustomFeeType {
/*
{
  "customFeeType": "string",
  "customFeeTypeDescription": "string",
  "customFeeTypeId": 0,
  "customFeeTypeStatus": "active",
  "feeType": "string",
  "feeTypeDescription": "string",
  "feeTypeId": 0,
  "feeTypeStatus": "active",
  "schoolDisplayName": "string",
  "schoolId": 0
}
*/

  String? customFeeType;
  String? customFeeTypeDescription;
  int? customFeeTypeId;
  String? customFeeTypeStatus;
  String? feeType;
  String? feeTypeDescription;
  int? feeTypeId;
  String? feeTypeStatus;
  String? schoolDisplayName;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  TextEditingController customFeeTypeController = TextEditingController();

  CustomFeeType({
    this.customFeeType,
    this.customFeeTypeDescription,
    this.customFeeTypeId,
    this.customFeeTypeStatus,
    this.feeType,
    this.feeTypeDescription,
    this.feeTypeId,
    this.feeTypeStatus,
    this.schoolDisplayName,
    this.schoolId,
  }) {
    customFeeTypeController.text = customFeeType ?? "";
  }

  CustomFeeType.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeController.text = customFeeType ?? "";
    customFeeTypeDescription = json['customFeeTypeDescription']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    customFeeTypeStatus = json['customFeeTypeStatus']?.toString();
    feeType = json['feeType']?.toString();
    feeTypeDescription = json['feeTypeDescription']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    feeTypeStatus = json['feeTypeStatus']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeType'] = customFeeType;
    data['customFeeTypeDescription'] = customFeeTypeDescription;
    data['customFeeTypeId'] = customFeeTypeId;
    data['customFeeTypeStatus'] = customFeeTypeStatus;
    data['feeType'] = feeType;
    data['feeTypeDescription'] = feeTypeDescription;
    data['feeTypeId'] = feeTypeId;
    data['feeTypeStatus'] = feeTypeStatus;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "{\n\t'customFeeType': $customFeeType, \n\t'customFeeTypeDescription': $customFeeTypeDescription, \n\t'customFeeTypeId': $customFeeTypeId, \n\t'customFeeTypeStatus': $customFeeTypeStatus, \n\t'feeType': $feeType, \n\t'feeTypeDescription': $feeTypeDescription, \n\t'feeTypeId': $feeTypeId, \n\t'feeTypeStatus': $feeTypeStatus, \n\t'schoolDisplayName': $schoolDisplayName, \n\t'schoolId': $schoolId, \n}";
  }
}

class FeeType {
/*
{
  "customFeeTypesList": [
    {
      "customFeeType": "string",
      "customFeeTypeDescription": "string",
      "customFeeTypeId": 0,
      "customFeeTypeStatus": "active",
      "feeType": "string",
      "feeTypeDescription": "string",
      "feeTypeId": 0,
      "feeTypeStatus": "active",
      "schoolDisplayName": "string",
      "schoolId": 0
    }
  ],
  "feeType": "string",
  "feeTypeDescription": "string",
  "feeTypeId": 0,
  "feeTypeStatus": "active",
  "schoolDisplayName": "string",
  "schoolId": 0
}
*/

  List<CustomFeeType?>? customFeeTypesList;
  String? feeType;
  String? feeTypeDescription;
  int? feeTypeId;
  String? feeTypeStatus;
  String? schoolDisplayName;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;
  TextEditingController feeTypeController = TextEditingController();

  FeeType({
    this.customFeeTypesList,
    this.feeType,
    this.feeTypeDescription,
    this.feeTypeId,
    this.feeTypeStatus,
    this.schoolDisplayName,
    this.schoolId,
  }) {
    feeTypeController.text = feeType ?? "";
  }

  FeeType.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['customFeeTypesList'] != null) {
      final v = json['customFeeTypesList'];
      final arr0 = <CustomFeeType>[];
      v.forEach((v) {
        arr0.add(CustomFeeType.fromJson(v));
      });
      customFeeTypesList = arr0;
    }
    feeType = json['feeType']?.toString();
    feeTypeController.text = feeType ?? "";
    feeTypeDescription = json['feeTypeDescription']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    feeTypeStatus = json['feeTypeStatus']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (customFeeTypesList != null) {
      final v = customFeeTypesList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['customFeeTypesList'] = arr0;
    }
    data['feeType'] = feeType;
    data['feeTypeDescription'] = feeTypeDescription;
    data['feeTypeId'] = feeTypeId;
    data['feeTypeStatus'] = feeTypeStatus;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "{\n\t'customFeeTypesList': $customFeeTypesList, \n\t'feeType': $feeType, \n\t'feeTypeDescription': $feeTypeDescription, \n\t'feeTypeId': $feeTypeId, \n\t'feeTypeStatus': $feeTypeStatus, \n\t'schoolDisplayName': $schoolDisplayName, \n\t'schoolId': $schoolId, \n}";
  }
}

class GetFeeTypesResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "feeTypesList": [
    {
      "customFeeTypesList": [
        {
          "customFeeType": "string",
          "customFeeTypeDescription": "string",
          "customFeeTypeId": 0,
          "customFeeTypeStatus": "active",
          "feeType": "string",
          "feeTypeDescription": "string",
          "feeTypeId": 0,
          "feeTypeStatus": "active",
          "schoolDisplayName": "string",
          "schoolId": 0
        }
      ],
      "feeType": "string",
      "feeTypeDescription": "string",
      "feeTypeId": 0,
      "feeTypeStatus": "active",
      "schoolDisplayName": "string",
      "schoolId": 0
    }
  ],
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  List<FeeType?>? feeTypesList;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetFeeTypesResponse({
    this.errorCode,
    this.errorMessage,
    this.feeTypesList,
    this.httpStatus,
    this.responseStatus,
  });

  GetFeeTypesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    if (json['feeTypesList'] != null) {
      final v = json['feeTypesList'];
      final arr0 = <FeeType>[];
      v.forEach((v) {
        arr0.add(FeeType.fromJson(v));
      });
      feeTypesList = arr0;
    }
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    if (feeTypesList != null) {
      final v = feeTypesList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['feeTypesList'] = arr0;
    }
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetFeeTypesResponse> getFeeTypes(GetFeeTypesRequest getFeeTypesRequest) async {
  print("Raising request to getFeeTypes with request ${jsonEncode(getFeeTypesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_FEE_TYPES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getFeeTypesRequest.toJson()),
  );

  GetFeeTypesResponse getFeeTypesResponse = GetFeeTypesResponse.fromJson(json.decode(response.body));
  print("GetFeeTypesResponse ${getFeeTypesResponse.toJson()}");
  return getFeeTypesResponse;
}

class CreateOrUpdateFeeTypesRequest {
/*
{
  "agent": 0,
  "feeTypesList": [
    {
      "customFeeTypesList": [
        {
          "customFeeType": "string",
          "customFeeTypeDescription": "string",
          "customFeeTypeId": 0,
          "customFeeTypeStatus": "active",
          "feeType": "string",
          "feeTypeDescription": "string",
          "feeTypeId": 0,
          "feeTypeStatus": "active",
          "schoolDisplayName": "string",
          "schoolId": 0
        }
      ],
      "feeType": "string",
      "feeTypeDescription": "string",
      "feeTypeId": 0,
      "feeTypeStatus": "active",
      "schoolDisplayName": "string",
      "schoolId": 0
    }
  ],
  "schoolId": 0
}
*/

  int? agent;
  List<FeeType?>? feeTypesList;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateFeeTypesRequest({
    this.agent,
    this.feeTypesList,
    this.schoolId,
  });
  CreateOrUpdateFeeTypesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['feeTypesList'] != null) {
      final v = json['feeTypesList'];
      final arr0 = <FeeType>[];
      v.forEach((v) {
        arr0.add(FeeType.fromJson(v));
      });
      feeTypesList = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (feeTypesList != null) {
      final v = feeTypesList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['feeTypesList'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateFeeTypesResponse {
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

  CreateOrUpdateFeeTypesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateFeeTypesResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateFeeTypesResponse> createOrUpdateFeeTypes(CreateOrUpdateFeeTypesRequest createOrUpdateFeeTypesRequest) async {
  print("Raising request to createOrUpdateFeeTypes with request ${jsonEncode(createOrUpdateFeeTypesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_FEE_TYPES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateFeeTypesRequest.toJson()),
  );

  CreateOrUpdateFeeTypesResponse createOrUpdateFeeTypesResponse = CreateOrUpdateFeeTypesResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateFeeTypesResponse ${createOrUpdateFeeTypesResponse.toJson()}");
  return createOrUpdateFeeTypesResponse;
}

class GetSectionWiseAnnualFeesRequest {
/*
{
  "customFeeTypeId": 0,
  "feeTypeId": 0,
  "schoolId": 0,
  "sectionId": 0
}
*/

  int? customFeeTypeId;
  int? feeTypeId;
  int? schoolId;
  int? sectionId;
  Map<String, dynamic> __origJson = {};

  GetSectionWiseAnnualFeesRequest({
    this.customFeeTypeId,
    this.feeTypeId,
    this.schoolId,
    this.sectionId,
  });
  GetSectionWiseAnnualFeesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SectionWiseAnnualFeesBean {
/*
{
  "amount": 0,
  "customFeeType": "string",
  "customFeeTypeId": 0,
  "feeType": "string",
  "feeTypeId": 0,
  "schoolDisplayName": "string",
  "schoolId": 0,
  "sectionFeeMapId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "sectionWiseFeesStatus": "active"
}
*/

  int? amount;
  String? customFeeType;
  int? customFeeTypeId;
  String? feeType;
  int? feeTypeId;
  String? schoolDisplayName;
  int? schoolId;
  int? sectionFeeMapId;
  int? sectionId;
  String? sectionName;
  String? sectionWiseFeesStatus;
  Map<String, dynamic> __origJson = {};

  SectionWiseAnnualFeesBean({
    this.amount,
    this.customFeeType,
    this.customFeeTypeId,
    this.feeType,
    this.feeTypeId,
    this.schoolDisplayName,
    this.schoolId,
    this.sectionFeeMapId,
    this.sectionId,
    this.sectionName,
    this.sectionWiseFeesStatus,
  });
  SectionWiseAnnualFeesBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['annualFeeAmount']?.toInt();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionFeeMapId = json['sectionFeeMapId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    sectionWiseFeesStatus = json['sectionWiseFeesStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['annualFeeAmount'] = amount;
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['sectionFeeMapId'] = sectionFeeMapId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sectionWiseFeesStatus'] = sectionWiseFeesStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetSectionWiseAnnualFeesResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "sectionWiseAnnualFeesBeanList": [
    {
      "amount": 0,
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "schoolDisplayName": "string",
      "schoolId": 0,
      "sectionFeeMapId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "sectionWiseFeesStatus": "active"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SectionWiseAnnualFeesBean?>? sectionWiseAnnualFeesBeanList;
  Map<String, dynamic> __origJson = {};

  GetSectionWiseAnnualFeesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.sectionWiseAnnualFeesBeanList,
  });
  GetSectionWiseAnnualFeesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['sectionWiseAnnualFeesBeanList'] != null) {
      final v = json['sectionWiseAnnualFeesBeanList'];
      final arr0 = <SectionWiseAnnualFeesBean>[];
      v.forEach((v) {
        arr0.add(SectionWiseAnnualFeesBean.fromJson(v));
      });
      sectionWiseAnnualFeesBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (sectionWiseAnnualFeesBeanList != null) {
      final v = sectionWiseAnnualFeesBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['sectionWiseAnnualFeesBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSectionWiseAnnualFeesResponse> getSectionWiseAnnualFees(GetSectionWiseAnnualFeesRequest getSectionWiseAnnualFeesRequest) async {
  print("Raising request to getSectionWiseAnnualFees with request ${jsonEncode(getSectionWiseAnnualFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SECTION_WISE_ANNUAL_FEES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getSectionWiseAnnualFeesRequest.toJson()),
  );

  GetSectionWiseAnnualFeesResponse getSectionWiseAnnualFeesResponse = GetSectionWiseAnnualFeesResponse.fromJson(json.decode(response.body));
  print("GetSectionWiseAnnualFeesResponse ${getSectionWiseAnnualFeesResponse.toJson()}");
  return getSectionWiseAnnualFeesResponse;
}

class CreateOrUpdateSectionFeeMapRequest {
/*
{
  "agent": 0,
  "schoolId": 0,
  "sectionWiseFeesBeanList": [
    {
      "amount": 0,
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "schoolDisplayName": "string",
      "schoolId": 0,
      "sectionFeeMapId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "sectionWiseFeesStatus": "active"
    }
  ]
}
*/

  int? agent;
  int? schoolId;
  List<SectionWiseAnnualFeesBean?>? sectionWiseFeesBeanList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateSectionFeeMapRequest({
    this.agent,
    this.schoolId,
    this.sectionWiseFeesBeanList,
  });
  CreateOrUpdateSectionFeeMapRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['sectionWiseFeesBeanList'] != null) {
      final v = json['sectionWiseFeesBeanList'];
      final arr0 = <SectionWiseAnnualFeesBean>[];
      v.forEach((v) {
        arr0.add(SectionWiseAnnualFeesBean.fromJson(v));
      });
      sectionWiseFeesBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    if (sectionWiseFeesBeanList != null) {
      final v = sectionWiseFeesBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['sectionWiseFeesBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSectionFeeMapResponse {
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

  CreateOrUpdateSectionFeeMapResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateSectionFeeMapResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateSectionFeeMapResponse> createOrUpdateSectionFeeMap(CreateOrUpdateSectionFeeMapRequest createOrUpdateSectionFeeMapRequest) async {
  print("Raising request to createOrUpdateSectionFeeMap with request ${jsonEncode(createOrUpdateSectionFeeMapRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SECTION_WISE_ANNUAL_FEES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateSectionFeeMapRequest.toJson()),
  );

  CreateOrUpdateSectionFeeMapResponse createOrUpdateSectionFeeMapResponse = CreateOrUpdateSectionFeeMapResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateSectionFeeMapResponse ${createOrUpdateSectionFeeMapResponse.toJson()}");
  return createOrUpdateSectionFeeMapResponse;
}

class GetStudentWiseAnnualFeesRequest {
/*
{
  "customFeeTypeId": 0,
  "feeTypeId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0
}
*/

  int? customFeeTypeId;
  int? feeTypeId;
  int? schoolId;
  int? sectionId;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  GetStudentWiseAnnualFeesRequest({
    this.customFeeTypeId,
    this.feeTypeId,
    this.schoolId,
    this.sectionId,
    this.studentId,
  });
  GetStudentWiseAnnualFeesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentAnnualFeeMapBean {
/*
{
  "amount": 0,
  "amountPaid": 0,
  "comments": "string",
  "customFeeType": "string",
  "customFeeTypeId": 0,
  "feeType": "string",
  "feeTypeId": 0,
  "schoolDisplayName": "string",
  "schoolId": 0,
  "sectionFeeMapId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "status": "active",
  "studentFeeMapId": 0,
  "studentId": 0,
  "studentName": "string",
  "studentWalletBalance": 0
}
*/

  int? amount;
  int? amountPaid;
  String? comments;
  String? customFeeType;
  int? customFeeTypeId;
  String? feeType;
  int? feeTypeId;
  String? schoolDisplayName;
  int? schoolId;
  int? sectionFeeMapId;
  int? sectionId;
  String? sectionName;
  String? status;
  int? studentFeeMapId;
  int? studentId;
  String? studentName;
  int? studentWalletBalance;
  Map<String, dynamic> __origJson = {};

  StudentAnnualFeeMapBean({
    this.amount,
    this.amountPaid,
    this.comments,
    this.customFeeType,
    this.customFeeTypeId,
    this.feeType,
    this.feeTypeId,
    this.schoolDisplayName,
    this.schoolId,
    this.sectionFeeMapId,
    this.sectionId,
    this.sectionName,
    this.status,
    this.studentFeeMapId,
    this.studentId,
    this.studentName,
    this.studentWalletBalance,
  });
  StudentAnnualFeeMapBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    amountPaid = json['amountPaid']?.toInt();
    comments = json['comments']?.toString();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionFeeMapId = json['sectionFeeMapId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    studentFeeMapId = json['studentFeeMapId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    studentWalletBalance = json['studentWalletBalance']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['amountPaid'] = amountPaid;
    data['comments'] = comments;
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['sectionFeeMapId'] = sectionFeeMapId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['studentFeeMapId'] = studentFeeMapId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['studentWalletBalance'] = studentWalletBalance;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentBusFeeLogBean {
/*
{
  "fare": 0,
  "rollNumber": "string",
  "routeId": 0,
  "routeName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "stopId": 0,
  "stopName": "string",
  "studentId": 0,
  "studentName": "string",
  "validFrom": "string",
  "validThrough": "string"
}
*/

  int? fare;
  String? rollNumber;
  int? routeId;
  String? routeName;
  int? schoolId;
  String? schoolName;
  int? stopId;
  String? stopName;
  int? studentId;
  String? studentName;
  String? validFrom;
  String? validThrough;
  Map<String, dynamic> __origJson = {};

  StudentBusFeeLogBean({
    this.fare,
    this.rollNumber,
    this.routeId,
    this.routeName,
    this.schoolId,
    this.schoolName,
    this.stopId,
    this.stopName,
    this.studentId,
    this.studentName,
    this.validFrom,
    this.validThrough,
  });
  StudentBusFeeLogBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    fare = json['fare']?.toInt();
    rollNumber = json['rollNumber']?.toString();
    routeId = json['routeId']?.toInt();
    routeName = json['routeName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    stopId = json['stopId']?.toInt();
    stopName = json['stopName']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    validFrom = json['validFrom']?.toString();
    validThrough = json['validThrough']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fare'] = fare;
    data['rollNumber'] = rollNumber;
    data['routeId'] = routeId;
    data['routeName'] = routeName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['stopId'] = stopId;
    data['stopName'] = stopName;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['validFrom'] = validFrom;
    data['validThrough'] = validThrough;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentBusFeeBean {
/*
{
  "fare": 0,
  "routeId": 0,
  "routeName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "stopId": 0,
  "stopName": "string",
  "studentBusFeeLogBeans": [
    {
      "fare": 0,
      "rollNumber": "string",
      "routeId": 0,
      "routeName": "string",
      "schoolId": 0,
      "schoolName": "string",
      "stopId": 0,
      "stopName": "string",
      "studentId": 0,
      "studentName": "string",
      "validFrom": "string",
      "validThrough": "string"
    }
  ],
  "studentId": 0,
  "studentName": "string"
}
*/

  int? fare;
  int? routeId;
  String? routeName;
  int? schoolId;
  String? schoolName;
  int? stopId;
  String? stopName;
  List<StudentBusFeeLogBean?>? studentBusFeeLogBeans;
  int? studentId;
  String? studentName;
  Map<String, dynamic> __origJson = {};

  StudentBusFeeBean({
    this.fare,
    this.routeId,
    this.routeName,
    this.schoolId,
    this.schoolName,
    this.stopId,
    this.stopName,
    this.studentBusFeeLogBeans,
    this.studentId,
    this.studentName,
  });
  StudentBusFeeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    fare = json['fare']?.toInt();
    routeId = json['routeId']?.toInt();
    routeName = json['routeName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    stopId = json['stopId']?.toInt();
    stopName = json['stopName']?.toString();
    if (json['studentBusFeeLogBeans'] != null) {
      final v = json['studentBusFeeLogBeans'];
      final arr0 = <StudentBusFeeLogBean>[];
      v.forEach((v) {
        arr0.add(StudentBusFeeLogBean.fromJson(v));
      });
      studentBusFeeLogBeans = arr0;
    }
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fare'] = fare;
    data['routeId'] = routeId;
    data['routeName'] = routeName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['stopId'] = stopId;
    data['stopName'] = stopName;
    if (studentBusFeeLogBeans != null) {
      final v = studentBusFeeLogBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentBusFeeLogBeans'] = arr0;
    }
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentWiseAnnualFeesBean {
/*
{
  "actualFee": 0,
  "feePaid": 0,
  "sectionId": 0,
  "sectionName": "string",
  "studentAnnualFeeMapBeanList": [
    {
      "amount": 0,
      "amountPaid": 0,
      "comments": "string",
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "schoolDisplayName": "string",
      "schoolId": 0,
      "sectionFeeMapId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "studentFeeMapId": 0,
      "studentId": 0,
      "studentName": "string",
      "studentWalletBalance": 0
    }
  ],
  "studentId": 0,
  "studentName": "string",
  "studentWalletBalance": 0
}
*/

  int? actualFee;
  int? feePaid;
  int? sectionId;
  String? sectionName;
  List<StudentAnnualFeeMapBean?>? studentAnnualFeeMapBeanList;
  int? studentId;
  String? studentName;
  int? studentWalletBalance;
  String? rollNumber;
  StudentBusFeeBean? studentBusFeeBean;
  Map<String, dynamic> __origJson = {};

  StudentWiseAnnualFeesBean({
    this.actualFee,
    this.feePaid,
    this.sectionId,
    this.sectionName,
    this.studentAnnualFeeMapBeanList,
    this.studentId,
    this.studentName,
    this.studentWalletBalance,
    this.rollNumber,
    this.studentBusFeeBean,
  });
  StudentWiseAnnualFeesBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    actualFee = json['actualFee']?.toInt();
    feePaid = json['feePaid']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    if (json['studentAnnualFeeMapBeanList'] != null) {
      final v = json['studentAnnualFeeMapBeanList'];
      final arr0 = <StudentAnnualFeeMapBean>[];
      v.forEach((v) {
        arr0.add(StudentAnnualFeeMapBean.fromJson(v));
      });
      studentAnnualFeeMapBeanList = arr0;
    }
    studentBusFeeBean = (json['studentBusFeeBean'] != null) ? StudentBusFeeBean.fromJson(json['studentBusFeeBean']) : null;
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    studentWalletBalance = json['studentWalletBalance']?.toInt();
    rollNumber = json['rollNumber']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['actualFee'] = actualFee;
    data['feePaid'] = feePaid;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    if (studentAnnualFeeMapBeanList != null) {
      final v = studentAnnualFeeMapBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentAnnualFeeMapBeanList'] = arr0;
    }
    if (studentBusFeeBean != null) {
      data['studentBusFeeBean'] = studentBusFeeBean!.toJson();
    }
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['studentWalletBalance'] = studentWalletBalance;
    data['rollNumber'] = rollNumber;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentWiseAnnualFeesResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentWiseAnnualFeesBeanList": [
    {
      "actualFee": 0,
      "feePaid": 0,
      "sectionId": 0,
      "sectionName": "string",
      "studentAnnualFeeMapBeanList": [
        {
          "amount": 0,
          "amountPaid": 0,
          "comments": "string",
          "customFeeType": "string",
          "customFeeTypeId": 0,
          "feeType": "string",
          "feeTypeId": 0,
          "schoolDisplayName": "string",
          "schoolId": 0,
          "sectionFeeMapId": 0,
          "sectionId": 0,
          "sectionName": "string",
          "status": "active",
          "studentFeeMapId": 0,
          "studentId": 0,
          "studentName": "string",
          "studentWalletBalance": 0
        }
      ],
      "studentId": 0,
      "studentName": "string",
      "studentWalletBalance": 0
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentWiseAnnualFeesBean?>? studentWiseAnnualFeesBeanList;
  Map<String, dynamic> __origJson = {};

  GetStudentWiseAnnualFeesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentWiseAnnualFeesBeanList,
  });
  GetStudentWiseAnnualFeesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentWiseAnnualFeesBeanList'] != null) {
      final v = json['studentWiseAnnualFeesBeanList'];
      final arr0 = <StudentWiseAnnualFeesBean>[];
      v.forEach((v) {
        arr0.add(StudentWiseAnnualFeesBean.fromJson(v));
      });
      studentWiseAnnualFeesBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentWiseAnnualFeesBeanList != null) {
      final v = studentWiseAnnualFeesBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentWiseAnnualFeesBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentWiseAnnualFeesResponse> getStudentWiseAnnualFees(GetStudentWiseAnnualFeesRequest getStudentWiseAnnualFeesRequest) async {
  print("Raising request to getStudentWiseAnnualFees with request ${jsonEncode(getStudentWiseAnnualFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_WISE_ANNUAL_FEES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentWiseAnnualFeesRequest.toJson()),
  );

  GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = GetStudentWiseAnnualFeesResponse.fromJson(json.decode(response.body));
  print("GetStudentWiseAnnualFeesResponse ${getStudentWiseAnnualFeesResponse.toJson()}");
  return getStudentWiseAnnualFeesResponse;
}

class StudentAnnualFeeMapUpdateBean {
/*
{
  "amount": 0,
  "schoolId": 0,
  "sectionFeeMapId": 0,
  "studentFeeMapId": 0,
  "studentId": 0
}
*/

  int? amount;
  int? schoolId;
  int? sectionFeeMapId;
  int? studentFeeMapId;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  StudentAnnualFeeMapUpdateBean({
    this.amount,
    this.schoolId,
    this.sectionFeeMapId,
    this.studentFeeMapId,
    this.studentId,
  });
  StudentAnnualFeeMapUpdateBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionFeeMapId = json['sectionFeeMapId']?.toInt();
    studentFeeMapId = json['studentFeeMapId']?.toInt();
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['schoolId'] = schoolId;
    data['sectionFeeMapId'] = sectionFeeMapId;
    data['studentFeeMapId'] = studentFeeMapId;
    data['studentId'] = studentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentAnnualFeeMapRequest {
/*
{
  "agent": 0,
  "schoolId": 0,
  "studentAnnualFeeMapBeanList": [
    {
      "amount": 0,
      "schoolId": 0,
      "sectionFeeMapId": 0,
      "studentFeeMapId": 0,
      "studentId": 0
    }
  ]
}
*/

  int? agent;
  int? schoolId;
  List<StudentAnnualFeeMapUpdateBean?>? studentAnnualFeeMapBeanList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentAnnualFeeMapRequest({
    this.agent,
    this.schoolId,
    this.studentAnnualFeeMapBeanList,
  });
  CreateOrUpdateStudentAnnualFeeMapRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['studentAnnualFeeMapBeanList'] != null) {
      final v = json['studentAnnualFeeMapBeanList'];
      final arr0 = <StudentAnnualFeeMapUpdateBean>[];
      v.forEach((v) {
        arr0.add(StudentAnnualFeeMapUpdateBean.fromJson(v));
      });
      studentAnnualFeeMapBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    if (studentAnnualFeeMapBeanList != null) {
      final v = studentAnnualFeeMapBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentAnnualFeeMapBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentAnnualFeeMapResponse {
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

  CreateOrUpdateStudentAnnualFeeMapResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateStudentAnnualFeeMapResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateStudentAnnualFeeMapResponse> createOrUpdateStudentAnnualFeeMap(
    CreateOrUpdateStudentAnnualFeeMapRequest createOrUpdateStudentAnnualFeeMapRequest) async {
  print("Raising request to createOrUpdateStudentAnnualFeeMap with request ${jsonEncode(createOrUpdateStudentAnnualFeeMapRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_WISE_ANNUAL_FEES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateStudentAnnualFeeMapRequest.toJson()),
  );

  CreateOrUpdateStudentAnnualFeeMapResponse createOrUpdateStudentAnnualFeeMapResponse =
      CreateOrUpdateStudentAnnualFeeMapResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateStudentAnnualFeeMapResponse ${createOrUpdateStudentAnnualFeeMapResponse.toJson()}");
  return createOrUpdateStudentAnnualFeeMapResponse;
}

class GetTermsRequest {
/*
{
  "schoolId": 0,
  "termId": 0
}
*/

  int? schoolId;
  int? termId;
  Map<String, dynamic> __origJson = {};

  GetTermsRequest({
    this.schoolId,
    this.termId,
  });
  GetTermsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
    termId = json['termId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['termId'] = termId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TermBean {
/*
{
  "schoolDisplayName": "string",
  "schoolId": 0,
  "status": "active",
  "termEndDate": "string",
  "termId": 0,
  "termName": "string",
  "termNumber": 0,
  "termStartDate": "string"
}
*/

  String? schoolDisplayName;
  int? schoolId;
  String? status;
  String? termEndDate;
  int? termId;
  String? termName;
  int? termNumber;
  String? termStartDate;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;
  TextEditingController termNameController = TextEditingController();

  TermBean({
    this.schoolDisplayName,
    this.schoolId,
    this.status,
    this.termEndDate,
    this.termId,
    this.termName,
    this.termNumber,
    this.termStartDate,
  }) {
    termNameController.text = termName ?? "";
  }

  TermBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    termEndDate = json['termEndDate']?.toString();
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    termNameController.text = termName ?? "";
    termNumber = json['termNumber']?.toInt();
    termStartDate = json['termStartDate']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['termEndDate'] = termEndDate;
    data['termId'] = termId;
    data['termName'] = termName;
    data['termNumber'] = termNumber;
    data['termStartDate'] = termStartDate;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetTermsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "termBeanList": [
    {
      "schoolDisplayName": "string",
      "schoolId": 0,
      "status": "active",
      "termEndDate": "string",
      "termId": 0,
      "termName": "string",
      "termNumber": 0,
      "termStartDate": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<TermBean?>? termBeanList;
  Map<String, dynamic> __origJson = {};

  GetTermsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.termBeanList,
  });
  GetTermsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['termBeanList'] != null) {
      final v = json['termBeanList'];
      final arr0 = <TermBean>[];
      v.forEach((v) {
        arr0.add(TermBean.fromJson(v));
      });
      termBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (termBeanList != null) {
      final v = termBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['termBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetTermsResponse> getTerms(GetTermsRequest getTermsRequest) async {
  print("Raising request to getTerms with request ${jsonEncode(getTermsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TERMS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getTermsRequest.toJson()),
  );

  GetTermsResponse getTermsResponse = GetTermsResponse.fromJson(json.decode(response.body));
  print("GetTermsResponse ${getTermsResponse.toJson()}");
  return getTermsResponse;
}

class CreateOrUpdateTermRequest {
/*
{
  "agent": 0,
  "schoolId": 0,
  "status": "active",
  "termEndDate": "string",
  "termId": 0,
  "termName": "string",
  "termNumber": 0,
  "termStartDate": "string"
}
*/

  int? agent;
  int? schoolId;
  String? status;
  String? termEndDate;
  int? termId;
  String? termName;
  int? termNumber;
  String? termStartDate;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTermRequest({
    this.agent,
    this.schoolId,
    this.status,
    this.termEndDate,
    this.termId,
    this.termName,
    this.termNumber,
    this.termStartDate,
  });
  CreateOrUpdateTermRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    termEndDate = json['termEndDate']?.toString();
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    termNumber = json['termNumber']?.toInt();
    termStartDate = json['termStartDate']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['termEndDate'] = termEndDate;
    data['termId'] = termId;
    data['termName'] = termName;
    data['termNumber'] = termNumber;
    data['termStartDate'] = termStartDate;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateTermResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "termId": 0
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? termId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTermResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.termId,
  });
  CreateOrUpdateTermResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    termId = json['termId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['termId'] = termId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateTermResponse> createOrUpdateTerm(CreateOrUpdateTermRequest createOrUpdateTermRequest) async {
  print("Raising request to createOrUpdateTerm with request ${jsonEncode(createOrUpdateTermRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TERM;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateTermRequest.toJson()),
  );

  CreateOrUpdateTermResponse createOrUpdateTermResponse = CreateOrUpdateTermResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateTermResponse ${createOrUpdateTermResponse.toJson()}");
  return createOrUpdateTermResponse;
}

class GetSectionWiseTermFeesRequest {
/*
{
  "customFeeTypeId": 0,
  "feeTypeId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "termId": 0
}
*/

  int? customFeeTypeId;
  int? feeTypeId;
  int? schoolId;
  int? sectionId;
  int? termId;
  Map<String, dynamic> __origJson = {};

  GetSectionWiseTermFeesRequest({
    this.customFeeTypeId,
    this.feeTypeId,
    this.schoolId,
    this.sectionId,
    this.termId,
  });
  GetSectionWiseTermFeesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    termId = json['termId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['termId'] = termId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SectionWiseTermFeesBean {
/*
{
  "annualFeeAmount": 0,
  "customFeeType": "string",
  "customFeeTypeId": 0,
  "feeType": "string",
  "feeTypeId": 0,
  "schoolDisplayName": "string",
  "schoolId": 0,
  "sectionFeeMapId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "sectionWiseFeesStatus": "active",
  "termFeeAmount": 0,
  "termFeeMapId": 0
}
*/

  int? termId;
  int? annualFeeAmount;
  String? customFeeType;
  int? customFeeTypeId;
  String? feeType;
  int? feeTypeId;
  String? schoolDisplayName;
  int? schoolId;
  int? sectionFeeMapId;
  int? sectionId;
  String? sectionName;
  String? sectionWiseFeesStatus;
  int? termFeeAmount;
  int? termFeeMapId;
  Map<String, dynamic> __origJson = {};

  SectionWiseTermFeesBean({
    this.termId,
    this.annualFeeAmount,
    this.customFeeType,
    this.customFeeTypeId,
    this.feeType,
    this.feeTypeId,
    this.schoolDisplayName,
    this.schoolId,
    this.sectionFeeMapId,
    this.sectionId,
    this.sectionName,
    this.sectionWiseFeesStatus,
    this.termFeeAmount,
    this.termFeeMapId,
  });
  SectionWiseTermFeesBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    termId = json['termId']?.toInt();
    annualFeeAmount = json['annualFeeAmount']?.toInt();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionFeeMapId = json['sectionFeeMapId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    sectionWiseFeesStatus = json['sectionWiseFeesStatus']?.toString();
    termFeeAmount = json['termFeeAmount']?.toInt();
    termFeeMapId = json['termFeeMapId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['termId'] = termId;
    data['annualFeeAmount'] = annualFeeAmount;
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['sectionFeeMapId'] = sectionFeeMapId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sectionWiseFeesStatus'] = sectionWiseFeesStatus;
    data['termFeeAmount'] = termFeeAmount;
    data['termFeeMapId'] = termFeeMapId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetSectionWiseTermFeesResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "sectionWiseTermFeesBeanList": [
    {
      "annualFeeAmount": 0,
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "schoolDisplayName": "string",
      "schoolId": 0,
      "sectionFeeMapId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "sectionWiseFeesStatus": "active",
      "termFeeAmount": 0,
      "termFeeMapId": 0
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SectionWiseTermFeesBean?>? sectionWiseTermFeesBeanList;
  Map<String, dynamic> __origJson = {};

  GetSectionWiseTermFeesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.sectionWiseTermFeesBeanList,
  });
  GetSectionWiseTermFeesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['sectionWiseTermFeesBeanList'] != null) {
      final v = json['sectionWiseTermFeesBeanList'];
      final arr0 = <SectionWiseTermFeesBean>[];
      v.forEach((v) {
        arr0.add(SectionWiseTermFeesBean.fromJson(v));
      });
      sectionWiseTermFeesBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (sectionWiseTermFeesBeanList != null) {
      final v = sectionWiseTermFeesBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['sectionWiseTermFeesBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSectionWiseTermFeesResponse> getSectionWiseTermFees(GetSectionWiseTermFeesRequest getSectionWiseTermFeesRequest) async {
  print("Raising request to getSectionWiseTermFees with request ${jsonEncode(getSectionWiseTermFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SECTION_WISE_TERM_FEES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getSectionWiseTermFeesRequest.toJson()),
  );

  GetSectionWiseTermFeesResponse getSectionWiseTermFeesResponse = GetSectionWiseTermFeesResponse.fromJson(json.decode(response.body));
  print("GetSectionWiseTermFeesResponse ${getSectionWiseTermFeesResponse.toJson()}");
  return getSectionWiseTermFeesResponse;
}

class UpdateSectionWiseTermFeeBean {
/*
{
  "amount": 0,
  "schoolId": 0,
  "schoolName": "string",
  "sectionFeeMapId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "status": "active",
  "termFeeMapId": 0,
  "termId": 0,
  "termName": "string",
  "termNumber": 0
}
*/

  int? amount;
  int? schoolId;
  String? schoolName;
  int? sectionFeeMapId;
  int? sectionId;
  String? sectionName;
  String? status;
  int? termFeeMapId;
  int? termId;
  String? termName;
  int? termNumber;
  Map<String, dynamic> __origJson = {};

  UpdateSectionWiseTermFeeBean({
    this.amount,
    this.schoolId,
    this.schoolName,
    this.sectionFeeMapId,
    this.sectionId,
    this.sectionName,
    this.status,
    this.termFeeMapId,
    this.termId,
    this.termName,
    this.termNumber,
  });
  UpdateSectionWiseTermFeeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    sectionFeeMapId = json['sectionFeeMapId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    termFeeMapId = json['termFeeMapId']?.toInt();
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    termNumber = json['termNumber']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['sectionFeeMapId'] = sectionFeeMapId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['termFeeMapId'] = termFeeMapId;
    data['termId'] = termId;
    data['termName'] = termName;
    data['termNumber'] = termNumber;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSectionWiseTermFeeMapRequest {
/*
{
  "agent": 0,
  "schoolId": 0,
  "sectionWiseTermFeeList": [
    {
      "amount": 0,
      "schoolId": 0,
      "schoolName": "string",
      "sectionFeeMapId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "termFeeMapId": 0,
      "termId": 0,
      "termName": "string",
      "termNumber": 0
    }
  ]
}
*/

  int? agent;
  int? schoolId;
  List<UpdateSectionWiseTermFeeBean?>? sectionWiseTermFeeList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateSectionWiseTermFeeMapRequest({
    this.agent,
    this.schoolId,
    this.sectionWiseTermFeeList,
  });
  CreateOrUpdateSectionWiseTermFeeMapRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['sectionWiseTermFeeList'] != null) {
      final v = json['sectionWiseTermFeeList'];
      final arr0 = <UpdateSectionWiseTermFeeBean>[];
      v.forEach((v) {
        arr0.add(UpdateSectionWiseTermFeeBean.fromJson(v));
      });
      sectionWiseTermFeeList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    if (sectionWiseTermFeeList != null) {
      final v = sectionWiseTermFeeList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['sectionWiseTermFeeList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSectionWiseTermFeeMapResponse {
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

  CreateOrUpdateSectionWiseTermFeeMapResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateSectionWiseTermFeeMapResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateSectionWiseTermFeeMapResponse> createOrUpdateSectionWiseTermFeeMap(
    CreateOrUpdateSectionWiseTermFeeMapRequest createOrUpdateSectionWiseTermFeeMapRequest) async {
  print("Raising request to createOrUpdateSectionWiseTermFeeMap with request ${jsonEncode(createOrUpdateSectionWiseTermFeeMapRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_SECTION_WISE_TERM_FEES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateSectionWiseTermFeeMapRequest.toJson()),
  );

  CreateOrUpdateSectionWiseTermFeeMapResponse createOrUpdateSectionWiseTermFeeMapResponse =
      CreateOrUpdateSectionWiseTermFeeMapResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateSectionWiseTermFeeMapResponse ${createOrUpdateSectionWiseTermFeeMapResponse.toJson()}");
  return createOrUpdateSectionWiseTermFeeMapResponse;
}

class GetStudentWiseTermFeesRequest {
/*
{
  "customFeeTypeId": 0,
  "feeTypeId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "termId": 0
}
*/

  int? customFeeTypeId;
  int? feeTypeId;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? termId;
  Map<String, dynamic> __origJson = {};

  GetStudentWiseTermFeesRequest({
    this.customFeeTypeId,
    this.feeTypeId,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.termId,
  });
  GetStudentWiseTermFeesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    termId = json['termId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['termId'] = termId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentWiseTermFeeMapBean {
/*
{
  "amount": 0,
  "customFeeType": "string",
  "customFeeTypeId": 0,
  "feePaid": 0,
  "feePaidId": 0,
  "feeType": "string",
  "feeTypeId": 0,
  "modeOfPayment": "CASH",
  "paymentDate": "string",
  "schoolDisplayName": "string",
  "schoolId": 0,
  "sectionFeeMapId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "studentFeeMapId": 0,
  "studentId": 0,
  "studentName": "string",
  "studentWalletBalance": 0,
  "termEndDate": "string",
  "termFee": 0,
  "termFeeMapId": 0,
  "termId": 0,
  "termName": "string",
  "termNumber": 0,
  "termStartDate": "string",
  "transactionDescription": "string",
  "transactionId": 0,
  "transactionKind": "CR",
  "transactionStatus": "SUCCESS",
  "transactionType": "string"
}
*/

  int? amount;
  String? customFeeType;
  int? customFeeTypeId;
  int? feePaid;
  int? feePaidId;
  String? feeType;
  int? feeTypeId;
  String? modeOfPayment;
  String? paymentDate;
  String? schoolDisplayName;
  int? schoolId;
  int? sectionFeeMapId;
  int? sectionId;
  String? sectionName;
  int? studentFeeMapId;
  int? studentId;
  String? studentName;
  int? studentWalletBalance;
  String? termEndDate;
  int? termFee;
  int? termFeeMapId;
  int? termId;
  String? termName;
  int? termNumber;
  String? termStartDate;
  String? transactionDescription;
  String? transactionId;
  String? masterTransactionId;
  String? masterTransactionDate;
  String? transactionKind;
  String? transactionStatus;
  String? transactionType;
  Map<String, dynamic> __origJson = {};

  StudentWiseTermFeeMapBean({
    this.amount,
    this.customFeeType,
    this.customFeeTypeId,
    this.feePaid,
    this.feePaidId,
    this.feeType,
    this.feeTypeId,
    this.modeOfPayment,
    this.paymentDate,
    this.schoolDisplayName,
    this.schoolId,
    this.sectionFeeMapId,
    this.sectionId,
    this.sectionName,
    this.studentFeeMapId,
    this.studentId,
    this.studentName,
    this.studentWalletBalance,
    this.termEndDate,
    this.termFee,
    this.termFeeMapId,
    this.termId,
    this.termName,
    this.termNumber,
    this.termStartDate,
    this.transactionDescription,
    this.transactionId,
    this.masterTransactionId,
    this.masterTransactionDate,
    this.transactionKind,
    this.transactionStatus,
    this.transactionType,
  });
  StudentWiseTermFeeMapBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feePaid = json['feePaid']?.toInt();
    feePaidId = json['feePaidId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
    paymentDate = json['paymentDate']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionFeeMapId = json['sectionFeeMapId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentFeeMapId = json['studentFeeMapId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    studentWalletBalance = json['studentWalletBalance']?.toInt();
    termEndDate = json['termEndDate']?.toString();
    termFee = json['termFee']?.toInt();
    termFeeMapId = json['termFeeMapId']?.toInt();
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    termNumber = json['termNumber']?.toInt();
    termStartDate = json['termStartDate']?.toString();
    transactionDescription = json['transactionDescription']?.toString();
    transactionId = json['transactionId']?.toString();
    masterTransactionId = json['masterTransactionId']?.toString();
    masterTransactionDate = json['masterTransactionDate']?.toString();
    transactionKind = json['transactionKind']?.toString();
    transactionStatus = json['transactionStatus']?.toString();
    transactionType = json['transactionType']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feePaid'] = feePaid;
    data['feePaidId'] = feePaidId;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['modeOfPayment'] = modeOfPayment;
    data['paymentDate'] = paymentDate;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['sectionFeeMapId'] = sectionFeeMapId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentFeeMapId'] = studentFeeMapId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['studentWalletBalance'] = studentWalletBalance;
    data['termEndDate'] = termEndDate;
    data['termFee'] = termFee;
    data['termFeeMapId'] = termFeeMapId;
    data['termId'] = termId;
    data['termName'] = termName;
    data['termNumber'] = termNumber;
    data['termStartDate'] = termStartDate;
    data['transactionDescription'] = transactionDescription;
    data['transactionId'] = transactionId;
    data['masterTransactionId'] = masterTransactionId;
    data['masterTransactionDate'] = masterTransactionDate;
    data['transactionKind'] = transactionKind;
    data['transactionStatus'] = transactionStatus;
    data['transactionType'] = transactionType;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentWalletTransactionBean {
/*
{
  "studentId": 70,
  "studentName": "Kaushal",
  "transactionId": 1649708722944,
  "amount": 10000,
  "date": "2022-04-11",
  "transactionKind": "CR",
  "transactionType": "LOAD_WALLET",
  "description": "LOADING WALLET WITH AMOUNT 10000 FOR STUDENT Kaushal",
  "transactionStatus": "SUCCESS",
  "agent": 127
}
*/

  int? studentId;
  String? studentName;
  String? transactionId;
  String? masterTransactionId;
  String? masterTransactionDate;
  int? amount;
  String? date;
  String? transactionKind;
  String? transactionType;
  String? description;
  String? transactionStatus;
  int? agent;
  Map<String, dynamic> __origJson = {};

  StudentWalletTransactionBean({
    this.studentId,
    this.studentName,
    this.transactionId,
    this.masterTransactionId,
    this.masterTransactionDate,
    this.amount,
    this.date,
    this.transactionKind,
    this.transactionType,
    this.description,
    this.transactionStatus,
    this.agent,
  });
  StudentWalletTransactionBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    transactionId = json['transactionId']?.toString();
    masterTransactionId = json['masterTransactionId']?.toString();
    masterTransactionDate = json['masterTransactionDate']?.toString();
    amount = json['amount']?.toInt();
    date = json['date']?.toString();
    transactionKind = json['transactionKind']?.toString();
    transactionType = json['transactionType']?.toString();
    description = json['description']?.toString();
    transactionStatus = json['transactionStatus']?.toString();
    agent = json['agent']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['transactionId'] = transactionId;
    data['masterTransactionId'] = masterTransactionId;
    data['masterTransactionDate'] = masterTransactionDate;
    data['amount'] = amount;
    data['date'] = date;
    data['transactionKind'] = transactionKind;
    data['transactionType'] = transactionType;
    data['description'] = description;
    data['transactionStatus'] = transactionStatus;
    data['agent'] = agent;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "StudentWalletTransactionBean {'studentId': $studentId, 'studentName': $studentName, 'transactionId': $transactionId, 'masterTransactionId': $masterTransactionId, 'amount': $amount, 'date': $date, 'transactionKind': $transactionKind, 'transactionType': $transactionType, 'description': $description, 'transactionStatus': $transactionStatus, 'agent': $agent}";
  }
}

class StudentWiseTermFeesBean {
/*
{
  "actualFee": 0,
  "feePaid": 0,
  "sectionId": 0,
  "sectionName": "string",
  "studentId": 0,
  "studentName": "string",
  "studentWiseTermFeeMapBeanList": [
    {
      "amount": 0,
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feePaid": 0,
      "feePaidId": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "modeOfPayment": "CASH",
      "paymentDate": "string",
      "schoolDisplayName": "string",
      "schoolId": 0,
      "sectionFeeMapId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "studentFeeMapId": 0,
      "studentId": 0,
      "studentName": "string",
      "studentWalletBalance": 0,
      "termEndDate": "string",
      "termFee": 0,
      "termFeeMapId": 0,
      "termId": 0,
      "termName": "string",
      "termNumber": 0,
      "termStartDate": "string",
      "transactionDescription": "string",
      "transactionId": 0,
      "transactionKind": "CR",
      "transactionStatus": "SUCCESS",
      "transactionType": "string"
    }
  ]
}
*/

  int? actualFee;
  int? feePaid;
  int? sectionId;
  String? sectionName;
  int? studentId;
  String? studentName;
  List<StudentWiseTermFeeMapBean?>? studentWiseTermFeeMapBeanList;
  List<StudentWalletTransactionBean?>? studentWalletTransactionBeans;
  Map<String, dynamic> __origJson = {};

  StudentWiseTermFeesBean({
    this.actualFee,
    this.feePaid,
    this.sectionId,
    this.sectionName,
    this.studentId,
    this.studentName,
    this.studentWiseTermFeeMapBeanList,
    this.studentWalletTransactionBeans,
  });
  StudentWiseTermFeesBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    actualFee = json['actualFee']?.toInt();
    feePaid = json['feePaid']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    if (json['studentWiseTermFeeMapBeanList'] != null) {
      final v = json['studentWiseTermFeeMapBeanList'];
      final arr0 = <StudentWiseTermFeeMapBean>[];
      v.forEach((v) {
        arr0.add(StudentWiseTermFeeMapBean.fromJson(v));
      });
      studentWiseTermFeeMapBeanList = arr0;
    }
    if (json['studentWalletTransactionBeans'] != null) {
      final v = json['studentWalletTransactionBeans'];
      final arr1 = <StudentWalletTransactionBean>[];
      v.forEach((v) {
        arr1.add(StudentWalletTransactionBean.fromJson(v));
      });
      studentWalletTransactionBeans = arr1;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['actualFee'] = actualFee;
    data['feePaid'] = feePaid;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    if (studentWiseTermFeeMapBeanList != null) {
      final v = studentWiseTermFeeMapBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentWiseTermFeeMapBeanList'] = arr0;
    }
    if (studentWalletTransactionBeans != null) {
      final v = studentWalletTransactionBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentWalletTransactionBeans'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentWiseTermFeesResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentWiseTermFeesBeanList": [
    {
      "actualFee": 0,
      "feePaid": 0,
      "sectionId": 0,
      "sectionName": "string",
      "studentId": 0,
      "studentName": "string",
      "studentWiseTermFeeMapBeanList": [
        {
          "amount": 0,
          "customFeeType": "string",
          "customFeeTypeId": 0,
          "feePaid": 0,
          "feePaidId": 0,
          "feeType": "string",
          "feeTypeId": 0,
          "modeOfPayment": "CASH",
          "paymentDate": "string",
          "schoolDisplayName": "string",
          "schoolId": 0,
          "sectionFeeMapId": 0,
          "sectionId": 0,
          "sectionName": "string",
          "studentFeeMapId": 0,
          "studentId": 0,
          "studentName": "string",
          "studentWalletBalance": 0,
          "termEndDate": "string",
          "termFee": 0,
          "termFeeMapId": 0,
          "termId": 0,
          "termName": "string",
          "termNumber": 0,
          "termStartDate": "string",
          "transactionDescription": "string",
          "transactionId": 0,
          "transactionKind": "CR",
          "transactionStatus": "SUCCESS",
          "transactionType": "string"
        }
      ]
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentWiseTermFeesBean?>? studentWiseTermFeesBeanList;
  Map<String, dynamic> __origJson = {};

  GetStudentWiseTermFeesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentWiseTermFeesBeanList,
  });
  GetStudentWiseTermFeesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentWiseTermFeesBeanList'] != null) {
      final v = json['studentWiseTermFeesBeanList'];
      final arr0 = <StudentWiseTermFeesBean>[];
      v.forEach((v) {
        arr0.add(StudentWiseTermFeesBean.fromJson(v));
      });
      studentWiseTermFeesBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentWiseTermFeesBeanList != null) {
      final v = studentWiseTermFeesBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentWiseTermFeesBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentWiseTermFeesResponse> getStudentWiseTermFees(GetStudentWiseTermFeesRequest getStudentWiseTermFeesRequest) async {
  print("Raising request to getStudentWiseTermFees with request ${jsonEncode(getStudentWiseTermFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_WISE_TERM_FEES;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentWiseTermFeesRequest.toJson()),
  );

  GetStudentWiseTermFeesResponse getStudentWiseTermFeesResponse = GetStudentWiseTermFeesResponse.fromJson(json.decode(response.body));
  print("GetStudentWiseTermFeesResponse ${getStudentWiseTermFeesResponse.toJson()}");
  return getStudentWiseTermFeesResponse;
}

class CreateOrUpdateStudentFeePaidRequest {
/*
{
  "agent": 0,
  "loadWalletAmount": 0,
  "masterTransactionId": "string",
  "schoolId": 0,
  "studentId": 0,
  "studentTermFeeMapList": [
    {
      "amount": 0,
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feePaid": 0,
      "feePaidId": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "masterTransactionId": "string",
      "modeOfPayment": "CASH",
      "paymentDate": "string",
      "schoolDisplayName": "string",
      "schoolId": 0,
      "sectionFeeMapId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "studentFeeMapId": 0,
      "studentId": 0,
      "studentName": "string",
      "studentWalletBalance": 0,
      "termEndDate": "string",
      "termFee": 0,
      "termFeeMapId": 0,
      "termId": 0,
      "termName": "string",
      "termNumber": 0,
      "termStartDate": "string",
      "transactionDescription": "string",
      "transactionId": "string",
      "transactionKind": "CR",
      "transactionStatus": "SUCCESS",
      "transactionType": "string"
    }
  ]
}
*/

  int? agent;
  int? loadWalletAmount;
  String? masterTransactionId;
  int? schoolId;
  int? studentId;
  List<StudentWiseTermFeeMapBean?>? studentTermFeeMapList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentFeePaidRequest({
    this.agent,
    this.loadWalletAmount,
    this.masterTransactionId,
    this.schoolId,
    this.studentId,
    this.studentTermFeeMapList,
  });
  CreateOrUpdateStudentFeePaidRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    loadWalletAmount = json['loadWalletAmount']?.toInt();
    masterTransactionId = json['masterTransactionId']?.toString();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    if (json['studentTermFeeMapList'] != null) {
      final v = json['studentTermFeeMapList'];
      final arr0 = <StudentWiseTermFeeMapBean>[];
      v.forEach((v) {
        arr0.add(StudentWiseTermFeeMapBean.fromJson(v));
      });
      studentTermFeeMapList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['loadWalletAmount'] = loadWalletAmount;
    data['masterTransactionId'] = masterTransactionId;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    if (studentTermFeeMapList != null) {
      final v = studentTermFeeMapList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentTermFeeMapList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentFeePaidResponse {
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

  CreateOrUpdateStudentFeePaidResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateStudentFeePaidResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateStudentFeePaidResponse> createOrUpdateStudentFeePaid(
    CreateOrUpdateStudentFeePaidRequest createOrUpdateStudentFeePaidRequest) async {
  print("Raising request to createOrUpdateStudentFeePaid with request ${jsonEncode(createOrUpdateStudentFeePaidRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_FEE_PAID;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateStudentFeePaidRequest.toJson()),
  );

  CreateOrUpdateStudentFeePaidResponse createOrUpdateStudentFeePaidResponse =
      CreateOrUpdateStudentFeePaidResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateStudentFeePaidResponse ${createOrUpdateStudentFeePaidResponse.toJson()}");
  return createOrUpdateStudentFeePaidResponse;
}

class TransportFeeAssignmentTypeBean {
/*
{
  "agent": 0,
  "amount": 0,
  "assignmentType": "string",
  "schoolId": 0,
  "status": "active",
  "validFrom": "string",
  "validThrough": "string"
}
*/

  int? agent;
  int? amount;
  String? assignmentType;
  int? schoolId;
  String? status;
  String? validFrom;
  String? validThrough;
  Map<String, dynamic> __origJson = {};

  TextEditingController amountController = TextEditingController();

  TransportFeeAssignmentTypeBean({
    this.agent,
    this.amount,
    this.assignmentType,
    this.schoolId,
    this.status,
    this.validFrom,
    this.validThrough,
  }) {
    amountController.text = amount == null ? "" : doubleToStringAsFixed(amount! / 100, decimalPlaces: 2);
  }
  TransportFeeAssignmentTypeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    amount = json['amount']?.toInt();
    amountController.text = amount == null ? "" : doubleToStringAsFixed(amount! / 100, decimalPlaces: 2);
    assignmentType = json['assignmentType']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    validFrom = json['validFrom']?.toString();
    validThrough = json['validThrough']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['amount'] = amount;
    data['assignmentType'] = assignmentType;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['validFrom'] = validFrom;
    data['validThrough'] = validThrough;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetTransportFeeAssignmentTypeResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "transportFeeAssignmentTypeBean": {
    "agent": 0,
    "amount": 0,
    "assignmentType": "string",
    "schoolId": 0,
    "status": "active",
    "validFrom": "string",
    "validThrough": "string"
  }
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  TransportFeeAssignmentTypeBean? transportFeeAssignmentTypeBean;
  Map<String, dynamic> __origJson = {};

  GetTransportFeeAssignmentTypeResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.transportFeeAssignmentTypeBean,
  });
  GetTransportFeeAssignmentTypeResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    transportFeeAssignmentTypeBean =
        (json['transportFeeAssignmentTypeBean'] != null) ? TransportFeeAssignmentTypeBean.fromJson(json['transportFeeAssignmentTypeBean']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (transportFeeAssignmentTypeBean != null) {
      data['transportFeeAssignmentTypeBean'] = transportFeeAssignmentTypeBean!.toJson();
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetTransportFeeAssignmentTypeResponse> getTransportFeeAssignmentType(
    TransportFeeAssignmentTypeBean getTransportFeeAssignmentTypeRequest) async {
  print("Raising request to getTransportFeeAssignmentType with request ${jsonEncode(getTransportFeeAssignmentTypeRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TRANSPORT_FEE_ASSIGNMENT_TYPE;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getTransportFeeAssignmentTypeRequest.toJson()),
  );

  GetTransportFeeAssignmentTypeResponse getTransportFeeAssignmentTypeResponse =
      GetTransportFeeAssignmentTypeResponse.fromJson(json.decode(response.body));
  print("GetTransportFeeAssignmentTypeResponse ${getTransportFeeAssignmentTypeResponse.toJson()}");
  return getTransportFeeAssignmentTypeResponse;
}
