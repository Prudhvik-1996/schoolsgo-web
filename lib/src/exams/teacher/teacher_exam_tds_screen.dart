import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/teacher/teacher_tds_wise_exams_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class TeacherExamTdsScreen extends StatefulWidget {
  const TeacherExamTdsScreen({
    Key? key,
    required this.teacherProfile,
  }) : super(key: key);

  final TeacherProfile teacherProfile;

  @override
  State<TeacherExamTdsScreen> createState() => _TeacherExamTdsScreenState();
}

class _TeacherExamTdsScreenState extends State<TeacherExamTdsScreen> {
  bool _isLoading = true;

  List<TeacherDealingSection> _tdsList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.teacherProfile.schoolId,
      teacherId: widget.teacherProfile.teacherId,
      status: "active",
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _tdsWidget(TeacherDealingSection tds) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: InkWell(
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text("Section: ${tds.sectionName}"),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tds.subjectName!.capitalize(),
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(tds.teacherName!.capitalize()),
                        ),
                      ),
                    ],
                  ),
                ),
                // child: Text("Section: ${tds.sectionName}" +
                //     "\n" +
                //     "Teacher: ${tds.teacherName!.capitalize()}"),
                // child: Text("hi"),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                  child: ClayContainer(
                    depth: 40,
                    surfaceColor: clayContainerColor(context),
                    parentColor: clayContainerColor(context),
                    spread: 1,
                    customBorderRadius: const BorderRadius.only(
                      topRight: Radius.elliptical(10, 10),
                      bottomLeft: Radius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text(tds.sectionName ?? "-"),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return TeacherTdsWiseExamsScreen(
              teacherProfile: widget.teacherProfile,
              tds: tds,
            );
          }));
        },
      ),
    );
  }

  Widget _buildAllTdsGrid() {
    int n = MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 1;
    List<Widget> rows = [];
    // for (int i = 0; i < _tdsList.length; i++) {
    int i = 0;
    while (i < _tdsList.length) {
      List<Widget> x = [];
      for (int j = 0; j < n; j++) {
        if (i >= _tdsList.length) {
          x.add(Expanded(
            child: Container(),
          ));
        } else {
          x.add(Expanded(child: _tdsWidget(_tdsList[i])));
        }
        i = i + 1;
      }
      rows.add(Row(
        // mainAxisSize: MainAxisSize.min,
        children: x,
      ));
    }
    if (rows.isEmpty) {
      return const Center(
        child: Text("You are not assigned as a teacher to any section"),
      );
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exams"),
        actions: [
          buildRoleButtonForAppBar(context, widget.teacherProfile),
        ],
      ),
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
              child: _buildAllTdsGrid(),
            ),
    );
  }
}
