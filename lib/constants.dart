import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  //color: Color(0xff73e2a7),
  //fontWeight: FontWeight.bold,
  fontSize: 16.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(/*color: Color(0xff1c7c54), */width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(/*color: Color(0xff1c7c54), */width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(/*color: Color(0xff1c7c54), */width: 2.5),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
);