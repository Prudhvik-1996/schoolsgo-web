import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetNoticeBoardRequest {
  int? limit;
  int? newsId;
  int? offset;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetNoticeBoardRequest({
    this.limit,
    this.newsId,
    this.offset,
    this.schoolId,
  });
  GetNoticeBoardRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    limit = int.tryParse(json["limit"]?.toString() ?? '');
    newsId = int.tryParse(json["newsId"]?.toString() ?? '');
    offset = int.tryParse(json["offset"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["limit"] = limit;
    data["newsId"] = newsId;
    data["offset"] = offset;
    data["schoolId"] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class NewsMediaBeans {
  String? agent;
  String? createTime;
  String? description;
  String? lastUpdated;
  int? mediaId;
  String? mediaType;
  String? mediaUrl;
  int? newsId;
  int? newsMediaId;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  NewsMediaBeans({
    this.agent,
    this.createTime,
    this.description,
    this.lastUpdated,
    this.mediaId,
    this.mediaType,
    this.mediaUrl,
    this.newsId,
    this.newsMediaId,
    this.schoolId,
    this.status,
  });
  NewsMediaBeans.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json["agent"]?.toString();
    createTime = json["createTime"]?.toString();
    description = json["description"]?.toString();
    lastUpdated = json["lastUpdated"]?.toString();
    mediaId = int.tryParse(json["mediaId"]?.toString() ?? '');
    mediaType = json["mediaType"]?.toString();
    mediaUrl = json["mediaUrl"]?.toString();
    newsId = int.tryParse(json["newsId"]?.toString() ?? '');
    newsMediaId = int.tryParse(json["newsMediaId"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    status = json["status"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["createTime"] = createTime;
    data["description"] = description;
    data["lastUpdated"] = lastUpdated;
    data["mediaId"] = mediaId;
    data["mediaType"] = mediaType;
    data["mediaUrl"] = mediaUrl;
    data["newsId"] = newsId;
    data["newsMediaId"] = newsMediaId;
    data["schoolId"] = schoolId;
    data["status"] = status;
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
  String? agent;
  String? createTime;
  String? description;
  String? lastUpdated;
  int? newsId;
  List<NewsMediaBeans?>? newsMediaBeans;
  int? schoolId;
  String? status;
  String? title;
  Map<String, dynamic> __origJson = {};
  bool isEditMode = false;

  News({
    this.agent,
    this.createTime,
    this.description,
    this.lastUpdated,
    this.newsId,
    this.newsMediaBeans,
    this.schoolId,
    this.status,
    this.title,
  });
  News.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json["agent"]?.toString();
    createTime = json["createTime"]?.toString();
    description = json["description"]?.toString();
    lastUpdated = json["lastUpdated"]?.toString();
    newsId = int.tryParse(json["newsId"]?.toString() ?? '');
    if (json["newsMediaBeans"] != null && (json["newsMediaBeans"] is List)) {
      final v = json["newsMediaBeans"];
      final arr0 = <NewsMediaBeans>[];
      v.forEach((v) {
        arr0.add(NewsMediaBeans.fromJson(v));
      });
      newsMediaBeans = arr0;
    }
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    status = json["status"]?.toString();
    title = json["title"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["createTime"] = createTime;
    data["description"] = description;
    data["lastUpdated"] = lastUpdated;
    data["newsId"] = newsId;
    if (newsMediaBeans != null) {
      final v = newsMediaBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["newsMediaBeans"] = arr0;
    }
    data["schoolId"] = schoolId;
    data["status"] = status;
    data["title"] = title;
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
  List<News?>? news;
  Map<String, dynamic> __origJson = {};

  NoticeBoard({
    this.news,
  });
  NoticeBoard.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json["news"] != null && (json["news"] is List)) {
      final v = json["news"];
      final arr0 = <News>[];
      v.forEach((v) {
        arr0.add(News.fromJson(v));
      });
      news = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (news != null) {
      final v = news;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["news"] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetNoticeBoardResponse {
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
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    noticeBoard = (json["noticeBoard"] != null && (json["noticeBoard"] is Map))
        ? NoticeBoard.fromJson(json["noticeBoard"])
        : null;
    responseStatus = json["responseStatus"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    if (noticeBoard != null) {
      data["noticeBoard"] = noticeBoard!.toJson();
    }
    data["responseStatus"] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetNoticeBoardResponse> getNoticeBoard(
    GetNoticeBoardRequest getNoticeBoardRequest) async {
  print(
      "Raising request to getNoticeBoard with request ${jsonEncode(getNoticeBoardRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_NOTICE_BOARD;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getNoticeBoardRequest.toJson()),
  );

  GetNoticeBoardResponse getNoticeBoardResponse =
      GetNoticeBoardResponse.fromJson(json.decode(response.body));
  print("GetNoticeBoardResponse ${getNoticeBoardResponse.toJson()}");
  return getNoticeBoardResponse;
}

class CreateOrUpdateNoticeBoardMediaRequest {
  String? agent;
  int? schoolId;
  List<NewsMediaBeans>? newsMediaBeans;

  CreateOrUpdateNoticeBoardMediaRequest({
    this.agent,
    this.schoolId,
    this.newsMediaBeans,
  });
  CreateOrUpdateNoticeBoardMediaRequest.fromJson(Map<String, dynamic> json) {
    agent = json["agent"]?.toString();
    schoolId = json["schoolId"]?.toInt();
    if (json["newsMediaBeans"] != null && (json["newsMediaBeans"] is List)) {
      final v = json["newsMediaBeans"];
      final arr0 = <NewsMediaBeans>[];
      v.forEach((v) {
        arr0.add(NewsMediaBeans.fromJson(v));
      });
      newsMediaBeans = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["schoolId"] = schoolId;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateNoticeBoardMediaResponse> createOrUpdateNoticeBoardMedia(
    CreateOrUpdateNoticeBoardMediaRequest
        createOrUpdateNoticeBoardMediaRequest) async {
  print(
      "Raising request to createOrUpdateNoticeBoardMedia with request ${jsonEncode(createOrUpdateNoticeBoardMediaRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_NOTICE_BOARD_MEDIA_BEANS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateNoticeBoardMediaRequest.toJson()),
  );

  CreateOrUpdateNoticeBoardMediaResponse
      createOrUpdateNoticeBoardMediaResponse =
      CreateOrUpdateNoticeBoardMediaResponse.fromJson(
          json.decode(response.body));
  print(
      "CreateOrUpdateNoticeBoardMediaResponse ${createOrUpdateNoticeBoardMediaResponse.toJson()}");
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

  CreateOrUpdateNoticeBoardRequest({
    this.agentId,
    this.description,
    this.newsId,
    this.schoolId,
    this.status,
    this.title,
  });
  CreateOrUpdateNoticeBoardRequest.fromJson(Map<String, dynamic> json) {
    agentId = int.tryParse(json["agentId"]?.toString() ?? '');
    description = json["description"]?.toString();
    newsId = int.tryParse(json["newsId"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    status = json["status"]?.toString();
    title = json["title"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["agentId"] = agentId;
    data["description"] = description;
    data["newsId"] = newsId;
    data["schoolId"] = schoolId;
    data["status"] = status;
    data["title"] = title;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["newsId"] = newsId;
    data["responseStatus"] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateNoticeBoardResponse> createOrUpdateNoticeBoard(
    CreateOrUpdateNoticeBoardRequest createOrUpdateNoticeBoardRequest) async {
  print(
      "Raising request to createOrUpdateNoticeBoard with request ${jsonEncode(createOrUpdateNoticeBoardRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_NOTICE_BOARD;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateNoticeBoardRequest.toJson()),
  );

  CreateOrUpdateNoticeBoardResponse createOrUpdateNoticeBoardResponse =
      CreateOrUpdateNoticeBoardResponse.fromJson(json.decode(response.body));
  print(
      "CreateOrUpdateNoticeBoardResponse ${createOrUpdateNoticeBoardResponse.toJson()}");
  return createOrUpdateNoticeBoardResponse;
}
