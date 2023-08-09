import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetMarkingAlgorithmsRequest {
/*
{
  "markingAlgorithmId": 0,
  "schoolId": 0
}
*/

  int? markingAlgorithmId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetMarkingAlgorithmsRequest({
    this.markingAlgorithmId,
    this.schoolId,
  });

  GetMarkingAlgorithmsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class MarkingAlgorithmRangeBean {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "endRange": 0,
  "gpa": 0,
  "grade": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeId": 0,
  "schoolId": 0,
  "schoolName": "string",
  "startRange": 0,
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  int? endRange;
  TextEditingController endRangeController = TextEditingController();
  double? gpa;
  TextEditingController gpaController = TextEditingController();
  String? grade;
  TextEditingController gradeController = TextEditingController();
  int? markingAlgorithmId;
  int? markingAlgorithmRangeId;
  int? schoolId;
  String? schoolName;
  int? startRange;
  TextEditingController startRangeController = TextEditingController();
  String? status;
  Map<String, dynamic> __origJson = {};

  MarkingAlgorithmRangeBean({
    this.agent,
    this.algorithmName,
    this.endRange,
    this.gpa,
    this.grade,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeId,
    this.schoolId,
    this.schoolName,
    this.startRange,
    this.status,
  }) {
    endRangeController.text = '${endRange ?? ''}';
    startRangeController.text = '${startRange ?? ''}';
    gpaController.text = '${gpa ?? ""}';
    gradeController.text = grade ?? "";
  }

  MarkingAlgorithmRangeBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    endRange = json['endRange']?.toInt();
    endRangeController.text = '${endRange ?? ''}';
    gpa = json['gpa']?.toInt();
    gpaController.text = '${gpa ?? ""}';
    grade = json['grade']?.toString();
    gradeController.text = grade ?? "";
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmRangeId = json['markingAlgorithmRangeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    startRange = json['startRange']?.toInt();
    startRangeController.text = '${startRange ?? ''}';
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['endRange'] = endRange;
    data['gpa'] = gpa;
    data['grade'] = grade;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmRangeId'] = markingAlgorithmRangeId;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['startRange'] = startRange;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class MarkingAlgorithmBean {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeBeanList": [
    {
      "agent": 0,
      "algorithmName": "string",
      "endRange": 0,
      "gpa": 0,
      "grade": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "startRange": 0,
      "status": "active"
    }
  ],
  "schoolId": 0,
  "schoolName": "string",
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  TextEditingController algorithmNameController = TextEditingController();
  int? markingAlgorithmId;
  List<MarkingAlgorithmRangeBean?>? markingAlgorithmRangeBeanList;
  int? schoolId;
  String? schoolName;
  String? status;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  MarkingAlgorithmBean({
    this.agent,
    this.algorithmName,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeBeanList,
    this.schoolId,
    this.schoolName,
    this.status,
  }) {
    algorithmNameController.text = algorithmName ?? "";
  }

  MarkingAlgorithmBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    algorithmNameController.text = algorithmName ?? "";
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    if (json['markingAlgorithmRangeBeanList'] != null) {
      final v = json['markingAlgorithmRangeBeanList'];
      final arr0 = <MarkingAlgorithmRangeBean>[];
      v.forEach((v) {
        arr0.add(MarkingAlgorithmRangeBean.fromJson(v));
      });
      markingAlgorithmRangeBeanList = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['markingAlgorithmId'] = markingAlgorithmId;
    if (markingAlgorithmRangeBeanList != null) {
      final v = markingAlgorithmRangeBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmRangeBeanList'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  bool get isGpaAllowed => (markingAlgorithmRangeBeanList ?? []).map((e) => (e?.gpa ?? 0) != 0).contains(true);

  bool get isGradeAllowed => (markingAlgorithmRangeBeanList ?? []).map((e) => (e?.grade ?? "") != "").contains(true);

  double? gpaForPercentage(double percentage) {
    try {
      return (markingAlgorithmRangeBeanList ?? [])
          .whereNotNull()
          .where((e) => e.startRange! >= percentage.ceil() && percentage.ceil() <= e.endRange!)
          .firstOrNull
          ?.gpa;
    } catch (_) {
      debugPrint("Something went wrong..");
      return null;
    }
  }

  String? gradeForPercentage(double percentage) {
    try {
      return (markingAlgorithmRangeBeanList ?? [])
          .whereNotNull()
          .where((e) => e.startRange! >= percentage.ceil() && percentage.ceil() <= e.endRange!)
          .firstOrNull
          ?.grade;
    } catch (_) {
      debugPrint("Something went wrong..");
      return null;
    }
  }
}

class GetMarkingAlgorithmsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "markingAlgorithmBeanList": [
    {
      "agent": 0,
      "algorithmName": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeBeanList": [
        {
          "agent": 0,
          "algorithmName": "string",
          "endRange": 0,
          "gpa": 0,
          "grade": "string",
          "markingAlgorithmId": 0,
          "markingAlgorithmRangeId": 0,
          "schoolId": 0,
          "schoolName": "string",
          "startRange": 0,
          "status": "active"
        }
      ],
      "schoolId": 0,
      "schoolName": "string",
      "status": "active"
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<MarkingAlgorithmBean?>? markingAlgorithmBeanList;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetMarkingAlgorithmsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.markingAlgorithmBeanList,
    this.responseStatus,
  });

  GetMarkingAlgorithmsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['markingAlgorithmBeanList'] != null) {
      final v = json['markingAlgorithmBeanList'];
      final arr0 = <MarkingAlgorithmBean>[];
      v.forEach((v) {
        arr0.add(MarkingAlgorithmBean.fromJson(v));
      });
      markingAlgorithmBeanList = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (markingAlgorithmBeanList != null) {
      final v = markingAlgorithmBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmBeanList'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetMarkingAlgorithmsResponse> getMarkingAlgorithms(GetMarkingAlgorithmsRequest getMarkingAlgorithmsRequest) async {
  debugPrint("Raising request to getMarkingAlgorithms with request ${jsonEncode(getMarkingAlgorithmsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_MARKING_ALGORITHMS;

  GetMarkingAlgorithmsResponse getMarkingAlgorithmsResponse = await HttpUtils.post(
    _url,
    getMarkingAlgorithmsRequest.toJson(),
    GetMarkingAlgorithmsResponse.fromJson,
  );

  debugPrint("GetMarkingAlgorithmsResponse ${getMarkingAlgorithmsResponse.toJson()}");
  return getMarkingAlgorithmsResponse;
}

class CreateOrUpdateMarkingAlgorithmRequest {
/*
{
  "agent": 0,
  "algorithmName": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeBeanList": [
    {
      "agent": 0,
      "algorithmName": "string",
      "endRange": 0,
      "gpa": 0,
      "grade": "string",
      "markingAlgorithmId": 0,
      "markingAlgorithmRangeId": 0,
      "schoolId": 0,
      "schoolName": "string",
      "startRange": 0,
      "status": "active"
    }
  ],
  "schoolId": 0,
  "schoolName": "string",
  "status": "active"
}
*/

  int? agent;
  String? algorithmName;
  int? markingAlgorithmId;
  List<MarkingAlgorithmRangeBean?>? markingAlgorithmRangeBeanList;
  int? schoolId;
  String? schoolName;
  String? status;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateMarkingAlgorithmRequest({
    this.agent,
    this.algorithmName,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeBeanList,
    this.schoolId,
    this.schoolName,
    this.status,
  });

  CreateOrUpdateMarkingAlgorithmRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    algorithmName = json['algorithmName']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    if (json['markingAlgorithmRangeBeanList'] != null) {
      final v = json['markingAlgorithmRangeBeanList'];
      final arr0 = <MarkingAlgorithmRangeBean>[];
      v.forEach((v) {
        arr0.add(MarkingAlgorithmRangeBean.fromJson(v));
      });
      markingAlgorithmRangeBeanList = arr0;
    }
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['algorithmName'] = algorithmName;
    data['markingAlgorithmId'] = markingAlgorithmId;
    if (markingAlgorithmRangeBeanList != null) {
      final v = markingAlgorithmRangeBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['markingAlgorithmRangeBeanList'] = arr0;
    }
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateMarkingAlgorithmResponse {
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

  CreateOrUpdateMarkingAlgorithmResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateMarkingAlgorithmResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateMarkingAlgorithmResponse> createOrUpdateMarkingAlgorithm(
    CreateOrUpdateMarkingAlgorithmRequest createOrUpdateMarkingAlgorithmRequest) async {
  debugPrint("Raising request to createOrUpdateMarkingAlgorithm with request ${jsonEncode(createOrUpdateMarkingAlgorithmRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_MARKING_ALGORITHM;

  CreateOrUpdateMarkingAlgorithmResponse createOrUpdateMarkingAlgorithmResponse = await HttpUtils.post(
    _url,
    createOrUpdateMarkingAlgorithmRequest.toJson(),
    CreateOrUpdateMarkingAlgorithmResponse.fromJson,
  );

  debugPrint("createOrUpdateMarkingAlgorithmResponse ${createOrUpdateMarkingAlgorithmResponse.toJson()}");
  return createOrUpdateMarkingAlgorithmResponse;
}
