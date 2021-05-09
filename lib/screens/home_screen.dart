import 'package:flutter/material.dart';
import 'package:text_to_speech/screens/audio_overview_screen.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/text_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_to_speech/screens/create2_screen.dart';


class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPage = 0;

  final _pageOptions = [
    AudioOverviewScreen(),
    CreateScreen(),
    TextScreen(),
  ];

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
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.headset, size: 30), title: Text('Audio')),
            BottomNavigationBarItem(icon: Icon(Icons.add, size: 30), title: Text('Add New')),
            BottomNavigationBarItem(icon: Icon(Icons.settings, size: 30), title: Text('Settings')),
          ],
          elevation: 5.0,
          currentIndex: selectedPage,
          onTap: (index){
            setState(() {
              selectedPage = index;
            });
          },
        )
    );
  }
}