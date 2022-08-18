import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/fancy_fab.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/study_material/model/study_material.dart';
import 'package:schoolsgo_web/src/time_table/modal/teacher_dealing_sections.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AdminStudyMaterialScreen extends StatefulWidget {
  const AdminStudyMaterialScreen({
    Key? key,
    required this.adminProfile,
    required this.tds,
  }) : super(key: key);

  final AdminProfile adminProfile;
  final TeacherDealingSection tds;

  @override
  _AdminStudyMaterialScreenState createState() => _AdminStudyMaterialScreenState();
}

class _AdminStudyMaterialScreenState extends State<AdminStudyMaterialScreen> {
  bool _isLoading = true;

  List<StudyMaterial> _studyMaterial = [];

  final ItemScrollController _itemScrollController = ItemScrollController();

  DateTime? _selectedDate;

  bool _isAddNew = false;
  late StudyMaterial _newStudyMaterial;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isAddNew = false;
      _newStudyMaterial = StudyMaterial(
        teacherId: widget.tds.teacherId,
        subjectId: widget.tds.subjectId,
        sectionId: widget.tds.sectionId,
        tdsId: widget.tds.tdsId,
        sectionName: widget.tds.sectionName,
        agentId: widget.adminProfile.userId.toString(),
        status: "active",
        teacherName: widget.tds.teacherName,
        subjectName: widget.tds.subjectName,
        mediaList: [],
        studyMaterialType: "STUDY_MATERIAL",
        description: "",
      );
    });

    GetStudyMaterialResponse getStudyMaterialResponse = await getStudyMaterial(GetStudyMaterialRequest(
      schoolId: widget.adminProfile.schoolId,
      tdsId: widget.tds.tdsId,
      subjectId: widget.tds.subjectId,
      teacherId: widget.tds.teacherId,
    ));
    if (getStudyMaterialResponse.httpStatus != "OK" || getStudyMaterialResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        _studyMaterial = getStudyMaterialResponse.assignmentsAndStudyMaterialBeans!.map((e) => e!).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  FloatingActionButton _getDatePicker() {
    return FloatingActionButton(
      onPressed: () async {
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
            index: _studyMaterial.map((e) => e.createTime).toList().indexOf(_selectedDate!),
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOutCubic,
          );
        });
      },
      child: const Icon(
        Icons.calendar_today_rounded,
      ),
    );
  }

  Widget _getDatePickerForAssignment(StudyMaterial studyMaterial) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: InkWell(
        onTap: () async {
          HapticFeedback.vibrate();
          DateTime? _newDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 364)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            helpText: "Select a date",
          );
          if (_newDate == null) return;
          setState(() {
            studyMaterial.dueDate = _newDate.millisecondsSinceEpoch + 5 * 3600 + 30 * 60;
          });
        },
        child: ClayButton(
          depth: 40,
          color: clayContainerColor(context),
          spread: 2,
          borderRadius: 30,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                  ),
                  if (studyMaterial.dueDate != null)
                    const SizedBox(
                      width: 15,
                    ),
                  if (studyMaterial.dueDate != null)
                    Text(
                      convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(studyMaterial.dueDate!)),
                    ),
                ],
              ),
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
      (int viewId) => html.IFrameElement()
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
              Row(
                children: [
                  InkWell(
                    child: const Icon(Icons.download_rounded),
                    onTap: () {
                      downloadFile(
                        studyMaterial.mediaList![index]!.mediaUrl!,
                        filename: getCurrentTimeStringInDDMMYYYYHHMMSS() + "." + studyMaterial.mediaList![index]!.mediaType!,
                      );
                    },
                  ),
                  InkWell(
                    child: const Icon(Icons.open_in_new),
                    onTap: () {
                      html.window.open(
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
                child: getFileTypeForExtension(studyMaterial.mediaList![index]!.mediaType!) == MediaFileType.IMAGE_FILES
                    ? MediaLoadingWidget(
                        mediaUrl: studyMaterial.mediaList![index]!.mediaUrl!,
                        mediaFit: BoxFit.contain,
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
                    child: index == studyMaterial.mediaList!.length - 1 ? null : const Icon(Icons.arrow_right),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getDropDownForStudyMaterialType(StudyMaterial studyMaterial) {
    return DropdownButton(
      underline: Container(),
      items: ["ASSIGNMENT", "STUDY_MATERIAL", "QUESTION_PAPER"]
          .map(
            (e) => DropdownMenuItem(
              child: Text(
                e.replaceAll("_", " "),
              ),
              value: e.replaceAll("_", " "),
            ),
          )
          .toList(),
      value: studyMaterial.studyMaterialType!.replaceAll("_", " "),
      onChanged: (String? newValue) {
        if (newValue == null) return;
        setState(() {
          studyMaterial.studyMaterialType = newValue;
        });
      },
    );
  }

  Future<void> _saveChanges(StudyMaterial studyMaterial) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure you want to proceed"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                setState(() {
                  _isLoading = true;
                });

                CreateOrUpdateStudyMaterialRequest createOrUpdateStudyMaterialRequest = CreateOrUpdateStudyMaterialRequest(
                  description: studyMaterial.description,
                  studyMaterialType: studyMaterial.studyMaterialType,
                  status: studyMaterial.status,
                  agentId: widget.adminProfile.userId,
                  tdsId: widget.tds.tdsId,
                  schoolId: widget.adminProfile.schoolId,
                  assignmentsAndStudyMaterialId: studyMaterial.assignmentAndStudyMaterialId,
                  dueDate: studyMaterial.dueDate,
                );

                CreateOrUpdateStudyMaterialResponse createOrUpdateStudyMaterialResponse =
                    await createOrUpdateStudyMaterial(createOrUpdateStudyMaterialRequest);

                if (createOrUpdateStudyMaterialResponse.httpStatus != "OK" || createOrUpdateStudyMaterialResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                  _loadData();
                  return;
                }

                studyMaterial.mediaList!.map((e) => e!).forEach((e) {
                  setState(() {
                    e.assignmentAndStudyMaterialId = createOrUpdateStudyMaterialResponse.assignmentAndStudyMaterialId;
                  });
                });

                CreateOrUpdateStudyMaterialMediaMapResponse createOrUpdateStudyMaterialMediaMapResponse =
                    await createOrUpdateStudyMaterialMediaMap(CreateOrUpdateStudyMaterialMediaMapRequest(
                  schoolId: widget.adminProfile.schoolId,
                  agentId: widget.adminProfile.userId,
                  mediaList:
                      studyMaterial.mediaList!.map((e) => e!).where((e) => !const DeepCollectionEquality().equals(e.toJson(), e.origJson())).toList(),
                ));

                if (createOrUpdateStudyMaterialMediaMapResponse.httpStatus != "OK" ||
                    createOrUpdateStudyMaterialMediaMapResponse.responseStatus != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Try again later.."),
                    ),
                  );
                  _loadData();
                  return;
                }

                _loadData();
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text("Submit"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (studyMaterial.status == "inactive") {
                  setState(() {
                    studyMaterial.status = "active";
                    studyMaterial.status = "active";
                  });
                }
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _getStudyMaterialEditWidget(StudyMaterial studyMaterial) {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (studyMaterial.assignmentAndStudyMaterialId != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.vibrate();
                          setState(() {
                            studyMaterial.status = "inactive";
                          });
                          _saveChanges(studyMaterial);
                        },
                        child: ClayButton(
                          depth: 40,
                          color: clayContainerColor(context),
                          spread: 2,
                          borderRadius: 50,
                          height: 30,
                          width: 30,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                    child: InkWell(
                      onTap: () async {
                        HapticFeedback.vibrate();
                        if (!const DeepCollectionEquality().equals(studyMaterial.toJson(), studyMaterial.origJson())) {
                          if ((studyMaterial.description ?? "").trim() != "") {
                            _saveChanges(studyMaterial);
                          }
                        } else {
                          setState(() {
                            studyMaterial.isEditMode = false;
                          });
                        }
                      },
                      child: ClayButton(
                        depth: 40,
                        color: clayContainerColor(context),
                        spread: 2,
                        borderRadius: 50,
                        height: 30,
                        width: 30,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              Icons.check,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.topLeft,
                      fit: BoxFit.scaleDown,
                      child: _getDropDownForStudyMaterialType(studyMaterial),
                    ),
                  ),
                  if (studyMaterial.studyMaterialType! == "ASSIGNMENT") _getDatePickerForAssignment(studyMaterial)
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Description",
                        ),
                        maxLines: null,
                        initialValue: studyMaterial.description ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify,
                        onChanged: (text) => setState(() {
                          studyMaterial.description = text;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
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
                  itemCount: studyMaterial.mediaList!.where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive').toList().length + 1,
                  itemBuilder: (context, index) {
                    if (index == studyMaterial.mediaList!.where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive').toList().length) {
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

                                      StudyMaterialMedia studyMaterialMediaBean = StudyMaterialMedia();
                                      studyMaterialMediaBean.assignmentAndStudyMaterialId = studyMaterial.assignmentAndStudyMaterialId;
                                      studyMaterialMediaBean.status = "active";
                                      studyMaterialMediaBean.mediaType = uploadFileResponse.mediaBean!.mediaType;
                                      studyMaterialMediaBean.mediaUrl = uploadFileResponse.mediaBean!.mediaUrl;
                                      studyMaterialMediaBean.mediaId = uploadFileResponse.mediaBean!.mediaId;
                                      studyMaterialMediaBean.assignmentAndStudyMaterialMediaStatus = "active";

                                      if (studyMaterial.mediaList == null && studyMaterial.mediaList!.isEmpty) {
                                        setState(() {
                                          studyMaterial.mediaList = [];
                                        });
                                      }
                                      setState(() {
                                        studyMaterial.mediaList!.add(studyMaterialMediaBean);
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
                        openMediaBeans(studyMaterial, index);
                      },
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.transparent,
                            height: 100,
                            width: 100,
                            padding: const EdgeInsets.all(2),
                            child: getFileTypeForExtension(studyMaterial.mediaList!
                                        .where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive')
                                        .toList()[index]!
                                        .mediaType!) ==
                                    MediaFileType.IMAGE_FILES
                                ? MediaLoadingWidget(
                                    mediaUrl: studyMaterial.mediaList!
                                        .where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive')
                                        .toList()[index]!
                                        .mediaUrl!,
                                  )
                                : Image.asset(
                                    getAssetImageForFileType(
                                      getFileTypeForExtension(
                                        studyMaterial.mediaList!
                                            .where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive')
                                            .toList()[index]!
                                            .mediaType!,
                                      ),
                                    ),
                                    scale: 0.5,
                                  ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (studyMaterial.mediaList!
                                          .where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive')
                                          .toList()[index]!
                                          .assignmentAndStudyMaterialMediaStatus ==
                                      "active") {
                                    studyMaterial.mediaList!
                                        .where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive')
                                        .toList()[index]!
                                        .assignmentAndStudyMaterialMediaStatus = "inactive";
                                  } else {
                                    studyMaterial.mediaList!
                                        .where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive')
                                        .toList()[index]!
                                        .assignmentAndStudyMaterialMediaStatus = "active";
                                  }
                                });
                              },
                              child: studyMaterial.mediaList!
                                          .where((i) => i!.assignmentAndStudyMaterialMediaStatus != 'inactive')
                                          .toList()[index]!
                                          .assignmentAndStudyMaterialMediaStatus ==
                                      "active"
                                  ? const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStudyMaterialWidget(StudyMaterial studyMaterial) {
    return Container(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
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
                                    studyMaterial.studyMaterialType!.toUpperCase().replaceAll("_", " "),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (studyMaterial.studyMaterialType! == "ASSIGNMENT")
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Due date: ${studyMaterial.dueDate == null ? "-" : convertDateTimeToDDMMYYYYFormat(DateTime.fromMillisecondsSinceEpoch(studyMaterial.dueDate!))}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: InkWell(
                                onTap: () async {
                                  HapticFeedback.vibrate();
                                  if (_studyMaterial.map((e) => e.isEditMode).contains(true)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Cannot edit more than one material at the same time..",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    studyMaterial.isEditMode = true;
                                  });
                                },
                                child: ClayButton(
                                  depth: 40,
                                  color: clayContainerColor(context),
                                  spread: 2,
                                  borderRadius: 50,
                                  height: 30,
                                  width: 30,
                                  child: Container(
                                    margin: const EdgeInsets.all(8),
                                    child: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Icon(
                                        Icons.edit,
                                      ),
                                    ),
                                  ),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: getFileTypeForExtension(studyMaterial.mediaList![index]!.mediaType!) == MediaFileType.IMAGE_FILES
                              ? MediaLoadingWidget(
                                  mediaUrl: studyMaterial.mediaList![index]!.mediaUrl!,
                                )
                              : Image.asset(
                                  getAssetImageForFileType(
                                    getFileTypeForExtension(
                                      studyMaterial.mediaList![index]!.mediaType!,
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

  _performMoreActions(String choice) {
    if (choice == "add_new") {
      setState(() {
        _isAddNew = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Material"),
        actions: [
          buildRoleButtonForAppBar(
            context,
            widget.adminProfile,
          ),
          if (!_isAddNew)
            PopupMenuButton<String>(
              onSelected: _performMoreActions,
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<String>(
                    value: "add_new",
                    child: Text("Add New"),
                  ),
                ];
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : _isAddNew
              ? ListView(
                  children: [
                    _getStudyMaterialEditWidget(_newStudyMaterial),
                  ],
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
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    _studyMaterial.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text("Seems like there are entries yet.."),
                            ),
                          )
                        : SliverFillRemaining(
                            hasScrollBody: true,
                            fillOverscroll: true,
                            child: ScrollablePositionedList.builder(
                              itemScrollController: _itemScrollController,
                              itemCount: _studyMaterial.length,
                              itemBuilder: (context, index) => _studyMaterial[index].isEditMode && !widget.adminProfile.isMegaAdmin
                                  ? _getStudyMaterialEditWidget(_studyMaterial[index])
                                  : _getStudyMaterialWidget(_studyMaterial[index]),
                            ),
                          ),
                  ],
                ),
      // floatingActionButton: _isLoading
      //     ? null
      //     : _isAddNew
      //         ? FloatingActionButton(
      //             onPressed: () {
      //               setState(() {
      //                 _isAddNew = false;
      //               });
      //             },
      //             child: const Icon(Icons.close),
      //             tooltip: "Close",
      //           )
      //         : _getDatePicker(),
      floatingActionButton: widget.adminProfile.isMegaAdmin
          ? Container()
          : _isAddNew
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isAddNew = !_isAddNew;
                    });
                  },
                  child: _isAddNew ? const Icon(Icons.close) : const Icon(Icons.add),
                  tooltip: "Close",
                )
              : ExpandableFab(
                  axis: Axis.vertical,
                  tooltip: "More Options",
                  expandedWidgets: [
                    _getDatePicker(),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _isAddNew = !_isAddNew;
                        });
                      },
                      child: _isAddNew ? const Icon(Icons.close) : const Icon(Icons.add),
                      tooltip: "Close",
                    ),
                  ],
                ),
      // floatingActionButtonLocation:
      //     MediaQuery.of(context).orientation == Orientation.landscape
      //         ? FloatingActionButtonLocation.endTop
      //         : FloatingActionButtonLocation.endFloat,
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
