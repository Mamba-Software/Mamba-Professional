import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Providers/FirebaseAnalyticsProvider.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppThemes/AppThemes.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventFeedback.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BonosRequests.dart';
import 'package:provider/provider.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:resize/resize.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';

// Declaring Instance of AppThemes();
AppThemes _appThemes = AppThemes();

// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

// BackGroundNotificationHandler
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
}

// Starting app function. After initialization, we define the global providers:
// - Language Provider: To change the Language of the App.
Future<void> main() async {
  await runZonedGuarded(() async {
    // Initialize App
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // Initialise TimeZone
    timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // Firebase Messaging Back Ground Message Handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    // Firebase Dynamic Links
    DynamicLinkUtils().retrieveDynamicLink();
    // Firebase Crashlytics
    if (isProduction) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
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
        child: const Mamba(),
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

  final _dynamicLinkUtils = DynamicLinkUtils();
  Timer? _timerLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(
        const Duration(milliseconds: 1000), () {
            _dynamicLinkUtils.retrieveDynamicLink();
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3 <LanguageProvider, ThemeProvider, FirebaseAnalyticsProvider> (
        builder: (context, LanguageProvider language, ThemeProvider theme,  FirebaseAnalyticsProvider analytics, _) {
          final brightness = SchedulerBinding.instance.window.platformBrightness;
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
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const SplashScreen(),
                onGenerateRoute: (RouteSettings settings) {
                  final args = settings.arguments;
                  switch (settings.name) {
                    case 'SplashScreen':
                      return CupertinoPageRoute(
                          builder: (_) => const SplashScreen(),
                          settings: const RouteSettings(name: 'SplashScreen'),
                      );
                    case 'Notifications':
                      return CupertinoPageRoute(
                          builder: (_) => const Notifications(),
                          settings: const RouteSettings(name: 'Notifications'),
                      );
                    case 'Chat':
                      return CupertinoPageRoute(
                          builder: (_) => const ChatCore(),
                          settings: const RouteSettings(name: 'ChatCore'),
                      );
                    case 'EventPage':
                      String eventId = args as String;
                      return CupertinoPageRoute(
                          builder: (_) => EventPage(
                            eventId: eventId,
                          ),
                          settings: const RouteSettings(name: 'EventPage'),
                      );
                    case 'EventFeedbackPage':
                      String eventId = args as String;
                      return CupertinoPageRoute(
                          builder: (_) => EventFeedback(
                            eventId: eventId,
                          ),
                          settings: const RouteSettings(name: 'EventFeedback'),
                      );
                    case 'BonosRequests':
                      String brandId = args as String;
                      setState(() {
                        pageIndex = 5;
                      });
                      return CupertinoPageRoute(
                        builder: (_) => BonosRequests(
                          brandId: brandId,
                        ),
                        settings: const RouteSettings(name: 'BonosRequests'),
                      );
                  }
                },
              );
            },
          );
        }
    );
  }
}

