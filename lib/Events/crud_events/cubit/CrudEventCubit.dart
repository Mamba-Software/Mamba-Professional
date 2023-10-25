import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Events/crud_events/utils/enumAddEditEvent.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
part 'CrudEventState.dart';

class CrudEventCubit extends Cubit<CrudEventState> {
  final _eventDataService = EventDataService();
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  final _locationDataService = LocationDataService();
  Event event = Event();
  Event newEvent = Event();
  bool isFull = false;
  List<String> userIsBlockedBy = [];
  List<Bono> eventBonos = [];
  List<Usuario> allUsers = [];
  List<Usuario> allTrainers = [];
  List<Usuario> eventTrainers = [];
  List<Usuario> eventClients = [];
  List<double?> eventClientsFeedback = [];
  List<String> eventTrainersIds = [];
  List<bool> eventTrainersBool = [];
  Location location = Location();
  Location locationDet = Location();
  GoogleMapController? mapController;
  bool appBarExpanded = false;
  List<Usuario> originalTrainers = [];
  List<Usuario> originalClients = [];
  List<Usuario> brandTrainersSelected = [];
  List<Usuario> brandClientsSelected = [];
  List<Bono> allBonos = [];
  bool isBeforeEdit = true;
  bool errorDate = false;

  CrudEventCubit() : super(const CrudEventInitial());

  void getEventInfo(String eventId, bool loadState) async {
    if (event.id == '') {
      emit(const CrudEventLoading());
    } else if (eventId != event.id) {
      emit(const CrudEventLoading());
    }
    print(event.title);
    event = await _eventDataService.getSingleEvent(eventId);

    isFull = (event.numClients! / event.maxMembers! == 1);
    await getUsersBlockedUser();
    await getEventUsers();
    await getEventBonos();
    await getBrandBonos();
    if (loadState) {
      await getEventLocation(event.id!);
    }
    if (!loadState) {
      await getEventLocationDet(event.id!);
      await getEventMembers(event.id!);
    }
    await getLocation(event.locationId!);
    populateNewEvent();
    emit(CrudEventLoaded(
        event,
        isFull,
        userIsBlockedBy,
        eventBonos,
        eventTrainers,
        eventClients,
        eventClientsFeedback,
        eventTrainersIds,
        eventTrainersBool,
        location,
        mapController,
        appBarExpanded,
        originalTrainers,
        originalClients,
        brandTrainersSelected,
        brandClientsSelected,
        allBonos,
        locationDet,
        newEvent,
        isBeforeEdit));
  }

  void populateNewEvent() {
    newEvent.setBasicData = event;
    newEvent.eventBonos = setEventBonosMap();
    newEvent.startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    isBeforeEdit = true;
    if (newEvent.startDate.isBefore(DateTime.now())) {
      isBeforeEdit = false;
    }
    newEvent.selectedTrainers = eventTrainers;
    newEvent.maxMembers = event.maxMembers;
    newEvent.joinedMembers = brandClientsSelected;
  }

  Map<Bono, bool> setEventBonosMap() {
    final Map<Bono, bool> bonosMap = {};

    for (Bono bono in allBonos) {
      // Check if the current bono exists in eventBonos
      bool exists = eventBonos.any((eventBono) => eventBono == bono);
      // Set the value in the map
      bonosMap[bono] = exists;
    }
    return bonosMap;
  }

  void resetNewEvent() {
    newEvent.setBasicData = event;

    emit(CrudEventLoaded(
        event,
        isFull,
        userIsBlockedBy,
        eventBonos,
        eventTrainers,
        eventClients,
        eventClientsFeedback,
        eventTrainersIds,
        eventTrainersBool,
        location,
        mapController,
        appBarExpanded,
        originalTrainers,
        originalClients,
        brandTrainersSelected,
        brandClientsSelected,
        allBonos,
        locationDet,
        newEvent,
        isBeforeEdit));
  }

