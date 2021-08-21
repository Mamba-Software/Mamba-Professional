// Flutter Libs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime/FirstTrainer.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime/FirstClient.dart';

// First Time Widget
// Depending on Boolean it shows First Time Trainer / Client
class FirstTime extends StatefulWidget {
  @override
  _FirstTimeState createState() => _FirstTimeState();
}

class _FirstTimeState extends State<FirstTime> {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<Usuario>(context);
    userIsTrainer = usuario.isTrainer;
    return usuario.isTrainer ? FirstTrainer() : FirstClient();
  }
}