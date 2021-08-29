// Plugins
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Authenticate.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTimeWrapper.dart';
import 'package:provider/provider.dart';
import 'Providers/UserProvider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      builder: (context, child) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        return MaterialApp(
          theme: ThemeData(fontFamily: 'Raleway'),
          debugShowCheckedModeBanner: false,
          locale: languageProvider.idioma,
          supportedLocales: Idiomas.all,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AuthenticationWrapper(),
        );
      });
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, AuthenticationProvider user, _) {
        screenHeight = MediaQuery.of(context).size.height;
        screenWidth = MediaQuery.of(context).size.width;
        switch (user.status) {
          case Status.Uninitialized:
            return Loading();
          case Status.Unauthenticated:
            Provider.of<UserProvider>(context).resetUser();
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


