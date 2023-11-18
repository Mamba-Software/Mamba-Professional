import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/subjects.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

class LocalNotificationService {
  // Data Service
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  final _purchaseDataService = PurchaseDataService();

  // Variables
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotifications = BehaviorSubject<String?>();

  // Main Functions

  Future<void> initialize() async {
    // Init Timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
    // Configuration Android and iOs
    final AndroidInitializationSettings android =
        AndroidInitializationSettings('logo_foreground');
    final IOSInitializationSettings ios = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          didReceiveLocalNotificationSubject.add(
            ReceivedNotification(
              id: id,
              title: title,
              body: body,
              payload: payload,
            ),
          );
        });
    InitializationSettings initializationSettings =
        InitializationSettings(android: android, iOS: ios);
    // Initialise Notifications Plugin
    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      onNotifications.add(payload);
    });
  }

  AndroidNotificationDetails getAndroidNotificationDetails(
      {String? imageSource}) {
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
          iOS: getIOSNotificationDetails());
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

  Future<void> scheduleNotification(
      BuildContext context, ReceivedNotification notification) async {
    // Defining Platform Channel Specifics
    var platformChannelSpecifics = NotificationDetails(
        android: getAndroidNotificationDetails(),
        iOS: getIOSNotificationDetails());
    // Getting DateTimeTZ from CupertinoSelect scheduleNotifTime
    final location = tz.getLocation(timeZoneName!);
    final scheduledDate = tz.TZDateTime.from(notification.firesAt!, location);
    // Get Event
    //print(notification.eventId!);
    Event event = await _eventDataService.getSingleEvent(notification.eventId!);
    String eventTimeTime = StringUtils()
        .hourMinutesToString(int.parse(event.hour!), int.parse(event.minute!));
    // Check with Type of Notification
    String payloadFeedback = notification.payload!.substring(0, 2);
    String payloadSubString = notification.payload!.substring(2);
    bool isFeedback = payloadFeedback == "F-";
    if (isFeedback) {
      // Scheduling Notification
      _notificationsPlugin.zonedSchedule(
          notification.id!,
          AppLocalizations.of(context)!.afterEventTitleNotification,
          AppLocalizations.of(context)!.afterEventBodyNotification,
          scheduledDate,
          platformChannelSpecifics,
          payload: notification.payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } else {
      // Scheduling Notification
      _notificationsPlugin.zonedSchedule(
          notification.id!,
          AppLocalizations.of(context)!
              .beforeEventTitleNotification(event.title!, eventTimeTime),
          AppLocalizations.of(context)!.beforeEventBodyNotification,
          scheduledDate,
          platformChannelSpecifics,
          payload: notification.payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  // onClickedNotification handles Redirection of Notification
  Future<void> onClickedNotification(
      BuildContext context, String payload) async {
    // Two types of Notifications:
    //      LocalNotifications only send String payload
    //      Remote Firebase Notifications we send the whole Notification with Arguments
    print("onClickedNotification. Payload....");
    switch (payload) {
      case "SplashScreen":
        break;
      case "Notifications":
        await Navigator.of(context)
            .pushNamed("Notifications", arguments: pageIndex);
        break;
      case "Chat":
        await Navigator.of(context).pushNamed("Chat", arguments: pageIndex);
        break;
      case "BrandPage":
        break;
      case 'BonosRequests':
        await Navigator.of(context)
            .pushNamed("BonosRequests", arguments: currentBrand.id!);
        break;
      case 'MembershipRequests':
        await Navigator.of(context)
            .pushNamed("MembershipRequests", arguments: currentBrand.id!);
        break;
      default:
        String payloadFeedback = payload.substring(0, 2);
        String payloadSubString = payload.substring(2);
        bool isFeedback = payloadFeedback == "F-";
        if (isFeedback) {
          print("Feedback Event Page");
          await Navigator.of(context)
              .pushNamed("EventFeedbackPage", arguments: payloadSubString);
          // Jump to Page 2, Feedback
          //pageController.jumpToPage(2);
        } else {
          print("Event Page");
          await Navigator.of(context)
              .pushNamed("EventPage", arguments: payload);
        }
        break;
    }
  }

  // didNotificationLaunch handle
  Future<void> didNotificationLaunch(BuildContext context) async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp != null &&
        notificationAppLaunchDetails?.didNotificationLaunchApp == true) {
      onClickedNotification(context, notificationAppLaunchDetails!.payload!);
    }
  }

  Future<void> handleLocalNotifications(BuildContext context) async {
    print("Handling Local Notifications...");
    // Get Firebase Notifications
    List<ReceivedNotification> firebaseNotifications =
        await _userDataService.getLocalNotifications(currentUser.id!);
    // Create Aux Variables
    var firebaseNotificationsTemp = List.from(firebaseNotifications);
    // Delete the ones that have been fired
    for (int i = 0; i < firebaseNotifications.length; i++) {
      ReceivedNotification notif = firebaseNotifications[i];
      if (DateTime.now().isAfter(notif.firesAt!)) {
        // Find index in Local Notifications
        firebaseNotificationsTemp.remove(notif);
        _userDataService.deleteLocalNotification(
            currentUser.id!, notif.id!.toString());
        print("Removing Fired Notification " + notif.id.toString());
      }
      bool eventExists =
          await _eventDataService.checkIfEventExists(notif.eventId!);
      if (eventExists == false) {
        // Find index in Local Notifications
        firebaseNotificationsTemp.remove(notif);
        _userDataService.deleteLocalNotification(
            currentUser.id!, notif.id!.toString());
        print("Removing False Notification " + notif.id.toString());
      }
    }
    print(firebaseNotificationsTemp.length.toString() +
        " Firebase notifications left...");
    // Compare the ones left to fire with Local Device Notifications
    List<PendingNotificationRequest> pendingNotificationRequests =
        await _notificationsPlugin.pendingNotificationRequests();
    print(pendingNotificationRequests.length.toString() +
        " Local notifications...");
    // Create Aux Variables
    var pendingNotificationRequestsTemp =
        List.from(pendingNotificationRequests);
    var firebaseLeftTemp = List.from(firebaseNotificationsTemp);
    // Iterate Firebase Notifications
    for (int i = 0; i < firebaseNotificationsTemp.length; i++) {
      ReceivedNotification notif = firebaseNotificationsTemp[i];
      // Find index in Local Notifications
      int index = pendingNotificationRequests
          .indexWhere((element) => element.id == notif.id);
      // Notification Found
      if (index != -1) {
        // Remove From Firebase and Local Notifications Lists
        pendingNotificationRequestsTemp
            .removeWhere((element) => element.id == notif.id);
        firebaseLeftTemp.removeWhere((element) => element.id == notif.id);
        print("Notification Matched " + notif.id.toString());
      }
    }
    // Handle the Remaining Firebase Notifications
    if (firebaseLeftTemp.isNotEmpty) {
      // Firebase notifications that have not been matched with Local Device Notifications have to be created
      for (int i = 0; i < firebaseLeftTemp.length; i++) {
        ReceivedNotification notif = firebaseLeftTemp[i];
        // Schedule Notif
        await this.scheduleNotification(context, notif);
        print("Local Notification Added " + notif.id.toString());
      }
    }
    // Handle the Remaining Local Notifications
    if (pendingNotificationRequestsTemp.isNotEmpty) {
      // Local Device Notifications that have not been matched have to be cancelled
      for (int i = 0; i < pendingNotificationRequestsTemp.length; i++) {
        PendingNotificationRequest notif = pendingNotificationRequestsTemp[i];
        // Cancel Local Notification
        _notificationsPlugin.cancel(notif.id);
        print("Local Notification Canceled " + notif.id.toString());
      }
    }
    var localNotif = await _notificationsPlugin.pendingNotificationRequests();
    print(localNotif.length.toString() + " pending ...");
    print("Finished Handling Local Notifications...");
  }

  // Detailed Functions

  Future<void> addLocalNotification(ReceivedNotification notification) async {
    // Defining Platform Channel Specifics
    var platformChannelSpecifics = NotificationDetails(
        android: getAndroidNotificationDetails(),
        iOS: getIOSNotificationDetails());
    // Getting DateTimeTZ from CupertinoSelect scheduleNotifTime
    final location = tz.getLocation(timeZoneName!);
    final scheduledDate = tz.TZDateTime.from(notification.firesAt!, location);
    // Add Notification Firebase
    _userDataService.addLocalNotification(currentUser.id!, notification);
    // Scheduling Notification
    _notificationsPlugin.zonedSchedule(notification.id!, notification.title,
        notification.body, scheduledDate, platformChannelSpecifics,
        payload: notification.payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  // Local Notification Current User

  Future<void> addEventLocalNotifications(
      BuildContext context, String eventId, bool? isTrainer) async {
    // Defining Platform Channel Specifics
    var platformChannelSpecifics = NotificationDetails(
        android: getAndroidNotificationDetails(),
        iOS: getIOSNotificationDetails());
    // Getting Event Data
    Event event = await _eventDataService.getSingleEvent(eventId);
    DateTime startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    // Send Feedback Notification To Clients
    if (isTrainer == false) {
      var temp = event.duration!.toStringAsFixed(2);
      var hour = temp.split(".")[0];
      var min = temp.split(".")[1];
      int hourNumber = int.parse(hour);
      int minNumber = int.parse(min) + 1;
      // Schedule Before Notification
      DateTime afterDate =
          startDate.add(Duration(hours: hourNumber, minutes: minNumber));
      // Notification 1 minute after
      ReceivedNotification notificationAfter = ReceivedNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: AppLocalizations.of(context)!.afterEventTitleNotification,
        body: AppLocalizations.of(context)!.afterEventBodyNotification,
        payload: "F-" + event.id!,
        createdAt: Timestamp.now(),
        firesAt: afterDate,
      );
      // Getting DateTimeTZ from CupertinoSelect scheduleNotifTime
      final location = tz.getLocation(timeZoneName!);
      final scheduledDate =
          tz.TZDateTime.from(notificationAfter.firesAt!, location);
      // Add Notification Firebase
      _userDataService.addLocalNotification(currentUser.id!, notificationAfter);
      // Scheduling Notification
      _notificationsPlugin.zonedSchedule(
          notificationAfter.id!,
          notificationAfter.title,
          notificationAfter.body,
          scheduledDate,
          platformChannelSpecifics,
          payload: notificationAfter.payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      // To make sure not the same Timestamp
      await Future.delayed(Duration(seconds: 1));
    }

    // Schedule Before Notification
    DateTime beforeDate = startDate.subtract(Duration(hours: 1));
    String eventTimeTime =
        StringUtils().hourMinutesToString(startDate.hour, startDate.minute);
    // Notification one hour before
    ReceivedNotification notificationBefore = ReceivedNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: AppLocalizations.of(context)!
          .beforeEventTitleNotification(event.title!, eventTimeTime),
      /*title: '⚠️ 🏋️‍ ' +
          event.title! +
          ' a las ' +
          eventTimeTime.toString() +
          ' 🏋️‍ ⚠️ ',*/
      body: AppLocalizations.of(context)!.beforeEventBodyNotification,
      /*  body:
          'Esta sesión está a punto de empezar. Haz clic para consultar todos los detalles',*/

      payload: event.id!,
      createdAt: Timestamp.now(),
      firesAt: beforeDate,
    );
    // Getting DateTimeTZ from CupertinoSelect scheduleNotifTime
    final location = tz.getLocation(timeZoneName!);
    final scheduledDate =
        tz.TZDateTime.from(notificationBefore.firesAt!, location);
    // Add Notification Firebase
    _userDataService.addLocalNotification(currentUser.id!, notificationBefore);
    // Scheduling Notification
    _notificationsPlugin.zonedSchedule(
        notificationBefore.id!,
        notificationBefore.title,
        notificationBefore.body,
        scheduledDate,
        platformChannelSpecifics,
        payload: notificationBefore.payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> addEventLocalNotificationsCubit(
      BuildContext context,
      String eventId,
      bool? isTrainer,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    // Defining Platform Channel Specifics
    var platformChannelSpecifics = NotificationDetails(
        android: getAndroidNotificationDetails(),
        iOS: getIOSNotificationDetails());

    // Send Feedback Notification To Clients
    if (isTrainer == false) {
      /*
      var temp = event.duration!.toStringAsFixed(2);
      var hour = temp.split(".")[0];
      var min = temp.split(".")[1];
      int hourNumber = int.parse(hour);
      int minNumber = int.parse(min) + 1;
      // Schedule Before Notification
      DateTime afterDate =
          startDate.add(Duration(hours: hourNumber, minutes: minNumber));
      // Notification 1 minute after
      
      ReceivedNotification notificationAfter = ReceivedNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: AppLocalizations.of(context)!.afterEventTitleNotification,
        body: AppLocalizations.of(context)!.afterEventBodyNotification,
        payload: "F-" + event.id!,
        createdAt: Timestamp.now(),
        firesAt: afterDate,
      );*/
      // Getting DateTimeTZ from CupertinoSelect scheduleNotifTime
      final location = tz.getLocation(timeZoneName!);
      final scheduledDate =
          tz.TZDateTime.from(notificationAfter.firesAt!, location);
      // Add Notification Firebase
      _userDataService.addLocalNotification(currentUser.id!, notificationAfter);
      // Scheduling Notification
      _notificationsPlugin.zonedSchedule(
          notificationAfter.id!,
          notificationAfter.title,
          notificationAfter.body,
          scheduledDate,
          platformChannelSpecifics,
          payload: notificationAfter.payload,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      // To make sure not the same Timestamp
      await Future.delayed(Duration(seconds: 1));
    }

    // Schedule Before Notification

    // Getting DateTimeTZ from CupertinoSelect scheduleNotifTime
    final location = tz.getLocation(timeZoneName!);
    final scheduledDate =
        tz.TZDateTime.from(notificationBefore.firesAt!, location);
    // Add Notification Firebase
    _userDataService.addLocalNotification(currentUser.id!, notificationBefore);
    // Scheduling Notification
    _notificationsPlugin.zonedSchedule(
        notificationBefore.id!,
        notificationBefore.title,
        notificationBefore.body,
        scheduledDate,
        platformChannelSpecifics,
        payload: notificationBefore.payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> deleteEventLocalNotifications(String eventId) async {
    // Find Notifications under this Event Id.
    List<ReceivedNotification> eventNotifications = await _userDataService
        .findEventLocalNotification(currentUser.id!, eventId);
    // Delete the ones that have been fired
    for (int i = 0; i < eventNotifications.length; i++) {
      ReceivedNotification notif = eventNotifications[i];
      _userDataService.deleteLocalNotification(
          currentUser.id!, notif.id!.toString());
      _notificationsPlugin.cancel(notif.id!);
    }
  }

  // Local Notification Other User. Do it Remotely, aka Firebase

  Future<void> addRemoteEventLocalNotifications(BuildContext context,
      String eventId, String userId, bool isTrainer) async {
    // Getting Event Data
    Event event = await _eventDataService.getSingleEvent(eventId);
    DateTime startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    // Send Feedback Notification To Clients
    if (isTrainer == false) {
      var temp = event.duration!.toStringAsFixed(2);
      var hour = temp.split(".")[0];
      var min = temp.split(".")[1];
      int hourNumber = int.parse(hour);
      int minNumber = int.parse(min) + 1;
      // Schedule After Notification
      DateTime afterDate =
          startDate.add(Duration(hours: hourNumber, minutes: minNumber));
      // Notification 1 minute after
      ReceivedNotification notificationAfter = ReceivedNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '💪 ✅️ Sesión completada ✅️ 💪',
        //title: AppLocalizations.of(context)!.afterEventTitleNotification, PROBLEMS
        body:
            '¿Qué te ha parecido? ¿Demasiado intensa? Comunica tu nivel de esfuerzo a tu entrenador',
        //body: AppLocalizations.of(context)!.afterEventBodyNotification, PROBLEMS
        payload: "F-" + event.id!,
        createdAt: Timestamp.now(),
        firesAt: afterDate,
      );
      // Add Notification Firebase
      _userDataService.addLocalNotification(userId, notificationAfter);
      // To make sure not the same Timestamp
      await Future.delayed(Duration(seconds: 1));
      print("Feedback Event Notification Added");
    }

    // Schedule Before Notification
    DateTime beforeDate = startDate.subtract(Duration(hours: 1));
    String eventTimeTime =
        StringUtils().hourMinutesToString(startDate.hour, startDate.minute);
    // Notification one hour before
    ReceivedNotification notificationBefore = ReceivedNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      // title: AppLocalizations.of(context)!
      // .beforeEventTitleNotification(event.title!, eventTimeTime), PROBLEMS
      // body: AppLocalizations.of(context)!.beforeEventBodyNotification, PROBLEMS
      title: '⚠️ 🏋️‍ ' +
          event.title! +
          ' a las ' +
          eventTimeTime.toString() +
          ' 🏋️‍ ⚠️ ',
      //body: AppLocalizations.of(context)!.beforeEventBodyNotification, PROBLEMS
      body:
          'Esta sesión está a punto de empezar. Haz clic para consultar todos los detalles',
      payload: event.id!,
      createdAt: Timestamp.now(),
      firesAt: beforeDate,
    );
    // Add Notification Firebase
    _userDataService.addLocalNotification(userId, notificationBefore);
    print("Reminder Event Notification Added");
  }

  Future<void> addRemoteEventLocalNotificationsCubit(
      BuildContext context,
      String eventId,
      String userId,
      bool isTrainer,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    // Send Feedback Notification To Clients
    if (isTrainer == false) {
      // Add Notification Firebase
      _userDataService.addLocalNotification(userId, notificationAfter);
      // To make sure not the same Timestamp
      await Future.delayed(Duration(seconds: 1));
      print("Feedback Event Notification Added");
    }
    // Add Notification Firebase
    _userDataService.addLocalNotification(userId, notificationBefore);
    print("Reminder Event Notification Added");
  }

  Future<void> deleteRemoteEventLocalNotifications(
      String eventId, String userId) async {
    // Find Notifications under this Event Id.
    List<ReceivedNotification> eventNotifications =
        await _userDataService.findEventLocalNotification(userId, eventId);
    // Delete the ones that have been fired
    for (int i = 0; i < eventNotifications.length; i++) {
      ReceivedNotification notif = eventNotifications[i];
      _userDataService.deleteLocalNotification(userId, notif.id!.toString());
    }
  }

  // ADD/DELETE BONO REMOTE NOTIFICATION

  Future<void> addRemoteBonoExpirationLocalNotification(
      BuildContext context, String purchaseId) async {
    // Getting Purchase Data
    Purchase purchase = await _purchaseDataService.getPurchaseInfo(purchaseId);
    // Send only if there is an expiration condition
    if (purchase.bono!.condition!.expirationTime != 0) {
      String title = "";
      String body = "";
      String payload = "";
      // Getting Bono Data
      String brandId = purchase.brandId!;
      Bono bono = purchase.bono!;
      // Setting the three differents notifications
      DateTime purchasedDate = purchase.purchasedAt!.toDate();
      purchasedDate = DateTime(
          purchasedDate.year, purchasedDate.month, purchasedDate.day + 1, 9);
      DateTime expirationDate =
          purchasedDate.add(Duration(days: bono.condition!.expirationTime!));

      /// NOTIFICATION 1 DAY BEFORE
      DateTime oneDayBefore = expirationDate.subtract(const Duration(days: 1));
      // This means the Bono has finished with this session
      title = AppLocalizations.of(context)!
          .bonoExpirationTomorrowTitleNotification(bono.title!.toUpperCase());
      body =
          AppLocalizations.of(context)!.bonoExpirationTomorrowBodyNotification;
      payload = "E-" + brandId;
      // Notification 1 Day before
      ReceivedNotification notificationOneDayBefore = ReceivedNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: payload,
        createdAt: Timestamp.now(),
        firesAt: oneDayBefore,
        purchaseId: purchase.id,
      );
      // Add Notification Firebase
      _userDataService.addLocalNotification(
          purchase.userId!, notificationOneDayBefore);
      // To make sure not the same Timestamp
      await Future.delayed(const Duration(seconds: 1));

      /// NOTIFICATION 7 DAYS BEFORE
      DateTime oneWeekBefore = expirationDate.subtract(const Duration(days: 1));
      // This means the Bono has finished with this session
      title = AppLocalizations.of(context)!
          .bonoExpirationWeekTitleNotification(bono.title!.toUpperCase());
      body = AppLocalizations.of(context)!.bonoExpirationWeekBodyNotification;
      payload = "E-" + brandId;
      // Notification 1 Day before
      ReceivedNotification notificationOneWeekBefore = ReceivedNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: payload,
        createdAt: Timestamp.now(),
        firesAt: oneWeekBefore,
        purchaseId: purchase.id,
      );
      // Add Notification Firebase
      _userDataService.addLocalNotification(
          purchase.userId!, notificationOneWeekBefore);
    }
  }

  Future<void> deleteRemoteBonoExpirationLocalNotification(
      String userId, String bonoId, String purchaseId) async {
    // Find Notifications under this Event Id.
    List<ReceivedNotification> bonoNotifications = await _userDataService
        .findBonoLocalNotification(userId, bonoId, purchaseId);
    // Delete the ones that have been fired
    for (int i = 0; i < bonoNotifications.length; i++) {
      ReceivedNotification notif = bonoNotifications[i];
      _userDataService.deleteLocalNotification(
          currentUser.id!, notif.id!.toString());
    }
  }
}
