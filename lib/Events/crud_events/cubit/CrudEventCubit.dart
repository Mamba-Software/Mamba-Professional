import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Recurrent.dart';
import 'package:mamba_castelldefels/Events/crud_events/read_event/cubit/ReadEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
part 'CrudEventState.dart';

class CrudEventCubit extends Cubit<CrudEventLoaded> {
  final _eventDataService = EventDataService();
  final _locationDataService = LocationDataService();
  final _purchaseDataService = PurchaseDataService();

  // Notification Services
  final NotificationService _notificationService = NotificationService();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  List<Bono> eventBonos = [];

  Location location = Location();
  List<Bono> allBonos = [];
  bool isBeforeEdit = true;
  final _brandDataService = BrandDataService();
  bool errorBonos = false;

  CrudEventCubit()
      : super(CrudEventLoaded(Event(), Event(), false, true,
            const [false, false, false], false, true, 100, false, false));

  Future<void> populateNewEvent(Event event) async {
    state.oldEvent.setBasicData = event;
    state.newEvent.setBasicData = event;

    state.oldEvent.id = event.id;
    state.newEvent.id = event.id;

    state.oldEvent.startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    state.newEvent.startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );

    isBeforeEdit = true;
    if (state.newEvent.startDate!.isBefore(DateTime.now())) {
      isBeforeEdit = false;
    }

    state.oldEvent.location = event.location;
    state.newEvent.location = event.location;

    state.oldEvent.selectedTrainersList = event.selectedTrainersList!;
    state.oldEvent.maxMembers = event.maxMembers;
    state.oldEvent.joinedMembersList = event.joinedMembersList!;

    state.newEvent.selectedTrainersList = event.selectedTrainersList!;
    state.newEvent.maxMembers = event.maxMembers;
    state.newEvent.joinedMembersList = event.joinedMembersList!;

    await _getAllBonos();
    eventBonos = List.from(event.bonos);
    state.oldEvent.eventBonos = _setEventBonosMap();
    state.newEvent.eventBonos = _setEventBonosMap();

    state.oldEvent.isRecurrent = event.eventGroupId != null;
    state.newEvent.isRecurrent = event.eventGroupId != null;

