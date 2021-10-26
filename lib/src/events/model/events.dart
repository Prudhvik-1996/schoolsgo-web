import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

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
  print(
      "Raising request to getEvents with request ${jsonEncode(getEventsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EVENTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getEventsRequest.toJson()),
  );

  GetEventsResponse getEventsResponse =
      GetEventsResponse.fromJson(json.decode(response.body));
  print("GetEventsResponse ${getEventsResponse.toJson()}");
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    totalNoOfEventMedia =
        int.tryParse(json["totalNoOfEventMedia"]?.toString() ?? '');
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    if (eventMedia != null) {
      final v = eventMedia;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["eventMedia"] = arr0;
    }
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    data["totalNoOfEventMedia"] = totalNoOfEventMedia;
    return data;
  }
}

Future<GetEventMediaResponse> getEventMedia(
    GetEventMediaRequest getEventMediaRequest) async {
  print(
      "Raising request to getEventMedia with request ${jsonEncode(getEventMediaRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_EVENT_MEDIA;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getEventMediaRequest.toJson()),
  );

  GetEventMediaResponse getEventMediaResponse =
      GetEventMediaResponse.fromJson(json.decode(response.body));
  print("GetEventMediaResponse ${getEventMediaResponse.toJson()}");
  return getEventMediaResponse;
}
