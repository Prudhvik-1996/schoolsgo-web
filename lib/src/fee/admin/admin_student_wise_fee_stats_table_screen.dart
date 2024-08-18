import 'package:clay_containers/widgets/clay_container.dart';

// ignore: implementation_imports
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lazy_data_table/lazy_data_table.dart';
import 'package:schoolsgo_web/src/bus/modal/buses.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/fee/model/fee.dart';
import 'package:schoolsgo_web/src/fee/model/receipts/fee_receipts.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminStudentWiseFeeStatsTable extends StatefulWidget {
  const AdminStudentWiseFeeStatsTable({
    Key? key,
    this.adminProfile,
    this.otherRole,
    this.studentFeeReceipts,
    this.studentProfiles,
    this.feeTypes,
    this.schoolInfoBean,
    this.routeStopWiseStudents,
  }) : super(key: key);

  final AdminProfile? adminProfile;
  final OtherUserRoleProfile? otherRole;

  final List<StudentFeeReceipt>? studentFeeReceipts;
  final List<StudentProfile>? studentProfiles;
  final List<FeeType>? feeTypes;
  final SchoolInfoBean? schoolInfoBean;
  final List<RouteStopWiseStudent>? routeStopWiseStudents;

  @override
  State<AdminStudentWiseFeeStatsTable> createState() => _AdminStudentWiseFeeStatsTableState();
}

