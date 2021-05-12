import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:text_to_speech/screens/audio_overview_screen.dart';
import 'package:text_to_speech/screens/create2_screen.dart';
import 'package:text_to_speech/screens/settings_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_to_speech/constants.dart';
import 'package:text_to_speech/pdf_processing.dart';

class CreateScreen extends StatefulWidget {
  static const String id = 'create_screen';

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  //Navigation bar variables
  List pages = [AudioOverviewScreen.id, CreateScreen.id, SettingsScreen.id];
  int selectedPage = 1;

  // Image & PDF variables
  var usePDF = true;
  var feedback = 'Nothing uploaded yet ...';
  File _image;
  final picker = ImagePicker();
  String _pdfPath;

  // Audio File variables
  String audiofileTitle = "audiofile";
  String audiofileCategory = "default";
  String audiofileLanguage = "de-DE";
  String ssmlGender = "FEMALE";

  //Firebase variables
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User loggedInUser;

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

  // upload a file to the users folder in the firebase storage (default bucket)
  Future<void> uploadFile(
      String loggedinUser, String filePath, String title) async {
    File file = File('${Path.basename(filePath)}}');
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
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (_result != null) {
      String filepath = _result.files.single.path;
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
      String lang, String gender) async {
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

    //Extract all the text from the document.
    //var text = extractor.extractText();

    //Extract all the text from the document.
    List<TextLine> result = extractor.extractTextLines();

    String text = reduceTextToCommonFont(result);
    document.dispose();

    //Display the text.
    print(text);

    // Falls der Text mehr als 500 Zeichen hat: kürzen (Testing Zwecke)
    if (text.length > 500) {
      text = text.substring(0, 500);
    }

    // neues Document zu Firestore hinzufügen, das T2S Cloud Function triggered
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
              Container(
                height: 100.0,
                child: usePDF ? Center(child: Text(feedback)) : Image.file(_image),
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
                            color: Colors.white,
                          ),
                          tooltip:
                              'You can use your camera to scan any text you have in front of you.',
                          onPressed: () {
                            takeImage();
                          }),
                      Text(
                        'Take a photo',
                        style: TextStyle(color: Colors.white),
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
                          color: Colors.white,
                        ),
                        tooltip: 'You can upload an image as a text source.',
                        onPressed: () {
                          getImage();
                        },
                      ),
                      Text(
                        'Upload image from gallery',
                        style: TextStyle(color: Colors.white),
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
                          color: Colors.white,
                        ),
                        tooltip:
                            'You can choose a pdf file to convert its text to audio.',
                        onPressed: () async {
                          await processPDF();
                          //Navigator.pushNamed(context, Create2Screen.id);
                        },
                      ),
                      Text(
                        'Choose a PDF',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (title) {
                  audiofileTitle = title;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter a title for the audiofile'),
              ),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (cat) {
                  audiofileCategory = cat;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter a category for the audiofile'),
              ),
              /*TextField(
                textAlign: TextAlign.center,
                onChanged: (lang) {
                  audiofileLanguage = lang;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Language'),
              ),*/
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
                          value: "en-AUS",
                        ),
                        DropdownMenuItem(child: Text("French"), value: "fr-FR")
                      ],
                      onChanged: (value) {
                        setState(() {
                          audiofileLanguage = value;
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
                          ssmlGender = value;
                        });
                      }),
                ],
              ),
              SizedBox(
                height: 16.0,
                width: double.infinity,
              ),
              TextButton(
                  child: Text('Continue to the next step'),
                  onPressed: () async {
                    if (usePDF) {
                      await addTextToFirestore(_pdfPath, audiofileTitle,
                          audiofileCategory, audiofileLanguage, ssmlGender);
                    } else {
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
                      await uploadFile(
                          loggedInUser.email, _image.path, audiofileTitle);
                    }
                    Navigator.pushNamed(context, AudioOverviewScreen.id);
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
                icon: Icon(Icons.settings, size: 30), label: 'Settings'),
          ],
          elevation: 5.0,
          currentIndex: selectedPage,
          onTap: (index) {
            Navigator.pushNamed(context, pages[index]);
          },
        ));
  }
}
