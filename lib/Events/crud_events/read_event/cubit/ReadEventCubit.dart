import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
part 'ReadEventState.dart';

class ReadEventCubit extends Cubit<ReadEventLoaded> {
  final _eventDataService = EventDataService();
  final _userDataService = UserDataService();
  final _locationDataService = LocationDataService();

  Event event = Event();
  List<String> userIsBlockedBy = [];
  List<Bono> eventBonos = [];
  List<double?> eventClientsFeedback = [];
  Location location = Location();

  List<Usuario> brandTrainersSelected = [];
  List<Usuario> brandClientsSelected = [];

  bool isBeforeEdit = true;

  ReadEventCubit(String eventId)
      : super(ReadEventLoaded(Event(), false, const [], const [])) {
    getEventInfo(eventId);
  }

  void getEventInfo(String eventId) async {
    event = Event();
    userIsBlockedBy = [];
    eventBonos = [];
    eventClientsFeedback = [];
    location = Location();

    brandTrainersSelected = [];
    brandClientsSelected = [];

    isBeforeEdit = true;

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
    event.selectedTrainersList = brandTrainersSelected;
    event.joinedMembersList = brandClientsSelected;
    event.placesLeft = event.maxMembers! - brandClientsSelected.length;

    //Blocked
    await getUsersBlockedUser();

    emit(ReadEventLoaded(event, true, userIsBlockedBy, eventClientsFeedback));
  }

  void resetEvent() {
    emit(ReadEventLoaded(event, false, userIsBlockedBy, eventClientsFeedback));
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
    location = await _eventDataService.getEventLocation(event.id!);
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
}
