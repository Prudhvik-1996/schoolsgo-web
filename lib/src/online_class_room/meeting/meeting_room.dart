import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/online_class_room/model/online_class_room.dart';
import 'package:schoolsgo_web/src/utils/encryption_utils.dart';
import 'package:schoolsgo_web/src/utils/string_utils.dart';

class MeetingRoom extends StatefulWidget {
  const MeetingRoom(
      {Key? key, required this.onlineClassRoom, required this.adminProfile})
      : super(key: key);

  final OnlineClassRoom onlineClassRoom;
  final AdminProfile adminProfile;

  @override
  _MeetingRoomState createState() => _MeetingRoomState();
}

class _MeetingRoomState extends State<MeetingRoom> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "");
  final subjectText = TextEditingController(text: "");
  final nameText = TextEditingController(text: "");
  final emailText = TextEditingController(text: "");
  final iosAppBarRGBAColor =
      TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = false;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    roomText.text = encrypt(widget.onlineClassRoom.teacherId!);
    subjectText.text = (widget.onlineClassRoom.sectionName ?? "").capitalize() +
        " | " +
        (widget.onlineClassRoom.subjectName ?? "").capitalize() +
        " | " +
        (widget.onlineClassRoom.teacherName ?? "").capitalize();
    nameText.text = (widget.adminProfile.firstName ?? "-").capitalize();
    emailText.text = (widget.adminProfile.mailId ?? "-");
    JitsiMeet.addListener(
      JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Class Room'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: MediaQuery.of(context).orientation == Orientation.landscape
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.30,
                    child: meetConfig(),
                  ),
                  SizedBox(
                    width: width * 0.60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white54,
                        child: SizedBox(
                          width: width * 0.60 * 0.70,
                          height: width * 0.60 * 0.70,
                          child: JitsiMeetConferencing(
                            extraJS: const [
                              // extraJs setup example
                              '<script>function echo(){console.log("echo!!!")};</script>',
                              '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  SizedBox(
                    width: width * 0.60,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white54,
                        child: SizedBox(
                          width: width * 0.60 * 0.70,
                          height: width * 0.60 * 0.70,
                          child: JitsiMeetConferencing(
                            extraJS: const [
                              // extraJs setup example
                              '<script>function echo(){console.log("echo!!!")};</script>',
                              '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  meetConfig(),
                ],
              ),
      ),
    );
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 14.0,
          ),
          TextField(
            enabled: false,
            enableInteractiveSelection: false,
            focusNode: FocusNode(),
            controller: roomText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Room",
            ),
          ),
          const SizedBox(
            height: 14.0,
          ),
          TextField(
            enabled: false,
            enableInteractiveSelection: false,
            focusNode: FocusNode(),
            controller: subjectText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Subject",
            ),
          ),
          const SizedBox(
            height: 14.0,
          ),
          TextField(
            enabled: false,
            enableInteractiveSelection: false,
            focusNode: FocusNode(),
            controller: nameText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Display Name",
            ),
          ),
          const SizedBox(
            height: 14.0,
          ),
          TextField(
            enabled: false,
            enableInteractiveSelection: false,
            focusNode: FocusNode(),
            controller: emailText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email",
            ),
          ),
          const Divider(
            height: 48.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 64.0,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () {
                _joinMeeting();
              },
              child: const Text(
                "Join Meeting",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateColor.resolveWith((states) => Colors.blue)),
            ),
          ),
          const SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    var options = JitsiMeetingOptions(room: roomText.text)
      ..serverURL = serverUrl
      ..subject = subjectText.text
      ..userDisplayName = nameText.text
      ..userEmail = emailText.text
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": nameText.text}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
        onConferenceWillJoin: (message) {
          debugPrint("${options.room} will join with message: $message");
        },
        onConferenceJoined: (message) {
          debugPrint("${options.room} joined with message: $message");
        },
        onConferenceTerminated: (message) {
          debugPrint("${options.room} terminated with message: $message");
        },
        genericListeners: [
          JitsiGenericListener(
            eventName: 'readyToClose',
            callback: (dynamic message) {
              debugPrint("readyToClose callback");
            },
          ),
        ],
      ),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}
