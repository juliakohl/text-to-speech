import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_to_speech/screens/create_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
            ),
            SizedBox(
              height: 24.0,
            ),
            TextButton(
              child: Text('Register'),
              onPressed: () async {
                // TODO: add firebase registration
                try{
                  final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                  // add a new document for the user in firestore
                  FirebaseFirestore.instance.collection('users').doc(email).set({"since": DateTime.now()});

                  if(newUser!=null){
                    Navigator.pushNamed(context, CreateScreen.id);
                  }
                }catch(e){
                  print(e);
                }
                print(email);
                print(password);
              },
            ),
          ],
        ),
      ),
    );
  }
}
