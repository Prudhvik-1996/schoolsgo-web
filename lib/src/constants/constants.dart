const String SCHOOLS_GO_BASE_URL = "https://epsiloninfinityservices.com:8000/schoolsgo";
const String SCHOOLS_GO_DRIVE_SERVICE_BASE_URL = "https://epsiloninfinityservices.com:8002/eis";
const String SCHOOLS_GO_MESSAGING_SERVICE_BASE_URL = "https://epsiloninfinityservices.com:8001/schoolsgo";

const String BUS_TRACKING_API_URL = "https://epsiloninfinityservices.com:8005";
const String GET_LOCATION = "/bus_tracking/getBusPosition";

const String UPLOAD_FILE_TO_DRIVE = "/drive/uploadFileToDrive";
const String CREATE_EXCEL_FILE_AND_GET_ID = "/drive/createExcelFileAndGetId";

// TODO should find an alternative for this
String allowCORSEndPoint = "https://api.allorigins.win/raw?url=";

String INR_SYMBOL = "₹";

const String GET_USER_DETAILS = "/users/getUserDetails";
const String GET_SCHOOL_WISE_STATS = "/commons/getSchoolWiseStats";
const String GET_SCHOOL_WISE_EMPLOYEES = "/users/getSchoolWiseEmployees";
const String CREATE_USER_AND_ASSIGN_ROLES = "/users/createUserAndAssignRoles";
const String ASSIGN_USER_WITH_ROLES = "/users/assignUserWithRoles";
const String GET_SCHOOL_WISE_ACADEMIC_YEARS = "/commons/getSchoolWiseAcademicYears";
const String GET_USER_ROLES_DETAILS = "/commons/getUserRolesDetails";
const String GET_SCHOOLS_DETAILS = "/commons/getSchoolInfo";
const String UPDATE_USER_PIN = "/users/updateUserFourDigitPin";
const String UPDATE_MOBILE_AND_PASSWORD = "/users/updatePhoneNumberPassword";
const String RESET_PIN = "/auth/resetPin";
const String DO_LOGIN = "/auth/doLogin";
const String DO_LOGIN_WITH_USER_ID_AND_PASSWORD = "/auth/doLoginWithLoginUserIdAndPassword";
const String UPDATE_LOGIN_CREDENTIALS = "/auth/updateLoginCredentials";
const String DO_LOGOUT = "/auth/doLogout";
const String CREATE_OR_UPDATE_USER_FCM_TOKEN = "/users/createOrUpdateUserFcmToken";

const String REQUEST_OTP = "/auth/requestOtp";
const String SEND_EMAIL = "/email/sendMail";

const String GET_SECTION_WISE_TIME_SLOTS = "/timetable/getSectionWiseTimeSlots";
const String CREATE_OR_UPDATE_SECTION_WISE_TIME_SLOTS = "/timetable/createOrUpdateSectionWiseTimeSlots";
const String BULK_EDIT_SECTION_WISE_TIME_SLOTS = "/timetable/bulkEditSectionWiseTimeSlots";
const String RANDOMISE_SECTION_WISE_TIME_SLOTS = "/timetable/randomizeTimeTable";

const String GET_STUDENT_ATTENDANCE_TIME_SLOTS = "/attendance/getStudentAttendanceTimeSlots";
const String CREATE_OR_UPDATE_STUDENT_ATTENDANCE_TIME_SLOTS = "/attendance/createOrUpdateAttendanceTimeSlotBeans";
const String GET_STUDENT_ATTENDANCE_BEANS = "/attendance/getStudentAttendanceBeans";
const String CREATE_OR_UPDATE_STUDENT_ATTENDANCE_BEANS = "/attendance/createOrUpdateStudentAttendance";
const String BULK_EDIT_ATTENDANCE_TIME_SLOTS = "/attendance/bulkEditAttendanceTimeSlots";
const String GET_MONTH_WISE_STUDENT_ATTENDANCE_BEANS = "/attendance/getStudentMonthWiseAttendance";
const String GET_DATE_RANGE_STUDENT_ATTENDANCE_BEANS = "/attendance/getStudentDateRangeAttendance";

const String GET_NOTICE_BOARD = "/notice_board/getNoticeBoard";
const String CREATE_OR_UPDATE_NOTICE_BOARD_MEDIA_BEANS = "/notice_board/createOrUpdateNoticeBoardMedia";
const String CREATE_OR_UPDATE_NOTICE_BOARD = "/notice_board/createOrUpdateNoticeBoard";

