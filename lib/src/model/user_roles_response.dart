import 'dart:convert';

import 'package:http/http.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';

/// adminProfiles : [{"agent":0,"firstName":"string","lastName":"string","mailId":"string","middleName":"string","schoolId":0,"schoolName":"string","schoolPhotoUrl":"string","userId":0}]
/// errorCode : "INTERNAL_SERVER_ERROR"
/// errorMessage : "string"
/// httpStatus : "100"
/// responseStatus : "success"
/// studentProfiles : [{"balanceAmount":0,"fatherName":"string","gaurdianFirstName":"string","gaurdianId":0,"gaurdianLastName":"string","gaurdianMailId":"string","gaurdianMiddleName":"string","gaurdianMobile":"string","motherName":"string","rollNumber":"string","schoolId":0,"schoolName":"string","schoolPhotoUrl":"string","sectionDescription":"string","sectionId":0,"sectionName":"string","studentDob":"string","studentFirstName":"string","studentId":0,"studentLastName":"string","studentMailId":"string","studentMiddleName":"string","studentMobile":"string","studentPhotoUrl":"string"}]
/// teacherProfiles : [{"agent":"string","description":"string","dob":0,"fatherName":"string","firstName":"string","lastName":"string","mailId":"string","middleName":"string","motherName":"string","schoolId":0,"schoolName":"string","schoolPhotoUrl":"string","teacherId":0,"teacherName":"string","teacherPhotoUrl":"string"}]
/// userDetails : {"agent":"string","createTime":0,"firstName":"string","lastLogin":0,"lastName":"string","lastUpdatedTime":0,"mailId":"string","middleName":"string","mobile":"string","password":"string","passwordExpiryDate":0,"status":"active","userId":0}

class GetUserRolesRequest {
  int? schoolId;
  int? userId;

  GetUserRolesRequest({this.schoolId, this.userId});

  GetUserRolesRequest.fromJson(dynamic json) {
    schoolId = json['schoolId'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['schoolId'] = schoolId;
    map['userId'] = userId;
    return map;
  }
}

class UserDetails {
/*
{
  "agent": "string",
  "createTime": 0,
  "firstName": "string",
  "lastLogin": 0,
  "lastName": "string",
  "lastUpdatedTime": 0,
  "mailId": "string",
  "middleName": "string",
  "mobile": "string",
  "password": "string",
  "passwordExpiryDate": 0,
  "status": "active",
  "userId": 0
}
*/

  String? agent;
  int? createTime;
  String? firstName;
  int? lastLogin;
  String? lastName;
  int? lastUpdatedTime;
  String? mailId;
  String? middleName;
  String? mobile;
  String? password;
  int? passwordExpiryDate;
  String? status;
  int? userId;
  Map<String, dynamic> __origJson = {};

