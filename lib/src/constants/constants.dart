const String SCHOOLS_GO_BASE_URL = "https://epsiloninfinityservices.com:8000/schoolsgo";
const String SCHOOLS_GO_DRIVE_SERVICE_BASE_URL = "https://epsiloninfinityservices.com:8002/eis";
const String SCHOOLS_GO_MESSAGING_SERVICE_BASE_URL = "https://epsiloninfinityservices.com:8001/schoolsgo";

const String BUS_TRACKING_API_URL = "https://epsiloninfinityservices.com:8005";
const String GET_LOCATION = "/bus_tracking/getBusPosition";

const String UPLOAD_FILE_TO_DRIVE = "/drive/uploadFileToDrive";

// TODO should find an alternative for this
String allowCORSEndPoint = "https://api.allorigins.win/raw?url=";

String INR_SYMBOL = "₹";

const String GET_USER_DETAILS = "/users/getUserDetails";
const String GET_USER_ROLES_DETAILS = "/commons/getUserRolesDetails";
const String UPDATE_USER_PIN = "/users/updateUserFourDigitPin";
const String DO_LOGIN = "/auth/doLogin";

const String REQUEST_OTP = "/auth/requestOtp";
const String SEND_EMAIL = "/mailing/sendMail";

const String GET_SECTION_WISE_TIME_SLOTS = "/timetable/getSectionWiseTimeSlots";
const String CREATE_OR_UPDATE_SECTION_WISE_TIME_SLOTS = "/timetable/createOrUpdateSectionWiseTimeSlots";
const String BULK_EDIT_SECTION_WISE_TIME_SLOTS = "/timetable/bulkEditSectionWiseTimeSlots";
const String RANDOMISE_SECTION_WISE_TIME_SLOTS = "/timetable/randomizeTimeTable";

const String GET_STUDENT_ATTENDANCE_TIME_SLOTS = "/attendance/getStudentAttendanceTimeSlots";
const String CREATE_OR_UPDATE_STUDENT_ATTENDANCE_TIME_SLOTS = "/attendance/createOrUpdateAttendanceTimeSlotBeans";
const String GET_STUDENT_ATTENDANCE_BEANS = "/attendance/getStudentAttendanceBeans";
const String CREATE_OR_UPDATE_STUDENT_ATTENDANCE_BEANS = "/attendance/createOrUpdateStudentAttendance";
const String BULK_EDIT_ATTENDANCE_TIME_SLOTS = "/attendance/bulkEditAttendanceTimeSlots";

const String GET_NOTICE_BOARD = "/notice_board/getNoticeBoard";
const String CREATE_OR_UPDATE_NOTICE_BOARD_MEDIA_BEANS = "/notice_board/createOrUpdateNoticeBoardMedia";
const String CREATE_OR_UPDATE_NOTICE_BOARD = "/notice_board/createOrUpdateNoticeBoard";

const String GET_EVENTS = "/events/getEvents";
const String GET_EVENT_MEDIA = "/events/getEventMedia";
const String CREATE_OR_UPDATE_EVENTS = "/events/createOrUpdateEvents";
const String CREATE_OR_UPDATE_EVENT_MEDIA = "/events/createOrUpdateEventMedia";

const String GET_SECTIONS = "/commons/getSections";
const String GET_SUBJECTS = "/commons/getSubjects";
const String GET_TEACHERS = "/commons/getTeachers";
const String GET_STUDENT_PROFILE = "/students/getStudentProfile";
const String CREATE_OR_UPDATE_STUDENT_PROFILE = "/students/createOrUpdateStudentProfile";
const String CREATE_OR_UPDATE_TEACHER_PROFILE = "/teachers/createOrUpdateTeacherProfile";
const String CREATE_OR_UPDATE_ADMIN_PROFILE = "/users/createOrUpdateAdminProfile";

const String GET_TDS = "/timetable/getTeacherDealingSections";
const String CREATE_OR_UPDATE_TEACHER_DEALING_SECTIONS = "/timetable/createOrUpdateTeacherDealingSections";

const String GET_LOGBOOK = "/teachers/getTeacherLogBook";
const String CREATE_OR_UPDATE_LOGBOOK = "/teachers/createOrUpdateTeacherLogBook";

const String GET_DIARY = "/diary/getStudentDiary";
const String CREATE_OR_UPDATE_DIARY = "/diary/createOrUpdateDiary";

