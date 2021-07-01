import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/audio_overview_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_to_speech/screens/welcome_screen.dart';
import 'package:text_to_speech/constants.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  //FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var loggedInUser;
  TextEditingController fieldText = TextEditingController();

  String feedback = "";

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

  void clearText() {
    fieldText.clear();
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
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
              }),
              SizedBox(
                height: 36.0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: fieldText,
                  textAlign: TextAlign.center,
                  onChanged: (text) {
                    feedback = text;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Give us Feedback'),
                ),
              ),
              ElevatedButton(
                  child: Text(
                    'Submit',
                    style: kSendButtonTextStyle,
                  ),
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    await FirebaseFirestore.instance
                          .collection('feedback')
                          .add({
                            "feedback": feedback,
                            "addedAt": DateTime.now()
                          });
                    setState(() {
                      fieldText.clear();
                      showSpinner = false;
                    });
                    //Navigator.pushNamed(context, AudioOverviewScreen.id);
                  }),
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
      ),
    );
  }
}