// Flutter Libs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTime/FirstTime.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Models/Client.dart';

class FirstTimeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
        StreamProvider<Trainer>.value(value: DatabaseService().singleTrainer,initialData: currentTrainer),
        StreamProvider<Client>.value(value: DatabaseService().singleClient,initialData: currentClient),
        ],
        child: FutureBuilder<Usuario?>(
          future: Provider.of<Future<Usuario?>>(context),
          builder: (context, snapshot) {
            // Items are not available and you need to handle this situation, simple solution is to show a progress indicator
            if (!snapshot.hasData || !(snapshot.requireData!.uid == userUID)) {
              return Loading();
            }
            if (snapshot.requireData!.isFirst) {
              return FirstTime();
            } else {
              return HomePage();
            }
          }
        ),
      );
    }
  }