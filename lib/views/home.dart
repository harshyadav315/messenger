// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/shared_prefhelper.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/services/database.dart';
import 'package:messenger/views/chat_screen.dart';
import 'package:messenger/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final email = FirebaseAuth.instance;
  bool isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  Stream? usersStream, chatRoomsStream;

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  getChatRoomIdByUsernames_test(String a, String b) {
    if (a.length > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$a\_$b";
    }
  }

  String? myName, myProfilePic, myUsername, myEmail, chatRoomId;
  getmyInfo() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfile();
    myUsername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    return myUsername;
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
  }

  initialFunctions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await getmyInfo();
    while (myUsername == null) {
      print("dbcjhbdcbdbcjbdubcndf");
    }

    setState(() {});
  }

  @override
  void initState() {
    initialFunctions();
    getChatRooms();

    super.initState();
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        // print("$myUsername");
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: (snapshot.data as QuerySnapshot).docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds =
                      (snapshot.data as QuerySnapshot).docs[index];

                  // print(ds.id);
                  // print("$myUsername");
                  String username =
                      ds.id.replaceAll(myUsername!, "").replaceAll("_", "");
                  return Container(
                    child: Center(
                      child: ChatRoomListTile(
                        lastMessage: ds["lastMessage"],
                        username: username,
                        chatRoomId: ds.id,
                      ),
                    ),
                  );
                })
            : Center(child: Text("No Messages !"));
      },
    );
  }

  onSearchButtonClick() async {
    isSearching = true;
    setState(() {});
    usersStream =
        await DatabaseMethods().getUserByUsername(_searchController.text);
    setState(() {});
  }

  Widget searchUsersList() {
    return StreamBuilder(
        stream: usersStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds =
                        (snapshot.data as QuerySnapshot).docs[index];
                    return searchUserEntry(
                        ds["imgUrl"], ds["username"], ds["name"], ds["email"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget searchUserEntry(String profileUrl, username, name, email) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          if (myUsername != null) {
            var chatRoomId = getChatRoomIdByUsernames(username, myUsername!);
            // print("this is : $chatRoomId");
            Map<String, dynamic> chatRoomInfoMap = {
              "users": [myUsername, username],
            };
            DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => ChatScreen(
                        chatWithUsername: username,
                        name: name,
                        profileImage: profileUrl,
                      ))));
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: Image.network(
                profileUrl,
                height: 45,
                width: 45,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(email),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Chats",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            IconButton(
              onPressed: () {
                AuthMethods().signOut().then((x) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signin(),
                    ),
                  );
                });
              },
              icon: Icon(Icons.outbond_rounded),
              color: Colors.red,
              iconSize: 40,
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      )
                    : Container(),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(
                        color: Color(0x00bdbdbd),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      onSubmitted: (value) {
                        if (_searchController.text != "") {
                          onSearchButtonClick();
                        }
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.search_rounded),
                        hintText: "Search ...",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            chatRoomsList(),
            isSearching ? Flexible(child: searchUsersList()) : Container(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  const ChatRoomListTile(
      {Key? key,
      required this.username,
      required this.lastMessage,
      required this.chatRoomId})
      : super(key: key);
  final String lastMessage, username, chatRoomId;

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String? username, name, profilePicUrl;
  bool gotData = false;

  getUserInfo() async {
    username = widget.username;

    QuerySnapshot qs = await DatabaseMethods().getUserInfo(username!);
    qs = (qs as QuerySnapshot);

    // print("This is query snapshot ${qs.docs[0].id}");
    name = qs.docs[0]["name"];
    profilePicUrl = qs.docs[0]["imgUrl"];
    gotData = true;
    setState(() {});
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  onChatTap() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => ChatScreen(
                  chatWithUsername: username,
                  name: name,
                  profileImage: profilePicUrl,
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return gotData
        ? Padding(
            padding: const EdgeInsets.only(
              bottom: 5,
              left: 20,
              right: 10,
            ),
            child: InkWell(
              onTap: () {
                onChatTap();
              },
              child: Container(
                decoration: BoxDecoration(
                    // color: Colors.amber,
                    ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            profilePicUrl!,
                            height: 60,
                            width: 60,
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(widget.lastMessage),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    // Divider(
                    //   height: 10,
                    //   thickness: 1.8,
                    //   indent: 30,
                    //   endIndent: 30,
                    // ),
                  ],
                ),
              ),
            ),
          )
        : Center(child: Container());
  }
}
