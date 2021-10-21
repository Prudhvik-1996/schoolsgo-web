const String SCHOOLS_GO_BASE_URL =
    "https://epsiloninfinityservices.com:8000/schoolsgo";

const String GET_USER_DETAILS = "/users/getUserDetails";
const String GET_USER_ROLES_DETAILS = "/commons/getUserRolesDetails";

const String GET_SECTION_WISE_TIME_SLOTS = "/timetable/getSectionWiseTimeSlots";
const String CREATE_OR_UPDATE_SECTION_WISE_TIME_SLOTS =
    "/timetable/createOrUpdateSectionWiseTimeSlots";
const String BULK_EDIT_SECTION_WISE_TIME_SLOTS =
    "/timetable/bulkEditSectionWiseTimeSlots";
const String RANDOMISE_SECTION_WISE_TIME_SLOTS =
    "/timetable/randomizeTimeTable";

const String GET_STUDENT_ATTENDANCE_TIME_SLOTS =
    "/attendance/getStudentAttendanceTimeSlots";
const String CREATE_OR_UPDATE_STUDENT_ATTENDANCE_TIME_SLOTS =
    "/attendance/createOrUpdateAttendanceTimeSlotBeans";
const String GET_STUDENT_ATTENDANCE_BEANS =
    "/attendance/getStudentAttendanceBeans";
const String CREATE_OR_UPDATE_STUDENT_ATTENDANCE_BEANS =
    "/attendance/createOrUpdateStudentAttendance";
const String BULK_EDIT_ATTENDANCE_TIME_SLOTS =
    "/attendance/bulkEditAttendanceTimeSlots";

const String GET_NOTICE_BOARD = "/notice_board/getNoticeBoard";

const List<String> WEEKS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

const HEADERS = <String, String>{
  "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  "Access-Control-Allow-Credentials":
      "true", // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Headers":
      "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale,Access-Control-Allow-Origin",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-type": "application/json",
};
