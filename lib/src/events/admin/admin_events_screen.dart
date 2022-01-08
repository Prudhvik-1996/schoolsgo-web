import 'dart:html';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';

import '../model/events.dart';
import 'admin_each_event_screen.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({
    Key? key,
    required this.adminProfile,
  }) : super(key: key);

  final AdminProfile adminProfile;
  static const routeName = "/events";

  @override
  _AdminEventsScreenState createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  bool _isLoading = true;
  List<Event> events = [];

  bool isPreviewMode = true;

  Event newEvent = Event();
  bool isNewEvent = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadNewEvent() async {
    setState(() {
      _isLoading = true;
      isNewEvent = false;
      newEvent = Event(
        agent: widget.adminProfile.userId.toString(),
        schoolId: widget.adminProfile.schoolId,
        status: "active",
        description: "",
        coverPhotoUrl:
            "https://drive.google.com/uc?id=1tSVOeWmbXL2SGJFG7iPl63kDLcOOu6w5",
        coverPhotoUrlId: 550,
        eventName: "",
        eventType: "",
        organisedBy: "",
        eventDate: convertDateTimeToYYYYMMDDFormat(DateTime.now()),
      );
      newEvent.isEditMode = true;
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      isPreviewMode = true;
    });
    _loadNewEvent();
    GetEventsResponse getEventsResponse = await getEvents(GetEventsRequest(
      schoolId: widget.adminProfile.schoolId,
    ));
    if (getEventsResponse.httpStatus == 'OK' &&
        getEventsResponse.responseStatus == 'success') {
      setState(() {
        events = getEventsResponse.events!.map((e) => e!).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height / 2.5,
            child: Center(
              child: MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: buildEventCover(event),
                        ),
                        Expanded(
                          flex: 2,
                          child: buildEventDetails(event),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: buildEventCover(event),
                        ),
                        Expanded(
                          flex: 2,
                          child: buildEventDetails(event),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Container buildEventDetails(Event event) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ListView(
        children: eventDetailsChildren(event),
      ),
    );
  }

  List<Widget> eventDetailsChildren(Event event) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              "Event Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 10
                        : 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              event.eventName!,
              style: TextStyle(
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 10
                        : 18,
              ),
            ),
          ),
        ],
      ),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              "Event Date",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 10
                        : 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              event.eventDate!,
              style: TextStyle(
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 10
                        : 18,
              ),
            ),
          ),
        ],
      ),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 10
                        : 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              event.description!,
              style: TextStyle(
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 10
                        : 18,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  openMediaFromUrl(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                child: const Icon(Icons.download_rounded),
                onTap: () {
                  downloadFile(
                    event.coverPhotoUrl!,
                    filename: getCurrentTimeStringInDDMMYYYYHHMMSS() + ".jpg",
                  );
                },
              ),
              InkWell(
                child: const Icon(Icons.open_in_new),
                onTap: () {
                  window.open(
                    event.coverPhotoUrl!,
                    '_blank',
                  );
                },
              ),
            ],
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height /
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 10
                    : 2.5),
            width: MediaQuery.of(context).size.height /
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 2.5
                    : 10),
            child: FadeInImage(
              placeholder: const AssetImage(
                'assets/images/loading_grey_white.gif',
              ),
              image: NetworkImage(event.coverPhotoUrl!),
              fit: BoxFit.scaleDown,
            ),
          ),
        );
      },
    );
  }

  Widget buildEventCover(Event event) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width / 1.5
          : MediaQuery.of(context).size.width / 4,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height / 1.5
          : MediaQuery.of(context).size.height / 8,
      child: FittedBox(
        fit: BoxFit.cover,
        child: InkWell(
          onTap: () {
            openMediaFromUrl(event);
          },
          child: Container(
            height: MediaQuery.of(context).size.height /
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 10
                    : 2.5),
            width: MediaQuery.of(context).size.height /
                (MediaQuery.of(context).orientation == Orientation.portrait
                    ? 2.5
                    : 10),
            child: FadeInImage(
              placeholder: const AssetImage(
                'assets/images/loading_grey_white.gif',
              ),
              image: NetworkImage(event.coverPhotoUrl!),
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEventWidget(Event event) {
    String coverPhotoUrl = event.coverPhotoUrl!;
    return Container(
      margin: const EdgeInsets.all(15),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AdminEachEventScreen.routeName,
            arguments: [widget.adminProfile, event],
          );
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(1),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(coverPhotoUrl),
                      fit: BoxFit.contain,
                    ),
                    color: Colors.transparent,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (event.eventName ?? "-"),
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showEventDetails(event);
                        },
                        child: const Icon(
                          Icons.info_outline,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _performMoreActions(String choice) {
    print("Choice: $choice");
    if (choice == "enable_edit_mode") {
      setState(() {
        isPreviewMode = false;
      });
    } else if (choice == "enable_preview_mode") {
      setState(() {
        isPreviewMode = true;
      });
    }
  }

  Widget buildNewEventDatePicker(Event event) {
    return InkWell(
      child: const Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? _newDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(event.eventDate!),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          helpText: "Select a date",
        );
        if (_newDate != null) {
          setState(() {
            event.eventDate = convertDateTimeToYYYYMMDDFormat(_newDate);
          });
        }
      },
    );
  }

  List<Widget> editableEventDetailsChildren(Event event) {
    return [
      TextFormField(
        decoration: const InputDecoration(
          hintText: "Event Name",
        ),
        maxLines: 1,
        initialValue: event.eventName ?? "",
        style: const TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.justify,
        onChanged: (text) => setState(() {
          event.eventName = text;
        }),
      ),
      const SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(event.eventDate!),
          buildNewEventDatePicker(event),
        ],
      ),
      const Divider(
        thickness: 1,
        color: Colors.grey,
      ),
      TextFormField(
        decoration: const InputDecoration(
          hintText: "Description",
        ),
        maxLines: null,
        initialValue: event.description ?? "",
        style: const TextStyle(
          fontSize: 16,
        ),
        textAlign: TextAlign.justify,
        onChanged: (text) => setState(() {
          event.description = text;
        }),
      ),
    ];
  }

  Future<void> saveChanges(Event event) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: buildEditableEventWidget(
            event,
            isPreview: true,
            isLandscape:
                MediaQuery.of(context).orientation == Orientation.landscape,
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
                  child: Text(
                    event.status == "inactive" ? "Confirm" : "Submit",
                  ),
                ),
                onTap: () async {
                  if (Event.fromJson(event.origJson()) == event) {
                    setState(() {
                      event.isEditMode = false;
                    });
                    Navigator.pop(context);
                    return;
                  }
                  setState(() {
                    _isLoading = true;
                  });
                  event.agent = widget.adminProfile.userId.toString();
                  event.eventDate = DateTime.parse(event.eventDate!)
                      .millisecondsSinceEpoch
                      .toString();
                  CreateOrUpdateEventsRequest request =
                      CreateOrUpdateEventsRequest(
                    schoolId: widget.adminProfile.schoolId,
                    agent: widget.adminProfile.userId.toString(),
                    eventBeans: [event],
                  );
                  CreateOrUpdateEventsResponse response =
                      await createOrUpdateEvents(request);
                  if (response.httpStatus != 'OK' ||
                      response.responseStatus != 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Something went wrong while trying to execute your request..\nPlease try again later"),
                      ),
                    );
                  }
                  setState(() {
                    _isLoading = false;
                  });
                  _loadData();
                  Navigator.pop(context);
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

  Widget buildEditableEventWidget(Event event,
      {bool isPreview = false, bool isLandscape = true}) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 1,
        borderRadius: 10,
        child: Container(
          margin: const EdgeInsets.all(15),
          child: isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: event.isEditMode && !isPreview
                          ? Container(
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: InkWell(
                                onTap: () {
                                  FileUploadInputElement uploadInput =
                                      FileUploadInputElement();
                                  uploadInput.multiple = false;
                                  uploadInput.draggable = true;
                                  uploadInput.accept =
                                      '.png,.jpg,.jpeg,.PNG,.JPG,.JPEG';
                                  uploadInput.click();
                                  uploadInput.onChange.listen(
                                    (changeEvent) {
                                      final files = uploadInput.files!;
                                      for (File file in files) {
                                        final reader = FileReader();
                                        reader.readAsDataUrl(file);
                                        reader.onLoadEnd.listen(
                                          (loadEndEvent) async {
                                            // _file = file;
                                            print(
                                                "File uploaded: " + file.name);
                                            setState(() {
                                              _isLoading = true;
                                            });

                                            try {
                                              UploadFileToDriveResponse
                                                  uploadFileResponse =
                                                  await uploadFileToDrive(
                                                      reader.result!,
                                                      file.name);

                                              event.coverPhotoUrl =
                                                  uploadFileResponse
                                                      .mediaBean!.mediaUrl;
                                              event.coverPhotoUrlId =
                                                  uploadFileResponse
                                                      .mediaBean!.mediaId;
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
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
                                child: Container(
                                  height: MediaQuery.of(context).size.height /
                                      (MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? 10
                                          : 2.5),
                                  width: MediaQuery.of(context).size.height /
                                      (MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? 2.5
                                          : 10),
                                  child: FadeInImage(
                                    placeholder: const AssetImage(
                                      'assets/images/loading_grey_white.gif',
                                    ),
                                    image: NetworkImage(event.coverPhotoUrl!),
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height /
                                  (MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? 10
                                      : 2.5),
                              width: MediaQuery.of(context).size.height /
                                  (MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? 2.5
                                      : 10),
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: FadeInImage(
                                placeholder: const AssetImage(
                                  'assets/images/loading_grey_white.gif',
                                ),
                                image: NetworkImage(event.coverPhotoUrl!),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Column(
                          children: event.isEditMode && !isPreview
                              ? editableEventDetailsChildren(event)
                              : eventDetailsChildren(event),
                        ),
                      ),
                    ),
                    if (!isPreview && event.isEditMode && event.eventId != null)
                      ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 10,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (event.status == "active") {
                                event.status = "inactive";
                              } else {
                                event.status = "active";
                              }
                            });
                            if (event.isEditMode) {
                              saveChanges(event);
                            }
                            setState(() {
                              event.isEditMode = !event.isEditMode;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: (event.status ?? "inactive") == "active"
                                ? const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                  ),
                          ),
                        ),
                      ),
                    if (!isPreview && event.isEditMode)
                      const SizedBox(
                        width: 5,
                      ),
                    if (!isPreview)
                      ClayButton(
                        depth: 40,
                        surfaceColor: clayContainerColor(context),
                        parentColor: clayContainerColor(context),
                        spread: 1,
                        borderRadius: 10,
                        child: InkWell(
                          onTap: () {
                            if (event.isEditMode) {
                              saveChanges(event);
                            } else {
                              if (events.where((e) => e.isEditMode).isEmpty) {
                                setState(() {
                                  event.isEditMode = !event.isEditMode;
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              event.isEditMode ? Icons.check : Icons.edit,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isPreview && event.isEditMode)
                              ClayButton(
                                depth: 40,
                                surfaceColor: clayContainerColor(context),
                                parentColor: clayContainerColor(context),
                                spread: 1,
                                borderRadius: 10,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (event.status == "active") {
                                        event.status = "inactive";
                                      } else {
                                        event.status = "active";
                                      }
                                    });
                                    if (event.isEditMode) {
                                      saveChanges(event);
                                    }
                                    setState(() {
                                      event.isEditMode = !event.isEditMode;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child:
                                        (event.status ?? "inactive") == "active"
                                            ? const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              )
                                            : const Icon(
                                                Icons.add,
                                                color: Colors.green,
                                              ),
                                  ),
                                ),
                              ),
                            if (!isPreview && event.isEditMode)
                              const SizedBox(
                                width: 5,
                              ),
                            if (!isPreview)
                              ClayButton(
                                depth: 40,
                                surfaceColor: clayContainerColor(context),
                                parentColor: clayContainerColor(context),
                                spread: 1,
                                borderRadius: 10,
                                child: InkWell(
                                  onTap: () {
                                    if (event.isEditMode) {
                                      saveChanges(event);
                                    } else {
                                      if (events
                                          .where((e) => e.isEditMode)
                                          .isEmpty) {
                                        setState(() {
                                          event.isEditMode = !event.isEditMode;
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      event.isEditMode
                                          ? Icons.check
                                          : Icons.edit,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        event.isEditMode && !isPreview
                            ? Container(
                                margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: InkWell(
                                  onTap: () {
                                    FileUploadInputElement uploadInput =
                                        FileUploadInputElement();
                                    uploadInput.multiple = false;
                                    uploadInput.draggable = true;
                                    uploadInput.accept = '.png,.jpg,.jpeg';
                                    uploadInput.click();
                                    uploadInput.onChange.listen(
                                      (changeEvent) {
                                        final files = uploadInput.files!;
                                        for (File file in files) {
                                          final reader = FileReader();
                                          reader.readAsDataUrl(file);
                                          reader.onLoadEnd.listen(
                                            (loadEndEvent) async {
                                              // _file = file;
                                              print("File uploaded: " +
                                                  file.name);
                                              setState(() {
                                                _isLoading = true;
                                              });

                                              try {
                                                UploadFileToDriveResponse
                                                    uploadFileResponse =
                                                    await uploadFileToDrive(
                                                        reader.result!,
                                                        file.name);

                                                event.coverPhotoUrl =
                                                    uploadFileResponse
                                                        .mediaBean!.mediaUrl;
                                                event.coverPhotoUrlId =
                                                    uploadFileResponse
                                                        .mediaBean!.mediaId;
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Something went wrong while trying to upload, ${file.name}..\nPlease try again later"),
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
                                  child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        (MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? 10
                                            : 2.5),
                                    width: MediaQuery.of(context).size.height /
                                        (MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? 2.5
                                            : 10),
                                    child: FadeInImage(
                                      placeholder: const AssetImage(
                                        'assets/images/loading_grey_white.gif',
                                      ),
                                      image: NetworkImage(event.coverPhotoUrl!),
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: MediaQuery.of(context).size.height /
                                    (MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? 10
                                        : 2.5),
                                width: MediaQuery.of(context).size.height /
                                    (MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? 2.5
                                        : 10),
                                margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: FadeInImage(
                                  placeholder: const AssetImage(
                                    'assets/images/loading_grey_white.gif',
                                  ),
                                  image: NetworkImage(event.coverPhotoUrl!),
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                      ] +
                      (event.isEditMode && !isPreview
                          ? editableEventDetailsChildren(event)
                          : eventDetailsChildren(event)),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int count =
        MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 3;
    double mainMargin =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.width / 10
            : 10;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          buildRoleButtonForAppBar(context, widget.adminProfile),
          PopupMenuButton<String>(
            onSelected: _performMoreActions,
            itemBuilder: (context) {
              return [
                isPreviewMode
                    ? const PopupMenuItem<String>(
                        value: "enable_edit_mode",
                        child: Text("Edit"),
                      )
                    : const PopupMenuItem<String>(
                        value: "enable_preview_mode",
                        child: Text("View"),
                      ),
              ];
            },
          ),
        ],
      ),
      drawer: AdminAppDrawer(
        adminProfile: widget.adminProfile,
      ),
      body: _isLoading
          ? Center(
              child: Image.asset('assets/images/eis_loader.gif'),
            )
          : ListView(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                      mainMargin, 20, mainMargin, mainMargin),
                  child: isPreviewMode
                      ? GridView.count(
                          primary: false,
                          padding: const EdgeInsets.all(1.5),
                          crossAxisCount: count,
                          childAspectRatio: 1,
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children:
                              events.map((e) => buildEventWidget(e)).toList(),
                        )
                      : isNewEvent
                          ? buildEditableEventWidget(
                              newEvent,
                              isLandscape: MediaQuery.of(context).orientation ==
                                  Orientation.landscape,
                            )
                          : ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: events
                                  .map(
                                    (e) => buildEditableEventWidget(
                                      e,
                                      isLandscape:
                                          MediaQuery.of(context).orientation ==
                                              Orientation.landscape,
                                    ),
                                  )
                                  .toList(),
                            ),
                ),
              ],
            ),
      floatingActionButton: _isLoading || isPreviewMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  isNewEvent = !isNewEvent;
                });
              },
              child:
                  isNewEvent ? const Icon(Icons.close) : const Icon(Icons.add),
            ),
    );
  }
}
