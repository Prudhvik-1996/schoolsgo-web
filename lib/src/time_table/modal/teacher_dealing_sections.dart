import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetTeacherDealingSectionsRequest {
  int? schoolId;
  int? teacherId;
  int? sectionId;
  int? subjectId;
  int? tdsId;

  GetTeacherDealingSectionsRequest(
      {schoolId, teacherId, sectionId, subjectId, tdsId});

  GetTeacherDealingSectionsRequest.fromJson(Map<String, dynamic> json) {
    schoolId = json['schoolId'];
    teacherId = json['teacherId'];
    sectionId = json['sectionId'];
    subjectId = json['subjectId'];
    tdsId = json['tdsId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['teacherId'] = teacherId;
    data['sectionId'] = sectionId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    return data;
  }
}

class GetTeacherDealingSectionsResponse {
  List<TeacherDealingSection>? teacherDealingSections;
  String? responseStatus;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;

  GetTeacherDealingSectionsResponse(
      {teacherDealingSections,
      responseStatus,
      errorCode,
      errorMessage,
      httpStatus});

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
      data['teacherDealingSections'] =
          teacherDealingSections!.map((v) => v.toJson()).toList();
    }
    data['responseStatus'] = responseStatus;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    return data;
  }
}

Future<GetTeacherDealingSectionsResponse> getTeacherDealingSections(
    GetTeacherDealingSectionsRequest getTeacherDealingSectionsRequest) async {
  print(
      "Raising request to getTeacherDealingSections with request ${jsonEncode(getTeacherDealingSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TDS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getTeacherDealingSectionsRequest.toJson()),
  );

  GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse =
      GetTeacherDealingSectionsResponse.fromJson(json.decode(response.body));
  print(
      "GetTeacherDealingSectionsResponse ${getTeacherDealingSectionsResponse.toJson()}");
  return getTeacherDealingSectionsResponse;
}

class CreateOrUpdateTeacherDealingSectionsRequest {
  int? agentId;
  int? schoolId;
  List<TeacherDealingSection>? tdsList;

  CreateOrUpdateTeacherDealingSectionsRequest({agentId, schoolId, tdsList});

  CreateOrUpdateTeacherDealingSectionsRequest.fromJson(
      Map<String, dynamic> json) {
    agentId = json['agentId'];
    schoolId = json['schoolId'];
    if (json['tdsList'] != null) {
      tdsList = <TeacherDealingSection>[];
      json['tdsList'].forEach((v) {
        tdsList!.add(TeacherDealingSection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['schoolId'] = schoolId;
    if (tdsList != null) {
      data['tdsList'] = tdsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateOrUpdateTeacherDealingSectionsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  CreateOrUpdateTeacherDealingSectionsResponse(
      {errorCode, errorMessage, httpStatus, responseStatus});

  CreateOrUpdateTeacherDealingSectionsResponse.fromJson(
      Map<String, dynamic> json) {
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

Future<CreateOrUpdateTeacherDealingSectionsResponse>
    createOrUpdateTeacherDealingSections(
        CreateOrUpdateTeacherDealingSectionsRequest
            createOrUpdateTeacherDealingSectionsRequest) async {
  print(
      "Raising request to createOrUpdateTeacherDealingSections with request ${jsonEncode(createOrUpdateTeacherDealingSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TEACHER_DEALING_SECTIONS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateTeacherDealingSectionsRequest.toJson()),
  );

  CreateOrUpdateTeacherDealingSectionsResponse
      createOrUpdateTeacherDealingSectionsResponse =
      CreateOrUpdateTeacherDealingSectionsResponse.fromJson(
          json.decode(response.body));
  print(
      "createOrUpdateTeacherDealingSectionsResponse ${createOrUpdateTeacherDealingSectionsResponse.toJson()}");
  return createOrUpdateTeacherDealingSectionsResponse;
}

class TeacherDealingSection {
  int? tdsId;
  int? teacherId;
  String? teacherName;
  int? sectionId;
  String? sectionName;
  int? subjectId;
  String? subjectName;
  int? schoolId;
  int? agentId;
  String? description;
  String? status;
  bool? isEdited;

  TeacherDealingSection(
      {tdsId,
      teacherId,
      teacherName,
      sectionId,
      sectionName,
      subjectId,
      subjectName,
      schoolId,
      agentId,
      description,
      status});

  TeacherDealingSection.fromJson(Map<String, dynamic> json) {
    tdsId = json['tdsId'];
    teacherId = json['teacherId'];
    teacherName = json['teacherName'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    schoolId = json['schoolId'];
    agentId = json['agentId'];
    description = json['description'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['schoolId'] = schoolId;
    data['agentId'] = agentId;
    data['description'] = description;
    data['status'] = status;
    return data;
  }

  @override
  String toString() {
    return "{'tdsId' = $tdsId, 'teacherId' = $teacherId, 'teacherName' = $teacherName, 'sectionId' = $sectionId, 'sectionName' = $sectionName, 'subjectId' = $subjectId, 'subjectName' = $subjectName, 'schoolId' = $schoolId, 'agentId' = $agentId, 'description' = $description, 'status' = $status}";
  }

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode {
    return tdsId != null ? tdsId! : "$teacherId|$sectionId|$subjectId".hashCode;
  }
}
