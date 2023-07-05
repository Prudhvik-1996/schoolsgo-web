import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_comment_bean.dart';
import 'package:schoolsgo_web/src/academic_planner/modal/planner_slots.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

const String _jsonKeyPlannedBeanForTdsTitle = 't';
const String _jsonKeyPlannedBeanForTdsDescription = 'd';
const String _jsonKeyPlannedBeanForTdsNoOfSlots = 'n';
const String _jsonKeyPlannedBeanForTdsApprovalStatus = 'as';
const String _jsonKeyPlannerCommentBean = 'c';

class PlannedBeanForTds {
/*
{
  "title": "Pyth. the.",
  "description": "Intro...",
  "noOfSlots": 15,
  "approvalStatus": "approved",
  "comments": [
    {
      "a": "Prudhvik",
      "c": "Improve this",
      "d": "2023-01-01"
    }
  ]
}
*/

  String? title;
  String? description;
  int? noOfSlots;
  String? approvalStatus;
  List<PlannerCommentBean?>? comments;
  List<PlannerTimeSlot>? plannerSlots;
  final ScrollController slotsController = ScrollController();
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  PlannedBeanForTds({
    this.title,
    this.description,
    this.noOfSlots,
    this.approvalStatus,
    this.plannerSlots,
    this.comments,
  });

  PlannedBeanForTds.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    title = json[_jsonKeyPlannedBeanForTdsTitle]?.toString();
    description = json[_jsonKeyPlannedBeanForTdsDescription]?.toString();
    noOfSlots = json[_jsonKeyPlannedBeanForTdsNoOfSlots]?.toInt();
    approvalStatus = json[_jsonKeyPlannedBeanForTdsApprovalStatus]?.toString();
    if (json[_jsonKeyPlannerCommentBean] != null) {
      final v = json[_jsonKeyPlannerCommentBean];
      final arr0 = <PlannerCommentBean>[];
      v.forEach((v) {
        arr0.add(PlannerCommentBean.fromJson(v));
      });
      comments = arr0;
    }
  }

  get startDate => plannerSlots?.firstOrNull?.date;

  get endDate => plannerSlots?.lastOrNull?.date;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[_jsonKeyPlannedBeanForTdsTitle] = title;
    data[_jsonKeyPlannedBeanForTdsDescription] = description;
    data[_jsonKeyPlannedBeanForTdsNoOfSlots] = noOfSlots;
    data[_jsonKeyPlannedBeanForTdsApprovalStatus] = approvalStatus;
    if (comments != null) {
      final v = comments;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data[_jsonKeyPlannerCommentBean] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetPlannerRequest {
/*
{
  "academicYearId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? academicYearId;
  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetPlannerRequest({
    this.academicYearId,
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });

  GetPlannerRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class PlannerBean {
/*
{
  "plannerBeanJsonString": "string",
  "sectionId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  String? plannerBeanJsonString;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  PlannerBean({
    this.plannerBeanJsonString,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });

  PlannerBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    plannerBeanJsonString = json['plannerBeanJsonString']?.toString();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['plannerBeanJsonString'] = plannerBeanJsonString;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetPlannerResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "plannerBeans": [
    {
      "plannerBeanJsonString": "string",
      "sectionId": 0,
      "subjectId": 0,
      "tdsId": 0,
      "teacherId": 0
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<PlannerBean?>? plannerBeans;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetPlannerResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.plannerBeans,
    this.responseStatus,
  });

  GetPlannerResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['plannerBeans'] != null) {
      final v = json['plannerBeans'];
      final arr0 = <PlannerBean>[];
      v.forEach((v) {
        arr0.add(PlannerBean.fromJson(v));
      });
      plannerBeans = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (plannerBeans != null) {
      final v = plannerBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['plannerBeans'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetPlannerResponse> getPlanner(GetPlannerRequest getPlannerRequest) async {
  debugPrint("Raising request to getPlanner with request ${jsonEncode(getPlannerRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ACADEMIC_PLANNER;

  GetPlannerResponse getPlannerResponse = await HttpUtils.post(
    _url,
    getPlannerRequest.toJson(),
    GetPlannerResponse.fromJson,
  );

  debugPrint("GetPlannerResponse ${getPlannerResponse.toJson()}");
  return getPlannerResponse;
}

class CreateOrUpdatePlannerRequest {
/*
{
  "agent": 0,
  "plannerBeanJsonString": "string",
  "schoolId": 0,
  "sectionId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? agent;
  String? plannerBeanJsonString;
  int? schoolId;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdatePlannerRequest({
    this.agent,
    this.plannerBeanJsonString,
    this.schoolId,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });

  CreateOrUpdatePlannerRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    plannerBeanJsonString = json['plannerBeanJsonString']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['plannerBeanJsonString'] = plannerBeanJsonString;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdatePlannerResponse {
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

  CreateOrUpdatePlannerResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdatePlannerResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdatePlannerResponse> createOrUpdatePlanner(CreateOrUpdatePlannerRequest createOrUpdatePlannerRequest) async {
  debugPrint("Raising request to createOrUpdatePlanner with request ${jsonEncode(createOrUpdatePlannerRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_ACADEMIC_PLANNER;

  CreateOrUpdatePlannerResponse createOrUpdatePlannerResponse = await HttpUtils.post(
    _url,
    createOrUpdatePlannerRequest.toJson(),
    CreateOrUpdatePlannerResponse.fromJson,
  );

  debugPrint("createOrUpdatePlannerResponse ${createOrUpdatePlannerResponse.toJson()}");
  return createOrUpdatePlannerResponse;
}
