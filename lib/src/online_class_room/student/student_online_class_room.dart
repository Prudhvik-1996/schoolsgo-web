import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/online_class_room/meeting/meeting_room.dart';
import 'package:schoolsgo_web/src/online_class_room/model/online_class_room.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class StudentOnlineClassroomScreen extends StatefulWidget {
  const StudentOnlineClassroomScreen({
    Key? key,
    required this.studentProfile,
  }) : super(key: key);

  final StudentProfile studentProfile;

  static const routeName = "/onlineclassroom";

  @override
  _StudentOnlineClassroomScreenState createState() => _StudentOnlineClassroomScreenState();
}

class _StudentOnlineClassroomScreenState extends State<StudentOnlineClassroomScreen> {
  bool _isLoading = true;

  List<OnlineClassRoom> _onlineClassRooms = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Get all online class rooms
    GetOnlineClassRoomsResponse getOnlineClassRoomsResponse = await getOnlineClassRooms(GetOnlineClassRoomsRequest(
      schoolId: widget.studentProfile.schoolId,
      sectionId: widget.studentProfile.sectionId,
      weekId: DateTime.now().weekday,
    ));
    if (getOnlineClassRoomsResponse.httpStatus == "OK" && getOnlineClassRoomsResponse.responseStatus == "success") {
      setState(() {
        _onlineClassRooms = getOnlineClassRoomsResponse.onlineClassRooms!.map((e) => e!).where((e) => e.weekId == DateTime.now().weekday).toList();
        DateTime x = DateTime.now();
        DateTime now = DateTime(x.year, x.month, x.day);
        var customOCRs = _onlineClassRooms
            .where((eachOcr) => eachOcr.date != null && (convertYYYYMMDDFormatToDateTime(eachOcr.date!).difference(now)).inDays < 7)
            .toList();
        var traditionalOCRs = _onlineClassRooms.where((eachOcr) => eachOcr.date == null);
        var overLappedOCRs = [];
        for (var eachTraditionalOcr in traditionalOCRs) {
          for (var eachCustomOcr in customOCRs) {
            bool isOverlapped = false;
            int startTimeEqOfTraditionalOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachTraditionalOcr.startTime, eachTraditionalOcr.weekId);
            int startTimeEqOfCustomOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachCustomOcr.startTime, eachCustomOcr.weekId);
            int endTimeEqOfTraditionalOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachTraditionalOcr.endTime, eachTraditionalOcr.weekId);
            int endTimeEqOfCustomOcr = getSecondsEquivalentOfTimeFromWHHMMSS(eachCustomOcr.endTime, eachCustomOcr.weekId);
            if ((startTimeEqOfCustomOcr < startTimeEqOfTraditionalOcr && startTimeEqOfTraditionalOcr < endTimeEqOfCustomOcr) ||
                (startTimeEqOfCustomOcr < endTimeEqOfTraditionalOcr && endTimeEqOfTraditionalOcr < endTimeEqOfCustomOcr)) {
              isOverlapped = true;
            }
            if (startTimeEqOfCustomOcr == startTimeEqOfTraditionalOcr && endTimeEqOfCustomOcr == endTimeEqOfTraditionalOcr) {
              isOverlapped = true;
            }
            if (isOverlapped) {
              overLappedOCRs.add(eachTraditionalOcr);
            }
          }
        }
        for (var eachOverlappedOcr in overLappedOCRs) {
          _onlineClassRooms.remove(eachOverlappedOcr);
        }
        _onlineClassRooms.sort((a, b) => a.compareTo(b));
      });
    }

    print("100: _onlineClassRooms: $_onlineClassRooms");

    setState(() {
      _isLoading = false;
    });
  }

  Widget _onGoingClassesWidget(List<OnlineClassRoom> _onGoingClasses) {
    return PageView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      children: _onGoingClasses
          .map(
            (eachOnGoingClass) => Container(
              margin: const EdgeInsets.all(10),
              child: buildOnGoingClassWidget(eachOnGoingClass),
            ),
          )
          .toList(),
    );
  }

  Container buildOnGoingClassWidget(OnlineClassRoom eachOnGoingClass) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          if (eachOnGoingClass.subjectId == null ||
              eachOnGoingClass.teacherId == null ||
              eachOnGoingClass.sectionId == null ||
              eachOnGoingClass.tdsId == null) return;
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MeetingRoom(
              onlineClassRoom: eachOnGoingClass,
              studentProfile: widget.studentProfile,
            );
          }));
        },
        child: ClayButton(
          depth: 20,
          surfaceColor: Colors.green[300],
          parentColor: clayContainerColor(context),
          borderRadius: 10,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).orientation == Orientation.landscape
                ? MediaQuery.of(context).size.height - 100
                : MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).orientation == Orientation.landscape
                ? MediaQuery.of(context).size.height - 100
                : MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(
                            text: convertDateToDDMMMEEEE(eachOnGoingClass.date).split(", ")[0] +
                                (MediaQuery.of(context).orientation == Orientation.landscape ? "\n" : " "),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: convertDateToDDMMMEEEE(eachOnGoingClass.date).split(", ")[1],
                                style: TextStyle(
                                  color: clayContainerTextColor(context),
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${convert24To12HourFormat(eachOnGoingClass.startTime!)} - ${convert24To12HourFormat(eachOnGoingClass.endTime!)}",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          (eachOnGoingClass.subjectName ?? "-").capitalize(),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          (eachOnGoingClass.teacherName ?? "-").capitalize(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _upComingClassesWidget(List<OnlineClassRoom> _upcomingClasses) {
    return ListView(
      controller: ScrollController(),
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              child: ClayContainer(
                depth: 20,
                surfaceColor: Colors.blue[200],
                parentColor: clayContainerColor(context),
                borderRadius: 10,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Upcoming Classes"),
                  ),
                ),
              ),
            ),
          ] +
          (_upcomingClasses.isEmpty
              ? [_noUpcomingClassesWidget()]
              : _upcomingClasses
                  .map(
                    (eachUpcomingClass) => buildUpcomingClassWidget(eachUpcomingClass),
                  )
                  .toList()),
    );
  }

  Container buildUpcomingClassWidget(OnlineClassRoom eachUpcomingClass) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          text: convertDateToDDMMMEEEE(eachUpcomingClass.date).split(", ")[0] +
                              (MediaQuery.of(context).orientation == Orientation.landscape ? "\n" : " "),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: convertDateToDDMMMEEEE(eachUpcomingClass.date).split(", ")[1],
                              style: TextStyle(
                                color: clayContainerTextColor(context),
                                fontSize: 11,
                              ),
                            )
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${convert24To12HourFormat(eachUpcomingClass.startTime!)} - ${convert24To12HourFormat(eachUpcomingClass.endTime!)}",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (eachUpcomingClass.subjectName ?? "-").capitalize(),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (eachUpcomingClass.teacherName ?? "-").capitalize(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noOngoingClassesWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      height: double.infinity,
      width: double.infinity,
      child: ClayContainer(
        depth: 20,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("NO ONGOING CLASSES"),
          ),
        ),
      ),
    );
  }

  Widget _noUpcomingClassesWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ClayContainer(
        depth: 20,
        surfaceColor: Colors.blue[200],
        parentColor: clayContainerColor(context),
        borderRadius: 10,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("NO UPCOMING CLASSES"),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<OnlineClassRoom> _onGoingClasses = _onlineClassRooms.where((eachOnlineClassRoom) {
      int startTime = getSecondsEquivalentOfTimeFromWHHMMSS(eachOnlineClassRoom.startTime, eachOnlineClassRoom.weekId);
      int endTime = getSecondsEquivalentOfTimeFromWHHMMSS(eachOnlineClassRoom.endTime, eachOnlineClassRoom.weekId);
      int currentTime = getSecondsEquivalentOfTimeFromDateTime(now);
      return startTime <= currentTime && currentTime < endTime;
    }).toList();
    List<OnlineClassRoom> _upcomingClasses = _onlineClassRooms.where((eachOnlineClassRoom) {
      int startTime = getSecondsEquivalentOfTimeFromWHHMMSS(eachOnlineClassRoom.startTime, eachOnlineClassRoom.weekId);
      int currentTime = getSecondsEquivalentOfTimeFromDateTime(now);
      return startTime > currentTime;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Class Room"),
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
          : MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _onGoingClasses.isEmpty ? _noOngoingClassesWidget() : _onGoingClassesWidget(_onGoingClasses),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: ClayContainer(
                          depth: 20,
                          surfaceColor: clayContainerColor(context),
                          parentColor: clayContainerColor(context),
                          borderRadius: 10,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: _upComingClassesWidget(_upcomingClasses),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : ListView(
                  children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: ClayContainer(
                            depth: 20,
                            surfaceColor: Colors.blue[200],
                            parentColor: clayContainerColor(context),
                            borderRadius: 10,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("Ongoing Classes"),
                              ),
                            ),
                          ),
                        ),
                      ] +
                      _onGoingClasses.map((e) => buildOnGoingClassWidget(e)).toList() +
                      [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: ClayContainer(
                            depth: 20,
                            surfaceColor: clayContainerColor(context),
                            parentColor: clayContainerColor(context),
                            borderRadius: 10,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.all(10),
                                        child: ClayContainer(
                                          depth: 20,
                                          surfaceColor: Colors.blue[200],
                                          parentColor: clayContainerColor(context),
                                          borderRadius: 10,
                                          child: Container(
                                            padding: const EdgeInsets.all(15),
                                            child: const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text("Upcoming Classes"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] +
                                    (_upcomingClasses.isEmpty
                                        ? [_noUpcomingClassesWidget()]
                                        : _upcomingClasses.map((e) => buildUpcomingClassWidget(e)).toList()),
                              ),
                            ),
                          ),
                        ),
                      ],
                ),
    );
  }
}