const String GET_EVENTS = "/events/getEvents";
const String GET_EVENT_MEDIA = "/events/getEventMedia";
const String CREATE_OR_UPDATE_EVENTS = "/events/createOrUpdateEvents";
const String CREATE_OR_UPDATE_EVENT_MEDIA = "/events/createOrUpdateEventMedia";

const String GET_SECTIONS = "/commons/getSections";
const String CREATE_OR_UPDATE_SECTIONS = "/commons/createOrUpdateSection";
const String GET_SUBJECTS = "/commons/getSubjects";
const String GET_TEACHERS = "/commons/getTeachers";
const String GET_STUDENT_PROFILE = "/students/getStudentProfile";
const String CREATE_OR_UPDATE_STUDENT_PROFILE = "/students/createOrUpdateStudentProfile";
const String UPDATE_STUDENT_PROFILE = "/students/updateStudentBio";
const String CREATE_OR_UPDATE_TEACHER_PROFILE = "/teachers/createOrUpdateTeacherProfile";
const String CREATE_OR_UPDATE_ADMIN_PROFILE = "/users/createOrUpdateAdminProfile";
const String CREATE_OR_UPDATE_BULK_STUDENT_PROFILES = "/students/createOrUpdateBulkStudentProfiles";
const String GET_STUDENT_COMMENTS = "/students/getStudentComments";
const String CREATE_OR_UPDATE_STUDENT_COMMENTS = "/students/createOrUpdateStudentComment";
const String DEACTIVATE_STUDENT = "/students/deactivateStudent";

const String GET_TDS = "/timetable/getTeacherDealingSections";
const String CREATE_OR_UPDATE_TEACHER_DEALING_SECTIONS = "/timetable/createOrUpdateTeacherDealingSections";

const String GET_LOGBOOK = "/teachers/getTeacherLogBook";
const String CREATE_OR_UPDATE_LOGBOOK = "/teachers/createOrUpdateTeacherLogBook";

const String GET_DIARY = "/diary/getStudentDiary";
const String CREATE_OR_UPDATE_DIARY = "/diary/createOrUpdateDiary";

const String GET_SUGGESTION_BOX = "/complaintBox/getComplaintBox";
const String CREATE_SUGGESTION = "/complaintBox/createComplaintBox";
const String UPDATE_SUGGESTION = "/complaintBox/updateComplaintBox";

const String GET_STUDY_MATERIAL_TILES = "/assignmentsAndStudyMaterial/getAssignmentsAndStudyMaterialTiles";
const String GET_STUDY_MATERIAL = "/assignmentsAndStudyMaterial/getAssignmentsAndStudyMaterial";
const String CREATE_OR_UPDATE_STUDY_MATERIAL = "/assignmentsAndStudyMaterial/createOrUpdateAssignmentsAndStudyMaterial";
const String CREATE_OR_UPDATE_STUDY_MATERIAL_MEDIA_MAP = "/assignmentsAndStudyMaterial/createOrUpdateAssignmentsAndStudyMaterialMediaMap";

const String GET_STUDENT_TO_TEACHER_FEEDBACK = "/feedback/getStudentToTeacherFeedback";
const String CREATE_OR_UPDATE_STUDENT_TO_TEACHER_FEEDBACK = "/feedback/createOrUpdateStudentToTeacherFeedback";
const String GET_STUDENT_TO_TEACHER_FEEDBACK_ADMIN_VIEW = "/feedback/getStudentToTeacherFeedbackAdminView";

const String GET_ONLINE_CLASS_ROOMS = "/online_class_room/getOnlineClassRooms";
const String CREATE_OR_UPDATE_ONLINE_CLASS_ROOMS = "/online_class_room/createOrUpdateCustomOcr";
const String UPDATE_OCR_AS_PER_TT = "/online_class_room/updateOcrAsPerTt";

const List<String> WEEKS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
const List<String> CASTE_CATEGORIES = ["OC", "EWS", "BC A", "BC B", "BC C", "BC D", "BC E", "ST", "SC"];

const HEADERS = <String, String>{
  "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  "Access-Control-Allow-Credentials": "true", // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale,Access-Control-Allow-Origin",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-type": "application/json",
};

