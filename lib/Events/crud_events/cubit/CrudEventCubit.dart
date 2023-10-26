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
    if (state.newEvent.startDate.isBefore(DateTime.now())) {
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
    switch (editEventType) {
      case EditEventType.title:
        state.newEvent.title = varToChange;
        break;
      case EditEventType.description:
        state.newEvent.description = varToChange;
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
        //errorDate = false;
        state.newEvent.startDate = DateTime(
          varToChange.year,
          varToChange.month,
          varToChange.day,
          state.newEvent.startDate.hour,
          state.newEvent.startDate.minute,
        );
        break;
      case EditEventType.time:
        //errorDate = false;
        state.newEvent.startDate = DateTime(
          state.newEvent.startDate.year,
          state.newEvent.startDate.month,
          state.newEvent.startDate.day,
          varToChange.hour,
          varToChange.minute,
        );
        break;
      case EditEventType.duration:
        state.newEvent.duration = varToChange;
        break;
      case EditEventType.trainers:
        state.newEvent.selectedTrainers = varToChange;
        break;
      case EditEventType.clients:
        state.newEvent.joinedMembers = varToChange;
        break;
      case EditEventType.maxMembers:
        state.newEvent.maxMembers = varToChange;
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

    Event _newEvent = Event();
    _newEvent.setUpdatedBasicData = state.newEvent;

    emit(state.copyWith(
        oldEvent: state.oldEvent,
        newEvent: _newEvent,
        isLoaded: true,
        isNew: false,
        isBeforeEdit: isBeforeEdit));
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

  Future<void> getLocation(String locationId) async {
    state.newEvent.location =
        await _locationDataService.getSingleLocation(locationId);
    state.newEvent.location.initialPosition =
        CameraPosition(target: LatLng(location.latitude!, location.longitude!));
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(location.latitude!, location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    state.newEvent.location.markers!.add(marker);
  }

  void setBonoSelectedUnselected(Bono bono) async {
    if (state.newEvent.eventBonos.containsKey(bono)) {
      // Toggle the value associated with the bono key
      state.newEvent.eventBonos[bono] = !state.newEvent.eventBonos[bono]!;
    }
  }

  void setAllTrue() {
    state.newEvent.eventBonos.updateAll((key, value) => true);
  }
}
