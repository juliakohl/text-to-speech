import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:text_to_speech/screens/audio_overview_screen.dart';
import 'package:text_to_speech/screens/settings_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_to_speech/constants.dart';
import 'package:text_to_speech/pdf_processing.dart';
import 'package:page_transition/page_transition.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CreateScreen extends StatefulWidget {
  static const String id = 'create_screen';

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  // spinner
  bool showSpinner = false;

  //Navigation bar variables
  List pages = [AudioOverviewScreen(), CreateScreen(), SettingsScreen()];
  int selectedPage = 1;

  // Image & PDF variables
  var usePDF = true;
  var feedback = 'Nothing uploaded yet ...';
  var _image;
  final picker = ImagePicker();
  var _pdfPath;

  // Audio File variables
  String audiofileTitle = "audiofile"+'*:*'+DateTime.now().toString();
  String audiofileCategory = "default";
  String audiofileLanguage = "de-DE";
  String ssmlGender = "MALE";
  bool advancedSettings = false;
  bool onlyMostCommonFont = false;
  bool differStyle = false;
  bool excludeBrackets = false;
  bool pdf = false;

  //Firebase variables
  final _auth = FirebaseAuth.instance;
  var loggedInUser;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);


  // access the users camera and save the image file to _image
  Future takeImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        usePDF = false;
      } else {
        print('No image selected.');
      }
    });
  }

  // access the users gallery and save the picked image file to _image
  Future getImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        usePDF = false;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    //get the current user from firebase auth
    getCurrentUser();
    trackScreenview();
  }

  // retrieve the current user from firebase auth
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
        analytics.setCurrentScreen(screenName: 'create new audio');
    } catch (e) {
      print(e);
    }
  }

  void logEvent(String name, int value){
    analytics.logEvent(
      name: name,
      parameters: <String, dynamic>{
        'int': value,
      },
    );
  }

  // upload a file to the users folder in the firebase storage (default bucket)
  Future<void> uploadFile(
      String loggedinUser, String filePath, String title) async {
    //File file = File('${Path.basename(filePath)}}');
    print(filePath + _image.path);
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('images/$loggedinUser/$title.png')
          .putFile(_image);
      print('uploaded file');
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  // upload a pdf to the users folder in the pdf firebase storage bucket
  Future<void> processPDF() async {
    FilePickerResult _result =
        (await FilePicker.platform.pickFiles(type: FileType.any))!;

    if (_result != null) {
      String filepath = _result.files.single.path!;
      _pdfPath = filepath;

      var tmp_array = _pdfPath.split("/");
      var filename = tmp_array[tmp_array.length - 1];

      setState(() {
        usePDF = true;
        feedback = 'Successfully uploaded $filename';
      });
    } else {
      print('User canceled the picker');
    }
  }

  // update the users text value in the users firestore document and trigger the text2speech cloud function
  Future<void> addTextToFirestore(String filepath, String title, String cat,
      String lang, String gender, bool reduceToCommonFont) async {
    // Referenz zu audio collection des users in firestore definieren
    CollectionReference _audioCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(loggedInUser.email)
        .collection('audio');

    // Pfad zu audiofile definieren
    var firestore_filepath = 'audio/${loggedInUser.email}/$title.mp3';

    //Load an existing PDF document.
    final PdfDocument document =
        PdfDocument(inputBytes: File(filepath).readAsBytesSync());

    PdfTextExtractor extractor = PdfTextExtractor(document);

    String text = "";
    if (reduceToCommonFont) {
      List<TextLine> result = extractor.extractTextLines();

      text = reduceTextToCommonFont(result, differStyle);
    } else {
      text = extractor.extractText();
    }

    if(excludeBrackets){
      text = excludeTextInBrackets(text);
    }

    document.dispose();

    //Display the text.
    print(text.substring(0, 10));

    // log analytics event with character length
    logEvent('newPDFwithLength', text.length);

     /*Falls der Text mehr als 500 Zeichen hat: k??rzen (Testing Zwecke)
    if (text.length > 5000) {
      text = text.substring(0, 5000);
    }*/

    // neues Document zu Firestore hinzuf??gen, das T2S Cloud Function triggered
    return _audioCollection
        .add({
          'text': text,
          'title': title,
          'category': cat,
          'filepath': firestore_filepath,
          'language': lang,
          'ssmlGender': gender
        })
        .then((value) => print("Text Added"))
        .catchError((error) => print("Failed to add text: $error"));
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 32.0,
                      width: double.infinity,
                    ),
                    Container(
                      height: 100.0,
                      child: usePDF
                          ? Center(child: Text(feedback))
                          : Image.file(_image),
                    ),
                    SizedBox(
                      height: 24.0,
                      width: double.infinity,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                ),
                                tooltip:
                                    'You can use your camera to scan any text you have in front of you.',
                                onPressed: () {
                                  takeImage();
                                  setState(() {
                                    pdf = false;
                                  });
                                }),
                            Text(
                              'Take a photo',
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 24.0,
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.file_upload,
                              ),
                              tooltip:
                                  'You can upload an image as a text source. Language can not be changed for images. Default is set to German',
                              onPressed: () {
                                getImage();
                                setState(() {
                                  pdf = false;
                                });
                              },
                            ),
                            Text(
                              'Upload image\nfrom gallery',
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 24.0,
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                              ),
                              tooltip:
                                  'You can choose a pdf file to convert its text to audio.',
                              onPressed: () async {
                                await processPDF();
                                //Navigator.pushNamed(context, Create2Screen.id);
                                setState(() {
                                  pdf = true;
                                });
                              },
                            ),
                            Text(
                              'Choose a PDF',
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 48.0,
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      onChanged: (title) {
                        audiofileTitle = title+'*:*'+DateTime.now().toString();
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter a title for the audiofile'),
                    ),
                    SizedBox(
                      height: 24.0,
                      width: double.infinity,
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      onChanged: (cat) {
                        audiofileCategory = cat;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter a category for the audiofile'),
                    ),
                    SizedBox(
                      height: 24.0,
                      width: double.infinity,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton(
                            value: audiofileLanguage,
                            items: [
                              DropdownMenuItem(
                                  child: Text("Deutsch"), value: "de-DE"),
                              DropdownMenuItem(
                                child: Text("English (US)"),
                                value: "en-US",
                              ),
                              DropdownMenuItem(
                                child: Text("English (GB)"),
                                value: "en-GB",
                              ),
                              DropdownMenuItem(
                                child: Text("English (AUS)"),
                                value: "en-AU",
                              ),
                              DropdownMenuItem(
                                child: Text("Espa??ol (Espa??a)"),
                                value: "es-ES",
                              ),
                              DropdownMenuItem(
                                  child: Text("Fran??ais (France)"), value: "fr-FR"),
                              DropdownMenuItem(
                                child: Text("Italiano (Italia)"),
                                value: "it-IT",
                              )
                            ],
                            onChanged: (value) {
                              setState(() {
                                audiofileLanguage = value.toString();
                              });
                            }),
                        SizedBox(
                          width: 16.0,
                        ),
                        DropdownButton(
                            value: ssmlGender,
                            items: [
                              DropdownMenuItem(
                                  child: Text("Female"), value: "FEMALE"),
                              DropdownMenuItem(
                                child: Text("Male"),
                                value: "MALE",
                              )
                            ],
                            onChanged: (value) {
                              setState(() {
                                ssmlGender = value.toString();
                              });
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 32.0,
                      width: double.infinity,
                    ),
                    Visibility(
                      visible: pdf,
                      child: CheckboxListTile(
                        title: Text("Advanced Settings"),
                        value: advancedSettings,
                        onChanged: (newValue) {
                          setState(() {
                            advancedSettings = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                    ),
                    Visibility(
                      visible: advancedSettings,
                      child: CheckboxListTile(
                        title: Text("Exclude text in brackets"),
                        subtitle: Text("e.g. (Einstein, 1920) or [CL20]", style: TextStyle(fontSize: 11),),
                        value: excludeBrackets,
                        onChanged: (newValue) {
                          setState(() {
                            excludeBrackets = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                    ),
                    Visibility(
                      visible: advancedSettings,
                      child: CheckboxListTile(
                        title: Text("Only use most common font"),
                        subtitle: Text("Selecting only the most common font (name, size and style) is a workaround for excluding unwanted text.", style: TextStyle(fontSize: 11),),
                        value: onlyMostCommonFont,
                        onChanged: (newValue) {
                          setState(() {
                            onlyMostCommonFont = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                    ),
                    Visibility(
                      visible: onlyMostCommonFont,
                      child: CheckboxListTile(
                        title: Text("Differ between font style"),
                        subtitle: Text("Do you want to differ between regular, bold and italic for the calculation of the most common font?", style: TextStyle(fontSize: 11),),
                        value: differStyle,
                        onChanged: (newValue) {
                          setState(() {
                            differStyle = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                      width: double.infinity,
                    ),
                    Visibility(
                      visible: _pdfPath!=null || _image!=null,
                      child: ElevatedButton(
                          child: Text(
                            'Continue ????',
                            style: kSendButtonTextStyle,
                          ),
                          onPressed: () async {
                            setState(() {
                              showSpinner = true;
                            });
                            if (usePDF) {
                              await addTextToFirestore(
                                  _pdfPath,
                                  audiofileTitle,
                                  audiofileCategory,
                                  audiofileLanguage,
                                  ssmlGender,
                                  onlyMostCommonFont);
                            } else {
                              await uploadFile(
                                  loggedInUser.email!, _image.path, audiofileTitle);
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(loggedInUser.email)
                                  .collection("audio")
                                  .add({
                                "title": audiofileTitle,
                                "filepath":
                                    "audio/${loggedInUser.email}/$audiofileTitle.mp3",
                                "category": audiofileCategory,
                                "language": audiofileLanguage,
                                "ssmlGender": ssmlGender
                              });

                            }
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: AudioOverviewScreen()));
                            setState(() {
                              showSpinner = false;
                            });
                            //Navigator.pushNamed(context, AudioOverviewScreen.id);
                          }),
                    ),
                  ],
                ),
              ),
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
        )));
  }
}