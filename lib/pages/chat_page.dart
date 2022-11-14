import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/group_info.dart';
import 'package:flutter_chat/service/database_service.dart';
import 'package:flutter_chat/widgets/widgets.dart';

import '../widgets/message_tile.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = '';
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  //last documents that featched
  DocumentSnapshot? fetchedLastDoc;

  @override
  void initState() {
    getChatAdmin();
    super.initState();
  }

  getChatAdmin() {
    DataBaseService().getChats(widget.groupId).then((val) {
      //fetchedLastDoc = val.snapshots.data.docs.last;
      setState(() {
        chats = val;
      });
    });
    DataBaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final heightOfbttomGreyContainer = MediaQuery.of(context).size.height / 11;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(widget.groupName),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(
                      context,
                      GroupInfo(
                        groupId: widget.groupId,
                        groupName: widget.groupName,
                        adminName: admin,
                      ));
                },
                icon: const Icon(Icons.info))
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Stack(
            children: [
              chatMessages(heightOfbttomGreyContainer),
              Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  height: heightOfbttomGreyContainer,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  color: Colors.grey[700],
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Send a message...',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              )
            ],
          ),
        ));
  }

  chatMessages(double heightOfbttomGreyContainer) {
    print(heightOfbttomGreyContainer);
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: heightOfbttomGreyContainer),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      return await DataBaseService()
                          .getChatsRefreshed(widget.groupId, fetchedLastDoc!)
                          .then((value) {
                        fetchedLastDoc = value.docs.last;
                        setState(() {
                          chats = value;
                        });
                      });
                    },
                    child: ListView.builder(
                      primary: false,
                      reverse: true,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return MessageTile(
                          message: snapshot.data.docs[index]['message'],
                          sender: snapshot.data.docs[index]['sender'],
                          sendByMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                        );
                      },
                    ),
                  ),
                ),
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': messageController.text,
        'sender': widget.userName,
        'time': DateTime.now().microsecondsSinceEpoch
      };
      DataBaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
