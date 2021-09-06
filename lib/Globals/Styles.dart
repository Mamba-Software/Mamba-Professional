import 'package:flutter/material.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class Styles {

  // Colors for Theme
  static const Color mainColor = Color(0xFFF4AD1F);
  static const Color mainColorTrans = Color(0x33F4AD1F);

  static const Color accent = Color(0xFF200758);
  static const Color accentLight = Color(0x8F200758);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparentWhite = Color(0x00FFFFFF);

  static const Color red = Color(0xfff81b60);
  static const Color weakerRed = Color(0xffd81b60);

  static Color themePrimary = mainColor;
  static Color themeAccent = accent;
  static Color themeBackground = white;

  // Theme Data
  static ThemeData appTheme = ThemeData(
    primaryColor: themePrimary,
    accentColor:  themeAccent,
    backgroundColor: themeBackground,
    fontFamily: 'Raleway',
  );

  // Text Style
  static const purpleTextStyle = TextStyle(color: accent, fontSize: 18);
  static const whiteTextStyle = TextStyle(color: white, fontSize: 18);
  static const redTextStyle = TextStyle(color: red, fontSize: 20);

  // Text Input Decoration
  static var textFromInputDecoration = InputDecoration(
    labelStyle: purpleTextStyle,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: accent, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: accent, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: red, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: red, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
  );
}
