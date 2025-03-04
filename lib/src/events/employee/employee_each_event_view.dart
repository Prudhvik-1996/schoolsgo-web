import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';

import '../model/events.dart';

class EmployeeEachEventView extends StatefulWidget {
  const EmployeeEachEventView({
    Key? key,
    required this.teacherProfile,
    this.otherUserRoleProfile,
    required this.event,
  }) : super(key: key);

  final TeacherProfile? teacherProfile;
  final OtherUserRoleProfile? otherUserRoleProfile;
  final Event event;

  static const routeName = "/event";

  @override
  _EmployeeEachEventViewState createState() => _EmployeeEachEventViewState();
}

class _EmployeeEachEventViewState extends State<EmployeeEachEventView> {
  bool _isLoading = true;
  List<EventMedia> eventMedia = [];

  int? previewingIndex;

  List<int> selectedIndices = [];
  bool selectMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      selectedIndices = [];
    });
    GetEventMediaResponse getEventMediaResponse = await getEventMedia(GetEventMediaRequest(eventId: widget.event.eventId));
    if (getEventMediaResponse.httpStatus == 'OK' && getEventMediaResponse.responseStatus == 'success') {
      setState(() {
        eventMedia = getEventMediaResponse.eventMedia!.map((e) => e!).where((e) => e.status == 'active').toList();
      });
      for (int index = 0; index < eventMedia.length; index++) {
        // ignore: undefined_prefixed_name
        ui.platformViewRegistry.registerViewFactory(
          eventMedia[index].mediaUrl!,
          (int viewId) => IFrameElement()
            ..src = eventMedia[index].mediaUrl!
            ..allowFullscreen = false
            ..style.border = 'none'
            ..height = '500'
            ..width = '300',
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget buildEventMediaWidget(int index) {
    EventMedia eachEventMedia = eventMedia[index];
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: selectedIndices.contains(index)
            ? Border.all(
                color: Theme.of(context).primaryColor,
                width: 6,
              )
            : null,
        borderRadius: selectedIndices.contains(index) ? BorderRadius.circular(10) : null,
      ),
      child: GestureDetector(
        onTap: () {
          if (selectMode) {
            if (selectedIndices.contains(index)) {
              setState(() {
                selectedIndices.remove(index);
              });
              if (selectedIndices.isEmpty) {
                setState(() {
                  selectMode = false;
                });
              }
            } else {
              setState(() {
                selectedIndices.add(index);
              });
            }
          } else {
            setState(() {
              previewingIndex = index;
            });
          }
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: getFileTypeForExtension(eachEventMedia.mediaType!) == MediaFileType.IMAGE_FILES
              ? MediaLoadingWidget(
                  mediaUrl: eachEventMedia.mediaUrl!,
                )
              : Image.asset(
                  getAssetImageForFileType(
                    getFileTypeForExtension(
                      eachEventMedia.mediaType!,
                    ),
                  ),
                  scale: 0.5,
                ),
        ),
      ),
    );
  }

  _performMoreActions(String choice) {
    if (choice == "select") {
      setState(() {
        selectMode = true;
      });
    } else if (choice == "clear") {
      setState(() {
        selectedIndices = [];
        selectMode = false;
      });
    } else if (choice == "select_all") {
      setState(() {
        selectedIndices = List<int>.generate(eventMedia.length, (i) => i * 1);
      });
    } else if (choice == "download") {
      for (int selectedIndex in selectedIndices) {
        downloadFile(
          eventMedia[selectedIndex].mediaUrl!,
          filename: getCurrentTimeStringInDDMMYYYYHHMMSS() + "." + eventMedia[selectedIndex].mediaType!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int count = MediaQuery.of(context).orientation == Orientation.landscape ? 6 : 3;
    double mainMargin = MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width / 20 : 10;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.eventName!),
        actions: [
          buildRoleButtonForAppBar(context, (widget.teacherProfile ?? widget.otherUserRoleProfile)!),
          PopupMenuButton<String>(
            onSelected: _performMoreActions,
            itemBuilder: (context) {
              return [
                if (!selectMode)
                  const PopupMenuItem<String>(
                    value: "select",
                    child: Text("Select"),
                  ),
                if (selectMode)
                  const PopupMenuItem<String>(
                    value: "select_all",
                    child: Text("Select All"),
                  ),
                if (selectMode)
                  const PopupMenuItem<String>(
                    value: "clear",
                    child: Text("Clear Selection"),
                  ),
                if (selectMode)
                  const PopupMenuItem<String>(
                    value: "download",
                    child: Text("Download Selection"),
                  ),
              ];
            },
          ),
        ],
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : widget.teacherProfile == null
              ? null
              : TeacherAppDrawer(
                  teacherProfile: widget.teacherProfile!,
                ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : previewingIndex == null
              ? Container(
                  margin: EdgeInsets.fromLTRB(mainMargin, 20, mainMargin, mainMargin),
                  child: GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(1.5),
                    crossAxisCount: count,
                    childAspectRatio: 1,
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,
                    physics: const BouncingScrollPhysics(),
                    children: List<int>.generate(eventMedia.length, (i) => i * 1).map((i) => buildEventMediaWidget(i)).toList(),
                  ),
                )
              : Center(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(15),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Tooltip(
                                    message: 'Download',
                                    child: InkWell(
                                      child: const Icon(Icons.download_rounded),
                                      onTap: () {
                                        downloadFile(
                                          eventMedia[previewingIndex!].mediaUrl!,
                                          filename: getCurrentTimeStringInDDMMYYYYHHMMSS() + "." + eventMedia[previewingIndex!].mediaType!,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(15),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Tooltip(
                                    message: 'Open in new window',
                                    child: InkWell(
                                      child: const Icon(Icons.open_in_new),
                                      onTap: () {
                                        window.open(
                                          eventMedia[previewingIndex!].mediaUrl!,
                                          '_blank',
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(15),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Tooltip(
                                    message: 'Close',
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          previewingIndex = null;
                                        });
                                      },
                                      child: const Icon(Icons.close),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(20),
                            child: previewingIndex == 0
                                ? const SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Icon(Icons.arrow_left),
                                    ),
                                  )
                                : Tooltip(
                                    message: 'Previous',
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          previewingIndex = previewingIndex! - 1;
                                        });
                                      },
                                      child: const SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(Icons.arrow_left),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.height / 1,
                            child: getFileTypeForExtension(eventMedia[previewingIndex!].mediaType!) == MediaFileType.IMAGE_FILES
                                ? MediaLoadingWidget(
                                    mediaUrl: eventMedia[previewingIndex!].mediaUrl!,
                                    mediaFit: BoxFit.contain,
                                  )
                                : HtmlElementView(
                                    viewType: eventMedia[previewingIndex!].mediaUrl!,
                                  ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(20),
                            child: previewingIndex == eventMedia.length - 1
                                ? const SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Icon(Icons.arrow_right),
                                    ),
                                  )
                                : Tooltip(
                                    message: 'Next',
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          previewingIndex = previewingIndex! + 1;
                                        });
                                      },
                                      child: const SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Icon(Icons.arrow_right),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
