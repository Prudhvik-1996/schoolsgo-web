import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSubjectsRequest {
/*
{
  "schoolId": 0,
  "subjectId": 0
}
*/

  int? schoolId;
  int? subjectId;
  Map<String, dynamic> __origJson = {};

  GetSubjectsRequest({
    this.schoolId,
    this.subjectId,
  });

  GetSubjectsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["schoolId"] = schoolId;
    data["subjectId"] = subjectId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Subject {
/*
{
  "subjectId": 0,
  "schoolId": 0,
  "subjectName": "",
  "description": "",
  "agent": ""
}
*/

  int? subjectId;
  int? schoolId;
  String? subjectName;
  String? description;
  int? seqOrder;
  String? agent;
  Map<String, dynamic> __origJson = {};

  Subject({
    this.subjectId,
    this.schoolId,
    this.subjectName,
    this.description,
    this.seqOrder,
    this.agent,
  });

  Subject.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    subjectId = int.tryParse(json["subjectId"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    subjectName = json["subjectName"]?.toString();
    description = json["description"]?.toString();
    seqOrder = int.tryParse(json["seqOrder"]?.toString() ?? '');
    agent = json["agent"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["subjectId"] = subjectId;
    data["schoolId"] = schoolId;
    data["subjectName"] = subjectName;
    data["description"] = description;
    data["seqOrder"] = seqOrder;
    data["agent"] = agent;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  int compareTo(other) {
    return subjectId!.compareTo(other.subjectId);
  }

  @override
  int get hashCode => subjectId ?? 0;

  @override
  bool operator ==(other) {
    return compareTo(other) == 0;
  }

  @override
  String toString() {
    return "Subject: {'subjectId': $subjectId, 'subjectName: $subjectName}";
  }
}

class GetSubjectsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "subjects": [
    {
      "subjectId": 0,
      "schoolId": 0,
      "subjectName": "",
      "description": "",
      "agent": ""
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<Subject?>? subjects;
  Map<String, dynamic> __origJson = {};

  GetSubjectsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.subjects,
  });

  GetSubjectsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
    if (json["subjects"] != null && (json["subjects"] is List)) {
      final v = json["subjects"];
      final arr0 = <Subject>[];
      v.forEach((v) {
        arr0.add(Subject.fromJson(v));
      });
      subjects = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    if (subjects != null) {
      final v = subjects;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["subjects"] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSubjectsResponse> getSubjects(GetSubjectsRequest getSubjectsRequest) async {
  debugPrint("Raising request to getSubjects with request ${jsonEncode(getSubjectsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SUBJECTS;

  GetSubjectsResponse getSubjectsResponse = await HttpUtils.post(
    _url,
    getSubjectsRequest.toJson(),
    GetSubjectsResponse.fromJson,
  );

  debugPrint("GetSubjectsResponse ${getSubjectsResponse.toJson()}");
  return getSubjectsResponse;
}
