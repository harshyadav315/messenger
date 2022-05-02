// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:messenger/services/auth.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messenger")),
      body: Center(
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Text(
              "Signin With Google",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            padding: EdgeInsets.all(10),
          ),
          onTap: () {
            AuthMethods().signInWithGoogle(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
