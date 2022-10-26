import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/pages/auth/login_page.dart';
import 'package:flutter_chat/pages/profile_page.dart';
import 'package:flutter_chat/pages/search_page.dart';
import 'package:flutter_chat/service/auth_service.dart';
import 'package:flutter_chat/service/database_service.dart';
import 'package:flutter_chat/widgets/group_tile.dart';
import 'package:flutter_chat/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  String userName = '';
  String email = '';
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    //getting the list of snapshot in our stream
    await DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(Icons.search))
        ],
        title: const Text(
          'Groups',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 27,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 15),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                'Groups',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplacement(
                    context, ProfilePage(userName: userName, email: email));
              },
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Log out'),
                        content: const Text('Are you sure you want to logout?'),
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
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (route) => false);
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
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Create a group',
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              groupName = val;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != '') {
                      setState(() {
                        _isLoading = true;
                      });
                      DataBaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(userName,
                              FirebaseAuth.instance.currentUser!.uid, groupName)
                          .whenComplete(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                      showSnackBar(
                          context, Colors.green, 'group created successfuly');
                    }
                  },
                  child: const Text('CRATE'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                ),
              ],
            );
          });
        });
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          //check
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        snapshot.data['groups'].length - index - 1;
                    return GroupTile(
                        groupId: getId(snapshot.data['groups'][reverseIndex]),
                        groupName: getName(snapshot.data['groups'][reverseIndex]),
                        userName: snapshot.data['fullName']);
                  },
                );
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor));
          }
        });
  }

  noGroupWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: const Icon(
              Icons.add_circle,
              color: Colors.grey,
              size: 75,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'You have not joined any group, tap on the add button to create the gourp or seach from top search button',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
