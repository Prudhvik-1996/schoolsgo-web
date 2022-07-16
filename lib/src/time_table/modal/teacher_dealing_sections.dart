import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetTeacherDealingSectionsRequest {
  int? schoolId;
  int? teacherId;
  int? sectionId;
  int? subjectId;
  int? tdsId;
  int? franchiseId;
  String? status;

  GetTeacherDealingSectionsRequest({
    this.schoolId,
    this.teacherId,
    this.sectionId,
    this.subjectId,
    this.tdsId,
    this.franchiseId,
    this.status,
  });

  GetTeacherDealingSectionsRequest.fromJson(Map<String, dynamic> json) {
    schoolId = json['schoolId'];
    teacherId = json['teacherId'];
    sectionId = json['sectionId'];
    subjectId = json['subjectId'];
    tdsId = json['tdsId'];
    franchiseId = json['franchiseId'];
    status = json['status'];
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
  print("Raising request to getTeacherDealingSections with request ${jsonEncode(getTeacherDealingSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TDS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getTeacherDealingSectionsRequest.toJson()),
  );

  GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = GetTeacherDealingSectionsResponse.fromJson(json.decode(response.body));
  print("GetTeacherDealingSectionsResponse ${getTeacherDealingSectionsResponse.toJson()}");
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
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  Map<String, dynamic> __origJson = {};

  bool isEdited = false;

  TeacherDealingSection({
    this.agentId,
    this.description,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.status,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
  });
  TeacherDealingSection.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = int.tryParse(json['agentId']?.toString() ?? '');
    description = json['description']?.toString();
    schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
    sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    subjectId = int.tryParse(json['subjectId']?.toString() ?? '');
    subjectName = json['subjectName']?.toString();
    tdsId = int.tryParse(json['tdsId']?.toString() ?? '');
    teacherId = int.tryParse(json['teacherId']?.toString() ?? '');
    teacherName = json['teacherName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['description'] = description;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
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
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
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
  print("Raising request to createOrUpdateTeacherDealingSections with request ${jsonEncode(createOrUpdateTeacherDealingSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TEACHER_DEALING_SECTIONS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateTeacherDealingSectionsRequest.toJson()),
  );

  CreateOrUpdateTeacherDealingSectionsResponse createOrUpdateTeacherDealingSectionsResponse =
      CreateOrUpdateTeacherDealingSectionsResponse.fromJson(json.decode(response.body));
  print("createOrUpdateTeacherDealingSectionsResponse ${createOrUpdateTeacherDealingSectionsResponse.toJson()}");
  return createOrUpdateTeacherDealingSectionsResponse;
}
