import 'dart:convert';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSchoolMetadataRequest {
  int? schoolId;
  String? schoolMetadataKey; // assuming it's an enum/string in backend

  Map<String, dynamic> __origJson = {};

  GetSchoolMetadataRequest({
    this.schoolId,
    this.schoolMetadataKey,
  });

  GetSchoolMetadataRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
    schoolMetadataKey = json['schoolMetadataKey']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['schoolMetadataKey'] = schoolMetadataKey;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SchoolMetadataBean {
  int? id;
  int? schoolId;
  String? metadataKey;
  String? metadataValue;
  int? agent;
  String? status;
  String? createTime;
  String? isDefault;

  SchoolMetadataBean({
    this.id,
    this.schoolId,
    this.metadataKey,
    this.metadataValue,
    this.agent,
    this.status,
    this.createTime,
    this.isDefault,
  });

  SchoolMetadataBean.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();
    schoolId = json['schoolId']?.toInt();
    metadataKey = json['metadataKey']?.toString();
    metadataValue = json['metadataValue']?.toString();
    agent = json['agent']?.toInt();
    status = json['status']?.toString();
    createTime = json['createTime']?.toString();
    isDefault = json['isDefault']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['schoolId'] = schoolId;
    data['metadataKey'] = metadataKey;
    data['metadataValue'] = metadataValue;
    data['agent'] = agent;
    data['status'] = status;
    data['createTime'] = createTime;
    data['isDefault'] = isDefault;
    return data;
  }
}

class GetSchoolMetadataResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  int? schoolId;
  String? schoolMetadataKey;
  List<SchoolMetadataBean>? schoolMetadataBeans;

  Map<String, dynamic> __origJson = {};

  GetSchoolMetadataResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.schoolId,
    this.schoolMetadataKey,
    this.schoolMetadataBeans,
  });

  GetSchoolMetadataResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolMetadataKey = json['schoolMetadataKey']?.toString();

    if (json['schoolMetadataBeans'] != null) {
      schoolMetadataBeans = List<SchoolMetadataBean>.from(
        json['schoolMetadataBeans'].map((x) => SchoolMetadataBean.fromJson(x)),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['schoolId'] = schoolId;
    data['schoolMetadataKey'] = schoolMetadataKey;
    if (schoolMetadataBeans != null) {
      data['schoolMetadataBeans'] = schoolMetadataBeans!.map((e) => e.toJson()).toList();
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSchoolMetadataResponse> getSchoolMetadata(GetSchoolMetadataRequest request) async {
  debugPrint("Calling getSchoolMetadata API with ${jsonEncode(request.toJson())}");

  String _url = SCHOOLS_GO_BASE_URL +
      GET_SCHOOL_METADATA.replaceAll("{schoolId}", request.schoolId?.toString() ?? "").replaceAll("{key}", request.schoolMetadataKey ?? "");

  GetSchoolMetadataResponse response = await HttpUtils.get(
    _url,
    GetSchoolMetadataResponse.fromJson,
  );

  return response;
}

Future<String?> getSchoolDefaultFeeReceiptHeader(int? schoolId) async {
  debugPrint("Calling getSchoolDefaultFeeHeader API with $schoolId");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOL_DEFAULT_FEE_RECEIPT_HEADER.replaceAll("{schoolId}", schoolId?.toString() ?? "");
  return await HttpUtils.getForString(_url);
}

Future<String?> getSchoolDefaultMemoHeader(int? schoolId) async {
  debugPrint("Calling getSchoolDefaultMemoHeader API with $schoolId");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOL_DEFAULT_MEMO_HEADER.replaceAll("{schoolId}", schoolId?.toString() ?? "");
  return await HttpUtils.getForString(_url);
}

Future<String?> getDefaultPrincipalSignature(int? schoolId) async {
  debugPrint("Calling getDefaultPrincipalSignature API with $schoolId");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOL_DEFAULT_PRINCIPAL_SIGNATURE.replaceAll("{schoolId}", schoolId?.toString() ?? "");
  return await HttpUtils.getForString(_url);
}
