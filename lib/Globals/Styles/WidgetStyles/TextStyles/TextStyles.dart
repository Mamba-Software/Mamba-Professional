import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class TextStyles {

  // Text Style
  static TextStyle purpleTextStyle = TextStyle(color: Colors.black, fontSize: 18);
  static const whiteTextStyle = TextStyle(color: Colors.white, fontSize: 18);
  static const redTextStyle = TextStyle(color: Colors.red, fontSize: 20);

  // Text Input Decoration
  static var textFromInputDecoration = InputDecoration(
    labelStyle: purpleTextStyle,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
  );
}
