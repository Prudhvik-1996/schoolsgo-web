import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/fancy_fab.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../model/notice_board.dart';

class AdminNoticeBoardScreen extends StatefulWidget {
  const AdminNoticeBoardScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/noticeboard";

  @override
  _AdminNoticeBoardScreenState createState() => _AdminNoticeBoardScreenState();
}

class _AdminNoticeBoardScreenState extends State<AdminNoticeBoardScreen> {
  bool _isLoading = true;

  List<News?> _noticeBoardNews = [];
  final ItemScrollController _itemScrollController = ItemScrollController();
  bool _isReverse = false;
  late News newNews;
  bool _createNewNews = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _createNewNews = false;
      newNews = News(
        title: "",
        description: "",
        newsMediaBeans: [],
        status: "active",
        schoolId: widget.adminProfile.schoolId,
        franchiseId: widget.adminProfile.franchiseId,
        agent: widget.adminProfile.userId,
        createTime: DateTime.now().millisecondsSinceEpoch,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );
    });

    GetNoticeBoardResponse getNoticeBoardResponse = await getNoticeBoard(GetNoticeBoardRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
    ));

    if (getNoticeBoardResponse.httpStatus == 'OK' && getNoticeBoardResponse.responseStatus == 'success') {
      setState(() {
        _noticeBoardNews = getNoticeBoardResponse.noticeBoard!.news!.reversed.toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges(News eachNews) async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: Text(eachNews.status == "inactive"
              ? "Are you sure you want to delete the following news?"
              : "Are you sure you want to submit changes for the following news?"),
          content: Container(
            margin: const EdgeInsets.all(20),
            width: (MediaQuery.of(context).size.width) / (MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2),
            height: (MediaQuery.of(context).size.height) / (MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1),
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                buildEachNewsWidget(eachNews, false),
              ],
            ),
          ),
          actions: [
            ClayButton(
              depth: 40,
              surfaceColor: Theme.of(context).primaryColor,
              parentColor: Theme.of(context).primaryColor,
              spread: 1,
              borderRadius: 10,
              child: InkWell(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: Text(eachNews.status == "inactive" ? "Confirm" : "Submit"),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });
                  bool _errorOccurred = false;
                  List<NewsMediaBean> _newsMediaBeansToBeEdited = [];
                  List<NewsMediaBean?> _originalNewsMediaBeans = _noticeBoardNews
                      .map((News? e) => News.fromJson(e!.origJson()))
                      .map((News e) => e.newsMediaBeans)
                      .expand((List<NewsMediaBean?>? i) => i!)
                      .toList();
                  List<NewsMediaBean?> _currentNewsMediaBeans =
                      _noticeBoardNews.map((News? e) => e!.newsMediaBeans).expand((List<NewsMediaBean?>? i) => i!).toList();

                  for (var eachNewMediaBean in _currentNewsMediaBeans) {
                    if (!_originalNewsMediaBeans.contains(eachNewMediaBean)) {
                      _newsMediaBeansToBeEdited.add(eachNewMediaBean!);
                    }
                  }

                  CreateOrUpdateNoticeBoardMediaRequest createOrUpdateNoticeBoardMediaRequest = CreateOrUpdateNoticeBoardMediaRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId.toString(),
                    newsMediaBeans: _newsMediaBeansToBeEdited,
                  );

                  CreateOrUpdateNoticeBoardMediaResponse createOrUpdateNoticeBoardMediaResponse =
                      await createOrUpdateNoticeBoardMedia(createOrUpdateNoticeBoardMediaRequest);
                  if (createOrUpdateNoticeBoardMediaResponse.httpStatus != 'OK' ||
                      createOrUpdateNoticeBoardMediaResponse.responseStatus != 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong while trying to execute your request..\nPlease try again later"),
                      ),
                    );
                  }

                  News _oldNews = News.fromJson(eachNews.origJson());
                  if (_oldNews.description != eachNews.description || _oldNews.title != eachNews.title || _oldNews.status != eachNews.status) {
                    CreateOrUpdateNoticeBoardResponse createOrUpdateNoticeBoardResponse = await createOrUpdateNoticeBoard(
                      CreateOrUpdateNoticeBoardRequest(
                        schoolId: eachNews.schoolId,
                        description: eachNews.description,
                        agentId: widget.adminProfile.userId,
                        status: eachNews.status,
                        title: eachNews.title,
                        newsId: eachNews.newsId,
                      ),
                    );

                    if (createOrUpdateNoticeBoardResponse.httpStatus != 'OK' || createOrUpdateNoticeBoardResponse.responseStatus != 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong while trying to execute your request..\nPlease try again later"),
                        ),
                      );
                    }
                  }

                  setState(() {
                    _isLoading = false;
                  });

                  if (!_errorOccurred) {
                    setState(() {
                      eachNews.isEditMode = false;
                    });
                  }

                  if (eachNews.status == "inactive") {
                    _loadData();
                  }
                },
              ),
            ),
            ClayButton(
              depth: 40,
              surfaceColor: Theme.of(context).primaryColor,
              parentColor: Theme.of(context).primaryColor,
              spread: 1,
              borderRadius: 10,
              child: InkWell(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: const Text("Cancel"),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNewNews() async {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: const Text("Are you sure you want to submit changes for the following news?"),
          content: Container(
            margin: const EdgeInsets.all(20),
            width: (MediaQuery.of(context).size.width) / (MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 2),
            height: (MediaQuery.of(context).size.height) / (MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1),
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                buildEachNewsWidget(newNews, false),
              ],
            ),
          ),
          actions: [
            ClayButton(
              depth: 40,
              surfaceColor: Theme.of(context).primaryColor,
              parentColor: Theme.of(context).primaryColor,
              spread: 1,
              borderRadius: 10,
              child: GestureDetector(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: const Text("Submit"),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });

                  CreateOrUpdateNoticeBoardResponse createOrUpdateNoticeBoardResponse = await createOrUpdateNoticeBoard(
                    CreateOrUpdateNoticeBoardRequest(
                      schoolId: newNews.schoolId,
                      description: newNews.description,
                      agentId: widget.adminProfile.userId,
                      franchiseId: widget.adminProfile.franchiseId,
                      status: newNews.status,
                      title: newNews.title,
                      newsId: newNews.newsId,
                    ),
                  );

                  if (createOrUpdateNoticeBoardResponse.httpStatus != 'OK' || createOrUpdateNoticeBoardResponse.responseStatus != 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong while trying to execute your request..\nPlease try again later"),
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    return;
                  } else {
                    setState(() {
                      newNews.newsId = createOrUpdateNoticeBoardResponse.newsId;
                      for (var eachNewsMediaBean in newNews.newsMediaBeans!) {
                        eachNewsMediaBean!.newsId = newNews.newsId;
                      }
                    });
                  }

                  CreateOrUpdateNoticeBoardMediaRequest createOrUpdateNoticeBoardMediaRequest = CreateOrUpdateNoticeBoardMediaRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId.toString(),
                    newsMediaBeans: newNews.newsMediaBeans!.map((e) => e!).toList(),
                  );

                  CreateOrUpdateNoticeBoardMediaResponse createOrUpdateNoticeBoardMediaResponse =
                      await createOrUpdateNoticeBoardMedia(createOrUpdateNoticeBoardMediaRequest);
                  if (createOrUpdateNoticeBoardMediaResponse.httpStatus != 'OK' ||
                      createOrUpdateNoticeBoardMediaResponse.responseStatus != 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong while trying to execute your request..\nPlease try again later"),
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    return;
                  }

                  setState(() {
                    _isLoading = false;
                  });
                  _loadData();
                },
              ),
            ),
            ClayButton(
              depth: 40,
              surfaceColor: Theme.of(context).primaryColor,
              parentColor: Theme.of(context).primaryColor,
              spread: 1,
              borderRadius: 10,
              child: GestureDetector(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  child: const Text("Cancel"),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildEachNewsWidget(News eachNews, bool canEdit) {
    return ClayContainer(
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              color: Theme.of(context).primaryColor,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        eachNews.title!,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (canEdit)
                      InkWell(
                        onTap: () {
                          setState(() {
                            eachNews.isEditMode = true;
                          });
                        },
                        child: ClayButton(
                          depth: 40,
                          surfaceColor: Theme.of(context).primaryColor,
                          parentColor: Theme.of(context).primaryColor,
                          spread: 1,
                          borderRadius: 10,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
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
                    "${eachNews.description}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
          eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList().isEmpty
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
                    itemCount: eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList().length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          openMediaBeans(eachNews, index);
                        },
                        child: Container(
                          color: Colors.transparent,
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.all(2),
                          child:
                              getFileTypeForExtension(eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!) ==
                                      MediaFileType.IMAGE_FILES
                                  ? MediaLoadingWidget(
                                      mediaUrl: eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                                    )
                                  : Image.asset(
                                      getAssetImageForFileType(
                                        getFileTypeForExtension(
                                          eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!,
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
                    convertEpochToDDMMYYYYEEEEHHMMAA(eachNews.createTime!),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEachEditableNewsWidget(News eachNews) {
    return ClayContainer(
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
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              color: Theme.of(context).primaryColor,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Title",
                        ),
                        cursorColor: Colors.white,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                        initialValue: eachNews.title ?? "",
                        onChanged: (text) => setState(() {
                          eachNews.title = text;
                        }),
                        // onEditingComplete: () => debugPrint("text"),
                      ),
                    ),
                    if (eachNews.newsId != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              eachNews.status = "inactive";
                            });
                            _saveChanges(eachNews);
                          },
                          child: ClayButton(
                            depth: 40,
                            surfaceColor: Colors.red,
                            parentColor: Colors.red,
                            spread: 1,
                            borderRadius: 10,
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: InkWell(
                        onTap: () {
                          if (eachNews.newsId == null) {
                            _saveNewNews();
                          } else {
                            _saveChanges(eachNews);
                          }
                        },
                        child: ClayButton(
                          depth: 40,
                          surfaceColor: Theme.of(context).primaryColor,
                          parentColor: Theme.of(context).primaryColor,
                          spread: 1,
                          borderRadius: 10,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
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
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Description",
                    ),
                    maxLines: null,
                    initialValue: eachNews.description ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
                    onChanged: (text) => setState(() {
                      eachNews.description = text;
                    }),
                    // onEditingComplete: () => debugPrint("text"),
                  ),
                ),
              ],
            ),
          ),
          Container(
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
              itemCount: eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList().length + 1,
              itemBuilder: (context, index) {
                if (index == eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList().length) {
                  return InkWell(
                    onTap: () {
                      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                      uploadInput.multiple = true;
                      uploadInput.draggable = true;
                      uploadInput.accept =
                          '.png,.jpg,.jpeg,.pdf,.zip,.doc,.7z,.arj,.deb,.pkg,.rar,.rpm,.tar.gz,.z,.zip,.csv,.dat,.db,.dbf,.log,.mdb,.sav,.sql,.tar,.xml';
                      uploadInput.click();
                      uploadInput.onChange.listen(
                        (changeEvent) {
                          final files = uploadInput.files!;
                          for (html.File file in files) {
                            final reader = html.FileReader();
                            reader.readAsDataUrl(file);
                            reader.onLoadEnd.listen(
                              (loadEndEvent) async {
                                // _file = file;
                                debugPrint("File uploaded: " + file.name);
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  UploadFileToDriveResponse uploadFileResponse = await uploadFileToDrive(reader.result!, file.name);

                                  NewsMediaBean newsMediaBean = NewsMediaBean();
                                  newsMediaBean.newsId = eachNews.newsId;
                                  newsMediaBean.status = "active";
                                  newsMediaBean.mediaType = uploadFileResponse.mediaBean!.mediaType;
                                  newsMediaBean.mediaUrl = uploadFileResponse.mediaBean!.mediaUrl;
                                  newsMediaBean.mediaId = uploadFileResponse.mediaBean!.mediaId;

                                  if (eachNews.newsMediaBeans == null && eachNews.newsMediaBeans!.isEmpty) {
                                    setState(() {
                                      eachNews.newsMediaBeans = [];
                                    });
                                  }
                                  setState(() {
                                    eachNews.newsMediaBeans!.add(newsMediaBean);
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
                                    ),
                                  );
                                }

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                            );
                          }
                        },
                      );
                    },
                    child: Stack(
                      children: const [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.add_to_photos),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text("Add attachments"),
                          ),
                        )
                      ],
                    ),
                  );
                }
                return InkWell(
                  onTap: () {
                    openMediaBeans(eachNews, index);
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: 100,
                    width: 100,
                    padding: const EdgeInsets.all(2),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child:
                              getFileTypeForExtension(eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!) ==
                                      MediaFileType.IMAGE_FILES
                                  ? MediaLoadingWidget(
                                      mediaUrl: eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                                    )
                                  : Image.asset(
                                      getAssetImageForFileType(
                                        getFileTypeForExtension(
                                          eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!,
                                        ),
                                      ),
                                      scale: 0.5,
                                    ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              if (eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.status == 'active') {
                                setState(() {
                                  eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.status = 'inactive';
                                });
                              } else {
                                setState(() {
                                  eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.status = 'active';
                                });
                              }
                            },
                            child: eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.status == 'active'
                                ? const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  )
                                : const Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ],
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
                    "Last Updated: " + convertEpochToDDMMYYYYEEEEHHMMAA(eachNews.createTime!),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  openMediaBeans(News eachNews, int index) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
      (int viewId) => html.IFrameElement()
        ..src = eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!
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
                  "${eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.description ?? eachNews.title}",
                ),
              ),
              const SizedBox(
                width: 10,
              ),
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
                        eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                        filename: getCurrentTimeStringInDDMMYYYYHHMMSS() +
                            "." +
                            eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!,
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
                        eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                        '_blank',
                      );
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              )
            ],
          ),
          content: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  openMediaBeans(eachNews, index - 1);
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
                child: getFileTypeForExtension(eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaType!) ==
                        MediaFileType.IMAGE_FILES
                    ? MediaLoadingWidget(
                        mediaUrl: eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                      )
                    : HtmlElementView(
                        viewType: eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
                      ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  openMediaBeans(eachNews, index + 1);
                },
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: index == eachNews.newsMediaBeans!.where((i) => i!.status != 'inactive').toList().length - 1
                        ? null
                        : const Icon(Icons.arrow_right),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Notice Board"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : _createNewNews
              ? Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        buildEachEditableNewsWidget(newNews),
                      ],
                    ),
                  ),
                )
              : ScrollablePositionedList.builder(
                  reverse: _isReverse,
                  itemScrollController: _itemScrollController,
                  itemCount: _noticeBoardNews.length,
                  itemBuilder: (context, index) => Container(
                    margin: MediaQuery.of(context).orientation == Orientation.landscape
                        ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
                        : const EdgeInsets.all(20),
                    child: _noticeBoardNews[index]!.isEditMode
                        ? buildEachEditableNewsWidget(_noticeBoardNews[index]!)
                        : buildEachNewsWidget(
                            _noticeBoardNews[index]!, _noticeBoardNews.where((e) => e!.isEditMode).isEmpty && !widget.adminProfile.isMegaAdmin),
                  ),
                ),
      floatingActionButton: _isLoading || widget.adminProfile.isMegaAdmin
          ? null
          : Container(
              margin: const EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: _createNewNews
                  ? FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _createNewNews = false;
                        });
                      },
                      tooltip: "Cancel",
                      child: const Icon(Icons.close),
                    )
                  : ExpandableFab(
                      tooltip: "More Options",
                      expandedWidgets: [
                        FloatingActionButton(
                          onPressed: () async {
                            List<int> millisList = _noticeBoardNews.map((e) => e!.createTime!).toList();
                            millisList.sort((b, a) => a.compareTo(b));
                            List<String> _availableDates = millisList.map((e) => convertEpochToYYYYMMDD(e)).toList();
                            DateTime? _newDate = await showDatePicker(
                              context: context,
                              selectableDayPredicate: (DateTime val) {
                                return _availableDates.contains(convertDateTimeToYYYYMMDDFormat(val));
                              },
                              initialDate: DateTime.parse(_availableDates.first),
                              firstDate: DateTime.parse(_availableDates.last),
                              lastDate: DateTime.parse(_availableDates.first),
                              helpText: "Select a date",
                            );
                            if (_newDate == null) return;
                            setState(() {
                              _itemScrollController.scrollTo(
                                index: _availableDates.indexOf(convertEpochToYYYYMMDD(_newDate.millisecondsSinceEpoch)),
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeInOutCubic,
                              );
                            });
                          },
                          tooltip: "Search",
                          child: const Icon(Icons.calendar_today),
                        ),
                        if (_noticeBoardNews.where((e) => e!.newsId == null).isEmpty)
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                _createNewNews = true;
                              });
                            },
                            tooltip: "Add new notice",
                            child: const Icon(Icons.add),
                          ),
                      ],
                    ),
            ),
      floatingActionButtonLocation:
          MediaQuery.of(context).orientation == Orientation.landscape ? FloatingActionButtonLocation.endTop : FloatingActionButtonLocation.endFloat,
    );
  }
}
