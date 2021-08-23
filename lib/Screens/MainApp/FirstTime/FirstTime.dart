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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario?>(
      future: Provider.of<Future<Usuario?>>(context),
      builder: (context, snapshot) {
        // Items are not available and you need to handle this situation, simple solution is to show a progress indicator
        if (!snapshot.hasData) {
          return Loading();
        }
        if(snapshot.requireData!.isTrainer) {
          return FirstTrainer();
        } else {
          return FirstClient();
        }
      }
    );
  }
}
