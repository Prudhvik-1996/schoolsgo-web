import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/admin_dashboard/admin_dashboard.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class MegaAdminHomePage extends StatefulWidget {
  MegaAdminHomePage({
    Key? key,
    required this.megaAdminProfiles,
  }) : super(key: key);

  static const String routeName = 'mega_admin';
  List<MegaAdminProfile> megaAdminProfiles;

  @override
  _MegaAdminHomePageState createState() => _MegaAdminHomePageState();
}

class _MegaAdminHomePageState extends State<MegaAdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Epsilon Diary"),
      ),
      drawer: const DefaultAppDrawer(),
      body: ListView(
        children: widget.megaAdminProfiles
            .map(
              (MegaAdminProfile eachMegaAdminProfile) => buildMegaAdminButton(context, eachMegaAdminProfile),
            )
            .toList(),
      ),
    );
  }

  Container buildMegaAdminButton(BuildContext context, MegaAdminProfile eachMegaAdminProfile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: InkWell(
        onTap: () {
          AdminProfile adminProfile = AdminProfile(
            schoolId: eachMegaAdminProfile.schoolId,
            schoolName: eachMegaAdminProfile.schoolName,
            userId: eachMegaAdminProfile.userId,
            firstName: eachMegaAdminProfile.userName,
            mailId: eachMegaAdminProfile.mailId,
            schoolPhotoUrl: eachMegaAdminProfile.schoolPhotoUrl,
            isMegaAdmin: true,
          );
          Navigator.pushNamed(
            context,
            AdminDashboard.routeName,
            arguments: adminProfile,
          );
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            // child: Text("Student: ${e.studentFirstName}"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        eachMegaAdminProfile.schoolName ?? "-",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 50,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (eachMegaAdminProfile.city ?? "-").capitalize(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
