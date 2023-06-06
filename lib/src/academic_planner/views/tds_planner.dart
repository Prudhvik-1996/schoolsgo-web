import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/views/planner_creation.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';

class TdsPlanner extends StatefulWidget {
  const TdsPlanner({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;

  @override
  State<TdsPlanner> createState() => _TdsPlannerState();
}

class _TdsPlannerState extends State<TdsPlanner> {
  bool _isLoading = false;
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

    GetTeacherDealingSectionsRequest getTeacherDealingSectionsRequest = GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    );
    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse = await getTeacherDealingSections(getTeacherDealingSectionsRequest);
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" && getTeacherDealingSectionsResponse.responseStatus == "success") {
      setState(() {
        _tdsList = getTeacherDealingSectionsResponse.teacherDealingSections!.map((e) => e).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Planner"),
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
              children: _tdsList
                  .where((e) => e.status == 'active')
                  .map((e) => Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PlannerCreationScreen(
                                  adminProfile: widget.adminProfile,
                                  tds: e,
                                );
                              },
                            ),
                          ),
                          child: Card(
                            color: clayContainerColor(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Section: ${e.sectionName}\n"
                                  "Subject: ${e.subjectName}\n"
                                  "Teacher: ${e.teacherName}"),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
