import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'Globals/GlobalVars.dart';

// Starting app function. After initialitzation, we define the global providers:
// - Language Provider: To change the Language of the App.
void main() async {
  // Initialize App
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Firebse Messaging
  configLocalNotification();
  registerNotification();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
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

// Firebase Messaging
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void configLocalNotification() {
  AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo_foreground');
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications',  // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

void registerNotification() {
  firebaseMessaging.requestPermission();
  // OnMessage for App in Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('onMessage: $message');
    if (message.notification != null) {
      showNotification(message.notification!);
    }
    return;
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    if (message.notification != null) {
      showNotification(message.notification!);
    }
    return;
  });
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('background message ${message.notification!.body}');
  currentIndex = 2;
  pageController.jumpToPage(currentIndex);
}

void showNotification(RemoteNotification remoteNotification) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    Platform.isAndroid ? 'com.dfa.flutterchatdemo' : 'com.duytq.flutterchatdemo',
    'Flutter chat demo',
    channelDescription: 'your channel description',
    playSound: true,
    enableVibration: true,
    importance: Importance.max,
    priority: Priority.high,
    color: Color(0xFFF4AD1F),
  );
  IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  print(remoteNotification);

  await flutterLocalNotificationsPlugin.show(
    0,
    remoteNotification.title,
    remoteNotification.body,
    platformChannelSpecifics,
    payload: null,
  );
}

// Launching the Splash Screen
class Mamba extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
        builder: (context, LanguageProvider language, _) {
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
          );
        }
    );
  }
}

