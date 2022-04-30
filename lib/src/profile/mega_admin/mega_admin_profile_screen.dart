import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/profile/student/profile_picture_screen.dart';

class MegaAdminProfileScreen extends StatefulWidget {
  const MegaAdminProfileScreen({Key? key, required this.megaAdminProfile}) : super(key: key);

  final MegaAdminProfile megaAdminProfile;

  static const routeName = "/profile";

  @override
  _MegaAdminProfileScreenState createState() => _MegaAdminProfileScreenState();
}

class _MegaAdminProfileScreenState extends State<MegaAdminProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          buildRoleButtonForAppBar(context, widget.megaAdminProfile),
        ],
      ),
      drawer: MegaAdminAppDrawer(
        megaAdminProfile: widget.megaAdminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(25),
                    child: SizedBox(
                      height: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100,
                      width: MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 100,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return ProfilePictureScreen(
                              name: (widget.megaAdminProfile.userName ?? ""),
                              pictureUrl: "https://drive.google.com/uc?id=1XC8IaBukQkcmPnysy811oDbZrQImDvs2",
                            );
                          }));
                        },
                        child: ClayButton(
                          depth: 100,
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          spread: 0,
                          borderRadius: 150,
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            child: const ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(150.0),
                                topRight: Radius.circular(150.0),
                                bottomRight: Radius.circular(150.0),
                                bottomLeft: Radius.circular(150.0),
                              ),
                              child: FadeInImage(
                                placeholder: AssetImage(
                                  'assets/images/loading_grey_white.gif',
                                ),
                                image: NetworkImage(
                                  "https://drive.google.com/uc?id=1XC8IaBukQkcmPnysy811oDbZrQImDvs2",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: MediaQuery.of(context).orientation == Orientation.landscape
                      ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
                      : const EdgeInsets.all(20),
                  // padding: EdgeInsets.all(25),
                  child: ClayContainer(
                    depth: 10,
                    color: clayContainerColor(context),
                    spread: 1,
                    borderRadius: 10,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Text(
                                  "Name: ${widget.megaAdminProfile.userName ?? "-"}",
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Text(
                                  "Franchise name: ${widget.megaAdminProfile.franchiseName ?? "-"}",
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Text(
                                  "Mail Id: ${widget.megaAdminProfile.mailId ?? "-"}",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
