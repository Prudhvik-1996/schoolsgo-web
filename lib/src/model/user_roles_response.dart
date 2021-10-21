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

class GetUserRolesResponse {
  GetUserRolesResponse({
    this.adminProfiles,
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
    this.studentProfiles,
    this.teacherProfiles,
    this.userDetails,
  });

  GetUserRolesResponse.fromJson(dynamic json) {
    if (json['adminProfiles'] != null) {
      adminProfiles = [];
      json['adminProfiles'].forEach((v) {
        adminProfiles?.add(AdminProfile.fromJson(v));
      });
    }
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
    if (json['studentProfiles'] != null) {
      studentProfiles = [];
      json['studentProfiles'].forEach((v) {
        studentProfiles?.add(StudentProfile.fromJson(v));
      });
    }
    if (json['teacherProfiles'] != null) {
      teacherProfiles = [];
      json['teacherProfiles'].forEach((v) {
        teacherProfiles?.add(TeacherProfile.fromJson(v));
      });
    }
    userDetails = json['userDetails'] != null
        ? UserDetails.fromJson(json['userDetails'])
        : null;
  }
  List<AdminProfile>? adminProfiles;
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<StudentProfile>? studentProfiles;
  List<TeacherProfile>? teacherProfiles;
  UserDetails? userDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (adminProfiles != null) {
      map['adminProfiles'] = adminProfiles?.map((v) => v.toJson()).toList();
    }
    map['errorCode'] = errorCode;
    map['errorMessage'] = errorMessage;
    map['httpStatus'] = httpStatus;
    map['responseStatus'] = responseStatus;
    if (studentProfiles != null) {
      map['studentProfiles'] = studentProfiles?.map((v) => v.toJson()).toList();
    }
    if (teacherProfiles != null) {
      map['teacherProfiles'] = teacherProfiles?.map((v) => v.toJson()).toList();
    }
    if (userDetails != null) {
      map['userDetails'] = userDetails?.toJson();
    }
    return map;
  }
}

/// agent : "string"
/// createTime : 0
/// firstName : "string"
/// lastLogin : 0
/// lastName : "string"
/// lastUpdatedTime : 0
/// mailId : "string"
/// middleName : "string"
/// mobile : "string"
/// password : "string"
/// passwordExpiryDate : 0
/// status : "active"
/// userId : 0

class UserDetails {
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

  UserDetails.fromJson(dynamic json) {
    agent = json['agent'];
    createTime = json['createTime'];
    firstName = json['firstName'];
    lastLogin = json['lastLogin'];
    lastName = json['lastName'];
    lastUpdatedTime = json['lastUpdatedTime'];
    mailId = json['mailId'];
    middleName = json['middleName'];
    mobile = json['mobile'];
    password = json['password'];
    passwordExpiryDate = json['passwordExpiryDate'];
    status = json['status'];
    userId = json['userId'];
  }
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['agent'] = agent;
    map['createTime'] = createTime;
    map['firstName'] = firstName;
    map['lastLogin'] = lastLogin;
    map['lastName'] = lastName;
    map['lastUpdatedTime'] = lastUpdatedTime;
    map['mailId'] = mailId;
    map['middleName'] = middleName;
    map['mobile'] = mobile;
    map['password'] = password;
    map['passwordExpiryDate'] = passwordExpiryDate;
    map['status'] = status;
    map['userId'] = userId;
    return map;
  }
}

/// agent : "string"
/// description : "string"
/// dob : 0
/// fatherName : "string"
/// firstName : "string"
/// lastName : "string"
/// mailId : "string"
/// middleName : "string"
/// motherName : "string"
/// schoolId : 0
/// schoolName : "string"
/// schoolPhotoUrl : "string"
/// teacherId : 0
/// teacherName : "string"
/// teacherPhotoUrl : "string"

class TeacherProfile {
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
  });

  TeacherProfile.fromJson(dynamic json) {
    agent = json['agent'];
    description = json['description'];
    dob = json['dob'];
    fatherName = json['fatherName'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    mailId = json['mailId'];
    middleName = json['middleName'];
    motherName = json['motherName'];
    schoolId = json['schoolId'];
    schoolName = json['schoolName'];
    schoolPhotoUrl = json['schoolPhotoUrl'];
    teacherId = json['teacherId'];
    teacherName = json['teacherName'];
    teacherPhotoUrl = json['teacherPhotoUrl'];
  }
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['agent'] = agent;
    map['description'] = description;
    map['dob'] = dob;
    map['fatherName'] = fatherName;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['mailId'] = mailId;
    map['middleName'] = middleName;
    map['motherName'] = motherName;
    map['schoolId'] = schoolId;
    map['schoolName'] = schoolName;
    map['schoolPhotoUrl'] = schoolPhotoUrl;
    map['teacherId'] = teacherId;
    map['teacherName'] = teacherName;
    map['teacherPhotoUrl'] = teacherPhotoUrl;
    return map;
  }
}

