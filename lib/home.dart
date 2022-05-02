// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/signin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((x) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Signin(),
                  ),
                );
              });
            },
            child: Container(
              padding: EdgeInsets.all(15),
              child: Icon(Icons.exit_to_app_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                )
              ],
              border: Border.all(
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  style: TextStyle(
                    fontSize: 22,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type a username ...",
                  ),
                )),
                Icon(Icons.search_rounded),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
