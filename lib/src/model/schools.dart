import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

class GetSchoolInfoRequest {
/*
{
  "schoolId": 92
}
*/

  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetSchoolInfoRequest({
    this.schoolId,
  });
  GetSchoolInfoRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class SchoolInfoBean {

  String? academicYearEndDate;
  String? academicYearStartDate;
  int? agent;
  String? branchCode;
  String? city;
  String? description;
  String? detailedAddress;
  String? displayPictureUrl;
  int? displayPictureUrlId;
  int? estdYear;
  String? examMemoHeader;
  String? faxNumber;
  String? founder;
  int? franchiseId;
  int? linkedSchoolId;
  String? loginId;
  String? logoPhotoUrl;
  int? logoPhotoUrlId;
  String? mailId;
  String? mobile;
  String? principalSignature;
  int? promotedSchoolId;
  String? receiptHeader;
  String? schoolDisplayName;
  int? schoolId;
  String? schoolName;
  String? stampPhotoUrl;
  int? stampPhotoUrlId;
  String? status;
  Map<String, dynamic> __origJson = {};

  SchoolInfoBean({
    this.academicYearEndDate,
    this.academicYearStartDate,
    this.agent,
    this.branchCode,
    this.city,
    this.description,
    this.detailedAddress,
    this.displayPictureUrl,
    this.displayPictureUrlId,
    this.estdYear,
    this.examMemoHeader,
    this.faxNumber,
    this.founder,
    this.franchiseId,
    this.linkedSchoolId,
    this.loginId,
    this.logoPhotoUrl,
    this.logoPhotoUrlId,
    this.mailId,
    this.mobile,
    this.principalSignature,
    this.promotedSchoolId,
    this.receiptHeader,
    this.schoolDisplayName,
    this.schoolId,
    this.schoolName,
    this.stampPhotoUrl,
    this.stampPhotoUrlId,
    this.status,
  });

  SchoolInfoBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearEndDate = json['academicYearEndDate']?.toString();
    academicYearStartDate = json['academicYearStartDate']?.toString();
    agent = json['agent']?.toInt();
    branchCode = json['branchCode']?.toString();
    city = json['city']?.toString();
    description = json['description']?.toString();
    detailedAddress = json['detailedAddress']?.toString();
    displayPictureUrl = json['displayPictureUrl']?.toString();
    displayPictureUrlId = json['displayPictureUrlId']?.toInt();
    estdYear = json['estdYear']?.toInt();
    examMemoHeader = json['examMemoHeader']?.toString();
    faxNumber = json['faxNumber']?.toString();
    founder = json['founder']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    linkedSchoolId = json['linkedSchoolId']?.toInt();
    loginId = json['loginId']?.toString();
    logoPhotoUrl = json['logoPhotoUrl']?.toString();
    logoPhotoUrlId = json['logoPhotoUrlId']?.toInt();
    mailId = json['mailId']?.toString();
    mobile = json['mobile']?.toString();
    principalSignature = json['principalSignature']?.toString();
    promotedSchoolId = json['promotedSchoolId']?.toInt();
    receiptHeader = json['receiptHeader']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    stampPhotoUrl = json['stampPhotoUrl']?.toString();
    stampPhotoUrlId = json['stampPhotoUrlId']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearEndDate'] = academicYearEndDate;
    data['academicYearStartDate'] = academicYearStartDate;
    data['agent'] = agent;
    data['branchCode'] = branchCode;
    data['city'] = city;
    data['description'] = description;
    data['detailedAddress'] = detailedAddress;
    data['displayPictureUrl'] = displayPictureUrl;
    data['displayPictureUrlId'] = displayPictureUrlId;
    data['estdYear'] = estdYear;
    data['examMemoHeader'] = examMemoHeader;
    data['faxNumber'] = faxNumber;
    data['founder'] = founder;
    data['franchiseId'] = franchiseId;
    data['linkedSchoolId'] = linkedSchoolId;
    data['loginId'] = loginId;
    data['logoPhotoUrl'] = logoPhotoUrl;
    data['logoPhotoUrlId'] = logoPhotoUrlId;
    data['mailId'] = mailId;
    data['mobile'] = mobile;
    data['principalSignature'] = principalSignature;
    data['promotedSchoolId'] = promotedSchoolId;
    data['receiptHeader'] = receiptHeader;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['stampPhotoUrl'] = stampPhotoUrl;
    data['stampPhotoUrlId'] = stampPhotoUrlId;
    data['status'] = status;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class GetSchoolInfoResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "schoolInfo": {
    "description": "string",
    "displayPictureUrl": "string",
    "estdYear": 0,
    "faxNumber": "string",
    "founder": "string",
    "mailId": "string",
    "mobile": "string",
    "schoolDisplayName": "string",
    "schoolId": 0,
    "schoolName": "string",
    "stampPhotoUrl": "string",
    "status": "string"
  }
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  SchoolInfoBean? schoolInfo;
  List<SchoolInfoBean?>? schoolsInfo;
  Map<String, dynamic> __origJson = {};

  GetSchoolInfoResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.schoolInfo,
    this.schoolsInfo,
  });
  GetSchoolInfoResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    schoolInfo = (json['schoolInfo'] != null) ? SchoolInfoBean.fromJson(json['schoolInfo']) : null;
    if (json['schoolsInfo'] != null) {
      final v = json['schoolsInfo'];
      final arr0 = <SchoolInfoBean>[];
      v.forEach((v) {
        arr0.add(SchoolInfoBean.fromJson(v));
      });
      schoolsInfo = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (schoolInfo != null) {
      data['schoolInfo'] = schoolInfo!.toJson();
    }
    if (schoolsInfo != null) {
      final v = schoolsInfo;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['busLocationList'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetSchoolInfoResponse> getSchools(GetSchoolInfoRequest getSchoolsRequest) async {
  debugPrint("Raising request to getSchools with request ${jsonEncode(getSchoolsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SCHOOLS_DETAILS;

  GetSchoolInfoResponse getSchoolsResponse = await HttpUtils.post(
    _url,
    getSchoolsRequest.toJson(),
    GetSchoolInfoResponse.fromJson,
  );

  // debugPrint("GetSchoolsResponse ${getSchoolsResponse.toJson()}");
  return getSchoolsResponse;
}

class CreateOrUpdateSchoolInfoRequest {

  String? academicYearEndDate;
  String? academicYearStartDate;
  int? agent;
  String? branchCode;
  String? city;
  String? description;
  String? detailedAddress;
  String? displayPictureUrl;
  int? displayPictureUrlId;
  int? estdYear;
  String? examMemoHeader;
  String? faxNumber;
  String? founder;
  int? franchiseId;
  int? linkedSchoolId;
  String? loginId;
  String? logoPhotoUrl;
  int? logoPhotoUrlId;
  String? mailId;
  String? mobile;
  String? principalSignature;
  int? promotedSchoolId;
  String? receiptHeader;
  String? schoolDisplayName;
  int? schoolId;
  String? schoolName;
  String? stampPhotoUrl;
  int? stampPhotoUrlId;
  String? status;
  Map<String, dynamic> __origJson = {};

  TextEditingController schoolNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController detailedAddressController = TextEditingController();
  TextEditingController branchCodeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController mailIdController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  CreateOrUpdateSchoolInfoRequest({
    this.academicYearEndDate,
    this.academicYearStartDate,
    this.agent,
    this.branchCode,
    this.city,
    this.description,
    this.detailedAddress,
    this.displayPictureUrl,
    this.displayPictureUrlId,
    this.estdYear,
    this.examMemoHeader,
    this.faxNumber,
    this.founder,
    this.franchiseId,
    this.linkedSchoolId,
    this.loginId,
    this.logoPhotoUrl,
    this.logoPhotoUrlId,
    this.mailId,
    this.mobile,
    this.principalSignature,
    this.promotedSchoolId,
    this.receiptHeader,
    this.schoolDisplayName,
    this.schoolId,
    this.schoolName,
    this.stampPhotoUrl,
    this.stampPhotoUrlId,
    this.status,
  });
  CreateOrUpdateSchoolInfoRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    academicYearEndDate = json['academicYearEndDate']?.toString();
    academicYearStartDate = json['academicYearStartDate']?.toString();
    agent = json['agent']?.toInt();
    branchCode = json['branchCode']?.toString();
    city = json['city']?.toString();
    description = json['description']?.toString();
    detailedAddress = json['detailedAddress']?.toString();
    displayPictureUrl = json['displayPictureUrl']?.toString();
    displayPictureUrlId = json['displayPictureUrlId']?.toInt();
    estdYear = json['estdYear']?.toInt();
    examMemoHeader = json['examMemoHeader']?.toString();
    faxNumber = json['faxNumber']?.toString();
    founder = json['founder']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    linkedSchoolId = json['linkedSchoolId']?.toInt();
    loginId = json['loginId']?.toString();
    logoPhotoUrl = json['logoPhotoUrl']?.toString();
    logoPhotoUrlId = json['logoPhotoUrlId']?.toInt();
    mailId = json['mailId']?.toString();
    mobile = json['mobile']?.toString();
    principalSignature = json['principalSignature']?.toString();
    promotedSchoolId = json['promotedSchoolId']?.toInt();
    receiptHeader = json['receiptHeader']?.toString();
    schoolDisplayName = json['schoolDisplayName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    stampPhotoUrl = json['stampPhotoUrl']?.toString();
    stampPhotoUrlId = json['stampPhotoUrlId']?.toInt();
    status = json['status']?.toString();
    schoolNameController.text = schoolName ?? '';
    cityController.text = city ?? '';
    detailedAddressController.text = detailedAddress ?? '';
    branchCodeController.text = branchCode ?? '';
    descriptionController.text = description ?? '';
    mailIdController.text = mailId ?? '';
    mobileController.text = mobile ?? '';
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['academicYearEndDate'] = academicYearEndDate;
    data['academicYearStartDate'] = academicYearStartDate;
    data['agent'] = agent;
    data['branchCode'] = branchCode;
    data['city'] = city;
    data['description'] = description;
    data['detailedAddress'] = detailedAddress;
    data['displayPictureUrl'] = displayPictureUrl;
    data['displayPictureUrlId'] = displayPictureUrlId;
    data['estdYear'] = estdYear;
    data['examMemoHeader'] = examMemoHeader;
    data['faxNumber'] = faxNumber;
    data['founder'] = founder;
    data['franchiseId'] = franchiseId;
    data['linkedSchoolId'] = linkedSchoolId;
    data['loginId'] = loginId;
    data['logoPhotoUrl'] = logoPhotoUrl;
    data['logoPhotoUrlId'] = logoPhotoUrlId;
    data['mailId'] = mailId;
    data['mobile'] = mobile;
    data['principalSignature'] = principalSignature;
    data['promotedSchoolId'] = promotedSchoolId;
    data['receiptHeader'] = receiptHeader;
    data['schoolDisplayName'] = schoolDisplayName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['stampPhotoUrl'] = stampPhotoUrl;
    data['stampPhotoUrlId'] = stampPhotoUrlId;
    data['status'] = status;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateSchoolInfoResponse {

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateSchoolInfoResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateSchoolInfoResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateSchoolInfoResponse> createOrUpdateSchoolInfo(CreateOrUpdateSchoolInfoRequest createOrUpdateSchoolInfoRequest) async {
  debugPrint("Raising request to createOrUpdateSchoolInfo with request ${jsonEncode(createOrUpdateSchoolInfoRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SCHOOL_INFO;

  CreateOrUpdateSchoolInfoResponse createOrUpdateSchoolInfoResponse = await HttpUtils.post(
    _url,
    createOrUpdateSchoolInfoRequest.toJson(),
    CreateOrUpdateSchoolInfoResponse.fromJson,
  );

  debugPrint("CreateOrUpdateSchoolInfoResponse ${createOrUpdateSchoolInfoResponse.toJson()}");
  return createOrUpdateSchoolInfoResponse;
}