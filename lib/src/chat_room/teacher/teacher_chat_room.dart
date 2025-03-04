import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/chat_room/modal/chat_room.dart';
import 'package:schoolsgo_web/src/chat_room/teacher/teacher_chat_screen.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/common_components/common_components.dart';
import 'package:schoolsgo_web/src/common_components/epsilon_diary_loading_widget.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/settings/app_drawer_helper.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';

class TeacherChatRoom extends StatefulWidget {
  const TeacherChatRoom({
    Key? key,
    required this.teacherProfile,
  }) : super(key: key);

  final TeacherProfile teacherProfile;

  static const routeName = "/chat_room";

  @override
  State<TeacherChatRoom> createState() => _TeacherChatRoomState();
}

class _TeacherChatRoomState extends State<TeacherChatRoom> {
  bool _isLoading = true;

  List<ChatRoomBean> chatRooms = [];
  TextEditingController searchController = TextEditingController();
  String searchString = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    GetChatRoomsResponse getChatRoomsResponse = await getChatRooms(GetChatRoomsRequest(
      franchiseId: widget.teacherProfile.franchiseId,
      schoolId: widget.teacherProfile.schoolId,
      teacherId: widget.teacherProfile.teacherId,
    ));
    if (getChatRoomsResponse.httpStatus != "OK" || getChatRoomsResponse.responseStatus != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong! Try again later.."),
        ),
      );
    } else {
      setState(() {
        chatRooms = getChatRoomsResponse.chatRooms?.map((e) => e!).toList() ?? [];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Center(
                  child: ListTile(
                    title: Text("All"),
                  ),
                ),
              ),
              Tab(
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.group),
                    title: Text("Group"),
                  ),
                ),
              ),
              Tab(
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text("One To One"),
                  ),
                ),
              ),
            ],
          ),
          title: const Text("Chat Room"),
        ),
        drawer: AppDrawerHelper.instance.isAppDrawerDisabled()
            ? null
            : TeacherAppDrawer(
                teacherProfile: widget.teacherProfile,
              ),
        body: _isLoading
            ? const EpsilonDiaryLoadingWidget()
            : Column(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        width: MediaQuery.of(context).size.width - 50,
                        child: TextField(
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            labelText: 'Search',
                            hintText: 'Search',
                            contentPadding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                            suffix: Icon(Icons.search),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          autofocus: false,
                          onChanged: (String e) {
                            setState(() {
                              searchString = searchController.text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _isLoading
                            ? Center(
                                child: Image.asset(
                                  'assets/images/eis_loader.gif',
                                  height: 500,
                                  width: 500,
                                ),
                              )
                            : ListView(
                                children: chatRooms
                                    .where((e) => e.lastMessageId != null)
                                    .where((e) =>
                                        searchString.trim() == "" ||
                                        ("${e.teacherName ?? "-"}\n"
                                                "${e.subjectName ?? "-"}\n"
                                                "${e.studentName ?? "-"}")
                                            .toLowerCase()
                                            .contains(searchString.toLowerCase()))
                                    .map((e) => getChatRoomWidget(e))
                                    .toList(),
                              ),
                        _isLoading
                            ? Center(
                                child: Image.asset(
                                  'assets/images/eis_loader.gif',
                                  height: 500,
                                  width: 500,
                                ),
                              )
                            : ListView(
                                children: chatRooms
                                    .where((e) =>
                                        searchString.trim() == "" ||
                                        ("${e.teacherName ?? "-"}\n"
                                                "${e.subjectName ?? "-"}\n"
                                                "${e.studentName ?? "-"}")
                                            .toLowerCase()
                                            .contains(searchString.toLowerCase()))
                                    .where((e) => e.studentId == null)
                                    .map((e) => getChatRoomWidget(e))
                                    .toList(),
                              ),
                        _isLoading
                            ? Center(
                                child: Image.asset(
                                  'assets/images/eis_loader.gif',
                                  height: 500,
                                  width: 500,
                                ),
                              )
                            : ListView(
                                children: chatRooms
                                    .where((e) =>
                                        searchString.trim() == "" ||
                                        ("${e.teacherName ?? "-"}\n"
                                                "${e.subjectName ?? "-"}\n"
                                                "${e.studentName ?? "-"}")
                                            .toLowerCase()
                                            .contains(searchString.toLowerCase()))
                                    .where((e) => e.studentId != null)
                                    .map((e) => getChatRoomWidget(e))
                                    .toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget getChatRoomWidget(ChatRoomBean chatRoom) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return TeacherChatScreen(
              teacherProfile: widget.teacherProfile,
              chatRoom: chatRoom,
            );
          })).then((value) => _loadData());
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerColor(context),
          parentColor: clayContainerColor(context),
          spread: 1,
          borderRadius: 10,
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  chatRoom.studentId == null ? const Icon(Icons.group) : const Icon(Icons.account_circle),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      // margin: const EdgeInsets.all(10),
                      child: getChatRoomName(chatRoom),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
              if (chatRoom.lastMessageId != null) getLastMessageWidget(chatRoom),
            ],
          ),
        ),
      ),
    );
  }

  Widget getChatRoomName(ChatRoomBean chatRoom) {
    if (chatRoom.studentId == null) {
      return Text(
        "${chatRoom.teacherName ?? "-"}\n"
        "${chatRoom.sectionName}\n"
        "${chatRoom.subjectName}",
      );
    }
    return Text("${chatRoom.teacherName ?? "-"}\n"
        "${chatRoom.sectionName}\n"
        "${chatRoom.subjectName}\n"
        "${chatRoom.studentName}");
  }

  Widget getLastMessageWidget(ChatRoomBean chatRoom) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chatRoom.senderName ?? "-",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  (chatRoom.lastMessage ?? ""),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(chatRoom.lastMessageTime != null ? convertEpochToDDMMYYYYNHHMMAA(chatRoom.lastMessageTime!).split("\n").last : "-"),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
