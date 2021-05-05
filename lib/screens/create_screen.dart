import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:text_to_speech/screens/audio_overview_screen.dart';
import 'package:text_to_speech/screens/create2_screen.dart';
import 'package:text_to_speech/screens/text_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateScreen extends StatefulWidget {
  static const String id = 'create_screen';

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  //Navigation bar variables
  List pages = [AudioOverviewScreen.id, CreateScreen.id, TextScreen.id];
  int selectedPage = 1;

  File _image;
  final picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User loggedInUser;

  Future takeImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

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
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(String loggedinUser, String filePath) async {
    File file = File('${Path.basename(filePath)}}');
    print(filePath + _image.path);
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('images/$loggedinUser/${DateTime.now()}.png')
          .putFile(_image);
      print('uploaded file');
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> processPDF(String loggedinUser) async {
    FilePickerResult _result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    firebase_storage.FirebaseStorage _pdfStorage =
        firebase_storage.FirebaseStorage.instanceFor(
            bucket: 'text-to-speech-312509-pdf');

    if (_result != null) {
      String filepath = _result.files.single.path;
      addTextToFirestore(filepath);
      /*
      try {
        await _pdfStorage
            .ref('$loggedinUser/${DateTime.now()}.pdf')
            .putFile(file);
        print('uploaded file');
      } on firebase_core.FirebaseException catch (e) {
        print(e);
      }
      */
    } else {
      print('User canceled the picker');
    }
  }

  Future<void> addTextToFirestore(String filepath) async {
    DocumentReference _userDoc =
        FirebaseFirestore.instance.collection('users').doc(loggedInUser.email);

    //Load an existing PDF document.
    final PdfDocument document =
        PdfDocument(inputBytes: File(filepath).readAsBytesSync());
    //Extract the text from all the pages.
    List<TextLine> result = PdfTextExtractor(document)
        .extractTextLines(startPageIndex: 1, endPageIndex: 2);

    Rect textBounds = Rect.fromLTWH(5, 5, 100, 200);
    /*
    //Create a new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from a particular page.
    List<TextLine> result = extractor.extractTextLines(startPageIndex: 0);

    //Predefined bound.
    Rect textBounds = Rect.fromLTWH(474, 161, 50, 9);
    */
    String text = '';

    for (int i = 0; i < result.length; i++) {
      List<TextWord> wordCollection = result[i].wordCollection;
      for (int j = 0; j < wordCollection.length; j++) {
        if (textBounds.overlaps(wordCollection[j].bounds)) {
          continue;
        } else {
          text += wordCollection[j].text;
        }
      }
    }

    document.dispose();
    //Display the text.
    print(text);
    //_showResult(invoiceNumber);

    // Call the user's CollectionReference to add a new user
    return _userDoc
        .update({'text': text.substring(0, 1000)})
        .then((value) => print("Text Added"))
        .catchError((error) => print("Failed to add user: $error"));
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
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50.0,
                width: double.infinity,
              ),
              Container(
                height: 125.0,
                child: _image == null
                    ? Text('No image selected.')
                    : Image.file(_image),
              ),
              SizedBox(
                height: 24.0,
                width: double.infinity,
              ),
              IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                tooltip:
                    'You can use your camera to scan any text you have in front of you.',
                onPressed: () {
                  onPressed:
                  takeImage();
                },
              ),
              Text(
                'Take a photo',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 48.0,
                width: double.infinity,
              ),
              IconButton(
                icon: const Icon(
                  Icons.file_upload,
                  color: Colors.white,
                ),
                tooltip:
                    'You can upload a document in xy format as a text source.',
                onPressed: () {
                  getImage();
                },
              ),
              Text(
                'Upload image from gallery',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 48.0,
                width: double.infinity,
              ),
              IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                ),
                tooltip:
                    'You can choose a pdf file to convert its text to audio.',
                onPressed: () async {
                  await processPDF(loggedInUser.email);
                  Navigator.pushNamed(context, Create2Screen.id);
                },
              ),
              Text(
                'Choose a PDF',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 48.0,
                width: double.infinity,
              ),
              SizedBox(
                height: 48.0,
                width: double.infinity,
              ),
              TextButton(
                  child: Text('Continue to the next step'),
                  onPressed: () async {
                    await uploadFile(loggedInUser.email, _image.path);
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
                icon: Icon(Icons.format_align_center, size: 30),
                label: 'Text'),
          ],
          elevation: 5.0,
          currentIndex: selectedPage,
          onTap: (index) {
            Navigator.pushNamed(context, pages[index]);
          },
        ));
  }
}
