import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:schoolsgo_web/src/circulars/modal/circular_type.dart';
import 'package:schoolsgo_web/src/circulars/modal/circulars.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminCircularsScreen extends StatefulWidget {
  const AdminCircularsScreen({Key? key, required this.adminProfile}) : super(key: key);

  final AdminProfile adminProfile;

  static const routeName = "/circulars";

  @override
  State<AdminCircularsScreen> createState() => _AdminCircularsScreenState();
}

class _AdminCircularsScreenState extends State<AdminCircularsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  String? _uploadingFile;
  double? _fileUploadProgress;

  List<CircularBean> circulars = [];
  final ItemScrollController _itemScrollController = ItemScrollController();

  late CircularBean newCircular;
  bool isAddNew = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isAddNew = false;
      _isLoading = true;
      newCircular = CircularBean(
        franchiseId: widget.adminProfile.franchiseId,
        franchiseName: widget.adminProfile.franchiseName,
        schoolId: widget.adminProfile.schoolId,
        schoolName: widget.adminProfile.schoolName,
        status: "active",
        circularMediaBeans: [],
        agentId: widget.adminProfile.userId,
        circularType: "A",
      )..isEditMode = true;
      newCircular.origJson = newCircular.toJson();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedAcademicYearId = prefs.getInt('SELECTED_ACADEMIC_YEAR_ID');

    GetCircularsResponse getCircularsResponse = await getCirculars(GetCircularsRequest(
      schoolId: widget.adminProfile.schoolId,
      franchiseId: widget.adminProfile.franchiseId,
      role: "A",
      academicYearId: selectedAcademicYearId,
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
          : _uploadingFile != null
              ? Column(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Center(
                        child: Text("Uploading files"),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        'assets/images/eis_loader.gif',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text("Uploading file $_uploadingFile"),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: LinearPercentIndicator(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          alignment: MainAxisAlignment.center,
                          width: 140.0,
                          lineHeight: 14.0,
                          percent: (_fileUploadProgress ?? 0) / 100,
                          center: Text(
                            "${(_fileUploadProgress ?? 0).toStringAsFixed(2)} %",
                            style: const TextStyle(fontSize: 12.0),
                          ),
                          leading: const Icon(Icons.file_upload),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                        ),
                      ),
                    )
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        itemCount: (isAddNew ? [newCircular] : circulars).where((e) => e.status == "active").toList().length,
                        itemBuilder: (context, index) => Container(
                          margin: MediaQuery.of(context).orientation == Orientation.landscape
                              ? EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 4, 20, MediaQuery.of(context).size.width / 4, 20)
                              : const EdgeInsets.all(20),
                          child: (isAddNew ? [newCircular] : circulars).where((e) => e.status == "active").toList()[index].isEditMode
                              ? _buildCircularsWidgetForEditMode(
                                  (isAddNew ? [newCircular] : circulars).where((e) => e.status == "active").toList()[index],
                                )
                              : _buildCircularsWidgetForReadMode(
                                  (isAddNew ? [newCircular] : circulars).where((e) => e.status == "active").toList()[index],
                                  canEdit: (isAddNew ? [newCircular] : circulars).where((e) => e.status == "active").toList()[index].schoolId != null,
                                ),
                        ),
                      ),
                    )
                  ],
                ),
      floatingActionButton: buildEditButton(context),
    );
  }

  Widget buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isAddNew = !isAddNew;
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
        child: isAddNew
            ? ClayButton(
                color: clayContainerColor(context),
                height: 50,
                width: 50,
                borderRadius: 100,
                spread: 4,
                child: const Icon(
                  Icons.close,
                ),
              )
            : ClayButton(
                color: clayContainerColor(context),
                height: 50,
                width: 50,
                borderRadius: 100,
                spread: 4,
                child: const Icon(
                  Icons.add,
                ),
              ),
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
                        textAlign: TextAlign.start,
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
                                  ? MediaLoadingWidget(
                                      mediaUrl: circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
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

  Future<void> _saveChanges(CircularBean circular) async {
    await showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext dialogueContext) {
        return AlertDialog(
          title: Text(circular.status == "active" ? 'Are you sure you want to save changes?' : 'Are you sure you want to delete circular?'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width * 0.75,
            child: SingleChildScrollView(
              child: _buildCircularsWidgetForReadMode(circular, canEdit: false),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                if (!const DeepCollectionEquality().equals(circular.toJson(), circular.origJson)) {
                  setState(() {
                    _isLoading = true;
                  });
                  CreateOrUpdateCircularResponse createOrUpdateCircularResponse = await createOrUpdateCircular(CreateOrUpdateCircularRequest()
                    ..agentId = widget.adminProfile.userId
                    ..circularId = circular.circularId
                    ..circularMediaBeans =
                        circular.circularMediaBeans?.where((e) => !const DeepCollectionEquality().equals(e?.toJson(), e?.origJson())).toList()
                    ..circularType = circular.circularType
                    ..createTime = circular.createTime
                    ..description = circular.description
                    ..franchiseId = circular.franchiseId
                    ..franchiseName = circular.franchiseName
                    ..schoolId = circular.schoolId
                    ..schoolName = circular.schoolName
                    ..status = circular.status
                    ..title = circular.title);
                  setState(() {
                    _isLoading = false;
                  });
                  if (createOrUpdateCircularResponse.httpStatus != "OK" || createOrUpdateCircularResponse.responseStatus != "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Something went wrong! Try again later.."),
                      ),
                    );
                    return;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Changes updated successfully.."),
                      ),
                    );
                    setState(() {
                      circular.circularId = createOrUpdateCircularResponse.circularId;
                    });
                  }
                }
                setState(() {
                  circular.isEditMode = false;
                });
                _loadData();
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () async {
                debugPrint("481: ${circular.toJson()}");
                debugPrint("482: ${CircularBean.fromJson(circular.origJson).toJson()}");
                setState(() {
                  circular
                    ..agentId = CircularBean.fromJson(circular.origJson).agentId
                    ..circularId = CircularBean.fromJson(circular.origJson).circularId
                    ..circularMediaBeans = CircularBean.fromJson(circular.origJson).circularMediaBeans
                    ..circularType = CircularBean.fromJson(circular.origJson).circularType
                    ..createTime = CircularBean.fromJson(circular.origJson).createTime
                    ..description = CircularBean.fromJson(circular.origJson).description
                    ..franchiseId = CircularBean.fromJson(circular.origJson).franchiseId
                    ..franchiseName = CircularBean.fromJson(circular.origJson).franchiseName
                    ..schoolId = CircularBean.fromJson(circular.origJson).schoolId
                    ..schoolName = CircularBean.fromJson(circular.origJson).schoolName
                    ..status = CircularBean.fromJson(circular.origJson).status
                    ..title = CircularBean.fromJson(circular.origJson).title;
                  circular.isEditMode = false;
                });
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () async {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircularsWidgetForEditMode(
    CircularBean circular,
  ) {
    return Stack(
      children: [
        ClayContainer(
          depth: 20,
          color: clayContainerColor(context),
          spread: 5,
          borderRadius: 10,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: "Title",
                            ),
                            maxLines: null,
                            initialValue: circular.title ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.start,
                            onChanged: (text) => setState(() {
                              circular.title = text;
                            }),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (!circular.isEditMode)
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
                        if (circular.isEditMode && !isAddNew)
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                circular.status = "inactive";
                              });
                              await _saveChanges(circular);
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        const SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            _saveChanges(circular);
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
                                Icons.check,
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
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Content",
                        ),
                        maxLines: null,
                        initialValue: circular.description ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.start,
                        onChanged: (text) => setState(() {
                          circular.description = text;
                        }),
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
                  itemCount: circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList().length + 1,
                  itemBuilder: (context, index) {
                    if (index == circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList().length) {
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
                                      _uploadingFile = file.name;
                                      _fileUploadProgress = ((files.indexOf(file) / files.length) + (1 / (2 * files.length))) * 100.0;
                                    });

                                    try {
                                      UploadFileToDriveResponse uploadFileResponse = await uploadFileToDrive(reader.result!, file.name);

                                      CircularMediaBean circularMediaBean = CircularMediaBean();
                                      circularMediaBean.circularId = circular.circularId;
                                      circularMediaBean.status = "active";
                                      circularMediaBean.mediaType = uploadFileResponse.mediaBean!.mediaType;
                                      circularMediaBean.mediaUrl = uploadFileResponse.mediaBean!.mediaUrl;
                                      circularMediaBean.mediaId = uploadFileResponse.mediaBean!.mediaId;

                                      if (circular.circularMediaBeans == null && circular.circularMediaBeans!.isEmpty) {
                                        setState(() {
                                          circular.circularMediaBeans = [];
                                        });
                                      }
                                      setState(() {
                                        circular.circularMediaBeans!.add(circularMediaBean);
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
                                        ),
                                      );
                                    }

                                    setState(() {
                                      _uploadingFile = null;
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
                    return Stack(
                      children: [
                        InkWell(
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
                                ? MediaLoadingWidget(
                                    mediaUrl: circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.mediaUrl!,
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
                        ),
                        if (circular.isEditMode)
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  circular.circularMediaBeans!.where((i) => i!.status != 'inactive').toList()[index]!.status = "inactive";
                                });
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                        const SizedBox(
                          height: 50,
                          width: 150,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Circular to be sent to:",
                            ),
                          ),
                        ),
                      ] +
                      ["Admins", "Teachers", "Non-teaching staff", "Drivers"]
                          .map((e) => Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: checkValueForCircular(e, circular),
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        changeCircularType(circular, newValue ?? false, e);
                                      });
                                    },
                                  ),
                                  getRoleWidget(e),
                                ],
                              ))
                          .toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _saveChanges(circular);
                      },
                      child: ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 10,
                        child: Container(margin: const EdgeInsets.all(8.0), child: const Text("Submit")),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                    ? MediaLoadingWidget(
                        mediaUrl: circular.circularMediaBeans![index]!.mediaUrl!,
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
