// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/shared_prefhelper.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/services/database.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {Key? key, this.chatWithUsername, this.name, this.profileImage})
      : super(key: key);

  final chatWithUsername, name, profileImage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? chatRoomId, messageId = "";

  String? myName, myProfilePic, myUsername, myEmail;

  final TextEditingController _sendMessageController = TextEditingController();

  Stream? messageStream;

  getmyInfo() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfile();
    myUsername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    // print("$myUsername");
    chatRoomId =
        getChatRoomIdByUsernames(widget.chatWithUsername!, myUsername!);
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  sendMessage(bool sendClicked) async {
    if (_sendMessageController.text != "") {
      String message = _sendMessageController.text;
      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfo = {
        "message": message,
        "sendBy": myUsername,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic,
      };

      if (messageId == "") {
        messageId = randomAlphaNumeric(15);
      }

      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfo)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSentBy": myUsername,
          "lastMessageTs": lastMessageTs
        };
        if (sendClicked) {
          DatabaseMethods()
              .updateLastMessageSent(chatRoomId!, lastMessageInfoMap);
        }
      });
      if (sendClicked) {
        _sendMessageController.text = "";
        messageId = "";
      }
    }
  }

  Widget singleMessage(String message, bool sentByMe) {
    return Row(
      mainAxisAlignment:
          sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              color: sentByMe ? Colors.lightBlue[400] : Colors.grey[400],
              borderRadius: BorderRadius.only(
                topLeft: sentByMe ? Radius.circular(20) : Radius.circular(2),
                topRight: Radius.circular(20),
                bottomRight:
                    sentByMe ? Radius.circular(2) : Radius.circular(20),
                bottomLeft: Radius.circular(20),
              )),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: sentByMe ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget messagesList() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                padding: EdgeInsets.only(
                  bottom: 70,
                  top: 60,
                ),
                itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds =
                      (snapshot.data! as QuerySnapshot).docs[index];
                  return singleMessage(
                      ds["message"], myUsername == ds["sendBy"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getMessages() async {
    // print("chat id $chatRoomId");
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId!);
    setState(() {});
  }

  doThisOnLaunchScreen() async {
    await getmyInfo();
    getMessages();
  }

  @override
  void initState() {
    doThisOnLaunchScreen();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.profileImage,
                  height: 40,
                  width: 40,
                )),
            SizedBox(
              width: 15,
            ),
            Text(widget.name),
          ],
        ),
      ),
      body: Container(
        child: Stack(children: [
          messagesList(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(30)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TextField(
                          onChanged: ((value) {
                            sendMessage(false);
                          }),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a Message ...",
                          ),
                          controller: _sendMessageController,
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    // Send Button
                    onPressed: (() {
                      sendMessage(true);
                    }),
                    icon: Icon(Icons.send_rounded),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
