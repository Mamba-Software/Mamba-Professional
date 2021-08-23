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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario?>(
      future: Provider.of<Future<Usuario?>>(context),
      builder: (context, snapshot) {
        // Items are not available and you need to handle this situation, simple solution is to show a progress indicator
        if (!snapshot.hasData || !(snapshot.requireData!.uid == userUID) ) {
          return Loading();
        }
        if (snapshot.requireData!.isFirst) {
          return FirstTime();
        } else {
          return HomePage();
        }
      }
    );
  }
}