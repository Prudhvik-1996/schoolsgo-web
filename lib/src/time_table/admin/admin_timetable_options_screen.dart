import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/time_table/admin/admin_teacher_dealing_sections_screen.dart';

import 'admin_all_teachers_preview_time_table_screens.dart';
import 'admin_edit_timetable_screen.dart';
import 'admin_time_table_randomizer_screen.dart';

class AdminTimeTableOptions extends StatefulWidget {
  const AdminTimeTableOptions({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/timetable";

  @override
  _AdminTimeTableOptionsState createState() => _AdminTimeTableOptionsState();
}

class _AdminTimeTableOptionsState extends State<AdminTimeTableOptions> {
  @override
  void initState() {
    super.initState();
  }

  Widget _getTimeTableOption(
      String title, String? description, StatefulWidget nextWidget) {
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

  // _getHeaderRow() {
  //   return EisStandardHeader(
  //     title: ClayText(
  //       "Time Table",
  //       size: 32,
  //       textColor: Colors.blueGrey,
  //       spread: 2,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        primary: false,
        children: <Widget>[
          // _getHeaderRow(),
          _getTimeTableOption(
            "Teacher Dealing Sections",
            null,
            AdminTeacherDealingSectionsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getTimeTableOption(
            "Section Wise Time Slots Management",
            null,
            AdminEditTimeTable(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getTimeTableOption(
            "Automatic Time Table Generation",
            null,
            AdminTimeTableRandomizer(adminProfile: widget.adminProfile),
          ),
          _getTimeTableOption(
            "All Teachers' Time Table Preview",
            null,
            AdminAllTeacherTimeTablePreviewScreen(
              adminProfile: widget.adminProfile,
              teacherProfile: null,
            ),
          ),
        ],
      ),
    );
  }
}