/// balanceAmount : 0
/// fatherName : "string"
/// gaurdianFirstName : "string"
/// gaurdianId : 0
/// gaurdianLastName : "string"
/// gaurdianMailId : "string"
/// gaurdianMiddleName : "string"
/// gaurdianMobile : "string"
/// motherName : "string"
/// rollNumber : "string"
/// schoolId : 0
/// schoolName : "string"
/// schoolPhotoUrl : "string"
/// sectionDescription : "string"
/// sectionId : 0
/// sectionName : "string"
/// studentDob : "string"
/// studentFirstName : "string"
/// studentId : 0
/// studentLastName : "string"
/// studentMailId : "string"
/// studentMiddleName : "string"
/// studentMobile : "string"
/// studentPhotoUrl : "string"

class StudentProfile {
  StudentProfile({
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

  StudentProfile.fromJson(dynamic json) {
    balanceAmount = json['balanceAmount'];
    fatherName = json['fatherName'];
    gaurdianFirstName = json['gaurdianFirstName'];
    gaurdianId = json['gaurdianId'];
    gaurdianLastName = json['gaurdianLastName'];
    gaurdianMailId = json['gaurdianMailId'];
    gaurdianMiddleName = json['gaurdianMiddleName'];
    gaurdianMobile = json['gaurdianMobile'];
    motherName = json['motherName'];
    rollNumber = json['rollNumber'];
    schoolId = json['schoolId'];
    schoolName = json['schoolName'];
    schoolPhotoUrl = json['schoolPhotoUrl'];
    sectionDescription = json['sectionDescription'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    studentDob = json['studentDob'];
    studentFirstName = json['studentFirstName'];
    studentId = json['studentId'];
    studentLastName = json['studentLastName'];
    studentMailId = json['studentMailId'];
    studentMiddleName = json['studentMiddleName'];
    studentMobile = json['studentMobile'];
    studentPhotoUrl = json['studentPhotoUrl'];
  }
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['balanceAmount'] = balanceAmount;
    map['fatherName'] = fatherName;
    map['gaurdianFirstName'] = gaurdianFirstName;
    map['gaurdianId'] = gaurdianId;
    map['gaurdianLastName'] = gaurdianLastName;
    map['gaurdianMailId'] = gaurdianMailId;
    map['gaurdianMiddleName'] = gaurdianMiddleName;
    map['gaurdianMobile'] = gaurdianMobile;
    map['motherName'] = motherName;
    map['rollNumber'] = rollNumber;
    map['schoolId'] = schoolId;
    map['schoolName'] = schoolName;
    map['schoolPhotoUrl'] = schoolPhotoUrl;
    map['sectionDescription'] = sectionDescription;
    map['sectionId'] = sectionId;
    map['sectionName'] = sectionName;
    map['studentDob'] = studentDob;
    map['studentFirstName'] = studentFirstName;
    map['studentId'] = studentId;
    map['studentLastName'] = studentLastName;
    map['studentMailId'] = studentMailId;
    map['studentMiddleName'] = studentMiddleName;
    map['studentMobile'] = studentMobile;
    map['studentPhotoUrl'] = studentPhotoUrl;
    return map;
  }

  @override
  String toString() {
    return "'balanceAmount' = $balanceAmount,'fatherName' = $fatherName,'gaurdianFirstName' = $gaurdianFirstName,'gaurdianId' = $gaurdianId,'gaurdianLastName' = $gaurdianLastName,'gaurdianMailId' = $gaurdianMailId,'gaurdianMiddleName' = $gaurdianMiddleName,'gaurdianMobile' = $gaurdianMobile,'motherName' = $motherName,'rollNumber' = $rollNumber,'schoolId' = $schoolId,'schoolName' = $schoolName,'schoolPhotoUrl' = $schoolPhotoUrl,'sectionDescription' = $sectionDescription,'sectionId' = $sectionId,'sectionName' = $sectionName,'studentDob' = $studentDob,'studentFirstName' = $studentFirstName,'studentId' = $studentId,'studentLastName' = $studentLastName,'studentMailId' = $studentMailId,'studentMiddleName' = $studentMiddleName,'studentMobile' = $studentMobile,'studentPhotoUrl' = $studentPhotoUrl";
  }
}

class AdminProfile {
  AdminProfile({
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

  AdminProfile.fromJson(dynamic json) {
    agent = json['agent'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    mailId = json['mailId'];
    middleName = json['middleName'];
    schoolId = json['schoolId'];
    schoolName = json['schoolName'];
    schoolPhotoUrl = json['schoolPhotoUrl'];
    userId = json['userId'];
  }
  int? agent;
  String? firstName;
  String? lastName;
  String? mailId;
  String? middleName;
  int? schoolId;
  String? schoolName;
  String? schoolPhotoUrl;
  int? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['agent'] = agent;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['mailId'] = mailId;
    map['middleName'] = middleName;
    map['schoolId'] = schoolId;
    map['schoolName'] = schoolName;
    map['schoolPhotoUrl'] = schoolPhotoUrl;
    map['userId'] = userId;
    return map;
  }
}
