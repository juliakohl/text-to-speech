import 'package:flutter/material.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/audio_overview_screen.dart';

class TextScreen extends StatefulWidget {
  static const String id = 'text_screen';

  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  //Navigation bar variables
  List pages = [AudioOverviewScreen.id, CreateScreen.id, TextScreen.id];
  int selectedPage = 2;


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
            height: 200.0,
            width: double.infinity,
          ),
          Text('text screen'),
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
    icon: Icon(Icons.format_align_center, size: 30),
    label: 'Text'),
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