import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class AcademicYearMap {
  int startMonth;
  int endMonth;
  int startYear;
  int endYear;
  List<int> schoolIds;

  AcademicYearMap(this.startMonth, this.endMonth, this.startYear, this.endYear, this.schoolIds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicYearMap &&
          runtimeType == other.runtimeType &&
          startMonth == other.startMonth &&
          endMonth == other.endMonth &&
          startYear == other.startYear &&
          endYear == other.endYear;

  @override
  int get hashCode => startMonth.hashCode ^ endMonth.hashCode ^ startYear.hashCode ^ endYear.hashCode;

  int get endEquivalent => endYear * 100 + endMonth;

  @override
  String toString() {
    return 'AcademicYearMap{startMonth: $startMonth, endMonth: $endMonth, startYear: $startYear, endYear: $endYear, schoolIds: $schoolIds}';
  }

  String formattedString() =>
      "${MONTHS[startMonth - 1].substring(0, 3).toLowerCase().capitalize()} $startYear - ${MONTHS[endMonth - 1].substring(0, 3).toLowerCase().capitalize()} $endYear";
}
