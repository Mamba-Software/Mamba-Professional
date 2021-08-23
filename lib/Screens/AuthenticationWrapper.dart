// Flutter Libs
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:provider/provider.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Screens/Authentication/Authenticate.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTimeWrapper.dart';
import 'package:mamba_castelldefels/Models/FirebaseUser.dart';

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<FirebaseUser?>(context);
    return StreamProvider<Future<Usuario?>>.value(
        value: DatabaseService(uid: '').singleUser,
        initialData: Future(() => null),
        child: firebaseUser == null ? Authenticate() : FirstTimeWrapper(),
    );
  }
}