import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
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

  // Data Service
  var _userDataService = new UserDataService();
  
  // Variables 
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotifications = BehaviorSubject<String?>();

  // Main Functions

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

  AndroidNotificationDetails getAndroidNotificationDetails({String? imageSource}) {
    var androidPlatformChannelSpecifics;
    if (imageSource == null) {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        icon: 'logo_foreground',
        importance: Importance.high,
        priority: Priority.max,
      );
    } else {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        icon: 'logo_foreground',
        importance: Importance.high,
        priority: Priority.max,
        largeIcon: DrawableResourceAndroidBitmap('logo_foreground'),
        //sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      );
    }
    return androidPlatformChannelSpecifics;
  }

  IOSNotificationDetails getIOSNotificationDetails({String? imageSource}) {
    var iOSPlatformChannelSpecifics;
    if (imageSource == null) {
      iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
    } else {
      iOSPlatformChannelSpecifics = IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          /*
          attachments: <IOSNotificationAttachment>[
            IOSNotificationAttachment("assets/images/calendarImage.jpg")
          ]
          sound: 'a_long_cold_sting.wav',
          */
      );
    }
    return iOSPlatformChannelSpecifics;
  }

  Future<void> showNotification(ReceivedNotification notification) async {
    try {
      // Defining Platform Channel Specifics
      var platformChannelSpecifics = NotificationDetails(
          android: getAndroidNotificationDetails(),
          iOS: getIOSNotificationDetails()
      );
      // Showing Notification
      _notificationsPlugin.show(
          notification.id!,
          notification.title,
          notification.body,
          platformChannelSpecifics,
          payload: notification.payload,
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> scheduleNotification(DateTime scheduleNotifTime, ReceivedNotification notification) async {

    // Defining Platform Channel Specifics
    var platformChannelSpecifics = NotificationDetails(
        android: getAndroidNotificationDetails(),
        iOS: getIOSNotificationDetails()
    );
    // Getting DateTimeTZ from DateTime scheduleNotifTime
    final location = tz.getLocation(timeZoneName!);
    final scheduledDate = tz.TZDateTime.from(scheduleNotifTime, location);
    // Scheduling Notification
    _notificationsPlugin.zonedSchedule(
        notification.id!,
        notification.title,
        notification.body,
        scheduledDate,
        platformChannelSpecifics,
        payload: notification.payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  // onClickedNotification handles Redirection of Notification
  Future<void> onClickedNotification(BuildContext context, [String? payload, ReceivedNotification? notification]) async {
    // Two types of Notifications:
    //      LocalNotifications only send String payload
    //      Remote Firebase Notifications we send the whole Notification with Arguments

    // FIRST CASE: Local Notifications
    if (payload != null && notification == null) {
      String payloadFeedback = payload.substring(0,2);
      String payloadSubString = payload.substring(2);
      bool isFeedback = payloadFeedback == "F-";
      if (isFeedback) {
        print("Feedback Event Page");
        await Navigator.of(context).pushNamed("EventFeedbackPage", arguments: payloadSubString);
        pageController.jumpToPage(2);
      } else {
        print("Event Page");
        await Navigator.of(context).pushNamed("EventPage", arguments: payload);
      }
    } else
    // SECOND CASE: Firebase Cloud Notifications
    if (notification != null && payload == null) {

    }
  }

  // Detailed Functions

  Future<void> addLocalNotification(ReceivedNotification notification) async {
    // Defining Platform Channel Specifics
    var platformChannelSpecifics = NotificationDetails(
        android: getAndroidNotificationDetails(),
        iOS: getIOSNotificationDetails()
    );
    // Getting DateTimeTZ from DateTime scheduleNotifTime
    final location = tz.getLocation(timeZoneName!);
    final scheduledDate = tz.TZDateTime.from(notification.firesAt!, location);
    // Add Notification Firebase
    _userDataService.addLocalNotification(currentUser.id!, notification);
    // Scheduling Notification
    _notificationsPlugin.zonedSchedule(
        notification.id!,
        notification.title,
        notification.body,
        scheduledDate,
        platformChannelSpecifics,
        payload: notification.payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  Future<void> cancellAllLocalNotification() async {
    _notificationsPlugin.cancelAll();
  }

  Future<void> handleLocalNotifications() async {
    // Get Firebase Notifications
    List<ReceivedNotification> firebaseNotifications = await _userDataService.getLocalNotifications(currentUser.id!);
    // Create Aux Variables
    var firebaseNotificationsTemp = List.from(firebaseNotifications);
    // Delete the ones that have been fired
    for (int i = 0; i < firebaseNotifications.length; i++) {
      ReceivedNotification notif = firebaseNotifications[i];
      if (DateTime.now().isAfter(notif.firesAt!)) {
        // Find index in Local Notifications
        firebaseNotificationsTemp.remove(notif);
        _userDataService.deleteLocalNotification(currentUser.id!, notif.id!.toString());
        print("Removing Fired Notification "+notif.id.toString());

      }
    }
    // Compare the ones left to fire with Local Device Notifications
    List<PendingNotificationRequest> pendingNotificationRequests = await _notificationsPlugin.pendingNotificationRequests();
    // Create Aux Variables
    var pendingNotificationRequestsTemp = List.from(pendingNotificationRequests);
    var firebaseLeftTemp = List.from(firebaseNotificationsTemp);
    // Iterate Firebase Notifications
    for (int i = 0; i < firebaseNotificationsTemp.length; i++) {
      ReceivedNotification notif = firebaseNotificationsTemp[i];
      // Find index in Local Notifications
      int index = pendingNotificationRequests.indexWhere((element) => element.id == notif.id);
      // Notification Found
      if (index != -1) {
        // Remove From Firebase and Local Notifications Lists
        pendingNotificationRequestsTemp.removeWhere((element) => element.id == notif.id);
        firebaseLeftTemp.removeWhere((element) => element.id == notif.id);
        print("Notification Matched "+notif.id.toString());
      }
    }

    // Handle the Remaining Firebase Notifications
    if (firebaseLeftTemp.isNotEmpty) {
      // Firebase notifications that have not been matched with Local Device Notifications have to be created
      for (int i = 0; i < firebaseLeftTemp.length; i++) {
        ReceivedNotification notif = firebaseNotifications[i];
        // Schedule Notif
        this.scheduleNotification(notif.firesAt!, notif);
      }
    }
    // Handle the Remaining Local Notifications
    if (pendingNotificationRequestsTemp.isNotEmpty) {
      // Local Device Notifications that have not been matched have to be cancelled
      for (int i = 0; i < pendingNotificationRequestsTemp.length; i++) {
        PendingNotificationRequest notif = pendingNotificationRequestsTemp[i];
        // Cancel Local Notification
        _notificationsPlugin.cancel(notif.id);
      }
    }

    /// JUST TO DEBUG
    // Get Firebase Notifications
    var firebaseEnd = await _userDataService.getLocalNotifications(currentUser.id!);
    print("Firebase");
    for (int i = 0; i < firebaseEnd.length; i++) {
      ReceivedNotification notif = firebaseEnd[i];
      print(notif.id!);
    }
    // Get Local Notifications
    print("Local");
    var localEnd = await _notificationsPlugin.pendingNotificationRequests();
    for (int i = 0; i < localEnd.length; i++) {
      PendingNotificationRequest notif = localEnd[i];
      print(notif.id);
    }
  }
  


}