import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/stats/constants/fee_report_type.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
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
    feeTypeId = json['feeTypeId']?.toInt() ?? -1;
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
  debugPrint("Raising request to getFeeTypes with request ${jsonEncode(getFeeTypesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_FEE_TYPES;

  GetFeeTypesResponse getFeeTypesResponse = await HttpUtils.post(
    _url,
    getFeeTypesRequest.toJson(),
    GetFeeTypesResponse.fromJson,
  );

  debugPrint("GetFeeTypesResponse ${getFeeTypesResponse.toJson()}");
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
  debugPrint("Raising request to createOrUpdateFeeTypes with request ${jsonEncode(createOrUpdateFeeTypesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_FEE_TYPES;

  CreateOrUpdateFeeTypesResponse createOrUpdateFeeTypesResponse = await HttpUtils.post(
    _url,
    createOrUpdateFeeTypesRequest.toJson(),
    CreateOrUpdateFeeTypesResponse.fromJson,
  );

  debugPrint("CreateOrUpdateFeeTypesResponse ${createOrUpdateFeeTypesResponse.toJson()}");
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
  debugPrint("Raising request to getSectionWiseAnnualFees with request ${jsonEncode(getSectionWiseAnnualFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SECTION_WISE_ANNUAL_FEES;

  GetSectionWiseAnnualFeesResponse getSectionWiseAnnualFeesResponse = await HttpUtils.post(
    _url,
    getSectionWiseAnnualFeesRequest.toJson(),
    GetSectionWiseAnnualFeesResponse.fromJson,
  );

  debugPrint("GetSectionWiseAnnualFeesResponse ${getSectionWiseAnnualFeesResponse.toJson()}");
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
  debugPrint("Raising request to createOrUpdateSectionFeeMap with request ${jsonEncode(createOrUpdateSectionFeeMapRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SECTION_WISE_ANNUAL_FEES;

  CreateOrUpdateSectionFeeMapResponse createOrUpdateSectionFeeMapResponse = await HttpUtils.post(
    _url,
    createOrUpdateSectionFeeMapRequest.toJson(),
    CreateOrUpdateSectionFeeMapResponse.fromJson,
  );

  debugPrint("CreateOrUpdateSectionFeeMapResponse ${createOrUpdateSectionFeeMapResponse.toJson()}");
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
  List<int?>? sectionIds;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  GetStudentWiseAnnualFeesRequest({
    this.customFeeTypeId,
    this.feeTypeId,
    this.schoolId,
    this.sectionId,
    this.sectionIds,
    this.studentId,
  });

  GetStudentWiseAnnualFeesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    var v = json['sectionIds']?.toInt();
    final arr0 = <int?>[];
    v.forEach((v) {
      arr0.add(int.tryParse(v));
    });
    sectionIds = arr0;
    studentId = json['studentId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionIds'] = sectionIds;
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

  TextEditingController fareController = TextEditingController();

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
  }) {
    fareController.text = "${(fare ?? 0) / 100}";
  }

  StudentBusFeeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    fare = json['fare']?.toInt();
    fareController.text = "${(fare ?? 0) / 100}";
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
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
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
  String? status;
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
    this.status,
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
    status = json['status']?.toString();
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
    data['status'] = status;
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
  debugPrint("Raising request to getStudentWiseAnnualFees with request ${jsonEncode(getStudentWiseAnnualFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_WISE_ANNUAL_FEES;

  GetStudentWiseAnnualFeesResponse getStudentWiseAnnualFeesResponse = await HttpUtils.post(
    _url,
    getStudentWiseAnnualFeesRequest.toJson(),
    GetStudentWiseAnnualFeesResponse.fromJson,
  );

  debugPrint("GetStudentWiseAnnualFeesResponse ${getStudentWiseAnnualFeesResponse.toJson()}");
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
  List<StudentStopFare?>? studentRouteStopFares;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentAnnualFeeMapRequest({
    this.agent,
    this.schoolId,
    this.studentAnnualFeeMapBeanList,
    this.studentRouteStopFares,
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
    if (json['studentStopFares'] != null) {
      final v = json['studentRouteStopFares'];
      final arr0 = <StudentStopFare>[];
      v.forEach((v) {
        arr0.add(StudentStopFare.fromJson(v));
      });
      studentRouteStopFares = arr0;
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
    if (studentRouteStopFares != null) {
      final v = studentRouteStopFares;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentRouteStopFares'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentStopFare {
  int? studentId;
  int? fare;
  Map<String, dynamic> __origJson = {};

  StudentStopFare({
    this.studentId,
    this.fare,
  });

  StudentStopFare.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    studentId = json['studentId']?.toInt();
    fare = json['fare']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['studentId'] = studentId;
    data['fare'] = fare;
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
  debugPrint("Raising request to createOrUpdateStudentAnnualFeeMap with request ${jsonEncode(createOrUpdateStudentAnnualFeeMapRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_WISE_ANNUAL_FEES;

  CreateOrUpdateStudentAnnualFeeMapResponse createOrUpdateStudentAnnualFeeMapResponse = await HttpUtils.post(
    _url,
    createOrUpdateStudentAnnualFeeMapRequest.toJson(),
    CreateOrUpdateStudentAnnualFeeMapResponse.fromJson,
  );

  debugPrint("CreateOrUpdateStudentAnnualFeeMapResponse ${createOrUpdateStudentAnnualFeeMapResponse.toJson()}");
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
  debugPrint("Raising request to getTerms with request ${jsonEncode(getTermsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TERMS;

  GetTermsResponse getTermsResponse = await HttpUtils.post(
    _url,
    getTermsRequest.toJson(),
    GetTermsResponse.fromJson,
  );

  debugPrint("GetTermsResponse ${getTermsResponse.toJson()}");
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
  debugPrint("Raising request to createOrUpdateTerm with request ${jsonEncode(createOrUpdateTermRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TERM;

  CreateOrUpdateTermResponse createOrUpdateTermResponse = await HttpUtils.post(
    _url,
    createOrUpdateTermRequest.toJson(),
    CreateOrUpdateTermResponse.fromJson,
  );

  debugPrint("CreateOrUpdateTermResponse ${createOrUpdateTermResponse.toJson()}");
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
  debugPrint("Raising request to getSectionWiseTermFees with request ${jsonEncode(getSectionWiseTermFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SECTION_WISE_TERM_FEES;

  GetSectionWiseTermFeesResponse getSectionWiseTermFeesResponse = await HttpUtils.post(
    _url,
    getSectionWiseTermFeesRequest.toJson(),
    GetSectionWiseTermFeesResponse.fromJson,
  );

  debugPrint("GetSectionWiseTermFeesResponse ${getSectionWiseTermFeesResponse.toJson()}");
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
  debugPrint(
      "Raising request to createOrUpdateSectionWiseTermFeeMap with request ${jsonEncode(createOrUpdateSectionWiseTermFeeMapRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_SECTION_WISE_TERM_FEES;

  CreateOrUpdateSectionWiseTermFeeMapResponse createOrUpdateSectionWiseTermFeeMapResponse = await HttpUtils.post(
    _url,
    createOrUpdateSectionWiseTermFeeMapRequest.toJson(),
    CreateOrUpdateSectionWiseTermFeeMapResponse.fromJson,
  );

  debugPrint("CreateOrUpdateSectionWiseTermFeeMapResponse ${createOrUpdateSectionWiseTermFeeMapResponse.toJson()}");
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
  List<StudentWiseTermFeeMapBean?>? studentTermFeeMapBeanList;
  List<StudentWalletTransactionBean?>? studentWalletTransactionBeans;
  Map<String, dynamic> __origJson = {};

  StudentWiseTermFeesBean({
    this.actualFee,
    this.feePaid,
    this.sectionId,
    this.sectionName,
    this.studentId,
    this.studentName,
    this.studentTermFeeMapBeanList,
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
    if (json['studentTermFeeMapBeanList'] != null) {
      final v = json['studentTermFeeMapBeanList'];
      final arr0 = <StudentWiseTermFeeMapBean>[];
      v.forEach((v) {
        arr0.add(StudentWiseTermFeeMapBean.fromJson(v));
      });
      studentTermFeeMapBeanList = arr0;
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
    if (studentTermFeeMapBeanList != null) {
      final v = studentTermFeeMapBeanList;
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
  debugPrint("Raising request to getStudentWiseTermFees with request ${jsonEncode(getStudentWiseTermFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_WISE_TERM_FEES;

  GetStudentWiseTermFeesResponse getStudentWiseTermFeesResponse = await HttpUtils.post(
    _url,
    getStudentWiseTermFeesRequest.toJson(),
    GetStudentWiseTermFeesResponse.fromJson,
  );

  debugPrint("GetStudentWiseTermFeesResponse ${getStudentWiseTermFeesResponse.toJson()}");
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
  String? studentName;
  String? sectionName;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentFeePaidRequest({
    this.agent,
    this.loadWalletAmount,
    this.masterTransactionId,
    this.schoolId,
    this.studentId,
    this.studentTermFeeMapList,
    this.studentName,
    this.sectionName,
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
    studentName = json['studentName']?.toString();
    sectionName = json['sectionName']?.toString();
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
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentTermFeeMapList'] = arr0;
    }
    data['studentName'] = studentName;
    data['sectionName'] = sectionName;
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
  debugPrint("Raising request to createOrUpdateStudentFeePaid with request ${jsonEncode(createOrUpdateStudentFeePaidRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_FEE_PAID;

  CreateOrUpdateStudentFeePaidResponse createOrUpdateStudentFeePaidResponse = await HttpUtils.post(
    _url,
    createOrUpdateStudentFeePaidRequest.toJson(),
    CreateOrUpdateStudentFeePaidResponse.fromJson,
  );

  debugPrint("CreateOrUpdateStudentFeePaidResponse ${createOrUpdateStudentFeePaidResponse.toJson()}");
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
  debugPrint("Raising request to getTransportFeeAssignmentType with request ${jsonEncode(getTransportFeeAssignmentTypeRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TRANSPORT_FEE_ASSIGNMENT_TYPE;

  GetTransportFeeAssignmentTypeResponse getTransportFeeAssignmentTypeResponse = await HttpUtils.post(
    _url,
    getTransportFeeAssignmentTypeRequest.toJson(),
    GetTransportFeeAssignmentTypeResponse.fromJson,
  );

  debugPrint("GetTransportFeeAssignmentTypeResponse ${getTransportFeeAssignmentTypeResponse.toJson()}");
  return getTransportFeeAssignmentTypeResponse;
}

Future<List<int>> detailedFeeReport(GetStudentWiseAnnualFeesRequest getStudentWiseAnnualFeesRequest, FeeReportType feeReportType) async {
  debugPrint("Raising request to getStudentWiseAnnualFees with request ${jsonEncode(getStudentWiseAnnualFeesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + (feeReportType == FeeReportType.detailed ? GET_FEE_DETAILS_REPORT : GET_FEE_SUMMARY_REPORT);
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentWiseAnnualFeesRequest.toJson()),
  );

  List<int> getResponse = response.bodyBytes;
  return getResponse;
}

class GetStudentFeeDetailsRequest {
/*
{
  "customFeeTypeId": 0,
  "feeTypeId": 0,
  "receiptNumbers": [
    0
  ],
  "schoolId": 0,
  "sectionIds": [
    0
  ],
  "studentIds": [
    0
  ],
  "termIds": [
    0
  ]
}
*/

  int? customFeeTypeId;
  int? feeTypeId;
  List<int?>? receiptNumbers;
  int? schoolId;
  List<int?>? sectionIds;
  List<int?>? studentIds;
  List<int?>? termIds;
  Map<String, dynamic> __origJson = {};

  GetStudentFeeDetailsRequest({
    this.customFeeTypeId,
    this.feeTypeId,
    this.receiptNumbers,
    this.schoolId,
    this.sectionIds,
    this.studentIds,
    this.termIds,
  });
  GetStudentFeeDetailsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    if (json['receiptNumbers'] != null) {
      final v = json['receiptNumbers'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      receiptNumbers = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    if (json['sectionIds'] != null) {
      final v = json['sectionIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      sectionIds = arr0;
    }
    if (json['studentIds'] != null) {
      final v = json['studentIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      studentIds = arr0;
    }
    if (json['termIds'] != null) {
      final v = json['termIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      termIds = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    if (receiptNumbers != null) {
      final v = receiptNumbers;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['receiptNumbers'] = arr0;
    }
    data['schoolId'] = schoolId;
    if (sectionIds != null) {
      final v = sectionIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['sectionIds'] = arr0;
    }
    if (studentIds != null) {
      final v = studentIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['studentIds'] = arr0;
    }
    if (termIds != null) {
      final v = termIds;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v);
      }
      data['termIds'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentTermWiseFeeTypeDetailsBean {
/*
{
  "customFeeTypeId": 0,
  "feeTypeId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "termId": 0,
  "termName": "string",
  "termWiseTotalFee": 0,
  "termWiseTotalFeePaid": 0
}
*/

  int? customFeeTypeId;
  int? feeTypeId;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? termId;
  String? termName;
  int? termWiseTotalFee;
  int? termWiseTotalFeePaid;
  Map<String, dynamic> __origJson = {};

  StudentTermWiseFeeTypeDetailsBean({
    this.customFeeTypeId,
    this.feeTypeId,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.termId,
    this.termName,
    this.termWiseTotalFee,
    this.termWiseTotalFeePaid,
  });
  StudentTermWiseFeeTypeDetailsBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    termWiseTotalFee = json['termWiseTotalFee']?.toInt();
    termWiseTotalFeePaid = json['termWiseTotalFeePaid']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['termId'] = termId;
    data['termName'] = termName;
    data['termWiseTotalFee'] = termWiseTotalFee;
    data['termWiseTotalFeePaid'] = termWiseTotalFeePaid;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentWiseFeeTypeDetailsBean {
/*
{
  "annualFee": 0,
  "annualFeePaid": 0,
  "customFeeType": "string",
  "customFeeTypeId": 0,
  "feeType": "string",
  "feeTypeId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "studentTermWiseFeeTypeDetailsList": [
    {
      "customFeeTypeId": 0,
      "feeTypeId": 0,
      "schoolId": 0,
      "sectionId": 0,
      "studentId": 0,
      "termId": 0,
      "termName": "string",
      "termWiseTotalFee": 0,
      "termWiseTotalFeePaid": 0
    }
  ]
}
*/

  int? annualFee;
  int? annualFeePaid;
  String? customFeeType;
  int? customFeeTypeId;
  String? feeType;
  int? feeTypeId;
  int? schoolId;
  int? sectionId;
  int? studentId;
  List<StudentTermWiseFeeTypeDetailsBean?>? studentTermWiseFeeTypeDetailsList;
  Map<String, dynamic> __origJson = {};

  StudentWiseFeeTypeDetailsBean({
    this.annualFee,
    this.annualFeePaid,
    this.customFeeType,
    this.customFeeTypeId,
    this.feeType,
    this.feeTypeId,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.studentTermWiseFeeTypeDetailsList,
  });
  StudentWiseFeeTypeDetailsBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    annualFee = json['annualFee']?.toInt();
    annualFeePaid = json['annualFeePaid']?.toInt();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    if (json['studentTermWiseFeeTypeDetailsList'] != null) {
      final v = json['studentTermWiseFeeTypeDetailsList'];
      final arr0 = <StudentTermWiseFeeTypeDetailsBean>[];
      v.forEach((v) {
        arr0.add(StudentTermWiseFeeTypeDetailsBean.fromJson(v));
      });
      studentTermWiseFeeTypeDetailsList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['annualFee'] = annualFee;
    data['annualFeePaid'] = annualFeePaid;
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    if (studentTermWiseFeeTypeDetailsList != null) {
      final v = studentTermWiseFeeTypeDetailsList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentTermWiseFeeTypeDetailsList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentFeeChildTransactionBean {
/*
{
  "customFeeType": "string",
  "customFeeTypeId": 0,
  "feePaidAmount": 0,
  "feeType": "string",
  "feeTypeId": 0,
  "masterTransactionId": 0,
  "studentId": 0,
  "studentName": "string",
  "transactionDate": "string",
  "transactionId": 0
}
*/

  String? customFeeType;
  int? customFeeTypeId;
  int? feePaidAmount;
  String? feeType;
  int? feeTypeId;
  int? masterTransactionId;
  int? studentId;
  String? studentName;
  String? transactionDate;
  int? transactionId;

  List<TermComponent>? termComponents;
  Map<String, dynamic> __origJson = {};

  StudentFeeChildTransactionBean({
    this.customFeeType,
    this.customFeeTypeId,
    this.feePaidAmount,
    this.feeType,
    this.feeTypeId,
    this.masterTransactionId,
    this.studentId,
    this.studentName,
    this.transactionDate,
    this.transactionId,
    this.termComponents,
  });
  StudentFeeChildTransactionBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feePaidAmount = json['feePaidAmount']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    masterTransactionId = json['masterTransactionId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    transactionDate = json['transactionDate']?.toString();
    transactionId = json['transactionId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feePaidAmount'] = feePaidAmount;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['masterTransactionId'] = masterTransactionId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['transactionDate'] = transactionDate;
    data['transactionId'] = transactionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TermComponent {
  int? termId;
  String? termName;
  int? feePaid;
  int? fee;

  TermComponent(this.termId, this.termName, this.feePaid, this.fee);

  @override
  String toString() {
    return 'TermComponent{termId: $termId, termName: $termName, feePaid: $feePaid, fee: $fee}';
  }
}

class StudentFeeTransactionBean {
/*
{
  "masterTransactionId": 0,
  "studentFeeChildTransactionList": [
    {
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feePaidAmount": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "masterTransactionId": 0,
      "studentId": 0,
      "studentName": "string",
      "transactionDate": "string",
      "transactionId": 0
    }
  ],
  "studentId": 0,
  "studentName": "string",
  "transactionAmount": 0,
  "transactionDate": "string"
}
*/

  int? masterTransactionId;
  List<StudentFeeChildTransactionBean?>? studentFeeChildTransactionList;
  int? studentId;
  String? studentName;
  int? sectionId;
  String? sectionName;
  String? modeOfPayment;
  int? transactionAmount;
  int? receiptId;
  String? transactionDate;
  Map<String, dynamic> __origJson = {};

  StudentFeeTransactionBean({
    this.masterTransactionId,
    this.studentFeeChildTransactionList,
    this.studentId,
    this.studentName,
    this.sectionId,
    this.sectionName,
    this.modeOfPayment,
    this.transactionAmount,
    this.receiptId,
    this.transactionDate,
  });
  StudentFeeTransactionBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    masterTransactionId = json['masterTransactionId']?.toInt();
    if (json['studentFeeChildTransactionList'] != null) {
      final v = json['studentFeeChildTransactionList'];
      final arr0 = <StudentFeeChildTransactionBean>[];
      v.forEach((v) {
        arr0.add(StudentFeeChildTransactionBean.fromJson(v));
      });
      studentFeeChildTransactionList = arr0;
    }
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    modeOfPayment = json['modeOfPayment']?.toString();
    transactionAmount = json['transactionAmount']?.toInt();
    receiptId = json['receiptId']?.toInt();
    transactionDate = json['transactionDate']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['masterTransactionId'] = masterTransactionId;
    if (studentFeeChildTransactionList != null) {
      final v = studentFeeChildTransactionList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentFeeChildTransactionList'] = arr0;
    }
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['modeOfPayment'] = modeOfPayment;
    data['transactionAmount'] = transactionAmount;
    data['receiptId'] = receiptId;
    data['transactionDate'] = transactionDate;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentFeeDetailsBean {
/*
{
  "rollNumber": "string",
  "schoolId": 0,
  "schoolName": "string",
  "sectionId": 0,
  "sectionName": "string",
  "studentFeeTransactionList": [
    {
      "masterTransactionId": 0,
      "studentFeeChildTransactionList": [
        {
          "customFeeType": "string",
          "customFeeTypeId": 0,
          "feePaidAmount": 0,
          "feeType": "string",
          "feeTypeId": 0,
          "masterTransactionId": 0,
          "studentId": 0,
          "studentName": "string",
          "transactionDate": "string",
          "transactionId": 0
        }
      ],
      "studentId": 0,
      "studentName": "string",
      "transactionAmount": 0,
      "transactionDate": "string"
    }
  ],
  "studentId": 0,
  "studentName": "string",
  "studentWiseFeeTypeDetailsList": [
    {
      "annualFee": 0,
      "annualFeePaid": 0,
      "customFeeType": "string",
      "customFeeTypeId": 0,
      "feeType": "string",
      "feeTypeId": 0,
      "schoolId": 0,
      "sectionId": 0,
      "studentId": 0,
      "studentTermWiseFeeTypeDetailsList": [
        {
          "customFeeTypeId": 0,
          "feeTypeId": 0,
          "schoolId": 0,
          "sectionId": 0,
          "studentId": 0,
          "termId": 0,
          "termName": "string",
          "termWiseTotalFee": 0,
          "termWiseTotalFeePaid": 0
        }
      ]
    }
  ],
  "totalAnnualFee": 0,
  "totalFeePaid": 0
}
*/

  String? rollNumber;
  int? schoolId;
  String? schoolName;
  int? sectionId;
  String? sectionName;
  List<StudentFeeTransactionBean?>? studentFeeTransactionList;
  int? studentId;
  String? studentName;
  List<StudentWiseFeeTypeDetailsBean?>? studentWiseFeeTypeDetailsList;
  int? totalAnnualFee;
  int? totalFeePaid;
  int? busFee;
  int? busFeePaid;
  Map<String, dynamic> __origJson = {};

  StudentFeeDetailsBean({
    this.rollNumber,
    this.schoolId,
    this.schoolName,
    this.sectionId,
    this.sectionName,
    this.studentFeeTransactionList,
    this.studentId,
    this.studentName,
    this.studentWiseFeeTypeDetailsList,
    this.totalAnnualFee,
    this.totalFeePaid,
    this.busFee,
    this.busFeePaid,
  });
  StudentFeeDetailsBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    if (json['studentFeeTransactionList'] != null) {
      final v = json['studentFeeTransactionList'];
      final arr0 = <StudentFeeTransactionBean>[];
      v.forEach((v) {
        arr0.add(StudentFeeTransactionBean.fromJson(v));
      });
      studentFeeTransactionList = arr0;
    }
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    if (json['studentWiseFeeTypeDetailsList'] != null) {
      final v = json['studentWiseFeeTypeDetailsList'];
      final arr0 = <StudentWiseFeeTypeDetailsBean>[];
      v.forEach((v) {
        arr0.add(StudentWiseFeeTypeDetailsBean.fromJson(v));
      });
      studentWiseFeeTypeDetailsList = arr0;
    }
    totalAnnualFee = json['totalAnnualFee']?.toInt();
    totalFeePaid = json['totalFeePaid']?.toInt();
    busFee = json['busFee']?.toInt();
    busFeePaid = json['busFeePaid']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    if (studentFeeTransactionList != null) {
      final v = studentFeeTransactionList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentFeeTransactionList'] = arr0;
    }
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    if (studentWiseFeeTypeDetailsList != null) {
      final v = studentWiseFeeTypeDetailsList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentWiseFeeTypeDetailsList'] = arr0;
    }
    data['totalAnnualFee'] = totalAnnualFee;
    data['totalFeePaid'] = totalFeePaid;
    data['busFee'] = busFee;
    data['busFeePaid'] = busFeePaid;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentFeeDetailsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentFeeDetailsBeanList": [
    {
      "rollNumber": "string",
      "schoolId": 0,
      "schoolName": "string",
      "sectionId": 0,
      "sectionName": "string",
      "studentFeeTransactionList": [
        {
          "masterTransactionId": 0,
          "studentFeeChildTransactionList": [
            {
              "customFeeType": "string",
              "customFeeTypeId": 0,
              "feePaidAmount": 0,
              "feeType": "string",
              "feeTypeId": 0,
              "masterTransactionId": 0,
              "studentId": 0,
              "studentName": "string",
              "transactionDate": "string",
              "transactionId": 0
            }
          ],
          "studentId": 0,
          "studentName": "string",
          "transactionAmount": 0,
          "transactionDate": "string"
        }
      ],
      "studentId": 0,
      "studentName": "string",
      "studentWiseFeeTypeDetailsList": [
        {
          "annualFee": 0,
          "annualFeePaid": 0,
          "customFeeType": "string",
          "customFeeTypeId": 0,
          "feeType": "string",
          "feeTypeId": 0,
          "schoolId": 0,
          "sectionId": 0,
          "studentId": 0,
          "studentTermWiseFeeTypeDetailsList": [
            {
              "customFeeTypeId": 0,
              "feeTypeId": 0,
              "schoolId": 0,
              "sectionId": 0,
              "studentId": 0,
              "termId": 0,
              "termName": "string",
              "termWiseTotalFee": 0,
              "termWiseTotalFeePaid": 0
            }
          ]
        }
      ],
      "totalAnnualFee": 0,
      "totalFeePaid": 0
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentFeeDetailsBean?>? studentFeeDetailsBeanList;
  Map<String, dynamic> __origJson = {};

  GetStudentFeeDetailsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentFeeDetailsBeanList,
  });
  GetStudentFeeDetailsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentFeeDetailsBeanList'] != null) {
      final v = json['studentFeeDetailsBeanList'];
      final arr0 = <StudentFeeDetailsBean>[];
      v.forEach((v) {
        arr0.add(StudentFeeDetailsBean.fromJson(v));
      });
      studentFeeDetailsBeanList = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentFeeDetailsBeanList != null) {
      final v = studentFeeDetailsBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentFeeDetailsBeanList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentFeeDetailsResponse> getStudentFeeDetails(GetStudentFeeDetailsRequest getStudentFeeDetailsRequest) async {
  debugPrint("Raising request to getStudentFeeDetails with request ${jsonEncode(getStudentFeeDetailsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_FEE_DETAILS;

  GetStudentFeeDetailsResponse getStudentFeeDetailsResponse = await HttpUtils.post(
    _url,
    getStudentFeeDetailsRequest.toJson(),
    GetStudentFeeDetailsResponse.fromJson,
  );

  debugPrint("GetStudentFeeDetailsResponse ${getStudentFeeDetailsResponse.toJson()}");
  return getStudentFeeDetailsResponse;
}

class NewReceiptBeanSubBean {
/*
{
  "customFeeTypeId": 0,
  "feePaying": 0,
  "feeTypeId": 0,
  "termId": 0
}
*/

  int? customFeeTypeId;
  int? feePaying;
  int? feeTypeId;
  Map<String, dynamic> __origJson = {};

  NewReceiptBeanSubBean({
    this.customFeeTypeId,
    this.feePaying,
    this.feeTypeId,
  });
  NewReceiptBeanSubBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feePaying = json['feePaying']?.toInt();
    feeTypeId = json['feeTypeId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeTypeId'] = customFeeTypeId;
    data['feePaying'] = feePaying;
    data['feeTypeId'] = feeTypeId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class NewReceiptBean {
/*
{
  "agentId": 0,
  "date": 0,
  "receiptNumber": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subBeans": [
    {
      "customFeeTypeId": 0,
      "feePaying": 0,
      "feeTypeId": 0,
      "termId": 0
    }
  ]
}
*/

  int? agentId;
  int? date;
  int? receiptNumber;
  int? schoolId;
  int? sectionId;
  int? studentId;
  List<NewReceiptBeanSubBean?>? subBeans;
  int? busFeePaidAmount;
  String? modeOfPayment;
  Map<String, dynamic> __origJson = {};

  NewReceiptBean({
    this.agentId,
    this.date,
    this.receiptNumber,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subBeans,
    this.busFeePaidAmount,
    this.modeOfPayment,
  });
  NewReceiptBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    date = json['date']?.toInt();
    receiptNumber = json['receiptNumber']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    if (json['subBeans'] != null) {
      final v = json['subBeans'];
      final arr0 = <NewReceiptBeanSubBean>[];
      v.forEach((v) {
        arr0.add(NewReceiptBeanSubBean.fromJson(v));
      });
      subBeans = arr0;
    }
    busFeePaidAmount = json['busFeePaidAmount']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['date'] = date;
    data['receiptNumber'] = receiptNumber;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    if (subBeans != null) {
      final v = subBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['subBeans'] = arr0;
    }
    data['busFeePaidAmount'] = busFeePaidAmount;
    data['modeOfPayment'] = modeOfPayment;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateNewReceiptsRequest {
/*
{
  "newReceiptBean": [
    {
      "agentId": 0,
      "date": 0,
      "receiptNumber": 0,
      "schoolId": 0,
      "sectionId": 0,
      "studentId": 0,
      "subBeans": [
        {
          "customFeeTypeId": 0,
          "feePaying": 0,
          "feeTypeId": 0,
          "termId": 0
        }
      ]
    }
  ]
}
*/

  List<NewReceiptBean?>? newReceiptBeans;
  Map<String, dynamic> __origJson = {};

  CreateNewReceiptsRequest({
    this.newReceiptBeans,
  });
  CreateNewReceiptsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['newReceiptBeans'] != null) {
      final v = json['newReceiptBeans'];
      final arr0 = <NewReceiptBean>[];
      v.forEach((v) {
        arr0.add(NewReceiptBean.fromJson(v));
      });
      newReceiptBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (newReceiptBeans != null) {
      final v = newReceiptBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['newReceiptBeans'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateNewReceiptsResponse {
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

  CreateNewReceiptsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateNewReceiptsResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateNewReceiptsResponse> createNewReceipts(CreateNewReceiptsRequest createNewReceiptsRequest) async {
  debugPrint("Raising request to createNewReceipts with request ${jsonEncode(createNewReceiptsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_NEW_FEE_RECEIPTS;

  CreateNewReceiptsResponse createNewReceiptsResponse = await HttpUtils.post(
    _url,
    createNewReceiptsRequest.toJson(),
    CreateNewReceiptsResponse.fromJson,
  );

  debugPrint("CreateNewReceiptsResponse ${createNewReceiptsResponse.toJson()}");
  return createNewReceiptsResponse;
}

class StudentWiseFeePaidSupportBean {
  int? amount;
  String? customFeeType;
  int? customFeeTypeId;
  int? feePaidId;
  String? feeType;
  int? feeTypeId;
  int? masterTransactionId;
  int? receiptId;
  String? rollNumber;
  int? studentId;
  String? studentName;
  int? termId;
  String? termName;
  String? transactionDate;
  int? transactionId;
  Map<String, dynamic> __origJson = {};

  StudentWiseFeePaidSupportBean({
    this.amount,
    this.customFeeType,
    this.customFeeTypeId,
    this.feePaidId,
    this.feeType,
    this.feeTypeId,
    this.masterTransactionId,
    this.receiptId,
    this.rollNumber,
    this.studentId,
    this.studentName,
    this.termId,
    this.termName,
    this.transactionDate,
    this.transactionId,
  });
  StudentWiseFeePaidSupportBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feePaidId = json['feePaidId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    masterTransactionId = json['masterTransactionId']?.toInt();
    receiptId = json['receiptId']?.toInt();
    rollNumber = json['rollNumber']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    transactionDate = json['transactionDate']?.toString();
    transactionId = json['transactionId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feePaidId'] = feePaidId;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['masterTransactionId'] = masterTransactionId;
    data['receiptId'] = receiptId;
    data['rollNumber'] = rollNumber;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['termId'] = termId;
    data['termName'] = termName;
    data['transactionDate'] = transactionDate;
    data['transactionId'] = transactionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentTermWiseFeeSupportBean {
  String? customFeeType;
  int? customFeeTypeId;
  String? feeType;
  int? feeTypeId;
  String? rollNumber;
  String? schoolDisplayName;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  int? studentId;
  String? studentName;
  String? termEndDate;
  int? termId;
  String? termName;
  String? termStartDate;
  int? termWiseAmount;
  int? termWiseAmountPaid;
  Map<String, dynamic> __origJson = {};

  StudentTermWiseFeeSupportBean({
    this.customFeeType,
    this.customFeeTypeId,
    this.feeType,
    this.feeTypeId,
    this.rollNumber,
    this.schoolDisplayName,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.studentId,
    this.studentName,
    this.termEndDate,
    this.termId,
    this.termName,
    this.termStartDate,
    this.termWiseAmount,
    this.termWiseAmountPaid,
  });
  StudentTermWiseFeeSupportBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    rollNumber = json['rollNumber']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    termEndDate = json['termEndDate']?.toString();
    termId = json['termId']?.toInt();
    termName = json['termName']?.toString();
    termStartDate = json['termStartDate']?.toString();
    termWiseAmount = json['termWiseAmount']?.toInt();
    termWiseAmountPaid = json['termWiseAmountPaid']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customFeeType'] = customFeeType;
    data['customFeeTypeId'] = customFeeTypeId;
    data['feeType'] = feeType;
    data['feeTypeId'] = feeTypeId;
    data['rollNumber'] = rollNumber;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['termEndDate'] = termEndDate;
    data['termId'] = termId;
    data['termName'] = termName;
    data['termStartDate'] = termStartDate;
    data['termWiseAmount'] = termWiseAmount;
    data['termWiseAmountPaid'] = termWiseAmountPaid;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentMasterTransactionSupportBean {
  int? amount;
  String? description;
  int? franchiseId;
  int? parentTransactionId;
  int? receiptId;
  int? schoolId;
  int? studentId;
  String? studentName;
  int? transactionId;
  String? transactionKind;
  String? transactionStatus;
  String? transactionTime;
  String? transactionType;
  String? modeOfPayment;
  Map<String, dynamic> __origJson = {};

  StudentMasterTransactionSupportBean({
    this.amount,
    this.description,
    this.franchiseId,
    this.parentTransactionId,
    this.receiptId,
    this.schoolId,
    this.studentId,
    this.studentName,
    this.transactionId,
    this.transactionKind,
    this.transactionStatus,
    this.transactionTime,
    this.transactionType,
    this.modeOfPayment,
  });
  StudentMasterTransactionSupportBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    description = json['description']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    parentTransactionId = json['parentTransactionId']?.toInt();
    receiptId = json['receiptId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    transactionId = json['transactionId']?.toInt();
    transactionKind = json['transactionKind']?.toString();
    transactionStatus = json['transactionStatus']?.toString();
    transactionTime = json['transactionTime']?.toString();
    transactionType = json['transactionType']?.toString();
    modeOfPayment = json['modeOfPayment']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['description'] = description;
    data['franchiseId'] = franchiseId;
    data['parentTransactionId'] = parentTransactionId;
    data['receiptId'] = receiptId;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['transactionId'] = transactionId;
    data['transactionKind'] = transactionKind;
    data['transactionStatus'] = transactionStatus;
    data['transactionTime'] = transactionTime;
    data['transactionType'] = transactionType;
    data['modeOfPayment'] = modeOfPayment;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentAnnualFeeSupportBean {
  int? amount;
  int? amountPaid;
  String? comments;
  String? customFeeType;
  int? customFeeTypeId;
  String? feeType;
  int? feeTypeId;
  String? rollNumber;
  String? schoolDisplayName;
  int? schoolId;
  int? sectionFeeMapId;
  int? sectionId;
  String? sectionName;
  String? status;
  int? studentFeeMapId;
  int? studentId;
  String? studentName;
  Map<String, dynamic> __origJson = {};

  StudentAnnualFeeSupportBean({
    this.amount,
    this.amountPaid,
    this.comments,
    this.customFeeType,
    this.customFeeTypeId,
    this.feeType,
    this.feeTypeId,
    this.rollNumber,
    this.schoolDisplayName,
    this.schoolId,
    this.sectionFeeMapId,
    this.sectionId,
    this.sectionName,
    this.status,
    this.studentFeeMapId,
    this.studentId,
    this.studentName,
  });
  StudentAnnualFeeSupportBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    amountPaid = json['amountPaid']?.toInt();
    comments = json['comments']?.toString();
    customFeeType = json['customFeeType']?.toString();
    customFeeTypeId = json['customFeeTypeId']?.toInt();
    feeType = json['feeType']?.toString();
    feeTypeId = json['feeTypeId']?.toInt();
    rollNumber = json['rollNumber']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionFeeMapId = json['sectionFeeMapId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    studentFeeMapId = json['studentFeeMapId']?.toInt();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
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
    data['rollNumber'] = rollNumber;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['sectionFeeMapId'] = sectionFeeMapId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['studentFeeMapId'] = studentFeeMapId;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentFeeDetailsSupportClassesResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentAnnualFeeSupportBean?>? studentAnnualFeeBeanBeans;
  List<StudentMasterTransactionSupportBean?>? studentMasterTransactionBeans;
  List<StudentTermWiseFeeSupportBean?>? studentTermWiseFeeBeans;
  List<StudentWiseFeePaidSupportBean?>? studentWiseFeePaidBeans;
  List<StudentBusFeeLogBean?>? busFeeBeans;
  Map<String, dynamic> __origJson = {};

  GetStudentFeeDetailsSupportClassesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentAnnualFeeBeanBeans,
    this.studentMasterTransactionBeans,
    this.studentTermWiseFeeBeans,
    this.studentWiseFeePaidBeans,
    this.busFeeBeans,
  });
  GetStudentFeeDetailsSupportClassesResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentAnnualFeeBeanBeans'] != null) {
      final v = json['studentAnnualFeeBeanBeans'];
      final arr0 = <StudentAnnualFeeSupportBean>[];
      v.forEach((v) {
        arr0.add(StudentAnnualFeeSupportBean.fromJson(v));
      });
      studentAnnualFeeBeanBeans = arr0;
    }
    if (json['studentMasterTransactionBeans'] != null) {
      final v = json['studentMasterTransactionBeans'];
      final arr0 = <StudentMasterTransactionSupportBean>[];
      v.forEach((v) {
        arr0.add(StudentMasterTransactionSupportBean.fromJson(v));
      });
      studentMasterTransactionBeans = arr0;
    }
    if (json['studentTermWiseFeeBeans'] != null) {
      final v = json['studentTermWiseFeeBeans'];
      final arr0 = <StudentTermWiseFeeSupportBean>[];
      v.forEach((v) {
        arr0.add(StudentTermWiseFeeSupportBean.fromJson(v));
      });
      studentTermWiseFeeBeans = arr0;
    }
    if (json['studentWiseFeePaidBeans'] != null) {
      final v = json['studentWiseFeePaidBeans'];
      final arr0 = <StudentWiseFeePaidSupportBean>[];
      v.forEach((v) {
        arr0.add(StudentWiseFeePaidSupportBean.fromJson(v));
      });
      studentWiseFeePaidBeans = arr0;
    }
    if (json['busFeeBeans'] != null) {
      final v = json['busFeeBeans'];
      final arr0 = <StudentBusFeeLogBean>[];
      v.forEach((v) {
        arr0.add(StudentBusFeeLogBean.fromJson(v));
      });
      busFeeBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentAnnualFeeBeanBeans != null) {
      final v = studentAnnualFeeBeanBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentAnnualFeeBeanBeans'] = arr0;
    }
    if (studentMasterTransactionBeans != null) {
      final v = studentMasterTransactionBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentMasterTransactionBeans'] = arr0;
    }
    if (studentTermWiseFeeBeans != null) {
      final v = studentTermWiseFeeBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentTermWiseFeeBeans'] = arr0;
    }
    if (studentWiseFeePaidBeans != null) {
      final v = studentWiseFeePaidBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentWiseFeePaidBeans'] = arr0;
    }
    if (busFeeBeans != null) {
      final v = busFeeBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['busFeeBeans'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentFeeDetailsSupportClassesResponse> getStudentFeeDetailsSupportClasses(GetStudentFeeDetailsRequest getStudentFeeDetailsRequest) async {
  debugPrint("Raising request to getStudentFeeDetails with request ${jsonEncode(getStudentFeeDetailsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_FEE_DETAILS_SUPPORT_CLASSES;

  GetStudentFeeDetailsSupportClassesResponse getStudentFeeDetailsSupportClassesResponse = await HttpUtils.post(
    _url,
    getStudentFeeDetailsRequest.toJson(),
    GetStudentFeeDetailsSupportClassesResponse.fromJson,
  );

  debugPrint("GetStudentFeeDetailsSupportClassesResponse ${getStudentFeeDetailsSupportClassesResponse.toJson()}");
  return getStudentFeeDetailsSupportClassesResponse;
}

class DeleteReceiptRequest {
/*
{
  "agentId": 0,
  "comments": "string",
  "masterTransactionId": 0,
  "schoolId": 0
}
*/

  int? agentId;
  String? comments;
  int? masterTransactionId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  DeleteReceiptRequest({
    this.agentId,
    this.comments,
    this.masterTransactionId,
    this.schoolId,
  });
  DeleteReceiptRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    comments = json['comments']?.toString();
    masterTransactionId = json['masterTransactionId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['comments'] = comments;
    data['masterTransactionId'] = masterTransactionId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DeleteReceiptResponse {
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

  DeleteReceiptResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  DeleteReceiptResponse.fromJson(Map<String, dynamic> json) {
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

Future<DeleteReceiptResponse> deleteReceipt(DeleteReceiptRequest deleteReceiptRequest) async {
  debugPrint("Raising request to deleteReceipt with request ${jsonEncode(deleteReceiptRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + DELETE_FEE_RECEIPT;

  DeleteReceiptResponse deleteReceiptResponse = await HttpUtils.post(
    _url,
    deleteReceiptRequest.toJson(),
    DeleteReceiptResponse.fromJson,
  );

  debugPrint("DeleteReceiptResponse ${deleteReceiptResponse.toJson()}");
  return deleteReceiptResponse;
}

class UpdateReceiptRequest {
/*
{
  "agent": 0,
  "date": "string",
  "receiptId": 0,
  "schoolId": 0,
  "transactionId": 0
}
*/

  int? agent;
  String? date;
  int? receiptId;
  int? schoolId;
  int? transactionId;
  Map<String, dynamic> __origJson = {};

  UpdateReceiptRequest({
    this.agent,
    this.date,
    this.receiptId,
    this.schoolId,
    this.transactionId,
  });
  UpdateReceiptRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    date = json['date']?.toString();
    receiptId = json['receiptId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    transactionId = json['transactionId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['date'] = date;
    data['receiptId'] = receiptId;
    data['schoolId'] = schoolId;
    data['transactionId'] = transactionId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class UpdateReceiptResponse {
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

  UpdateReceiptResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  UpdateReceiptResponse.fromJson(Map<String, dynamic> json) {
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

Future<UpdateReceiptResponse> updateReceipt(UpdateReceiptRequest updateReceiptRequest) async {
  debugPrint("Raising request to updateReceipt with request ${jsonEncode(updateReceiptRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_FEE_RECEIPT;

  UpdateReceiptResponse updateReceiptResponse = await HttpUtils.post(
    _url,
    updateReceiptRequest.toJson(),
    UpdateReceiptResponse.fromJson,
  );

  debugPrint("UpdateReceiptResponse ${updateReceiptResponse.toJson()}");
  return updateReceiptResponse;
}
