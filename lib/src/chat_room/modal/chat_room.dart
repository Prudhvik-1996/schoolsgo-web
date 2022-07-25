import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetChatsRequest {
/*
{
  "chatRoomId": 0
}
*/

  int? chatRoomId;
  Map<String, dynamic> __origJson = {};

  GetChatsRequest({
    this.chatRoomId,
  });
  GetChatsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    chatRoomId = json['chatRoomId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['chatRoomId'] = chatRoomId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class ChatAttachmentBean {
  Map<String, dynamic> __origJson = {};

  ChatAttachmentBean();
  ChatAttachmentBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class ChatBean {
/*
{
  "agent": 0,
  "chatAttachments": [
    {}
  ],
  "chatId": 0,
  "chatMessage": "string",
  "chatRoomId": 0,
  "createTime": 0,
  "parentChatId": 0,
  "senderId": 0,
  "senderName": "string",
  "senderRole": "string",
  "status": "active"
}
*/
  TextEditingController chatMessageController = TextEditingController();

  int? agent;
  List<ChatAttachmentBean?>? chatAttachments;
  int? chatId;
  String? chatMessage;
  int? chatRoomId;
  int? createTime;
  int? parentChatId;
  int? senderId;
  String? senderName;
  String? senderRole;
  String? status;
  Map<String, dynamic> __origJson = {};

  ChatBean({
    this.agent,
    this.chatAttachments,
    this.chatId,
    this.chatMessage,
    this.chatRoomId,
    this.createTime,
    this.parentChatId,
    this.senderId,
    this.senderName,
    this.senderRole,
    this.status,
  }) {
    chatMessageController.text = chatMessage ?? "";
  }
  ChatBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    if (json['chatAttachments'] != null) {
      final v = json['chatAttachments'];
      final arr0 = <ChatAttachmentBean>[];
      v.forEach((v) {
        arr0.add(ChatAttachmentBean.fromJson(v));
      });
      chatAttachments = arr0;
    }
    chatId = json['chatId']?.toInt();
    chatMessage = json['chatMessage']?.toString();
    chatMessageController.text = chatMessage ?? "";
    chatRoomId = json['chatRoomId']?.toInt();
    createTime = json['createTime']?.toInt();
    parentChatId = json['parentChatId']?.toInt();
    senderId = json['senderId']?.toInt();
    senderName = json['senderName']?.toString();
    senderRole = json['senderRole']?.toString();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    if (chatAttachments != null) {
      final v = chatAttachments;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['chatAttachments'] = arr0;
    }
    data['chatId'] = chatId;
    data['chatMessage'] = chatMessage;
    data['chatRoomId'] = chatRoomId;
    data['createTime'] = createTime;
    data['parentChatId'] = parentChatId;
    data['senderId'] = senderId;
    data['senderName'] = senderName;
    data['senderRole'] = senderRole;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetChatsResponse {
/*
{
  "chats": [
    {
      "agent": 0,
      "chatAttachments": [
        {}
      ],
      "chatId": 0,
      "chatMessage": "string",
      "chatRoomId": 0,
      "createTime": 0,
      "parentChatId": 0,
      "senderId": 0,
      "senderName": "string",
      "senderRole": "string",
      "status": "active"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "totalNoOfChats": 0,
  "totalNoOfUnreadChats": 0
}
*/

  List<ChatBean?>? chats;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? totalNoOfChats;
  int? totalNoOfUnreadChats;
  Map<String, dynamic> __origJson = {};

  GetChatsResponse({
    this.chats,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.totalNoOfChats,
    this.totalNoOfUnreadChats,
  });
  GetChatsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['chats'] != null) {
      final v = json['chats'];
      final arr0 = <ChatBean>[];
      v.forEach((v) {
        arr0.add(ChatBean.fromJson(v));
      });
      chats = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    totalNoOfChats = json['totalNoOfChats']?.toInt();
    totalNoOfUnreadChats = json['totalNoOfUnreadChats']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (chats != null) {
      final v = chats;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['chats'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['totalNoOfChats'] = totalNoOfChats;
    data['totalNoOfUnreadChats'] = totalNoOfUnreadChats;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetChatsResponse> getChats(GetChatsRequest getChatsRequest) async {
  debugPrint("Raising request to getChats with request ${jsonEncode(getChatsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_CHATS;

  GetChatsResponse getChatsResponse = await HttpUtils.post(
    _url,
    getChatsRequest.toJson(),
    GetChatsResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("GetChatsResponse ${getChatsResponse.toJson()}");
  return getChatsResponse;
}

class CreateOrUpdateChatResponse {
/*
{
  "chatId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? chatId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateChatResponse({
    this.chatId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateChatResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    chatId = json['chatId']?.toInt();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['chatId'] = chatId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateChatResponse> createOrUpdateChat(ChatBean createChatRequest) async {
  debugPrint("Raising request to createChat with request ${jsonEncode(createChatRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_CHAT;

  CreateOrUpdateChatResponse createChatResponse = await HttpUtils.post(
    _url,
    createChatRequest.toJson(),
    CreateOrUpdateChatResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("createChatResponse ${createChatResponse.toJson()}");
  return createChatResponse;
}

class GetChatRoomsRequest {
/*
{
  "franchiseId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0,
  "subjectId": 0,
  "tdsId": 0,
  "teacherId": 0
}
*/

  int? franchiseId;
  int? schoolId;
  int? sectionId;
  int? studentId;
  int? subjectId;
  int? tdsId;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  GetChatRoomsRequest({
    this.franchiseId,
    this.schoolId,
    this.sectionId,
    this.studentId,
    this.subjectId,
    this.tdsId,
    this.teacherId,
  });
  GetChatRoomsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    subjectId = json['subjectId']?.toInt();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class ChatRoomBean {
/*
{
  "adminRoom": true,
  "agent": 0,
  "chatRoomId": 0,
  "franchiseId": 0,
  "franchiseName": "string",
  "lastMessage": "string",
  "lastMessageId": 0,
  "lastMessageSenderId": 0,
  "lastMessageSenderRole": "string",
  "schoolDisplayName": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "senderName": "string",
  "status": "active",
  "studentId": 0,
  "studentName": "string",
  "subjectId": 0,
  "subjectName": "string",
  "tdsId": 0,
  "teacherId": 0,
  "teacherName": "string"
}
*/

  bool? isAdminRoom;
  int? agent;
  int? chatRoomId;
  int? franchiseId;
  String? franchiseName;
  String? lastMessage;
  int? lastMessageId;
  int? lastMessageSenderId;
  String? lastMessageSenderRole;
  String? schoolDisplayName;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  String? senderName;
  String? status;
  int? studentId;
  String? studentName;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  int? lastMessageTime;
  Map<String, dynamic> __origJson = {};

  ChatRoomBean({
    this.isAdminRoom,
    this.agent,
    this.chatRoomId,
    this.franchiseId,
    this.franchiseName,
    this.lastMessage,
    this.lastMessageId,
    this.lastMessageSenderId,
    this.lastMessageSenderRole,
    this.schoolDisplayName,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.senderName,
    this.status,
    this.studentId,
    this.studentName,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
    this.lastMessageTime,
  });
  ChatRoomBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    isAdminRoom = json['adminRoom'];
    agent = json['agent']?.toInt();
    chatRoomId = json['chatRoomId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    lastMessage = json['lastMessage']?.toString();
    lastMessageId = json['lastMessageId']?.toInt();
    lastMessageSenderId = json['lastMessageSenderId']?.toInt();
    lastMessageSenderRole = json['lastMessageSenderRole']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    senderName = json['senderName']?.toString();
    status = json['status']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
    subjectId = json['subjectId']?.toInt();
    subjectName = json['subjectName']?.toString();
    tdsId = json['tdsId']?.toInt();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
    lastMessageTime = json['lastMessageTime']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminRoom'] = isAdminRoom;
    data['agent'] = agent;
    data['chatRoomId'] = chatRoomId;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['lastMessage'] = lastMessage;
    data['lastMessageId'] = lastMessageId;
    data['lastMessageSenderId'] = lastMessageSenderId;
    data['lastMessageSenderRole'] = lastMessageSenderRole;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['senderName'] = senderName;
    data['status'] = status;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['lastMessageTime'] = lastMessageTime;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetChatRoomsResponse {
/*
{
  "chatRooms": [
    {
      "agent": 0,
      "chatRoomId": 0,
      "franchiseId": 0,
      "franchiseName": "string",
      "lastMessage": "string",
      "lastMessageId": 0,
      "lastMessageSenderId": 0,
      "lastMessageSenderRole": "string",
      "schoolDisplayName": "string",
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "senderName": "string",
      "status": "active",
      "studentId": 0,
      "studentName": "string",
      "subjectId": 0,
      "subjectName": "string",
      "tdsId": 0,
      "teacherId": 0,
      "teacherName": "string"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<ChatRoomBean?>? chatRooms;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetChatRoomsResponse({
    this.chatRooms,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetChatRoomsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['chatRooms'] != null) {
      final v = json['chatRooms'];
      final arr0 = <ChatRoomBean>[];
      v.forEach((v) {
        arr0.add(ChatRoomBean.fromJson(v));
      });
      chatRooms = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (chatRooms != null) {
      final v = chatRooms;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['chatRooms'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetChatRoomsResponse> getChatRooms(GetChatRoomsRequest getChatRoomsRequest) async {
  debugPrint("Raising request to getChatRooms with request ${jsonEncode(getChatRoomsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_CHAT_ROOMS;

  GetChatRoomsResponse getChatRoomsResponse = await HttpUtils.post(
    _url,
    getChatRoomsRequest.toJson(),
    GetChatRoomsResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("GetChatRoomsResponse ${getChatRoomsResponse.toJson()}");
  return getChatRoomsResponse;
}
