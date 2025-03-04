import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/demo_widgets.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/demo/demo_screen.dart';
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
  late List<DemoWidget<StudentProfile>> demoWidgets;

  @override
  void initState() {
    demoWidgets = studentDemoWidgets(widget.studentProfile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demo"),
      ),
      body: ListView(
        children: demoWidgets.map((e) => buildDemoItemWidget(e)).toList(),
      ),
    );
  }

  Widget buildDemoItemWidget(DemoWidget<StudentProfile> e) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 25, 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DemoScreen(
              adminProfile: null,
              studentProfile: e.argument,
              teacherProfile: null,
              demoFile: e.demoFile,
            );
          }));
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          margin: EdgeInsets.all(MediaQuery.of(context).orientation == Orientation.landscape ? 7.0 : 0.0),
          child: ClayButton(
            depth: 40,
            surfaceColor: clayContainerColor(context),
            parentColor: clayContainerColor(context),
            spread: 1,
            borderRadius: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(
                              "${e.title}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (e.description != null)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
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
