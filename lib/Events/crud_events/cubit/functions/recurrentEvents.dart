import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/functions/addEvents.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/functions/notificationsEvents.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:uuid/uuid.dart';

class RecurrentEvents {
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();

  final _addEvents = AddEventFunctions();
  final _notificationsEvents = NotificationsEvent();

  Future<String> addOneRecurrentEvent(
      BuildContext context,
      DateTime startDate,
      String eventGroupId,
      Event _event,
      bool isPrivate,
      Brand currentBrandLoc,
      String currentUserId,
      List<Bono> selectedBonos,
      List<String> bonos,
      List<String> trainers,
      String titleNot,
      String bodyNot) async {
    String eventImageUrl;

    // Get Random Photo if no Image Selected
    eventImageUrl =
        await _brandDataService.getRandomBrandPhoto(currentBrandLoc.id!);

    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(startDate);

    // Creating Event Object
    Event event = Event(
      id: const Uuid().v1(),
      isPrivate: isPrivate,
      title: _event.title,
      description: _event.description,
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
      duration: _event.duration!,
      locationId: _event.location!.id,
      numClients: _event.joinedMembersList!.length,
      numTrainers: _event.selectedTrainersList!.length,
      maxMembers: _event.maxMembers,
      joinedMembersList: _event.joinedMembersList!,
      selectedTrainersList: _event.selectedTrainersList!,
      eventGroupId: eventGroupId,
      bonos: selectedBonos,
      location: _event.location!,
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
          _notificationsEvents.setEventNotificationBefore(
              event, titleNot, bodyNot));
      trainers.remove(currentUserId);
    }

    _eventDataService.addEventRecurrent(
        event,
        bonos,
        trainers,
        _notificationsEvents.setEventNotificationBefore(
            event, titleNot, bodyNot));

    // Add Event

    /*  String eventId = await _addEventCall(event);

    // Add Event Members
    await _addEventTrainers(eventId, event.selectedTrainersList!, context);

    // Add Event Bonos
    // _addEventBonosCall(eventId, selectedBonos);*/

    return eventId;
  }
}
