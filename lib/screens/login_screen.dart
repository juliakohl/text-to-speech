import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_to_speech/screens/create_screen.dart';

import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String email = "";
  late String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), BlendMode.dstATop),
                image: AssetImage("images/bw.jpg"),
                fit: BoxFit.cover)),
        child: Padding(
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
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
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
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              Text(error),
              SizedBox(
                height: 24.0,
              ),
              ElevatedButton(
                child: Text(
                  'Log In',
                  style: kSendButtonTextStyle,
                ),
                onPressed: () async {
                  // TODO: add firebase log in
                  try {
                    UserCredential user = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: password);
                    if (user != null) {
                      Navigator.pushNamed(context, CreateScreen.id);
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      print('No user found for that email.');
                      setState(() {
                        error = 'Sorry, we couldn\'t find a user found for that email.';
                      });
                    } else if (e.code == 'wrong-password') {
                      print('Wrong password provided for that user.');
                      setState(() {
                        error = 'Oops, wrong password ...';
                      });
                    } else if (e.code == 'invalid-email') {
                      setState(() {
                        error =
                            'Sorry, we couldn\'t find a user found for that email.';
                      });
                    } else {
                      setState(() {
                        error = e.message!;
                      });
                      print(e);
                    }
                  }
                  print(email);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
