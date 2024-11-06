import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/exams/custom_exams/model/custom_exams.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class PopulateInternalExamMarksRequest {
/*
{
  "agent": 127,
  "computingStrategy": "A",
  "internalExamId": 214,
  "masterExamId": 212,
  "otherExamIds": [
    199
  ],
  "roundingStrategy": "null",
  "schoolId": 126,
  "sectionId": 705
}
*/

  int? agent;
  String? computingStrategy;
  int? internalExamId;
  int? masterExamId;
  List<int?>? otherExamIds;
  String? roundingStrategy;
  int? schoolId;
  int? sectionId;

  PopulateInternalExamMarksRequest({
    this.agent,
    this.computingStrategy,
    this.internalExamId,
    this.masterExamId,
    this.otherExamIds,
    this.roundingStrategy,
    this.schoolId,
    this.sectionId,
  });
  PopulateInternalExamMarksRequest.fromJson(Map<String, dynamic> json) {
    agent = json['agent']?.toInt();
    computingStrategy = json['computingStrategy']?.toString();
    internalExamId = json['internalExamId']?.toInt();
    masterExamId = json['masterExamId']?.toInt();
    if (json['otherExamIds'] != null) {
      final v = json['otherExamIds'];
      final arr0 = <int>[];
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      otherExamIds = arr0;
    }
    roundingStrategy = json['roundingStrategy']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['computingStrategy'] = computingStrategy;
    data['internalExamId'] = internalExamId;
    data['masterExamId'] = masterExamId;
    if (otherExamIds != null) {
      final v = otherExamIds;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data['otherExamIds'] = arr0;
    }
    data['roundingStrategy'] = roundingStrategy;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    return data;
  }
}

Future<GetCustomExamsResponse> populateExamMarksAsPerOtherExams(PopulateInternalExamMarksRequest populateInternalExamMarksRequest) async {
  debugPrint("Raising request to getCustomExams with request ${jsonEncode(populateInternalExamMarksRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + POPULATE_INTERNAL_EXAM_MARKS;

  GetCustomExamsResponse getCustomExamsResponse = await HttpUtils.post(
    _url,
    populateInternalExamMarksRequest.toJson(),
    GetCustomExamsResponse.fromJson,
  );

  debugPrint("GetCustomExamsResponse ${getCustomExamsResponse.toJson()}");
  return getCustomExamsResponse;
}