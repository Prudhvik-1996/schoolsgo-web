import 'package:schoolsgo_web/src/utils/date_utils.dart';

class TimeSlot {
  String? startTime; //"6:00 AM"
  String? endTime; //"6:00 AM"
  int? weekId;

  TimeSlot({this.startTime, this.endTime, this.weekId});

  @override
  String toString() {
    return 'TimeSlot{startTime: $startTime, endTime: $endTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          runtimeType == other.runtimeType &&
          weekId == other.weekId &&
          timeToDouble(stringToTimeOfDay(startTime!)) ==
              timeToDouble(stringToTimeOfDay(other.startTime!)) &&
          timeToDouble(stringToTimeOfDay(endTime!)) ==
              timeToDouble(stringToTimeOfDay(other.endTime!));

  TimeSlot.fromJson(Map<String, dynamic> json) {
    endTime = json['endTime'];
    startTime = json['startTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['endTime'] = endTime;
    data['startTime'] = startTime;
    return data;
  }

  @override
  int get hashCode =>
      weekId! ^
      timeToDouble(stringToTimeOfDay(startTime!)).hashCode ^
      timeToDouble(stringToTimeOfDay(endTime!)).hashCode;
}