const String GET_MARKING_ALGORITHMS = "/exams/getMarkingAlgorithms";
const String CREATE_OR_UPDATE_MARKING_ALGORITHM = "/exams/createOrUpdateMarkingAlgorithm";

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
const String GET_STUDENT_FEE_DETAILS = "/fee/getStudentFeeDetails";
const String GET_STUDENT_FEE_DETAILS_SUPPORT_CLASSES = "/fee/getStudentFeeDetailsSupportClasses";
const String CREATE_NEW_FEE_RECEIPTS = "/fee/createNewReceipts";
const String DELETE_FEE_RECEIPT = "/fee/deleteReceipt";
const String UPDATE_FEE_RECEIPT = "/fee/updateReceipt";
const String GET_STUDENT_FEE_RECEIPTS = "/fee/getStudentFeeReceipts";
const String SEND_FEE_RECEIPT_SMS = "/fee/sendFeeReceiptSms";

const String GET_BUSES_DRIVERS = "/buses/getDrivers";
const String GET_BUSES_BASE_DETAILS = "/buses/getBusesBaseDetails";
const String CREATE_OR_UPDATE_BUSES_BASE_DETAILS = "/buses/createOrUpdateBus";
const String GET_ROUTE_INFO = "/buses/getBusRouteDetails";
const String CREATE_OR_UPDATE_BUS_ROUTE_DETAILS = "/buses/createOrUpdateBusRouteDetails";
const String CREATE_OR_UPDATE_STOP_WISE_STUDENTS_ASSIGNMENT = "/buses/createOrUpdateStopWiseStudentsAssignment";
const String UPDATE_BUS_FARES = "/buses/updateBusFares";
const String GET_TRANSPORT_FEE_ASSIGNMENT_TYPE = "/buses/getTransportFeeAssignmentType";

const String GET_CIRCULARS = "/circulars/getCirculars";
const String CREATE_OR_UPDATE_CIRCULAR = "/circulars/createOrUpdateCircular";

const String GET_TRANSACTIONS = "/ledger/getTransactions";
const String GET_ADMIN_EXPENSES = "/ledger/getAdminExpenses";
const String CREATE_OR_UPDATE_ADMIN_EXPENSES = "/ledger/createOrUpdateAdminExpense";

const String GET_CHATS = "/chats/getChats";
const String CREATE_OR_UPDATE_CHAT = "/chats/createOrUpdateChat";
const String GET_CHAT_ROOMS = "/chats/getChatRooms";

const String GET_MONTHS_AND_YEARS_FOR_SCHOOL = "/payslips/getMonthsAndYearsForSchools";
const String CREATE_OR_UPDATE_MONTHS_AND_YEARS_FOR_SCHOOL = "/payslips/createMonthsAndYearsForSchools";
const String GET_PAYSLIP_COMPONENTS = "/payslips/getPayslipComponents";
const String CREATE_OR_UPDATE_PAYSLIP_COMPONENTS = "/payslips/createOrUpdatePayslipComponents";
const String GET_PAYSLIP_TEMPLATE_FOR_EMPLOYEE = "/payslips/getPayslipTemplateForEmployee";
const String CREATE_OR_UPDATE_PAYSLIP_TEMPLATE_FOR_EMPLOYEE = "/payslips/createOrUpdatePayslipTemplateForEmployeeBean";
const String GET_EMPLOYEE_PAYSLIPS = "/payslips/getEmployeePayslips";
const String CREATE_OR_UPDATE_LOSS_OF_PAY_FOR_EMPLOYEES = "/payslips/createOrUpdateLossOfPayForEmployees";
const String PAY_EMPLOYEE_SALARIES = "/payslips/payEmployeeSalaries";

const List<String> shouldEncryptDataForUrl = []; // [GET_USER_DETAILS, UPDATE_USER_PIN, DO_LOGIN];

