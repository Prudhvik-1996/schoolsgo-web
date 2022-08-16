import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetEventsRequest {
  int? eventDate;
  int? eventId;
  int? limit;
  int? offset;
  int? schoolId;

  GetEventsRequest({
    this.eventDate,
    this.eventId,
    this.limit,
    this.offset,
    this.schoolId,
  });
  GetEventsRequest.fromJson(Map<String, dynamic> json) {
    eventDate = int.tryParse(json["eventDate"]?.toString() ?? '');
    eventId = int.tryParse(json["eventId"]?.toString() ?? '');
    limit = int.tryParse(json["limit"]?.toString() ?? '');
    offset = int.tryParse(json["offset"]?.toString() ?? '');
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["eventDate"] = eventDate;
    data["eventId"] = eventId;
    data["limit"] = limit;
    data["offset"] = offset;
    data["schoolId"] = schoolId;
    return data;
  }
}

class Event {
/*
{
  "agent": "string",
  "coverPhotoUrl": "string",
  "coverPhotoUrlId": 0,
  "description": "string",
  "eventDate": "string",
  "eventId": 0,
  "eventName": "string",
  "eventType": "string",
  "organisedBy": "string",
  "schoolId": 0,
  "status": "active"
}
*/

  String? agent;
  String? coverPhotoUrl;
  int? coverPhotoUrlId;
  String? description;
  String? eventDate;
  int? eventId;
  String? eventName;
  String? eventType;
  String? organisedBy;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  bool isEditMode = false;

  Event({
    this.agent,
    this.coverPhotoUrl,
    this.coverPhotoUrlId,
    this.description,
    this.eventDate,
    this.eventId,
    this.eventName,
    this.eventType,
    this.organisedBy,
    this.schoolId,
    this.status,
  });
  Event.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json["agent"]?.toString();
    coverPhotoUrl = json["coverPhotoUrl"]?.toString();
    coverPhotoUrlId = int.tryParse(json["coverPhotoUrlId"]?.toString() ?? '');
    description = json["description"]?.toString();
    eventDate = json["eventDate"]?.toString();
    eventId = int.tryParse(json["eventId"]?.toString() ?? '');
    eventName = json["eventName"]?.toString();
    eventType = json["eventType"]?.toString();
    organisedBy = json["organisedBy"]?.toString();
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    status = json["status"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["coverPhotoUrl"] = coverPhotoUrl;
    data["coverPhotoUrlId"] = coverPhotoUrlId;
    data["description"] = description;
    data["eventDate"] = eventDate;
    data["eventId"] = eventId;
    data["eventName"] = eventName;
    data["eventType"] = eventType;
    data["organisedBy"] = organisedBy;
    data["schoolId"] = schoolId;
    data["status"] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  String toString() {
    return "Event {'agent': $agent, 'coverPhotoUrl': $coverPhotoUrl, 'coverPhotoUrlId': $coverPhotoUrlId, 'description': $description, 'eventDate': $eventDate, 'eventId': $eventId, 'eventName': $eventName, 'eventType': $eventType, 'organisedBy': $organisedBy, 'schoolId': $schoolId, 'status': $status}";
  }

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => toString().hashCode;
}

class GetEventsResponse {
  String? errorCode;
  String? errorMessage;
  List<Event?>? events;
  String? httpStatus;
  String? responseStatus;
  int? totalNoOfEvents;

