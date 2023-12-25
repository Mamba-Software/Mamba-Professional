import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/functions/notificationsEvents.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';

class AddEventFunctions {
  final _eventDataService = EventDataService();

  final _notificationsEvents = NotificationsEvent();

  final NotificationService _notificationService = NotificationService();

  final _purchaseDataService = PurchaseDataService();

  //add
  Future<String> addEventCall(Event event) async {
    // Add Event
    String eid = await _eventDataService.addEvent(event);
    return eid;
  }

  Future<void> addEventTrainers(
      String eventId,
      List<Usuario> eventTrainers,
      BuildContext context,
      String currentUserId,
      ReceivedNotification notificationBefore) async {
    // Add Event Members
    for (var i = 0; i < eventTrainers.length; i++) {
      var user = eventTrainers[i];
      // Firebase Call
      if (user.id != currentUserId) {
        await _eventDataService.addUserToEvent(eventId, user.id!, "", true);
      } else {
        await _eventDataService.addUserToEvent(eventId, user.id!, "");
      }

      // Local Notifications
      await _notificationsEvents.addEventLocalNotificationsCallCubit(
          context,
          eventId,
          user.id!,
          user.isTrainer!,
          currentUserId,
          notificationBefore,
          notificationBefore);
    }
  }

  Future<void> addEventCurrentTrainer(
      String eventId,
      String trainerId,
      BuildContext context,
      String currentUserId,
      ReceivedNotification notificationBefore) async {
    // Add Event Members
    await _eventDataService.addUserToEvent(eventId, trainerId, "");
    // Local Notifications
    await _notificationsEvents.addEventLocalNotificationsCallCubit(
        context,
        eventId,
        trainerId,
        true,
        currentUserId,
        notificationBefore,
        notificationBefore);
  }

  Future<void> addEventClients(
      String eventId,
      List<Usuario> eventClients,
      List<Bono> selectedBonos,
      BuildContext context,
      String currentUserId,
      String currentBrandId,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationsAfter) async {
    // Add Event Members
    for (var i = 0; i < eventClients.length; i++) {
      var user = eventClients[i];
      // Firebase Call
      await _eventDataService.addUserToEvent(
          eventId, user.id!, user.purchaseId!, true);
      if (selectedBonos.isNotEmpty) {
        await _purchaseDataService.addEventToPurchase(
            user.purchaseId!, eventId);
      }
      // Notifications Service, this also send Notifications to Trainers
      _notificationService.userJoinEvent(user.id!, currentBrandId, eventId);
      //JMF_AddUser_End

      // Local Notifications
      await _notificationsEvents.addEventLocalNotificationsCallCubit(
          context,
          eventId,
          user.id!,
          user.isTrainer!,
          currentUserId,
          notificationBefore,
          notificationsAfter);
    }
  }

  Future<void> assignTrainers(
      BuildContext context,
      Event oldEvent,
      Event event,
      String currentUserId,
      ReceivedNotification notificationBefore) async {
    Set<String?> oldIds =
        oldEvent.selectedTrainersList!.map((usuario) => usuario.id).toSet();
    Set<String?> newIds =
        event.selectedTrainersList!.map((usuario) => usuario.id).toSet();

    Set<String?> idsToAdd = newIds.difference(oldIds);
    Set<String?> idsToRemove = oldIds.difference(newIds);
    Set<String?> idsMatched = oldIds.intersection(newIds);

    List<Usuario> trainersToAdd = idsToAdd
        .map((id) => event.selectedTrainersList!
            .firstWhere((usuario) => usuario.id == id))
        .cast<Usuario>()
        .toList();
    List<Usuario> trainersToRemove = idsToRemove
        .map((id) => oldEvent.selectedTrainersList!
            .firstWhere((usuario) => usuario.id == id))
        .cast<Usuario>()
        .toList();
    List<Usuario> matchedTrainers = idsMatched
        .map((id) => event.selectedTrainersList!
            .firstWhere((usuario) => usuario.id == id))
        .cast<Usuario>()
        .toList();

    // Compare Current Members vs Original Members
    /// Start With Trainers
    for (int i = 0; i < matchedTrainers.length; i++) {
      var user = matchedTrainers[i];

      print("Trainer Matched ${user.id}");
      if (oldEvent.startDate! != event.startDate!) {
        // Remove Old Local Notification
        await _notificationsEvents.deleteEventLocalNotificationsCall(
            event.id!, user.id!, currentUserId);
        // Add updated ones now
        await _notificationsEvents.addEventLocalNotificationsCallCubit(
            context,
            event.id!,
            user.id!,
            user.isTrainer!,
            currentUserId,
            notificationBefore,
            notificationBefore);
      }
    }

    /// Handle Trainers Not Matched
    // Original Trainers Not Matched means that they have been removed from Event
    for (int i = 0; i < trainersToRemove.length; i++) {
      var user = trainersToRemove[i];
      // Remove Trainer From Event
      await _eventDataService.deleteUserFromEvent(event.id!, user.id!);
      // Remove Event Local Notifications
      await _notificationsEvents.deleteEventLocalNotificationsCall(
          event.id!, user.id!, currentUserId);
      print("Trainer Removed ${user.id}");
    }

    /// Handle Trainers Added
    // Trainers Added Not Matched means that they have added to the Event
    for (int i = 0; i < trainersToAdd.length; i++) {
      var user = trainersToAdd[i];
      // Add Trainer to Event
      if (user.id != currentUserId) {
        await _eventDataService.addUserToEvent(event.id!, user.id!, "", true);
      } else {
        await _eventDataService.addUserToEvent(event.id!, user.id!, "");
      }
      // Add Event Local Notifications
      await _notificationsEvents.addEventLocalNotificationsCallCubit(
          context,
          event.id!,
          user.id!,
          user.isTrainer!,
          currentUserId,
          notificationBefore,
          notificationBefore);
      print("Trainer Added ${user.id}");
    }
  }

