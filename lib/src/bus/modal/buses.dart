import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

class GetDriversRequest {
/*
{
  "driverId": 0,
  "schoolId": 0
}
*/

  int? driverId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetDriversRequest({
    this.driverId,
    this.schoolId,
  });
  GetDriversRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    driverId = json['driverId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['driverId'] = driverId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class BusDriverBean {
/*
{
  "schoolId": 0,
  "schoolName": "string",
  "userId": 0,
  "userName": "string",
  "userPhotoUrl": "string"
}
*/

  int? schoolId;
  String? schoolName;
  int? userId;
  String? userName;
  String? userPhotoUrl;
  Map<String, dynamic> __origJson = {};

  BusDriverBean({
    this.schoolId,
    this.schoolName,
    this.userId,
    this.userName,
    this.userPhotoUrl,
  });
  BusDriverBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    userId = json['userId']?.toInt();
    userName = json['userName']?.toString();
    userPhotoUrl = json['userPhotoUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['userId'] = userId;
    data['userName'] = userName;
    data['userPhotoUrl'] = userPhotoUrl;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetDriversResponse {
/*
{
  "drivers": [
    {
      "schoolId": 0,
      "schoolName": "string",
      "userId": 0,
      "userName": "string",
      "userPhotoUrl": "string"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<BusDriverBean?>? drivers;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetDriversResponse({
    this.drivers,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetDriversResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['drivers'] != null) {
      final v = json['drivers'];
      final arr0 = <BusDriverBean>[];
      v.forEach((v) {
        arr0.add(BusDriverBean.fromJson(v));
      });
      drivers = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (drivers != null) {
      final v = drivers;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['drivers'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetDriversResponse> getDrivers(GetDriversRequest getDriversRequest) async {
  print("Raising request to getDrivers with request ${jsonEncode(getDriversRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_BUSES_DRIVERS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getDriversRequest.toJson()),
  );

  GetDriversResponse getDriversResponse = GetDriversResponse.fromJson(json.decode(response.body));
  print("GetDriversResponse ${getDriversResponse.toJson()}");
  return getDriversResponse;
}

class GetBusesBaseDetailsRequest {
/*
{
  "busDriverId": 0,
  "busId": 0,
  "routeId": 0,
  "schoolId": 0
}
*/

  int? busDriverId;
  int? busId;
  int? routeId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetBusesBaseDetailsRequest({
    this.busDriverId,
    this.busId,
    this.routeId,
    this.schoolId,
  });
  GetBusesBaseDetailsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    busDriverId = json['busDriverId']?.toInt();
    busId = json['busId']?.toInt();
    routeId = json['routeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['busDriverId'] = busDriverId;
    data['busId'] = busId;
    data['routeId'] = routeId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class RouteStopWiseStudent {
/*
{
  "agent": 0,
  "busDiverId": 0,
  "busDriverName": "string",
  "busId": 0,
  "busName": "string",
  "busStopId": 0,
  "busStopName": "string",
  "routeId": 0,
  "routeName": "string",
  "sectionId": 0,
  "sectionName": "string",
  "status": "active",
  "studentId": 0,
  "studentName": "string"
}
*/

  int? agent;
  int? busDiverId;
  String? busDriverName;
  int? busId;
  String? busName;
  int? busStopId;
  String? busStopName;
  int? routeId;
  String? routeName;
  int? sectionId;
  String? sectionName;
  String? status;
  int? studentId;
  String? studentName;
  Map<String, dynamic> __origJson = {};

  RouteStopWiseStudent({
    this.agent,
    this.busDiverId,
    this.busDriverName,
    this.busId,
    this.busName,
    this.busStopId,
    this.busStopName,
    this.routeId,
    this.routeName,
    this.sectionId,
    this.sectionName,
    this.status,
    this.studentId,
    this.studentName,
  });
  RouteStopWiseStudent.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    busDiverId = json['busDiverId']?.toInt();
    busDriverName = json['busDriverName']?.toString();
    busId = json['busId']?.toInt();
    busName = json['busName']?.toString();
    busStopId = json['busStopId']?.toInt();
    busStopName = json['busStopName']?.toString();
    routeId = json['routeId']?.toInt();
    routeName = json['routeName']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    status = json['status']?.toString();
    studentId = json['studentId']?.toInt();
    studentName = json['studentName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['busDiverId'] = busDiverId;
    data['busDriverName'] = busDriverName;
    data['busId'] = busId;
    data['busName'] = busName;
    data['busStopId'] = busStopId;
    data['busStopName'] = busStopName;
    data['routeId'] = routeId;
    data['routeName'] = routeName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['status'] = status;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class BusRouteStop {
/*
{
  "agent": 0,
  "busRouteStopId": 0,
  "dropTime": {
    "date": 0,
    "day": 0,
    "hours": 0,
    "minutes": 0,
    "month": 0,
    "seconds": 0,
    "time": 0,
    "timezoneOffset": 0,
    "year": 0
  },
  "latitude": 0,
  "longitude": 0,
  "pickUpTime": {
    "date": 0,
    "day": 0,
    "hours": 0,
    "minutes": 0,
    "month": 0,
    "seconds": 0,
    "time": 0,
    "timezoneOffset": 0,
    "year": 0
  },
  "routeId": 0,
  "routeName": "string",
  "schoolId": 0,
  "status": "active",
  "students": [
    {
      "agent": 0,
      "busDiverId": 0,
      "busDriverName": "string",
      "busId": 0,
      "busName": "string",
      "busStopId": 0,
      "busStopName": "string",
      "routeId": 0,
      "routeName": "string",
      "sectionId": 0,
      "sectionName": "string",
      "status": "active",
      "studentId": 0,
      "studentName": "string"
    }
  ],
  "terminalName": "string",
  "terminalNumber": 0
}
*/

  int? agent;
  int? busRouteStopId;
  String? dropTime;
  int? latitude;
  int? longitude;
  String? pickUpTime;
  int? routeId;
  String? routeName;
  int? schoolId;
  String? status;
  List<RouteStopWiseStudent?>? students;
  String? terminalName;
  TextEditingController terminalNameController = TextEditingController();
  int? terminalNumber;
  Map<String, dynamic> __origJson = {};

  BusRouteStop({
    this.agent,
    this.busRouteStopId,
    this.dropTime,
    this.latitude,
    this.longitude,
    this.pickUpTime,
    this.routeId,
    this.routeName,
    this.schoolId,
    this.status,
    this.students,
    this.terminalName,
    this.terminalNumber,
  }) {
    terminalNameController.text = terminalName ?? "";
  }
  BusRouteStop.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    busRouteStopId = json['busRouteStopId']?.toInt();
    dropTime = json['dropTime']?.toString();
    latitude = json['latitude']?.toInt();
    longitude = json['longitude']?.toInt();
    pickUpTime = json['pickUpTime']?.toString();
    routeId = json['routeId']?.toInt();
    routeName = json['routeName']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    if (json['students'] != null) {
      final v = json['students'];
      final arr0 = <RouteStopWiseStudent>[];
      v.forEach((v) {
        arr0.add(RouteStopWiseStudent.fromJson(v));
      });
      students = arr0;
    }
    terminalName = json['terminalName']?.toString();
    terminalNameController.text = terminalName ?? "";
    terminalNumber = json['terminalNumber']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['busRouteStopId'] = busRouteStopId;
    data['dropTime'] = dropTime;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['pickUpTime'] = pickUpTime;
    data['routeId'] = routeId;
    data['routeName'] = routeName;
    data['schoolId'] = schoolId;
    data['status'] = status;
    if (students != null) {
      final v = students;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['students'] = arr0;
    }
    data['terminalName'] = terminalName;
    data['terminalNumber'] = terminalNumber;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class BusRouteInfo {
/*
{
  "agent": 0,
  "busDriverId": 0,
  "busDriverName": "string",
  "busDriverProfilePhotoUrl": "string",
  "busId": 0,
  "busName": "string",
  "busRouteId": 0,
  "busRouteName": "string",
  "busRouteStopsList": [
    {
      "agent": 0,
      "busRouteStopId": 0,
      "dropTime": {
        "date": 0,
        "day": 0,
        "hours": 0,
        "minutes": 0,
        "month": 0,
        "seconds": 0,
        "time": 0,
        "timezoneOffset": 0,
        "year": 0
      },
      "latitude": 0,
      "longitude": 0,
      "pickUpTime": {
        "date": 0,
        "day": 0,
        "hours": 0,
        "minutes": 0,
        "month": 0,
        "seconds": 0,
        "time": 0,
        "timezoneOffset": 0,
        "year": 0
      },
      "routeId": 0,
      "routeName": "string",
      "schoolId": 0,
      "status": "active",
      "students": [
        {
          "agent": 0,
          "busDiverId": 0,
          "busDriverName": "string",
          "busId": 0,
          "busName": "string",
          "busStopId": 0,
          "busStopName": "string",
          "routeId": 0,
          "routeName": "string",
          "sectionId": 0,
          "sectionName": "string",
          "status": "active",
          "studentId": 0,
          "studentName": "string"
        }
      ],
      "terminalName": "string",
      "terminalNumber": 0
    }
  ],
  "noOfSeats": 0,
  "rc": "string",
  "regNo": "string",
  "routeInChargeId": 0,
  "routeInChargeName": "string",
  "schoolId": 0,
  "status": "active"
}
*/

  bool isExpanded = false;
  int currentStep = 0;
  bool expandAllStops = false;
  bool isEditMode = false;

  int? agent;
  int? busDriverId;
  String? busDriverName;
  String? busDriverProfilePhotoUrl;
  int? busId;
  String? busName;
  int? busRouteId;
  String? busRouteName;
  TextEditingController routeNameController = TextEditingController();
  List<BusRouteStop?>? busRouteStopsList;
  int? noOfSeats;
  String? rc;
  String? regNo;
  int? routeInChargeId;
  String? routeInChargeName;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  BusRouteInfo({
    this.agent,
    this.busDriverId,
    this.busDriverName,
    this.busDriverProfilePhotoUrl,
    this.busId,
    this.busName,
    this.busRouteId,
    this.busRouteName,
    this.busRouteStopsList,
    this.noOfSeats,
    this.rc,
    this.regNo,
    this.routeInChargeId,
    this.routeInChargeName,
    this.schoolId,
    this.status,
  }) {
    routeNameController.text = busRouteName ?? "";
  }
  BusRouteInfo.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    busDriverId = json['busDriverId']?.toInt();
    busDriverName = json['busDriverName']?.toString();
    busDriverProfilePhotoUrl = json['busDriverProfilePhotoUrl']?.toString();
    busId = json['busId']?.toInt();
    busName = json['busName']?.toString();
    busRouteId = json['busRouteId']?.toInt();
    busRouteName = json['busRouteName']?.toString();
    routeNameController.text = busRouteName ?? "";
    if (json['busRouteStopsList'] != null) {
      final v = json['busRouteStopsList'];
      final arr0 = <BusRouteStop>[];
      v.forEach((v) {
        arr0.add(BusRouteStop.fromJson(v));
      });
      busRouteStopsList = arr0;
    }
    noOfSeats = json['noOfSeats']?.toInt();
    rc = json['rc']?.toString();
    regNo = json['regNo']?.toString();
    routeInChargeId = json['routeInChargeId']?.toInt();
    routeInChargeName = json['routeInChargeName']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }

  BusRouteInfo.deepCloneFromOriginalJson(BusRouteInfo busRouteInfo) {
    busRouteInfo.agent = busRouteInfo.__origJson['agent']?.toInt();
    busRouteInfo.busDriverId = busRouteInfo.__origJson['busDriverId']?.toInt();
    busRouteInfo.busDriverName = busRouteInfo.__origJson['busDriverName']?.toString();
    busRouteInfo.busDriverProfilePhotoUrl = busRouteInfo.__origJson['busDriverProfilePhotoUrl']?.toString();
    busRouteInfo.busId = busRouteInfo.__origJson['busId']?.toInt();
    busRouteInfo.busName = busRouteInfo.__origJson['busName']?.toString();
    busRouteInfo.busRouteId = busRouteInfo.__origJson['busRouteId']?.toInt();
    busRouteInfo.busRouteName = busRouteInfo.__origJson['busRouteName']?.toString();
    if (busRouteInfo.__origJson['busRouteStopsList'] != null) {
      final v = busRouteInfo.__origJson['busRouteStopsList'];
      final arr0 = <BusRouteStop>[];
      v.forEach((v) {
        arr0.add(BusRouteStop.fromJson(v));
      });
      busRouteInfo.busRouteStopsList = arr0;
    }
    busRouteInfo.noOfSeats = busRouteInfo.__origJson['noOfSeats']?.toInt();
    busRouteInfo.rc = busRouteInfo.__origJson['rc']?.toString();
    busRouteInfo.regNo = busRouteInfo.__origJson['regNo']?.toString();
    busRouteInfo.routeInChargeId = busRouteInfo.__origJson['routeInChargeId']?.toInt();
    busRouteInfo.routeInChargeName = busRouteInfo.__origJson['routeInChargeName']?.toString();
    busRouteInfo.schoolId = busRouteInfo.__origJson['schoolId']?.toInt();
    busRouteInfo.status = busRouteInfo.__origJson['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['busDriverId'] = busDriverId;
    data['busDriverName'] = busDriverName;
    data['busDriverProfilePhotoUrl'] = busDriverProfilePhotoUrl;
    data['busId'] = busId;
    data['busName'] = busName;
    data['busRouteId'] = busRouteId;
    data['busRouteName'] = busRouteName;
    if (busRouteStopsList != null) {
      final v = busRouteStopsList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['busRouteStopsList'] = arr0;
    }
    data['noOfSeats'] = noOfSeats;
    data['rc'] = rc;
    data['regNo'] = regNo;
    data['routeInChargeId'] = routeInChargeId;
    data['routeInChargeName'] = routeInChargeName;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class BusBaseDetails {
/*
{
  "busDriverId": 0,
  "busDriverName": "string",
  "busDriverProfilePhotoUrl": "string",
  "busId": 0,
  "busName": "string",
  "busRouteInfo": {
    "agent": 0,
    "busDriverId": 0,
    "busDriverName": "string",
    "busDriverProfilePhotoUrl": "string",
    "busId": 0,
    "busName": "string",
    "busRouteId": 0,
    "busRouteName": "string",
    "busRouteStopsList": [
      {
        "agent": 0,
        "busRouteStopId": 0,
        "dropTime": {
          "date": 0,
          "day": 0,
          "hours": 0,
          "minutes": 0,
          "month": 0,
          "seconds": 0,
          "time": 0,
          "timezoneOffset": 0,
          "year": 0
        },
        "latitude": 0,
        "longitude": 0,
        "pickUpTime": {
          "date": 0,
          "day": 0,
          "hours": 0,
          "minutes": 0,
          "month": 0,
          "seconds": 0,
          "time": 0,
          "timezoneOffset": 0,
          "year": 0
        },
        "routeId": 0,
        "routeName": "string",
        "schoolId": 0,
        "status": "active",
        "students": [
          {
            "agent": 0,
            "busDiverId": 0,
            "busDriverName": "string",
            "busId": 0,
            "busName": "string",
            "busStopId": 0,
            "busStopName": "string",
            "routeId": 0,
            "routeName": "string",
            "sectionId": 0,
            "sectionName": "string",
            "status": "active",
            "studentId": 0,
            "studentName": "string"
          }
        ],
        "terminalName": "string",
        "terminalNumber": 0
      }
    ],
    "noOfSeats": 0,
    "rc": "string",
    "regNo": "string",
    "routeInChargeId": 0,
    "routeInChargeName": "string",
    "schoolId": 0,
    "status": "active"
  },
  "noOfSeats": 0,
  "rc": "string",
  "regNo": "string",
  "routeId": 0,
  "schoolId": 0,
  "status": "active"
}
*/

  bool isEditMode = false;
  int? busDriverId;
  String? busDriverName;
  String? busDriverProfilePhotoUrl;
  int? busId;
  String? busName;
  BusRouteInfo? busRouteInfo;
  int? noOfSeats;
  String? regNo;
  int? routeId;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  TextEditingController busNameController = TextEditingController();
  TextEditingController regNoController = TextEditingController();

  BusBaseDetails({
    this.busDriverId,
    this.busDriverName,
    this.busDriverProfilePhotoUrl,
    this.busId,
    this.busName,
    this.busRouteInfo,
    this.noOfSeats,
    this.regNo,
    this.routeId,
    this.schoolId,
    this.status,
  }) {
    busNameController.text = busName ?? "";
    regNoController.text = regNo ?? "";
  }
  BusBaseDetails.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    busDriverId = json['busDriverId']?.toInt();
    busDriverName = json['busDriverName']?.toString();
    busDriverProfilePhotoUrl = json['busDriverProfilePhotoUrl']?.toString();
    busId = json['busId']?.toInt();
    busName = json['busName']?.toString();
    busNameController.text = busName ?? "";
    busRouteInfo = (json['busRouteInfo'] != null) ? BusRouteInfo.fromJson(json['busRouteInfo']) : null;
    noOfSeats = json['noOfSeats']?.toInt();
    regNo = json['regNo']?.toString();
    regNoController.text = regNo ?? "";
    routeId = json['routeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['busDriverId'] = busDriverId;
    data['busDriverName'] = busDriverName;
    data['busDriverProfilePhotoUrl'] = busDriverProfilePhotoUrl;
    data['busId'] = busId;
    data['busName'] = busName;
    if (busRouteInfo != null) {
      data['busRouteInfo'] = busRouteInfo!.toJson();
    }
    data['noOfSeats'] = noOfSeats;
    data['regNo'] = regNo;
    data['routeId'] = routeId;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetBusesBaseDetailsResponse {
/*
{
  "busBaseDetailsList": [
    {
      "busDriverId": 0,
      "busDriverName": "string",
      "busDriverProfilePhotoUrl": "string",
      "busId": 0,
      "busName": "string",
      "busRouteInfo": {
        "agent": 0,
        "busDriverId": 0,
        "busDriverName": "string",
        "busDriverProfilePhotoUrl": "string",
        "busId": 0,
        "busName": "string",
        "busRouteId": 0,
        "busRouteName": "string",
        "busRouteStopsList": [
          {
            "agent": 0,
            "busRouteStopId": 0,
            "dropTime": {
              "date": 0,
              "day": 0,
              "hours": 0,
              "minutes": 0,
              "month": 0,
              "seconds": 0,
              "time": 0,
              "timezoneOffset": 0,
              "year": 0
            },
            "latitude": 0,
            "longitude": 0,
            "pickUpTime": {
              "date": 0,
              "day": 0,
              "hours": 0,
              "minutes": 0,
              "month": 0,
              "seconds": 0,
              "time": 0,
              "timezoneOffset": 0,
              "year": 0
            },
            "routeId": 0,
            "routeName": "string",
            "schoolId": 0,
            "status": "active",
            "students": [
              {
                "agent": 0,
                "busDiverId": 0,
                "busDriverName": "string",
                "busId": 0,
                "busName": "string",
                "busStopId": 0,
                "busStopName": "string",
                "routeId": 0,
                "routeName": "string",
                "sectionId": 0,
                "sectionName": "string",
                "status": "active",
                "studentId": 0,
                "studentName": "string"
              }
            ],
            "terminalName": "string",
            "terminalNumber": 0
          }
        ],
        "noOfSeats": 0,
        "rc": "string",
        "regNo": "string",
        "routeInChargeId": 0,
        "routeInChargeName": "string",
        "schoolId": 0,
        "status": "active"
      },
      "noOfSeats": 0,
      "rc": "string",
      "regNo": "string",
      "routeId": 0,
      "schoolId": 0,
      "status": "active"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<BusBaseDetails?>? busBaseDetailsList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetBusesBaseDetailsResponse({
    this.busBaseDetailsList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetBusesBaseDetailsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['busBaseDetailsList'] != null) {
      final v = json['busBaseDetailsList'];
      final arr0 = <BusBaseDetails>[];
      v.forEach((v) {
        arr0.add(BusBaseDetails.fromJson(v));
      });
      busBaseDetailsList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (busBaseDetailsList != null) {
      final v = busBaseDetailsList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['busBaseDetailsList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetBusesBaseDetailsResponse> getBusesBaseDetails(GetBusesBaseDetailsRequest getBusesBaseDetailsRequest) async {
  print("Raising request to getBusesBaseDetails with request ${jsonEncode(getBusesBaseDetailsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_BUSES_BASE_DETAILS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getBusesBaseDetailsRequest.toJson()),
  );

  GetBusesBaseDetailsResponse getBusesBaseDetailsResponse = GetBusesBaseDetailsResponse.fromJson(json.decode(response.body));
  print("GetBusesBaseDetailsResponse ${getBusesBaseDetailsResponse.toJson()}");
  return getBusesBaseDetailsResponse;
}

class CreateOrUpdateBusRequest {
/*
{
  "agent": 0,
  "busDriverId": 0,
  "busId": 0,
  "busName": "string",
  "noOfSeats": 0,
  "rc": "string",
  "regNo": "string",
  "schoolId": 0,
  "status": "active"
}
*/

  int? agent;
  int? busDriverId;
  int? busId;
  String? busName;
  int? noOfSeats;
  String? rc;
  String? regNo;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateBusRequest({
    this.agent,
    this.busDriverId,
    this.busId,
    this.busName,
    this.noOfSeats,
    this.rc,
    this.regNo,
    this.schoolId,
    this.status,
  });
  CreateOrUpdateBusRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    busDriverId = json['busDriverId']?.toInt();
    busId = json['busId']?.toInt();
    busName = json['busName']?.toString();
    noOfSeats = json['noOfSeats']?.toInt();
    rc = json['rc']?.toString();
    regNo = json['regNo']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['busDriverId'] = busDriverId;
    data['busId'] = busId;
    data['busName'] = busName;
    data['noOfSeats'] = noOfSeats;
    data['rc'] = rc;
    data['regNo'] = regNo;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateBusResponse {
/*
{
  "busId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? busId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateBusResponse({
    this.busId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateBusResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    busId = json['busId']?.toInt();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['busId'] = busId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateBusResponse> createOrUpdateBus(CreateOrUpdateBusRequest createOrUpdateBusRequest) async {
  print("Raising request to createOrUpdateBus with request ${jsonEncode(createOrUpdateBusRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_BUSES_BASE_DETAILS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateBusRequest.toJson()),
  );

  CreateOrUpdateBusResponse createOrUpdateBusResponse = CreateOrUpdateBusResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateBusResponse ${createOrUpdateBusResponse.toJson()}");
  return createOrUpdateBusResponse;
}

class GetBusRouteDetailsRequest {
/*
{
  "busDriverId": 0,
  "busId": 0,
  "busStopId": 0,
  "routeId": 0,
  "schoolId": 0,
  "sectionId": 0,
  "studentId": 0
}
*/

  int? busDriverId;
  int? busId;
  int? busStopId;
  int? routeId;
  int? schoolId;
  int? sectionId;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  GetBusRouteDetailsRequest({
    this.busDriverId,
    this.busId,
    this.busStopId,
    this.routeId,
    this.schoolId,
    this.sectionId,
    this.studentId,
  });
  GetBusRouteDetailsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    busDriverId = json['busDriverId']?.toInt();
    busId = json['busId']?.toInt();
    busStopId = json['busStopId']?.toInt();
    routeId = json['routeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['busDriverId'] = busDriverId;
    data['busId'] = busId;
    data['busStopId'] = busStopId;
    data['routeId'] = routeId;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetBusRouteDetailsResponse {
/*
{
  "busRouteInfoBeanList": [
    {
      "agent": 0,
      "busDriverId": 0,
      "busDriverName": "string",
      "busDriverProfilePhotoUrl": "string",
      "busId": 0,
      "busName": "string",
      "busRouteId": 0,
      "busRouteName": "string",
      "busRouteStopsList": [
        {
          "agent": 0,
          "busRouteStopId": 0,
          "dropTime": {
            "date": 0,
            "day": 0,
            "hours": 0,
            "minutes": 0,
            "month": 0,
            "seconds": 0,
            "time": 0,
            "timezoneOffset": 0,
            "year": 0
          },
          "latitude": 0,
          "longitude": 0,
          "pickUpTime": {
            "date": 0,
            "day": 0,
            "hours": 0,
            "minutes": 0,
            "month": 0,
            "seconds": 0,
            "time": 0,
            "timezoneOffset": 0,
            "year": 0
          },
          "routeId": 0,
          "routeName": "string",
          "schoolId": 0,
          "status": "active",
          "students": [
            {
              "agent": 0,
              "busDiverId": 0,
              "busDriverName": "string",
              "busId": 0,
              "busName": "string",
              "busStopId": 0,
              "busStopName": "string",
              "routeId": 0,
              "routeName": "string",
              "sectionId": 0,
              "sectionName": "string",
              "status": "active",
              "studentId": 0,
              "studentName": "string"
            }
          ],
          "terminalName": "string",
          "terminalNumber": 0
        }
      ],
      "noOfSeats": 0,
      "rc": "string",
      "regNo": "string",
      "routeInChargeId": 0,
      "routeInChargeName": "string",
      "schoolId": 0,
      "status": "active"
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  List<BusRouteInfo?>? busRouteInfoBeanList;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetBusRouteDetailsResponse({
    this.busRouteInfoBeanList,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  GetBusRouteDetailsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['busRouteInfoBeanList'] != null) {
      final v = json['busRouteInfoBeanList'];
      final arr0 = <BusRouteInfo>[];
      v.forEach((v) {
        arr0.add(BusRouteInfo.fromJson(v));
      });
      busRouteInfoBeanList = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (busRouteInfoBeanList != null) {
      final v = busRouteInfoBeanList;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['busRouteInfoBeanList'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetBusRouteDetailsResponse> getBusRouteDetails(GetBusRouteDetailsRequest getBusRouteDetailsRequest) async {
  print("Raising request to getBusRouteDetails with request ${jsonEncode(getBusRouteDetailsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_ROUTE_INFO;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getBusRouteDetailsRequest.toJson()),
  );

  GetBusRouteDetailsResponse getBusRouteDetailsResponse = GetBusRouteDetailsResponse.fromJson(json.decode(response.body));
  print("GetBusRouteDetailsResponse ${getBusRouteDetailsResponse.toJson()}");
  return getBusRouteDetailsResponse;
}

class CreateOrUpdateBusRouteDetailsRequest {
/*
{
  "agent": 0,
  "busDriverId": 0,
  "busDriverName": "string",
  "busDriverProfilePhotoUrl": "string",
  "busId": 0,
  "busName": "string",
  "busRouteId": 0,
  "busRouteName": "string",
  "busRouteStopsList": [
    {
      "agent": 0,
      "busRouteStopId": 0,
      "dropTime": "",
      "latitude": 0,
      "longitude": 0,
      "pickUpTime": "",
      "routeId": 0,
      "routeName": "string",
      "schoolId": 0,
      "status": "active",
      "students": [
        {
          "agent": 0,
          "busDiverId": 0,
          "busDriverName": "string",
          "busId": 0,
          "busName": "string",
          "busStopId": 0,
          "busStopName": "string",
          "routeId": 0,
          "routeName": "string",
          "sectionId": 0,
          "sectionName": "string",
          "status": "active",
          "studentId": 0,
          "studentName": "string"
        }
      ],
      "terminalName": "string",
      "terminalNumber": 0
    }
  ],
  "noOfSeats": 0,
  "rc": "string",
  "regNo": "string",
  "routeInChargeId": 0,
  "routeInChargeName": "string",
  "schoolId": 0,
  "status": "active"
}
*/

  int? agent;
  int? busDriverId;
  String? busDriverName;
  String? busDriverProfilePhotoUrl;
  int? busId;
  String? busName;
  int? busRouteId;
  String? busRouteName;
  List<BusRouteStop?>? busRouteStopsList;
  int? noOfSeats;
  String? rc;
  String? regNo;
  int? routeInChargeId;
  String? routeInChargeName;
  int? schoolId;
  String? status;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateBusRouteDetailsRequest({
    this.agent,
    this.busDriverId,
    this.busDriverName,
    this.busDriverProfilePhotoUrl,
    this.busId,
    this.busName,
    this.busRouteId,
    this.busRouteName,
    this.busRouteStopsList,
    this.noOfSeats,
    this.rc,
    this.regNo,
    this.routeInChargeId,
    this.routeInChargeName,
    this.schoolId,
    this.status,
  });
  CreateOrUpdateBusRouteDetailsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    busDriverId = json['busDriverId']?.toInt();
    busDriverName = json['busDriverName']?.toString();
    busDriverProfilePhotoUrl = json['busDriverProfilePhotoUrl']?.toString();
    busId = json['busId']?.toInt();
    busName = json['busName']?.toString();
    busRouteId = json['busRouteId']?.toInt();
    busRouteName = json['busRouteName']?.toString();
    if (json['busRouteStopsList'] != null) {
      final v = json['busRouteStopsList'];
      final arr0 = <BusRouteStop>[];
      v.forEach((v) {
        arr0.add(BusRouteStop.fromJson(v));
      });
      busRouteStopsList = arr0;
    }
    noOfSeats = json['noOfSeats']?.toInt();
    rc = json['rc']?.toString();
    regNo = json['regNo']?.toString();
    routeInChargeId = json['routeInChargeId']?.toInt();
    routeInChargeName = json['routeInChargeName']?.toString();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['busDriverId'] = busDriverId;
    data['busDriverName'] = busDriverName;
    data['busDriverProfilePhotoUrl'] = busDriverProfilePhotoUrl;
    data['busId'] = busId;
    data['busName'] = busName;
    data['busRouteId'] = busRouteId;
    data['busRouteName'] = busRouteName;
    if (busRouteStopsList != null) {
      final v = busRouteStopsList;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['busRouteStopsList'] = arr0;
    }
    data['noOfSeats'] = noOfSeats;
    data['rc'] = rc;
    data['regNo'] = regNo;
    data['routeInChargeId'] = routeInChargeId;
    data['routeInChargeName'] = routeInChargeName;
    data['schoolId'] = schoolId;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateBusRouteDetailsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "routeId": 0
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? routeId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateBusRouteDetailsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.routeId,
  });
  CreateOrUpdateBusRouteDetailsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    routeId = json['routeId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['routeId'] = routeId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateBusRouteDetailsResponse> createOrUpdateBusRouteDetails(
    CreateOrUpdateBusRouteDetailsRequest createOrUpdateBusRouteDetailsRequest) async {
  print("Raising request to createOrUpdateBusRouteDetails with request ${jsonEncode(createOrUpdateBusRouteDetailsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_BUS_ROUTE_DETAILS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateBusRouteDetailsRequest.toJson()),
  );

  CreateOrUpdateBusRouteDetailsResponse createOrUpdateBusRouteDetailsResponse =
      CreateOrUpdateBusRouteDetailsResponse.fromJson(json.decode(response.body));
  print("CreateOrUpdateBusRouteDetailsResponse ${createOrUpdateBusRouteDetailsResponse.toJson()}");
  return createOrUpdateBusRouteDetailsResponse;
}