import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/circulars/modal/circular_type.dart';
import 'package:schoolsgo_web/src/circulars/modal/circulars.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TeacherCircularsScreen extends StatefulWidget {
  const TeacherCircularsScreen({Key? key, required this.teacherProfile}) : super(key: key);

  final TeacherProfile teacherProfile;

  static const routeName = "/circulars";

  @override
  State<TeacherCircularsScreen> createState() => _TeacherCircularsScreenState();
}

class _TeacherCircularsScreenState extends State<TeacherCircularsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  List<CircularBean> circulars = [];
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetCircularsResponse getCircularsResponse = await getCirculars(GetCircularsRequest(
      schoolId: widget.teacherProfile.schoolId,
      franchiseId: widget.teacherProfile.franchiseId,
      role: "T",
    ));
    if (getCircularsResponse.httpStatus != "OK" || getCircularsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        circulars = getCircularsResponse.circulars!.map((e) => e!).toList();
        circulars.sort(
          (b, a) => (a.createTime ?? 0).compareTo((b.createTime ?? 0)),
        );
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Circulars"),
        actions: [
          buildRoleButtonForAppBar(context, widget.teacherProfile),
        ],
      ),
      drawer: TeacherAppDrawer(
        teacherProfile: widget.teacherProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemCount: circulars.where((e) => e.status == "active").toList().length,
                    itemBuilder: (context, index) => Container(
                      margin: MediaQuery.of(context).orientation == Orientation.landscape
                          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
                          : const EdgeInsets.all(20),
                      child: _buildCircularsWidgetForReadMode(
                        circulars.where((e) => e.status == "active").toList()[index],
                        canEdit: false,
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildCircularsWidgetForReadMode(
    CircularBean circular, {
    bool canEdit = true,
  }) {
    return Stack(
      children: [
        ClayContainer(
          depth: 20,
          color: clayContainerColor(context),
          spread: 5,
          borderRadius: 10,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  color: Colors.yellow,
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            circular.title ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (canEdit)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                circular.showSentTo = !circular.showSentTo;
                              });
                            },
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.black,
                            ),
                          ),
                        const SizedBox(
                          width: 15,
                        ),
                        if (canEdit)
                          InkWell(
                            onTap: () {
                              setState(() {
                                circular.isEditMode = true;
                              });
                            },
                            child: ClayButton(
                              depth: 40,
                              surfaceColor: Colors.yellow,
                              parentColor: Colors.yellow,
                              spread: 1,
                              borderRadius: 10,
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        circular.description ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
              circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList().isEmpty
                  ? Container()
                  : Container(
                      // height: 150,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList().length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              openMediaBeans(circular, index);
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: 100,
                              width: 100,
                              padding: const EdgeInsets.all(2),
                              child: getFileTypeForExtension(
                                          circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!) ==
                                      MediaFileType.IMAGE_FILES
                                  ? FadeInImage(
                                      image:
                                          NetworkImage(circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!),
                                      placeholder: const AssetImage(
                                        'assets/images/loading_grey_white.gif',
                                      ),
                                    )
                                  : Image.asset(
                                      getAssetImageForFileType(
                                        getFileTypeForExtension(
                                          circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!,
                                        ),
                                      ),
                                      scale: 0.5,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        circular.createTime == null ? "-" : convertEpochToDDMMYYYYEEEEHHMMAA(circular.createTime!),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (circular.showSentTo && canEdit)
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 60, 60, 0),
              decoration: BoxDecoration(
                border: Border.all(),
                color: clayContainerColor(context),
              ),
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                      const SizedBox(
                        height: 50,
                        width: 150,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Circular sent to:",
                          ),
                        ),
                      ),
                    ] +
                    rolesPerCircularType(circular.circularType ?? "-").map((e) => getRoleWidget(e)).toList(),
              ),
            ),
          ),
      ],
    );
  }

  openMediaBeans(CircularBean circular, int index) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      circular.circularMediaBeans![index]!.mediaUrl!,
      (int viewId) => html.IFrameElement()
        ..src = circular.circularMediaBeans![index]!.mediaUrl!
        ..allowFullscreen = false
        ..style.border = 'none'
        ..height = '500'
        ..width = '300',
    );
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  "${circular.title}",
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              if (!circular.isEditMode)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: const Icon(Icons.download_rounded),
                      onTap: () {
                        downloadFile(
                          circular.circularMediaBeans![index]!.mediaUrl!,
                          filename: getCurrentTimeStringInDDMMYYYYHHMMSS() + "." + circular.circularMediaBeans![index]!.mediaType!,
                        );
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: const Icon(Icons.open_in_new),
                      onTap: () {
                        html.window.open(
                          circular.circularMediaBeans![index]!.mediaUrl!,
                          '_blank',
                        );
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
            ],
          ),
          content: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  openMediaBeans(circular, index - 1);
                },
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: index == 0 ? null : const Icon(Icons.arrow_left),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 1,
                child: getFileTypeForExtension(circular.circularMediaBeans![index]!.mediaType!) == MediaFileType.IMAGE_FILES
                    ? FadeInImage(
                        placeholder: const AssetImage(
                          'assets/images/loading_grey_white.gif',
                        ),
                        image: NetworkImage(circular.circularMediaBeans![index]!.mediaUrl!),
                        fit: BoxFit.contain,
                      )
                    : HtmlElementView(
                        viewType: circular.circularMediaBeans![index]!.mediaUrl!,
                      ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  openMediaBeans(circular, index + 1);
                },
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: index == circular.circularMediaBeans!.length - 1 ? null : const Icon(Icons.arrow_right),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
