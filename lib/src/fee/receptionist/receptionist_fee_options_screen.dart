import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/fee/admin/admin_fee_receipts_screen_v3.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';

class ReceptionistFeeOptionsScreen extends StatefulWidget {
  const ReceptionistFeeOptionsScreen({
    Key? key,
    required this.receptionistProfile,
  }) : super(key: key);

  final OtherUserRoleProfile receptionistProfile;
  static const routeName = "/fee";

  @override
  State<ReceptionistFeeOptionsScreen> createState() => _ReceptionistFeeOptionsScreenState();
}

class _ReceptionistFeeOptionsScreenState extends State<ReceptionistFeeOptionsScreen> {
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
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : ReceptionistAppDrawer(
              receptionistProfile: widget.receptionistProfile,
            ),
      body: ListView(
        padding: EdgeInsets.zero,
        primary: false,
        children: <Widget>[
          _getFeeOption(
            "Fee Receipts",
            null,
            AdminFeeReceiptsScreenV3(
              otherRole: widget.receptionistProfile,
            ),
          ),
        ],
      ),
    );
  }
}
