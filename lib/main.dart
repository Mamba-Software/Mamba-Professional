// Plugins
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Authenticate.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTimeWrapper.dart';
import 'package:provider/provider.dart';

import 'Providers/UserProvider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider.instance()
        ),
        ChangeNotifierProvider<UserProvider>(
            create: (_) => UserProvider()
        ),
        ChangeNotifierProvider<ClientProvider>(
            create: (_) => ClientProvider()
        ),
        ChangeNotifierProvider<TrainerProvider>(
            create: (_) => TrainerProvider()
        ),
      ],
      child: Mamba(),
    )
  );
}

class Mamba extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: 'Raleway'),
        debugShowCheckedModeBanner: false,
        home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, AuthenticationProvider user, _) {
        switch (user.status) {
          case Status.Uninitialized:
            return Loading();
          case Status.Unauthenticated:
            return Authenticate();
          case Status.Authenticating:
            return Loading();
          case Status.Authenticated:
            return FirstTimeWrapper();
        }
      },
    );
  }
}


