import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/academic_planner/views/academic_planner_date_wise_calender_view.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminAcademicPlannerOptionsScreen extends StatefulWidget {
  const AdminAcademicPlannerOptionsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/academic_planner";

  @override
  _AdminAcademicPlannerOptionsScreenState createState() => _AdminAcademicPlannerOptionsScreenState();
}

class _AdminAcademicPlannerOptionsScreenState extends State<AdminAcademicPlannerOptionsScreen> {
  Widget _getAcademicPlannerOption(String title, String? description, StatefulWidget nextWidget) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return nextWidget;
        }));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(10), // margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: const Icon(
                    Icons.adjust,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      Text(
                        description ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AcademicPlanner"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        primary: false,
        children: <Widget>[
          _getAcademicPlannerOption(
            "Calender View",
            null,
            AcademicPlannerDateWiseCalenderView(
              adminProfile: widget.adminProfile,
            ),
          ),
        ],
      ),
    );
  }
}
