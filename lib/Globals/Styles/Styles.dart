import 'package:flutter/material.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class Styles {

  // Colors for Theme
  static const Color mainColor = Color(0xFFF4AD1F);
  
  static const Color mainColorTrans = Color(0x33F4AD1F);
  static const Color accent = Color(0xFF200758);
  static const Color red = Colors.red;

  // New Theme
  // Light Theme
  static const Color blue = Color(0xFF200758);
  static const Color lightBlue = Color(0x8F200758);
  static const Color amber = Color(0xFFF4AD1F);
  // Background Color
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkerGrey = Color(0xFFDEDEDE);
  static const Color grey = Color(0xFF808080);  
  
  // Text Style
  static TextStyle purpleTextStyle = const TextStyle(color: Colors.white, fontSize: 18);
  static const whiteTextStyle = TextStyle(color: white, fontSize: 18);
  static const redTextStyle = TextStyle(color: red, fontSize: 20);

  // Text Input Decoration
  static var textFromInputDecoration = InputDecoration(
    labelStyle: purpleTextStyle,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: red, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: red, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
  );
}
