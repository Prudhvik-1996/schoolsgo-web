import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetBusPositionRequest {
/*
{
  "busId": 0,
  "driverId": 0,
  "franchiseId": 0,
  "schoolId": 0
}
*/

  int? busId;
  int? driverId;
  int? franchiseId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetBusPositionRequest({
    this.busId,
    this.driverId,
    this.franchiseId,
    this.schoolId,
  });
  GetBusPositionRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    busId = json['busId']?.toInt();
    driverId = json['driverId']?.toInt();
    franchiseId = json['franchiseId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['busId'] = busId;
    data['driverId'] = driverId;
    data['franchiseId'] = franchiseId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class BusLocation {
/*
{
  "accuracy": 0,
  "altitude": 0,
  "bearing": 0,
  "busId": 0,
  "device": "string",
  "driverId": 0,
  "latitude": 0,
  "longitude": 0,
  "schoolId": 0,
  "speed": 0,
  "status": "active"
}
*/

  double? accuracy;
  double? altitude;
  double? bearing;
  int? busId;
  String? device;
  int? driverId;
  double? latitude;
  double? longitude;
  int? schoolId;
  double? speed;
  String? status;
  Map<String, dynamic> __origJson = {};

  BusLocation({
    this.accuracy,
    this.altitude,
    this.bearing,
    this.busId,
    this.device,
    this.driverId,
    this.latitude,
    this.longitude,
    this.schoolId,
    this.speed,
    this.status,
  });
  BusLocation.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    accuracy = json['accuracy']?.toDouble();
    altitude = json['altitude']?.toDouble();
    bearing = json['bearing']?.toDouble();
    busId = json['busId']?.toInt();
    device = json['device']?.toString();
    driverId = json['driverId']?.toInt();
    latitude = json['latitude']?.toDouble();
    longitude = json['longitude']?.toDouble();
    schoolId = json['schoolId']?.toInt();
    speed = json['speed']?.toDouble();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['accuracy'] = accuracy;
    data['altitude'] = altitude;
    data['bearing'] = bearing;
    data['busId'] = busId;
    data['device'] = device;
    data['driverId'] = driverId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['schoolId'] = schoolId;
    data['speed'] = speed;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetBusPositionResponse {
/*
{
  "busLocationList": [
    {
      "accuracy": 0,
      "altitude": 0,
      "bearing": 0,
      "busId": 0,
      "device": "string",
      "driverId": 0,
      "latitude": 0,
      "longitude": 0,
      "schoolId": 0,
      "speed": 0,
      "status": "active"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<BusLocation?>? busLocationList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetBusPositionResponse({
    this.busLocationList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetBusPositionResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['busLocationList'] != null) {
      final v = json['busLocationList'];
      final arr0 = <BusLocation>[];
      v.forEach((v) {
        arr0.add(BusLocation.fromJson(v));
      });
      busLocationList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (busLocationList != null) {
      final v = busLocationList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['busLocationList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetBusPositionResponse> getBusPosition(GetBusPositionRequest getBusPositionRequest) async {
  print("Raising request to getBusPosition with request ${jsonEncode(getBusPositionRequest.toJson())}");
  String _url = BUS_TRACKING_API_URL + GET_LOCATION;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getBusPositionRequest.toJson()),
  );

  GetBusPositionResponse getBusPositionResponse = GetBusPositionResponse.fromJson(json.decode(response.body));
  print("GetBusPositionResponse ${getBusPositionResponse.toJson()}");
  return getBusPositionResponse;
}
