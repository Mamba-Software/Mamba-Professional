import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../GlobalVars.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo_foreground');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _notificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? route) async {
      print("NOTIFICATION CLICKED BY USER");
      if (route != null) {
        if (route == "SplashScreen1") {
          String routeFromMessage = route.substring(0, route.length - 1);;
          currentIndex = int.parse(route[route.length-1]);
          Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
        } else {
          if (ModalRoute.of(context)!.isCurrent) {
            print("Top Page, Moving to Notifications Page");
            currentIndex = int.parse(route[route.length-1]);
            pageController.jumpToPage(currentIndex);
          } else {
            print("Not in Home Page, Moving to Splash Screen");
            String routeFromMessage = route.substring(0, route.length - 1);;
            currentIndex = int.parse(route[route.length-1]);
            Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
          }
        }
      }
    });
  }

  static void display(RemoteMessage message) async {
    try {

      final id = DateTime.now().millisecondsSinceEpoch ~/1000;

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.mamba.mambastyleapp',
        'MambaClient Style',
        channelDescription: 'This is the Android Local Notifications channel',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
      );

      IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        platformChannelSpecifics,
        payload: message.data["route"],
      );

    } on Exception catch (e) {
      print(e);
    }
  }
}