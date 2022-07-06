import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Providers/FirebaseAnalyticsProvider.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppThemes/AppThemes.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:provider/provider.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:resize/resize.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';

// Declaring Instance of AppThemes();
AppThemes _appThemes = AppThemes();

// BackGroundNotificationHandler
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  currentIndex = 2;
}

// Starting app function. After initialization, we define the global providers:
// - Language Provider: To change the Language of the App.
void main() async {
  await runZonedGuarded(() async {
    // Initialize App
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // Initialise TimeZone
    timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // Firebase Messaging Back Ground Message Handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    // Firebase Crash Lytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    // Run App
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageProvider>(
              create: (_) => LanguageProvider()
          ),
          ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider()
          ),
          ChangeNotifierProvider<FirebaseAnalyticsProvider>(
              create: (_) => FirebaseAnalyticsProvider()
          ),
        ],
        child: Mamba(),
      )
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });

}

class Mamba extends StatefulWidget {
  const Mamba({Key? key}) : super(key: key);

  @override
  _MambaState createState() => _MambaState();
}

class _MambaState extends State<Mamba> with WidgetsBindingObserver {

  var _dynamicLinkUtils = new DynamicLinkUtils();
  Timer? _timerLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(milliseconds: 1000), () {
            _dynamicLinkUtils.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    if (_timerLink != null) {
      _timerLink?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3 <LanguageProvider, ThemeProvider, FirebaseAnalyticsProvider> (
        builder: (context, LanguageProvider language, ThemeProvider theme,  FirebaseAnalyticsProvider analytics, _) {
          final brightness = SchedulerBinding.instance?.window.platformBrightness;
          if (brightness == Brightness.dark) {
            print("Dark Mode");
            theme.darkModeStatusAndNavigationBar();
          } else {
            print("Light Mode");
            theme.lightModeStatusAndNavigationBar();
          }
          return Resize(
            allowtextScaling: true,
            builder: () {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: Constants.appName,
                themeMode: theme.themeMode,
                theme: _appThemes.returnResponsiveLightTheme(100.vh),
                darkTheme: _appThemes.returnResponsiveDarkTheme(100.vh),
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
                  "Notifications": (_) => Notifications(),
                  "Chat": (_) => ChatCore(),
                },
              );
            },
          );
        }
    );
  }
}

