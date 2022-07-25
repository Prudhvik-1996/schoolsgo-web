// import 'dart:convert';
//
// import 'package:http/http.dart';
// import 'package:schoolsgo_web/src/constants/constants.dart';
//
// class GetFeeTypesRequest {
// /*
// {
//   "schoolId": 0,
//   "sectionId": 0,
//   "studentId": 0
// }
// */
//
//   int? schoolId;
//   int? sectionId;
//   int? studentId;
//   Map<String, dynamic> __origJson = {};
//
//   GetFeeTypesRequest({
//     this.schoolId,
//     this.sectionId,
//     this.studentId,
//   });
//   GetFeeTypesRequest.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
//     sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
//     studentId = int.tryParse(json['studentId']?.toString() ?? '');
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['schoolId'] = schoolId;
//     data['sectionId'] = sectionId;
//     data['studentId'] = studentId;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// class CustomFee {
// /*
// {
//   "agent": 0,
//   "createTime": 0,
//   "customFeeAmount": 0,
//   "customFeeDescription": "string",
//   "customFeeId": 0,
//   "feeType": "string",
//   "feeTypeAmount": 0,
//   "feeTypeDescription": "string",
//   "feeTypeId": 0,
//   "lastUpdated": 0,
//   "schoolDisplayName": "string",
//   "schoolId": 0,
//   "schoolName": "string",
//   "selectType": "NONE",
//   "status": "active"
// }
// */
//
//   int? agent;
//   int? createTime;
//   int? customFeeAmount;
//   String? customFeeDescription;
//   int? customFeeId;
//   String? feeType;
//   int? feeTypeAmount;
//   String? feeTypeDescription;
//   int? feeTypeId;
//   int? lastUpdated;
//   String? schoolDisplayName;
//   int? schoolId;
//   String? schoolName;
//   String? selectType;
//   String? status;
//   Map<String, dynamic> __origJson = {};
//
//   CustomFee({
//     this.agent,
//     this.createTime,
//     this.customFeeAmount,
//     this.customFeeDescription,
//     this.customFeeId,
//     this.feeType,
//     this.feeTypeAmount,
//     this.feeTypeDescription,
//     this.feeTypeId,
//     this.lastUpdated,
//     this.schoolDisplayName,
//     this.schoolId,
//     this.schoolName,
//     this.selectType,
//     this.status,
//   });
//   CustomFee.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     agent = int.tryParse(json['agent']?.toString() ?? '');
//     createTime = int.tryParse(json['createTime']?.toString() ?? '');
//     customFeeAmount = int.tryParse(json['customFeeAmount']?.toString() ?? '');
//     customFeeDescription = json['customFeeDescription']?.toString();
//     customFeeId = int.tryParse(json['customFeeId']?.toString() ?? '');
//     feeType = json['feeType']?.toString();
//     feeTypeAmount = int.tryParse(json['feeTypeAmount']?.toString() ?? '');
//     feeTypeDescription = json['feeTypeDescription']?.toString();
//     feeTypeId = int.tryParse(json['feeTypeId']?.toString() ?? '');
//     lastUpdated = int.tryParse(json['lastUpdated']?.toString() ?? '');
//     schoolDisplayName = json['schoolDisplayName']?.toString();
//     schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
//     schoolName = json['schoolName']?.toString();
//     selectType = json['selectType']?.toString();
//     status = json['status']?.toString();
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['agent'] = agent;
//     data['createTime'] = createTime;
//     data['customFeeAmount'] = customFeeAmount;
//     data['customFeeDescription'] = customFeeDescription;
//     data['customFeeId'] = customFeeId;
//     data['feeType'] = feeType;
//     data['feeTypeAmount'] = feeTypeAmount;
//     data['feeTypeDescription'] = feeTypeDescription;
//     data['feeTypeId'] = feeTypeId;
//     data['lastUpdated'] = lastUpdated;
//     data['schoolDisplayName'] = schoolDisplayName;
//     data['schoolId'] = schoolId;
//     data['schoolName'] = schoolName;
//     data['selectType'] = selectType;
//     data['status'] = status;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// class FeeType {
// /*
// {
//   "agent": 0,
//   "amount": 0,
//   "createTime": 0,
//   "customFeeBeans": [
//     {
//       "agent": 0,
//       "createTime": 0,
//       "customFeeAmount": 0,
//       "customFeeDescription": "string",
//       "customFeeId": 0,
//       "feeType": "string",
//       "feeTypeAmount": 0,
//       "feeTypeDescription": "string",
//       "feeTypeId": 0,
//       "lastUpdated": 0,
//       "schoolDisplayName": "string",
//       "schoolId": 0,
//       "schoolName": "string",
//       "selectType": "NONE",
//       "status": "active"
//     }
//   ],
//   "description": "string",
//   "feeType": "string",
//   "feeTypeId": 0,
//   "lastUpdated": 0,
//   "schoolDisplayName": "string",
//   "schoolId": 0,
//   "schoolName": "string",
//   "selectType": "NONE",
//   "seqOrder": 0,
//   "status": "active"
// }
// */
//
//   int? agent;
//   int? amount;
//   int? createTime;
//   List<CustomFee?>? customFeeBeans;
//   String? description;
//   String? feeType;
//   int? feeTypeId;
//   int? lastUpdated;
//   String? schoolDisplayName;
//   int? schoolId;
//   String? schoolName;
//   String? selectType;
//   int? seqOrder;
//   String? status;
//   Map<String, dynamic> __origJson = {};
//
//   FeeType({
//     this.agent,
//     this.amount,
//     this.createTime,
//     this.customFeeBeans,
//     this.description,
//     this.feeType,
//     this.feeTypeId,
//     this.lastUpdated,
//     this.schoolDisplayName,
//     this.schoolId,
//     this.schoolName,
//     this.selectType,
//     this.seqOrder,
//     this.status,
//   });
//   FeeType.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     agent = int.tryParse(json['agent']?.toString() ?? '');
//     amount = int.tryParse(json['amount']?.toString() ?? '');
//     createTime = int.tryParse(json['createTime']?.toString() ?? '');
//     if (json['customFeeBeans'] != null && (json['customFeeBeans'] is List)) {
//       final v = json['customFeeBeans'];
//       final arr0 = <CustomFee>[];
//       v.forEach((v) {
//         arr0.add(CustomFee.fromJson(v));
//       });
//       customFeeBeans = arr0;
//     }
//     description = json['description']?.toString();
//     feeType = json['feeType']?.toString();
//     feeTypeId = int.tryParse(json['feeTypeId']?.toString() ?? '');
//     lastUpdated = int.tryParse(json['lastUpdated']?.toString() ?? '');
//     schoolDisplayName = json['schoolDisplayName']?.toString();
//     schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
//     schoolName = json['schoolName']?.toString();
//     selectType = json['selectType']?.toString();
//     seqOrder = int.tryParse(json['seqOrder']?.toString() ?? '');
//     status = json['status']?.toString();
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['agent'] = agent;
//     data['amount'] = amount;
//     data['createTime'] = createTime;
//     if (customFeeBeans != null) {
//       final v = customFeeBeans;
//       final arr0 = [];
//       for (var v in v!) {
//         arr0.add(v!.toJson());
//       }
//       data['customFeeBeans'] = arr0;
//     }
//     data['description'] = description;
//     data['feeType'] = feeType;
//     data['feeTypeId'] = feeTypeId;
//     data['lastUpdated'] = lastUpdated;
//     data['schoolDisplayName'] = schoolDisplayName;
//     data['schoolId'] = schoolId;
//     data['schoolName'] = schoolName;
//     data['selectType'] = selectType;
//     data['seqOrder'] = seqOrder;
//     data['status'] = status;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// class GetFeeTypesResponse {
// /*
// {
//   "errorCode": "INTERNAL_SERVER_ERROR",
//   "errorMessage": "string",
//   "feeTypeBeans": [
//     {
//       "agent": 0,
//       "amount": 0,
//       "createTime": 0,
//       "customFeeBeans": [
//         {
//           "agent": 0,
//           "createTime": 0,
//           "customFeeAmount": 0,
//           "customFeeDescription": "string",
//           "customFeeId": 0,
//           "feeType": "string",
//           "feeTypeAmount": 0,
//           "feeTypeDescription": "string",
//           "feeTypeId": 0,
//           "lastUpdated": 0,
//           "schoolDisplayName": "string",
//           "schoolId": 0,
//           "schoolName": "string",
//           "selectType": "NONE",
//           "status": "active"
//         }
//       ],
//       "description": "string",
//       "feeType": "string",
//       "feeTypeId": 0,
//       "lastUpdated": 0,
//       "schoolDisplayName": "string",
//       "schoolId": 0,
//       "schoolName": "string",
//       "selectType": "NONE",
//       "seqOrder": 0,
//       "status": "active"
//     }
//   ],
//   "httpStatus": "100",
//   "responseStatus": "success"
// }
// */
//
//   String? errorCode;
//   String? errorMessage;
//   List<FeeType?>? feeTypeBeans;
//   String? httpStatus;
//   String? responseStatus;
//   Map<String, dynamic> __origJson = {};
//
//   GetFeeTypesResponse({
//     this.errorCode,
//     this.errorMessage,
//     this.feeTypeBeans,
//     this.httpStatus,
//     this.responseStatus,
//   });
//   GetFeeTypesResponse.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     errorCode = json['errorCode']?.toString();
//     errorMessage = json['errorMessage']?.toString();
//     if (json['feeTypeBeans'] != null && (json['feeTypeBeans'] is List)) {
//       final v = json['feeTypeBeans'];
//       final arr0 = <FeeType>[];
//       v.forEach((v) {
//         arr0.add(FeeType.fromJson(v));
//       });
//       feeTypeBeans = arr0;
//     }
//     httpStatus = json['httpStatus']?.toString();
//     responseStatus = json['responseStatus']?.toString();
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['errorCode'] = errorCode;
//     data['errorMessage'] = errorMessage;
//     if (feeTypeBeans != null) {
//       final v = feeTypeBeans;
//       final arr0 = [];
//       for (var v in v!) {
//         arr0.add(v!.toJson());
//       }
//       data['feeTypeBeans'] = arr0;
//     }
//     data['httpStatus'] = httpStatus;
//     data['responseStatus'] = responseStatus;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// Future<GetFeeTypesResponse> getFeeTypes(
//     GetFeeTypesRequest getFeeTypesRequest) async {
//   debugPrint(
//       "Raising request to getFeeTypes with request ${jsonEncode(getFeeTypesRequest.toJson())}");
//   String _url = SCHOOLS_GO_BASE_URL + GET_FEE_TYPES;
//   Map<String, String> _headers = {"Content-type": "application/json"};
//
//   Response response = await post(
//     Uri.parse(_url),
//     headers: _headers,
//     body: jsonEncode(getFeeTypesRequest.toJson()),
//   );
//
//   GetFeeTypesResponse getFeeTypesResponse =
//       GetFeeTypesResponse.fromJson(json.decode(response.body));
//   debugPrint("GetFeeTypesResponse ${getFeeTypesResponse.toJson()}");
//   return getFeeTypesResponse;
// }
//
// class GetCustomFeesRequest {
// /*
// {
//   "feeTypeId": 0,
//   "schoolId": 0,
//   "sectionId": 0,
//   "studentId": 0
// }
// */
//
//   int? feeTypeId;
//   int? schoolId;
//   int? sectionId;
//   int? studentId;
//   Map<String, dynamic> __origJson = {};
//
//   GetCustomFeesRequest({
//     this.feeTypeId,
//     this.schoolId,
//     this.sectionId,
//     this.studentId,
//   });
//   GetCustomFeesRequest.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     feeTypeId = int.tryParse(json['feeTypeId']?.toString() ?? '');
//     schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
//     sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
//     studentId = int.tryParse(json['studentId']?.toString() ?? '');
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['feeTypeId'] = feeTypeId;
//     data['schoolId'] = schoolId;
//     data['sectionId'] = sectionId;
//     data['studentId'] = studentId;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// class GetCustomFeesResponse {
// /*
// {
//   "customFeeBeans": [
//     {
//       "agent": 0,
//       "createTime": 0,
//       "customFeeAmount": 0,
//       "customFeeDescription": "string",
//       "customFeeId": 0,
//       "feeType": "string",
//       "feeTypeAmount": 0,
//       "feeTypeDescription": "string",
//       "feeTypeId": 0,
//       "lastUpdated": 0,
//       "schoolDisplayName": "string",
//       "schoolId": 0,
//       "schoolName": "string",
//       "selectType": "NONE",
//       "status": "active"
//     }
//   ],
//   "errorCode": "INTERNAL_SERVER_ERROR",
//   "errorMessage": "string",
//   "httpStatus": "100",
//   "responseStatus": "success"
// }
// */
//
//   List<CustomFee?>? customFeeBeans;
//   String? errorCode;
//   String? errorMessage;
//   String? httpStatus;
//   String? responseStatus;
//   Map<String, dynamic> __origJson = {};
//
//   GetCustomFeesResponse({
//     this.customFeeBeans,
//     this.errorCode,
//     this.errorMessage,
//     this.httpStatus,
//     this.responseStatus,
//   });
//   GetCustomFeesResponse.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     if (json['customFeeBeans'] != null && (json['customFeeBeans'] is List)) {
//       final v = json['customFeeBeans'];
//       final arr0 = <CustomFee>[];
//       v.forEach((v) {
//         arr0.add(CustomFee.fromJson(v));
//       });
//       customFeeBeans = arr0;
//     }
//     errorCode = json['errorCode']?.toString();
//     errorMessage = json['errorMessage']?.toString();
//     httpStatus = json['httpStatus']?.toString();
//     responseStatus = json['responseStatus']?.toString();
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     if (customFeeBeans != null) {
//       final v = customFeeBeans;
//       final arr0 = [];
//       for (var v in v!) {
//         arr0.add(v!.toJson());
//       }
//       data['customFeeBeans'] = arr0;
//     }
//     data['errorCode'] = errorCode;
//     data['errorMessage'] = errorMessage;
//     data['httpStatus'] = httpStatus;
//     data['responseStatus'] = responseStatus;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// Future<GetCustomFeesResponse> getCustomFees(
//     GetCustomFeesRequest getCustomFeesRequest) async {
//   debugPrint(
//       "Raising request to getCustomFees with request ${jsonEncode(getCustomFeesRequest.toJson())}");
//   String _url = SCHOOLS_GO_BASE_URL + GET_CUSTOM_FEE_TYPES;
//   Map<String, String> _headers = {"Content-type": "application/json"};
//
//   Response response = await post(
//     Uri.parse(_url),
//     headers: _headers,
//     body: jsonEncode(getCustomFeesRequest.toJson()),
//   );
//
//   GetCustomFeesResponse getCustomFeesResponse =
//       GetCustomFeesResponse.fromJson(json.decode(response.body));
//   debugPrint("GetCustomFeesResponse ${getCustomFeesResponse.toJson()}");
//   return getCustomFeesResponse;
// }
//
// class GetFeeMapRequest {
// /*
// {
//   "customFeeId": 0,
//   "feeTypeId": 0,
//   "schoolId": 0,
//   "sectionId": 0,
//   "studentId": 0
// }
// */
//
//   int? customFeeId;
//   int? feeTypeId;
//   int? schoolId;
//   int? sectionId;
//   int? studentId;
//   Map<String, dynamic> __origJson = {};
//
//   GetFeeMapRequest({
//     this.customFeeId,
//     this.feeTypeId,
//     this.schoolId,
//     this.sectionId,
//     this.studentId,
//   });
//   GetFeeMapRequest.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     customFeeId = int.tryParse(json['customFeeId']?.toString() ?? '');
//     feeTypeId = int.tryParse(json['feeTypeId']?.toString() ?? '');
//     schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
//     sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
//     studentId = int.tryParse(json['studentId']?.toString() ?? '');
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['customFeeId'] = customFeeId;
//     data['feeTypeId'] = feeTypeId;
//     data['schoolId'] = schoolId;
//     data['sectionId'] = sectionId;
//     data['studentId'] = studentId;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// class FeeMap {
// /*
// {
//   "agent": 0,
//   "createTime": 0,
//   "customFeeAmount": 0,
//   "customFeeDescription": "string",
//   "customFeeId": 0,
//   "feeMapAmount": 0,
//   "feeMapDescription": "string",
//   "feeMapId": 0,
//   "feeSelectType": "NONE",
//   "feeType": "string",
//   "feeTypeAmount": 0,
//   "feeTypeDescription": "string",
//   "feeTypeId": 0,
//   "lastUpdated": 0,
//   "schoolDisplayName": "string",
//   "schoolId": 0,
//   "schoolName": "string",
//   "sectionId": 0,
//   "sectionName": "string",
//   "status": "active",
//   "studentId": 0
// }
// */
//
//   int? agent;
//   int? createTime;
//   int? customFeeAmount;
//   String? customFeeDescription;
//   int? customFeeId;
//   int? feeMapAmount;
//   String? feeMapDescription;
//   int? feeMapId;
//   String? feeSelectType;
//   String? feeType;
//   int? feeTypeAmount;
//   String? feeTypeDescription;
//   int? feeTypeId;
//   int? lastUpdated;
//   String? schoolDisplayName;
//   int? schoolId;
//   String? schoolName;
//   int? sectionId;
//   String? sectionName;
//   String? status;
//   int? studentId;
//   Map<String, dynamic> __origJson = {};
//
//   FeeMap({
//     this.agent,
//     this.createTime,
//     this.customFeeAmount,
//     this.customFeeDescription,
//     this.customFeeId,
//     this.feeMapAmount,
//     this.feeMapDescription,
//     this.feeMapId,
//     this.feeSelectType,
//     this.feeType,
//     this.feeTypeAmount,
//     this.feeTypeDescription,
//     this.feeTypeId,
//     this.lastUpdated,
//     this.schoolDisplayName,
//     this.schoolId,
//     this.schoolName,
//     this.sectionId,
//     this.sectionName,
//     this.status,
//     this.studentId,
//   });
//   FeeMap.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     agent = int.tryParse(json['agent']?.toString() ?? '');
//     createTime = int.tryParse(json['createTime']?.toString() ?? '');
//     customFeeAmount = int.tryParse(json['customFeeAmount']?.toString() ?? '');
//     customFeeDescription = json['customFeeDescription']?.toString();
//     customFeeId = int.tryParse(json['customFeeId']?.toString() ?? '');
//     feeMapAmount = int.tryParse(json['feeMapAmount']?.toString() ?? '');
//     feeMapDescription = json['feeMapDescription']?.toString();
//     feeMapId = int.tryParse(json['feeMapId']?.toString() ?? '');
//     feeSelectType = json['feeSelectType']?.toString();
//     feeType = json['feeType']?.toString();
//     feeTypeAmount = int.tryParse(json['feeTypeAmount']?.toString() ?? '');
//     feeTypeDescription = json['feeTypeDescription']?.toString();
//     feeTypeId = int.tryParse(json['feeTypeId']?.toString() ?? '');
//     lastUpdated = int.tryParse(json['lastUpdated']?.toString() ?? '');
//     schoolDisplayName = json['schoolDisplayName']?.toString();
//     schoolId = int.tryParse(json['schoolId']?.toString() ?? '');
//     schoolName = json['schoolName']?.toString();
//     sectionId = int.tryParse(json['sectionId']?.toString() ?? '');
//     sectionName = json['sectionName']?.toString();
//     status = json['status']?.toString();
//     studentId = int.tryParse(json['studentId']?.toString() ?? '');
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['agent'] = agent;
//     data['createTime'] = createTime;
//     data['customFeeAmount'] = customFeeAmount;
//     data['customFeeDescription'] = customFeeDescription;
//     data['customFeeId'] = customFeeId;
//     data['feeMapAmount'] = feeMapAmount;
//     data['feeMapDescription'] = feeMapDescription;
//     data['feeMapId'] = feeMapId;
//     data['feeSelectType'] = feeSelectType;
//     data['feeType'] = feeType;
//     data['feeTypeAmount'] = feeTypeAmount;
//     data['feeTypeDescription'] = feeTypeDescription;
//     data['feeTypeId'] = feeTypeId;
//     data['lastUpdated'] = lastUpdated;
//     data['schoolDisplayName'] = schoolDisplayName;
//     data['schoolId'] = schoolId;
//     data['schoolName'] = schoolName;
//     data['sectionId'] = sectionId;
//     data['sectionName'] = sectionName;
//     data['status'] = status;
//     data['studentId'] = studentId;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// class GetFeeMapResponse {
// /*
// {
//   "errorCode": "INTERNAL_SERVER_ERROR",
//   "errorMessage": "string",
//   "feeMapBeans": [
//     {
//       "agent": 0,
//       "createTime": 0,
//       "customFeeAmount": 0,
//       "customFeeDescription": "string",
//       "customFeeId": 0,
//       "feeMapAmount": 0,
//       "feeMapDescription": "string",
//       "feeMapId": 0,
//       "feeSelectType": "NONE",
//       "feeType": "string",
//       "feeTypeAmount": 0,
//       "feeTypeDescription": "string",
//       "feeTypeId": 0,
//       "lastUpdated": 0,
//       "schoolDisplayName": "string",
//       "schoolId": 0,
//       "schoolName": "string",
//       "sectionId": 0,
//       "sectionName": "string",
//       "status": "active",
//       "studentId": 0
//     }
//   ],
//   "httpStatus": "100",
//   "responseStatus": "success"
// }
// */
//
//   String? errorCode;
//   String? errorMessage;
//   List<FeeMap?>? feeMapBeans;
//   String? httpStatus;
//   String? responseStatus;
//   Map<String, dynamic> __origJson = {};
//
//   GetFeeMapResponse({
//     this.errorCode,
//     this.errorMessage,
//     this.feeMapBeans,
//     this.httpStatus,
//     this.responseStatus,
//   });
//   GetFeeMapResponse.fromJson(Map<String, dynamic> json) {
//     __origJson = json;
//     errorCode = json['errorCode']?.toString();
//     errorMessage = json['errorMessage']?.toString();
//     if (json['feeMapBeans'] != null && (json['feeMapBeans'] is List)) {
//       final v = json['feeMapBeans'];
//       final arr0 = <FeeMap>[];
//       v.forEach((v) {
//         arr0.add(FeeMap.fromJson(v));
//       });
//       feeMapBeans = arr0;
//     }
//     httpStatus = json['httpStatus']?.toString();
//     responseStatus = json['responseStatus']?.toString();
//   }
//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['errorCode'] = errorCode;
//     data['errorMessage'] = errorMessage;
//     if (feeMapBeans != null) {
//       final v = feeMapBeans;
//       final arr0 = [];
//       v!.forEach((v) {
//         arr0.add(v!.toJson());
//       });
//       data['feeMapBeans'] = arr0;
//     }
//     data['httpStatus'] = httpStatus;
//     data['responseStatus'] = responseStatus;
//     return data;
//   }
//
//   Map<String, dynamic> origJson() => __origJson;
// }
//
// Future<GetFeeMapResponse> getFeeMap(GetFeeMapRequest getFeeMapRequest) async {
//   debugPrint(
//       "Raising request to getFeeMap with request ${jsonEncode(getFeeMapRequest.toJson())}");
//   String _url = SCHOOLS_GO_BASE_URL + GET_FEE_MAP;
//   Map<String, String> _headers = {"Content-type": "application/json"};
//
//   Response response = await post(
//     Uri.parse(_url),
//     headers: _headers,
//     body: jsonEncode(getFeeMapRequest.toJson()),
//   );
//
//   GetFeeMapResponse getFeeMapResponse =
//       GetFeeMapResponse.fromJson(json.decode(response.body));
//   debugPrint("GetFeeMapResponse ${getFeeMapResponse.toJson()}");
//   return getFeeMapResponse;
// }
