import 'package:flutter/material.dart';

// Main Variables
final logoExtended = "assets/images/ExtendedWhite.png";
final logoExtendedYellow = "assets/images/ExtendedYellow.png";
final logoSimple = "assets/images/SimpleWhite.png";
final logoSimpleYellow = "assets/images/SimpleYellow.png";
final fotoPerfil = "assets/images/as.png";

// Error Auth
var errorAuthLogin = false;
var errorAuthRegister = false;

// User
String userUID = "";
bool userIsTrainer = false;
var currentUser;

// Screen
var screenWidth;
var screenHeight;

// Styles
const yellowColor = Color(0xFFF4AD1F);
const yellowColorTrans = Color(0x66F4AD1F);
const purpleColor = Color(0xFF200758);
const purpleLightColor = Color(0x8F190763);
const purpleColorTrans = Color(0x40200758);
const whiteColor = Colors.white;
const redColor = Colors.red;

// Text Style
const purpleTextStyle = TextStyle(color: purpleColor, fontSize: 18);
const whiteTextStyle = TextStyle(color: whiteColor, fontSize: 18);
const redTextStyle = TextStyle(color: redColor, fontSize: 20);

// Text Input Decoration
final textFromInputDecoration = InputDecoration(
    labelStyle: purpleTextStyle,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: purpleColor, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: purpleColor, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: redColor, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: redColor, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
  );