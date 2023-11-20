import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';

class NotificationsEvent {
  // Notification Services

  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  //add

  Future<void> addEventLocalNotificationsCallCubit(
      BuildContext context,
      String eventId,
      String userId,
      bool isTrainer,
      String currentUserId,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    //PROBLEMS TODO SOLVE
    try {
      // Local Notifications Service
      if (userId == currentUserId) {
        await _localNotificationService.addEventLocalNotificationsCubit(
            context, eventId, isTrainer, notificationBefore, notificationAfter);
      } else {
        await _localNotificationService.addRemoteEventLocalNotificationsCubit(
            context,
            eventId,
            userId,
            isTrainer,
            notificationBefore,
            notificationAfter);
      }
    } catch (e) {
      print(e);
    }
  }

  //delete

  Future<void> deleteEventLocalNotificationsCall(
      String eventId, String userId, String currentUserId) async {
    if (userId == currentUserId) {
      await _localNotificationService.deleteEventLocalNotifications(eventId);
    } else {
      await _localNotificationService.deleteRemoteEventLocalNotifications(
          eventId, userId);
    }
  }

  //set
  ReceivedNotification setEventNotificationBefore(
      Event event, String titleNot, String bodyNot) {
    // Schedule Before Notification
    DateTime beforeDate = event.startDate!.subtract(Duration(hours: 1));
    String eventTimeTime = StringUtils()
        .hourMinutesToString(event.startDate!.hour, event.startDate!.minute);
    // Notification one hour before
    ReceivedNotification notificationBefore = ReceivedNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: titleNot,
      body: bodyNot,
      bonoId: '',
      payload: '',
      //payload: event.id!,
      createdAt: Timestamp.now(),
      firesAt: beforeDate,
    );
    return notificationBefore;
  }

  ReceivedNotification setEventNotificationBeforeRecurrent(
      Event event, String titleNot, String bodyNot) {
    // Schedule Before Notification
    DateTime beforeDate = event.startDate!.subtract(Duration(hours: 1));
    String eventTimeTime = StringUtils()
        .hourMinutesToString(event.startDate!.hour, event.startDate!.minute);
    titleNot = titleNot.replaceAll('replace', eventTimeTime);
    // Notification one hour before
    ReceivedNotification notificationBefore = ReceivedNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: titleNot,
      body: bodyNot,
      bonoId: '',
      payload: event.id!,
      createdAt: Timestamp.now(),
      firesAt: beforeDate,
    );
    return notificationBefore;
  }

  ReceivedNotification setEventNotificationAfter(
      Event event, String titleNotAfter, String bodyNotAfter) {
    var temp = event.duration!.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    int hourNumber = int.parse(hour);
    int minNumber = int.parse(min) + 1;
    // Schedule Before Notification
    DateTime afterDate =
        event.startDate!.add(Duration(hours: hourNumber, minutes: minNumber));
    // Notification 1 minute after

    ReceivedNotification notificationAfter = ReceivedNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: titleNotAfter,
      body: bodyNotAfter,
      //title: AppLocalizations.of(context)!.afterEventTitleNotification,
      //body: AppLocalizations.of(context)!.afterEventBodyNotification,
      //payload: "F-" + event.id!,
      payload: "",
      createdAt: Timestamp.now(),
      firesAt: afterDate,
    );

    return notificationAfter;
  }
}
