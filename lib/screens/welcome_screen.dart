import 'package:text_to_speech/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:text_to_speech/constants.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: animation.value,
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
                image: AssetImage("images/bw.jpg"),
                fit: BoxFit.cover)
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      child: Image.asset('images/logo.png'),
                      height: 60.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'In Sono',
                      style: TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(width: 32.0,)
                ],
              ),
              SizedBox(
                height: 48.0,
              ),
              ElevatedButton(
                child: Text('Log In', style: kSendButtonTextStyle,),
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
              ElevatedButton(
                  child: Text('Register', style: kSendButtonTextStyle,),
                  onPressed: () {
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  })
            ],
          ),
        ),
      ),
    );
  }
}