import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/home_page.dart';
import 'package:flutter_chat/service/database_service.dart';
import 'package:flutter_chat/widgets/widgets.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo(
      {super.key,
      required this.adminName,
      required this.groupId,
      required this.groupName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf('_') + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Group info'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Exit'),
                      content: const Text('Exit the group?'),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            DataBaseService(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .toggleGroupJoin(widget.groupId,
                                    getName(widget.adminName), widget.groupName)
                                .whenComplete(() => {
                                      nextScreenReplacement(
                                          context, const HomePage())
                                    });
                          },
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    widget.groupName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group: ${widget.groupName}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Admin: ${getName(widget.adminName)}')
                  ],
                )
              ],
            ),
          ),
          memberList(),
        ]),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getName(snapshot.data['members'][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        });
  }
}
