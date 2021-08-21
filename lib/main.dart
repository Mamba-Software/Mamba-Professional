// Plugins
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Data Services
import 'Data/Database.dart';
import 'Globals/Globals.dart';
import 'Models/FirebaseUser.dart';
import 'Data/AuthService.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

// Screens
import 'package:mamba_castelldefels/screens/AuthenticationWrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Mamba());
}

class Mamba extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser?>.value(value: AuthenticationService().usuarioFirebase, initialData: null,
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'Raleway'),
        debugShowCheckedModeBanner: false,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

