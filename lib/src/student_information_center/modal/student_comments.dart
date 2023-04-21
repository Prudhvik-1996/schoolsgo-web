import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetStudentCommentsRequest {
/*
{
  "onlyAdmin": true,
  "onlyPTM": true,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0
}
*/

  String? onlyAdmin;
  String? onlyPTM;
  int? schoolId;
  int? sectionId;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  GetStudentCommentsRequest({
    this.onlyAdmin,
    this.onlyPTM,
    this.schoolId,
    this.sectionId,
    this.studentId,
  });
  GetStudentCommentsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    onlyAdmin = json['onlyAdmin']?.toString();
    onlyPTM = json['onlyPTM']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['onlyAdmin'] = onlyAdmin;
    data['onlyPTM'] = onlyPTM;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class StudentCommentBean {
/*
{
  "admin": true,
  "admissionNo": "string",
  "agent": 0,
  "commentId": 0,
  "commentedBy": 0,
  "commenter": "string",
  "date": "string",
  "note": "string",
  "ptm": true,
  "rollNumber": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "status": "active",
  "studentId": 0,
  "studentName": "string"
}
*/

  String? isAdmin;
  String? admissionNo;
  int? agent;
  int? commentId;
  int? commentedBy;
  String? commenter;
  String? date;
  String? note;
  String? isPtm;
  String? rollNumber;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  String? status;
  int? studentId;
  String? studentName;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;
  TextEditingController noteEditingController = TextEditingController();

  StudentCommentBean({
    this.isAdmin,
    this.admissionNo,
    this.agent,
    this.commentId,
    this.commentedBy,
    this.commenter,
    this.date,
    this.note,
    this.isPtm,
    this.rollNumber,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.status,
    this.studentId,
    this.studentName,
  }) {
    noteEditingController.text = note ?? "";
    __origJson = toJson();
  }

  StudentCommentBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    isAdmin = json['isAdmin'];
    admissionNo = json['admissionNo']?.toString();
    agent = json['agent']?.toInt();
    commentId = json['commentId']?.toInt();
    commentedBy = json['commentedBy']?.toInt();
    commenter = json['commenter']?.toString();
    date = json['date']?.toString();
    note = json['note']?.toString();
    noteEditingController.text = note ?? "";
    isPtm = json['isPtm'];
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isAdmin'] = isAdmin;
    data['admissionNo'] = admissionNo;
    data['agent'] = agent;
    data['commentId'] = commentId;
    data['commentedBy'] = commentedBy;
    data['commenter'] = commenter;
    data['date'] = date;
    data['note'] = note;
    data['isPtm'] = isPtm;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentCommentsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentCommentBeans": [
    {
      "admin": true,
      "admissionNo": "string",
      "agent": 0,
      "commentId": 0,
      "commentedBy": 0,
      "commenter": "string",
      "date": "string",
      "note": "string",
      "ptm": true,
      "rollNumber": "string",
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "studentId": 0,
      "studentName": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentCommentBean?>? studentCommentBeans;
  Map<String, dynamic> __origJson = {};

  GetStudentCommentsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentCommentBeans,
  });
  GetStudentCommentsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentCommentBeans'] != null) {
      final v = json['studentCommentBeans'];
      final arr0 = <StudentCommentBean>[];
      v.forEach((v) {
        arr0.add(StudentCommentBean.fromJson(v));
      });
      studentCommentBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentCommentBeans != null) {
      final v = studentCommentBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentCommentBeans'] = arr0;
    }
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentCommentsResponse> getStudentComments(
    GetStudentCommentsRequest getStudentCommentsRequest) async {
  debugPrint("Raising request to getStudentComments with request ${jsonEncode(getStudentCommentsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_COMMENTS;

  GetStudentCommentsResponse getStudentCommentsResponse = await HttpUtils.post(
    _url,
    getStudentCommentsRequest.toJson(),
    GetStudentCommentsResponse.fromJson,
  );

  debugPrint("GetStudentCommentBeanResponse ${getStudentCommentsResponse.toJson()}");
  return getStudentCommentsResponse;
}

class CreateOrUpdateStudentCommentRequest extends StudentCommentBean {
  CreateOrUpdateStudentCommentRequest(StudentCommentBean comment) {
    isAdmin = comment.isAdmin;
    admissionNo = comment.admissionNo;
    agent = comment.agent;
    commentId = comment.commentId;
    commentedBy = comment.commentedBy;
    commenter = comment.commenter;
    date = comment.date;
    note = comment.note;
    isPtm = comment.isPtm;
    rollNumber = comment.rollNumber;
    schoolId = comment.schoolId;
    sectionId = comment.sectionId;
    sectionName = comment.sectionName;
    status = comment.status;
    studentId = comment.studentId;
    studentName = comment.studentName;
  }
}

class CreateOrUpdateStudentCommentResponse {
/*
{
  "commentId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? commentId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentCommentResponse({
    this.commentId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateStudentCommentResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    commentId = json['commentId']?.toInt();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['commentId'] = commentId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateStudentCommentResponse> createOrUpdateStudentComment(CreateOrUpdateStudentCommentRequest createOrUpdateStudentCommentRequest) async {
  debugPrint("Raising request to createOrUpdateStudentComment with request ${jsonEncode(createOrUpdateStudentCommentRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_COMMENTS;

  CreateOrUpdateStudentCommentResponse createOrUpdateStudentCommentResponse = await HttpUtils.post(
    _url,
    createOrUpdateStudentCommentRequest.toJson(),
    CreateOrUpdateStudentCommentResponse.fromJson,
  );

  debugPrint("createOrUpdateStudentCommentResponse ${createOrUpdateStudentCommentResponse.toJson()}");
  return createOrUpdateStudentCommentResponse;
}
