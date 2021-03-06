import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:text_to_speech/screens/settings_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:text_to_speech/constants.dart';

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
  var speed = 1.0;
  var iconcolor = Colors.black54;

  // auth instance to get current user
  final _auth = FirebaseAuth.instance;
  var loggedInUser;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    trackScreenview();
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

  // firebase analytics pageview
  void trackScreenview() {
    try {
      analytics.setCurrentScreen(screenName: 'audio player');
    } catch (e) {
      print(e);
    }
  }

  void download(String url, String title) async {
    String audiofileURL = await downloadAudio(url, title);
    Directory appDocDir =
        await getTemporaryDirectory(); //getApplicationDocumentsDirectory();
    print(appDocDir.path + " downloadURL: " + audiofileURL);
    File downloadToFile = File('${appDocDir.path}/$title.mp3');

    try {
      await firebase_storage.FirebaseStorage.instanceFor(
              bucket: 'text-to-speech-312509-audio')
          .ref(url)
          .writeToFile(downloadToFile);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  // mp3 von cloud storage url abspielen
  void play(String url, String title) async {
    String audiofileURL = await downloadAudio(url, title);

    try {
      await assetsAudioPlayer.open(
        Audio.network(
          audiofileURL,
          metas: Metas(
            title: title,
          ),
        ),
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
              height: 16.0,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Text(
                  'Don\'t worry if the audio doesn\'t play immediately after converting, the process can take up to 10 minutes.'),
            ),
            SizedBox(
              height: 16.0,
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
                        .orderBy('category', descending: false)
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
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _buildPopupDialog(
                                                context,
                                                document.id,
                                                loggedInUser.email),
                                      );
                                    },
                                    child: Icon(
                                      Icons.delete_forever,
                                    )),
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.pressed))
                                            return Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.5);
                                          return Colors
                                              .black12; // Use the component's default.
                                        },
                                      ),
                                    ),
                                    child: Text(
                                      document["category"] +
                                          ': ' +
                                          document["title"].split("*:*").first,
                                      style: kSendButtonTextStyle,
                                    ),
                                    onPressed: () async {
                                      play(document["filepath"],
                                          document["title"]);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                (Platform.operatingSystem != "ios")
                                    ? InkWell(
                                        //only for android devices
                                        child: Icon(Icons.open_in_new),
                                        onTap: () async {
                                          var link = await downloadAudio(
                                              document["filepath"],
                                              document["title"]);
                                          launch(link);
                                        })
                                    : SizedBox(
                                        width: 12.0,
                                      ),
                                (Platform.operatingSystem != "ios")
                                    ? SizedBox(
                                        width: 16.0,
                                      )
                                    : SizedBox(
                                        width: 0,
                                      )
                                /*
                              IconButton(icon: Icon(Icons.download_rounded), onPressed: () async {
                                download(document["filepath"],document["title"]);
                                print("Download icon clicked");
                              },)*/
                              ]);
                        }).toList(),
                      );
                    }),
              ),
            ),
            //const AudioSlider(),
            IconButton(
                icon: Icon(
                  Icons.loop,
                  size: 48,
                  color: iconcolor,
                ),
                onPressed: () {
                  LoopMode loopmode = assetsAudioPlayer.currentLoopMode!;
                  if (loopmode == LoopMode.none) {
                    assetsAudioPlayer.setLoopMode(LoopMode.single);
                    setState(() {
                      iconcolor = Colors.blue;
                    });
                  } else {
                    assetsAudioPlayer.setLoopMode(LoopMode.none);
                    setState(() {
                      iconcolor = Colors.black54;
                    });
                  }
                }),
            //assetsAudioPlayer.setLoopMode(LoopMode.single);

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (Platform.operatingSystem == "ios")
                    ? IconButton(
                        icon: Icon(
                          Icons.fast_rewind_outlined,
                          size: 48,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            speed -= 0.1;
                          });
                          assetsAudioPlayer.forwardOrRewind(speed);
                          //audioPlayer.stop();
                        })
                    : SizedBox(
                        width: 0,
                      ),
                SizedBox(
                  width: 24.0,
                ),
                IconButton(
                    icon: Icon(
                      Icons.play_circle_outline,
                      size: 48,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        speed = 1.0;
                      });
                      assetsAudioPlayer.play();
                    }),
                SizedBox(
                  width: 24.0,
                ),
                IconButton(
                    icon: Icon(Icons.pause_circle_outline,
                        size: 48, color: Colors.black54),
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
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        speed = 1.0;
                      });
                      assetsAudioPlayer.stop();
                      //audioPlayer.stop();
                    }),
                SizedBox(
                  width: 24.0,
                ),
                (Platform.operatingSystem == "ios")
                    ? IconButton(
                        icon: Icon(
                          Icons.fast_forward_outlined,
                          size: 48,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            speed += 0.1;
                          });
                          assetsAudioPlayer.forwardOrRewind(speed);
                        })
                    : SizedBox(
                        width: 0,
                      ),
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

Widget _buildPopupDialog(BuildContext context, String id, email) {
  return new AlertDialog(
    title: const Text('Do you really want to delete this file?'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("This action is final and can not be undone."),
      ],
    ),
    actions: <Widget>[
      new TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Oops, no!'),
      ),
      new TextButton(
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(email)
              .collection('audio')
              .doc(id)
              .delete();
          Navigator.of(context).pop();
        },
        child: const Text('Yes, delete!'),
      ),
    ],
  );
}
