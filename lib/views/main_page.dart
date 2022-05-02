import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:messenger/signin.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: StreamBuilder<User?>(
        //     stream: FirebaseAuth.instance.authStateChanges(),builder: function(context,AsyncSnapshot<User?> user){
        //       Signin();
        //     },),
        );
  }
}
