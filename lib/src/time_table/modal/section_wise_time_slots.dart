import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/time_table/modal/time_slot.dart';

class GetSectionWiseTimeSlotsRequest {
  String? date;
  int? schoolId;
  int? sectionId;
  int? sectionWiseTimeSlotsId;
  String? status;
  int? subjectId;
  int? tdsId;
  int? teacherId;

  GetSectionWiseTimeSlotsRequest(
      {this.date,
      this.schoolId,
      this.sectionId,
      this.sectionWiseTimeSlotsId,
      this.status,
      this.subjectId,
      this.tdsId,
      this.teacherId});

  GetSectionWiseTimeSlotsRequest.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    schoolId = json['schoolId'];
    sectionId = json['sectionId'];
    sectionWiseTimeSlotsId = json['sectionWiseTimeSlotsId'];
    status = json['status'];
    subjectId = json['subjectId'];
    tdsId = json['tdsId'];
    teacherId = json['teacherId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['schoolId'] = schoolId;
    data['sectionId'] = sectionId;
    data['sectionWiseTimeSlotsId'] = sectionWiseTimeSlotsId;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    return data;
  }
}

class GetSectionWiseTimeSlotsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SectionWiseTimeSlotBean>? sectionWiseTimeSlotBeanList;

  GetSectionWiseTimeSlotsResponse(
      {this.errorCode,
      this.errorMessage,
      this.httpStatus,
      this.responseStatus,
      this.sectionWiseTimeSlotBeanList});

  GetSectionWiseTimeSlotsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
    if (json['sectionWiseTimeSlotBeanList'] != null) {
      sectionWiseTimeSlotBeanList = <SectionWiseTimeSlotBean>[];
      json['sectionWiseTimeSlotBeanList'].forEach((v) {
        sectionWiseTimeSlotBeanList!.add(SectionWiseTimeSlotBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (sectionWiseTimeSlotBeanList != null) {
      data['sectionWiseTimeSlotBeanList'] =
          sectionWiseTimeSlotBeanList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SectionWiseTimeSlotBean {
  int? agent;
  String? createTime;
  String? date;
  String? endTime;
  String? lastUpdated;
  int? sectionId;
  String? sectionName;
  int? sectionWiseTimeSlotId;
  String? startTime;
  String? status;
  int? subjectId;
  String? subjectName;
  int? tdsId;
  int? teacherId;
  String? teacherName;
  String? validFrom;
  String? validThrough;
  String? week;
  int? weekId;
  bool? isEdited;
  bool? isPinned;
  bool? isEditedForRandomizing;

  SectionWiseTimeSlotBean({
    this.agent,
    this.createTime,
    this.date,
    this.endTime,
    this.lastUpdated,
    this.sectionId,
    this.sectionName,
    this.sectionWiseTimeSlotId,
    this.startTime,
    this.status,
    this.subjectId,
    this.subjectName,
    this.tdsId,
    this.teacherId,
    this.teacherName,
    this.validFrom,
    this.validThrough,
    this.week,
    this.weekId,
    this.isEditedForRandomizing,
  });

  SectionWiseTimeSlotBean.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    createTime = json['createTime'];
    date = json['date'];
    endTime = json['endTime'];
    lastUpdated = json['lastUpdated'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    sectionWiseTimeSlotId = json['sectionWiseTimeSlotId'];
    startTime = json['startTime'];
    status = json['status'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    tdsId = json['tdsId'];
    teacherId = json['teacherId'];
    teacherName = json['teacherName'];
    validFrom = json['validFrom'];
    validThrough = json['validThrough'];
    week = json['week'];
    weekId = json['weekId'];
    isEditedForRandomizing = json['isEditedForRandomizing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    data['createTime'] = createTime;
    data['date'] = date;
    data['endTime'] = endTime;
    data['lastUpdated'] = lastUpdated;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['sectionWiseTimeSlotId'] = sectionWiseTimeSlotId;
    data['startTime'] = startTime;
    data['status'] = status;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['tdsId'] = tdsId;
    data['teacherId'] = teacherId;
    data['teacherName'] = teacherName;
    data['validFrom'] = validFrom;
    data['validThrough'] = validThrough;
    data['week'] = week;
    data['weekId'] = weekId;
    data['isEditedForRandomizing'] = isEditedForRandomizing;
    return data;
  }

  @override
  String toString() {
    return "'agent': $agent, 'createTime': $createTime, 'date': $date, 'endTime': $endTime, 'lastUpdated': $lastUpdated, 'sectionId': $sectionId, 'sectionName': $sectionName, 'sectionWiseTimeSlotId': $sectionWiseTimeSlotId, 'startTime': $startTime, 'status': $status, 'subjectId': $subjectId, 'subjectName': $subjectName, 'tdsId': $tdsId, 'teacherId': $teacherId, 'teacherName': $teacherName, 'validFrom': $validFrom, 'validThrough': $validThrough, 'week': $week, 'weekId': $weekId, 'isEditedForRandomizing': $isEditedForRandomizing";
  }
}

Future<GetSectionWiseTimeSlotsResponse> getSectionWiseTimeSlots(
    GetSectionWiseTimeSlotsRequest getSectionWiseTimeSlotsRequest) async {
  print(
      "Raising request to getSectionWiseTimeSlots with request ${jsonEncode(getSectionWiseTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_SECTION_WISE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(getSectionWiseTimeSlotsRequest.toJson()),
  );

  GetSectionWiseTimeSlotsResponse getSectionWiseTimeSlotsResponse =
      GetSectionWiseTimeSlotsResponse.fromJson(json.decode(response.body));
  print(
      "GetSectionWiseTimeSlotsResponse ${getSectionWiseTimeSlotsResponse.toJson()}");
  return getSectionWiseTimeSlotsResponse;
}

class CreateOrUpdateSectionWiseTimeSlotsRequest {
  int? agent;
  int? schoolId;
  List<SectionWiseTimeSlotBean>? sectionWiseTimeSlotBeans;

  CreateOrUpdateSectionWiseTimeSlotsRequest(
      {this.agent, this.schoolId, this.sectionWiseTimeSlotBeans});

  CreateOrUpdateSectionWiseTimeSlotsRequest.fromJson(
      Map<String, dynamic> json) {
    agent = json['agent'];
    schoolId = json['schoolId'];
    if (json['sectionWiseTimeSlotBeans'] != null) {
      sectionWiseTimeSlotBeans = <SectionWiseTimeSlotBean>[];
      json['sectionWiseTimeSlotBeans'].forEach((v) {
        sectionWiseTimeSlotBeans!.add(SectionWiseTimeSlotBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    if (sectionWiseTimeSlotBeans != null) {
      data['sectionWiseTimeSlotBeans'] =
          sectionWiseTimeSlotBeans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateOrUpdateSectionWiseTimeSlotsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  CreateOrUpdateSectionWiseTimeSlotsResponse(
      {this.errorCode,
      this.errorMessage,
      this.httpStatus,
      this.responseStatus});

  CreateOrUpdateSectionWiseTimeSlotsResponse.fromJson(
      Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<CreateOrUpdateSectionWiseTimeSlotsResponse>
    createOrUpdateSectionWiseTimeSlots(
        CreateOrUpdateSectionWiseTimeSlotsRequest
            createOrUpdateSectionWiseTimeSlotsRequest) async {
  print(
      "Raising request to createOrUpdateSectionWiseTimeSlots with request ${jsonEncode(createOrUpdateSectionWiseTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_SECTION_WISE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(createOrUpdateSectionWiseTimeSlotsRequest.toJson()),
  );

  CreateOrUpdateSectionWiseTimeSlotsResponse
      createOrUpdateSectionWiseTimeSlotsResponse =
      CreateOrUpdateSectionWiseTimeSlotsResponse.fromJson(
          json.decode(response.body));
  print(
      "CreateOrUpdateSectionWiseTimeSlotsResponse ${createOrUpdateSectionWiseTimeSlotsResponse.toJson()}");
  return createOrUpdateSectionWiseTimeSlotsResponse;
}

class BulkEditSectionWiseTimeSlotsRequest {
  int? agent;
  int? schoolId;
  List<int>? sectionIds;
  List<TimeSlot>? timeSlots;
  List<int>? weekIds;

  BulkEditSectionWiseTimeSlotsRequest(
      {this.agent,
      this.schoolId,
      this.sectionIds,
      this.timeSlots,
      this.weekIds});

  BulkEditSectionWiseTimeSlotsRequest.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    schoolId = json['schoolId'];
    sectionIds = json['sectionIds'].cast<int>();
    if (json['timeSlots'] != null) {
      timeSlots = <TimeSlot>[];
      json['timeSlots'].forEach((v) {
        timeSlots!.add(TimeSlot.fromJson(v));
      });
    }
    weekIds = json['weekIds'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    data['schoolId'] = schoolId;
    data['sectionIds'] = sectionIds;
    if (timeSlots != null) {
      data['timeSlots'] = timeSlots!.map((v) => v.toJson()).toList();
    }
    data['weekIds'] = weekIds;
    return data;
  }
}

class BulkEditSectionWiseTimeSlotsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;

  BulkEditSectionWiseTimeSlotsResponse(
      {this.errorCode,
      this.errorMessage,
      this.httpStatus,
      this.responseStatus});

  BulkEditSectionWiseTimeSlotsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }
}

Future<BulkEditSectionWiseTimeSlotsResponse> bulkEditSectionWiseTimeSlots(
    BulkEditSectionWiseTimeSlotsRequest
        bulkEditSectionWiseTimeSlotsRequest) async {
  print(
      "Raising request to bulkEditSectionWiseTimeSlots with request ${jsonEncode(bulkEditSectionWiseTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + BULK_EDIT_SECTION_WISE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(bulkEditSectionWiseTimeSlotsRequest.toJson()),
  );

  BulkEditSectionWiseTimeSlotsResponse bulkEditSectionWiseTimeSlotsResponse =
      BulkEditSectionWiseTimeSlotsResponse.fromJson(json.decode(response.body));
  print(
      "bulkEditSectionWiseTimeSlotsResponse ${bulkEditSectionWiseTimeSlotsResponse.toJson()}");
  return bulkEditSectionWiseTimeSlotsResponse;
}

class RandomizeSectionWiseTimeSlotsRequest {
  int? agent;
  List<RandomisingTimeSlot>? randomisingTimeSlotList;
  List<TdsDailyLimitBeans>? tdsDailyLimitBeans;
  List<TeacherDealingSection>? tdsList;
  List<TdsWeeklyLimitBeans>? tdsWeeklyLimitBeans;
  List<SectionWiseTimeSlotBean>? sectionWiseTimeSlotBeanList;

  RandomizeSectionWiseTimeSlotsRequest({
    this.agent,
    this.randomisingTimeSlotList,
    this.tdsDailyLimitBeans,
    this.tdsList,
    this.tdsWeeklyLimitBeans,
    this.sectionWiseTimeSlotBeanList,
  });

  RandomizeSectionWiseTimeSlotsRequest.fromJson(Map<String, dynamic> json) {
    agent = json['agent'];
    if (json['randomisingTimeSlotList'] != null) {
      randomisingTimeSlotList = <RandomisingTimeSlot>[];
      json['randomisingTimeSlotList'].forEach((v) {
        randomisingTimeSlotList!.add(new RandomisingTimeSlot.fromJson(v));
      });
    }
    if (json['tdsDailyLimitBeans'] != null) {
      tdsDailyLimitBeans = <TdsDailyLimitBeans>[];
      json['tdsDailyLimitBeans'].forEach((v) {
        tdsDailyLimitBeans!.add(new TdsDailyLimitBeans.fromJson(v));
      });
    }
    if (json['tdsList'] != null) {
      tdsList = <TeacherDealingSection>[];
      json['tdsList'].forEach((v) {
        tdsList!.add(TeacherDealingSection.fromJson(v));
      });
    }
    if (json['tdsWeeklyLimitBeans'] != null) {
      tdsWeeklyLimitBeans = <TdsWeeklyLimitBeans>[];
      json['tdsWeeklyLimitBeans'].forEach((v) {
        tdsWeeklyLimitBeans!.add(TdsWeeklyLimitBeans.fromJson(v));
      });
    }
    if (json['sectionWiseTimeSlotBeanList'] != null) {
      sectionWiseTimeSlotBeanList = <SectionWiseTimeSlotBean>[];
      json['sectionWiseTimeSlotBeanList'].forEach((v) {
        sectionWiseTimeSlotBeanList!.add(SectionWiseTimeSlotBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent'] = agent;
    if (randomisingTimeSlotList != null) {
      data['randomisingTimeSlotList'] =
          randomisingTimeSlotList!.map((v) => v.toJson()).toList();
    }
    if (tdsDailyLimitBeans != null) {
      data['tdsDailyLimitBeans'] =
          tdsDailyLimitBeans!.map((v) => v.toJson()).toList();
    }
    if (tdsList != null) {
      data['tdsList'] = tdsList!.map((v) => v.toJson()).toList();
    }
    if (tdsWeeklyLimitBeans != null) {
      data['tdsWeeklyLimitBeans'] =
          tdsWeeklyLimitBeans!.map((v) => v.toJson()).toList();
    }
    if (sectionWiseTimeSlotBeanList != null) {
      data['sectionWiseTimeSlotBeanList'] =
          sectionWiseTimeSlotBeanList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RandomisingTimeSlot {
  String? endTime;
  String? startTime;
  TeacherDealingSection? tds;
  int? timeSlotId;
  String? week;
  int? weekId;
  int? sectionId;

  RandomisingTimeSlot({
    this.endTime,
    this.startTime,
    this.tds,
    this.timeSlotId,
    this.week,
    this.weekId,
    this.sectionId,
  });

  RandomisingTimeSlot.fromJson(Map<String, dynamic> json) {
    endTime = json['endTime'];
    startTime = json['startTime'];
    tds = json['tds'] != null
        ? TeacherDealingSection.fromJson(json['tds'])
        : null;
    timeSlotId = json['timeSlotId'];
    week = json['week'];
    weekId = json['weekId'];
    sectionId = json['sectionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['endTime'] = endTime;
    data['startTime'] = startTime;
    if (tds != null) {
      data['tds'] = tds!.toJson();
    }
    data['timeSlotId'] = timeSlotId;
    data['week'] = week;
    data['weekId'] = weekId;
    data['sectionId'] = sectionId;
    return data;
  }
}

class TdsDailyLimitBeans {
  int? dailyLimit;
  TeacherDealingSection? tds;
  int? weekId;

  TdsDailyLimitBeans({this.dailyLimit, this.tds, this.weekId});

  TdsDailyLimitBeans.fromJson(Map<String, dynamic> json) {
    dailyLimit = json['dailyLimit'];
    tds = json['tds'] != null
        ? TeacherDealingSection.fromJson(json['tds'])
        : null;
    weekId = json['weekId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dailyLimit'] = dailyLimit;
    if (tds != null) {
      data['tds'] = tds!.toJson();
    }
    data['weekId'] = weekId;
    return data;
  }

  @override
  String toString() {
    return "{dailyLimit: $dailyLimit, tds: $tds, weekId: $weekId}";
  }
}

class TdsWeeklyLimitBeans {
  TeacherDealingSection? tds;
  int? weeklyLimit;

  TdsWeeklyLimitBeans({this.tds, this.weeklyLimit});

  TdsWeeklyLimitBeans.fromJson(Map<String, dynamic> json) {
    tds = json['tds'] != null
        ? TeacherDealingSection.fromJson(json['tds'])
        : null;
    weeklyLimit = json['weeklyLimit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tds != null) {
      data['tds'] = tds!.toJson();
    }
    data['weeklyLimit'] = weeklyLimit;
    return data;
  }
}

class RandomizeSectionWiseTimeSlotsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  List<SectionWiseTimeSlotBean>? sectionWiseTimeSlotBeanList;

  RandomizeSectionWiseTimeSlotsResponse(
      {this.errorCode,
      this.errorMessage,
      this.httpStatus,
      this.responseStatus,
      this.sectionWiseTimeSlotBeanList});

  RandomizeSectionWiseTimeSlotsResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    httpStatus = json['httpStatus'];
    responseStatus = json['responseStatus'];
    if (json['sectionWiseTimeSlotBeanList'] != null) {
      sectionWiseTimeSlotBeanList = <SectionWiseTimeSlotBean>[];
      json['sectionWiseTimeSlotBeanList'].forEach((v) {
        sectionWiseTimeSlotBeanList!.add(SectionWiseTimeSlotBean.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    if (sectionWiseTimeSlotBeanList != null) {
      data['sectionWiseTimeSlotBeanList'] =
          sectionWiseTimeSlotBeanList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

Future<RandomizeSectionWiseTimeSlotsResponse> randomizeSectionWiseTimeSlots(
    RandomizeSectionWiseTimeSlotsRequest
        randomizeSectionWiseTimeSlotsRequest) async {
  print(
      "Raising request to randomizeSectionWiseTimeSlots with request ${jsonEncode(randomizeSectionWiseTimeSlotsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + RANDOMISE_SECTION_WISE_TIME_SLOTS;
  Map<String, String> _headers = {"Content-type": "application/json"};

  Response response = await http.post(
    Uri.parse(_url),
    headers: _headers,
    body: jsonEncode(randomizeSectionWiseTimeSlotsRequest.toJson()),
  );

  RandomizeSectionWiseTimeSlotsResponse randomizeSectionWiseTimeSlotsResponse =
      RandomizeSectionWiseTimeSlotsResponse.fromJson(
          json.decode(response.body));
  print(
      "randomizeSectionWiseTimeSlotsResponse ${randomizeSectionWiseTimeSlotsResponse.toJson()}");
  return randomizeSectionWiseTimeSlotsResponse;
}