    emit(state.copyWith(
        oldEvent: state.oldEvent,
        newEvent: state.newEvent,
        isLoaded: true,
        isNew: false,
        isPrivate: event.isPrivate,
        isValidated:
            _validateEvent(state.newEvent, event.isPrivate!, isBeforeEdit),
        isBeforeEdit: isBeforeEdit,
        isWorking: 100,
        mustUpdateParent: false,
        errorBonos: errorBonos));
  }

  Future<void> createNewEvent(DateTime? dateTime, bool isPrivate) async {
    late Event event = Event();
    DateTime startDate = DateTime.now();
    List<Usuario> _selectedTrainer = [];
    eventBonos = [];

    event.title = ""; // = event.copyWith(title: '');
    event.description = ""; // = event.copyWith(description: '');
    event.location = await _getLocation(currentBrand.baseLocation!);
    //event.copyWith(location: await getLocation(currentBrand.baseLocation!));
    await _getAllBonos();
    event.eventBonos = _setEventBonosMap();

    if (dateTime == null || dateTime.isBefore(DateTime.now())) {
      startDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startDate.hour + 1,
        0,
      );
    } else {
      startDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        0,
      );
    }
    event.startDate =
        startDate; // = event.copyWith(startDate: state.newEvent.startDate = startDate);
    event.duration = 1; // = event.copyWith(duration: 1);
    _selectedTrainer.add(currentUser);
    event.selectedTrainersList = List.from(_selectedTrainer);
    event.joinedMembersList = []; // = event.copyWith(joinedMembersList!: []);
    event.maxMembers = 1; // event.copyWith(maxMembers: 1);
    event.isRecurrent = false;
    Recurrent recurrent = Recurrent(
      oneWeek: event.startDate!.add(const Duration(days: 7)),
      twoWeek: event.startDate!.add(const Duration(days: 14)),
      oneMonth: event.startDate!.add(const Duration(days: 28)),
      twoMonth: event.startDate!.add(const Duration(days: 56)),
      threeMonth: event.startDate!.add(const Duration(days: 74)),
      values: [false, false, false, false, false, false, false],
      value: 1,
    );

    event.recurrent = recurrent;

    emit(state.copyWith(
        newEvent: event,
        oldEvent: event,
        isLoaded: true,
        isNew: true,
        isPrivate: isPrivate,
        isValidated: _validateEvent(event, isPrivate, true),
        isBeforeEdit: true,
        isWorking: 100,
        mustUpdateParent: false,
        errorBonos: errorBonos));
  }

  void emitWorkingState(double workProgress) {
    emit(state.copyWith(isWorking: workProgress));
  }

  Future<void> addEventFunction(
      BuildContext context, Event _event, bool isPrivate) async {
    emitWorkingState(10);
    await _addEventFunction(context, _event, isPrivate);
  }

  Future<void> _addEventFunction(
      BuildContext context, Event _event, bool isPrivate) async {
    String eventImageUrl;

    //Event Bonos
    List<Bono> selectedBonos = _event.eventBonos!.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    mixpanel!.timeEvent("add_event_completed");

    // Get Random Photo if no Image Selected

    eventImageUrl =
        await _brandDataService.getRandomBrandPhoto(currentBrand.id!);

    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(_event.startDate!);
    print(_event.title);

    if (!_event.isRecurrent!) {
      // Creating Event Object
      Event event = Event(
        isPrivate: isPrivate,
        title: _event.title,
        description: _event.description,
        imageUrl: eventImageUrl,
        doneAt: doneAt,
        createdAt: Timestamp.now(),
        year: _event.startDate!.year.toString(),
        month: _event.startDate!.month.toString(),
        day: _event.startDate!.day.toString(),
        hour: _event.startDate!.hour.toString(),
        minute: _event.startDate!.minute.toString(),
        duration: _event.duration!,
        locationId: _event.location!.id,
        numClients: _event.joinedMembersList!.length,
        numTrainers: _event.selectedTrainersList!.length,
        maxMembers: _event.maxMembers,
        joinedMembersList: _event.joinedMembersList!,
        selectedTrainersList: _event.selectedTrainersList!,
      );
      // Add Event
      String eventId = await _addEventCall(event);
      emitWorkingState(40);
      // Add Event Members
      await _addEventTrainers(eventId, event.selectedTrainersList!, context);
      emitWorkingState(70);
      await _addEventClients(
          eventId, event.joinedMembersList!, selectedBonos, context);

      emitWorkingState(80);
      // Add Event Bonos
      _addEventBonosCall(eventId, selectedBonos);
      emitWorkingState(90);
      mixpanel!.track('add_event_completed', properties: {
        'descriptionLength': event.description!.length.toString(),
        'isPrivate': event.isPrivate,
        'isRecurrent': false,
        'doneAt': event.doneAt!.toDate().toString(),
        'duration': event.duration.toString(),
        'numClients': event.numClients!.toString(),
        'numTrainers': event.numTrainers!.toString(),
        'maxMembers': event.maxMembers!.toString(),
      });
      // } else {
      //   // Recurrent total
      //   int days = values.where((item) => item == true).length;
      //   totalEvents = days * _value;
      //   if (_value == 3) {
      //     totalEvents += days;
      //   }
      //   // Event Group Id
      //   String eventGroupId = const Uuid().v1();
      //   // First the First Event
      //   Event event = Event(
      //     isPrivate: false,
      //     eventGroupId: eventGroupId,
      //     title: titleController.text,
      //     description: descriptionController.text,
      //     imageUrl: eventImageUrl,
      //     doneAt: doneAt,
      //     createdAt: Timestamp.now(),
      //     year: startDate.year.toString(),
      //     month: startDate.month.toString(),
      //     day: startDate.day.toString(),
      //     hour: startDate.hour.toString(),
      //     minute: startDate.minute.toString(),
      //     duration: double.parse(duration),
      //     locationId: location.id,
      //     numClients: brandClientsSelected.length,
      //     numTrainers: brandTrainersSelected.length,
      //     maxMembers: eventMaxMembers,
      //   );
      //   // Add Event
      //   String eventId = await _addEventCall(event);
      //   // Add Event Members
      //   await _addEventMembersCall(eventId, eventMembers);
      //   // Add Event Bonos
      //   _addEventBonosCall(eventId, selectedBonos);
      //   // Start Recurrence
      //   List<String> groupEventsIds = [eventId];
      //   var tempDate = startDate.add(const Duration(days: 1));
      //   var tempTimestamp = Timestamp.fromDate(tempDate);
      //   var weekDay = tempDate.weekday;
      //   if (_value == 1) {
      //     // One Week
      //     for (var i = 0; i < 6; i++) {
      //       if (values[weekDay - 1]!) {
      //         // Updating Loading Text
      //         setState(() {
      //           isRecurrentLoadingText = AppLocalizations.of(context)!.creating +
      //               " " +
      //               AppLocalizations.of(context)!.events.toLowerCase() +
      //               "... (" +
      //               currentEvent.toString() +
      //               "/" +
      //               totalEvents.toString() +
      //               ")";
      //         });
      //         currentEvent += 1;
      //         // Change Image Url if IsRecurrent is Selected
      //         if (isRandomImage) {
      //           eventImageUrl =
      //               await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
      //         }
      //         // Event Object
      //         event = Event(
      //           isPrivate: false,
      //           eventGroupId: eventGroupId,
      //           title: titleController.text,
      //           description: descriptionController.text,
      //           imageUrl: eventImageUrl,
      //           doneAt: tempTimestamp,
      //           createdAt: Timestamp.now(),
      //           year: tempDate.year.toString(),
      //           month: tempDate.month.toString(),
      //           day: tempDate.day.toString(),
      //           hour: tempDate.hour.toString(),
      //           minute: tempDate.minute.toString(),
      //           duration: double.parse(duration),
      //           locationId: location.id,
      //           numClients: brandClientsSelected.length,
      //           numTrainers: brandTrainersSelected.length,
      //           maxMembers: eventMaxMembers,
      //         );
      //         // Add Event
      //         String eventId = await _addEventCall(event);
      //         // Add Event to Group Events
      //         groupEventsIds.add(eventId);
      //         // Add Event Members
      //         await _addEventMembersCall(eventId, eventMembers);
      //         // Add Event Bonos
      //         _addEventBonosCall(eventId, selectedBonos);
      //       }
      //       tempDate = tempDate.add(const Duration(days: 1));
      //       tempTimestamp = Timestamp.fromDate(tempDate);
      //       weekDay = tempDate.weekday;
      //     }
      //   } else if (_value == 2) {
      //     // Two Weeks
      //     for (var i = 0; i < 13; i++) {
      //       if (values[weekDay - 1]!) {
      //         // Updating Loading Text
      //         setState(() {
      //           isRecurrentLoadingText = AppLocalizations.of(context)!.creating +
      //               " " +
      //               AppLocalizations.of(context)!.events.toLowerCase() +
      //               "... (" +
      //               currentEvent.toString() +
      //               "/" +
      //               totalEvents.toString() +
      //               ")";
      //         });
      //         currentEvent += 1;
      //         // Change Image Url if IsRecurrent is Selected
      //         if (isRandomImage) {
      //           eventImageUrl =
      //               await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
      //         }
      //         // Event Object
      //         event = Event(
      //           isPrivate: false,
      //           eventGroupId: eventGroupId,
      //           title: titleController.text,
      //           description: descriptionController.text,
      //           imageUrl: eventImageUrl,
      //           doneAt: tempTimestamp,
      //           createdAt: Timestamp.now(),
      //           year: tempDate.year.toString(),
      //           month: tempDate.month.toString(),
      //           day: tempDate.day.toString(),
      //           hour: tempDate.hour.toString(),
      //           minute: tempDate.minute.toString(),
      //           duration: double.parse(duration),
      //           locationId: location.id,
      //           numClients: brandClientsSelected.length,
      //           numTrainers: brandTrainersSelected.length,
      //           maxMembers: eventMaxMembers,
      //         );
      //         // Add Event
      //         String eventId = await _addEventCall(event);
      //         // Add Event to Group Events
      //         groupEventsIds.add(eventId);
      //         // Add Event Members
      //         await _addEventMembersCall(eventId, eventMembers);
      //         // Add Event Bonos
      //         _addEventBonosCall(eventId, selectedBonos);
      //       }
      //       tempDate = tempDate.add(const Duration(days: 1));
      //       tempTimestamp = Timestamp.fromDate(tempDate);
      //       weekDay = tempDate.weekday;
      //     }
      //   } else if (_value == 3) {
      //     // One Month
      //     for (var i = 0; i < 27; i++) {
      //       if (values[weekDay - 1]!) {
      //         // Updating Loading Text
      //         setState(() {
      //           isRecurrentLoadingText = AppLocalizations.of(context)!.creating +
      //               " " +
      //               AppLocalizations.of(context)!.events.toLowerCase() +
      //               "... (" +
      //               currentEvent.toString() +
      //               "/" +
      //               totalEvents.toString() +
      //               ")";
      //         });
      //         currentEvent += 1;
      //         // Change Image Url if IsRecurrent is Selected
      //         if (isRandomImage) {
      //           eventImageUrl =
      //               await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
      //         }
      //         // Event Object
      //         event = Event(
      //           isPrivate: false,
      //           eventGroupId: eventGroupId,
      //           title: titleController.text,
      //           description: descriptionController.text,
      //           imageUrl: eventImageUrl,
      //           doneAt: tempTimestamp,
      //           createdAt: Timestamp.now(),
      //           year: tempDate.year.toString(),
      //           month: tempDate.month.toString(),
      //           day: tempDate.day.toString(),
      //           hour: tempDate.hour.toString(),
      //           minute: tempDate.minute.toString(),
      //           duration: double.parse(duration),
      //           locationId: location.id,
      //           numClients: brandClientsSelected.length,
      //           numTrainers: brandTrainersSelected.length,
      //           maxMembers: eventMaxMembers,
      //         );
      //         // Add Event
      //         String eventId = await _addEventCall(event);
      //         // Add Event to Group Events
      //         groupEventsIds.add(eventId);
      //         // Add Event Members
      //         await _addEventMembersCall(eventId, eventMembers);
      //         // Add Event Bonos
      //         _addEventBonosCall(eventId, selectedBonos);
      //       }
      //       tempDate = tempDate.add(const Duration(days: 1));
      //       tempTimestamp = Timestamp.fromDate(tempDate);
      //       weekDay = tempDate.weekday;
      //     }
      //   }
      //   // Create Entry in /Event Groups
      //   await _eventDataService.addRecurrentEventGroup(
      //       eventGroupId, groupEventsIds);
      //   mixpanel!.track('add_event_completed', properties: {
      //     'descriptionLength': event.description!.length.toString(),
      //     'isPrivate': false,
      //     'isRecurrent': true,
      //     'doneAt': event.doneAt!.toDate().toString(),
      //     'duration': event.duration.toString(),
      //     'numClients': event.numClients!.toString(),
      //     'numTrainers': event.numTrainers!.toString(),
      //     'maxMembers': event.maxMembers!.toString(),
      //   });
      // }
      resetNewEvent();
    }
  }

  Future<void> updateEventFunction(
      BuildContext context, Event _event, Event _oldEvent) async {
    emit(state.copyWith(isWorking: 0));
    await _updateEventFunction(context, _event, _oldEvent);
  }

  Future<void> _updateEventFunction(
      BuildContext context, Event _event, Event _oldEvent) async {
    String eventImageUrl;

    print(state.oldEvent.title);
    print(state.newEvent.title);

    mixpanel!.timeEvent("edit_event_completed");

    //Event Bonos
    List<Bono> selectedBonos = _event.eventBonos!.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    eventImageUrl = _event.imageUrl!;

    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(_event.startDate!);
    // Creating Event Object
    Event event = Event(
      id: _oldEvent.id,
      isPrivate: _oldEvent.isPrivate,
      title: _event.title,
      description: _event.description,
      imageUrl: eventImageUrl,
      doneAt: doneAt,
      createdAt: Timestamp.now(),
      year: _event.startDate!.year.toString(),
      month: _event.startDate!.month.toString(),
      day: _event.startDate!.day.toString(),
      hour: _event.startDate!.hour.toString(),
      minute: _event.startDate!.minute.toString(),
      duration: _event.duration!,
      locationId: _event.location!.id,
      numClients: _event.joinedMembersList!.length,
      numTrainers: _event.selectedTrainersList!.length,
      maxMembers: _event.maxMembers,
      joinedMembersList: _event.joinedMembersList!,
      selectedTrainersList: _event.selectedTrainersList!,
      startDate: _event.startDate!,
    );

    // Update Event
    await _eventDataService.updateEvent(event);

    // Update Event Bonos
    List<Bono> originalBonos = [];

    for (Bono bono in _oldEvent.bonos) {
      originalBonos.add(bono);
    }

    if (!selectedBonos.every((bono) =>
        originalBonos.any((originalBono) => originalBono.id == bono.id))) {
      await _eventDataService.updateEventBonosObject(event.id!, selectedBonos);
    }

    // Update Event Location
    if (event.locationId! != _oldEvent.locationId!) {
      await _eventDataService.updateEventLocation(
          event.id!, event.locationId!, _oldEvent.locationId!);
    }

    await _assignTrainers(context, _oldEvent, event);

    await _assignClients(context, _oldEvent, event, selectedBonos);

    mixpanel!.track('edit_event_completed', properties: {
      'descriptionLength': event.description!.length.toString(),
      'isPrivate': event.isPrivate,
      'isRecurrent': false,
      'doneAt': event.doneAt!.toDate().toString(),
      'duration': event.duration.toString(),
      'numClients': event.numClients!.toString(),
      'numTrainers': event.numTrainers!.toString(),
      'maxMembers': event.maxMembers!.toString(),
    });

    updateEvent();
  }

  Future<void> _assignTrainers(
      BuildContext context, Event _oldEvent, Event event) async {
    Set<String?> oldIds =
        _oldEvent.selectedTrainersList!.map((usuario) => usuario.id).toSet();
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
        .map((id) => _oldEvent.selectedTrainersList!
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

      print("Trainer Matched " + user.id.toString());
      if (_oldEvent.startDate! != event.startDate!) {
        // Remove Old Local Notification
        await _deleteEventLocalNotificationsCall(event.id!, user.id!);
        // Add updated ones now
        await _addEventLocalNotificationsCall(
            context, event.id!, user.id!, user.isTrainer!);
      }
    }

    /// Handle Trainers Not Matched
    // Original Trainers Not Matched means that they have been removed from Event
    for (int i = 0; i < trainersToRemove.length; i++) {
      var user = trainersToRemove[i];
      // Remove Trainer From Event
      await _eventDataService.deleteUserFromEvent(event.id!, user.id!);
      // Remove Event Local Notifications
      await _deleteEventLocalNotificationsCall(event.id!, user.id!);
      print("Trainer Removed " + user.id.toString());
    }

    /// Handle Trainers Added
    // Trainers Added Not Matched means that they have added to the Event
    for (int i = 0; i < trainersToAdd.length; i++) {
      var user = trainersToAdd[i];
      // Add Trainer to Event
      if (user.id != currentUser.id!) {
        await _eventDataService.addUserToEvent(event.id!, user.id!, "", true);
      } else {
        await _eventDataService.addUserToEvent(event.id!, user.id!, "");
      }
      // Add Event Local Notifications
      await _addEventLocalNotificationsCall(
          context, event.id!, user.id!, user.isTrainer!);
      print("Trainer Added " + user.id.toString());
    }
  }

  Future<void> _assignClients(BuildContext context, Event _oldEvent,
      Event event, List<Bono> selectedBonos) async {
    Set<String?> oldIds =
        _oldEvent.joinedMembersList!.map((usuario) => usuario.id).toSet();
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
        .map((id) => _oldEvent.joinedMembersList!
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

      print("Client Matched " + user.id.toString());
      if (_oldEvent.startDate! != event.startDate!) {
        // Remove Old Local Notification
        await _deleteEventLocalNotificationsCall(event.id!, user.id!);
        // Add updated ones now
        await _addEventLocalNotificationsCall(
            context, event.id!, user.id!, user.isTrainer!);
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
      _notificationService.userLeaveEvent(
          user.id!, currentBrand.id!, event.id!);
      // Remove Event Local Notifications
      await _deleteEventLocalNotificationsCall(event.id!, user.id!);
      print("Client Removed " + user.id.toString());
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
      await _addEventLocalNotificationsCall(
          context, event.id!, user.id!, user.isTrainer!);
      print("Client Added " + user.id.toString());
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

  void resetNewEvent() {
    List<bool> validations = [false, false, false];
    emit(state.copyWith(
        oldEvent: Event(),
        newEvent: Event(),
        isLoaded: false,
        isNew: true,
        isPrivate: false,
        isValidated: validations,
        isBeforeEdit: true,
        isWorking: 100,
        mustUpdateParent: false));
  }

  void updateEvent() {
    List<bool> validations = [false, false, false];
    emit(state.copyWith(
        oldEvent: Event(),
        newEvent: Event(),
        isLoaded: false,
        isNew: true,
        isPrivate: false,
        isValidated: validations,
        isBeforeEdit: true,
        isWorking: 100,
        mustUpdateParent: true));
  }

  void setMustUpdateToFalse() {
    emit(state.copyWith(mustUpdateParent: false));
  }

  Future<void> editEventInfo(var varToChange, EditEventType editEventType,
      [Bono? bono, String? textRefetence]) async {
    late Event event = Event();
    List<bool> validations = [
      state.isValidated[0],
      state.isValidated[1],
      state.isValidated[2]
    ];
    errorBonos = state.errorBonos;
    switch (editEventType) {
      case EditEventType.title:
        event = state.newEvent.copyWith(title: varToChange);
        validations[0] =
            _validateTitleDescription(varToChange, state.isPrivate);
        break;
      case EditEventType.description:
        event = state.newEvent.copyWith(description: varToChange);
        break;
      case EditEventType.location:
        event =
            state.newEvent.copyWith(location: await _getLocation(varToChange));
        break;
      case EditEventType.bonos:
        if (varToChange == 'AllBonos') {
          event = state.newEvent.copyWith(eventBonos: _setAllTrue());
        } else {
          event = state.newEvent
              .copyWith(eventBonos: _setBonoSelectedUnselected(bono!));
        }
        break;
      case EditEventType.startDate:
        DateTime startDate = DateTime(
          varToChange.year,
          varToChange.month,
          varToChange.day,
          state.newEvent.startDate!.hour,
          state.newEvent.startDate!.minute,
        );
        event = state.newEvent.copyWith(
            startDate: state.newEvent.startDate = startDate,
            recurrent: updateRecurrency(
                startDate,
                state.newEvent.isRecurrent!,
                state.newEvent.recurrent!.value!,
                true,
                state.newEvent.recurrent!.values!,
                -1));
        validations[1] = _validateDateTimeDuration(event.startDate!,
            state.newEvent.duration!, state.isPrivate, state.isBeforeEdit);
        break;
      case EditEventType.time:
        DateTime startDate = DateTime(
          state.newEvent.startDate!.year,
          state.newEvent.startDate!.month,
          state.newEvent.startDate!.day,
          varToChange.hour,
          varToChange.minute,
        );
        event = state.newEvent.copyWith(
            startDate: state.newEvent.startDate = startDate,
            recurrent: updateRecurrency(
                startDate,
                state.newEvent.isRecurrent!,
                state.newEvent.recurrent!.value!,
                false,
                state.newEvent.recurrent!.values!,
                -1));
        validations[1] = _validateDateTimeDuration(event.startDate!,
            state.newEvent.duration!, state.isPrivate, state.isBeforeEdit);
        break;
      case EditEventType.duration:
        event = state.newEvent.copyWith(duration: varToChange);
        validations[1] = _validateDateTimeDuration(state.newEvent.startDate!,
            varToChange, state.isPrivate, state.isBeforeEdit);
        break;
      case EditEventType.trainers:
        event = state.newEvent.copyWith(selectedTrainersList: varToChange);
        validations[2] = _validateStaff(varToChange, state.isPrivate);
        break;
      case EditEventType.clients:
        if (varToChange.isNotEmpty) {
          if (varToChange.any((client) => client.purchaseId != "")) {
            errorBonos = true;
          } else {
            errorBonos = false;
          }
        } else {
          errorBonos = false;
        }
        event = state.newEvent.copyWith(joinedMembersList: varToChange);
        break;
      case EditEventType.maxMembers:
        event = state.newEvent.copyWith(maxMembers: varToChange);
        break;
      case EditEventType.recurrent:
        event = state.newEvent.copyWith(
            isRecurrent: varToChange,
            recurrent: updateRecurrency(
                state.newEvent.startDate!,
                varToChange,
                state.newEvent.recurrent!.value!,
                true,
                state.newEvent.recurrent!.values!,
                -1));
        break;
      case EditEventType.dayFromRecurrent:
        event = state.newEvent.copyWith(
            recurrent: updateRecurrency(
                state.newEvent.startDate!,
                state.newEvent.isRecurrent!,
                state.newEvent.recurrent!.value!,
                false,
                state.newEvent.recurrent!.values!,
                varToChange));
        break;
      case EditEventType.valueRecurrent:
        event = state.newEvent.copyWith(
            recurrent: updateRecurrency(
                state.newEvent.startDate!,
                state.newEvent.isRecurrent!,
                varToChange,
                false,
                state.newEvent.recurrent!.values!,
                -1));
        break;

      /*
    oneWeek = pickedDateTemp.add(const Duration(days: 7));
    twoWeek = pickedDateTemp.add(const Duration(days: 14));
    oneMonth = pickedDateTemp.add(const Duration(days: 28));
    if (isRecurrent) {
      values = [false, false, false, false, false, false, false];
      values[startDate.weekday - 1] = true;
    }*/
    }
    emit(state.copyWith(
      newEvent: event,
      isValidated: validations,
      errorBonos: errorBonos,
    ));
  }

  Recurrent updateRecurrency(DateTime startDate, bool isRecurrent, int _value,
      bool checkValues, List<bool> _values, int newVal) {
    List<bool> values;
    if (checkValues) {
      if (isRecurrent) {
        values = [false, false, false, false, false, false, false];
        values[startDate.weekday - 1] = true;
      } else {
        values = [false, false, false, false, false, false, false];
      }
    } else {
      values = _values;
      if (newVal != -1) {
        values[newVal % 7] = !values[newVal % 7];
      }
    }
    Recurrent recurrent = Recurrent(
      oneWeek: startDate.add(const Duration(days: 7)),
      twoWeek: startDate.add(const Duration(days: 14)),
      oneMonth: startDate.add(const Duration(days: 28)),
      twoMonth: startDate.add(const Duration(days: 56)),
      threeMonth: startDate.add(const Duration(days: 74)),
      values: values,
      value: _value,
    );
    return recurrent;
  }

  @override
  void onChange(Change<CrudEventLoaded> change) {
    super.onChange(change);
    log(change.currentState.toString());
    log(change.nextState.toString());
  }

  //CREATE UPDATE EVENT FUNCTIONS

  Future<String> _addEventCall(Event event) async {
    // Add Event
    String eid = await _eventDataService.addEvent(event);
    return eid;
  }

  Future<void> _addEventTrainers(
      String eventId, List<Usuario> eventTrainers, BuildContext context) async {
    // Add Event Members
    for (var i = 0; i < eventTrainers.length; i++) {
      var user = eventTrainers[i];
      // Firebase Call
      if (user.id != currentUser.id!) {
        await _eventDataService.addUserToEvent(eventId, user.id!, "", true);
      } else {
        await _eventDataService.addUserToEvent(eventId, user.id!, "");
      }

      // Local Notifications
      await _addEventLocalNotificationsCall(
          context, eventId, user.id!, user.isTrainer!);
    }
  }

  Future<void> _addEventClients(String eventId, List<Usuario> eventClients,
      List<Bono> selectedBonos, BuildContext context) async {
    // Add Event Members
    for (var i = 0; i < eventClients.length; i++) {
      var user = eventClients[i];
      // Firebase Call
      await _eventDataService.addUserToEvent(
          eventId, user.id!, user.purchaseId!, true);
      if (selectedBonos.isNotEmpty) {
        await _purchaseDataService.addEventToPurchase(
            user.purchaseId!, eventId);

        // Notifications Service, this also send Notifications to Trainers
        _notificationService.userJoinEvent(user.id!, currentBrand.id!, eventId);
      }
      //JMF_AddUser_End

      // Local Notifications
      await _addEventLocalNotificationsCall(
          context, eventId, user.id!, user.isTrainer!);
    }
  }

  Future<void> _addEventLocalNotificationsCall(BuildContext context,
      String eventId, String userId, bool isTrainer) async {
    //PROBLEMS TODO SOLVE
    try {
      // Local Notifications Service
      if (userId == currentUser.id!) {
        await _localNotificationService.addEventLocalNotifications(
            context, eventId, isTrainer);
      } else {
        await _localNotificationService.addRemoteEventLocalNotifications(
            context, eventId, userId, isTrainer);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteEventLocalNotificationsCall(
      String eventId, String userId) async {
    if (userId == currentUser.id!) {
      await _localNotificationService.deleteEventLocalNotifications(eventId);
    } else {
      await _localNotificationService.deleteRemoteEventLocalNotifications(
          eventId, userId);
    }
  }

  //LOCATION FUNCTIONS

  Future<Location> _getLocation(String locationId) async {
    Location location = Location();
    location = await _locationDataService.getSingleLocation(locationId);
    location.initialPosition =
        CameraPosition(target: LatLng(location.latitude!, location.longitude!));
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(location.latitude!, location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    location.markers!.add(marker);

    return location;
  }

  Future<void> _addEventBonosCall(
      String eventId, List<Bono> selectedBonos) async {
    // Add Event Members
    await _eventDataService.addEventBonosObject(eventId, selectedBonos);
  }

  //BONOS FUNCTIONS

  Map<Bono, bool> _setBonoSelectedUnselected(Bono bono) {
    if (state.newEvent.eventBonos!.containsKey(bono)) {
      if (state.newEvent.eventBonos![bono] == true) {
        if (state.newEvent.joinedMembersList!
            .any((client) => client.purchaseId != "")) {
          errorBonos = true;
        } else {
          errorBonos = false;
          state.newEvent.eventBonos![bono] = !state.newEvent.eventBonos![bono]!;
        }
      } else {
        state.newEvent.eventBonos![bono] = !state.newEvent.eventBonos![bono]!;
      }
    }
    return state.newEvent.eventBonos!;
  }

  Map<Bono, bool> _setAllTrue() {
    state.newEvent.eventBonos?.updateAll((key, value) => true);
    return state.newEvent.eventBonos!;
  }

  Future<void> _getAllBonos() async {
    allBonos =
        await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
    allBonos.removeWhere((element) => element.isActive == false);
    allBonos.sort((a, b) {
      var aSessions = a.sessions;
      var bSessions = b.sessions;
      return aSessions!.compareTo(bSessions!);
    });
  }

  Map<Bono, bool> _setEventBonosMap() {
    final Map<Bono, bool> bonosMap = {};

    for (Bono bono in allBonos) {
      // Check if the current bono exists in eventBonos
      bool exists = eventBonos.any((eventBono) => eventBono.id! == bono.id!);
      // Set the value in the map
      bonosMap[bono] = exists;
    }
    return bonosMap;
  }

  //VALIDATE FUNCTIONS

  bool _validateTitleDescription(String text, bool isPrivate) {
    if (text == "") {
      if (!state.isNew) {
        mixpanel!.track('edit_event_info_error',
            properties: {'isPrivate': isPrivate});
      } else {
        mixpanel!.track('add_event_info_error',
            properties: {'isPrivate': isPrivate});
      }
      return false;
    }
    return true;
  }

  bool _validateStaff(var selectedTrainersList, bool isPrivate) {
    if (selectedTrainersList!.isEmpty) {
      if (!state.isNew) {
        mixpanel!.track('edit_event_trainers_error',
            properties: {'isPrivate': isPrivate});
      } else {
        mixpanel!.track('add_event_trainers_error',
            properties: {'isPrivate': isPrivate});
      }
      return false;
    }
    return true;
  }

  bool _validateDateTimeDuration(
      DateTime startDate, double duration, bool isPrivate, bool _isBeforeEdit) {
    if (!_validateDateAndTime(startDate, duration, _isBeforeEdit)) {
      if (!state.isNew) {
        mixpanel!.track('edit_event_datetime_error',
            properties: {'isPrivate': isPrivate});
      } else {
        mixpanel!.track('add_event_datetime_error',
            properties: {'isPrivate': isPrivate});
      }
      return false;
    }
    return true;
  }

  bool _validateDateAndTime(
      DateTime startTime, double duration, bool _isBeforeEdit) {
    if (!isBeforeEdit) return true;
    // Calculating the Time to check
    var hour = duration.toString().split(".")[0];
    var min = duration.toStringAsFixed(2).split(".")[1];
    var endTime = startTime
        .add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
    // Computing the workshift
    var workshift1 = currentBrand.workShift[0];
    var workshift2 = currentBrand.workShift[1];
    var startWorkHour = workshift1.toStringAsFixed(2).split(".")[0];
    var startWorkMin = workshift1.toStringAsFixed(2).split(".")[1];
    var endWorkHour = workshift2.toStringAsFixed(2).split(".")[0];
    var endWorkMin = workshift2.toStringAsFixed(2).split(".")[1];
    var startWorkDay = DateTime(startTime.year, startTime.month, startTime.day,
        int.parse(startWorkHour), int.parse(startWorkMin));
    var endWorkDay = DateTime(startTime.year, startTime.month, startTime.day,
        int.parse(endWorkHour), int.parse(endWorkMin));
    if ( // Can´t create event in the past
        startTime.isBefore(DateTime.now()) ||
            startTime.isAtSameMomentAs(DateTime.now()) ||
            endTime.isBefore(DateTime.now()) ||
            endTime.isAtSameMomentAs(DateTime.now())
            // Can´t create event outside of working hours
            ||
            startTime.isBefore(startWorkDay) ||
            endTime.isBefore(startWorkDay) ||
            startTime.isAfter(endWorkDay) ||
            endTime.isAfter(endWorkDay)) {
      return false;
    } else {
      // Can´t create event in break period of working hours
      for (var i = 2; i < currentBrand.workShift.length; i += 2) {
        // Breaks
        var break1 = currentBrand.workShift[i];
        var break2 = currentBrand.workShift[i + 1];
        // Take the minute and the hour
        var startBreakHour = break1.toStringAsFixed(2).split(".")[0];
        var startBreakMin = break1.toStringAsFixed(2).split(".")[1];
        var endBreakHour = break2.toStringAsFixed(2).split(".")[0];
        var endBreakMin = break2.toStringAsFixed(2).split(".")[1];
        // Date Time formatted
        var startBreak = DateTime(startTime.year, startTime.month,
            startTime.day, int.parse(startBreakHour), int.parse(startBreakMin));
        var endBreak = DateTime(startTime.year, startTime.month, startTime.day,
            int.parse(endBreakHour), int.parse(endBreakMin));
        // Condition check
        if (((startTime.isAfter(startBreak) ||
                    startTime.isAtSameMomentAs(startBreak)) &&
                (startTime.isBefore(endBreak))) ||
            ((endTime.isAfter(startBreak)) &&
                (endTime.isBefore(endBreak) ||
                    endTime.isAtSameMomentAs(endBreak)))) {
          return false;
        }
      }
      return true;
    }
  }

  List<bool> _validateEvent(Event _event, bool _isPrivate, bool _isBeforeEdit) {
    bool isPrivate = _isPrivate;
    List<bool> isValidated = [true, true, true];

    if (!_validateTitleDescription(_event.title!, isPrivate)) {
      isValidated[0] = false;
    }

    if (!_validateDateTimeDuration(
        _event.startDate!, _event.duration!, isPrivate, _isBeforeEdit)) {
      isValidated[1] = false;
    }

    if (!_validateStaff(_event.selectedTrainersList!, isPrivate)) {
      isValidated[2] = false;
    }

    return isValidated;
  }
}
