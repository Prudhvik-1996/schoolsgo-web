import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminPublishResultsScreen extends StatefulWidget {
  const AdminPublishResultsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/publish_results";

  @override
  _AdminPublishResultsScreenState createState() =>
      _AdminPublishResultsScreenState();
}

class _AdminPublishResultsScreenState extends State<AdminPublishResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish Results"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
    );
  }
}