  Future<void> assignClients(
      BuildContext context,
      Event oldEvent,
      Event event,
      List<Bono> selectedBonos,
      String currentBrandId,
      String currentUserId,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationsAfter) async {
    Set<String?> oldIds =
        oldEvent.joinedMembersList!.map((usuario) => usuario.id).toSet();
    Set<String?> newIds =
        event.joinedMembersList!.map((usuario) => usuario.id).toSet();

    Set<String?> idsToAdd = newIds.difference(oldIds);
    Set<String?> idsToRemove = oldIds.difference(newIds);
    Set<String?> idsMatched = oldIds.intersection(newIds);

    List<Usuario> clientsToAdd = idsToAdd
        .map((id) =>
            event.joinedMembersList!.firstWhere((usuario) => usuario.id == id))
        .cast<Usuario>()
        .toList();
    List<Usuario> clientsToRemove = idsToRemove
        .map((id) => oldEvent.joinedMembersList!
            .firstWhere((usuario) => usuario.id == id))
        .cast<Usuario>()
        .toList();
    List<Usuario> matchedClients = idsMatched
        .map((id) =>
            event.joinedMembersList!.firstWhere((usuario) => usuario.id == id))
        .cast<Usuario>()
        .toList();

    for (int i = 0; i < matchedClients.length; i++) {
      var user = matchedClients[i];

      print("Client Matched ${user.id}");
      if (oldEvent.startDate! != event.startDate!) {
        // Remove Old Local Notification
        await _notificationsEvents.deleteEventLocalNotificationsCall(
            event.id!, user.id!, currentUserId);
        // Add updated ones now
        await _notificationsEvents.addEventLocalNotificationsCallCubit(
            context,
            event.id!,
            user.id!,
            user.isTrainer!,
            currentUserId,
            notificationBefore,
            notificationsAfter);
      }
    }
    // Handle Clients Not Matched
    // Original Clients Not Matched means that they have been removed from Event
    for (int i = 0; i < clientsToRemove.length; i++) {
      var user = clientsToRemove[i];
      // Remove Client From Event
      await _eventDataService.deleteUserFromEvent(event.id!, user.id!);
      // Remove Client From Purchase
      //JMF_AddUser_BEGIN
      if (selectedBonos.isNotEmpty) {
        await _purchaseDataService.deletedPurchaseUserFromEvent(
            user, event.id!);
      }
      //JMF_AddUser_END
      // Send Client Left Event
      _notificationService.userLeaveEvent(user.id!, currentBrandId, event.id!);
      // Remove Event Local Notifications
      await _notificationsEvents.deleteEventLocalNotificationsCall(
          event.id!, user.id!, currentUserId);
      print("Client Removed ${user.id}");
    }

    //JMF_AddUser_Begin
    //Update purchase
    if (selectedBonos.isNotEmpty) {
      await _updateUserPurchase(event);
    }
    //JMF_AddUser_End

    // Handle Clients Added
    // Clients Added Not Matched means that they have added to the Event
    for (int i = 0; i < clientsToAdd.length; i++) {
      var user = clientsToAdd[i];
      // Add Clients to Event
      await _eventDataService.addUserToEvent(
          event.id!, user.id!, user.purchaseId!, true);

      //JMF_AddUser_BEGIN
      if (selectedBonos.isNotEmpty) {
        await _purchaseDataService.addEventToPurchase(
            clientsToAdd[i].purchaseId!, event.id!);
      }
      //JMF_AddUser_END

      // Add Event Local Notifications
      await _notificationsEvents.addEventLocalNotificationsCallCubit(
          context,
          event.id!,
          user.id!,
          user.isTrainer!,
          currentUserId,
          notificationBefore,
          notificationsAfter);
      print("Client Added ${user.id}");
    }
  }

  Future<void> updateBonos(
      List<Bono> originalBonos, List<Bono> newBonos, String eventId) async {
    bool isDifferent = false;

    if (originalBonos.length != newBonos.length) {
      isDifferent = true;
    } else {
      bool hasNewBono = newBonos.any((bono) =>
          !originalBonos.any((originalBono) => originalBono.id == bono.id));

      bool hasRemovedBono = originalBonos.any((originalBono) =>
          !newBonos.any((bono) => bono.id == originalBono.id));

      isDifferent = hasNewBono || hasRemovedBono;
    }
    if (isDifferent) {
      await _eventDataService.updateEventBonosObject(eventId, newBonos);
    }
  }

  Future<void> _updateUserPurchase(Event event) async {
    for (int i = 0; i < event.joinedMembersList!.length; ++i) {
      await _eventDataService.updateEventUserPurchase(
          event.id!,
          event.joinedMembersList![i].id!,
          event.joinedMembersList![i].purchaseId!);
    }
  }
}
