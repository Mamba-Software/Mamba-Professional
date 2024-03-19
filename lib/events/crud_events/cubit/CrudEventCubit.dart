import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/data/Models/Bono.dart';
import 'package:mamba_castelldefels/data/Models/Location.dart';
import 'package:mamba_castelldefels/data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/functions/addEvents.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/functions/notificationsEvents.dart';
import 'package:mamba_castelldefels/events/crud_events/cubit/functions/recurrentEvents.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Recurrent.dart';
import 'package:mamba_castelldefels/events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:uuid/uuid.dart';
part 'CrudEventState.dart';

class CrudEventCubit extends Cubit<CrudEventLoaded> {
  final _eventDataService = EventDataService();
  final _locationDataService = LocationDataService();
  final _notificationsEvents = NotificationsEvent();
  final _addEvents = AddEventFunctions();
  final _recurrentEvents = RecurrentEvents();

  List<Bono> eventBonos = [];

  Location location = Location();
  List<Bono> allBonos = [];
  bool isBeforeEdit = true;
  final _brandDataService = BrandDataService();
  bool errorBonos = false;
  bool clientsModified = false;

  CrudEventCubit()
      : super(CrudEventLoaded(
            Event(),
            Event(),
            false,
            true,
            const [false, false, false],
            false,
            true,
            100,
            false,
            false,
            false));

