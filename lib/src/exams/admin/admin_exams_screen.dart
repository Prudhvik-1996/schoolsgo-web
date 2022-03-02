import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/exams/admin/grading_algorithms/admin_grading_algorithms_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/manage_exams/admin_manage_exams_screen.dart';
import 'package:schoolsgo_web/src/exams/admin/publish_results/admin_publish_results_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminExamsScreen extends StatefulWidget {
  const AdminExamsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/exams";

  @override
  _AdminExamsScreenState createState() => _AdminExamsScreenState();
}

class _AdminExamsScreenState extends State<AdminExamsScreen> {
  Widget _getExamsOption(
      String title, String? description, StatefulWidget nextWidget) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return nextWidget;
          }));
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(10),
            // margin: const EdgeInsets.all(10),
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
        title: const Text("Exams"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: ListView(
        children: [
          _getExamsOption(
            "Manage Exams",
            null,
            AdminManageExamsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getExamsOption(
            "Publish Results",
            null,
            AdminPublishResultsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getExamsOption(
            "Grading Algorithms",
            null,
            AdminGradingAlgorithmsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
        ],
      ),
    );
  }
}