  UserDetails({
    this.agent,
    this.createTime,
    this.firstName,
    this.lastLogin,
    this.lastName,
    this.lastUpdatedTime,
    this.mailId,
    this.middleName,
    this.mobile,
    this.password,
    this.passwordExpiryDate,
    this.status,
    this.userId,
  });
  UserDetails.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    createTime = json['createTime']?.toInt();
    firstName = json['firstName']?.toString();
    lastLogin = json['lastLogin']?.toInt();
    lastName = json['lastName']?.toString();
    lastUpdatedTime = json['lastUpdatedTime']?.toInt();
    mailId = json['mailId']?.toString();
    middleName = json['middleName']?.toString();
    mobile = json['mobile']?.toString();
    password = json['password']?.toString();
    passwordExpiryDate = json['passwordExpiryDate']?.toInt();
    status = json['status']?.toString();
    userId = json['userId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['createTime'] = createTime;
    data['firstName'] = firstName;
    data['lastLogin'] = lastLogin;
    data['lastName'] = lastName;
    data['lastUpdatedTime'] = lastUpdatedTime;
    data['mailId'] = mailId;
    data['middleName'] = middleName;
    data['mobile'] = mobile;
    data['password'] = password;
    data['passwordExpiryDate'] = passwordExpiryDate;
    data['status'] = status;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class TeacherProfile {
/*
{
  "agent": "string",
  "description": "string",
  "dob": 0,
  "fatherName": "string",
  "firstName": "string",
  "lastName": "string",
  "mailId": "string",
  "middleName": "string",
  "motherName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "teacherId": 0,
  "teacherName": "string",
  "teacherPhotoUrl": "string"
}
*/

  String? agent;
  String? description;
  int? dob;
  String? fatherName;
  String? firstName;
  String? lastName;
  String? mailId;
  String? middleName;
  String? motherName;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  int? teacherId;
  String? teacherName;
  String? teacherPhotoUrl;
  int? franchiseId;
  String? franchiseName;
  Map<String, dynamic> __origJson = {};

  TeacherProfile({
    this.agent,
    this.description,
    this.dob,
    this.fatherName,
    this.firstName,
    this.lastName,
    this.mailId,
    this.middleName,
    this.motherName,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.teacherId,
    this.teacherName,
    this.teacherPhotoUrl,
    this.franchiseId,
    this.franchiseName,
  });
  TeacherProfile.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    description = json['description']?.toString();
    dob = json['dob']?.toInt();
    fatherName = json['fatherName']?.toString();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    mailId = json['mailId']?.toString();
    middleName = json['middleName']?.toString();
    motherName = json['motherName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
    teacherPhotoUrl = json['teacherPhotoUrl']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['description'] = description;
    data['dob'] = dob;
    data['fatherName'] = fatherName;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['mailId'] = mailId;
    data['middleName'] = middleName;
    data['motherName'] = motherName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['teacherPhotoUrl'] = teacherPhotoUrl;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentProfile {
/*
{
  "balanceAmount": 0,
  "fatherName": "string",
  "gaurdianFirstName": "string",
  "gaurdianId": 0,
  "gaurdianLastName": "string",
  "gaurdianMailId": "string",
  "gaurdianMiddleName": "string",
  "gaurdianMobile": "string",
  "motherName": "string",
  "rollNumber": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "sectionDescription": "string",
  "sectionId": 0,
  "sectionName": "string",
  "studentDob": "string",
  "studentFirstName": "string",
  "studentId": 0,
  "studentLastName": "string",
  "studentMailId": "string",
  "studentMiddleName": "string",
  "studentMobile": "string",
  "studentPhotoUrl": "string"
}
*/

  int? balanceAmount;
  String? fatherName;
  String? gaurdianFirstName;
  int? gaurdianId;
  String? gaurdianLastName;
  String? gaurdianMailId;
  String? gaurdianMiddleName;
  String? gaurdianMobile;
  String? motherName;
  String? rollNumber;
  int? schoolId;
  String? schoolName;
  String? branchCode;
  String? schoolPhotoUrl;
  String? sectionDescription;
  int? sectionId;
  String? sectionName;
  String? studentDob;
  String? studentFirstName;
  int? studentId;
  String? studentLastName;
  String? studentMailId;
  String? studentMiddleName;
  String? studentMobile;
  String? studentPhotoUrl;
  int? franchiseId;
  String? franchiseName;
  bool? isAssignedToBusStop;
  Map<String, dynamic> __origJson = {};

  StudentProfile(
      {this.balanceAmount,
      this.fatherName,
      this.gaurdianFirstName,
      this.gaurdianId,
      this.gaurdianLastName,
      this.gaurdianMailId,
      this.gaurdianMiddleName,
      this.gaurdianMobile,
      this.motherName,
      this.rollNumber,
      this.schoolId,
      this.schoolName,
      this.branchCode,
      this.schoolPhotoUrl,
      this.sectionDescription,
      this.sectionId,
      this.sectionName,
      this.studentDob,
      this.studentFirstName,
      this.studentId,
      this.studentLastName,
      this.studentMailId,
      this.studentMiddleName,
      this.studentMobile,
      this.studentPhotoUrl,
      this.franchiseId,
      this.franchiseName,
      this.isAssignedToBusStop});
  StudentProfile.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    balanceAmount = json['balanceAmount']?.toInt();
    fatherName = json['fatherName']?.toString();
    gaurdianFirstName = json['gaurdianFirstName']?.toString();
    gaurdianId = json['gaurdianId']?.toInt();
    gaurdianLastName = json['gaurdianLastName']?.toString();
    gaurdianMailId = json['gaurdianMailId']?.toString();
    gaurdianMiddleName = json['gaurdianMiddleName']?.toString();
    gaurdianMobile = json['gaurdianMobile']?.toString();
    motherName = json['motherName']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    branchCode = json['branchCode']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    sectionDescription = json['sectionDescription']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentDob = json['studentDob']?.toString();
    studentFirstName = json['studentFirstName']?.toString();
    studentId = json['studentId']?.toInt();
    studentLastName = json['studentLastName']?.toString();
    studentMailId = json['studentMailId']?.toString();
    studentMiddleName = json['studentMiddleName']?.toString();
    studentMobile = json['studentMobile']?.toString();
    studentPhotoUrl = json['studentPhotoUrl']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    isAssignedToBusStop = json['assignedToBusStop']?.toString() == "true";
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['balanceAmount'] = balanceAmount;
    data['fatherName'] = fatherName;
    data['gaurdianFirstName'] = gaurdianFirstName;
    data['gaurdianId'] = gaurdianId;
    data['gaurdianLastName'] = gaurdianLastName;
    data['gaurdianMailId'] = gaurdianMailId;
    data['gaurdianMiddleName'] = gaurdianMiddleName;
    data['gaurdianMobile'] = gaurdianMobile;
    data['motherName'] = motherName;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['branchCode'] = branchCode;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['sectionDescription'] = sectionDescription;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentDob'] = studentDob;
    data['studentFirstName'] = studentFirstName;
    data['studentId'] = studentId;
    data['studentLastName'] = studentLastName;
    data['studentMailId'] = studentMailId;
    data['studentMiddleName'] = studentMiddleName;
    data['studentMobile'] = studentMobile;
    data['studentPhotoUrl'] = studentPhotoUrl;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['isAssignedToBusStop'] = isAssignedToBusStop;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;

  @override
  int get hashCode {
    return studentId ?? -1;
  }

  @override
  bool operator ==(Object other) {
    try {
      StudentProfile x = other as StudentProfile;
      return studentId == x.studentId;
    } catch (e) {
      return super == other;
    }
  }
}

class OtherUserRoleProfile {
/*
{
  "mailId": "string",
  "roleDescription": "string",
  "roleId": 0,
  "roleName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "userId": 0,
  "userName": "string"
}
*/

  String? mailId;
  String? roleDescription;
  int? roleId;
  String? roleName;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  int? userId;
  String? userName;
  Map<String, dynamic> __origJson = {};

  OtherUserRoleProfile({
    this.mailId,
    this.roleDescription,
    this.roleId,
    this.roleName,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.userId,
    this.userName,
  });
  OtherUserRoleProfile.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    mailId = json['mailId']?.toString();
    roleDescription = json['roleDescription']?.toString();
    roleId = json['roleId']?.toInt();
    roleName = json['roleName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    userId = json['userId']?.toInt();
    userName = json['userName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['mailId'] = mailId;
    data['roleDescription'] = roleDescription;
    data['roleId'] = roleId;
    data['roleName'] = roleName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['userId'] = userId;
    data['userName'] = userName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class MegaAdminProfile {
/*
{
  "detailedAddress": "string",
  "franchiseContactInfo": "string",
  "franchiseId": 0,
  "franchiseName": "string",
  "mailId": "string",
  "roleDescription": "string",
  "roleId": 0,
  "roleName": "string",
  "schoolId": 0,
  "userId": 0,
  "userName": "string"
}
*/

  String? detailedAddress;
  String? franchiseContactInfo;
  int? franchiseId;
  String? franchiseName;
  String? mailId;
  String? roleDescription;
  int? roleId;
  String? roleName;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  String? city;
  String? branchCode;
  int? userId;
  String? userName;
  Map<String, dynamic> __origJson = {};

  List<AdminProfile>? adminProfiles;

  MegaAdminProfile({
    this.detailedAddress,
    this.franchiseContactInfo,
    this.franchiseId,
    this.franchiseName,
    this.mailId,
    this.roleDescription,
    this.roleId,
    this.roleName,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.city,
    this.branchCode,
    this.userId,
    this.userName,
    this.adminProfiles,
  });
  MegaAdminProfile.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    detailedAddress = json['detailedAddress']?.toString();
    franchiseContactInfo = json['franchiseContactInfo']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    mailId = json['mailId']?.toString();
    roleDescription = json['roleDescription']?.toString();
    roleId = json['roleId']?.toInt();
    roleName = json['roleName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    city = json['city']?.toString();
    branchCode = json['branchCode']?.toString();
    userId = json['userId']?.toInt();
    userName = json['userName']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['detailedAddress'] = detailedAddress;
    data['franchiseContactInfo'] = franchiseContactInfo;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['mailId'] = mailId;
    data['roleDescription'] = roleDescription;
    data['roleId'] = roleId;
    data['roleName'] = roleName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['city'] = city;
    data['branchCode'] = branchCode;
    data['userId'] = userId;
    data['userName'] = userName;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class AdminProfile {
/*
{
  "agent": 0,
  "firstName": "string",
  "lastName": "string",
  "mailId": "string",
  "middleName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "userId": 0
}
*/

  int? agent;
  String? firstName;
  String? lastName;
  String? mailId;
  String? middleName;
  int? schoolId;
  String? schoolName;
  String? branchCode;
  String? schoolPhotoUrl;
  int? userId;
  String? adminPhotoUrl;
  String? city;
  int? franchiseId;
  String? franchiseName;

  bool isMegaAdmin = false;

  Map<String, dynamic> __origJson = {};

  AdminProfile({
    this.agent,
    this.firstName,
    this.lastName,
    this.mailId,
    this.middleName,
    this.schoolId,
    this.schoolName,
    this.branchCode,
    this.schoolPhotoUrl,
    this.userId,
    this.adminPhotoUrl,
    this.city,
    this.franchiseId,
    this.franchiseName,
    required this.isMegaAdmin,
  });
  AdminProfile.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    mailId = json['mailId']?.toString();
    middleName = json['middleName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    branchCode = json['branchCode']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    userId = json['userId']?.toInt();
    adminPhotoUrl = json['adminPhotoUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['mailId'] = mailId;
    data['middleName'] = middleName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['branchCode'] = branchCode;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['userId'] = userId;
    data['adminPhotoUrl'] = adminPhotoUrl;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetUserRolesDetailsResponse {
/*
{
  "adminProfiles": [
    {
      "agent": 0,
      "firstName": "string",
      "lastName": "string",
      "mailId": "string",
      "middleName": "string",
      "schoolId": 0,
      "schoolName": "string",
      "schoolPhotoUrl": "string",
      "userId": 0
    }
  ],
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "megaAdminProfiles": [
    {
      "detailedAddress": "string",
      "franchiseContactInfo": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "mailId": "string",
      "roleDescription": "string",
      "roleId": 0,
      "roleName": "string",
      "schoolId": 0,
      "userId": 0,
      "userName": "string"
    }
  ],
  "otherUserRoleProfiles": [
    {
      "mailId": "string",
      "roleDescription": "string",
      "roleId": 0,
      "roleName": "string",
      "schoolId": 0,
      "schoolName": "string",
      "schoolPhotoUrl": "string",
      "userId": 0,
      "userName": "string"
    }
  ],
  "responseStatus": "success",
  "studentProfiles": [
    {
      "balanceAmount": 0,
      "fatherName": "string",
      "gaurdianFirstName": "string",
      "gaurdianId": 0,
      "gaurdianLastName": "string",
      "gaurdianMailId": "string",
      "gaurdianMiddleName": "string",
      "gaurdianMobile": "string",
      "motherName": "string",
      "rollNumber": "string",
      "schoolId": 0,
      "schoolName": "string",
      "schoolPhotoUrl": "string",
      "sectionDescription": "string",
      "sectionId": 0,
      "sectionName": "string",
      "studentDob": "string",
      "studentFirstName": "string",
      "studentId": 0,
      "studentLastName": "string",
      "studentMailId": "string",
      "studentMiddleName": "string",
      "studentMobile": "string",
      "studentPhotoUrl": "string"
    }
  ],
  "teacherProfiles": [
    {
      "agent": "string",
      "description": "string",
      "dob": 0,
      "fatherName": "string",
      "firstName": "string",
      "lastName": "string",
      "mailId": "string",
      "middleName": "string",
      "motherName": "string",
      "schoolId": 0,
      "schoolName": "string",
      "schoolPhotoUrl": "string",
      "teacherId": 0,
      "teacherName": "string",
      "teacherPhotoUrl": "string"
    }
  ],
  "userDetails": {
    "agent": "string",
    "createTime": 0,
    "firstName": "string",
    "lastLogin": 0,
    "lastName": "string",
    "lastUpdatedTime": 0,
    "mailId": "string",
    "middleName": "string",
    "mobile": "string",
    "password": "string",
    "passwordExpiryDate": 0,
    "status": "active",
    "userId": 0
  }
}
*/

  List<AdminProfile?>? adminProfiles;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<MegaAdminProfile?>? megaAdminProfiles;
  List<OtherUserRoleProfile?>? otherUserRoleProfiles;
  String? responseStatus;
  List<StudentProfile?>? studentProfiles;
  List<TeacherProfile?>? teacherProfiles;
  UserDetails? userDetails;
  Map<String, dynamic> __origJson = {};

  GetUserRolesDetailsResponse({
    this.adminProfiles,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.megaAdminProfiles,
    this.otherUserRoleProfiles,
    this.responseStatus,
    this.studentProfiles,
    this.teacherProfiles,
    this.userDetails,
  });
  GetUserRolesDetailsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    if (json['adminProfiles'] != null) {
      final v = json['adminProfiles'];
      final arr0 = <AdminProfile>[];
      v.forEach((v) {
        arr0.add(AdminProfile.fromJson(v));
      });
      adminProfiles = arr0;
    }
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['megaAdminProfiles'] != null) {
      final v = json['megaAdminProfiles'];
      final arr0 = <MegaAdminProfile>[];
      v.forEach((v) {
        arr0.add(MegaAdminProfile.fromJson(v));
      });
      megaAdminProfiles = arr0;
    }
    if (json['otherUserRoleProfiles'] != null) {
      final v = json['otherUserRoleProfiles'];
      final arr0 = <OtherUserRoleProfile>[];
      v.forEach((v) {
        arr0.add(OtherUserRoleProfile.fromJson(v));
      });
      otherUserRoleProfiles = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
    if (json['studentProfiles'] != null) {
      final v = json['studentProfiles'];
      final arr0 = <StudentProfile>[];
      v.forEach((v) {
        arr0.add(StudentProfile.fromJson(v));
      });
      studentProfiles = arr0;
    }
    if (json['teacherProfiles'] != null) {
      final v = json['teacherProfiles'];
      final arr0 = <TeacherProfile>[];
      v.forEach((v) {
        arr0.add(TeacherProfile.fromJson(v));
      });
      teacherProfiles = arr0;
    }
    userDetails = (json['userDetails'] != null) ? UserDetails.fromJson(json['userDetails']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (adminProfiles != null) {
      final v = adminProfiles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['adminProfiles'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (megaAdminProfiles != null) {
      final v = megaAdminProfiles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['megaAdminProfiles'] = arr0;
    }
    if (otherUserRoleProfiles != null) {
      final v = otherUserRoleProfiles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['otherUserRoleProfiles'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    if (studentProfiles != null) {
      final v = studentProfiles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentProfiles'] = arr0;
    }
    if (teacherProfiles != null) {
      final v = teacherProfiles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['teacherProfiles'] = arr0;
    }
    if (userDetails != null) {
      data['userDetails'] = userDetails!.toJson();
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentProfileRequest {
/*
{
  "sectionId": 0,
  "studentId": 0
}
*/

  int? sectionId;
  int? studentId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetStudentProfileRequest({
    this.sectionId,
    this.studentId,
    this.schoolId,
  });
  GetStudentProfileRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetStudentProfileResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentProfiles": [
    {
      "balanceAmount": 0,
      "fatherName": "string",
      "gaurdianFirstName": "string",
      "gaurdianId": 0,
      "gaurdianLastName": "string",
      "gaurdianMailId": "string",
      "gaurdianMiddleName": "string",
      "gaurdianMobile": "string",
      "motherName": "string",
      "rollNumber": "string",
      "schoolId": 0,
      "schoolName": "string",
      "schoolPhotoUrl": "string",
      "sectionDescription": "string",
      "sectionId": 0,
      "sectionName": "string",
      "studentDob": "string",
      "studentFirstName": "string",
      "studentId": 0,
      "studentLastName": "string",
      "studentMailId": "string",
      "studentMiddleName": "string",
      "studentMobile": "string",
      "studentPhotoUrl": "string"
    }
  ]
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentProfile?>? studentProfiles;
  Map<String, dynamic> __origJson = {};

  GetStudentProfileResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentProfiles,
  });
  GetStudentProfileResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    if (json['studentProfiles'] != null) {
      final v = json['studentProfiles'];
      final arr0 = <StudentProfile>[];
      v.forEach((v) {
        arr0.add(StudentProfile.fromJson(v));
      });
      studentProfiles = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (studentProfiles != null) {
      final v = studentProfiles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['studentProfiles'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentProfileResponse> getStudentProfile(GetStudentProfileRequest getStudentProfileRequest) async {
  print("Raising request to getStudentProfile with request ${jsonEncode(getStudentProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_PROFILE;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getStudentProfileRequest.toJson()),
  );

  GetStudentProfileResponse getStudentProfileResponse = GetStudentProfileResponse.fromJson(json.decode(response.body));
  print("GetStudentProfileResponse ${getStudentProfileResponse.toJson()}");
  return getStudentProfileResponse;
}

class CreateOrUpdateStudentProfileRequest {
/*
{
  "agent": 0,
  "balanceAmount": 0,
  "fatherName": "string",
  "gaurdianFirstName": "string",
  "gaurdianId": 0,
  "gaurdianLastName": "string",
  "gaurdianMailId": "string",
  "gaurdianMiddleName": "string",
  "gaurdianMobile": "string",
  "motherName": "string",
  "rollNumber": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "sectionDescription": "string",
  "sectionId": 0,
  "sectionName": "string",
  "studentDob": "string",
  "studentFirstName": "string",
  "studentId": 0,
  "studentLastName": "string",
  "studentMailId": "string",
  "studentMiddleName": "string",
  "studentMobile": "string",
  "studentPhotoUrl": "string"
}
*/

  int? agent;
  int? balanceAmount;
  String? fatherName;
  String? gaurdianFirstName;
  int? gaurdianId;
  String? gaurdianLastName;
  String? gaurdianMailId;
  String? gaurdianMiddleName;
  String? gaurdianMobile;
  String? motherName;
  String? rollNumber;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  String? sectionDescription;
  int? sectionId;
  String? sectionName;
  String? studentDob;
  String? studentFirstName;
  int? studentId;
  String? studentLastName;
  String? studentMailId;
  String? studentMiddleName;
  String? studentMobile;
  String? studentPhotoUrl;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentProfileRequest({
    this.agent,
    this.balanceAmount,
    this.fatherName,
    this.gaurdianFirstName,
    this.gaurdianId,
    this.gaurdianLastName,
    this.gaurdianMailId,
    this.gaurdianMiddleName,
    this.gaurdianMobile,
    this.motherName,
    this.rollNumber,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.sectionDescription,
    this.sectionId,
    this.sectionName,
    this.studentDob,
    this.studentFirstName,
    this.studentId,
    this.studentLastName,
    this.studentMailId,
    this.studentMiddleName,
    this.studentMobile,
    this.studentPhotoUrl,
  });
  CreateOrUpdateStudentProfileRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    balanceAmount = json['balanceAmount']?.toInt();
    fatherName = json['fatherName']?.toString();
    gaurdianFirstName = json['gaurdianFirstName']?.toString();
    gaurdianId = json['gaurdianId']?.toInt();
    gaurdianLastName = json['gaurdianLastName']?.toString();
    gaurdianMailId = json['gaurdianMailId']?.toString();
    gaurdianMiddleName = json['gaurdianMiddleName']?.toString();
    gaurdianMobile = json['gaurdianMobile']?.toString();
    motherName = json['motherName']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    sectionDescription = json['sectionDescription']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    studentDob = json['studentDob']?.toString();
    studentFirstName = json['studentFirstName']?.toString();
    studentId = json['studentId']?.toInt();
    studentLastName = json['studentLastName']?.toString();
    studentMailId = json['studentMailId']?.toString();
    studentMiddleName = json['studentMiddleName']?.toString();
    studentMobile = json['studentMobile']?.toString();
    studentPhotoUrl = json['studentPhotoUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['balanceAmount'] = balanceAmount;
    data['fatherName'] = fatherName;
    data['gaurdianFirstName'] = gaurdianFirstName;
    data['gaurdianId'] = gaurdianId;
    data['gaurdianLastName'] = gaurdianLastName;
    data['gaurdianMailId'] = gaurdianMailId;
    data['gaurdianMiddleName'] = gaurdianMiddleName;
    data['gaurdianMobile'] = gaurdianMobile;
    data['motherName'] = motherName;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['sectionDescription'] = sectionDescription;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['studentDob'] = studentDob;
    data['studentFirstName'] = studentFirstName;
    data['studentId'] = studentId;
    data['studentLastName'] = studentLastName;
    data['studentMailId'] = studentMailId;
    data['studentMiddleName'] = studentMiddleName;
    data['studentMobile'] = studentMobile;
    data['studentPhotoUrl'] = studentPhotoUrl;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateStudentProfileResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "studentId": 0
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? studentId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateStudentProfileResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentId,
  });
  CreateOrUpdateStudentProfileResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    studentId = json['studentId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['studentId'] = studentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateStudentProfileResponse> createOrUpdateStudentProfile(CreateOrUpdateStudentProfileRequest createStudentProfileRequest) async {
  print("Raising request to createStudentProfile with request ${jsonEncode(createStudentProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_PROFILE;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createStudentProfileRequest.toJson()),
  );

  CreateOrUpdateStudentProfileResponse createStudentProfileResponse = CreateOrUpdateStudentProfileResponse.fromJson(json.decode(response.body));
  print("createStudentProfileResponse ${createStudentProfileResponse.toJson()}");
  return createStudentProfileResponse;
}

class CreateOrUpdateTeacherProfileRequest {
/*
{
  "agent": "string",
  "description": "string",
  "dob": 0,
  "fatherName": "string",
  "firstName": "string",
  "lastName": "string",
  "mailId": "string",
  "middleName": "string",
  "motherName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "teacherId": 0,
  "teacherName": "string",
  "teacherPhotoUrl": "string"
}
*/

  String? agent;
  String? description;
  int? dob;
  String? fatherName;
  String? firstName;
  String? lastName;
  String? mailId;
  String? middleName;
  String? motherName;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  int? teacherId;
  String? teacherName;
  String? teacherPhotoUrl;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTeacherProfileRequest({
    this.agent,
    this.description,
    this.dob,
    this.fatherName,
    this.firstName,
    this.lastName,
    this.mailId,
    this.middleName,
    this.motherName,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.teacherId,
    this.teacherName,
    this.teacherPhotoUrl,
  });
  CreateOrUpdateTeacherProfileRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toString();
    description = json['description']?.toString();
    dob = json['dob']?.toInt();
    fatherName = json['fatherName']?.toString();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    mailId = json['mailId']?.toString();
    middleName = json['middleName']?.toString();
    motherName = json['motherName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    teacherId = json['teacherId']?.toInt();
    teacherName = json['teacherName']?.toString();
    teacherPhotoUrl = json['teacherPhotoUrl']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['description'] = description;
    data['dob'] = dob;
    data['fatherName'] = fatherName;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['mailId'] = mailId;
    data['middleName'] = middleName;
    data['motherName'] = motherName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['teacherPhotoUrl'] = teacherPhotoUrl;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateTeacherProfileResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success",
  "teacherId": 0
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  int? teacherId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateTeacherProfileResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.teacherId,
  });
  CreateOrUpdateTeacherProfileResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
    teacherId = json['teacherId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    data['teacherId'] = teacherId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateTeacherProfileResponse> createOrUpdateTeacherProfile(CreateOrUpdateTeacherProfileRequest createTeacherProfileRequest) async {
  print("Raising request to createTeacherProfile with request ${jsonEncode(createTeacherProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TEACHER_PROFILE;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createTeacherProfileRequest.toJson()),
  );

  CreateOrUpdateTeacherProfileResponse createTeacherProfileResponse = CreateOrUpdateTeacherProfileResponse.fromJson(json.decode(response.body));
  print("createTeacherProfileResponse ${createTeacherProfileResponse.toJson()}");
  return createTeacherProfileResponse;
}

class CreateOrUpdateAdminProfileRequest {
/*
{
  "adminPhotoUrl": "string",
  "agent": 0,
  "firstName": "string",
  "lastName": "string",
  "mailId": "string",
  "middleName": "string",
  "schoolId": 0,
  "schoolName": "string",
  "schoolPhotoUrl": "string",
  "userId": 0
}
*/

  String? adminPhotoUrl;
  int? agent;
  String? firstName;
  String? lastName;
  String? mailId;
  String? middleName;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  int? userId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateAdminProfileRequest({
    this.adminPhotoUrl,
    this.agent,
    this.firstName,
    this.lastName,
    this.mailId,
    this.middleName,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.userId,
  });
  CreateOrUpdateAdminProfileRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    adminPhotoUrl = json['adminPhotoUrl']?.toString();
    agent = json['agent']?.toInt();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    mailId = json['mailId']?.toString();
    middleName = json['middleName']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    userId = json['userId']?.toInt();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminPhotoUrl'] = adminPhotoUrl;
    data['agent'] = agent;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['mailId'] = mailId;
    data['middleName'] = middleName;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['userId'] = userId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateAdminProfileResponse {
/*
{
  "adminId": 0,
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  int? adminId;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateAdminProfileResponse({
    this.adminId,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });
  CreateOrUpdateAdminProfileResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    adminId = json['adminId']?.toInt();
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminId'] = adminId;
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateAdminProfileResponse> createOrUpdateAdminProfile(CreateOrUpdateAdminProfileRequest createAdminProfileRequest) async {
  print("Raising request to createAdminProfile with request ${jsonEncode(createAdminProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_ADMIN_PROFILE;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createAdminProfileRequest.toJson()),
  );

  CreateOrUpdateAdminProfileResponse createAdminProfileResponse = CreateOrUpdateAdminProfileResponse.fromJson(json.decode(response.body));
  print("createAdminProfileResponse ${createAdminProfileResponse.toJson()}");
  return createAdminProfileResponse;
}
