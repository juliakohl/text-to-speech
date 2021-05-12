import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_to_speech/constants.dart';


String getMostCommonFont(text){
  Map<String, int> counter = {};
  String fontName;
  String fontSize;
  String fontStyle;

  //Draw rectangle.
  for (int i = 0; i < text.length; i++) {
    List<TextWord> wordCollection = text[i].wordCollection;
    for (int j = 0; j < wordCollection.length; j++) {
      //Get the font name.
      fontName = wordCollection[j].fontName;
      //Get the font size.
      fontSize = wordCollection[j].fontSize.toString();
      //Get the font style.
      fontStyle = wordCollection[j].fontStyle.toString();

      if(counter[fontName+fontStyle+fontSize]==null){
        counter[fontName+fontStyle+fontSize] = 1;
      }else{
        counter[fontName+fontStyle+fontSize] += 1;
      }
    }
  }
  print('Font: '+fontName+fontStyle+fontSize+' - count: '+counter[fontName+fontStyle+fontSize].toString());

  var keys = counter.keys;
  var max = keys.elementAt(0);
  var i;

  for (i = 1; i < keys.length; i++) {
    var value = counter[keys.elementAt(i)];
    if (value > counter[max]) max = keys.elementAt(i);
  }

  return max;
}

String reduceTextToCommonFont(result) {
  var commonFont = getMostCommonFont(result);
  print('most common font: '+commonFont);

  String text = "";
  String fontName;
  String fontSize;
  String fontStyle;

  for (int i = 0; i < result.length; i++) {
    List<TextWord> wordCollection = result[i].wordCollection;
    for (int j = 0; j < wordCollection.length; j++) {
      //Get the font name.
      fontName = wordCollection[j].fontName;
      //Get the font size.
      fontSize = wordCollection[j].fontSize.toString();
      //Get the font style.
      fontStyle = wordCollection[j].fontStyle.toString();

      if(fontName+fontStyle+fontSize == commonFont){
        text += wordCollection[j].text;
      }else{
        continue;
      }
    }
    text += " ";
  }
  return text;
}

