import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetTasksRequest {
/*
{
  "academicYearId": 1,
  "assigneeId": 1,
  "assignerId": 127,
  "schoolId": 91
}
*/

  int? academicYearId;
  int? assigneeId;
  int? assignerId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetTasksRequest({
    this.academicYearId,
    this.assigneeId,
    this.assignerId,
    this.schoolId,
  });

  GetTasksRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearId = json['academicYearId']?.toInt();
    assigneeId = json['assigneeId']?.toInt();
    assignerId = json['assignerId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearId'] = academicYearId;
    data['assigneeId'] = assigneeId;
    data['assignerId'] = assignerId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TaskCommentBean {
/*
{
  "agent": "string",
  "comment": "string",
  "commentId": 0,
  "commentedDate": "string",
  "commenterId": 0,
  "commenterName": "string",
  "commenterRoles": "string",
  "taskId": 0
}
*/

  String? agent;
  String? comment;
  int? commentId;
  String? commentedDate;
  int? commenterId;
  String? commenterName;
  String? commenterRoles;
  int? taskId;
  int? createdTime;
  Map<String, dynamic> __origJson = {};

  TaskCommentBean({
    this.agent,
    this.comment,
    this.commentId,
    this.commentedDate,
    this.commenterId,
    this.commenterName,
    this.commenterRoles,
    this.taskId,
    this.createdTime,
  });

  TaskCommentBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    comment = json['comment']?.toString();
    commentId = json['commentId']?.toInt();
    commentedDate = json['commentedDate']?.toString();
    commenterId = json['commenterId']?.toInt();
    commenterName = json['commenterName']?.toString();
    commenterRoles = json['commenterRoles']?.toString();
    taskId = json['taskId']?.toInt();
    createdTime = json['createdTime']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['comment'] = comment;
    data['commentId'] = commentId;
    data['commentedDate'] = commentedDate;
    data['commenterId'] = commenterId;
    data['commenterName'] = commenterName;
    data['commenterRoles'] = commenterRoles;
    data['taskId'] = taskId;
    data['createdTime'] = createdTime;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TaskBean {
/*
{
  "assigneeId": 0,
  "assigneeName": "string",
  "assigneeRoles": "string",
  "assignerId": 0,
  "assignerName": "string",
  "assignerRoles": "string",
  "description": "string",
  "dueDate": "string",
  "schoolId": 0,
  "startDate": "string",
  "taskCommentBeanList": [
    {
      "agent": "string",
      "comment": "string",
      "commentId": 0,
      "commentedDate": "string",
      "commenterId": 0,
      "commenterName": "string",
      "commenterRoles": "string",
      "taskId": 0
    }
  ],
  "taskId": 0,
  "taskStatus": "ASSIGNED",
  "title": "string"
}
*/

  int? assigneeId;
  String? assigneeName;
  String? assigneeRoles;
  int? assignerId;
  String? assignerName;
  String? assignerRoles;
  String? description;
  String? dueDate;
  int? schoolId;
  String? startDate;
  List<TaskCommentBean?>? taskCommentBeanList;
  int? taskId;
  String? taskStatus;
  String? title;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  TaskBean({
    this.assigneeId,
    this.assigneeName,
    this.assigneeRoles,
    this.assignerId,
    this.assignerName,
    this.assignerRoles,
    this.description,
    this.dueDate,
    this.schoolId,
    this.startDate,
    this.taskCommentBeanList,
    this.taskId,
    this.taskStatus,
    this.title,
  });

  TaskBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    assigneeId = json['assigneeId']?.toInt();
    assigneeName = json['assigneeName']?.toString();
    assigneeRoles = json['assigneeRoles']?.toString();
    assignerId = json['assignerId']?.toInt();
    assignerName = json['assignerName']?.toString();
    assignerRoles = json['assignerRoles']?.toString();
    description = json['description']?.toString();
    dueDate = json['dueDate']?.toString();
    schoolId = json['schoolId']?.toInt();
    startDate = json['startDate']?.toString();
    if (json['taskCommentBeanList'] != null) {
      final v = json['taskCommentBeanList'];
      final arr0 = <TaskCommentBean>[];
      v.forEach((v) {
        arr0.add(TaskCommentBean.fromJson(v));
      });
      taskCommentBeanList = arr0;
    }
    taskId = json['taskId']?.toInt();
    taskStatus = json['taskStatus']?.toString();
    title = json['title']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['assigneeId'] = assigneeId;
    data['assigneeName'] = assigneeName;
    data['assigneeRoles'] = assigneeRoles;
    data['assignerId'] = assignerId;
    data['assignerName'] = assignerName;
    data['assignerRoles'] = assignerRoles;
    data['description'] = description;
    data['dueDate'] = dueDate;
    data['schoolId'] = schoolId;
    data['startDate'] = startDate;
    if (taskCommentBeanList != null) {
      final v = taskCommentBeanList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['taskCommentBeanList'] = arr0;
    }
    data['taskId'] = taskId;
    data['taskStatus'] = taskStatus;
    data['title'] = title;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetTasksResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "tasks": [
    {
      "assigneeId": 0,
      "assigneeName": "string",
      "assigneeRoles": "string",
      "assignerId": 0,
      "assignerName": "string",
      "assignerRoles": "string",
      "description": "string",
      "dueDate": "string",
      "schoolId": 0,
      "startDate": "string",
      "taskCommentBeanList": [
        {
          "agent": "string",
          "comment": "string",
          "commentId": 0,
          "commentedDate": "string",
          "commenterId": 0,
          "commenterName": "string",
          "commenterRoles": "string",
          "taskId": 0
        }
      ],
      "taskId": 0,
      "taskStatus": "ASSIGNED",
      "title": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<TaskBean?>? tasks;
  Map<String, dynamic> __origJson = {};

  GetTasksResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.tasks,
  });

  GetTasksResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['tasks'] != null) {
      final v = json['tasks'];
      final arr0 = <TaskBean>[];
      v.forEach((v) {
        arr0.add(TaskBean.fromJson(v));
      });
      tasks = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (tasks != null) {
      final v = tasks;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['tasks'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetTasksResponse> getTasks(GetTasksRequest getTasksRequest) async {
  debugPrint("Raising request to getTasks with request ${jsonEncode(getTasksRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_TASKS;

  GetTasksResponse getTasksResponse = await HttpUtils.post(
    _url,
    getTasksRequest.toJson(),
    GetTasksResponse.fromJson,
  );

  debugPrint("GetTasksResponse ${getTasksResponse.toJson()}");
  return getTasksResponse;
}

class CreateOrUpdateTaskCommentRequest {
/*
{
  "agent": 0,
  "comment": "string",
  "commentId": 0,
  "commentedBy": 0,
  "status": "active",
  "taskId": 0
}
*/

  int? agent;
  String? comment;
  int? commentId;
  int? commentedBy;
  String? status;
  int? taskId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTaskCommentRequest({
    this.agent,
    this.comment,
    this.commentId,
    this.commentedBy,
    this.status,
    this.taskId,
  });

  CreateOrUpdateTaskCommentRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    comment = json['comment']?.toString();
    commentId = json['commentId']?.toInt();
    commentedBy = json['commentedBy']?.toInt();
    status = json['status']?.toString();
    taskId = json['taskId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['comment'] = comment;
    data['commentId'] = commentId;
    data['commentedBy'] = commentedBy;
    data['status'] = status;
    data['taskId'] = taskId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateTaskCommentResponse {
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

  CreateOrUpdateTaskCommentResponse({
    this.commentId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateTaskCommentResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateTaskCommentResponse> createOrUpdateTaskComment(CreateOrUpdateTaskCommentRequest createOrUpdateTaskCommentRequest) async {
  debugPrint("Raising request to createOrUpdateTaskComment with request ${jsonEncode(createOrUpdateTaskCommentRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TASK_COMMENT;

  CreateOrUpdateTaskCommentResponse createOrUpdateTaskCommentResponse = await HttpUtils.post(
    _url,
    createOrUpdateTaskCommentRequest.toJson(),
    CreateOrUpdateTaskCommentResponse.fromJson,
  );

  debugPrint("createOrUpdateTaskCommentResponse ${createOrUpdateTaskCommentResponse.toJson()}");
  return createOrUpdateTaskCommentResponse;
}

class CreateOrUpdateTaskRequest {
/*
{
  "agent": 0,
  "assignedBy": 0,
  "assignedTo": 0,
  "description": "string",
  "dueDate": "string",
  "schoolId": 0,
  "startDate": "string",
  "status": "active",
  "taskId": 0,
  "taskStatus": "ASSIGNED",
  "title": "string"
}
*/

  int? agent;
  int? assignedBy;
  int? assignedTo;
  String? description;
  String? dueDate;
  int? schoolId;
  String? startDate;
  String? status;
  int? taskId;
  String? taskStatus;
  String? title;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTaskRequest({
    this.agent,
    this.assignedBy,
    this.assignedTo,
    this.description,
    this.dueDate,
    this.schoolId,
    this.startDate,
    this.status,
    this.taskId,
    this.taskStatus,
    this.title,
  });

  CreateOrUpdateTaskRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    assignedBy = json['assignedBy']?.toInt();
    assignedTo = json['assignedTo']?.toInt();
    description = json['description']?.toString();
    dueDate = json['dueDate']?.toString();
    schoolId = json['schoolId']?.toInt();
    startDate = json['startDate']?.toString();
    status = json['status']?.toString();
    taskId = json['taskId']?.toInt();
    taskStatus = json['taskStatus']?.toString();
    title = json['title']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['assignedBy'] = assignedBy;
    data['assignedTo'] = assignedTo;
    data['description'] = description;
    data['dueDate'] = dueDate;
    data['schoolId'] = schoolId;
    data['startDate'] = startDate;
    data['status'] = status;
    data['taskId'] = taskId;
    data['taskStatus'] = taskStatus;
    data['title'] = title;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateTaskResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "taskId": 0
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? taskId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTaskResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.taskId,
  });

  CreateOrUpdateTaskResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    taskId = json['taskId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['taskId'] = taskId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateTaskResponse> createOrUpdateTask(CreateOrUpdateTaskRequest createOrUpdateTaskRequest) async {
  debugPrint("Raising request to createOrUpdateTask with request ${jsonEncode(createOrUpdateTaskRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TASK;

  CreateOrUpdateTaskResponse createOrUpdateTaskResponse = await HttpUtils.post(
    _url,
    createOrUpdateTaskRequest.toJson(),
    CreateOrUpdateTaskResponse.fromJson,
  );

  debugPrint("createOrUpdateTaskResponse ${createOrUpdateTaskResponse.toJson()}");
  return createOrUpdateTaskResponse;
}
