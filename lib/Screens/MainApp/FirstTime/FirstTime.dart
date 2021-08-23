// Flutter Libs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime/FirstTrainer.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime/FirstClient.dart';

// First Time Widget
// Depending on Boolean it shows First Time Trainer / Client
class FirstTime extends StatelessWidget {
  var widget;
  @override
  Widget build(BuildContext context) {
    late var usuario = Provider.of<Usuario>(context);
    userIsTrainer = usuario.isTrainer;
    widget = Loading();
    if (userIsTrainer) {
      widget =  FirstTrainer();
    } else {
      widget =  FirstClient();
    }
    return widget;
  }
}
