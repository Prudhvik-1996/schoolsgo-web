import 'dart:async';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/chat_room/modal/chat_room.dart';
import 'package:schoolsgo_web/src/common_components/clay_button.dart';
import 'package:schoolsgo_web/src/constants/colors.dart';
import 'package:schoolsgo_web/src/model/user_roles_response.dart';
import 'package:schoolsgo_web/src/utils/date_utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StudentChatScreen extends StatefulWidget {
  const StudentChatScreen({
    Key? key,
    required this.studentProfile,
    required this.chatRoom,
  }) : super(key: key);

  final StudentProfile studentProfile;
  final ChatRoomBean chatRoom;

  @override
  State<StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  bool _isLoading = true;

  List<ChatBean> chats = [];
  late ChatBean newChatBean;

  List<_DateWiseChatBean> dateWiseChatBeans = [];
  final ItemScrollController _itemScrollController = ItemScrollController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => _loadNewChats());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      createNewChatBean();
    });
    GetChatsResponse getChatsResponse = await getChats(GetChatsRequest(
      chatRoomId: widget.chatRoom.chatRoomId,
    ));
    if (getChatsResponse.httpStatus == "OK" && getChatsResponse.responseStatus == "success") {
      setState(() {
        chats = (getChatsResponse.chats ?? []).map((e) => e!).toList();
      });
      loadDateWiseChatBeans();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadNewChats() async {
    GetChatsResponse getChatsResponse = await getChats(GetChatsRequest(
      chatRoomId: widget.chatRoom.chatRoomId,
    ));
    if (getChatsResponse.httpStatus == "OK" && getChatsResponse.responseStatus == "success") {
      bool newAvailable = false;
      var newChats = (getChatsResponse.chats ?? []).map((e) => e!).toList();
      for (var eachChat in newChats) {
        if (!chats.map((e) => e.chatId).contains(eachChat.chatId)) {
          chats.add(eachChat);
          newAvailable = true;
        }
      }
      if (newAvailable) {
        loadDateWiseChatBeans();
      }
    }
  }

  void loadDateWiseChatBeans() {
    setState(() {
      dateWiseChatBeans = [];
      chats
          .map((eachChatBean) {
            var x = DateTime.fromMillisecondsSinceEpoch(eachChatBean.createTime!);
            return DateTime(x.year, x.month, x.day);
          })
          .toSet()
          .forEach((eachDateTime) {
            dateWiseChatBeans.add(_DateWiseChatBean(date: eachDateTime, chatBeans: []));
          });
      dateWiseChatBeans.sort(
        (a, b) => a.date.compareTo(b.date),
      );
      for (var eachDateWiseChatBean in dateWiseChatBeans) {
        eachDateWiseChatBean.chatBeans = chats.where((e) {
          var x = DateTime.fromMillisecondsSinceEpoch(e.createTime!);
          return e.status == "active" && DateTime(x.year, x.month, x.day).millisecondsSinceEpoch == eachDateWiseChatBean.date.millisecondsSinceEpoch;
        }).toList();
      }
      for (var eachDateWiseChatBean in dateWiseChatBeans) {
        eachDateWiseChatBean.chatBeans.sort(
          (a, b) => a.createTime!.compareTo(b.createTime!),
        );
      }
    });
  }

  void createNewChatBean() {
    setState(() {
      newChatBean = ChatBean(
        agent: widget.studentProfile.studentId,
        chatAttachments: [],
        chatId: null,
        chatMessage: "",
        chatRoomId: widget.chatRoom.chatRoomId,
        createTime: DateTime.now().millisecondsSinceEpoch,
        parentChatId: null,
        senderId: widget.studentProfile.studentId,
        senderName: widget.studentProfile.studentFirstName,
        senderRole: "STUDENT",
        status: "active",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Room"),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/eis_loader.gif',
                height: 500,
                width: 500,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: chats.isEmpty
                      ? const Center(
                          child: Text("No chats"),
                        )
                      : ScrollablePositionedList.builder(
                          reverse: true,
                          itemScrollController: _itemScrollController,
                          itemCount: dateWiseChatBeans.length,
                          itemBuilder: (context, index) => eachDateWiseChatWidget(dateWiseChatBeans.reversed.toList()[index]),
                        ),
                ),
                const Divider(),
                buildEditableChatWidget(newChatBean),
              ],
            ),
    );
  }

  Widget buildEditableChatWidget(ChatBean chatBean) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 5, 5),
      child: Row(
        children: [
          Expanded(
            child: textFieldWidgetForNewMessage(chatBean),
          ),
          const SizedBox(
            width: 5,
          ),
          sendMessageButton(chatBean),
        ],
      ),
    );
  }

  Widget eachDateWiseChatWidget(_DateWiseChatBean dateWiseChatBean) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 7,
            bottom: 7,
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: Color(0x558AD3D5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                getChatDateText(dateWiseChatBean.date),
              ),
            ),
          ),
        ),
        for (ChatBean eachChatBean in dateWiseChatBean.chatBeans)
          chatBubbleWidget(eachChatBean, eachChatBean.senderRole == "STUDENT" && eachChatBean.senderId == widget.studentProfile.studentId)
      ],
    );
  }

  Widget chatBubbleWidget(ChatBean eachChatBean, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.25,
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        child: Card(
          color: eachChatBean.senderRole != "STUDENT"
              ? Colors.green
              : !isSender
                  ? clayContainerColor(context)
                  : Colors.blue[300],
          child: Wrap(
            alignment: WrapAlignment.end,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    eachChatBean.senderName ?? "-",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    (eachChatBean.chatMessage ?? ""),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: eachChatBean.chatId == null
                      ? const Icon(
                          Icons.access_time_outlined,
                          size: 8,
                        )
                      : Text(convertEpochToDDMMYYYYNHHMMAA(eachChatBean.createTime!).split("\n").last),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textFieldWidgetForNewMessage(ChatBean chatBean) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 25.0,
        maxHeight: 135.0,
      ),
      child: ClayContainer(
        depth: 40,
        surfaceColor: clayContainerColor(context),
        parentColor: clayContainerColor(context),
        spread: 2,
        borderRadius: 10,
        child: TextField(
          cursorColor: Colors.blue,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          controller: chatBean.chatMessageController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 2.0, left: 13.0, right: 13.0, bottom: 2.0),
            hintText: "Type your message",
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget sendMessageButton(ChatBean chatBean) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () async {
          if (chatBean.chatMessageController.text.trim().isEmpty) {
            return;
          }
          setState(() {
            chatBean.chatMessage = chatBean.chatMessageController.text;
          });
          CreateOrUpdateChatResponse createOrUpdateChatResponse = await createOrUpdateChat(newChatBean);
          if (createOrUpdateChatResponse.httpStatus == "OK" && createOrUpdateChatResponse.responseStatus == "success") {
            setState(() {
              newChatBean.chatId = createOrUpdateChatResponse.chatId;
              chats.add(newChatBean);
            });
            createNewChatBean();
            loadDateWiseChatBeans();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Something went wrong! Try again later.."),
              ),
            );
          }
        },
        child: ClayButton(
          depth: 40,
          surfaceColor: clayContainerTextColor(context),
          parentColor: clayContainerColor(context),
          spread: 2,
          borderRadius: 100,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  Icons.send,
                  color: clayContainerColor(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateWiseChatBean {
  DateTime date;
  List<ChatBean> chatBeans;

  _DateWiseChatBean({required this.date, required this.chatBeans});
}
