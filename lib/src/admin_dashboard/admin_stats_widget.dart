import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/admin_expenses/admin/date_wise_admin_expenses_stats_screen.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_student_absentees_screen.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/admin_employee_attendance_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/stats/date_wise_fee_stats.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/stats/financial_reports/financial_reports_screen.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class AdminStatsWidget extends StatefulWidget {
  const AdminStatsWidget({
    Key? key,
    required this.context,
    required this.totalAcademicFee,
    required this.totalAcademicFeeCollected,
    required this.totalBusFee,
    required this.totalBusFeeCollected,
    required this.totalFeeCollectedForTheDay,
    required this.totalNoOfStudents,
    required this.totalNoOfStudentsMarkedForAttendance,
    required this.totalNoOfStudentsPresent,
    required this.totalNoOfEmployees,
    required this.totalNoOfEmployeesMarkedForAttendance,
    required this.totalNoOfEmployeesPresent,
    required this.totalExpensesForTheDay,
    required this.adminProfile,
  }) : super(key: key);

  final BuildContext context;
  final int? totalAcademicFee;
  final int? totalAcademicFeeCollected;
  final int? totalBusFee;
  final int? totalBusFeeCollected;
  final int? totalFeeCollectedForTheDay;
  final int? totalNoOfStudents;
  final int? totalNoOfStudentsMarkedForAttendance;
  final int? totalNoOfStudentsPresent;
  final int? totalNoOfEmployees;
  final int? totalNoOfEmployeesMarkedForAttendance;
  final int? totalNoOfEmployeesPresent;
  final int? totalExpensesForTheDay;

  final AdminProfile adminProfile;

  @override
  State<AdminStatsWidget> createState() => _AdminStatsWidgetState();
}

class _AdminStatsWidgetState extends State<AdminStatsWidget> {
  @override
  Widget build(BuildContext context) {
    return buildDashBoardStatsView();
  }

