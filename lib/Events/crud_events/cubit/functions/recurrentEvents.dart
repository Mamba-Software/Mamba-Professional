import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/functions/addEvents.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/functions/notificationsEvents.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';

class RecurrentEvents {
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();

  final _addEvents = AddEventFunctions();
  final _notificationsEvents = NotificationsEvent();

  Future<String> addOneRecurrentEvent(
      BuildContext context,
      DateTime startDate,
      String eventGroupId,
      Event eventVariable,
      bool isPrivate,
      Brand currentBrandLoc,
      String currentUserId,
      List<Bono> selectedBonos,
      List<String> bonos,
      List<String> trainers,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    String eventImageUrl;
    List<String> trainersNoCurrent = List.from(trainers);

    // Get Random Photo if no Image Selected
    eventImageUrl =
        await _brandDataService.getRandomBrandPhoto(currentBrandLoc.id!);

    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(startDate);

    // Creating Event Object
    Event event = Event(
      isPrivate: isPrivate,
      title: eventVariable.title,
      description: eventVariable.description,
      imageUrl: eventImageUrl,
      brandID: currentBrandLoc.id,
      creatorID: currentUserId,
      doneAt: doneAt,
      createdAt: Timestamp.now(),
      year: startDate.year.toString(),
      month: startDate.month.toString(),
      day: startDate.day.toString(),
      hour: startDate.hour.toString(),
      minute: startDate.minute.toString(),
      duration: eventVariable.duration!,
      locationId: eventVariable.location!.id,
      numClients: eventVariable.joinedMembersList!.length,
      numTrainers: eventVariable.selectedTrainersList!.length,
      maxMembers: eventVariable.maxMembers,
      joinedMembersList: eventVariable.joinedMembersList!,
      selectedTrainersList: eventVariable.selectedTrainersList!,
      eventGroupId: eventGroupId,
      bonos: selectedBonos,
      location: eventVariable.location!,
      brandName: currentBrandLoc.name,
      brandLogo: currentBrandLoc.logoUrl,
      startDate: startDate,
    );

    String eventId = await _addEvents.addEventCall(event);

    event.id = eventId;

    if (trainers.contains(currentUserId)) {
      await _addEvents.addEventCurrentTrainer(
          eventId,
          currentUserId,
          context,
          currentUserId,
          _notificationsEvents.setEventNotificationBeforeRecurrent(
              event, notificationBefore.title!, notificationBefore.body!));
      trainersNoCurrent.remove(currentUserId);
      //trainers.remove(currentUserId);
    }

    _eventDataService.addEventRecurrent(
        event,
        bonos,
        trainersNoCurrent,
        _notificationsEvents.setEventNotificationBeforeRecurrent(
            event, notificationBefore.title!, notificationBefore.body!));

    // Add Event

    /*  String eventId = await _addEventCall(event);

    // Add Event Members
    await _addEventTrainers(eventId, event.selectedTrainersList!, context);

    // Add Event Bonos
    // _addEventBonosCall(eventId, selectedBonos);*/

    return eventId;
  }
}