  GetEventsResponse({
    this.errorCode,
    this.errorMessage,
    this.events,
    this.httpStatus,
    this.responseStatus,
    this.totalNoOfEvents,
  });
  GetEventsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    if (json["events"] != null && (json["events"] is List)) {
      final v = json["events"];
      final arr0 = <Event>[];
      v.forEach((v) {
        arr0.add(Event.fromJson(v));
      });
      events = arr0;
    }
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
    totalNoOfEvents = int.tryParse(json["totalNoOfEvents"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    if (events != null) {
      final v = events;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["events"] = arr0;
    }
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    data["totalNoOfEvents"] = totalNoOfEvents;
    return data;
  }
}

Future<GetEventsResponse> getEvents(GetEventsRequest getEventsRequest) async {
  debugPrint("Raising request to getEvents with request ${jsonEncode(getEventsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EVENTS;

  GetEventsResponse getEventsResponse = await HttpUtils.post(
    _url,
    getEventsRequest.toJson(),
    GetEventsResponse.fromJson,
  );

  debugPrint("GetEventsResponse ${getEventsResponse.toJson()}");
  return getEventsResponse;
}

class GetEventMediaRequest {
  int? eventId;
  int? limit;
  int? offset;

  GetEventMediaRequest({
    this.eventId,
    this.limit,
    this.offset,
  });
  GetEventMediaRequest.fromJson(Map<String, dynamic> json) {
    eventId = int.tryParse(json["eventId"]?.toString() ?? '');
    limit = int.tryParse(json["limit"]?.toString() ?? '');
    offset = int.tryParse(json["offset"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["eventId"] = eventId;
    data["limit"] = limit;
    data["offset"] = offset;
    return data;
  }
}

class EventMedia {
  String? agent;
  String? description;
  int? eventId;
  int? eventMediaId;
  int? mediaId;
  String? mediaType;
  String? mediaUrl;
  String? status;

  EventMedia({
    this.agent,
    this.description,
    this.eventId,
    this.eventMediaId,
    this.mediaId,
    this.mediaType,
    this.mediaUrl,
    this.status,
  });
  EventMedia.fromJson(Map<String, dynamic> json) {
    agent = json["agent"]?.toString();
    description = json["description"]?.toString();
    eventId = int.tryParse(json["eventId"]?.toString() ?? '');
    eventMediaId = int.tryParse(json["eventMediaId"]?.toString() ?? '');
    mediaId = int.tryParse(json["mediaId"]?.toString() ?? '');
    mediaType = json["mediaType"]?.toString();
    mediaUrl = json["mediaUrl"]?.toString();
    status = json["status"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["description"] = description;
    data["eventId"] = eventId;
    data["eventMediaId"] = eventMediaId;
    data["mediaId"] = mediaId;
    data["mediaType"] = mediaType;
    data["mediaUrl"] = mediaUrl;
    data["status"] = status;
    return data;
  }
}

class GetEventMediaResponse {
  String? errorCode;
  String? errorMessage;
  List<EventMedia?>? eventMedia;
  String? httpStatus;
  String? responseStatus;
  int? totalNoOfEventMedia;

  GetEventMediaResponse({
    this.errorCode,
    this.errorMessage,
    this.eventMedia,
    this.httpStatus,
    this.responseStatus,
    this.totalNoOfEventMedia,
  });
  GetEventMediaResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    if (json["eventMedia"] != null && (json["eventMedia"] is List)) {
      final v = json["eventMedia"];
      final arr0 = <EventMedia>[];
      v.forEach((v) {
        arr0.add(EventMedia.fromJson(v));
      });
      eventMedia = arr0;
    }
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
    totalNoOfEventMedia = int.tryParse(json["totalNoOfEventMedia"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    if (eventMedia != null) {
      final v = eventMedia;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["eventMedia"] = arr0;
    }
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    data["totalNoOfEventMedia"] = totalNoOfEventMedia;
    return data;
  }
}

Future<GetEventMediaResponse> getEventMedia(GetEventMediaRequest getEventMediaRequest) async {
  debugPrint("Raising request to getEventMedia with request ${jsonEncode(getEventMediaRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EVENT_MEDIA;

  GetEventMediaResponse getEventMediaResponse = await HttpUtils.post(
    _url,
    getEventMediaRequest.toJson(),
    GetEventMediaResponse.fromJson,
  );

  debugPrint("GetEventMediaResponse ${getEventMediaResponse.toJson()}");
  return getEventMediaResponse;
}

class CreateOrUpdateEventsRequest {
/*
{
  "agent": "string",
  "eventBeans": [
    {
      "agent": "string",
      "coverPhotoUrl": "string",
      "description": "string",
      "eventDate": 0,
      "eventId": 0,
      "eventName": "string",
      "eventType": "string",
      "organisedBy": "string",
      "schoolId": 0,
      "status": "active"
    }
  ],
  "schoolId": 0
}
*/

  String? agent;
  List<Event?>? eventBeans;
  int? schoolId;

  CreateOrUpdateEventsRequest({
    this.agent,
    this.eventBeans,
    this.schoolId,
  });
  CreateOrUpdateEventsRequest.fromJson(Map<String, dynamic> json) {
    agent = json["agent"]?.toString();
    if (json["eventBeans"] != null && (json["eventBeans"] is List)) {
      final v = json["eventBeans"];
      final arr0 = <Event>[];
      v.forEach((v) {
        arr0.add(Event.fromJson(v));
      });
      eventBeans = arr0;
    }
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    if (eventBeans != null) {
      final v = eventBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["eventBeans"] = arr0;
    }
    data["schoolId"] = schoolId;
    return data;
  }
}

class CreateOrUpdateEventsResponse {
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

  CreateOrUpdateEventsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateEventsResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateEventsResponse> createOrUpdateEvents(CreateOrUpdateEventsRequest createOrUpdateEventsRequest) async {
  debugPrint("Raising request to createOrUpdateEvents with request ${jsonEncode(createOrUpdateEventsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_EVENTS;

  CreateOrUpdateEventsResponse createOrUpdateEventsResponse = await HttpUtils.post(
    _url,
    createOrUpdateEventsRequest.toJson(),
    CreateOrUpdateEventsResponse.fromJson,
  );

  debugPrint("CreateOrUpdateEventsResponse ${createOrUpdateEventsResponse.toJson()}");
  return createOrUpdateEventsResponse;
}

class CreateOrUpdateEventMediaRequest {
/*
{
  "agent": "string",
  "eventMediaBeans": [
    {
      "agent": "string",
      "description": "string",
      "eventId": 0,
      "eventMediaId": 0,
      "mediaId": 0,
      "mediaType": "string",
      "mediaUrl": "string",
      "status": "active"
    }
  ],
  "schoolId": 0
}
*/

  String? agent;
  List<EventMedia?>? eventMediaBeans;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateEventMediaRequest({
    this.agent,
    this.eventMediaBeans,
    this.schoolId,
  });
  CreateOrUpdateEventMediaRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json["agent"]?.toString();
    if (json["eventMediaBeans"] != null && (json["eventMediaBeans"] is List)) {
      final v = json["eventMediaBeans"];
      final arr0 = <EventMedia>[];
      v.forEach((v) {
        arr0.add(EventMedia.fromJson(v));
      });
      eventMediaBeans = arr0;
    }
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    if (eventMediaBeans != null) {
      final v = eventMediaBeans;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["eventMediaBeans"] = arr0;
    }
    data["schoolId"] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateEventMediaResponse {
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

  CreateOrUpdateEventMediaResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateEventMediaResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateEventMediaResponse> createOrUpdateEventMedia(CreateOrUpdateEventMediaRequest createOrUpdateEventMediaRequest) async {
  debugPrint("Raising request to createOrUpdateEventMedia with request ${jsonEncode(createOrUpdateEventMediaRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_EVENT_MEDIA;

  CreateOrUpdateEventMediaResponse createOrUpdateEventMediaResponse = await HttpUtils.post(
    _url,
    createOrUpdateEventMediaRequest.toJson(),
    CreateOrUpdateEventMediaResponse.fromJson,
  );

  debugPrint("CreateOrUpdateEventMediaResponse ${createOrUpdateEventMediaResponse.toJson()}");
  return createOrUpdateEventMediaResponse;
}
