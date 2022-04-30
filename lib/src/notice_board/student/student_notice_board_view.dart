import 'dart:html';
import 'dart:ui' as ui;

import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../model/notice_board.dart';

class StudentNoticeBoardView extends StatefulWidget {
  const StudentNoticeBoardView({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/noticeboard";

  @override
  _StudentNoticeBoardViewState createState() => _StudentNoticeBoardViewState();
}

class _StudentNoticeBoardViewState extends State<StudentNoticeBoardView> {
  bool _isLoading = true;

  List<News?> _noticeBoardNews = [];
  final ItemScrollController _itemScrollController = ItemScrollController();
  bool _isReverse = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetNoticeBoardResponse getNoticeBoardResponse = await getNoticeBoard(GetNoticeBoardRequest(schoolId: widget.studentProfile.schoolId));

    if (getNoticeBoardResponse.httpStatus == 'OK' && getNoticeBoardResponse.responseStatus == 'success') {
      setState(() {
        _noticeBoardNews = getNoticeBoardResponse.noticeBoard!.news!.reversed.toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildEachNewsWidget(News eachNews) {
    return Container(
      margin: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: ClayContainer(
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
            eachNews.newsMediaBeans!.isEmpty
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
                      itemCount: eachNews.newsMediaBeans!.length,
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
                            child: getFileTypeForExtension(eachNews.newsMediaBeans![index]!.mediaType!) == MediaFileType.IMAGE_FILES
                                ? FadeInImage(
                                    image: NetworkImage(eachNews.newsMediaBeans![index]!.mediaUrl!),
                                    placeholder: const AssetImage(
                                      'assets/images/loading_grey_white.gif',
                                    ),
                                  )
                                : Image.asset(
                                    getAssetImageForFileType(
                                      getFileTypeForExtension(
                                        eachNews.newsMediaBeans![index]!.mediaType!,
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
      ),
    );
  }

  openMediaBeans(News eachNews, int index) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      eachNews.newsMediaBeans![index]!.mediaUrl!,
      (int viewId) => IFrameElement()
        ..src = eachNews.newsMediaBeans![index]!.mediaUrl!
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
                  "${eachNews.newsMediaBeans![index]!.description ?? eachNews.title}",
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
                        eachNews.newsMediaBeans![index]!.mediaUrl!,
                        filename: getCurrentTimeStringInDDMMYYYYHHMMSS() + "." + eachNews.newsMediaBeans![index]!.mediaType!,
                      );
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    child: const Icon(Icons.open_in_new),
                    onTap: () {
                      window.open(
                        eachNews.newsMediaBeans![index]!.mediaUrl!,
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
                child: getFileTypeForExtension(eachNews.newsMediaBeans![index]!.mediaType!) == MediaFileType.IMAGE_FILES
                    ? FadeInImage(
                        placeholder: const AssetImage(
                          'assets/images/loading_grey_white.gif',
                        ),
                        image: NetworkImage(eachNews.newsMediaBeans![index]!.mediaUrl!),
                        fit: BoxFit.contain,
                      )
                    : HtmlElementView(
                        viewType: eachNews.newsMediaBeans![index]!.mediaUrl!,
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
                    child: index == eachNews.newsMediaBeans!.length - 1 ? null : const Icon(Icons.arrow_right),
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
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: StudentAppDrawer(
        studentProfile: widget.studentProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : ScrollablePositionedList.builder(
              reverse: _isReverse,
              itemScrollController: _itemScrollController,
              itemCount: _noticeBoardNews.length,
              itemBuilder: (context, index) => buildEachNewsWidget(_noticeBoardNews[index]!),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isReverse = !_isReverse;
              });
            },
            child: const Icon(Icons.sort_by_alpha),
          ),
          const SizedBox(
            height: 15,
          ),
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
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
