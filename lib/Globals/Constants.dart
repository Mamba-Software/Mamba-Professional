import 'package:flutter/material.dart';

class Constants {
  // App Name
  static String appName = "Mamba";

  // Main Assets
  static String logoExtended = "assets/images/ExtendedWhite.png";
  static String logoExtendedYellow = "assets/images/ExtendedYellow.png";
  static String logoSimple = "assets/images/SimpleWhite.png";
  static String logoSimpleYellow = "assets/images/SimpleYellow.png";
  static String fotoPerfil = "assets/images/as.png";

  // Screen
  var screenWidth;
  var screenHeight;

  // Error Auth
  var errorAuthLogin = false;
  var errorAuthRegister = false;

  // User
  String userUID = "";
  bool userIsTrainer = false;
  var currentUser;
}
