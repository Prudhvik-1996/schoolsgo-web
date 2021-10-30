import 'dart:html';
import 'dart:ui' as ui;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/study_material/model/study_material.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentStudyMaterialScreen extends StatefulWidget {
  const StudentStudyMaterialScreen({
    Key? key,
    required this.studentProfile,
    required this.tds,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final TeacherDealingSection tds;

  @override
  _StudentStudyMaterialScreenState createState() =>
      _StudentStudyMaterialScreenState();
}

class _StudentStudyMaterialScreenState
    extends State<StudentStudyMaterialScreen> {
  bool _isLoading = true;

  List<StudyMaterial> _studyMaterial = [];

  final ItemScrollController _itemScrollController = ItemScrollController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetStudyMaterialResponse getStudyMaterialResponse =
        await getStudyMaterial(GetStudyMaterialRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
      tdsId: widget.tds.tdsId,
      subjectId: widget.tds.subjectId,
      teacherId: widget.tds.teacherId,
      studentId: widget.studentProfile.studentId,
    ));
    if (getStudyMaterialResponse.httpStatus != "OK" ||
        getStudyMaterialResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        _studyMaterial = getStudyMaterialResponse
            .assignmentsAndStudyMaterialBeans!
            .map((e) => e!)
            .toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _getDatePicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: InkWell(
        onTap: () async {
          HapticFeedback.vibrate();
          if (_studyMaterial.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Suggestions not found"),
              ),
            );
            return;
          }
          DateTime? _newDate = await showDatePicker(
            context: context,
            selectableDayPredicate: (DateTime val) {
              return _studyMaterial.map((e) => e.createTime).contains(val);
            },
            initialDate: _studyMaterial.map((e) => e.createTime).first,
            firstDate: _studyMaterial.map((e) => e.createTime).last,
            lastDate: _studyMaterial.map((e) => e.createTime).first,
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            _selectedDate = _newDate;
            _itemScrollController.scrollTo(
              index: _studyMaterial
                  .map((e) => e.createTime)
                  .toList()
                  .indexOf(_selectedDate!),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutCubic,
            );
          });
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: const Color(0xFFC9EDF8),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 50,
          height: 60,
          width: 60,
          child: const Center(
            child: Icon(
              Icons.calendar_today_rounded,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }

  openMediaBeans(StudyMaterial studyMaterial, int index) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      studyMaterial.mediaList![index]!.mediaUrl!,
      (int viewId) => IFrameElement()
        ..src = studyMaterial.mediaList![index]!.mediaUrl!
        ..allowFullscreen = false
        ..style.border = 'none'
        ..height = '500'
        ..width = '300',
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${studyMaterial.mediaList![index]!.description ?? studyMaterial.description}",
              ),
              Row(
                children: [
                  InkWell(
                    child: const Icon(Icons.download_rounded),
                    onTap: () {
                      downloadFile(
                        studyMaterial.mediaList![index]!.mediaUrl!,
                        filename: getCurrentTimeStringInDDMMYYYYHHMMSS() +
                            "." +
                            studyMaterial.mediaList![index]!.mediaType!,
                      );
                    },
                  ),
                  InkWell(
                    child: const Icon(Icons.open_in_new),
                    onTap: () {
                      window.open(
                        studyMaterial.mediaList![index]!.mediaUrl!,
                        '_blank',
                      );
                    },
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
                  openMediaBeans(studyMaterial, index - 1);
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
                child: getFileTypeForExtension(
                            studyMaterial.mediaList![index]!.mediaType!) ==
                        MediaFileType.IMAGE_FILES
                    ? FadeInImage(
                        placeholder: const AssetImage(
                          'assets/images/loading_grey_white.gif',
                        ),
                        image: NetworkImage(
                            studyMaterial.mediaList![index]!.mediaUrl!),
                        fit: BoxFit.contain,
                      )
                    : HtmlElementView(
                        viewType: studyMaterial.mediaList![index]!.mediaUrl!,
                      ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  openMediaBeans(studyMaterial, index + 1);
                },
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: index == studyMaterial.mediaList!.length - 1
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

  Widget _getStudyMaterialWidget(StudyMaterial studyMaterial) {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20,
              MediaQuery.of(context).size.width / 4, 20)
          : const EdgeInsets.all(20),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: ClayContainer(
                  depth: 40,
                  surfaceColor: clayContainerColor(context),
                  parentColor: clayContainerColor(context),
                  spread: 1,
                  borderRadius: 10,
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: FittedBox(
                                  alignment: Alignment.topLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    studyMaterial.studyMaterialType!
                                        .toUpperCase()
                                        .replaceAll("_", " "),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (studyMaterial.studyMaterialType! ==
                                "ASSIGNMENT")
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Due date: ${studyMaterial.dueDate == null ? "-" : convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(studyMaterial.dueDate!))}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                studyMaterial.description!.capitalize(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (studyMaterial.mediaList!.isNotEmpty)
                Container(
                  // height: 150,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemCount: studyMaterial.mediaList!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          openMediaBeans(studyMaterial, index);
                        },
                        child: Container(
                          color: Colors.transparent,
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.all(2),
                          child: getFileTypeForExtension(studyMaterial
                                      .mediaList![index]!.mediaType!) ==
                                  MediaFileType.IMAGE_FILES
                              ? FadeInImage(
                                  image: NetworkImage(studyMaterial
                                      .mediaList![index]!.mediaUrl!),
                                  placeholder: const AssetImage(
                                    'assets/images/loading_grey_white.gif',
                                  ),
                                )
                              : Image.asset(
                                  getAssetImageForFileType(
                                    getFileTypeForExtension(
                                      studyMaterial
                                          .mediaList![index]!.mediaType!,
                                    ),
                                  ),
                                  scale: 0.5,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Created Date: ${convertDateTimeToDDMMYYYYFormat(studyMaterial.createTime)}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Material"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.studentProfile,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : CustomScrollView(
              physics: const ClampingScrollPhysics(),
              // controller: controller,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 150.0,
                                minHeight: 150.0,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildTdsDetailWidget(
                                    context,
                                    widget.tds.sectionName!.capitalize(),
                                  ),
                                  buildTdsDetailWidget(
                                    context,
                                    widget.tds.subjectName!.capitalize(),
                                  ),
                                  buildTdsDetailWidget(
                                    context,
                                    widget.tds.teacherName!.capitalize(),
                                  ),
                                ],
                              ),
                            )
                          : ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 50.0,
                                minHeight: 50.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: buildTdsDetailWidget(
                                      context,
                                      widget.tds.sectionName!.capitalize(),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTdsDetailWidget(
                                      context,
                                      widget.tds.subjectName!.capitalize(),
                                    ),
                                  ),
                                  Expanded(
                                    child: buildTdsDetailWidget(
                                      context,
                                      widget.tds.teacherName!.capitalize(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  fillOverscroll: true,
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemCount: _studyMaterial.length,
                    itemBuilder: (context, index) =>
                        _getStudyMaterialWidget(_studyMaterial[index]),
                  ),
                ),
              ],
            ),
      floatingActionButton: _isLoading ? null : _getDatePicker(),
    );
  }

  Container buildTdsDetailWidget(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }
}