const String GET_SUGGESTION_BOX = "/complaintBox/getComplaintBox";
const String CREATE_SUGGESTION = "/complaintBox/createComplaintBox";
const String UPDATE_SUGGESTION = "/complaintBox/updateComplaintBox";

const String GET_STUDY_MATERIAL = "/assignmentsAndStudyMaterial/getAssignmentsAndStudyMaterial";
const String CREATE_OR_UPDATE_STUDY_MATERIAL = "/assignmentsAndStudyMaterial/createOrUpdateAssignmentsAndStudyMaterial";
const String CREATE_OR_UPDATE_STUDY_MATERIAL_MEDIA_MAP = "/assignmentsAndStudyMaterial/createOrUpdateAssignmentsAndStudyMaterialMediaMap";

const String GET_STUDENT_TO_TEACHER_FEEDBACK = "/feedback/getStudentToTeacherFeedback";
const String CREATE_OR_UPDATE_STUDENT_TO_TEACHER_FEEDBACK = "/feedback/createOrUpdateStudentToTeacherFeedback";

const String GET_ONLINE_CLASS_ROOMS = "/online_class_room/getOnlineClassRooms";
const String CREATE_OR_UPDATE_ONLINE_CLASS_ROOMS = "/online_class_room/createOrUpdateCustomOcr";
const String UPDATE_OCR_AS_PER_TT = "/online_class_room/updateOcrAsPerTt";

const List<String> WEEKS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

const HEADERS = <String, String>{
  "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  "Access-Control-Allow-Credentials": "true", // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale,Access-Control-Allow-Origin",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-type": "application/json",
};

const String GET_EXAMS = "/exams/getExams";
const String GET_MARKING_ALGORITHMS = "/exams/getMarkingAlgorithms";
const String GET_ADMIN_EXAMS = "/exams/getAdminExamDetails";
const String CREATE_OR_UPDATE_ADMIN_EXAMS = "/exams/createOrUpdateExam";
const String CREATE_OR_UPDATE_MARKING_ALGORITHM = "/exams/createOrUpdateMarkingAlgorithm";
const String GET_STUDENT_EXAM_MARKS = "/exams/getStudentExamMarksDetails";
const String CREATE_OR_UPDATE_EXAM_MARKS = "/exams/createOrUpdateStudentExamMarks";

const String GET_FEE_TYPES = "/fee/getFeeTypes";
const String CREATE_OR_UPDATE_FEE_TYPES = "/fee/createOrUpdateFeeTypes";
const String GET_SECTION_WISE_ANNUAL_FEES = "/fee/getSectionWiseAnnualFees";
const String CREATE_OR_UPDATE_SECTION_WISE_ANNUAL_FEES = "/fee/createOrUpdateSectionFeeMap";
const String GET_STUDENT_WISE_ANNUAL_FEES = "/fee/getStudentWiseAnnualFees";
const String CREATE_OR_UPDATE_STUDENT_WISE_ANNUAL_FEES = "/fee/createOrUpdateStudentAnnualFeeMap";
const String GET_TERMS = "/fee/getTerms";
const String CREATE_OR_UPDATE_TERM = "/fee/createOrUpdateTerm";
const String GET_SECTION_WISE_TERM_FEES = "/fee/getSectionWiseTermFees";
const String CREATE_SECTION_WISE_TERM_FEES = "/fee/createOrUpdateSectionWiseTermFeeMap";
const String GET_STUDENT_WISE_TERM_FEES = "/fee/getStudentWiseTermFees";
const String CREATE_OR_UPDATE_FEE_PAID = "/fee/createOrUpdateStudentFeePaid";
// const String GET_CUSTOM_FEE_TYPES = "/fee/getCustomFees";
// const String GET_FEE_MAP = "/fee/getFeeMap";

const String GET_BUSES_DRIVERS = "/buses/getDrivers";
const String GET_BUSES_BASE_DETAILS = "/buses/getBusesBaseDetails";
const String CREATE_OR_UPDATE_BUSES_BASE_DETAILS = "/buses/createOrUpdateBus";
const String GET_ROUTE_INFO = "/buses/getBusRouteDetails";
const String CREATE_OR_UPDATE_BUS_ROUTE_DETAILS = "/buses/createOrUpdateBusRouteDetails";
const String CREATE_OR_UPDATE_STOP_WISE_STUDENTS_ASSIGNMENT = "/buses/createOrUpdateStopWiseStudentsAssignment";
