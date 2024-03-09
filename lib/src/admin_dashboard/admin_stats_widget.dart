import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schoolsgo_web/src/attendance/admin/admin_mark_student_attendance_screen.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/employee_attendance/admin/admin_employee_attendance_management_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_fee_receipts_screen_v3.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
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
              return AdminMarkStudentAttendanceScreen(
                adminProfile: widget.adminProfile,
                teacherProfile: null,
                selectedSection: null,
                selectedDateTime: DateTime.now(),
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
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AdminFeeReceiptsScreenV3(
                adminProfile: widget.adminProfile,
              );
            },
          ),
        ),
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
                if (MediaQuery.of(widget.context).orientation == Orientation.landscape) const SizedBox(width: 20),
                SizedBox(
                  height: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 100 : 50,
                  width: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 100 : 50,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 100 : 50,
                        width: MediaQuery.of(widget.context).orientation == Orientation.landscape ? 100 : 50,
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
                if (MediaQuery.of(widget.context).orientation == Orientation.landscape) const SizedBox(width: 50),
                if (MediaQuery.of(widget.context).orientation != Orientation.landscape) const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Total Fee:",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 10,
                              ),
                            ),
                          ),
                          Text(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR(((widget.totalAcademicFee ?? 0) + (widget.totalBusFee ?? 0)) / 100.0)} /-",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Total Fee Collected:",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 10,
                              ),
                            ),
                          ),
                          Text(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR(((widget.totalAcademicFeeCollected ?? 0) + (widget.totalBusFeeCollected ?? 0)) / 100.0)} /-",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Total Fee Collected Today:",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 10,
                              ),
                            ),
                          ),
                          Text(
                            "$INR_SYMBOL ${doubleToStringAsFixedForINR((widget.totalFeeCollectedForTheDay ?? 0) / 100.0)} /-",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(widget.context).orientation == Orientation.landscape ? null : 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.of(widget.context).orientation == Orientation.landscape) const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
