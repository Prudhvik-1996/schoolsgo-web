import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/common_components/media_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/events/model/events.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/file_utils.dart';

import 'student_each_event_view.dart';

class StudentEventsView extends StatefulWidget {
  const StudentEventsView({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/events";

  @override
  _StudentEventsViewState createState() => _StudentEventsViewState();
}

class _StudentEventsViewState extends State<StudentEventsView> {
  bool _isLoading = true;
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    GetEventsResponse getEventsResponse = await getEvents(GetEventsRequest(
      schoolId: widget.studentProfile.schoolId,
    ));
    if (getEventsResponse.httpStatus == 'OK' && getEventsResponse.responseStatus == 'success') {
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
          content: SizedBox(
            width: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height / 2.5,
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
        );
      },
    );
  }

  Container buildEventDetails(Event event) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 1,
                child: FittedBox(
                  alignment: Alignment.topLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Event Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(event.eventName!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 1,
                child: FittedBox(
                  alignment: Alignment.topLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Event Date",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(event.eventDate!),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 1,
                child: FittedBox(
                  alignment: Alignment.topLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(event.description!),
              ),
            ],
          ),
        ],
      ),
    );
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
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 1,
            child: MediaLoadingWidget(
              mediaUrl: event.coverPhotoUrl!,
              mediaFit: BoxFit.contain,
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
        fit: BoxFit.scaleDown,
        child: InkWell(
          onTap: () {
            openMediaFromUrl(event);
          },
          child: MediaLoadingWidget(
            mediaUrl: event.coverPhotoUrl!,
            mediaFit: BoxFit.contain,
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
            StudentEachEventView.routeName,
            arguments: [widget.studentProfile, event],
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: Colors.transparent,
                  ),
                  child: MediaLoadingWidget(
                    mediaUrl: event.coverPhotoUrl!,
                    mediaFit: BoxFit.contain,
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

  @override
  Widget build(BuildContext context) {
    int count = MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 3;
    double mainMargin = MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width / 10 : 10;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          buildRoleButtonForAppBar(context, widget.studentProfile),
        ],
      ),
      drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
          ? null
          : StudentAppDrawer(
              studentProfile: widget.studentProfile,
            ),
      body: _isLoading
          ? const EpsilonDiaryLoadingWidget()
          : Container(
              margin: EdgeInsets.fromLTRB(mainMargin, 20, mainMargin, mainMargin),
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(1.5),
                crossAxisCount: count,
                childAspectRatio: 1,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0,
                physics: const BouncingScrollPhysics(),
                children: events.map((e) => buildEventWidget(e)).toList(),
              ),
            ),
    );
  }
}
