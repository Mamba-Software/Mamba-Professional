// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:provider/provider.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime/FirstTime.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

class FirstTimeWrapper extends StatelessWidget {
  var widget;
  @override
  Widget build(BuildContext context) {
    late var usuario = Provider.of<Usuario>(context);
    userIsTrainer = usuario.isTrainer;
    widget = Loading();
    if (usuario.isFirst) {
      widget =  FirstTime();
    } else {
      widget =  HomePage();
    }
    return widget;
  }
}