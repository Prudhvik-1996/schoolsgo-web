import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetNoticeBoardRequest {
/*
{
  "franchiseId": 0,
  "limit": 0,
  "newsId": 0,
  "offset": 0,
  "schoolId": 0
}
*/

  int? franchiseId;
  int? limit;
  int? newsId;
  int? offset;
  int? schoolId;
  int? academicYearId;
  Map<String, dynamic> __origJson = {};

  GetNoticeBoardRequest({
    this.franchiseId,
    this.limit,
    this.newsId,
    this.offset,
    this.schoolId,
    this.academicYearId,
  });

  GetNoticeBoardRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    franchiseId = json['franchiseId']?.toInt();
    limit = json['limit']?.toInt();
    newsId = json['newsId']?.toInt();
    offset = json['offset']?.toInt();
    schoolId = json['schoolId']?.toInt();
    academicYearId = json['academicYearId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['franchiseId'] = franchiseId;
    data['limit'] = limit;
    data['newsId'] = newsId;
    data['offset'] = offset;
    data['schoolId'] = schoolId;
    data['academicYearId'] = academicYearId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class NewsMediaBean {
/*
{
  "agent": 0,
  "branchCode": "string",
  "city": "string",
  "createTime": 0,
  "description": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "lastUpdated": 0,
  "mediaId": 0,
  "mediaType": "string",
  "mediaUrl": "string",
  "newsId": 0,
  "newsMediaId": 0,
  "schoolDisplayName": "string",
  "schoolId": 0,
  "status": "active"
}
*/

  int? agent;
  String? branchCode;
  String? city;
  int? createTime;
  String? description;
  int? franchiseId;
  String? franchiseName;
  int? lastUpdated;
  int? mediaId;
  String? mediaType;
  String? mediaUrl;
  int? newsId;
  int? newsMediaId;
  String? schoolDisplayName;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  NewsMediaBean({
    this.agent,
    this.branchCode,
    this.city,
    this.createTime,
    this.description,
    this.franchiseId,
    this.franchiseName,
    this.lastUpdated,
    this.mediaId,
    this.mediaType,
    this.mediaUrl,
    this.newsId,
    this.newsMediaId,
    this.schoolDisplayName,
    this.schoolId,
    this.status,
  });

  NewsMediaBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    branchCode = json['branchCode']?.toString();
    city = json['city']?.toString();
    createTime = json['createTime']?.toInt();
    description = json['description']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    lastUpdated = json['lastUpdated']?.toInt();
    mediaId = json['mediaId']?.toInt();
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    newsId = json['newsId']?.toInt();
    newsMediaId = json['newsMediaId']?.toInt();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['branchCode'] = branchCode;
    data['city'] = city;
    data['createTime'] = createTime;
    data['description'] = description;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['lastUpdated'] = lastUpdated;
    data['mediaId'] = mediaId;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['newsId'] = newsId;
    data['newsMediaId'] = newsMediaId;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "NewsMediaBeans{'agent': $agent, 'createTime': $createTime, 'description': $description, 'lastUpdated': $lastUpdated, 'mediaId': $mediaId, 'mediaType': $mediaType, 'mediaUrl': $mediaUrl, 'newsId': $newsId, 'newsMediaId': $newsMediaId, 'schoolId': $schoolId, 'status': $status}";
  }

  @override
  int get hashCode {
    return toString().hashCode;
  }

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}

class News {
/*
{
  "agent": 0,
  "branchCode": "string",
  "city": "string",
  "createTime": 0,
  "description": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "lastUpdated": 0,
  "newsId": 0,
  "newsMediaBeans": [
    {
      "agent": 0,
      "branchCode": "string",
      "city": "string",
      "createTime": 0,
      "description": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "lastUpdated": 0,
      "mediaId": 0,
      "mediaType": "string",
      "mediaUrl": "string",
      "newsId": 0,
      "newsMediaId": 0,
      "schoolDisplayName": "string",
      "schoolId": 0,
      "status": "active"
    }
  ],
  "schoolDisplayName": "string",
  "schoolId": 0,
  "status": "active",
  "title": "string"
}
*/

  int? agent;
  String? branchCode;
  String? city;
  int? createTime;
  String? description;
  int? franchiseId;
  String? franchiseName;
  int? lastUpdated;
  int? newsId;
  List<NewsMediaBean?>? newsMediaBeans;
  String? schoolDisplayName;
  int? schoolId;
  String? status;
  String? title;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  News({
    this.agent,
    this.branchCode,
    this.city,
    this.createTime,
    this.description,
    this.franchiseId,
    this.franchiseName,
    this.lastUpdated,
    this.newsId,
    this.newsMediaBeans,
    this.schoolDisplayName,
    this.schoolId,
    this.status,
    this.title,
  });

  News.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    branchCode = json['branchCode']?.toString();
    city = json['city']?.toString();
    createTime = json['createTime']?.toInt();
    description = json['description']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    lastUpdated = json['lastUpdated']?.toInt();
    newsId = json['newsId']?.toInt();
    if (json['newsMediaBeans'] != null) {
      final v = json['newsMediaBeans'];
      final arr0 = <NewsMediaBean>[];
      v.forEach((v) {
        arr0.add(NewsMediaBean.fromJson(v));
      });
      newsMediaBeans = arr0;
    }
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    title = json['title']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['branchCode'] = branchCode;
    data['city'] = city;
    data['createTime'] = createTime;
    data['description'] = description;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['lastUpdated'] = lastUpdated;
    data['newsId'] = newsId;
    if (newsMediaBeans != null) {
      final v = newsMediaBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['newsMediaBeans'] = arr0;
    }
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['title'] = title;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "News{'agent': $agent, 'createTime': $createTime, 'description': $description, 'lastUpdated': $lastUpdated, 'newsId': $newsId, 'newsMediaBeans': $newsMediaBeans, 'schoolId': $schoolId, 'status': $status, 'title': $title}";
  }

  @override
  int get hashCode {
    return toString().hashCode;
  }

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}