  Future<void> populateNewEvent(Event event) async {
    emit(state.copyWith(isNew: false));

    clientsModified = false;
    errorBonos = false;

    state.oldEvent.setBasicData = event;
    state.newEvent.setBasicData = event;

    state.oldEvent.id = event.id;
    state.newEvent.id = event.id;

    if (event.eventGroupId != null) {
      state.oldEvent.eventGroupId = event.eventGroupId;
      state.newEvent.eventGroupId = event.eventGroupId;
    }

    state.oldEvent.isPrivate = event.isPrivate;
    state.newEvent.isPrivate = event.isPrivate;

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

    Recurrent recurrent = Recurrent(
      oneWeek: event.startDate!.add(const Duration(days: 7)),
      twoWeek: event.startDate!.add(const Duration(days: 14)),
      oneMonth: event.startDate!.add(const Duration(days: 28)),
      threeMonth: event.startDate!.add(const Duration(days: 74)),
      sixMonth: event.startDate!.add(const Duration(days: 168)),
      nineMonth: event.startDate!.add(const Duration(days: 252)),
      twelveMonth: event.startDate!.add(const Duration(days: 888)),
      values: [false, false, false, false, false, false, false],
      value: 1,
    );

    state.newEvent.recurrent = recurrent;

    await _getAllBonos();
    eventBonos = List.from(event.bonos);
    state.oldEvent.eventBonos = _setEventBonosMap();
    state.newEvent.eventBonos = _setEventBonosMap();

    state.oldEvent.isRecurrent = event.eventGroupId != null;
    state.newEvent.isRecurrent = event.eventGroupId != null;

    emit(state.copyWith(isNew: true));

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
        errorBonos: errorBonos,
        clientsModified: clientsModified));
  }

  Future<void> createNewEvent(DateTime? dateTime, bool isPrivate) async {
    emit(state.copyWith(isNew: true));

    late Event event = Event();
    DateTime startDate = DateTime.now();
    List<Usuario> selectedTrainer = [];
    eventBonos = [];
    clientsModified = false;
    errorBonos = false;

    event.title = currentBrand.name; // = event.copyWith(title: '');
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
    selectedTrainer.add(currentUser);
    event.selectedTrainersList = List.from(selectedTrainer);
    event.joinedMembersList = []; // = event.copyWith(joinedMembersList!: []);
    event.maxMembers = 4; // event.copyWith(maxMembers: 1);
    event.isRecurrent = false;
    Recurrent recurrent = Recurrent(
      oneWeek: event.startDate!.add(const Duration(days: 7)),
      twoWeek: event.startDate!.add(const Duration(days: 14)),
      oneMonth: event.startDate!.add(const Duration(days: 28)),
      threeMonth: event.startDate!.add(const Duration(days: 74)),
      sixMonth: event.startDate!.add(const Duration(days: 168)),
      nineMonth: event.startDate!.add(const Duration(days: 252)),
      twelveMonth: event.startDate!.add(const Duration(days: 888)),
      values: [false, false, false, false, false, false, false],
      value: 1,
    );

    event.recurrent = recurrent;

    event.isPrivate = isPrivate;

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
        errorBonos: errorBonos,
        clientsModified: clientsModified));
  }

  void emitWorkingState(double workProgress) {
    emit(state.copyWith(isWorking: workProgress));
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
      mustUpdateParent: false,
      errorBonos: errorBonos,
      clientsModified: clientsModified,
    ));
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
        mustUpdateParent: true,
        errorBonos: errorBonos,
        clientsModified: clientsModified));
  }

  //ADD EVENT

  Future<void> addEventFunction(
      BuildContext context,
      Event event,
      bool isPrivate,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    if (!event.isRecurrent!) {
      emitWorkingState(30);
      await _addUniqueEventFunction(
          context, event, isPrivate, notificationBefore, notificationAfter);
    } else {
      emitWorkingState(30);
      await _addRecurrentEvents(
          context, event, isPrivate, notificationBefore, notificationAfter);
    }
  }

  Future<void> _addUniqueEventFunction(
      BuildContext context,
      Event eventVariable,
      bool isPrivate,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    String eventImageUrl;
    mixpanel!.timeEvent("add_event_completed");

    //Event Bonos
    List<Bono> selectedBonos = eventVariable.eventBonos!.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Get Random Photo if no Image Selected
    eventImageUrl =
        await _brandDataService.getRandomBrandPhoto(currentBrand.id!);

    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(eventVariable.startDate!);

    // Creating Event Object
    Event event = Event(
      isPrivate: isPrivate,
      title: eventVariable.title,
      description: eventVariable.description,
      imageUrl: eventImageUrl,
      doneAt: doneAt,
      createdAt: Timestamp.now(),
      year: eventVariable.startDate!.year.toString(),
      month: eventVariable.startDate!.month.toString(),
      day: eventVariable.startDate!.day.toString(),
      hour: eventVariable.startDate!.hour.toString(),
      minute: eventVariable.startDate!.minute.toString(),
      duration: eventVariable.duration!,
      locationId: eventVariable.location!.id,
      numClients: eventVariable.joinedMembersList!.length,
      numTrainers: eventVariable.selectedTrainersList!.length,
      maxMembers: eventVariable.maxMembers,
      joinedMembersList: eventVariable.joinedMembersList!,
      selectedTrainersList: eventVariable.selectedTrainersList!,
    );
    // Add Event
    String eventId = await _addEvents.addEventCall(event);
    notificationBefore.payload = eventId;
    notificationAfter.payload = "F-$eventId";
    emitWorkingState(60);

    // Add Event Members
    await _addEvents.addEventTrainers(eventId, event.selectedTrainersList!,
        context, currentUser.id!, notificationBefore);

    await _addEvents.addEventClients(
        eventId,
        event.joinedMembersList!,
        selectedBonos,
        context,
        currentUser.id!,
        currentBrand.id!,
        notificationBefore,
        notificationAfter);

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

    resetNewEvent();
  }

  Future<void> _addRecurrentEvents(
      BuildContext context,
      Event event,
      bool isPrivate,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    mixpanel!.timeEvent("add_event_completed");

    List<int> dayOfWeek = [];
    Recurrent recurrent = event.recurrent!;

    int weekDay = event.startDate!.weekday;
    weekDay = weekDay - 1;

    for (int i = 0; i < recurrent.values!.length; i++) {
      if (event.recurrent!.values![i]) {
        dayOfWeek.add(i - weekDay);
      }
    }
    //Event Bonos
    List<Bono> selectedBonos = event.eventBonos!.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    List<String> bonos = [];
    if (selectedBonos.isNotEmpty) {
      bonos = selectedBonos.map((bono) => bono.id).cast<String>().toList();
    }

    List<String> trainers = [];
    if (event.selectedTrainersList!.isNotEmpty) {
      trainers = event.selectedTrainersList!
          .map((trainer) => trainer.id)
          .cast<String>()
          .toList();
    }

    event.doneAt = Timestamp.fromDate(event.startDate!);

    // Event Group Id
    String eventGroupId = const Uuid().v1();

    DateTime startDate;

    // Start Recurrence
    List<String> groupEventsIds = [];

    int totalEvents = recurrent.value! * dayOfWeek.length;
    double valuePortions = 70 / totalEvents;
    double valueToSum = valuePortions;

    //PER CADA SETMANA
    for (int i = 0; i < recurrent.value!; i++) {
      //AGAFEM ELS DIES QUE S'HA D'APLICAR
      for (int j = 0; j < dayOfWeek.length; j++) {
        emitWorkingState(valuePortions);
        valuePortions += valueToSum;
        startDate =
            event.startDate!.add(Duration(days: ((i * 7) + dayOfWeek[j])));
        if (!startDate.isBefore(event.startDate!)) {
          //TODO CLOUD FUNCTION
          groupEventsIds.add(await _recurrentEvents.addOneRecurrentEvent(
              context,
              startDate,
              eventGroupId,
              event,
              isPrivate,
              currentBrand,
              currentUser.id!,
              selectedBonos,
              bonos,
              trainers,
              notificationBefore,
              notificationAfter));
          // Create Entry in /Event Groups
          await _eventDataService.addRecurrentEventGroup(
              eventGroupId, groupEventsIds);
        }
      }
    }

    mixpanel!.track('add_event_completed', properties: {
      'descriptionLength': event.description!.length.toString(),
      'isPrivate': isPrivate,
      'isRecurrent': true,
      'doneAt': event.doneAt!.toDate().toString(),
      'duration': event.duration.toString(),
      'numClients': event.joinedMembersList!.length.toString(),
      'numTrainers': event.selectedTrainersList!.length.toString(),
      'maxMembers': event.maxMembers!.toString(),
    });

    resetNewEvent();
  }

  //Update event

  Future<void> updateEventFunction(
      BuildContext context,
      Event event,
      Event oldEvent,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    emit(state.copyWith(isWorking: 30));
    await _updateEventFunction(
        context, event, oldEvent, notificationBefore, notificationAfter);
  }

  Future<void> updateRecurrentEventFunction(
      BuildContext context,
      Event event,
      Event oldEvent,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    emit(state.copyWith(isWorking: 30));
    await _updateRecurrentEventFunction(context, event, oldEvent.isPrivate!,
        notificationBefore, notificationAfter);
  }

  Future<void> _updateRecurrentEventFunction(
      BuildContext context,
      Event event,
      bool isPrivate,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    mixpanel!.timeEvent('edit_event_completed');

    List<Bono> selectedBonos = event.eventBonos!.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Get Recurrent Group Ids ..
    var eventGroupIds =
        await _eventDataService.getRecurrentEventGroup(event.eventGroupId!);
    List<String> eventGroupIdsList = eventGroupIds.cast<String>();

    // Find index of Current Event
    int index = eventGroupIdsList.indexWhere((element) => element == event.id!);
    // Recurrent total
    //totalEvents = eventGroupIdsList.length - index;
    int totalEvents = eventGroupIdsList.length;
    double valuePortions = 70 / totalEvents;
    double valueToSum = valuePortions;

    // Update All Events After The Index
    for (var i = index; i < eventGroupIdsList.length; i++) {
      emit(state.copyWith(isWorking: valuePortions));
      valuePortions += valueToSum;

      // Event Id
      String eventId = eventGroupIdsList[i];

      // Original Event Data
      Event originalEvent = await _eventDataService.getSingleEvent(eventId);

      List<Usuario> originalUsers =
          await _eventDataService.getEventUsers(eventId);

      List<Usuario> originalTrainers = [];

      for (var u in originalUsers) {
        if (u.isTrainer!) {
          originalTrainers.add(u);
        }
      }

      originalEvent.selectedTrainersList = List.from(originalTrainers);
      // Event Start Date
      var originalStartDate = DateTime(
        int.parse(originalEvent.year!),
        int.parse(originalEvent.month!),
        int.parse(originalEvent.day!),
        int.parse(originalEvent.hour!),
        int.parse(originalEvent.minute!),
      );

      originalEvent.startDate = originalStartDate;

      var updatedStartDate = DateTime(
        int.parse(originalEvent.year!),
        int.parse(originalEvent.month!),
        int.parse(originalEvent.day!),
        event.startDate!.hour,
        event.startDate!.minute,
      );

      Timestamp doneAt = Timestamp.fromDate(updatedStartDate);

      Event updatedEvent = Event(
        id: eventId,
        isPrivate: isPrivate,
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        doneAt: doneAt,
        createdAt: Timestamp.now(),
        year: updatedStartDate.year.toString(),
        month: updatedStartDate.month.toString(),
        day: updatedStartDate.day.toString(),
        hour: updatedStartDate.hour.toString(),
        minute: updatedStartDate.minute.toString(),
        duration: event.duration,
        locationId: event.location!.id,
        numClients: event.joinedMembersList!.length,
        numTrainers: event.selectedTrainersList!.length,
        maxMembers: event.maxMembers,
        joinedMembersList: event.joinedMembersList!,
        selectedTrainersList: event.selectedTrainersList!,
        startDate: updatedStartDate,
      );

      // Update Event
      await _eventDataService.updateEvent(updatedEvent);

      // Update Event Bonos
      List<Bono> originalBonos =
          await _eventDataService.getEventBonos(eventId, currentBrand.id!);

      await _addEvents.updateBonos(originalBonos, selectedBonos, eventId);

      // Update Event Location
      if (originalEvent.locationId! != updatedEvent.locationId!) {
        await _eventDataService.updateEventLocation(
            eventId, updatedEvent.locationId!, originalEvent.locationId!);
      }

      await _addEvents.assignTrainers(
          context,
          originalEvent,
          updatedEvent,
          currentUser.id!,
          _notificationsEvents.setEventNotificationBeforeRecurrent(updatedEvent,
              notificationBefore.title!, notificationBefore.body!));
    }

    resetNewEvent();
  }

  Future<void> _updateEventFunction(
      BuildContext context,
      Event eventVariable,
      Event oldEvent,
      ReceivedNotification notificationBefore,
      ReceivedNotification notificationAfter) async {
    String eventImageUrl;

    print(state.oldEvent.title);
    print(state.newEvent.title);

    mixpanel!.timeEvent("edit_event_completed");

    //Event Bonos
    List<Bono> selectedBonos = eventVariable.eventBonos!.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    eventImageUrl = eventVariable.imageUrl!;

    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(eventVariable.startDate!);
    // Creating Event Object
    Event event = Event(
      id: oldEvent.id,
      isPrivate: oldEvent.isPrivate,
      title: eventVariable.title,
      description: eventVariable.description,
      imageUrl: eventImageUrl,
      doneAt: doneAt,
      createdAt: Timestamp.now(),
      year: eventVariable.startDate!.year.toString(),
      month: eventVariable.startDate!.month.toString(),
      day: eventVariable.startDate!.day.toString(),
      hour: eventVariable.startDate!.hour.toString(),
      minute: eventVariable.startDate!.minute.toString(),
      duration: eventVariable.duration!,
      locationId: eventVariable.location!.id,
      numClients: eventVariable.joinedMembersList!.length,
      numTrainers: eventVariable.selectedTrainersList!.length,
      maxMembers: eventVariable.maxMembers,
      joinedMembersList: eventVariable.joinedMembersList!,
      selectedTrainersList: eventVariable.selectedTrainersList!,
      startDate: eventVariable.startDate!,
    );

    notificationBefore.payload = oldEvent.id;
    notificationAfter.payload = "F-${oldEvent.id!}";

    // Update Event
    await _eventDataService.updateEvent(event);

    // Update Event Bonos
    List<Bono> originalBonos = [];

    for (Bono bono in oldEvent.bonos) {
      originalBonos.add(bono);
    }

    await _addEvents.updateBonos(originalBonos, selectedBonos, event.id!);

    // Update Event Location
    if (event.locationId! != oldEvent.locationId!) {
      await _eventDataService.updateEventLocation(
          event.id!, event.locationId!, oldEvent.locationId!);
    }

    await _addEvents.assignTrainers(
        context, oldEvent, event, currentUser.id!, notificationBefore);

    await _addEvents.assignClients(
        context,
        oldEvent,
        event,
        selectedBonos,
        currentBrand.id!,
        currentUser.id!,
        notificationBefore,
        notificationAfter);

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

  //Delete event

  Future<void> deleteEventFunction(
      BuildContext context, Event oldEvent, bool isPrivate) async {
    emitWorkingState(30);
    await _deleteEventFunction(context, oldEvent, isPrivate);
  }

  Future<void> _deleteEventFunction(
      BuildContext context, Event oldEvent, bool isPrivate) async {
    mixpanel!.timeEvent("delete_event_completed");

    // Delete Event Call
    await _eventDataService.deleteEvent(oldEvent.id!, isPrivate);
    emitWorkingState(30);

    // Event Members
    List<Usuario> eventMembers = List.from(oldEvent.selectedTrainersList!);
    eventMembers.addAll(oldEvent.joinedMembersList!);

    // Delete Event Bonos
    _deleteEventBonosCall(oldEvent.id!);
    emitWorkingState(60);
    // Delete Event Local Notifications
    for (var i = 0; i < eventMembers.length; i++) {
      var user = eventMembers[i];
      // Remove Local Notifications Service
      await _notificationsEvents.deleteEventLocalNotificationsCall(
          oldEvent.id!, user.id!, currentUser.id!);
    }
    emitWorkingState(80);
    // Delete Event From Event Group Id in Case it has any.
    if (oldEvent.eventGroupId != null) {
      // Get Recurrent Group Ids ..
      var eventGroupIds = await _eventDataService
          .getRecurrentEventGroup(oldEvent.eventGroupId!);
      // Delete Only This Event..
      eventGroupIds.removeWhere((element) => element == oldEvent.id!);
      // Delete Event From Recurrent Group..
      if (eventGroupIds.isNotEmpty) {
        await _eventDataService.updateRecurrentEventGroup(
            oldEvent.eventGroupId!, eventGroupIds);
      } else {
        await _eventDataService
            .deleteRecurrentEventGroup(oldEvent.eventGroupId!);
      }
    }
    mixpanel!.track('delete_event_completed',
        properties: {'isPrivate': isPrivate, 'isRecurrent': false});

    resetNewEvent();
  }

  Future<void> deleteRecurrentEventFunction(
      BuildContext context, Event oldEvent, bool isPrivate) async {
    emitWorkingState(30);
    await _deleteRecurrentEventFunction(context, oldEvent, isPrivate);
  }

  Future<void> _deleteRecurrentEventFunction(
      BuildContext context, Event oldEvent, bool isPrivate) async {
    mixpanel!.timeEvent("delete_event_completed");

    // Get Recurrent Group Ids ..
    var eventGroupIds =
        await _eventDataService.getRecurrentEventGroup(oldEvent.eventGroupId!);
    List<String> eventGroupIdsList = eventGroupIds.cast<String>();
    // Find index of Current Event
    int index =
        eventGroupIdsList.indexWhere((element) => element == oldEvent.id!);
    // Update Recurrent Event Group
    if (index == 0) {
      await _eventDataService.deleteRecurrentEventGroup(oldEvent.eventGroupId!);
    } else {
      eventGroupIds = eventGroupIds.sublist(0, index);
      await _eventDataService.updateRecurrentEventGroup(
          oldEvent.eventGroupId!, eventGroupIds);
    }
    // Recurrent total
    int totalEvents = eventGroupIdsList.length - index;
    double valuePortions = 70 / totalEvents;
    double valueToSum = valuePortions;
    // Delete All Events After The Index
    for (var i = index; i < eventGroupIdsList.length; i++) {
      // Updating Loading Text
      emitWorkingState(valuePortions);
      valuePortions += valueToSum;
      // Event Id
      String eventId = eventGroupIdsList[i];
      // Delete Event Call
      await _eventDataService.deleteEvent(eventId);
      // Delete Event Bonos
      _deleteEventBonosCall(eventId);
      // Delete Event Members
      List<Usuario> eventMembers =
          await _eventDataService.getEventUsers(eventId);
      // Delete Event Local Notifications
      for (var i = 0; i < eventMembers.length; i++) {
        var user = eventMembers[i];
        // Remove Local Notifications Service
        await _notificationsEvents.deleteEventLocalNotificationsCall(
            oldEvent.id!, user.id!, currentUser.id!);
      }
    }
    mixpanel!.track('delete_event_completed',
        properties: {'isPrivate': isPrivate, 'isRecurrent': true});
    resetNewEvent();
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
    clientsModified = state.clientsModified;

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
        //PROBLEMS QUAN FAIG UPDATE EVENT
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
        clientsModified = true;
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
        event = state.newEvent.copyWith(maxMembers: int.parse(varToChange));
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
    }
    emit(state.copyWith(
      newEvent: event,
      isValidated: validations,
      errorBonos: errorBonos,
      clientsModified: clientsModified,
    ));
  }

  Recurrent updateRecurrency(DateTime startDate, bool isRecurrent, int value,
      bool checkValues, List<bool> values, int newVal) {
    List<bool> localValues = List.from(values);
    if (checkValues) {
      if (isRecurrent) {
        localValues = [false, false, false, false, false, false, false];
        localValues[startDate.weekday - 1] = true;
      } else {
        localValues = [false, false, false, false, false, false, false];
      }
    } else {
      if (newVal != -1) {
        localValues[newVal % 7] = !localValues[newVal % 7];
      }
    }
    Recurrent recurrent = Recurrent(
      oneWeek: startDate.add(const Duration(days: 7)),
      twoWeek: startDate.add(const Duration(days: 14)),
      oneMonth: startDate.add(const Duration(days: 28)),
      threeMonth: startDate.add(const Duration(days: 91)),
      sixMonth: startDate.add(const Duration(days: 182)),
      nineMonth: startDate.add(const Duration(days: 273)),
      twelveMonth: startDate.add(const Duration(days: 364)),
      values: localValues,
      value: value,
    );
    return recurrent;
  }

  @override
  void onChange(Change<CrudEventLoaded> change) {
    super.onChange(change);
    log(change.currentState.toString());
    log(change.nextState.toString());
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

  //BONOS FUNCTIONS

  Future<void> _addEventBonosCall(
      String eventId, List<Bono> selectedBonos) async {
    // Add Event Members
    await _eventDataService.addEventBonosObject(eventId, selectedBonos);
  }

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
    Map<Bono, bool> bonosMap = {};

    for (Bono bono in allBonos) {
      // Check if the current bono exists in eventBonos
      bool exists = eventBonos.any((eventBono) => eventBono.id! == bono.id!);
      // Set the value in the map
      bonosMap[bono] = exists;
    }
    return bonosMap;
  }

  Future<void> _deleteEventBonosCall(String eventId) async {
    // Add Event Members
    await _eventDataService.deleteEventBonos(eventId);
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
      DateTime startDate, double duration, bool isPrivate, bool isBeforeEdit) {
    if (!_validateDateAndTime(startDate, duration, isBeforeEdit)) {
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
      DateTime startTime, double duration, bool isBeforeEdit) {
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
      /*
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
      }*/
      return true;
    }
  }

  List<bool> _validateEvent(Event event, bool isPrivateVar, bool isBeforeEdit) {
    bool isPrivate = isPrivateVar;
    List<bool> isValidated = [true, true, true];

    if (!_validateTitleDescription(event.title!, isPrivate)) {
      isValidated[0] = false;
    }

    if (!_validateDateTimeDuration(
        event.startDate!, event.duration!, isPrivate, isBeforeEdit)) {
      isValidated[1] = false;
    }

    if (!_validateStaff(event.selectedTrainersList!, isPrivate)) {
      isValidated[2] = false;
    }

    return isValidated;
  }
}