  Widget buildDashBoardStatsView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        MediaQuery.of(widget.context).orientation == Orientation.landscape
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (MediaQuery.of(widget.context).orientation == Orientation.landscape) const SizedBox(width: 20),
                  const SizedBox(width: 20),
                  buildFeeCollectedProgressChart(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: buildStudentsButton(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: buildEmployeesButton(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (MediaQuery.of(widget.context).orientation == Orientation.landscape) const SizedBox(width: 20),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        buildFeeCollectedProgressChart(),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: buildStudentsButton(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: buildEmployeesButton(),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ]),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildStudentsButton() {
    return SizedBox(
      height: 140,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              // return AdminMarkStudentAttendanceScreen(
              //   adminProfile: widget.adminProfile,
              //   teacherProfile: null,
              //   selectedSection: null,
              //   selectedDateTime: DateTime.now(),
              // );
              return AdminStudentAbsenteesScreen(
                adminProfile: widget.adminProfile,
                teacherProfile: null,
                defaultSelectedSection: null,
              );
            },
          ),
        ),
        child: ClayButton(
          surfaceColor: clayContainerColor(widget.context),
          parentColor: clayContainerColor(widget.context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.green,
                  Colors.lightGreen,
                ],
                stops: [0, 0.9],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/images/student.png",
                      fit: BoxFit.scaleDown,
                      height: 50,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Students",
                        style: GoogleFonts.archivoBlack(
                          textStyle: TextStyle(
                            fontSize: 36,
                            color: Colors.lightGreen[200],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      "${((widget.totalNoOfStudentsMarkedForAttendance ?? 0) == 0) ? "-" : widget.totalNoOfStudentsMarkedForAttendance} / ${(widget.totalNoOfStudentsMarkedForAttendance ?? 0) == 0 ? widget.totalNoOfStudents : widget.totalNoOfStudentsMarkedForAttendance}",
                      style: GoogleFonts.archivoBlack(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.lightGreen[200],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.totalNoOfStudents ?? "-"}",
                      style: GoogleFonts.archivoBlack(
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.green[200],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmployeesButton() {
    return SizedBox(
      height: 140,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AdminEmployeeAttendanceManagementScreen(
                adminProfile: widget.adminProfile,
              );
            },
          ),
        ),
        child: ClayButton(
          surfaceColor: clayContainerColor(widget.context),
          parentColor: clayContainerColor(widget.context),
          spread: 1,
          borderRadius: 10,
          depth: 40,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.orange,
                  Colors.orange.shade100,
                ],
                stops: const [0, 0.9],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/images/student.png",
                      fit: BoxFit.scaleDown,
                      height: 50,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Employees",
                        style: GoogleFonts.archivoBlack(
                          textStyle: TextStyle(
                            fontSize: 36,
                            color: Colors.orange[50],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      "${((widget.totalNoOfEmployeesMarkedForAttendance ?? 0) == 0) ? "-" : widget.totalNoOfEmployeesMarkedForAttendance} / ${(widget.totalNoOfEmployeesMarkedForAttendance ?? 0) == 0 ? widget.totalNoOfEmployees : widget.totalNoOfEmployeesMarkedForAttendance}",
                      style: GoogleFonts.archivoBlack(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.orange[100],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.totalNoOfEmployees ?? "-"}",
                      style: GoogleFonts.archivoBlack(
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.orange[50],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFeeCollectedProgressChart() {
    return SizedBox(
      width: MediaQuery.of(widget.context).orientation == Orientation.landscape
          ? MediaQuery.of(widget.context).size.width / 2
          : MediaQuery.of(widget.context).size.width - 40,
      child: ClayContainer(
        surfaceColor: clayContainerColor(widget.context),
        parentColor: clayContainerColor(widget.context),
        spread: 1,
        borderRadius: 10,
        depth: 40,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.blue, Colors.cyan]),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              if (MediaQuery.of(widget.context).orientation == Orientation.landscape)
                Image.asset(
                  "assets/images/INR_symbol.png",
                  fit: BoxFit.scaleDown,
                  height: 100,
                ),
              if (MediaQuery.of(widget.context).orientation == Orientation.landscape) const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return DateWiseReceiptStats(
                        adminProfile: widget.adminProfile,
                        routeStopWiseStudents: null,
                        studentFeeReceipts: null,
                        isDefaultGraphView: true,
                        showAllDates: true,
                      );
                    },
                  ),
                ),
                child: Tooltip(
                  message: "Total Fee Collected",
                  child: SizedBox(
                    height: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 75 : 50,
                    width: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 75 : 50,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 75 : 50,
                          width: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 75 : 50,
                          child: CircularProgressIndicator(
                            value: ((widget.totalAcademicFeeCollected ?? 0) + (widget.totalBusFeeCollected ?? 0)) /
                                ((widget.totalAcademicFee ?? 0) + (widget.totalBusFee ?? 0)),
                            color: Colors.blue,
                            strokeWidth: 10,
                            semanticsLabel: "Fee collected",
                            semanticsValue:
                                "${doubleToStringAsFixed(((widget.totalAcademicFeeCollected ?? 0) + (widget.totalBusFeeCollected ?? 0)) * 100 / ((widget.totalAcademicFee ?? 0) + (widget.totalBusFee ?? 0)))} %",
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            backgroundColor: const Color(0xFFCDFCFF),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "${doubleToStringAsFixed(((widget.totalAcademicFeeCollected ?? 0) + (widget.totalBusFeeCollected ?? 0)) * 100 / ((widget.totalAcademicFee ?? 0) + (widget.totalBusFee ?? 0)))} %",
                              style: TextStyle(
                                color: clayContainerColor(widget.context),
                                fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 10,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return DateWiseReceiptStats(
                              adminProfile: widget.adminProfile,
                              routeStopWiseStudents: null,
                              studentFeeReceipts: null,
                              isDefaultGraphView: true,
                              showAllDates: true,
                            );
                          },
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            width: 20,
                            height: 20,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Icon(
                                Icons.arrow_drop_up,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Today's fee: $INR_SYMBOL ${doubleToStringAsFixedForINR((widget.totalFeeCollectedForTheDay ?? 0) / 100.0)} /-",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return DateWiseAdminExpensesStatsScreen(
                              adminProfile: widget.adminProfile,
                              adminExpenses: null,
                            );
                          },
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            width: 20,
                            height: 20,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Today's expenses: $INR_SYMBOL ${doubleToStringAsFixedForINR((widget.totalExpensesForTheDay ?? 0) / 100.0)} /-",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return FinancialReportsScreen(
                                adminProfile: widget.adminProfile,
                              );
                            },
                          ),
                        );
                      },
                      child: const ClayButton(
                        width: double.infinity,
                        surfaceColor: Colors.blue,
                        parentColor: Colors.blue,
                        spread: 1,
                        borderRadius: 10,
                        depth: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Financial Reports",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.of(widget.context).orientation == Orientation.landscape) const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
