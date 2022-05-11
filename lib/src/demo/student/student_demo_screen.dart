import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/dashboard_widgets.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/demo/student/student_attendance_demo.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class StudentDemoScreen extends StatefulWidget {
  const StudentDemoScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const String routeName = "/demo";

  @override
  State<StudentDemoScreen> createState() => _StudentDemoScreenState();
}

class _StudentDemoScreenState extends State<StudentDemoScreen> {
  late List<DashboardWidget<StudentProfile>> dashboardWidgets;

  @override
  void initState() {
    dashboardWidgets = studentDashBoardWidgets(widget.studentProfile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demo"),
      ),
      body: ListView(
        children: dashboardWidgets.where((e) => e.description != null).map((e) => buildDemoItemWidget(e)).toList(),
      ),
    );
  }

  Widget buildDemoItemWidget(DashboardWidget<StudentProfile> e) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 25, 10),
      child: GestureDetector(
        onTap: () {
          if (e.title == "Attendance") {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const StudentAttendanceDemoScreen();
            }));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.all(MediaQuery.of(context).orientation == Orientation.landscape ? 7.0 : 0.0),
          child: ClayButton(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 10,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.all(5),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Center(
                        child: e.image,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topLeft,
                          child: Center(
                            child: Text(
                              "${e.title}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topLeft,
                          child: Center(
                            child: Text("${e.description}"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
