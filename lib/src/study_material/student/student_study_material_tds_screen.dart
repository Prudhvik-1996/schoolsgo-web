import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/study_material/student/student_study_material_screen.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentStudyMaterialTDSScreen extends StatefulWidget {
  const StudentStudyMaterialTDSScreen({Key? key, required this.studentProfile}) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/study_material";

  @override
  _StudentStudyMaterialTdsScreenState createState() => _StudentStudyMaterialTdsScreenState();
}

class _StudentStudyMaterialTdsScreenState extends State<StudentStudyMaterialTDSScreen> {
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
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
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
          child: Container(
            margin: const EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // physics: const NeverScrollableScrollPhysics(),
                // shrinkWrap: true,
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
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return StudentStudyMaterialScreen(
              studentProfile: widget.studentProfile,
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
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Material"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.studentProfile,
          ),
        ],
      ),
      drawer: StudentAppDrawer(studentProfile: widget.studentProfile),
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
