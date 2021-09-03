// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
// Internal App Resources
import 'package:mamba_castelldefels/screens/Authentication/Login.dart';
import 'package:mamba_castelldefels/screens/Authentication/Register.dart';

// Authentiaction Widget
// Depending on Boolean it shows Login / Register
class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = errorAuthRegister == true ? false : true;
  void toggleView(){
    setState(() => showSignIn = !showSignIn);
    errorAuthLogin = false;
    errorAuthRegister = false;
  }
  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return Login(toggleView:  toggleView);
    } else {
      return Register(toggleView:  toggleView);
    }
  }
}