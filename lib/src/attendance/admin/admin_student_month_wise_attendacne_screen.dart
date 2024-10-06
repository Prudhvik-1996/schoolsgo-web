import 'package:auto_size_text/auto_size_text.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazy_data_table/lazy_data_table.dart';
import 'package:schoolsgo_web/src/attendance/admin/student_month_wise_attendance_creation_in_bulk.dart';
import 'package:schoolsgo_web/src/attendance/model/month_wise_attendance.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/schools.dart';
import 'package:schoolsgo_web/src/model/sections.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class AdminStudentMonthWiseAttendanceScreen extends StatefulWidget {
  const AdminStudentMonthWiseAttendanceScreen({
    super.key,
    required this.adminProfile,
    required this.teacherProfile,
  });

  final AdminProfile? adminProfile;
  final TeacherProfile? teacherProfile;

  @override
  State<AdminStudentMonthWiseAttendanceScreen> createState() => _AdminStudentMonthWiseAttendanceScreenState();
}

class _AdminStudentMonthWiseAttendanceScreenState extends State<AdminStudentMonthWiseAttendanceScreen> {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Section> sectionsList = [];
  bool isSectionPickerOpen = false;
  Section? selectedSection;

  List<String> mmmYYYYStrings = [];

  List<StudentMonthWiseAttendance> studentMonthWiseAttendance = [];
  List<StudentProfile> studentsList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    GetSchoolInfoResponse getSchoolsResponse = await getSchools(GetSchoolInfoRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getSchoolsResponse.httpStatus != "OK" || getSchoolsResponse.responseStatus != "success" || getSchoolsResponse.schoolInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      SchoolInfoBean schoolInfoBean = getSchoolsResponse.schoolInfo!;
      mmmYYYYStrings = generateMmmYYYYStrings(
          convertYYYYMMDDFormatToDateTime(schoolInfoBean.academicYearStartDate), convertYYYYMMDDFormatToDateTime(schoolInfoBean.academicYearEndDate));
    }
    GetSectionsRequest getSectionsRequest = GetSectionsRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    );
    GetSectionsResponse getSectionsResponse = await getSections(getSectionsRequest);
    if (getSectionsResponse.httpStatus == "OK" && getSectionsResponse.responseStatus == "success") {
      sectionsList = getSectionsResponse.sections!.map((e) => e!).toList();
      if (widget.teacherProfile != null) {
        sectionsList.removeWhere((e) => e.classTeacherId != widget.teacherProfile?.teacherId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    GetStudentProfileResponse getStudentProfileResponse = await getStudentProfile(GetStudentProfileRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
    ));
    if (getStudentProfileResponse.httpStatus != "OK" || getStudentProfileResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    } else {
      setState(() {
        studentsList = getStudentProfileResponse.studentProfiles?.where((e) => e != null).map((e) => e!).toList() ?? [];
        studentsList.sort((a, b) {
          int aSection = sectionsList.where((es) => es.sectionId == a.sectionId).firstOrNull?.seqOrder ?? 0;
          int bSection = sectionsList.where((es) => es.sectionId == b.sectionId).firstOrNull?.seqOrder ?? 0;
          if (aSection == bSection) {
            return (int.tryParse(a.rollNumber ?? "") ?? 0).compareTo(int.tryParse(b.rollNumber ?? "") ?? 0);
          }
          return aSection.compareTo(bSection);
        });
      });
    }
    GetStudentMonthWiseAttendanceResponse getStudentMonthWiseAttendanceResponse =
        await getStudentMonthWiseAttendance(GetStudentMonthWiseAttendanceRequest(
      schoolId: widget.adminProfile?.schoolId ?? widget.teacherProfile?.schoolId,
      isAdminView: "Y",
      studentId: null,
    ));
    if (getStudentMonthWiseAttendanceResponse.httpStatus != "OK" || getStudentMonthWiseAttendanceResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      studentMonthWiseAttendance = (getStudentMonthWiseAttendanceResponse.studentMonthWiseAttendanceList ?? []).whereNotNull().toList();
    }
    setState(() => _isLoading = false);
  }

  Future<void> handleMoreOptions(String value) async {
    if (widget.adminProfile == null) return;
    switch (value) {
      case "Download Template":
        await downloadTemplateAction();
        return;
      case "Upload from Template":
        await uploadFromTemplateAction();
        return;
      default:
        return;
    }
  }

  Future<void> downloadTemplateAction() async {
    if (selectedSection == null) return;
    setState(() => _isLoading = true);
    await StudentMonthWiseAttendanceCreationInBulk(
      studentsList.where((e) => e.sectionId == selectedSection?.sectionId).toList(),
      selectedSection!,
      studentMonthWiseAttendance,
      mmmYYYYStrings,
    ).downloadTemplate();
    setState(() => _isLoading = false);
  }

  Future<void> uploadFromTemplateAction() async {
    List<StudentMonthWiseAttendance>? newAttendance = await StudentMonthWiseAttendanceCreationInBulk(
      studentsList.where((e) => e.sectionId == selectedSection?.sectionId).toList(),
      selectedSection!,
      studentMonthWiseAttendance,
      mmmYYYYStrings,
    ).readAndValidateExcel(context);
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text("Are you sure to update the changes?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                CreateOrUpdateStudentMonthWiseAttendanceResponse createOrUpdateStudentMonthWiseAttendanceResponse =
                    await createOrUpdateStudentMonthWiseAttendance(CreateOrUpdateStudentMonthWiseAttendanceRequest(
                  agent: widget.adminProfile!.userId,
                  schoolId: widget.adminProfile!.schoolId,
                  studentMonthWiseAttendanceBeans: newAttendance,
                ));
                if (createOrUpdateStudentMonthWiseAttendanceResponse.httpStatus != "OK" ||
                    createOrUpdateStudentMonthWiseAttendanceResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                  return;
                } else {
                  await _loadData();
                }
                setState(() => _isLoading = false);
              },
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                setState(() => _isLoading = false);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Student Month Wise Attendance"),
        actions: selectedSection == null
            ? []
            : [
                PopupMenuButton<String>(
                  onSelected: (String choice) async => await handleMoreOptions(choice),
                  itemBuilder: (BuildContext context) {
                    return {
                      'Download Template',
                      'Upload from Template',
                    }.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
      ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Column(
              children: [
                sectionPicker(),
                Expanded(
                  child: selectedSection == null
                      ? const Center(
                          child: Text("Select a section to view stats"),
                        )
                      : sectionWiseAttendanceStatsTable(selectedSection!),
                ),
              ],
            ),
    );
  }

  Widget sectionWiseAttendanceStatsTable(Section section) {
    List<LazyColumn> columns = [
      ...mmmYYYYStrings.map((e) => LazyColumn(e, true, 100)),
    ];
    List<StudentProfile> selectedStudentsList = studentsList.where((e) => e.sectionId == section.sectionId).toList();
    double dateCellWidth = 100;
    double defaultCellWidth = 150;
    double defaultCellHeight = 40;
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
        columns: columns.length,
        rows: selectedStudentsList.length,
        tableDimensions: LazyDataTableDimensions(
          cellHeight: defaultCellHeight,
          cellWidth: defaultCellWidth,
          topHeaderHeight: defaultCellHeight,
          leftHeaderWidth: 200,
          customCellWidth: Map<int, double>.fromEntries(columns.where((e) => e.isVisible).mapIndexed((i, e) => MapEntry(i, e.width))),
        ),
        topHeaderBuilder: (i) => clayCell(
          alignment: Alignment.centerLeft,
          child: Text(
            columns[i].columnName,
            style: const TextStyle(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          emboss: true,
        ),
        leftHeaderBuilder: (i) {
          return clayCell(
            alignment: Alignment.centerLeft,
            child: Text(
              selectedStudentsList[i].studentNameAsStringWithRollNumber(),
              textAlign: TextAlign.start,
            ),
            emboss: true,
          );
        },
        topLeftCornerWidget: clayCell(
          alignment: Alignment.centerLeft,
          child: const AutoSizeText(
            "Student Name",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            minFontSize: 7,
            maxFontSize: 12,
            softWrap: true,
          ),
          emboss: true,
        ),
        dataCellBuilder: (int rowIndex, int columnIndex) {
          StudentProfile? student = selectedStudentsList[rowIndex];
          StudentMonthWiseAttendance? attendanceBean = studentMonthWiseAttendance
              .where((e) => e.studentId == student.studentId)
              .firstWhereOrNull((e) => e.mmmYYYYString.toLowerCase() == mmmYYYYStrings[columnIndex].toLowerCase());
          String cellText = attendanceBean == null || attendanceBean.totalWorkingDays == 0
              ? "-"
              : "${attendanceBean.present ?? 0}/${attendanceBean.totalWorkingDays}";
          return Tooltip(
            message: attendanceBean?.percentage ?? "",
            child: clayCell(
              alignment: Alignment.center,
              child: Center(
                child: Text(cellText),
              ),
              emboss: true,
            ),
          );
        },
      ),
    );
  }

  Widget clayCell({
    Widget? child,
    EdgeInsetsGeometry? margin = const EdgeInsets.all(2),
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
        borderRadius: 4,
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

  Widget sectionPicker() {
    return AnimatedSize(
      curve: Curves.fastOutSlowIn,
      duration: Duration(milliseconds: isSectionPickerOpen ? 750 : 500),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: isSectionPickerOpen
            ? Container(
                margin: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 2,
                  borderRadius: 10,
                  child: selectSectionExpanded(),
                ),
              )
            : selectSectionCollapsed(),
      ),
    );
  }

  Widget buildSectionCheckBox(Section section) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.vibrate();
          setState(() {
            if (selectedSection != null && selectedSection!.sectionId == section.sectionId) {
              selectedSection = null;
            } else {
              selectedSection = section;
              isSectionPickerOpen = false;
            }
          });
        },
        child: ClayButton(
          depth: 40,
          spread: selectedSection != null && selectedSection!.sectionId == section.sectionId ? 0 : 2,
          surfaceColor:
              selectedSection != null && selectedSection!.sectionId == section.sectionId ? Colors.blue.shade300 : clayContainerColor(context),
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              section.sectionName!,
            ),
          ),
        ),
      ),
    );
  }

  Widget selectSectionExpanded() {
    return Container(
      width: double.infinity,
      // margin: const EdgeInsets.fromLTRB(17, 17, 17, 12),
      padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.vibrate();
              setState(() {
                isSectionPickerOpen = !isSectionPickerOpen;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Icon(Icons.expand_less),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.25,
            crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            shrinkWrap: true,
            children: sectionsList.map((e) => buildSectionCheckBox(e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget selectSectionCollapsed() {
    return ClayContainer(
      depth: 20,
      surfaceColor: clayContainerColor(context),
      parentColor: clayContainerColor(context),
      spread: 2,
      borderRadius: 10,
      child: InkWell(
        onTap: () {
          setState(() {
            isSectionPickerOpen = !isSectionPickerOpen;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(
                    selectedSection == null ? "Select a section" : "Section: ${selectedSection!.sectionName ?? "-"}",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
