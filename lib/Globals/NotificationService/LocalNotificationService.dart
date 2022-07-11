import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Data/Models/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/subjects.dart';

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

class LocalNotificationService {

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotifications = BehaviorSubject<String?>();

  Future<void> initialize(BuildContext context) async {
    // Init Timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
    // Configuration Android and iOs
    final AndroidInitializationSettings android = AndroidInitializationSettings('logo_foreground');
    final IOSInitializationSettings ios = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
          didReceiveLocalNotificationSubject.add(
            ReceivedNotification(
              id: id,
              title: title,
              body: body,
              payload: payload,
            ),
          );
        }
      );
    InitializationSettings initializationSettings = InitializationSettings(android: android, iOS: ios);
    // Initialise Notifications Plugin
    _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        onNotifications.add(payload);
      }
    );
  }

  void handleNotificationOnClick(BuildContext context, String? payload) {
    print("NOTIFICATION CLICKED BY USER");
    if (payload != null) {
      if (payload == "SplashScreen1") {
        String routeFromMessage = payload.substring(0, payload.length - 1);;
        currentIndex = int.parse(payload[payload.length-1]);
        Navigator.of(context).pushNamedAndRemoveUntil(routeFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
      } else {
        if (ModalRoute.of(context)!.isCurrent) {
          print("Top Page, Moving to Notifications Page");
          currentIndex = int.parse(payload[payload.length-1]);
          if (currentIndex == 2) {
            Navigator.of(context).pushNamedAndRemoveUntil("Notifications", (Route<dynamic> route) => false, arguments: currentIndex);
          } else if (currentIndex == 3) {
            Navigator.of(context).pushNamedAndRemoveUntil("Chat", (Route<dynamic> route) => false, arguments: currentIndex);
          } else {
            pageController.jumpToPage(currentIndex);
          }
        } else {
          print("Not in Home Page, Moving to Splash Screen");
          String payloadFromMessage = payload.substring(0, payload.length - 1);;
          currentIndex = int.parse(payload[payload.length-1]);
          Navigator.of(context).pushNamedAndRemoveUntil(payloadFromMessage, (Route<dynamic> route) => false, arguments: currentIndex);
        }
      }
    }
  }

  static void display(RemoteMessage message) async {
    try {

      final id = DateTime.now().millisecondsSinceEpoch ~/1000;

      // Defining PlatfromChannelSpecifics
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '2',
        'testNotif',
        icon: 'logo_foreground',
        importance: Importance.high,
        priority: Priority.max,
        //sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
        largeIcon: DrawableResourceAndroidBitmap('logo_foreground'),
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        //sound: 'a_long_cold_sting.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          attachments: <IOSNotificationAttachment>[
            IOSNotificationAttachment("assets/images/calendarImage.jpg")
          ]
      );
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics
      );

      // Show Notification
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

  Future<void> showNotification() async {
    try {
      // Defining PlatfromChannelSpecifics
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '2',
        'testNotif',
        icon: 'logo_foreground',
        importance: Importance.high,
        priority: Priority.max,
        //sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
        largeIcon: DrawableResourceAndroidBitmap('logo_foreground'),
      );
      //await ImageUtils().getImageFileFromAssets("assets/images/calendarImage.jpg");
      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        //sound: 'a_long_cold_sting.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          /*
          attachments: <IOSNotificationAttachment>[
            IOSNotificationAttachment("assets/images/calendarImage.jpg")
          ]
           */
      );
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics
      );

      // Showing Notification
      _notificationsPlugin.show(
        0,
        'plain title',
        'plain body',
        platformChannelSpecifics,
        payload: 'item x'
      );

    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> zonedScheduleNotification(DateTime scheduleNotifTime) async {    
      
    // Defining PlatfromChannelSpecifics
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
          presentSound: true
      );
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, 
          iOS: iOSPlatformChannelSpecifics
      );

    // Getting DateTime of Notification
    // Find the 'current location'
    final location = tz.getLocation(timeZoneName!);
    final scheduledDate = tz.TZDateTime.from(scheduleNotifTime, location);


    _notificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
    
  }
}