import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:resize/resize.dart';


// Starting app function. After initialitzation, we define the global providers:
// - Language Provider: To change the Language of the App.

// BackGroundNotificationHandler
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  currentIndex = 2;
}

void main() async {
  // Initialize App
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Firebase Messaging Back Ground Message Handler
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  // System and Top Bar Style
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider()
        ),
      ],
      child: Mamba(),
    )
  );
}

// Launching the Splash Screen
class Mamba extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
        builder: (context, LanguageProvider language, _) {
          return Resize(
            allowtextScaling: true,
            builder: () {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: Constants.appName,
                theme: Styles.lightTheme,
                locale: language.idioma,
                supportedLocales: Idiomas.all,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: SplashScreen(),
                routes: {
                  "SplashScreen": (_) => SplashScreen(),
                },
              );
            },
          );
        }
    );
  }
}

