import 'package:flutter/material.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/audio_overview_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //Navigation bar variables
  List pages = [AudioOverviewScreen.id, CreateScreen.id, SettingsScreen.id];
  int selectedPage = 2;


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
            Text('Settings'),
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
          Navigator.pushNamed(context, pages[index]);
        },
      ),
    );
  }
}