  Future<void> editEventInfo(var varToChange, EditEventType editEventType,
      [Bono? bono]) async {
    //emit(const CrudEventLoading());
    switch (editEventType) {
      case EditEventType.title:
        newEvent.title = varToChange;
        break;
      case EditEventType.description:
        newEvent.description = varToChange;
        break;
      case EditEventType.location:
        await getLocation(varToChange);
        break;
      case EditEventType.bonos:
        if (varToChange == 'AllBonos') {
          setAllTrue();
        } else {
          setBonoSelectedUnselected(bono!);
        }
        break;
      case EditEventType.startDate:
        errorDate = false;
        newEvent.startDate = DateTime(
          varToChange.year,
          varToChange.month,
          varToChange.day,
          newEvent.startDate.hour,
          newEvent.startDate.minute,
        );
        break;
      case EditEventType.time:
        errorDate = false;
        newEvent.startDate = DateTime(
          newEvent.startDate.year,
          newEvent.startDate.month,
          newEvent.startDate.day,
          varToChange.hour,
          varToChange.minute,
        );
        break;
      case EditEventType.duration:
        newEvent.duration = varToChange;
        break;
      case EditEventType.trainers:
        newEvent.selectedTrainers = varToChange;
        break;
      case EditEventType.clients:
        newEvent.joinedMembers = varToChange;
        break;
      case EditEventType.maxMembers:
        (state as CrudEventLoaded).newEvent.maxMembers = varToChange;
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
    emit(CrudEventLoaded(
        event,
        isFull,
        userIsBlockedBy,
        eventBonos,
        eventTrainers,
        eventClients,
        eventClientsFeedback,
        eventTrainersIds,
        eventTrainersBool,
        location,
        mapController,
        appBarExpanded,
        originalTrainers,
        originalClients,
        brandTrainersSelected,
        brandClientsSelected,
        allBonos,
        locationDet,
        (state as CrudEventLoaded).newEvent,
        isBeforeEdit));
  }

  @override
  void onChange(Change<CrudEventState> change) {
    super.onChange(change);
    log(change.currentState.toString());
    log(change.nextState.toString());
  }

  void setAppBarExpanded(bool isAppBarExpanded) {
    appBarExpanded = isAppBarExpanded;
    emit(CrudEventLoaded(
        event,
        isFull,
        userIsBlockedBy,
        eventBonos,
        eventTrainers,
        eventClients,
        eventClientsFeedback,
        eventTrainersIds,
        eventTrainersBool,
        location,
        mapController,
        appBarExpanded,
        originalTrainers,
        originalClients,
        brandTrainersSelected,
        brandClientsSelected,
        allBonos,
        locationDet,
        newEvent,
        isBeforeEdit));
  }

  Future<void> getUsersBlockedUser() async {
    userIsBlockedBy = await _userDataService.getBlockedByUsers(currentUser.id!);
  }

  Future<void> getEventBonos() async {
    eventBonos =
        await _eventDataService.getEventBonos(event.id!, currentBrand.id!);
    eventBonos.sort((a, b) {
      var aSessions = a.sessions;
      var bSessions = b.sessions;
      return aSessions!.compareTo(bSessions!);
    });
  }

  Future<void> getEventUsers() async {
    allUsers = await _eventDataService.getEventUsers(event!.id!);
    allTrainers = await _brandDataService.getBrandTrainers(currentBrand.id!);
    List<Usuario> trainers = [];
    List<String> trainersIds = [];
    List<Usuario> clients = [];
    for (var i = 0; i < allUsers.length; i++) {
      var user = allUsers[i];
      if (user.isTrainer!) {
        if (currentUser.id! == user.id!) {
          // User has joined the event
          trainers.insert(0, user);
          trainersIds.insert(0, user.id!);
        } else {
          trainers.add(user);
          trainersIds.add(user.id!);
        }
      } else {
        clients.add(user);
        double? feedbackClient =
            await _eventDataService.getEventUserFeedback(event!.id!, user.id!);
        eventClientsFeedback.add(feedbackClient);
      }
    }
    eventTrainersBool = [];
    for (var i = 0; i < allTrainers.length; i++) {
      var trainer = allTrainers[i];
      if (trainersIds.contains(trainer.id!)) {
        eventTrainersBool.add(true);
      } else {
        eventTrainersBool.add(false);
      }
    }
    eventTrainers = trainers;
    eventTrainersIds = trainersIds;
    eventClients = clients;
  }

  Future<void> getEventMembers(String eventId) async {
    List<Usuario> members = await _eventDataService.getEventUsers(eventId);
    for (var m in members) {
      if (m.isTrainer!) {
        brandTrainersSelected.add(m);
        originalTrainers.add(m);
      } else {
        brandClientsSelected.add(m);
        originalClients.add(m);
      }
    }
  }

  Future<void> getBrandBonos() async {
    allBonos =
        await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
    allBonos.removeWhere((element) => element.isActive == false);
    allBonos.sort((a, b) {
      var aSessions = a.sessions;
      var bSessions = b.sessions;
      return aSessions!.compareTo(bSessions!);
    });
  }

  Future<void> getEventLocation(String eventId) async {
    location = await _eventDataService.getEventLocation(eventId);
    event.locationId = location.id!;
    location.initialPosition =
        CameraPosition(target: LatLng(location.latitude!, location.longitude!));
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(location.latitude!, location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    location.markers!.add(marker);
  }

  Future<void> getEventLocationDet(String eventId) async {
    location = await _locationDataService.getSingleLocation(location.id!);
    event.locationId = location.id!;
    location.initialPosition =
        CameraPosition(target: LatLng(location.latitude!, location.longitude!));
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(location.latitude!, location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    location.markers!.add(marker);
  }

  Future<void> getLocation(String locationId) async {
    newEvent.location =
        await _locationDataService.getSingleLocation(locationId);
    newEvent.location.initialPosition =
        CameraPosition(target: LatLng(location.latitude!, location.longitude!));
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(location.latitude!, location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    newEvent.location.markers!.add(marker);
  }

  void setBonoSelectedUnselected(Bono bono) async {
    if (newEvent.eventBonos.containsKey(bono)) {
      // Toggle the value associated with the bono key
      newEvent.eventBonos[bono] = !newEvent.eventBonos[bono]!;
    }
  }

  void setAllTrue() {
    newEvent.eventBonos.updateAll((key, value) => true);
  }
}
