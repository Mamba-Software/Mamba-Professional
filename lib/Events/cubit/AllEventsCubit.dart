import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
part 'AllEventsState.dart';

class AllEventsCubit extends Cubit<List<Event>> {
  final _eventDataService = EventDataService();
  List<Event> eventList = [];
  late StreamSubscription<QuerySnapshot> _streamAllEvents;
  bool isStreamActive = false;

  AllEventsCubit(final cubitAuth) : super([]) {
    emit([]);
    Stream<QuerySnapshot> getBrandEventsStream(String brandId) {
      return _eventDataService.getBrandEventsStream(currentBrand.id!);
    }

    try {
      cubitAuth.stream.distinct().listen((state) {
        // Handle the state change
        if (state is AuthUserBrand) {
          if (isStreamActive) _streamAllEvents.cancel();
          isStreamActive = true;
          _streamAllEvents = getBrandEventsStream(currentBrand.id!)
              .listen((querySnapshot) async {
            List<DocumentSnapshot> documents = querySnapshot.docs;
            eventList = documentsToEvents(documents, []);
            // Emit a new state with the list of `Events`.
            emit(eventList);
          });
        } else {
          if (isStreamActive) {
            _streamAllEvents.cancel();
            isStreamActive = false;
          }
        }
      });
    } catch (e) {
      emit([]);
    }
  }

  // Don't forget to cancel the subscription when the cubit is closed
  @override
  Future<void> close() {
    _streamAllEvents.cancel();
    return super.close();
  }
/*
  AllEventsCubit() : super([]) {
    Stream<QuerySnapshot> getBrandEventsStream(String brandId) {
      return _eventDataService.getBrandEventsStream(currentBrand.id!);
    }
    try {
      blocA.stream.distinct().listen((state) {
        // Handle the state change
        if (state is SpecificBlocAState) {
          add(SpecificBlocBEvent()); // Trigger some event in BlocB
        }
      });
      getBrandEventsStream(currentBrand.id!).listen((querySnapshot) async {
        List<DocumentSnapshot> documents = querySnapshot.docs;
        eventList = documentsToEvents(documents, []);
        // Emit a new state with the list of `Events`.
        emit(eventList);
      });
    }
    catch(e)
    {
      emit([]);
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
