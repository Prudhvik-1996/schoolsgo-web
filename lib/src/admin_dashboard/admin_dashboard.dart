import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/dashboard_widgets.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key, required this.adminProfile})
      : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/admin_dashboard";

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    int count =
        MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 3;
    double mainMargin =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.width / 10
            : 10;
    return Scaffold(
      restorationId: 'AdminDashBoard',
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
          InkWell(
            onTap: () {
              //  TODO performLogout
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        controller: ScrollController(),
        children: [
          EisStandardHeader(
            title: ClayText(
              "Admin Dashboard",
              size: 32,
              textColor: Colors.blueGrey,
              spread: 2,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(mainMargin, 20, mainMargin, mainMargin),
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(1.5),
              crossAxisCount: count,
              childAspectRatio: 1,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              physics: const NeverScrollableScrollPhysics(),
              children: adminDashBoardWidgets(widget.adminProfile)
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        print("Entering ${e.routeName}");
                        Navigator.pushNamed(
                          context,
                          e.routeName!,
                          arguments: e.argument as AdminProfile,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: EdgeInsets.all(
                            MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? 7.0
                                : 0.0),
                        child: ClayButton(
                          depth: 40,
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          spread: 1,
                          borderRadius: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  padding: const EdgeInsets.all(5),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Center(
                                      child: e.image,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 20,
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).orientation ==
                                              Orientation.landscape
                                          ? 5
                                          : 2),
                                  width: double.infinity,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Center(
                                      child: Text("${e.title}"),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ), //new Cards()
                  )
                  .toList(),
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
