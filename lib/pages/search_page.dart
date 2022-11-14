import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/pages/chat_page.dart';
import 'package:flutter_chat/service/database_service.dart';
import 'package:flutter_chat/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapShot;
  bool hasUserSearched = false;
  String userName = '';
  User? user;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser!;
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
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(children: [
        Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search Group....",
                  hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                initiateSearchMethod();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            )
          ]),
        ),
        _isLoading
            ? Center(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : groupList(),
      ]),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DataBaseService()
          .searchByname(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapShot = snapshot;
          _isLoading = false;
          hasUserSearched = true;
        });
        print(searchSnapShot!.docs[0]['groupId']);
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapShot!.docs.length,
            itemBuilder: ((context, index) {
              return groupTile(
                userName,
                searchSnapShot!.docs[index]['groupId'],
                searchSnapShot!.docs[index]['groupName'],
                searchSnapShot!.docs[index]['admin'],
              );
            }),
          )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    await DataBaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    //function to check whether user already exits in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Admin: ${getName(admin)}'),
      trailing: InkWell(
        onTap: () async {
          await DataBaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackBar(context, Colors.green, 'succesfully joined the group');
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackBar(context, Colors.red, 'Left the group ${groupName}');
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Joined',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Join now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
