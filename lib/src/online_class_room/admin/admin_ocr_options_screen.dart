import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/online_class_room/admin/admin_manage_online_class_rooms_screen.dart';

import 'admin_monitor_online_class_rooms_screen.dart';

class AdminOnlineClassRoomsOptionsScreen extends StatefulWidget {
  const AdminOnlineClassRoomsOptionsScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/onlineclassroom";

  @override
  _AdminOnlineClassRoomsOptionsScreenState createState() => _AdminOnlineClassRoomsOptionsScreenState();
}

class _AdminOnlineClassRoomsOptionsScreenState extends State<AdminOnlineClassRoomsOptionsScreen> {
  Widget _getOcrOption(String title, String? description, StatefulWidget nextWidget) {
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
          _getOcrOption(
            "Manage Online Class Rooms",
            null,
            AdminManageOnlineClassRoomsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getOcrOption(
            "Monitor Online Class Rooms",
            null,
            AdminMonitorOnlineClassRoomsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
        ],
      ),
    );
  }
}