class _AdminStudentWiseFeeStatsTableState extends State<AdminStudentWiseFeeStatsTable> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<StudentFeeReceipt> studentFeeReceipts = [];
  List<StudentProfile> studentProfiles = [];
  List<FeeType> feeTypes = [];
  SchoolInfoBean? schoolInfoBean;
  List<RouteStopWiseStudent> routeStopWiseStudents = [];

  List<StudentWiseReceipts> studentDateWiseFeeReceipts = [];
  List<String> mmmYYYYStrings = [];

  double studentDetailsCellWidth = 300;
  double monthWiseFeeReceiptsCellWidth = 150;
  double defaultCellHeight = 80;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await loadSchoolInfo();
    await loadFeeReceipts();
    await loadStudentProfiles();
    await loadFeeTypes();
    await loadBusInfo();
    await populateTableData();
    setState(() => _isLoading = false);
  }

  Future<void> loadSchoolInfo() async {
    if (schoolInfoBean != null) {
      schoolInfoBean = widget.schoolInfoBean;
      return;
    }
    setState(() => _isLoading = true);
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      schoolInfoBean = getSchoolsResponse.schoolInfo!;
    }
    setState(() => _isLoading = false);
  }

  Future<void> loadFeeReceipts() async {
    if ((widget.studentFeeReceipts ?? []).isNotEmpty) {
      studentFeeReceipts = widget.studentFeeReceipts ?? [];
      return;
    }
    setState(() => _isLoading = true);
    GetStudentFeeReceiptsResponse studentFeeReceiptsResponse = await getStudentFeeReceipts(GetStudentFeeReceiptsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (studentFeeReceiptsResponse.httpStatus != "OK" || studentFeeReceiptsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentFeeReceipts = studentFeeReceiptsResponse.studentFeeReceipts!.map((e) => e!).toList();
      studentFeeReceipts.sort((b, a) {
        int dateCom = convertYYYYMMDDFormatToDateTime(a.transactionDate).compareTo(convertYYYYMMDDFormatToDateTime(b.transactionDate));
        return (dateCom == 0) ? (a.receiptNumber ?? 0).compareTo(b.receiptNumber ?? 0) : dateCom;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> loadStudentProfiles() async {
    if ((widget.studentProfiles ?? []).isNotEmpty) {
      studentProfiles = widget.studentProfiles ?? [];
      return;
    }
    setState(() => _isLoading = true);
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentProfiles = (getStudentProfileResponse.studentProfiles ?? []).where((e) => e != null).map((e) => e!).toList();
      studentProfiles.sort((a, b) => ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0)) != 0
          ? ((a.sectionId ?? 0)).compareTo((b.sectionId ?? 0))
          : ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0)) != 0
              ? ((int.tryParse(a.rollNumber ?? "") ?? 0)).compareTo((int.tryParse(b.rollNumber ?? "") ?? 0))
              : (((a.studentFirstName ?? ""))).compareTo(((b.studentFirstName ?? ""))));
    }
    setState(() => _isLoading = false);
  }

  Future<void> loadFeeTypes() async {
    if ((widget.feeTypes ?? []).isNotEmpty) {
      feeTypes = widget.feeTypes ?? [];
      return;
    }
    setState(() => _isLoading = true);
    GetFeeTypesResponse getFeeTypesResponse = await getFeeTypes(GetFeeTypesRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getFeeTypesResponse.httpStatus != "OK" || getFeeTypesResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      feeTypes = getFeeTypesResponse.feeTypesList!.map((e) => e!).toList();
    }
    setState(() => _isLoading = false);
  }

  Future<void> loadBusInfo() async {
    if ((widget.routeStopWiseStudents ?? []).isNotEmpty) {
      routeStopWiseStudents = widget.routeStopWiseStudents ?? [];
      return;
    }
    setState(() => _isLoading = true);
    GetBusRouteDetailsResponse getBusRouteDetailsResponse = await getBusRouteDetails(GetBusRouteDetailsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.otherRole?.schoolId,
    ));
    if (getBusRouteDetailsResponse.httpStatus != "OK" || getBusRouteDetailsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        routeStopWiseStudents = (getBusRouteDetailsResponse.busRouteInfoBeanList?.map((e) => e!).toList() ?? [])
            .map((e) => (e.busRouteStopsList ?? []).whereNotNull())
            .expand((i) => i)
            .map((e) => (e.students ?? []).whereNotNull())
            .expand((i) => i)
            .toList();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> populateTableData() async {
    setState(() => _isLoading = true);
    DateTime academicYearStartDate = convertYYYYMMDDFormatToDateTime(schoolInfoBean?.academicYearStartDate!);
    DateTime academicYearEndDate = convertYYYYMMDDFormatToDateTime(schoolInfoBean?.academicYearEndDate!);
    DateTime oldestReceiptDate = convertYYYYMMDDFormatToDateTime(studentFeeReceipts.last.transactionDate);
    DateTime newestReceiptDate = convertYYYYMMDDFormatToDateTime(studentFeeReceipts.last.transactionDate);
    mmmYYYYStrings = generateMmmYYYYStrings(minDate([academicYearStartDate, oldestReceiptDate]), maxDate([academicYearEndDate, newestReceiptDate]));
    for (StudentProfile eachStudent in studentProfiles) {
      List<StudentMonthWiseReceipts> studentMonthWiseReceipts = [];
      for (String eachMmYyyyString in mmmYYYYStrings) {
        studentMonthWiseReceipts.add(StudentMonthWiseReceipts(eachMmYyyyString, []));
      }
      studentFeeReceipts.where((esfr) => esfr.studentId == eachStudent.studentId).forEach((esfr) {
        String mmmYYYYString = convertDateTimeToMMYYYYString(convertYYYYMMDDFormatToDateTime(esfr.transactionDate));
        studentMonthWiseReceipts.firstWhere((esmwr) => esmwr.mmmYYYYString == mmmYYYYString).studentFeeReceipts.add(esfr);
      });
      StudentWiseReceipts studentWiseReceipts = StudentWiseReceipts(eachStudent, studentMonthWiseReceipts);
      studentDateWiseFeeReceipts.add(studentWiseReceipts);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Wise Fee Stats"),
      ),
      body: _isLoading ? const EpsilonDiaryLoadingWidget() : feeStatsTable(),
    );
  }

  Widget feeStatsTable() {
    studentDetailsCellWidth = MediaQuery.of(context).orientation == Orientation.landscape ? 300 : 200;
    monthWiseFeeReceiptsCellWidth = MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100;
    return clayCell(
      // child: stickyHeadersTable(legendCellWidth),
      child: LazyDataTable(
        tableTheme: const LazyDataTableTheme(
          alternateCellColor: Colors.transparent,
          alternateColumnHeaderColor: Colors.transparent,
          alternateRowHeaderColor: Colors.transparent,
          cellColor: Colors.transparent,
          columnHeaderColor: Colors.transparent,
          cornerColor: Colors.transparent,
          rowHeaderColor: Colors.transparent,
          alternateColumn: true,
          alternateRow: true,
          alternateCellBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          alternateColumnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          alternateRowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          cellBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          columnHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          cornerBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
          rowHeaderBorder: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
        ),
        columns: mmmYYYYStrings.length,
        rows: studentProfiles.length,
        tableDimensions: LazyDataTableDimensions(
          cellHeight: defaultCellHeight,
          cellWidth: monthWiseFeeReceiptsCellWidth,
          topHeaderHeight: defaultCellHeight,
          leftHeaderWidth: studentDetailsCellWidth,
        ),
        topHeaderBuilder: (i) => clayCell(child: Center(child: Text(mmmYYYYStrings[i]))),
        leftHeaderBuilder: (i) {
          var eachStudent = studentProfiles[i];
          return clayCell(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "${eachStudent.sectionName} - ${eachStudent.rollNumber ?? "-"}. ${eachStudent.studentFirstName ?? "-"}",
                  ),
                ),
              ],
            ),
          );
        },
        dataCellBuilder: (int rowIndex, int columnIndex) {
          int? studentId = studentProfiles[rowIndex].studentId;
          ScrollController _scrollController = ScrollController();

          return clayCell(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: studentDateWiseFeeReceipts
                      .firstWhere((es) => es.student.studentId == studentId)
                      .studentMonthWiseReceipts[columnIndex]
                      .studentFeeReceipts
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: InkWell(
                              onTap: () async {
                                // await showReceipt(e);
                                return;
                              },
                              child: Chip(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                label: Column(
                                  children: [
                                    Text(
                                      "${e.receiptNumber ?? "-"}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "$INR_SYMBOL${doubleToStringAsFixedForINR(e.getTotalAmountForReceipt() / 100)}/-",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            emboss: true,
          );
        },
        topLeftCornerWidget: clayCell(child: const Center(child: Text("Student Details"))),
      ),
    );
  }

  Future<void> showReceipt(StudentFeeReceipt e) async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (currentContext) {
        return AlertDialog(
          title: const Text("Receipt"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView(
                  children: [
                    e.widget(
                      _scaffoldKey.currentContext ?? context,
                      adminId: null,
                      isTermWise: false,
                      setState: setState,
                      reload: null,
                      makePdf: null,
                      routeStopWiseStudent: routeStopWiseStudents.where((e) => e.studentId == e.studentId).firstOrNull,
                      canSendSms: false,
                      updateModeOfPayment: null,
                      sendReceiptSms: null,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Widget clayCell({
    Widget? child,
    EdgeInsetsGeometry? margin = const EdgeInsets.all(4),
    EdgeInsetsGeometry? padding = const EdgeInsets.all(8),
    bool emboss = false,
    double height = double.infinity,
    double width = double.infinity,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      margin: margin,
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        emboss: emboss,
        child: alignment == null
            ? Container(
                padding: padding,
                height: height,
                width: width,
                child: child,
              )
            : Align(
                alignment: alignment,
                child: Container(
                  padding: padding,
                  height: height,
                  width: width,
                  child: child,
                ),
              ),
      ),
    );
  }
}

class StudentWiseReceipts {
  StudentProfile student;
  List<StudentMonthWiseReceipts> studentMonthWiseReceipts;

  StudentWiseReceipts(this.student, this.studentMonthWiseReceipts);
}

class StudentMonthWiseReceipts {
  String mmmYYYYString;
  List<StudentFeeReceipt> studentFeeReceipts;

  StudentMonthWiseReceipts(this.mmmYYYYString, this.studentFeeReceipts);
}
