import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetTeacherDealingSectionsRequest {
  int? schoolId;
  int? teacherId;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? franchiseId;
  int? academicYearId;
  String? status;

  GetTeacherDealingSectionsRequest({
    this.schoolId,
    this.teacherId,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.franchiseId,
    this.status,
    this.academicYearId,
  });

  GetTeacherDealingSectionsRequest.fromJson(Map<String, dynamic> json) {
    schoolId = json['schoolId'];
    teacherId = json['teacherId'];
    sectionId = json['sectionId'];
    subjectId = json['subjectId'];
    tdsId = json['tdsId'];
    franchiseId = json['franchiseId'];
    status = json['status'];
    academicYearId = json['academicYearId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['teacherId'] = teacherId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['franchiseId'] = franchiseId;
    data['status'] = status;
    data['academicYearId'] = academicYearId;
    return data;
  }
}

class GetTeacherDealingSectionsResponse {
  List<TeacherDealingSection>? teacherDealingSections;
  String? responseStatus;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;

  GetTeacherDealingSectionsResponse({teacherDealingSections, responseStatus, errorCode, errorMessage, httpStatus});

  GetTeacherDealingSectionsResponse.fromJson(Map<String, dynamic> json) {
    if (json['teacherDealingSections'] != null) {
      teacherDealingSections = <TeacherDealingSection>[];
      json['teacherDealingSections'].forEach((v) {
        teacherDealingSections!.add(TeacherDealingSection.fromJson(v));
      });
    }
    responseStatus = json['responseStatus'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (teacherDealingSections != null) {
      data['teacherDealingSections'] = teacherDealingSections!.map((v) => v.toJson()).toList();
    }
    data['responseStatus'] = responseStatus;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    return data;
  }
}

Future<GetTeacherDealingSectionsResponse> getTeacherDealingSections(GetTeacherDealingSectionsRequest getTeacherDealingSectionsRequest) async {
  debugPrint("Raising request to getTeacherDealingSections with request ${jsonEncode(getTeacherDealingSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TDS;

  GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await HttpUtils.post(
    _url,
    getTeacherDealingSectionsRequest.toJson(),
    GetTeacherDealingSectionsResponse.fromJson,
  );

  debugPrint("GetTeacherDealingSectionsResponse ${getTeacherDealingSectionsResponse.toJson()}");
  return getTeacherDealingSectionsResponse;
}

class TeacherDealingSection {
/*
{
  "agentId": 0,
  "description": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "status": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  int? agentId;
  String? description;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  String? status;
  String? validFrom;
  String? validThrough;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  int? sectionSeqOrder;
  int? subjectSeqOrder;
  Map<String, dynamic> __origJson = {};

  bool isEdited = false;

  TeacherDealingSection({
    this.agentId,
    this.description,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.status,
    this.validFrom,
    this.validThrough,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
    this.sectionSeqOrder,
    this.subjectSeqOrder,
  });

  TeacherDealingSection.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json['agentId']?.toString() ?? '');
    description = json['description']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    validFrom = json['validFrom']?.toString();
    validThrough = json['validThrough']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    subjectName = json['subjectName']?.toString();
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherName = json['teacherName']?.toString();
    sectionSeqOrder = int.tryParse(json['sectionSeqOrder']?.toString() ?? '');
    subjectSeqOrder = int.tryParse(json['subjectSeqOrder']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['description'] = description;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['validFrom'] = validFrom;
    data['validThrough'] = validThrough;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['sectionSeqOrder'] = sectionSeqOrder;
    data['subjectSeqOrder'] = subjectSeqOrder;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "'agentId': $agentId, 'description': $description, 'schoolId': $schoolId, 'sectionId': $sectionId, 'sectionName': $sectionName, 'status': $status, 'subjectId': $subjectId, 'subjectName': $subjectName, 'tdsId': $tdsId, 'teacherId': $teacherId, 'teacherName': $teacherName, 'isEdited': $isEdited";
  }
}

class CreateOrUpdateTeacherDealingSectionsRequest {
/*
{
  "agentId": 0,
  "schoolId": 0,
  "tdsList": [
    {
      "agentId": 0,
      "description": "string",
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "status": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ]
}
*/

  int? agentId;
  int? schoolId;
  List<TeacherDealingSection?>? tdsList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTeacherDealingSectionsRequest({
    this.agentId,
    this.schoolId,
    this.tdsList,
  });

  CreateOrUpdateTeacherDealingSectionsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json['agentId']?.toString() ?? '');
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    if (json['tdsList'] != null && (json['tdsList'] is List)) {
      final v = json['tdsList'];
      final arr0 = <TeacherDealingSection>[];
      v.forEach((v) {
        arr0.add(TeacherDealingSection.fromJson(v));
      });
      tdsList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['schoolId'] = schoolId;
    if (tdsList != null) {
      final v = tdsList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['tdsList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateTeacherDealingSectionsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  CreateOrUpdateTeacherDealingSectionsResponse({errorCode, errorMessage, httpStatus, responseStatus});

  CreateOrUpdateTeacherDealingSectionsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateTeacherDealingSectionsResponse> createOrUpdateTeacherDealingSections(
    CreateOrUpdateTeacherDealingSectionsRequest createOrUpdateTeacherDealingSectionsRequest) async {
  debugPrint(
      "Raising request to createOrUpdateTeacherDealingSections with request ${jsonEncode(createOrUpdateTeacherDealingSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TEACHER_DEALING_SECTIONS;

  CreateOrUpdateTeacherDealingSectionsResponse createOrUpdateTeacherDealingSectionsResponse = await HttpUtils.post(
    _url,
    createOrUpdateTeacherDealingSectionsRequest.toJson(),
    CreateOrUpdateTeacherDealingSectionsResponse.fromJson,
  );

  debugPrint("createOrUpdateTeacherDealingSectionsResponse ${createOrUpdateTeacherDealingSectionsResponse.toJson()}");
  return createOrUpdateTeacherDealingSectionsResponse;
}
