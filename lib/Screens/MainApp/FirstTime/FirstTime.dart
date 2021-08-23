// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Models/Client.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
import 'package:provider/provider.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Home.dart';
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
        if (!snapshot.hasData || !(snapshot.requireData!.uid == userUID)) {
          return Loading();
        }
        if(snapshot.requireData!.isTrainer) {
          userIsTrainer = true;
          currentTrainer = Provider.of<Trainer>(context);
          return FirstTrainer();
        } else {
          currentClient = Provider.of<Client>(context);
          return FirstClient();
        }
      }
    );
  }
}
