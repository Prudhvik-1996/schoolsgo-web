import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

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
    amount = json['amount']?.toInt();
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
    data['amount'] = amount;
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
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
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
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
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
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentAnnualFeeMapBeanList'] = arr0;
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
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
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
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
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
