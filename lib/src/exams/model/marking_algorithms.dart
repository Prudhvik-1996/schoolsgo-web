class MarkingAlgorithmRange {
/*
{
  "algorithmName": "string",
  "endRange": 0,
  "gpa": 0,
  "grade": "string",
  "markingAlgorithmId": 0,
  "markingAlgorithmRangeId": 0,
  "schoolId": 0,
  "schoolName": "string",
  "startRange": 0,
  "status": "active"
}
*/

  String? algorithmName;
  int? endRange;
  int? gpa;
  String? grade;
  int? markingAlgorithmId;
  int? markingAlgorithmRangeId;
  int? schoolId;
  String? schoolName;
  int? startRange;
  String? status;
  Map<String, dynamic> __origJson = {};

  MarkingAlgorithmRange({
    this.algorithmName,
    this.endRange,
    this.gpa,
    this.grade,
    this.markingAlgorithmId,
    this.markingAlgorithmRangeId,
    this.schoolId,
    this.schoolName,
    this.startRange,
    this.status,
  });
  MarkingAlgorithmRange.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    algorithmName = json['algorithmName']?.toString();
    endRange = json['endRange']?.toInt();
    gpa = json['gpa']?.toInt();
    grade = json['grade']?.toString();
    markingAlgorithmId = json['markingAlgorithmId']?.toInt();
    markingAlgorithmRangeId = json['markingAlgorithmRangeId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    schoolName = json['schoolName']?.toString();
    startRange = json['startRange']?.toInt();
    status = json['status']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['algorithmName'] = algorithmName;
    data['endRange'] = endRange;
    data['gpa'] = gpa;
    data['grade'] = grade;
    data['markingAlgorithmId'] = markingAlgorithmId;
    data['markingAlgorithmRangeId'] = markingAlgorithmRangeId;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['startRange'] = startRange;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}
