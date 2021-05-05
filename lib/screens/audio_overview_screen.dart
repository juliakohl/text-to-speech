import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/text_screen.dart';

class AudioOverviewScreen extends StatefulWidget {
  static const String id = 'audio_overview_screen';

  @override
  _AudioOverviewState createState() => _AudioOverviewState();
}

class _AudioOverviewState extends State<AudioOverviewScreen> {

  // Navbar variables
  List pages = [AudioOverviewScreen.id, CreateScreen.id, TextScreen.id];
  int selectedPage = 0;

  // List with users audiofiles
  List<String> audiofiles = [];

  // auth instance to get current user
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  /*
  Future<void> getUsersAudioFiles() async {
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instanceFor(
                bucket: 'text-to-speech-312509-audio')
            .ref()
            .child('audio')
            .child(loggedInUser.email)
            .listAll();

    await result.items.forEach((firebase_storage.Reference ref) {
      audiofiles.add(ref.fullPath);
      print('Found file: $ref');
    });
  }
*/
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
                height: 100.0,
                width: double.infinity,
              ),
              Expanded(
                child: SizedBox(
                  height: 300.0,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').doc(loggedInUser.email).collection('audio').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                      // spinner wenn keine Daten existieren / noch nicht geladen sind
                      if(!snapshot.hasData){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      // Liste mit Titeln der Audiofiles
                      return ListView(
                        children: snapshot.data.docs.map((document) {
                          return Center(
                            child: Container(
                              child: Text("Title: " + document['title']),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  ),
                ),
              ),
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
                icon: Icon(Icons.format_align_center, size: 30), label: 'Text'),
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
