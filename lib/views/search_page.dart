// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../helper/shared_prefhelper.dart';
import '../services/database.dart';
import 'chat_screen.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  Stream? usersStream, chatRoomsStream;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  String? myName, myProfilePic, myUsername, myEmail, chatRoomId;

  onSearchInit() async {
    usersStream = await DatabaseMethods().getUserByUsername(widget.username);
    isSearching = true;
    await getmyInfo();
    setState(() {});
  }

  @override
  void initState() {
    onSearchInit();
    super.initState();
  }

  getmyInfo() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfile();
    myUsername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    return myUsername;
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
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
        onTap: () async {
          // print("$myUsername");

          var chatRoomId = getChatRoomIdByUsernames(username, myUsername!);
          // print("this is : $chatRoomId");
          Map<String, dynamic> chatRoomInfoMap = {
            "users": [myUsername, username],
          };
          await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

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
              "Search",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            Icon(
              Icons.search_rounded,
              color: Colors.transparent,
            ),
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
              // Search Bar
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          Navigator.pop(context);
                          // setState(() {});
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
            isSearching ? Flexible(child: searchUsersList()) : Container(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
