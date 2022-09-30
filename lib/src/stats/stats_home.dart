import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/stats/admin_expenses/admin_expenses_report_screen.dart';
import 'package:schoolsgo_web/src/stats/attendance/student_attendance_report_screen.dart';
import 'package:schoolsgo_web/src/stats/diary/diary_report_screen.dart';
import 'package:schoolsgo_web/src/stats/fees/fees_report_screen.dart';
import 'package:schoolsgo_web/src/stats/ledger/ledger_report_screen.dart';
import 'package:schoolsgo_web/src/stats/student_time_table/student_time_table_report_screen.dart';
import 'package:schoolsgo_web/src/stats/suggestion_box/suggestion_box_report_screen.dart';
import 'package:schoolsgo_web/src/stats/teacher_logbook/teacher_logbook_report_screen.dart';
import 'package:schoolsgo_web/src/stats/under_development_screen.dart';

class StatsHome extends StatefulWidget {
  const StatsHome({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  static const String routeName = "/stats";

  @override
  State<StatsHome> createState() => _StatsHomeState();
}

class _StatsHomeState extends State<StatsHome> {
  bool _isLoading = true;

  List<StatsType> statsType = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    statsType = [
      StatsType("assets/images/attendance.svg", "Student Attendance", newScreen: StudentAttendanceReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/exams.svg", "Exams", newScreen: UnderDevelopmentScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/timetable.svg", "Time Table", newScreen: StudentTimeTableReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/diary.svg", "Student Diary", newScreen: DiaryReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/logbook.svg", "Teacher Log Book", newScreen: TeacherLogbookReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/complainbox.svg", "Suggestion Box", newScreen: SuggestionBoxReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/ledger.svg", "Ledger", newScreen: LedgerReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/fee.svg", "Fee", newScreen: FeesReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/admin_expenses.svg", "Admin Expenses", newScreen: AdminExpensesReportScreen(adminProfile: widget.adminProfile)),
      StatsType("assets/images/payslips.svg", "Payslips", newScreen: UnderDevelopmentScreen(adminProfile: widget.adminProfile)),
    ];
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: statsType.map((e) => goToSpecificReportWidget(e.svgAssetImage, e.reportType, e.newScreen)).toList(),
            ),
    );
  }

  Widget goToSpecificReportWidget(String svgAssetImage, String reportType, Widget? newScreen) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: GestureDetector(
        onTap: () {
          if (newScreen == null) return;
          Navigator.push(context, MaterialPageRoute(builder: (context) => newScreen));
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: AbsorbPointer(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                leading: SizedBox(
                  height: 25,
                  width: 25,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SvgPicture.asset(svgAssetImage),
                  ),
                ),
                title: Text(reportType),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatsType {
  String svgAssetImage;
  String reportType;
  Widget? newScreen;

  StatsType(
    this.svgAssetImage,
    this.reportType, {
    this.newScreen,
  });
}
