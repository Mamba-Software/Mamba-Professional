// TODO Implement this library.import 'dart:async';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:equatable/equatable.dart';
part 'eventsWeek_state.dart';

class EventsWeekCubit extends Cubit<List<int>> {
  final _eventDataService = EventDataService();
  late StreamSubscription<int> streamSubscriptionCurrWeek;
  late StreamSubscription<int> streamSubscriptionNextWeek;
  int eventsCurrWeek = -1;
  int eventsNextWeek = -1;

  EventsWeekCubit(final cubitAuth) : super([0, 0]) {
    // Subscribe to the stream and emit values as they arrive

    try {
      cubitAuth.stream.distinct().listen((state) {
        // Handle the state change
        if (state is AuthUserBrand) {
          if (eventsCurrWeek == -1 && eventsNextWeek == -1) {
            streamSubscriptionCurrWeek = _eventDataService
                .getBrandsEventsWeek(state.brand.id!, DateTime.now())
                .listen(
              (eventCountCurrWeek) {
                eventsCurrWeek = eventCountCurrWeek;
                emit([
                  eventsCurrWeek,
                  eventsNextWeek
                ]); // Emit the count from the stream
              },
            );
            streamSubscriptionNextWeek = _eventDataService
                .getBrandsEventsWeek(
                    state.brand.id!, DateTime.now().add(Duration(days: 7)))
                .listen(
              (eventsCountNextWeek) {
                eventsNextWeek = eventsCountNextWeek;
                emit([
                  eventsCurrWeek,
                  eventsNextWeek
                ]); // Emit the count from the stream
              },
            );
          }
        } else {
          //_streamBrandSuscription.cancel();
        }
      });
    } catch (e) {
      emit([0, 0]);
    }
  }

  // Don't forget to cancel the subscription when the cubit is closed
  @override
  Future<void> close() {
    streamSubscriptionCurrWeek.cancel();
    streamSubscriptionNextWeek.cancel();
    return super.close();
  }
}
