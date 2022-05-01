import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetSectionsRequest {
/*
{
  "schoolId": 0,
  "sectionId": 0
}
*/

  int? schoolId;
  int? sectionId;
  int? franchiseId;
  Map<String, dynamic> __origJson = {};

  GetSectionsRequest({
    this.schoolId,
    this.sectionId,
    this.franchiseId,
  });

  GetSectionsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    franchiseId = int.tryParse(json["franchiseId"]?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["schoolId"] = schoolId;
    data["sectionId"] = sectionId;
    data["franchiseId"] = franchiseId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class Section {
/*
{
  "agent": "string",
  "description": "string",
  "schoolId": 0,
  "sectionId": 0,
  "sectionName": "string",
  "sectionPhotoUrl": "string",
  "ocrAsPerTt": false
}
*/

  String? agent;
  String? description;
  int? schoolId;
  int? sectionId;
  String? sectionName;
  String? sectionPhotoUrl;
  bool? ocrAsPerTt;
  Map<String, dynamic> __origJson = {};

  Section({
    this.agent,
    this.description,
    this.schoolId,
    this.sectionId,
    this.sectionName,
    this.sectionPhotoUrl,
    this.ocrAsPerTt,
  });

  Section.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json["agent"]?.toString();
    description = json["description"]?.toString();
    schoolId = int.tryParse(json["schoolId"]?.toString() ?? '');
    sectionId = int.tryParse(json["sectionId"]?.toString() ?? '');
    sectionName = json["sectionName"]?.toString();
    sectionPhotoUrl = json["sectionPhotoUrl"]?.toString();
    ocrAsPerTt = json["ocrAsPerTt"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["agent"] = agent;
    data["description"] = description;
    data["schoolId"] = schoolId;
    data["sectionId"] = sectionId;
    data["sectionName"] = sectionName;
    data["sectionPhotoUrl"] = sectionPhotoUrl;
    data["ocrAsPerTt"] = ocrAsPerTt;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  int compareTo(other) {
    return toJson().toString().compareTo(other.toJson().toString());
  }

  @override
  String toString() {
    return "Section {'sectionId'=$sectionId,'schoolId'=$schoolId,'sectionName'='$sectionName','sectionPhotoUrl'='$sectionPhotoUrl','description'='$description','agent'=$agent,'ocrAsPerTt'=$ocrAsPerTt}";
  }

  @override
  int get hashCode => sectionId ?? 0;

  @override
  bool operator ==(other) {
    return compareTo(other) == 0;
  }
}

class GetSectionsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "sections": [
    {
      "agent": "string",
      "description": "string",
      "schoolId": 0,
      "sectionId": 0,
      "sectionName": "string",
      "sectionPhotoUrl": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<Section?>? sections;
  Map<String, dynamic> __origJson = {};

  GetSectionsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.sections,
  });

  GetSectionsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json["errorCode"]?.toString();
    errorMessage = json["errorMessage"]?.toString();
    httpStatus = json["httpStatus"]?.toString();
    responseStatus = json["responseStatus"]?.toString();
    if (json["sections"] != null && (json["sections"] is List)) {
      final v = json["sections"];
      final arr0 = <Section>[];
      v.forEach((v) {
        arr0.add(Section.fromJson(v));
      });
      sections = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["errorCode"] = errorCode;
    data["errorMessage"] = errorMessage;
    data["httpStatus"] = httpStatus;
    data["responseStatus"] = responseStatus;
    if (sections != null) {
      final v = sections;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data["sections"] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSectionsResponse> getSections(GetSectionsRequest getSectionsRequest) async {
  print("Raising request to getSections with request ${jsonEncode(getSectionsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SECTIONS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getSectionsRequest.toJson()),
  );

  GetSectionsResponse getSectionsResponse = GetSectionsResponse.fromJson(json.decode(response.body));
  print("GetSectionsResponse ${getSectionsResponse.toJson()}");
  return getSectionsResponse;
}