class NoticeBoard {
/*
{
  "news": [
    {
      "agent": 0,
      "branchCode": "string",
      "city": "string",
      "createTime": 0,
      "description": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "lastUpdated": 0,
      "newsId": 0,
      "newsMediaBeans": [
        {
          "agent": 0,
          "branchCode": "string",
          "city": "string",
          "createTime": 0,
          "description": "string",
          "franchiseId": 0,
          "franchiseName": "string",
          "lastUpdated": 0,
          "mediaId": 0,
          "mediaType": "string",
          "mediaUrl": "string",
          "newsId": 0,
          "newsMediaId": 0,
          "schoolDisplayName": "string",
          "schoolId": 0,
          "status": "active"
        }
      ],
      "schoolDisplayName": "string",
      "schoolId": 0,
      "status": "active",
      "title": "string"
    }
  ]
}
*/

  List<News?>? news;
  Map<String, dynamic> __origJson = {};

  NoticeBoard({
    this.news,
  });

  NoticeBoard.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['news'] != null) {
      final v = json['news'];
      final arr0 = <News>[];
      v.forEach((v) {
        arr0.add(News.fromJson(v));
      });
      news = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (news != null) {
      final v = news;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['news'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetNoticeBoardResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "noticeBoard": {
    "news": [
      {
        "agent": 0,
        "branchCode": "string",
        "city": "string",
        "createTime": 0,
        "description": "string",
        "franchiseId": 0,
        "franchiseName": "string",
        "lastUpdated": 0,
        "newsId": 0,
        "newsMediaBeans": [
          {
            "agent": 0,
            "branchCode": "string",
            "city": "string",
            "createTime": 0,
            "description": "string",
            "franchiseId": 0,
            "franchiseName": "string",
            "lastUpdated": 0,
            "mediaId": 0,
            "mediaType": "string",
            "mediaUrl": "string",
            "newsId": 0,
            "newsMediaId": 0,
            "schoolDisplayName": "string",
            "schoolId": 0,
            "status": "active"
          }
        ],
        "schoolDisplayName": "string",
        "schoolId": 0,
        "status": "active",
        "title": "string"
      }
    ]
  },
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  NoticeBoard? noticeBoard;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetNoticeBoardResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.noticeBoard,
    this.responseStatus,
  });

  GetNoticeBoardResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    noticeBoard = (json['noticeBoard'] != null) ? NoticeBoard.fromJson(json['noticeBoard']) : null;
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (noticeBoard != null) {
      data['noticeBoard'] = noticeBoard!.toJson();
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetNoticeBoardResponse> getNoticeBoard(GetNoticeBoardRequest getNoticeBoardRequest) async {
  debugPrint("Raising request to getNoticeBoard with request ${jsonEncode(getNoticeBoardRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_NOTICE_BOARD;

  GetNoticeBoardResponse getNoticeBoardResponse = await HttpUtils.post(
    _url,
    getNoticeBoardRequest.toJson(),
    GetNoticeBoardResponse.fromJson,
  );

  debugPrint("GetNoticeBoardResponse ${getNoticeBoardResponse.toJson()}");
  return getNoticeBoardResponse;
}

class CreateOrUpdateNoticeBoardMediaRequest {
  String? agent;
  int? schoolId;
  int? franchiseId;
  List<NewsMediaBean>? newsMediaBeans;

  CreateOrUpdateNoticeBoardMediaRequest({
    this.agent,
    this.schoolId,
    this.franchiseId,
    this.newsMediaBeans,
  });

  CreateOrUpdateNoticeBoardMediaRequest.fromJson(Map<String, dynamic> json) {
    agent = json["agent"]?.toString();
    schoolId = json["schoolId"]?.toInt();
    franchiseId = json["franchiseId"]?.toInt();
    if (json["newsMediaBeans"] != null && (json["newsMediaBeans"] is List)) {
      final v = json["newsMediaBeans"];
      final arr0 = <NewsMediaBean>[];
      v.forEach((v) {
        arr0.add(NewsMediaBean.fromJson(v));
      });
      newsMediaBeans = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["schoolId"] = schoolId;
    data["franchiseId"] = franchiseId;
    data["newsMediaBeans"] = newsMediaBeans;
    if (newsMediaBeans != null) {
      final v = newsMediaBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v.toJson());
      }
      data["newsMediaBeans"] = arr0;
    }
    return data;
  }
}

class CreateOrUpdateNoticeBoardMediaResponse {
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

  CreateOrUpdateNoticeBoardMediaResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateNoticeBoardMediaResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateNoticeBoardMediaResponse> createOrUpdateNoticeBoardMedia(
    CreateOrUpdateNoticeBoardMediaRequest createOrUpdateNoticeBoardMediaRequest) async {
  debugPrint("Raising request to createOrUpdateNoticeBoardMedia with request ${jsonEncode(createOrUpdateNoticeBoardMediaRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_NOTICE_BOARD_MEDIA_BEANS;

  CreateOrUpdateNoticeBoardMediaResponse createOrUpdateNoticeBoardMediaResponse = await HttpUtils.post(
    _url,
    createOrUpdateNoticeBoardMediaRequest.toJson(),
    CreateOrUpdateNoticeBoardMediaResponse.fromJson,
  );

  debugPrint("CreateOrUpdateNoticeBoardMediaResponse ${createOrUpdateNoticeBoardMediaResponse.toJson()}");
  return createOrUpdateNoticeBoardMediaResponse;
}

class CreateOrUpdateNoticeBoardRequest {
/*
{
  "agentId": 0,
  "description": "string",
  "newsId": 0,
  "schoolId": 0,
  "status": "active",
  "title": "string"
}
*/

  int? agentId;
  String? description;
  int? newsId;
  int? schoolId;
  String? status;
  String? title;
  int? franchiseId;

  CreateOrUpdateNoticeBoardRequest({
    this.agentId,
    this.description,
    this.newsId,
    this.schoolId,
    this.status,
    this.title,
    this.franchiseId,
  });

  CreateOrUpdateNoticeBoardRequest.fromJson(Map<String, dynamic> json) {
    agentId = int.tryParse(json["agentId"]?.toString() ?? '');
    description = json["description"]?.toString();
    newsId = int.tryParse(json["newsId"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    status = json["status"]?.toString();
    title = json["title"]?.toString();
    franchiseId = json["franchiseId"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agentId"] = agentId;
    data["description"] = description;
    data["newsId"] = newsId;
    data["schoolId"] = schoolId;
    data["status"] = status;
    data["title"] = title;
    data["franchiseId"] = franchiseId;
    return data;
  }
}

class CreateOrUpdateNoticeBoardResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "newsId": 0,
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  int? newsId;
  String? responseStatus;

  CreateOrUpdateNoticeBoardResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.newsId,
    this.responseStatus,
  });

  CreateOrUpdateNoticeBoardResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    newsId = int.tryParse(json["newsId"]?.toString() ?? '');
    responseStatus = json["responseStatus"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["newsId"] = newsId;
    data["responseStatus"] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateNoticeBoardResponse> createOrUpdateNoticeBoard(CreateOrUpdateNoticeBoardRequest createOrUpdateNoticeBoardRequest) async {
  debugPrint("Raising request to createOrUpdateNoticeBoard with request ${jsonEncode(createOrUpdateNoticeBoardRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_NOTICE_BOARD;

  CreateOrUpdateNoticeBoardResponse createOrUpdateNoticeBoardResponse = await HttpUtils.post(
    _url,
    createOrUpdateNoticeBoardRequest.toJson(),
    CreateOrUpdateNoticeBoardResponse.fromJson,
  );

  debugPrint("CreateOrUpdateNoticeBoardResponse ${createOrUpdateNoticeBoardResponse.toJson()}");
  return createOrUpdateNoticeBoardResponse;
}
