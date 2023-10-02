import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
part 'CrudEventState.dart';

class CrudEventCubit extends Cubit<CrudEventState> {

  final _eventDataService = EventDataService();
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  Event event = Event();
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
  GoogleMapController? mapController;
  bool appBarExpanded = false;


  CrudEventCubit(String eventId) : super(const CrudEventInitial()) {
    getEventInfo(eventId);
  }

  void getEventInfo(String eventId) async {
    event = await _eventDataService.getSingleEvent(eventId);
    isFull = (event.numClients!/event.maxMembers! == 1);
    await getUsersBlockedUser();
    await getEventUsers();
    await getEventBonos();
    await getEventLocation(event.id!);
    emit(CrudEventLoaded(event, isFull, userIsBlockedBy, eventBonos, eventTrainers, eventClients, eventClientsFeedback, eventTrainersIds, eventTrainersBool, location, mapController, appBarExpanded));
  }

  void setAppBarExpanded(bool isAppBarExpanded)
  {
    appBarExpanded = isAppBarExpanded;
    emit(CrudEventLoaded(event, isFull, userIsBlockedBy, eventBonos, eventTrainers, eventClients, eventClientsFeedback, eventTrainersIds, eventTrainersBool, location, mapController, appBarExpanded));
  }

  Future<void> getUsersBlockedUser() async {
    userIsBlockedBy = await _userDataService.getBlockedByUsers(currentUser.id!);
  }

  Future<void> getEventBonos() async {
    eventBonos = await _eventDataService.getEventBonos(event.id!, currentBrand.id!);
    eventBonos.sort((a,b) {
      var aSessions =  a.sessions;
      var bSessions =  b.sessions;
      return aSessions!.compareTo(bSessions!);
    });
  }

  Future<void> getEventUsers() async {
    allUsers = await _eventDataService.getEventUsers(event!.id!);
    allTrainers = await _brandDataService.getBrandTrainers(currentBrand.id!);
    List<Usuario> trainers = [];
    List<String> trainersIds = [];
    List<Usuario> clients = [];
    for (var i=0; i < allUsers.length; i++) {
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
        double? feedbackClient = await _eventDataService.getEventUserFeedback(event!.id!, user.id!);
        eventClientsFeedback.add(feedbackClient);
      }
    }
    eventTrainersBool = [];
    for (var i=0; i < allTrainers.length; i++) {
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

  Future<void> getEventLocation(String eventId) async {
    location = await _eventDataService.getEventLocation(eventId);
  }
}