const String GET_STUDENT_ATTENDANCE_REPORT = "/reports/getStudentAttendanceFile";
const String GET_DIARY_REPORT = "/reports/getStudentDiaryReport";
const String GET_STUDENT_TIME_TABLE_REPORT = "/reports/getStudentTimeTableReport";
const String GET_LEDGER_REPORT = "/reports/getLedgerReport";
const String GET_SUGGESTION_BOX_REPORT = "/reports/getSuggestionBoxReport";
const String GET_LOGBOOK_REPORT = "/reports/getTeacherLogBookReport";
const String GET_ADMIN_EXPENSES_REPORT = "/reports/getAdminExpensesReport";
const String GET_FEE_DETAILS_REPORT = "/reports/getDetailedFeesReport";
const String GET_FEE_SECTION_WISE_TERM_WISE_REPORT_FOR_ALL_STUDENTS = "/reports/getSectionWiseFeesDueReport";
const String GET_FEE_SUMMARY_REPORT = "/reports/getFeesSummaryReport";
const String GET_BUS_WISE_FEES_SUMMARY_REPORT = "/reports/getBusWiseFeesSummaryReport";
const String GET_HALL_TICKETS = "/reports/generateHallTickets";

const String GET_ACADEMIC_PLANNER_TIME_SLOTS = "/academic_planner/getPlannerTimeSlots";
const String GET_ACADEMIC_PLANNER = "/academic_planner/getPlanner";
const String CREATE_OR_UPDATE_ACADEMIC_PLANNER = "/academic_planner/createOrUpdatePlanner";

const String GET_TASKS = "/task_manager/getTasks";
const String CREATE_OR_UPDATE_TASK_COMMENT = "/task_manager/createOrUpdateTaskComment";
const String CREATE_OR_UPDATE_TASK = "/task_manager/createOrUpdateTask";

const String GET_EMPLOYEE_ATTENDANCE = "/attendance/getEmployeeAttendance";
const String CREATE_OR_UPDATE_EMPLOYEE_ATTENDANCE = "/attendance/createOrUpdateEmployeeAttendanceClock";

const String GET_APP_VERSION_URL = "/commons/latestAppVersion?appName=EpsilonDiary";
String getAppVersionUrl(String? versionName) => GET_APP_VERSION_URL + (versionName == null ? "" : "&versionName=$versionName");

const String GET_HOSTELS = "/hostel/getHostels";

const String GET_EXAM_TOPICS = "/exams/getExamTopics";
const String CREATE_OR_UPDATE_EXAM_TOPICS = "/exams/createOrUpdateExamTopics";
const String GET_TOPICS_WISE_EXAMS = "/exams/getTopicWiseExams";
const String CREATE_OR_UPDATE_TOPICS_WISE_EXAMS = "/exams/createOrUpdateTopicWiseExam";
const String CREATE_OR_UPDATE_EXAM_MARKS = "/exams/createOrUpdateExamMarks";
const String GET_CUSTOM_EXAMS = "/exams/getCustomExams";
const String CREATE_OR_UPDATE_CUSTOM_EXAMS = "/exams/createOrUpdateCustomExam";
const String GET_STUDENT_WISE_EXAMS = "/exams/getStudentWiseExams";
const String GET_FA_EXAMS = "/exams/getFAExams";
const String CREATE_OR_UPDATE_FA_EXAMS = "/exams/createOrUpdateFAExam";

const String GET_SCHOOL_WISE_SMS_COUNTER = "/sms/getSchoolWiseSmsCounter";
const String GET_SMS_CATEGORIES = "/sms/getSmsCategories";
const String GET_SMS_CONFIG = "/sms/getSmsConfig";
const String GET_SMS_TEMPLATES = "/sms/getSmsTemplates";
const String GET_SMS_LOGS = "/sms/getSmsLogs";
const String GET_SMS_TEMPLATE_WISE_LOGS = "/sms/getSmsTemplateWiseLog";
const String SEND_SMS = "/sms/sendSms";
const String UPDATE_SMS_CONFIG = "/sms/updateSmsConfig";

const String GET_INVENTORY_ITEMS = "/inventory/getInventoryItems";
const String GET_INVENTORY_ITEM_CONSUMPTION = "/inventory/getInventoryItemsConsumption";
const String GET_INVENTORY_PO = "/inventory/getInventoryPo";
const String CREATE_OR_UPDATE_INVENTORY_ITEMS = "/inventory/createOrUpdateInventoryItems";
const String CREATE_OR_UPDATE_INVENTORY_ITEMS_CONSUMPTION = "/inventory/createOrUpdateInventoryItemsConsumption";
const String CREATE_OR_UPDATE_INVENTORY_PO = "/inventory/createOrUpdateInventoryPo";
const String GET_INVENTORY_LOG = "/inventory/getInventoryLog";
