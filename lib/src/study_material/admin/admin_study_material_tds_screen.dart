import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

import 'admin_study_material_screen.dart';

class AdminStudyMaterialTDSScreen extends StatefulWidget {
  const AdminStudyMaterialTDSScreen({Key? key, required this.adminProfile})
      : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/study_material";

  @override
  _AdminStudyMaterialTdsScreenState createState() =>
      _AdminStudyMaterialTdsScreenState();
}

class _AdminStudyMaterialTdsScreenState
    extends State<AdminStudyMaterialTDSScreen> {
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

    GetTeacherDealingSectionsResponse getTeacherDealingSectionsResponse =
        await getTeacherDealingSections(GetTeacherDealingSectionsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getTeacherDealingSectionsResponse.httpStatus == "OK" &&
        getTeacherDealingSectionsResponse.responseStatus == "success") {
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
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20,
              MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: InkWell(
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            margin: const EdgeInsets.all(15),
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Text("Section: ${tds.sectionName}"),
                Text("Subject: ${tds.subjectName!.capitalize()}"),
                Text("Teacher: ${tds.teacherName!.capitalize()}"),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AdminStudyMaterialScreen(
              adminProfile: widget.adminProfile,
              tds: tds,
            );
          }));
        },
      ),
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
            widget.adminProfile,
          ),
        ],
      ),
      drawer: AdminAppDrawer(adminProfile: widget.adminProfile),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: _tdsList.map((tds) => _tdsWidget(tds)).toList(),
            ),
    );
  }
}
