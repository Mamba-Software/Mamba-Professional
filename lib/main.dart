// Plugins
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mamba_castelldefels/models/Usuario.dart';
import 'package:provider/provider.dart';

// Data Services
import 'data/AuthService.dart';

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
    return StreamProvider<Usuario>.value(
      // Valor es el nostre stream de usuaris
      value: AuthenticationService().usuario,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

