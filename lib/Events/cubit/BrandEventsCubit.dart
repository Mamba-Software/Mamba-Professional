import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
part 'BrandEventsState.dart';

class BrandEventsCubit extends Cubit<BrandEventsState> {
  BrandEventsCubit(final cubitAuth) : super(const BrandEventsInitial()) {
    cubitAuth.stream.distinct().listen((state) async {
      // Handle the state change
      if (state is AuthUserBrand) {
        if (isStreamActive) _subscription.cancel();
        // Set the State to Loading
        emit(const BrandEventsLoading());

        isStreamActive = true;
        _brandTrainers =
            await _brandDataService.getBrandTrainers(currentBrand.id!);
        getInitialBrandEvents(_brandTrainers);
      } else {
        if (isStreamActive) {
          _subscription.cancel();
          isStreamActive = false;
        }
      }
    });
  }

  final _eventDataService = EventDataService();
  final _brandDataService = BrandDataService();
  final limit = 50;
  List<Event> finishedEventsList = [];
  List<Event> upcomingEventsList = [];
  List<Usuario> _brandTrainers = [];
  late StreamSubscription<QuerySnapshot> _subscription;
  bool isStreamActive = false;

  Future<void> getInitialBrandEvents(List<Usuario> brandTrainers) async {
    try {
      // Brand Id String
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      finishedEventsList = await _eventDataService
          .getBrandFirstCompletedEventsLimit(brandId, limit);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Event evt in finishedEventsList) {
        for (Usuario trainer in brandTrainers) {
          int index =
              trainer.eventsList.indexWhere((element) => element.id == evt.id);
          if (index != -1) {
            eventTrainers.add(trainer);
          }
        }
        evt.setUserList = eventTrainers;
        eventTrainers = [];
      }
      // Open the Stream to Get Brand Upcoming Events
      _subscription =
          _eventDataService.getBrandUpcomingEventsStream(brandId).listen(
        (querySnapshot) async {
          List<DocumentSnapshot> documents = querySnapshot.docs;
          upcomingEventsList = documentsToEvents(documents, brandTrainers);
          List<Event> finalList = finishedEventsList + upcomingEventsList;
          // Order Notification List Descending Time
          finalList.sort((a, b) {
            var aDate = DateTime(
              int.parse(a.year!),
              int.parse(a.month!),
              int.parse(a.day!),
              int.parse(a.hour!),
              int.parse(a.minute!),
            );
            var bDate = DateTime(
              int.parse(b.year!),
              int.parse(b.month!),
              int.parse(b.day!),
              int.parse(b.hour!),
              int.parse(b.minute!),
            );
            return aDate.compareTo(bDate);
          });
          // Emit a new state with the list of `Events`.
          emit(BrandEventsLoaded(finalList));
        },
        onError: (e) {
          print("Brand Events Error$e");
          emit(BrandEventsError(e.toString()));
        },
      );
    } catch (e) {
      print("Brand Events Error$e");
      emit(BrandEventsError(e.toString()));
    }
  }

  Future<void> getMoreBrandEvents(
      String eventId, List<Usuario> brandTrainers) async {
    try {
      print("Getting More Brand Events");
      // Set the State to Loading
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      List<Event> moreFinishedEvents = await _eventDataService
          .getBrandMoreCompletedEventsLimit(brandId, eventId, limit * 2);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Event evt in moreFinishedEvents) {
        for (Usuario trainer in brandTrainers) {
          int index =
              trainer.eventsList.indexWhere((element) => element.id == evt.id);
          if (index != -1) {
            eventTrainers.add(trainer);
          }
        }
        evt.setUserList = eventTrainers;
        eventTrainers = [];
      }
      finishedEventsList = List.from(moreFinishedEvents + finishedEventsList);
      List<Event> finalList =
          List.from(finishedEventsList + upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a, b) {
        var aDate = DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate = DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(BrandEventsLoaded(finalList));
    } catch (e) {
      print("More Brand Events Error$e");
      emit(BrandEventsError(e.toString()));
    }
  }

  Future<void> updateBrandEvent(
      String eventId, List<Usuario> brandTrainers) async {
    try {
      print("Update Brand Event");
      // Set the State to Loading
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      Event event = await _eventDataService.getSingleEvent(eventId);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Usuario trainer in brandTrainers) {
        int index =
            trainer.eventsList.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          eventTrainers.add(trainer);
        }
      }
      event.setUserList = eventTrainers;
      // Remove From Finished List First and Add Again
      finishedEventsList.removeWhere((element) => element.id == eventId);
      finishedEventsList.add(event);
      List<Event> finalList =
          List.from(finishedEventsList + upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a, b) {
        var aDate = DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate = DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(BrandEventsLoaded(finalList));
      print("Event $eventId Successfully Updated");
    } catch (e) {
      print("Delete Brand Event Error$e");
      emit(BrandEventsError(e.toString()));
    }
  }

  Future<void> deleteBrandEvent(String eventId) async {
    try {
      print("Delete More Brand Events");
      upcomingEventsList.removeWhere((element) => element.id == eventId);
      finishedEventsList.removeWhere((element) => element.id == eventId);
      List<Event> finalList =
          List.from(finishedEventsList + upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a, b) {
        var aDate = DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate = DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(BrandEventsLoaded(finalList));
      print("Event $eventId Successfully Deleted");
    } catch (e) {
      print("Delete Brand Event Error$e");
      emit(BrandEventsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    //print('LO CIERRO');
    _subscription.cancel();
    return super.close();
  }

  /*
  TODO: FUTURE FILTER FERLO PER AQUI
  Future<void> filterEvents(int filterSelection, List<Usuario> _selectedTrainers) async {
    try {
      print("Filtering Events ...");
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      /// Check Filter Selection for Type of Event
      if (filterSelection == 0) {
        // Show Both Private and Group Events
      } else if(filterSelection == 1) {
        // Show Only Group Events
        finalList.removeWhere((element) => element.isPrivate == true);
      } else if(filterSelection == 2) {
        // Show Only Private Events
        finalList.removeWhere((element) => element.isPrivate == false);
      }
      emit(BrandEventsLoaded(finalList));
    } catch(e) {
      print("Filter Brand Events Error"+e.toString());
      emit(BrandEventsError(e.toString()));
    }
  }
   */
}

List<Event> documentsToEvents(
    List<DocumentSnapshot> documents, List<Usuario> brandTrainers) {
  List<Event> events = [];
  List<Usuario> eventTrainers = [];
  for (int i = 0; i < documents.length; i++) {
    Event evt = Event.fromObjectOnlyCoverData(documents[i].id, documents[i]);
    // Check Trainers in Event
    for (Usuario trainer in brandTrainers) {
      int index =
          trainer.eventsList.indexWhere((element) => element.id == evt.id);
      if (index != -1) {
        eventTrainers.add(trainer);
      }
    }
    evt.setUserList = eventTrainers;
    events.add(evt);
    eventTrainers = [];
  }
  // Order By
  events.sort((a, b) {
    var aDate = a.doneAt!.toDate();
    var bDate = b.doneAt!.toDate();
    return aDate.compareTo(bDate);
  });
  // Return List of Events
  return events;
}

Event documentToEvent(DocumentSnapshot document, List<Usuario> brandTrainers) {
  List<Usuario> eventTrainers = [];
  Event evt = Event.fromObjectOnlyCoverData(document.id, document);
  // Check Trainers in Event
  for (Usuario trainer in brandTrainers) {
    int index =
        trainer.eventsList.indexWhere((element) => element.id == evt.id);
    if (index != -1) {
      eventTrainers.add(trainer);
    }
  }
  evt.setUserList = eventTrainers;
  return evt;
}
