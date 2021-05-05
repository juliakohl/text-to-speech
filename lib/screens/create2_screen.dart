import 'package:flutter/material.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/audio_overview_screen.dart';
import 'package:text_to_speech/screens/text_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Create2Screen extends StatefulWidget {
  static const String id = 'create2_screen';

  @override
  _Create2ScreenState createState() => _Create2ScreenState();
}

class _Create2ScreenState extends State<Create2Screen> {

  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try{
      final user = _auth.currentUser;
      if(user!=null){
        loggedInUser = user;
        print(loggedInUser.email);
      }}catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Go to your profile',
            onPressed: () {
              print('clicked profile icon');
            },
          ),
          title: Text('In Sono'),
        ),
      body: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 50.0,
            width: double.infinity,
          ),
          Container(
            height: 150.0,
            child: Text("text")
          ),
          SizedBox(
            height: 50.0,
            width: double.infinity,
          ),
          TextButton(child: Text('Continue to the next step'), onPressed: () { print('pressed the button'); Navigator.pushNamed(context, AudioOverviewScreen.id);}),
        ],
      ),
    ),
    );
  }
}
