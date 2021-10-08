import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/model/user_details.dart' as userDetails;
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

Future<userDetails.GetUserDetailsResponse> getUserDetails(
    userDetails.UserDetails getUserDetailsRequest) async {
  print(
      "Raising request to getUserDetails with request ${jsonEncode(getUserDetailsRequest.toJson())}");
  Map<String, String> _headers = {
    "Content-type": "application/json",
    "Access-Control-Allow-Origin": "*"
  };

  http.Response response = await http.post(
    Uri.parse(SCHOOLS_GO_BASE_URL + GET_USER_DETAILS),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(getUserDetailsRequest.toJson()),
  );

  print("Response: ${json.decode(response.body)}");

  userDetails.GetUserDetailsResponse getUserDetailsResponse =
      userDetails.GetUserDetailsResponse.fromJson(json.decode(response.body));
  print("GetUserDetailsResponse ${getUserDetailsResponse.toJson()}");
  return getUserDetailsResponse;
}

Future<GetUserRolesResponse> getUserRoles(
    GetUserRolesRequest getUserRolesRequest) async {
  print(
      "Raising request to getUserRoles with request ${jsonEncode(getUserRolesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_USER_ROLES_DETAILS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  http.Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getUserRolesRequest.toJson()),
  );

  GetUserRolesResponse getUserRolesRespone =
      GetUserRolesResponse.fromJson(json.decode(response.body));
  print("GetUserRolesResponse ${getUserRolesRespone.toJson()}");
  return getUserRolesRespone;
}
