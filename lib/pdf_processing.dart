import 'package:syncfusion_flutter_pdf/pdf.dart';

String getMostCommonFont(text, differStyle){
  Map<String, num?> counter = {};
  String fontName;
  String fontSize;
  String fontStyle;

  for (int i = 0; i < text.length; i++) {
    List<TextWord> wordCollection = text[i].wordCollection;

    for (int j = 0; j < wordCollection.length; j++) {

      //Get the font name.
      fontName = wordCollection[j].fontName;

      //Get the font size.
      fontSize = wordCollection[j].fontSize.toString();

      //If differStyle -> get the font style.
      if(differStyle){
        fontStyle = wordCollection[j].fontStyle.toString();
      } else { fontStyle = "";}

      // increase counter for current font
      if(counter[fontName+fontStyle+fontSize]==null){
        counter[fontName+fontStyle+fontSize] = 1;
      }else{
        if(counter[fontName+fontStyle+fontSize]!=null){
          counter[fontName+fontStyle+fontSize] = counter[fontName+fontStyle+fontSize]! +1;
        }
      }
    }
  }

  var keys = counter.keys; // fonts
  var max = keys.elementAt(0); // most common font
  var i;

  for (i = 1; i < keys.length; i++) { // foreach font
    var value;
    value = counter[keys.elementAt(i)]; // count for current font
    if (value > counter[max]) max = keys.elementAt(i); // if font > current most common font -> max = value
  }
  return max; // return most common font
}

String reduceTextToCommonFont(result, differStyle) {
  // calculate the most common font
  var commonFont = getMostCommonFont(result, differStyle);
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
      //If differStyle -> get font style
      if(differStyle){
        fontStyle = wordCollection[j].fontStyle.toString();
      } else {
        fontStyle = "";
      }
      // if current font == most common font, add to text
      if(fontName+fontStyle+fontSize == commonFont){
        text += wordCollection[j].text;
      }else{
        continue;
      }
    }
    text += " "; // add space at the end of the line
  }
  return text; // return common font text
}

String excludeTextInBrackets(text) {
  String result = text.replaceAll(new RegExp(r'\(.*?\)')," ");
  return result;
}

