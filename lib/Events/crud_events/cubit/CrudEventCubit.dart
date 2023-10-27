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

class CrudEventCubit extends Cubit<CrudEventLoaded> {
  final _eventDataService = EventDataService();
  final _locationDataService = LocationDataService();

  List<Bono> eventBonos = [];

  Location location = Location();
  List<Usuario> brandTrainersSelected = [];
  List<Usuario> brandClientsSelected = [];
  List<Bono> allBonos = [];
  bool isBeforeEdit = true;
  final _brandDataService = BrandDataService();

  CrudEventCubit()
      : super(CrudEventLoaded(Event(), Event(), false, true, true));

  Future<void> populateNewEvent(Event event) async {
    state.oldEvent.setBasicData = event;
    state.newEvent.setBasicData = event;

    state.oldEvent.eventBonos = setEventBonosMap();
    state.newEvent.eventBonos = setEventBonosMap();

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

    state.oldEvent.selectedTrainers = event.selectedTrainers;
    state.oldEvent.maxMembers = event.maxMembers;
    state.oldEvent.joinedMembers = event.joinedMembers;

    state.newEvent.selectedTrainers = event.selectedTrainers;
    state.newEvent.maxMembers = event.maxMembers;
    state.newEvent.joinedMembers = event.joinedMembers;

    await getAllBonos();
    state.oldEvent.eventBonos = setEventBonosMap();
    state.newEvent.eventBonos = setEventBonosMap();

    emit(state.copyWith(
        oldEvent: state.oldEvent,
        newEvent: state.newEvent,
        isLoaded: true,
        isNew: false,
        isBeforeEdit: isBeforeEdit));
  }

  Future<void> createNewEvent() async {
    late Event event = Event();

    event = event.copyWith(title: '');
    event = event.copyWith(description: '');
    event =
        event.copyWith(location: await getLocation(currentBrand.baseLocation!));
    await getAllBonos();
    event.eventBonos = setEventBonosMap();
    event =
        event.copyWith(startDate: state.newEvent.startDate = DateTime.now());
    event = event.copyWith(duration: 1);
    event = event.copyWith(selectedTrainers: [currentUser]);
    event = event.copyWith(selectedTrainers: []);
    event = event.copyWith(maxMembers: 1);

    emit(state.copyWith(
        newEvent: event,
        oldEvent: event,
        isLoaded: true,
        isNew: true,
        isBeforeEdit: true));
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
    emit(state.copyWith(
        oldEvent: Event(),
        newEvent: Event(),
        isLoaded: false,
        isNew: true,
        isBeforeEdit: true));
  }

  Future<void> getAllBonos() async {
    allBonos =
        await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
    allBonos.removeWhere((element) => element.isActive == false);
    allBonos.sort((a, b) {
      var aSessions = a.sessions;
      var bSessions = b.sessions;
      return aSessions!.compareTo(bSessions!);
    });
  }

  Future<void> editEventInfo(var varToChange, EditEventType editEventType,
      [Bono? bono]) async {
    late Event event = Event();
    switch (editEventType) {
      case EditEventType.title:
        event = state.newEvent.copyWith(title: varToChange);
        break;
      case EditEventType.description:
        event = state.newEvent.copyWith(description: varToChange);
        break;
      case EditEventType.location:
        event =
            state.newEvent.copyWith(location: await getLocation(varToChange));
        break;
      case EditEventType.bonos:
        if (varToChange == 'AllBonos') {
          event = state.newEvent.copyWith(eventBonos: setAllTrue());
        } else {
          event = state.newEvent
              .copyWith(eventBonos: setBonoSelectedUnselected(bono!));
        }
        break;
      case EditEventType.startDate:
        //errorDate = false;
        event = state.newEvent.copyWith(
            startDate: state.newEvent.startDate = DateTime(
          varToChange.year,
          varToChange.month,
          varToChange.day,
          state.newEvent.startDate!.hour,
          state.newEvent.startDate!.minute,
        ));
        break;
      case EditEventType.time:
        event = state.newEvent.copyWith(
            startDate: state.newEvent.startDate = DateTime(
          state.newEvent.startDate!.year,
          state.newEvent.startDate!.month,
          state.newEvent.startDate!.day,
          varToChange.hour,
          varToChange.minute,
        ));
        //errorDate = false;
        break;
      case EditEventType.duration:
        event = state.newEvent.copyWith(duration: varToChange);
        break;
      case EditEventType.trainers:
        event = state.newEvent.copyWith(selectedTrainers: varToChange);
        break;
      case EditEventType.clients:
        event = state.newEvent.copyWith(joinedMembers: varToChange);
        break;
      case EditEventType.maxMembers:
        event = state.newEvent.copyWith(maxMembers: varToChange);
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

    emit(state.copyWith(newEvent: event));
  }

  @override
  void onChange(Change<CrudEventLoaded> change) {
    super.onChange(change);
    log(change.currentState.toString());
    log(change.nextState.toString());
  }

  Future<void> getEventMembers(String eventId) async {
    List<Usuario> members = await _eventDataService.getEventUsers(eventId);
    for (var m in members) {
      if (m.isTrainer!) {
        brandTrainersSelected.add(m);
      } else {
        brandClientsSelected.add(m);
      }
    }
  }

  Future<void> getEventLocationDet(String eventId) async {
    location = await _locationDataService.getSingleLocation(location.id!);
    //event.locationId = location.id!;
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

  Future<Location> getLocation(String locationId) async {
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

  Map<Bono, bool> setBonoSelectedUnselected(Bono bono) {
    if (state.newEvent.eventBonos!.containsKey(bono)) {
      // Toggle the value associated with the bono key
      state.newEvent.eventBonos![bono] = !state.newEvent.eventBonos![bono]!;
    }
    return state.newEvent.eventBonos!;
  }

  Map<Bono, bool> setAllTrue() {
    state.newEvent.eventBonos?.updateAll((key, value) => true);
    return state.newEvent.eventBonos!;
  }
}
