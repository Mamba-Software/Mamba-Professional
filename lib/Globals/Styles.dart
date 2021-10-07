import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Styles contains all the Colors, Themes and TextStyles used in the App.
class Styles {

  // Colors for Theme
  static const Color mainColor = Color(0xFFF4AD1F);
  static const Color mainColorTrans = Color(0x33F4AD1F);

  static const Color accent = Color(0xFF200758);
  static const Color accentLight = Color(0x8F200758);
  static const Color accentLightTrans = Color(0xFFEAE4F7);

  static const Color white = Color(0xFFFFFFFF);
  static const Color transparentWhite = Color(0xFFFFFF);

  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFDEDEDE);
  static const Color grey = Color(0xFF808080);

  static const Color red = Colors.red;
  static const Color weakerRed = Color(0xffd81b60);

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    backgroundColor: red,
    primaryColor: mainColor,
    accentColor:  accent,
    scaffoldBackgroundColor: white,
    brightness: Brightness.light,
    fontFamily: "Raleway",
    appBarTheme: AppBarTheme(
      elevation: 4.0,
      backgroundColor: mainColor,
      textTheme: TextTheme(
        headline6: TextStyle(
          fontFamily: "Raleway",
          color: white,
          fontSize: 22.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  // Text Style
  static TextStyle purpleTextStyle = TextStyle(color: accent, fontSize: 18);
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
