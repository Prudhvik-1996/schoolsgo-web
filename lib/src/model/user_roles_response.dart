import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

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
  String? mobile;
  int? userId;

  GetUserRolesRequest({
    this.schoolId,
    this.mobile,
    this.userId,
  });

  GetUserRolesRequest.fromJson(dynamic json) {
    schoolId = json['schoolId'];
    mobile = json['mobile'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['schoolId'] = schoolId;
    map['mobile'] = mobile;
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
  String? fourDigitPin;
  List<int?>? classTeacherFor;
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
    this.fourDigitPin,
    this.classTeacherFor,
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
    fourDigitPin = json['fourDigitPin']?.toString();
    if (json['classTeacherFor'] != null) {
      final v = json['classTeacherFor'];
      final arr0 = <int?>[];
      v.forEach((v) {
        arr0.add(v);
      });
      classTeacherFor = arr0.toList();
    }
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
    data['fourDigitPin'] = fourDigitPin;
    data['classTeacherFor'] = classTeacherFor;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class StudentProfile {
  String? aadhaarNo;
  String? aadhaarPhotoUrl;
  int? aadhaarPhotoUrlId;
  String? admissionNo;
  int? agentId;
  String? alternateMobile;
  bool? assignedToBusStop;
  int? balanceAmount;
  String? branchCode;
  String? custom;
  int? fatherAnnualIncome;
  String? fatherName;
  String? fatherOccupation;
  String? fatherQualification;
  int? franchiseId;
  String? franchiseName;
  String? gaurdianFirstName;
  int? gaurdianId;
  String? gaurdianLastName;
  String? gaurdianMailId;
  String? gaurdianMiddleName;
  String? gaurdianMobile;
  String? loginId;
  int? motherAnnualIncome;
  String? motherName;
  String? motherOccupation;
  String? motherQualification;
  String? motherTongue;
  String? otherPhoneNumbers;
  String? permanentResidence;
  String? previousSchoolRecords;
  String? residenceForCommunication;
  String? rollNumber;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  String? sectionDescription;
  int? sectionId;
  String? sectionName;
  int? sectionSeqOrder;
  String? status;
  String? studentDob;
  String? studentFirstName;
  int? studentId;
  String? studentLastName;
  String? studentMailId;
  String? studentMiddleName;
  String? studentMobile;
  String? studentPhotoUrl;
  String? studentPhotoThumbnailUrl;
  String? studentStatus;
  String? sex;
  String? nationality;
  String? religion;
  String? caste;
  String? category;
  String? identificationMarks;
  String? password;
  String? createTime;
  String? lastUpdated;

  bool? isAssignedToBusStop;
  Map<String, dynamic> __origJson = {};

  TextEditingController rollNumberController = TextEditingController();
  TextEditingController admissionNoController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();
  TextEditingController gaurdianNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController alternatePhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController fatherOccupationController = TextEditingController();
  TextEditingController fatherAnnualIncomeController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController motherOccupationController = TextEditingController();
  TextEditingController motherAnnualIncomeController = TextEditingController();
  TextEditingController aadhaarNumberController = TextEditingController();
  TextEditingController nationalityController = TextEditingController(text: "India");
  TextEditingController religionController = TextEditingController();
  TextEditingController casteController = TextEditingController();
  TextEditingController motherTongueController = TextEditingController();
  TextEditingController addressForCommunicationController = TextEditingController();
  TextEditingController permanentAddressController = TextEditingController();
  TextEditingController identificationMarksController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  StudentProfile({
    this.aadhaarNo,
    this.aadhaarPhotoUrl,
    this.aadhaarPhotoUrlId,
    this.admissionNo,
    this.agentId,
    this.alternateMobile,
    this.assignedToBusStop,
    this.balanceAmount,
    this.branchCode,
    this.caste,
    this.category,
    this.custom,
    this.fatherAnnualIncome,
    this.fatherName,
    this.fatherOccupation,
    this.fatherQualification,
    this.franchiseId,
    this.franchiseName,
    this.gaurdianFirstName,
    this.gaurdianId,
    this.gaurdianLastName,
    this.gaurdianMailId,
    this.gaurdianMiddleName,
    this.gaurdianMobile,
    this.identificationMarks,
    this.loginId,
    this.motherAnnualIncome,
    this.motherName,
    this.motherOccupation,
    this.motherQualification,
    this.motherTongue,
    this.nationality,
    this.otherPhoneNumbers,
    this.permanentResidence,
    this.previousSchoolRecords,
    this.religion,
    this.residenceForCommunication,
    this.rollNumber,
    this.schoolId,
    this.schoolName,
    this.schoolPhotoUrl,
    this.sectionDescription,
    this.sectionId,
    this.sectionName,
    this.sectionSeqOrder,
    this.sex,
    this.status,
    this.studentDob,
    this.studentFirstName,
    this.studentId,
    this.studentLastName,
    this.studentMailId,
    this.studentMiddleName,
    this.studentMobile,
    this.studentPhotoUrl,
    this.studentPhotoThumbnailUrl,
    this.studentStatus,
    this.isAssignedToBusStop,
    this.password,
    this.createTime,
    this.lastUpdated,
  }) {
    populateControllers();
  }

  void populateControllers() {
    rollNumberController = TextEditingController(text: rollNumber ?? "");
    admissionNoController = TextEditingController(text: admissionNo ?? "");
    studentNameController = TextEditingController(
        text: ((studentFirstName == null ? "" : (studentFirstName ?? "").capitalize() + " ") +
            (studentMiddleName == null ? "" : (studentMiddleName ?? "").capitalize() + " ") +
            (studentLastName == null ? "" : (studentLastName ?? "").capitalize() + " ")));
    gaurdianNameController = TextEditingController(
        text: ((gaurdianFirstName == null ? "" : (gaurdianFirstName ?? "").capitalize() + " ") +
            (gaurdianMiddleName == null ? "" : (gaurdianMiddleName ?? "").capitalize() + " ") +
            (gaurdianLastName == null ? "" : (gaurdianLastName ?? "").capitalize() + " ")));
    phoneController = TextEditingController(text: gaurdianMobile ?? "");
    alternatePhoneController = TextEditingController(text: alternateMobile ?? "");
    emailController = TextEditingController(text: gaurdianMailId ?? "");
    fatherNameController = TextEditingController(text: fatherName ?? "");
    fatherOccupationController = TextEditingController(text: fatherOccupation ?? "");
    fatherAnnualIncomeController = TextEditingController(text: "${fatherAnnualIncome ?? ""}");
    motherNameController = TextEditingController(text: motherName ?? "");
    motherOccupationController = TextEditingController(text: motherOccupation ?? "");
    motherAnnualIncomeController = TextEditingController(text: "${motherAnnualIncome ?? ""}");
    aadhaarNumberController = TextEditingController(text: aadhaarNo ?? "");
    nationalityController = TextEditingController(text: nationality ?? "India");
    religionController = TextEditingController(text: religion);
    casteController = TextEditingController(text: caste);
    motherTongueController = TextEditingController(text: motherTongue);
    addressForCommunicationController = TextEditingController(text: residenceForCommunication);
    permanentAddressController = TextEditingController(text: permanentResidence);
    identificationMarksController = TextEditingController(text: identificationMarks);
    passwordController = TextEditingController(text: password);
  }

  void fromControllers() {
    rollNumber = rollNumberController.text;
    admissionNo = admissionNoController.text;
    studentFirstName = studentNameController.text;
    gaurdianFirstName = gaurdianNameController.text;
    gaurdianMobile = phoneController.text;
    alternateMobile = alternatePhoneController.text;
    gaurdianMailId = emailController.text;
    fatherName = fatherNameController.text;
    fatherOccupation = fatherOccupationController.text;
    fatherAnnualIncome = int.tryParse(fatherAnnualIncomeController.text);
    motherName = motherNameController.text;
    motherOccupation = motherOccupationController.text;
    motherAnnualIncome = int.tryParse(motherAnnualIncomeController.text);
    aadhaarNo = aadhaarNumberController.text;
    nationality = nationalityController.text;
    religion = religionController.text;
    caste = casteController.text;
    motherTongue = motherTongueController.text;
    residenceForCommunication = addressForCommunicationController.text;
    permanentResidence = permanentAddressController.text;
    identificationMarks = identificationMarksController.text;
    password = passwordController.text;
  }

  StudentProfile.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    aadhaarNo = json['aadhaarNo']?.toString();
    aadhaarPhotoUrl = json['aadhaarPhotoUrl']?.toString();
    aadhaarPhotoUrlId = json['aadhaarPhotoUrlId']?.toInt();
    admissionNo = json['admissionNo']?.toString();
    agentId = json['agentId']?.toInt();
    alternateMobile = json['alternateMobile']?.toString();
    assignedToBusStop = json['assignedToBusStop'];
    balanceAmount = json['balanceAmount']?.toInt();
    branchCode = json['branchCode']?.toString();
    caste = json['caste']?.toString();
    category = json['category']?.toString();
    custom = json['custom']?.toString();
    fatherAnnualIncome = json['fatherAnnualIncome']?.toInt();
    fatherName = json['fatherName']?.toString();
    fatherOccupation = json['fatherOccupation']?.toString();
    fatherQualification = json['fatherQualification']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    gaurdianFirstName = json['gaurdianFirstName']?.toString();
    gaurdianId = json['gaurdianId']?.toInt();
    gaurdianLastName = json['gaurdianLastName']?.toString();
    gaurdianMailId = json['gaurdianMailId']?.toString();
    gaurdianMiddleName = json['gaurdianMiddleName']?.toString();
    gaurdianMobile = json['gaurdianMobile']?.toString();
    identificationMarks = json['identificationMarks']?.toString();
    loginId = json['loginId']?.toString();
    motherAnnualIncome = json['motherAnnualIncome']?.toInt();
    motherName = json['motherName']?.toString();
    motherOccupation = json['motherOccupation']?.toString();
    motherQualification = json['motherQualification']?.toString();
    motherTongue = json['motherTongue']?.toString();
    nationality = json['nationality']?.toString();
    otherPhoneNumbers = json['otherPhoneNumbers']?.toString();
    permanentResidence = json['permanentResidence']?.toString();
    previousSchoolRecords = json['previousSchoolRecords']?.toString();
    religion = json['religion']?.toString();
    residenceForCommunication = json['residenceForCommunication']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    sectionDescription = json['sectionDescription']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    sectionSeqOrder = json['sectionSeqOrder']?.toInt();
    sex = json['sex']?.toString();
    status = json['status']?.toString();
    studentDob = json['studentDob']?.toString();
    studentFirstName = json['studentFirstName']?.toString();
    studentId = json['studentId']?.toInt();
    studentLastName = json['studentLastName']?.toString();
    studentMailId = json['studentMailId']?.toString();
    studentMiddleName = json['studentMiddleName']?.toString();
    studentMobile = json['studentMobile']?.toString();
    studentPhotoUrl = json['studentPhotoUrl']?.toString();
    studentPhotoThumbnailUrl = json['studentPhotoThumbnailUrl']?.toString();
    studentStatus = json['studentStatus']?.toString();
    password = json['password']?.toString();
    createTime = json['createTime']?.toString();
    lastUpdated = json['lastUpdated']?.toString();
    populateControllers();
  }

  void modifyAsPerJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      json = origJson();
    }
    aadhaarNo = json['aadhaarNo']?.toString();
    aadhaarPhotoUrl = json['aadhaarPhotoUrl']?.toString();
    aadhaarPhotoUrlId = json['aadhaarPhotoUrlId']?.toInt();
    admissionNo = json['admissionNo']?.toString();
    agentId = json['agentId']?.toInt();
    alternateMobile = json['alternateMobile']?.toString();
    assignedToBusStop = json['assignedToBusStop'];
    balanceAmount = json['balanceAmount']?.toInt();
    branchCode = json['branchCode']?.toString();
    caste = json['caste']?.toString();
    category = json['category']?.toString();
    custom = json['custom']?.toString();
    fatherAnnualIncome = json['fatherAnnualIncome']?.toInt();
    fatherName = json['fatherName']?.toString();
    fatherOccupation = json['fatherOccupation']?.toString();
    fatherQualification = json['fatherQualification']?.toString();
    franchiseId = json['franchiseId']?.toInt();
    franchiseName = json['franchiseName']?.toString();
    gaurdianFirstName = json['gaurdianFirstName']?.toString();
    gaurdianId = json['gaurdianId']?.toInt();
    gaurdianLastName = json['gaurdianLastName']?.toString();
    gaurdianMailId = json['gaurdianMailId']?.toString();
    gaurdianMiddleName = json['gaurdianMiddleName']?.toString();
    gaurdianMobile = json['gaurdianMobile']?.toString();
    identificationMarks = json['identificationMarks']?.toString();
    loginId = json['loginId']?.toString();
    motherAnnualIncome = json['motherAnnualIncome']?.toInt();
    motherName = json['motherName']?.toString();
    motherOccupation = json['motherOccupation']?.toString();
    motherQualification = json['motherQualification']?.toString();
    motherTongue = json['motherTongue']?.toString();
    nationality = json['nationality']?.toString();
    otherPhoneNumbers = json['otherPhoneNumbers']?.toString();
    permanentResidence = json['permanentResidence']?.toString();
    previousSchoolRecords = json['previousSchoolRecords']?.toString();
    religion = json['religion']?.toString();
    residenceForCommunication = json['residenceForCommunication']?.toString();
    rollNumber = json['rollNumber']?.toString();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    schoolPhotoUrl = json['schoolPhotoUrl']?.toString();
    sectionDescription = json['sectionDescription']?.toString();
    sectionId = json['sectionId']?.toInt();
    sectionName = json['sectionName']?.toString();
    sectionSeqOrder = json['sectionSeqOrder']?.toInt();
    sex = json['sex']?.toString();
    status = json['status']?.toString();
    studentDob = json['studentDob']?.toString();
    studentFirstName = json['studentFirstName']?.toString();
    studentId = json['studentId']?.toInt();
    studentLastName = json['studentLastName']?.toString();
    studentMailId = json['studentMailId']?.toString();
    studentMiddleName = json['studentMiddleName']?.toString();
    studentMobile = json['studentMobile']?.toString();
    studentPhotoUrl = json['studentPhotoUrl']?.toString();
    studentPhotoThumbnailUrl = json['studentPhotoThumbnailUrl']?.toString();
    studentStatus = json['studentStatus']?.toString();
    password = json['password']?.toString();
    createTime = json['createTime']?.toString();
    lastUpdated = json['lastUpdated']?.toString();
    populateControllers();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['aadhaarNo'] = aadhaarNo;
    data['aadhaarPhotoUrl'] = aadhaarPhotoUrl;
    data['aadhaarPhotoUrlId'] = aadhaarPhotoUrlId;
    data['admissionNo'] = admissionNo;
    data['agentId'] = agentId;
    data['alternateMobile'] = alternateMobile;
    data['assignedToBusStop'] = assignedToBusStop;
    data['balanceAmount'] = balanceAmount;
    data['branchCode'] = branchCode;
    data['caste'] = caste;
    data['category'] = category;
    data['custom'] = custom;
    data['fatherAnnualIncome'] = fatherAnnualIncome;
    data['fatherName'] = fatherName;
    data['fatherOccupation'] = fatherOccupation;
    data['fatherQualification'] = fatherQualification;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['gaurdianFirstName'] = gaurdianFirstName;
    data['gaurdianId'] = gaurdianId;
    data['gaurdianLastName'] = gaurdianLastName;
    data['gaurdianMailId'] = gaurdianMailId;
    data['gaurdianMiddleName'] = gaurdianMiddleName;
    data['gaurdianMobile'] = gaurdianMobile;
    data['identificationMarks'] = identificationMarks;
    data['loginId'] = loginId;
    data['motherAnnualIncome'] = motherAnnualIncome;
    data['motherName'] = motherName;
    data['motherOccupation'] = motherOccupation;
    data['motherQualification'] = motherQualification;
    data['motherTongue'] = motherTongue;
    data['nationality'] = nationality;
    data['otherPhoneNumbers'] = otherPhoneNumbers;
    data['permanentResidence'] = permanentResidence;
    data['previousSchoolRecords'] = previousSchoolRecords;
    data['religion'] = religion;
    data['residenceForCommunication'] = residenceForCommunication;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['sectionDescription'] = sectionDescription;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sectionSeqOrder'] = sectionSeqOrder;
    data['sex'] = sex;
    data['status'] = status;
    data['studentDob'] = studentDob;
    data['studentFirstName'] = studentFirstName;
    data['studentId'] = studentId;
    data['studentLastName'] = studentLastName;
    data['studentMailId'] = studentMailId;
    data['studentMiddleName'] = studentMiddleName;
    data['studentMobile'] = studentMobile;
    data['studentPhotoUrl'] = studentPhotoUrl;
    data['studentPhotoThumbnailUrl'] = studentPhotoThumbnailUrl;
    data['studentStatus'] = studentStatus;
    data['password'] = password;
    data['createTime'] = createTime;
    data['lastUpdated'] = lastUpdated;
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

  double profileProgress() {
    List<bool> measures = [(aadhaarNo?.trim() ?? "").isEmpty];
    return 0.0;
  }

  bool isModified() {
    Map<String, dynamic> newJson = toJson();
    Map<String, dynamic> oldJson = origJson();

    for (var key in newJson.keys) {
      var aValue = newJson[key];
      var bValue = oldJson[key];
      print("618: $key $aValue $bValue");
      if ("${aValue ?? ''}" != "${bValue ?? ''}") return true;
    }
    return false;
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
  String? fourDigitPin;
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
    this.fourDigitPin,
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
    fourDigitPin = json['fourDigitPin']?.toString();
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
    data['fourDigitPin'] = fourDigitPin;
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
  String? fourDigitPin;

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
    this.fourDigitPin,
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
    fourDigitPin = json['fourDigitPin']?.toString();
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
    data['fourDigitPin'] = fourDigitPin;
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
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['adminProfiles'] = arr0;
    }
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (megaAdminProfiles != null) {
      final v = megaAdminProfiles;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['megaAdminProfiles'] = arr0;
    }
    if (otherUserRoleProfiles != null) {
      final v = otherUserRoleProfiles;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['otherUserRoleProfiles'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    if (studentProfiles != null) {
      final v = studentProfiles;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentProfiles'] = arr0;
    }
    if (teacherProfiles != null) {
      final v = teacherProfiles;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
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
  int? academicYearId;
  Map<String, dynamic> __origJson = {};

  GetStudentProfileRequest({
    this.sectionId,
    this.studentId,
    this.schoolId,
    this.academicYearId,
  });

  GetStudentProfileRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    sectionId = json['sectionId']?.toInt();
    studentId = json['studentId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    academicYearId = json['academicYearId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sectionId'] = sectionId;
    data['studentId'] = studentId;
    data['schoolId'] = schoolId;
    data['academicYearId'] = academicYearId;
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
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['studentProfiles'] = arr0;
    }
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetStudentProfileResponse> getStudentProfile(GetStudentProfileRequest getStudentProfileRequest) async {
  debugPrint("Raising request to getStudentProfile with request ${jsonEncode(getStudentProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_PROFILE;

  GetStudentProfileResponse getStudentProfileResponse = await HttpUtils.post(
    _url,
    getStudentProfileRequest.toJson(),
    GetStudentProfileResponse.fromJson,
  );

  debugPrint("GetStudentProfileResponse ${getStudentProfileResponse.toJson()}");
  return getStudentProfileResponse;
}

class CreateOrUpdateStudentProfileRequest extends StudentProfile {
  int? agent;

  CreateOrUpdateStudentProfileRequest({
    this.agent,
    super.aadhaarNo,
    super.aadhaarPhotoUrl,
    super.aadhaarPhotoUrlId,
    super.admissionNo,
    super.agentId,
    super.alternateMobile,
    super.assignedToBusStop,
    super.balanceAmount,
    super.branchCode,
    super.caste,
    super.category,
    super.custom,
    super.fatherAnnualIncome,
    super.fatherName,
    super.fatherOccupation,
    super.fatherQualification,
    super.franchiseId,
    super.franchiseName,
    super.gaurdianFirstName,
    super.gaurdianId,
    super.gaurdianLastName,
    super.gaurdianMailId,
    super.gaurdianMiddleName,
    super.gaurdianMobile,
    super.identificationMarks,
    super.loginId,
    super.motherAnnualIncome,
    super.motherName,
    super.motherOccupation,
    super.motherQualification,
    super.motherTongue,
    super.nationality,
    super.otherPhoneNumbers,
    super.permanentResidence,
    super.previousSchoolRecords,
    super.religion,
    super.residenceForCommunication,
    super.rollNumber,
    super.schoolId,
    super.schoolName,
    super.schoolPhotoUrl,
    super.sectionDescription,
    super.sectionId,
    super.sectionName,
    super.sex,
    super.status,
    super.studentDob,
    super.studentFirstName,
    super.studentId,
    super.studentLastName,
    super.studentMailId,
    super.studentMiddleName,
    super.studentMobile,
    super.studentPhotoUrl,
    super.studentPhotoThumbnailUrl,
    super.studentStatus,
  });

  CreateOrUpdateStudentProfileRequest.fromStudentProfile(this.agent, StudentProfile studentProfile) {
    aadhaarNo = studentProfile.aadhaarNo;
    aadhaarPhotoUrl = studentProfile.aadhaarPhotoUrl;
    aadhaarPhotoUrlId = studentProfile.aadhaarPhotoUrlId;
    admissionNo = studentProfile.admissionNo;
    agentId = agent;
    alternateMobile = studentProfile.alternateMobile;
    assignedToBusStop = studentProfile.assignedToBusStop;
    balanceAmount = studentProfile.balanceAmount;
    branchCode = studentProfile.branchCode;
    caste = studentProfile.caste;
    category = studentProfile.category;
    custom = studentProfile.custom;
    fatherAnnualIncome = studentProfile.fatherAnnualIncome;
    fatherName = studentProfile.fatherName;
    fatherOccupation = studentProfile.fatherOccupation;
    fatherQualification = studentProfile.fatherQualification;
    franchiseId = studentProfile.franchiseId;
    franchiseName = studentProfile.franchiseName;
    gaurdianFirstName = studentProfile.gaurdianFirstName;
    gaurdianId = studentProfile.gaurdianId;
    gaurdianLastName = studentProfile.gaurdianLastName;
    gaurdianMailId = studentProfile.gaurdianMailId;
    gaurdianMiddleName = studentProfile.gaurdianMiddleName;
    gaurdianMobile = studentProfile.gaurdianMobile;
    identificationMarks = studentProfile.identificationMarks;
    loginId = studentProfile.loginId;
    motherAnnualIncome = studentProfile.motherAnnualIncome;
    motherName = studentProfile.motherName;
    motherOccupation = studentProfile.motherOccupation;
    motherQualification = studentProfile.motherQualification;
    motherTongue = studentProfile.motherTongue;
    nationality = studentProfile.nationality;
    otherPhoneNumbers = studentProfile.otherPhoneNumbers;
    permanentResidence = studentProfile.permanentResidence;
    previousSchoolRecords = studentProfile.previousSchoolRecords;
    religion = studentProfile.religion;
    residenceForCommunication = studentProfile.residenceForCommunication;
    rollNumber = studentProfile.rollNumber;
    schoolId = studentProfile.schoolId;
    schoolName = studentProfile.schoolName;
    schoolPhotoUrl = studentProfile.schoolPhotoUrl;
    sectionDescription = studentProfile.sectionDescription;
    sectionId = studentProfile.sectionId;
    sectionName = studentProfile.sectionName;
    sex = studentProfile.sex;
    status = studentProfile.status;
    studentDob = studentProfile.studentDob;
    studentFirstName = studentProfile.studentFirstName;
    studentId = studentProfile.studentId;
    studentLastName = studentProfile.studentLastName;
    studentMailId = studentProfile.studentMailId;
    studentMiddleName = studentProfile.studentMiddleName;
    studentMobile = studentProfile.studentMobile;
    studentPhotoUrl = studentProfile.studentPhotoUrl;
    studentPhotoThumbnailUrl = studentProfile.studentPhotoThumbnailUrl;
    studentStatus = studentProfile.studentStatus;
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['aadhaarNo'] = aadhaarNo;
    data['aadhaarPhotoUrl'] = aadhaarPhotoUrl;
    data['aadhaarPhotoUrlId'] = aadhaarPhotoUrlId;
    data['admissionNo'] = admissionNo;
    data['agentId'] = agentId;
    data['agent'] = agent;
    data['alternateMobile'] = alternateMobile;
    data['assignedToBusStop'] = assignedToBusStop;
    data['balanceAmount'] = balanceAmount;
    data['branchCode'] = branchCode;
    data['caste'] = caste;
    data['category'] = category;
    data['custom'] = custom;
    data['fatherAnnualIncome'] = fatherAnnualIncome;
    data['fatherName'] = fatherName;
    data['fatherOccupation'] = fatherOccupation;
    data['fatherQualification'] = fatherQualification;
    data['franchiseId'] = franchiseId;
    data['franchiseName'] = franchiseName;
    data['gaurdianFirstName'] = gaurdianFirstName;
    data['gaurdianId'] = gaurdianId;
    data['gaurdianLastName'] = gaurdianLastName;
    data['gaurdianMailId'] = gaurdianMailId;
    data['gaurdianMiddleName'] = gaurdianMiddleName;
    data['gaurdianMobile'] = gaurdianMobile;
    data['identificationMarks'] = identificationMarks;
    data['loginId'] = loginId;
    data['motherAnnualIncome'] = motherAnnualIncome;
    data['motherName'] = motherName;
    data['motherOccupation'] = motherOccupation;
    data['motherQualification'] = motherQualification;
    data['motherTongue'] = motherTongue;
    data['nationality'] = nationality;
    data['otherPhoneNumbers'] = otherPhoneNumbers;
    data['permanentResidence'] = permanentResidence;
    data['previousSchoolRecords'] = previousSchoolRecords;
    data['religion'] = religion;
    data['residenceForCommunication'] = residenceForCommunication;
    data['rollNumber'] = rollNumber;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['schoolPhotoUrl'] = schoolPhotoUrl;
    data['sectionDescription'] = sectionDescription;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sex'] = sex;
    data['status'] = status;
    data['studentDob'] = studentDob;
    data['studentFirstName'] = studentFirstName;
    data['studentId'] = studentId;
    data['studentLastName'] = studentLastName;
    data['studentMailId'] = studentMailId;
    data['studentMiddleName'] = studentMiddleName;
    data['studentMobile'] = studentMobile;
    data['studentPhotoUrl'] = studentPhotoUrl;
    data['studentPhotoThumbnailUrl'] = studentPhotoThumbnailUrl;
    data['studentStatus'] = studentStatus;
    return data;
  }
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
  debugPrint("Raising request to createStudentProfile with request ${jsonEncode(createStudentProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_STUDENT_PROFILE;

  CreateOrUpdateStudentProfileResponse createStudentProfileResponse = await HttpUtils.post(
    _url,
    createStudentProfileRequest.toJson(),
    CreateOrUpdateStudentProfileResponse.fromJson,
  );

  debugPrint("createStudentProfileResponse ${createStudentProfileResponse.toJson()}");
  return createStudentProfileResponse;
}

Future<CreateOrUpdateStudentProfileResponse> updateStudentProfile(StudentProfile studentProfile) async {
  debugPrint("Raising request to updateStudentProfile with request ${jsonEncode(studentProfile.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + UPDATE_STUDENT_PROFILE;

  CreateOrUpdateStudentProfileResponse updateStudentProfileResponse = await HttpUtils.post(
    _url,
    studentProfile.toJson(),
    CreateOrUpdateStudentProfileResponse.fromJson,
  );

  debugPrint("updateStudentProfileResponse ${updateStudentProfileResponse.toJson()}");
  return updateStudentProfileResponse;
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
  debugPrint("Raising request to createTeacherProfile with request ${jsonEncode(createTeacherProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_TEACHER_PROFILE;

  CreateOrUpdateTeacherProfileResponse createTeacherProfileResponse = await HttpUtils.post(
    _url,
    createTeacherProfileRequest.toJson(),
    CreateOrUpdateTeacherProfileResponse.fromJson,
  );

  debugPrint("createTeacherProfileResponse ${createTeacherProfileResponse.toJson()}");
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
  debugPrint("Raising request to createAdminProfile with request ${jsonEncode(createAdminProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_ADMIN_PROFILE;

  CreateOrUpdateAdminProfileResponse createAdminProfileResponse = await HttpUtils.post(
    _url,
    createAdminProfileRequest.toJson(),
    CreateOrUpdateAdminProfileResponse.fromJson,
  );

  debugPrint("createAdminProfileResponse ${createAdminProfileResponse.toJson()}");
  return createAdminProfileResponse;
}

class CreateOrUpdateBulkStudentProfilesRequest {
/*
{
  "agent": 0,
  "schoolId": 0,
  "studentProfiles": [
    {
      "agentId": 0,
      "alternateMobile": "string",
      "assignedToBusStop": true,
      "balanceAmount": 0,
      "branchCode": "string",
      "fatherName": "string",
      "franchiseId": 0,
      "franchiseName": "string",
      "gaurdianFirstName": "string",
      "gaurdianId": 0,
      "gaurdianLastName": "string",
      "gaurdianMailId": "string",
      "gaurdianMiddleName": "string",
      "gaurdianMobile": "string",
      "loginId": "string",
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

  int? agent;
  int? schoolId;
  List<StudentProfile?>? studentProfiles;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateBulkStudentProfilesRequest({
    this.agent,
    this.schoolId,
    this.studentProfiles,
  });

  CreateOrUpdateBulkStudentProfilesRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    schoolId = json['schoolId']?.toInt();
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
    data['agent'] = agent;
    data['schoolId'] = schoolId;
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

class CreateOrUpdateBulkStudentProfilesResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateBulkStudentProfilesResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateBulkStudentProfilesResponse.fromJson(Map<String, dynamic> json) {
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

Future<CreateOrUpdateBulkStudentProfilesResponse> createOrUpdateBulkStudentProfiles(
    CreateOrUpdateBulkStudentProfilesRequest createBulkStudentProfilesRequest) async {
  debugPrint("Raising request to createBulkStudentProfiles with request ${jsonEncode(createBulkStudentProfilesRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_BULK_STUDENT_PROFILES;

  CreateOrUpdateBulkStudentProfilesResponse createBulkStudentProfilesResponse = await HttpUtils.post(
    _url,
    createBulkStudentProfilesRequest.toJson(),
    CreateOrUpdateBulkStudentProfilesResponse.fromJson,
  );

  debugPrint("createBulkStudentProfilesResponse ${createBulkStudentProfilesResponse.toJson()}");
  return createBulkStudentProfilesResponse;
}

class DeactivateStudentRequest {
/*
{
  "agentId": 0,
  "reasonForDeactivation": "string",
  "schoolId": 0,
  "studentId": 0
}
*/

  int agentId;
  String reasonForDeactivation;
  int schoolId;
  int studentId;
  Map<String, dynamic> __origJson = {};

  DeactivateStudentRequest({
    required this.agentId,
    required this.reasonForDeactivation,
    required this.schoolId,
    required this.studentId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['reasonForDeactivation'] = reasonForDeactivation;
    data['schoolId'] = schoolId;
    data['studentId'] = studentId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class DeactivateStudentResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  DeactivateStudentResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  DeactivateStudentResponse.fromJson(Map<String, dynamic> json) {
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

Future<DeactivateStudentResponse> deactivateStudent(DeactivateStudentRequest deactivateStudentRequest) async {
  debugPrint("Raising request to deactivateStudent with request ${jsonEncode(deactivateStudentRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + DEACTIVATE_STUDENT;

  DeactivateStudentResponse deactivateStudentResponse = await HttpUtils.post(
    _url,
    deactivateStudentRequest.toJson(),
    DeactivateStudentResponse.fromJson,
  );

  debugPrint("deactivateStudentResponse ${deactivateStudentResponse.toJson()}");
  return deactivateStudentResponse;
}

Future<List<int>> getStudentMasterData(GetStudentProfileRequest getStudentProfileRequest) async {
  debugPrint("Raising request to getStudentAttendanceReport with request ${jsonEncode(getStudentProfileRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_STUDENT_MASTER_DATA;
  return await HttpUtils.postToDownloadFile(_url, getStudentProfileRequest.toJson());
}
