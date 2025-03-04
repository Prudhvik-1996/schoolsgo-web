import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/bus/admin/admin_bus_management_screen.dart';
import 'package:schoolsgo_web/src/bus/admin/admin_bus_route_management.dart';
import 'package:schoolsgo_web/src/bus/admin/admin_stop_wise_student_assignment_screen_v2.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class AdminBusOptionsScreen extends StatefulWidget {
  const AdminBusOptionsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/bus";

  @override
  _AdminBusOptionsScreenState createState() => _AdminBusOptionsScreenState();
}

class _AdminBusOptionsScreenState extends State<AdminBusOptionsScreen> {
  Widget _getBusOption(String title, String? description, StatefulWidget nextWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus"),
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : AdminAppDrawer(
              adminProfile: widget.adminProfile,
            ),
      body: ListView(
        padding: EdgeInsets.zero,
        primary: false,
        children: <Widget>[
          _getBusOption(
            "Bus Management",
            null,
            AdminBusManagementScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getBusOption(
            "Bus Route Management",
            null,
            AdminRouteManagementScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getBusOption(
            "Student - Bus Assignment",
            null,
            AdminStopWiseStudentAssignmentScreenV2(
              adminProfile: widget.adminProfile,
            ),
          ),
          // _getBusOption(
          //   "Bus Tracking",
          //   null,
          //   AdminBusTrackingScreen(
          //     adminProfile: widget.adminProfile,
          //   ),
          // ),
        ],
      ),
    );
  }
}
