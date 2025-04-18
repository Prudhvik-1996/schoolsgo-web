import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class GetTeachersRequest {
/*
{
  "schoolId": 0,
  "teacherId": 0
}
*/

  int? schoolId;
  int? teacherId;
  int? franchiseId;
  int? academicYearId;
  Map<String, dynamic> __origJson = {};

  GetTeachersRequest({
    this.schoolId,
    this.teacherId,
    this.franchiseId,
    this.academicYearId,
  });

  GetTeachersRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    teacherId = int.tryParse(json["teacherId"]?.toString() ?? '');
    franchiseId = int.tryParse(json["franchiseId"]?.toString() ?? '');
    academicYearId = int.tryParse(json["academicYearId"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["schoolId"] = schoolId;
    data["teacherId"] = teacherId;
    data["franchiseId"] = franchiseId;
    data["academicYearId"] = academicYearId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetTeachersResponse {
  String? responseStatus;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<Teacher>? teachers;

  GetTeachersResponse({
    this.responseStatus,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.teachers,
  });

  GetTeachersResponse.fromJson(Map<String, dynamic> json) {
    responseStatus = json['responseStatus'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    if (json['teachers'] != null) {
      teachers = <Teacher>[];
      json['teachers'].forEach((v) {
        teachers!.add(Teacher.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseStatus'] = responseStatus;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (teachers != null) {
      data['teachers'] = teachers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Teacher {
  int? teacherId;
  int? schoolId;
  String? teacherName;
  String? teacherPhotoUrl;
  String? description;
  String? agent;

  Teacher({
    this.teacherId,
    this.schoolId,
    this.teacherName,
    this.teacherPhotoUrl,
    this.description,
    this.agent,
  });

  Teacher.fromJson(Map<String, dynamic> json) {
    teacherId = json['teacherId'];
    schoolId = json['schoolId'];
    teacherName = json['teacherName'];
    teacherPhotoUrl = json['teacherPhotoUrl'];
    description = json['description'];
    agent = json['agent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['teacherId'] = teacherId;
    data['schoolId'] = schoolId;
    data['teacherName'] = teacherName;
    data['teacherPhotoUrl'] = teacherPhotoUrl;
    data['description'] = description;
    data['agent'] = agent;
    return data;
  }

  @override
  String toString() {
    return "Teacher {'teacherId': $teacherId, 'schoolId': $schoolId, 'teacherName': $teacherName, 'teacherPhotoUrl': $teacherPhotoUrl, 'description': $description, 'agent': $agent}";
  }

  int compareTo(other) {
    return (teacherId == null || other.teacherId == null) ? 0 : teacherId!.compareTo(other.teacherId!);
  }

  @override
  int get hashCode => teacherId ?? 0;

  @override
  bool operator ==(other) {
    return compareTo(other) == 0;
  }
}

Future<GetTeachersResponse> getTeachers(GetTeachersRequest getTeachersRequest) async {
  debugPrint("Raising request to getTeachers with request ${jsonEncode(getTeachersRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TEACHERS;

  GetTeachersResponse getTeachersResponse = await HttpUtils.post(
    _url,
    getTeachersRequest.toJson(),
    GetTeachersResponse.fromJson,
  );

  debugPrint("GetTeachersResponse ${getTeachersResponse.toJson()}");
  return getTeachersResponse;
}
