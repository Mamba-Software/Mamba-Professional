import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    // Primary Colors
    primaryColor: Colors.black,
    primaryColorLight: lightBlue,
    accentColor:  amber,
    // BackGround Colors
    backgroundColor: lightGrey,
    scaffoldBackgroundColor: white,
    // Brightness
    brightness: Brightness.light,
    // Texts
    textTheme: TextTheme(
      headline1: TextStyle(color: Colors.black, fontSize: 22),
      subtitle1: TextStyle(color: grey, fontSize: 16),
    ),
    fontFamily: "Helvetica",
    appBarTheme: AppBarTheme(
      elevation: 4.0,
      backgroundColor: white,
      iconTheme: IconThemeData(
        color: Colors.black
      ),
      titleTextStyle: TextStyle(
        fontFamily: "Helvetica",
        color: Colors.black,
        fontSize: 22.0,
        fontWeight: FontWeight.w800,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 40,
      type: BottomNavigationBarType.fixed,
      backgroundColor: white,
      showUnselectedLabels: false,
      showSelectedLabels: true,
    ),
  );

  // Text Style
  static TextStyle purpleTextStyle = TextStyle(color: Colors.black, fontSize: 18);
  static const whiteTextStyle = TextStyle(color: white, fontSize: 18);
  static const redTextStyle = TextStyle(color: red, fontSize: 20);

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
      borderSide: BorderSide(color: red, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: red, width: 1.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
  );
}
