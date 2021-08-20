// Flutter Libs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Internal App Tools
import 'package:mamba_castelldefels/models/Usuario.dart';
import 'package:mamba_castelldefels/screens/Authentication/Authenticate.dart';
import 'package:mamba_castelldefels/Screens/MainApp/MainApp.dart';

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario?>(context);
    // return either the Home or Authenticate widget
    if (usuario == null) {
      return Authenticate();
    } else {
      return HomePage();
    }
  }
}