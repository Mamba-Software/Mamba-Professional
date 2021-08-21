// Flutter Libs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime/FirstTime.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

class FirstTimeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario>(context);
    return usuario.isFirst ? FirstTime() : HomePage();
  }
}