import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:equatable/equatable.dart';
part 'BrandEventsState.dart';

class BrandEventsCubit extends Cubit<BrandEventsState> {


  final _eventDataService = EventDataService();
  final limit = 200;
  List<Event> finishedEventsList = [];
  List<Event> upcomingEventsList = [];

  BrandEventsCubit() : super(const BrandEventsInitial());

  Future<void> updateInitialBrandEvents() async {
    try {
      // Set the State to Loading
      emit(const BrandEventsLoading());
      // Brand Id String
      String brandId = "50738633-dba0-48b9-bc55-e4fd52db6f59";
      // Get Last 100 Finished Events
      finishedEventsList = await _eventDataService.getBrandFirstCompletedEventsLimit(brandId, limit);
      // Open the Stream to Get Brand Upcoming Events
      _eventDataService.getBrandUpcomingEventsStream(brandId).listen((querySnapshot) async {
        List<DocumentSnapshot> documents = querySnapshot.docs;
        upcomingEventsList = documentsToEvents(documents);
        List<Event> finalList = finishedEventsList+upcomingEventsList;
        // Order Notification List Descending Time
        finalList.sort((a,b) {
          var aDate =  DateTime(
            int.parse(a.year!),
            int.parse(a.month!),
            int.parse(a.day!),
            int.parse(a.hour!),
            int.parse(a.minute!),
          );
          var bDate =  DateTime(
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
      });
    } catch(e) {
      print("Brand Events Error"+e.toString());
      emit(BrandEventsError(e.toString()));
    }
  }

  Future<void> getMoreBrandEvents(String eventId) async {
    try {
      print("Getting More Brand Events");
      // Set the State to Loading
      String brandId = "50738633-dba0-48b9-bc55-e4fd52db6f59";
      // Get Last 100 Finished Events
      List<Event> moreFinishedEvents = await _eventDataService.getBrandMoreCompletedEventsLimit(brandId, eventId, limit);
      finishedEventsList = List.from(moreFinishedEvents+finishedEventsList);
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a,b) {
        var aDate =  DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate =  DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(BrandEventsLoaded(finalList));
    } catch(e) {
      print("More Brand Events Error"+e.toString());
      emit(BrandEventsError(e.toString()));
    }
  }

}


List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
  List<Event> events = [];
  List<Usuario> eventTrainers = [];
  List<Event> groupEvents = [];
  List<Event> privateEvents = [];
  for(int i = 0; i < documents.length; i++) {
    Event evt = Event.fromObjectOnlyCoverData(documents[i].id, documents[i]);
    /* Check Trainers in Event
    for (Usuario trainer in _brandTrainers) {
      int index =  trainer.eventsList.indexWhere((element) => element.id == evt.id);
      if (index != -1) {
        eventTrainers.add(trainer);
      }
    }
    evt.setUserList = eventTrainers;
    eventTrainers = [];
    /* How to Fetch Trainer before
      if (evt.usersList.isEmpty) {
        evt.setUserList = await _eventDataService.getEventUsers(evt.id!);
      }*/
     */
    // Type of Events
    if (evt.isPrivate! == false) {
      groupEvents.add(evt);
    } else {
      privateEvents.add(evt);
    }
  }
  // Order By
  groupEvents.sort((a,b) {
    var aDate =  a.doneAt!.toDate();
    var bDate =  b.doneAt!.toDate();
    return aDate.compareTo(bDate);
  });
  privateEvents.sort((a,b) {
    var aDate =  a.doneAt!.toDate();
    var bDate =  b.doneAt!.toDate();
    return aDate.compareTo(bDate);
  });
  /// TO CAHNGE
  int filterSelection = 0;
  // Filter By
  if (filterSelection == 0) {
    // Active/Inactive Selected
    events.addAll(groupEvents);
    events.addAll(privateEvents);
  } else if(filterSelection == 1) {
    // Group Events Selected
    events.addAll(groupEvents);
  } else if(filterSelection == 2) {
    // Group Events Selected
    events.addAll(privateEvents);
  }
  // Return List of Events
  return events;
}

/*
List<Event> documentsToEvents(List<DocumentSnapshot> documents, int filterSelection, List<Usuario> _brandTrainers, List<Usuario> selectedTrainers) {
  List<Event> events = [];
  List<Usuario> eventTrainers = [];
  List<Event> groupEvents = [];
  List<Event> privateEvents = [];
  for(int i = 0; i < documents.length; i++) {
    Event evt = Event.fromObjectOnlyCoverData(documents[i].id, documents[i]);
    // Check Trainers in Event
    for (Usuario trainer in _brandTrainers) {
      int index =  trainer.eventsList.indexWhere((element) => element.id == evt.id);
      if (index != -1) {
        eventTrainers.add(trainer);
      }
    }
    evt.setUserList = eventTrainers;
    eventTrainers = [];
    /* How to Fetch Trainer before
      if (evt.usersList.isEmpty) {
        evt.setUserList = await _eventDataService.getEventUsers(evt.id!);
      }*/
    // Type of Events
    if (evt.isPrivate! == false) {
      groupEvents.add(evt);
    } else {
      privateEvents.add(evt);
    }
  }
  // Order By
  groupEvents.sort((a,b) {
    var aDate =  a.doneAt!.toDate();
    var bDate =  b.doneAt!.toDate();
    return aDate.compareTo(bDate);
  });
  privateEvents.sort((a,b) {
    var aDate =  a.doneAt!.toDate();
    var bDate =  b.doneAt!.toDate();
    return aDate.compareTo(bDate);
  });
  // Filter By
  if (filterSelection == 0) {
    // Active/Inactive Selected
    events.addAll(groupEvents);
    events.addAll(privateEvents);
  } else if(filterSelection == 1) {
    // Group Events Selected
    events.addAll(groupEvents);
  } else if(filterSelection == 2) {
    // Group Events Selected
    events.addAll(privateEvents);
  }
  // Return List of Events
  return events;
}
 */