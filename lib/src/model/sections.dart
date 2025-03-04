import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSectionsRequest {
/*
{
  "schoolId": 0,
  "sectionId": 0
}
*/

  int? schoolId;
  int? linkedSchoolId;
  int? sectionId;
  int? franchiseId;
  int? academicYearId;
  Map<String, dynamic> __origJson = {};

  GetSectionsRequest({
    this.schoolId,
    this.linkedSchoolId,
    this.sectionId,
    this.franchiseId,
    this.academicYearId,
  });

  GetSectionsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    linkedSchoolId = int.tryParse(json["linkedSchoolId"]?.toString() ?? '');
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    franchiseId = int.tryParse(json["franchiseId"]?.toString() ?? '');
    academicYearId = int.tryParse(json["academicYearId"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["schoolId"] = schoolId;
    data["linkedSchoolId"] = linkedSchoolId;
    data["sectionId"] = sectionId;
    data["franchiseId"] = franchiseId;
    data["academicYearId"] = academicYearId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Section {
/*
{
  "agent": "string",
  "description": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "sectionPhotoUrl": "string",
  "ocrAsPerTt": false
}
*/

  String? agent;
  String? description;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  String? sectionPhotoUrl;
  bool? ocrAsPerTt;
  int? seqOrder;
  int? classTeacherId;
  int? linkedSchoolId;
  Map<String, dynamic> __origJson = {};

  Section({
    this.agent,
    this.description,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.sectionPhotoUrl,
    this.ocrAsPerTt,
    this.seqOrder,
    this.classTeacherId,
    this.linkedSchoolId,
  });

  Section.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json["agent"]?.toString();
    description = json["description"]?.toString();
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    sectionName = json["sectionName"]?.toString();
    sectionPhotoUrl = json["sectionPhotoUrl"]?.toString();
    ocrAsPerTt = json["ocrAsPerTt"] ?? false;
    seqOrder = int.tryParse(json["seqOrder"]?.toString() ?? '');
    classTeacherId = int.tryParse(json["classTeacherId"]?.toString() ?? '');
    linkedSchoolId = int.tryParse(json["linkedSchoolId"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["description"] = description;
    data["schoolId"] = schoolId;
    data["sectionId"] = sectionId;
    data["sectionName"] = sectionName;
    data["sectionPhotoUrl"] = sectionPhotoUrl;
    data["ocrAsPerTt"] = ocrAsPerTt;
    data["seqOrder"] = seqOrder;
    data["classTeacherId"] = classTeacherId;
    data["linkedSchoolId"] = linkedSchoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  int compareTo(other) {
    return toJson().toString().compareTo(other.toJson().toString());
  }

  @override
  String toString() {
    return 'Section{agent: $agent, description: $description, schoolId: $schoolId, sectionId: $sectionId, sectionName: $sectionName, sectionPhotoUrl: $sectionPhotoUrl, ocrAsPerTt: $ocrAsPerTt, seqOrder: $seqOrder, classTeacherId: $classTeacherId, __origJson: $__origJson}';
  }

  @override
  int get hashCode => sectionId ?? 0;

  @override
  bool operator ==(other) {
    return compareTo(other) == 0;
  }
}

class GetSectionsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "sections": [
    {
      "agent": "string",
      "description": "string",
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "sectionPhotoUrl": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<Section?>? sections;
  Map<String, dynamic> __origJson = {};

  GetSectionsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.sections,
  });

  GetSectionsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
    if (json["sections"] != null && (json["sections"] is List)) {
      final v = json["sections"];
      final arr0 = <Section>[];
      v.forEach((v) {
        arr0.add(Section.fromJson(v));
      });
      sections = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    if (sections != null) {
      final v = sections;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["sections"] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSectionsResponse> getSections(GetSectionsRequest getSectionsRequest) async {
  debugPrint("Raising request to getSections with request ${jsonEncode(getSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SECTIONS;

  GetSectionsResponse getSectionsResponse = await HttpUtils.post(
    _url,
    getSectionsRequest.toJson(),
    GetSectionsResponse.fromJson,
  );

  debugPrint("GetSectionsResponse ${getSectionsResponse.toJson()}");
  return getSectionsResponse;
}

class CreateOrUpdateSectionRequest {
/*
{
  "agent": "string",
  "classTeacherId": 0,
  "description": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "ocrAsPerTt": true,
  "schoolId": 0,
  "schoolName": "string",
  "sectionId": 0,
  "sectionName": "string",
  "sectionPhotoUrl": "string",
  "seqOrder": 0
}
*/

  String? agent;
  int? classTeacherId;
  String? description;
  int? franchiseId;
  String? franchiseName;
  bool? ocrAsPerTt;
  int? schoolId;
  String? schoolName;
  int? sectionId;
  String? sectionName;
  String? sectionPhotoUrl;
  int? seqOrder;
  int? linkedSchoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateSectionRequest.fromSection(Section section) {
    agent = section.agent;
    classTeacherId = section.classTeacherId;
    description = section.description;
    ocrAsPerTt = section.ocrAsPerTt;
    schoolId = section.schoolId;
    sectionId = section.sectionId;
    sectionName = section.sectionName;
    sectionPhotoUrl = section.sectionPhotoUrl;
    seqOrder = section.seqOrder;
    linkedSchoolId = section.linkedSchoolId;
  }

  CreateOrUpdateSectionRequest({
    this.agent,
    this.classTeacherId,
    this.description,
    this.franchiseId,
    this.franchiseName,
    this.ocrAsPerTt,
    this.schoolId,
    this.schoolName,
    this.sectionId,
    this.sectionName,
    this.sectionPhotoUrl,
    this.seqOrder,
    this.linkedSchoolId,
  });

  CreateOrUpdateSectionRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    classTeacherId = json['classTeacherId']?.toInt();
    description = json['description']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    ocrAsPerTt = json['ocrAsPerTt'];
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    sectionPhotoUrl = json['sectionPhotoUrl']?.toString();
    seqOrder = json['seqOrder']?.toInt();
    linkedSchoolId = json['linkedSchoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['classTeacherId'] = classTeacherId;
    data['description'] = description;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['ocrAsPerTt'] = ocrAsPerTt;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sectionPhotoUrl'] = sectionPhotoUrl;
    data['seqOrder'] = seqOrder;
    data['linkedSchoolId'] = linkedSchoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSectionResponse {
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

  CreateOrUpdateSectionResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateSectionResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateSectionResponse> createOrUpdateSection(CreateOrUpdateSectionRequest createOrUpdateSectionRequest) async {
  debugPrint("Raising request to createOrUpdateSection with request ${jsonEncode(createOrUpdateSectionRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SECTION;

  CreateOrUpdateSectionResponse createOrUpdateSectionResponse = await HttpUtils.post(
    _url,
    createOrUpdateSectionRequest.toJson(),
    CreateOrUpdateSectionResponse.fromJson,
  );

  debugPrint("CreateOrUpdateSectionResponse ${createOrUpdateSectionResponse.toJson()}");
  return createOrUpdateSectionResponse;
}

class CreateOrUpdateSectionsRequest {
/*
{
  "agentId": 0,
  "schoolId": 0,
  "sectionsList": [
    {
      "agent": "string",
      "classTeacherId": 0,
      "description": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "linkedSchoolId": 0,
      "ocrAsPerTt": true,
      "schoolId": 0,
      "schoolName": "string",
      "sectionId": 0,
      "sectionName": "string",
      "sectionPhotoUrl": "string",
      "seqOrder": 0
    }
  ]
}
*/

  int? agentId;
  int? schoolId;
  List<Section?>? sectionsList;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateSectionsRequest({
    this.agentId,
    this.schoolId,
    this.sectionsList,
  });

  CreateOrUpdateSectionsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    if (json['sectionsList'] != null) {
      final v = json['sectionsList'];
      final arr0 = <Section>[];
      v.forEach((v) {
        arr0.add(Section.fromJson(v));
      });
      sectionsList = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['schoolId'] = schoolId;
    if (sectionsList != null) {
      final v = sectionsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['sectionsList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSectionsResponse {
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

  CreateOrUpdateSectionsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateSectionsResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateSectionsResponse> createOrUpdateSections(CreateOrUpdateSectionsRequest createOrUpdateSectionsRequest) async {
  debugPrint("Raising request to createOrUpdateSections with request ${jsonEncode(createOrUpdateSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SECTIONS;

  CreateOrUpdateSectionsResponse createOrUpdateSectionsResponse = await HttpUtils.post(
    _url,
    createOrUpdateSectionsRequest.toJson(),
    CreateOrUpdateSectionsResponse.fromJson,
  );

  debugPrint("CreateOrUpdateSectionsResponse ${createOrUpdateSectionsResponse.toJson()}");
  return createOrUpdateSectionsResponse;
}
