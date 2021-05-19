import 'package:flutter/material.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/audio_overview_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_to_speech/screens/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final _auth = FirebaseAuth.instance;
  //FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var loggedInUser;


  //Navigation bar variables
  List pages = [AudioOverviewScreen(), CreateScreen(), SettingsScreen()];
  int selectedPage = 2;

  @override
  void initState() {
    super.initState();

    //get the current user from firebase auth
    getCurrentUser();
  }

  // retrieve the current user from firebase auth
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In Sono'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 200.0,
              width: double.infinity,
            ),
            Text('Log Out'),
            IconButton(icon: Icon(Icons.logout), onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, WelcomeScreen.id);
            })
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.headset, size: 30), label: 'Audio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add, size: 30), label: 'Add New'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 30),
              label: 'Settings'),
        ],
        elevation: 5.0,
        currentIndex: selectedPage,
        onTap: (index) {
          Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: pages[index]));
          //Navigator.pushNamed(context, pages[index]);
        },
      ),
    );
  }
}