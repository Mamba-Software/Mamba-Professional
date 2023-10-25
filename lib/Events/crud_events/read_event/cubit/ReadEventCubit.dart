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
part 'ReadEventState.dart';

class ReadEventCubit extends Cubit<ReadEventLoaded> {
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

  ReadEventCubit(String eventId)
      : super(ReadEventLoaded(Event(), false, const [], const [])) {
    getEventInfo(eventId);
  }

  void getEventInfo(String eventId) async {
    //BASIC DATA
    event = await _eventDataService.getSingleEvent(eventId);

    //LOCATION
    await getEventLocation(event.id!);
    event.location = location;

    //DATE
    event.startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );

    //BONOS
    await getEventBonos();
    event.bonos = eventBonos;

    //Event users
    await getEventMembers(event.id!);
    event.selectedTrainers = brandTrainersSelected;
    event.joinedMembers = brandClientsSelected;
    event.placesLeft = event.maxMembers! - brandClientsSelected.length;

    //Blocked
    await getUsersBlockedUser();

    emit(ReadEventLoaded(event, true, userIsBlockedBy, eventClientsFeedback));
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

  Future<void> getEventMembers(String eventId) async {
    List<Usuario> members = await _eventDataService.getEventUsers(eventId);
    for (var m in members) {
      if (m.isTrainer!) {
        brandTrainersSelected.add(m);
      } else {
        brandClientsSelected.add(m);
        double? feedbackClient =
            await _eventDataService.getEventUserFeedback(event.id!, m.id!);
        eventClientsFeedback.add(feedbackClient);
      }
    }
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
}
