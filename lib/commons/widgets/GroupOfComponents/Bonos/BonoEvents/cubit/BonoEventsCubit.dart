import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/data/Models/Purchase.dart';
import 'package:equatable/equatable.dart';

part 'BonoEventsState.dart';

class BonoEventsCubit extends Cubit<BonoEventsState> {
  final Purchase purchase;
  final String brandId;
  final List<Event> selectedEvents;
  final List<Event> allEventsInit;
  final bool chargeAll;
  final _purchaseDataService = PurchaseDataService();

  BonoEventsCubit(this.purchase, this.brandId, this.selectedEvents,
      this.allEventsInit, this.chargeAll)
      : super(const BonoEventsInitial()) {
    loadList(purchase, brandId, selectedEvents, allEventsInit);
  }

  void loadList(Purchase purchase, String brandId, List<Event> selectedEvents,
      List<Event> allEventsInit) async {
    emit(const BonoEventsLoading());
    List<Event> newSelectedEvents = [];
    List<Event> allEvents = [];
    if (allEventsInit.isNotEmpty) {
      allEvents = allEventsInit;
      if (allEvents.isNotEmpty) {
        for (var event in selectedEvents) {
          String id = event.id!;
          var index = allEvents.indexWhere((element) => element.id! == id);
          if (index != -1) {
            newSelectedEvents.add(allEvents[index]);
          }
        }
      }
    } else {
      if (chargeAll) {
        allEvents = await getAllEvents(purchase, brandId);
      }
    }
    emit(BonoEventsLoaded(allEvents, newSelectedEvents, allEvents));
  }

  void updateSelected(Event event, List<Event> selectedEvents,
      List<Event> allEvents, List<Event> filteredEvents) async {
    emit(const BonoEventsLoading());
    if (selectedEvents.contains(event)) {
      selectedEvents.remove(event);
    } else {
      selectedEvents.add(event);
    }
    emit(BonoEventsLoaded(allEvents, selectedEvents, filteredEvents));
  }

  void filterSearchResults(String query, List<Event> selectedEvents,
      List<Event> allEvents, List<Event> filteredEvents) {
    emit(const BonoEventsLoading());
    List<Event> eventsFiltered = [];
    List<Event> filteredEvents = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allEvents) {
        if (item.title!.toLowerCase().startsWith(query)) {
          eventsFiltered.add(item);
        }
      }
      filteredEvents = eventsFiltered;
    } else {
      filteredEvents = allEvents;
    }
    emit(BonoEventsLoaded(allEvents, selectedEvents, filteredEvents));
  }

  Future<List<Event>> getAllEvents(Purchase purchase, String brandId) async {
    List<Event> allEvents = await _purchaseDataService
        .getPurchaseEventsLast30Days(purchase, brandId);
    if (allEvents.isNotEmpty) {
      // Sort Clients
      allEvents.sort((a, b) {
        if (a.doneAt != null && b.doneAt != null) {
          return b.doneAt!.compareTo(a.doneAt!);
        } else if (a.doneAt != null) {
          return -1; // a is greater (comes first) if it has doneAt value
        } else if (b.doneAt != null) {
          return 1; // b is greater (comes first) if it has doneAt value
        } else {
          return 0; // both events don't have doneAt value, so no change in order
        }
      });
    }
    return allEvents;
  }
}
