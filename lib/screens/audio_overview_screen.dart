import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/settings_screen.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class AudioOverviewScreen extends StatefulWidget {
  static const String id = 'audio_overview_screen';

  @override
  _AudioOverviewState createState() => _AudioOverviewState();
}

class _AudioOverviewState extends State<AudioOverviewScreen> {
  // Navbar variables
  List pages = [AudioOverviewScreen(), CreateScreen(), SettingsScreen()];
  int selectedPage = 0;

  // Audioplayer
  //AudioPlayer audioPlayer = AudioPlayer();
  final assetsAudioPlayer = AssetsAudioPlayer();

  // auth instance to get current user
  final _auth = FirebaseAuth.instance;
  var loggedInUser;

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

  // mp3 von cloud storage url abspielen
  void play(String url, String title) async {
    String audiofileURL = await downloadAudio(url, title);

    /*int result = await audioPlayer.play(audiofileURL);
    if (result == 1) {
      print("playing audio was successful!");
    }*/

    try {
      await assetsAudioPlayer.open(
        Audio.network(audiofileURL),
        showNotification: true,
        headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
      );
    } catch (t) {
      print(t);
    }

  }

  Future<String> downloadAudio(String url, String title) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    print(appDocDir.path);

    //File downloadToFile = File('${appDocDir.path}/t2s_audiofile.mp3');

    try {
      String downloadURL = await firebase_storage.FirebaseStorage.instanceFor(
              bucket: 'text-to-speech-312509-audio')
          .ref(url)
          .getDownloadURL();
      print("finished download clause");
      return downloadURL;
    } on firebase_core.FirebaseException catch (e) {
      print(e);
      return "";
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
                height: 32.0,
                width: double.infinity,
              ),
              Expanded(
                child: SizedBox(
                  height: 300.0,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(loggedInUser.email)
                          .collection('audio')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        // spinner wenn keine Daten existieren / noch nicht geladen sind
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        // Liste mit Titeln der Audiofiles
                        return ListView(
                          children: snapshot.data!.docs.map((document) {
                            return Center(
                              child: Container(
                                child: TextButton(
                                  child: Text(document["category"]+': '+document["title"], style: TextStyle(color: Colors.tealAccent),),
                                  onPressed: () async {
                                    play(document["filepath"],
                                        document["title"]);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                ),
              ),
              const AudioSlider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.fast_rewind_outlined,
                        size: 48,
                      ),
                      onPressed: () {
                        assetsAudioPlayer.forwardOrRewind(-1.5);
                        //audioPlayer.stop();
                      }),
                  SizedBox(
                    width: 24.0,
                  ),
                  IconButton(
                      icon: Icon(Icons.play_circle_outline, size: 48),
                      onPressed: () {
                        assetsAudioPlayer.play();
                      }),
                  SizedBox(
                    width: 24.0,
                  ),
                  IconButton(
                      icon: Icon(Icons.pause_circle_outline, size: 48),
                      onPressed: () {
                        assetsAudioPlayer.pause();
                        //audioPlayer.pause();
                      }),
                  SizedBox(
                    width: 24.0,
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.stop_circle_outlined,
                        size: 48,
                      ),
                      onPressed: () {
                        assetsAudioPlayer.stop();
                        //audioPlayer.stop();
                      }),
                  SizedBox(
                    width: 24.0,
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.fast_forward_outlined,
                        size: 48,
                      ),
                      onPressed: () {
                        assetsAudioPlayer.forwardOrRewind(1.5);
                        //audioPlayer.stop();
                      })
                ],
              ),
              SizedBox(height: 24.0),
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
                  icon: Icon(Icons.settings, size: 30), label: 'Settings'),
            ],
            elevation: 5.0,
            currentIndex: selectedPage,
            onTap: (index) {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: pages[index]));
              //Navigator.pushNamed(context, pages[index]);
            },
          ),
        );
  }
}

/// This is the stateful widget that the main application instantiates.
class AudioSlider extends StatefulWidget {
  const AudioSlider({Key? key}) : super(key: key);

  @override
  State<AudioSlider> createState() => _AudioSliderState();
}

/// This is the private State class that goes with AudioSlider.
class _AudioSliderState extends State<AudioSlider> {
  double _currentSliderValue = 20;

  set sliderValue(double value) {
    _currentSliderValue = value;
  }


  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      min: 0,
      max: 100,
      divisions: 10,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
        });
      },
    );
  }
}
