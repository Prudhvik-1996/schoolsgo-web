import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_assign_bus_fee_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_assign_fee_type_to_sections_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_fee_receipts_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_manage_terms_screen.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_student_fee_management_screen.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminFeeOptionsScreen extends StatefulWidget {
  const AdminFeeOptionsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/fee";

  @override
  _AdminFeeOptionsScreenState createState() => _AdminFeeOptionsScreenState();
}

class _AdminFeeOptionsScreenState extends State<AdminFeeOptionsScreen> {
  Widget _getFeeOption(String title, String? description, StatefulWidget nextWidget) {
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
        title: const Text("Fee"),
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        primary: false,
        children: <Widget>[
          // _getTimeTableOption(
          //   "Manage Fee Types",
          //   null,
          //   AdminManageFeeTypesScreen(
          //     adminProfile: widget.adminProfile,
          //   ),
          // ),
          _getFeeOption(
            "Manage Fee Assignment",
            null,
            AdminAssignFeeTypesToSectionsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getFeeOption(
            "Terms Management",
            null,
            AdminManageTermsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getFeeOption(
            "Student Fee Management",
            null,
            AdminStudentFeeManagementScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getFeeOption(
            "Bus Fee Management",
            null,
            AdminAssignBusFeeScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
          _getFeeOption(
            "Fee Receipts",
            null,
            AdminFeeReceiptsScreen(
              adminProfile: widget.adminProfile,
            ),
          ),
        ],
      ),
    );
  }
}
