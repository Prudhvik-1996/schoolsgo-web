import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as user_details;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';

Future<user_details.GetUserDetailsResponse> getUserDetails(user_details.UserDetails getUserDetailsRequest) async {
  debugPrint("Raising request to getUserDetails with request ${jsonEncode(getUserDetailsRequest.toJson())}");

  user_details.GetUserDetailsResponse getUserDetailsResponse = await HttpUtils.post(
    SCHOOLS_GO_BASE_URL + GET_USER_DETAILS,
    getUserDetailsRequest.toJson(),
    user_details.GetUserDetailsResponse.fromJson,
    doEncrypt: true,
  );

  debugPrint("GetUserDetailsResponse ${getUserDetailsResponse.toJson()}");
  return getUserDetailsResponse;
}

Future<GetUserRolesDetailsResponse> getUserRoles(GetUserRolesRequest getUserRolesRequest) async {
  debugPrint("Raising request to getUserRoles with request ${jsonEncode(getUserRolesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_USER_ROLES_DETAILS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  http.Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getUserRolesRequest.toJson()),
  );

  GetUserRolesDetailsResponse getUserRolesResponse = GetUserRolesDetailsResponse.fromJson(json.decode(response.body));
  debugPrint("GetUserRolesResponse ${getUserRolesResponse.toJson()}");
  return getUserRolesResponse;
}
