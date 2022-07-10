import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/subjects.dart';

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
BehaviorSubject<String?>();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    // Init Timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));

    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo_foreground');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (
            int id,
            String? title,
            String? body,
            String? payload,
            ) async {
          didReceiveLocalNotificationSubject.add(
            ReceivedNotification(
              id: id,
              title: title,
              body: body,
              payload: payload,
            ),
          );
        });
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
            if (currentIndex == 2) {
              Navigator.of(context).pushNamedAndRemoveUntil("Notifications", (Route<dynamic> route) => false, arguments: currentIndex);
            } else if (currentIndex == 3) {
              Navigator.of(context).pushNamedAndRemoveUntil("Chat", (Route<dynamic> route) => false, arguments: currentIndex);
            } else {
              pageController.jumpToPage(currentIndex);
            }
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
        'Mamba Style',
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

  static Future showNotification() async {
    try {
      print(_notificationsPlugin.toString());
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await _notificationsPlugin.show(
          0, 'plain title', 'plain body', platformChannelSpecifics,
          payload: 'item x');
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> zonedScheduleNotification(DateTime scheduleNotifTime) async {    
      
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1',
        'testNotif',        
        icon: 'logo_foreground',
        //sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
        largeIcon: DrawableResourceAndroidBitmap('logo_foreground'),
      );

      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
          //sound: 'a_long_cold_sting.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true);
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, 
          iOS: iOSPlatformChannelSpecifics
      );

    await _notificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
    
  }
}