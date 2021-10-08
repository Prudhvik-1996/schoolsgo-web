class GetUserDetailsResponse {
  GetUserDetailsResponse({
    required this.errorCode,
    required this.errorMessage,
    required this.httpStatus,
    required this.responseStatus,
    required this.userDetails,
  });
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<UserDetails>? userDetails;

  GetUserDetailsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'] ?? "";
    errorMessage = json['errorMessage'] ?? "";
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
    userDetails = List.from(json['userDetails'])
        .map((e) => UserDetails.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['errorCode'] = errorCode;
    _data['errorMessage'] = errorMessage;
    _data['httpStatus'] = httpStatus;
    _data['responseStatus'] = responseStatus;
    _data['userDetails'] = userDetails!.map((e) => e.toJson()).toList();
    return _data;
  }
}

class UserDetails {
  UserDetails({
    this.firstName,
    this.lastName,
    this.mailId,
    this.status,
    this.userId,
  });
  String? firstName;
  String? lastName;
  String? mailId;
  String? status;
  int? userId;

  UserDetails.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    mailId = json['mailId'];
    status = json['status'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['firstName'] = firstName;
    _data['lastName'] = lastName;
    _data['mailId'] = mailId;
    _data['status'] = status;
    _data['userId'] = userId;
    return _data;
  }
}
