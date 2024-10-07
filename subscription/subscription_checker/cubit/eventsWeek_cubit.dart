import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/auth/cubit/AuthCubit.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
part 'eventsWeek_state.dart';

class EventsWeekCubit extends Cubit<int> {
  final _eventDataService = EventDataService();
  late StreamSubscription<int> streamSubscription;
  int events = -1;

  EventsWeekCubit(final cubitAuth) : super(0) {
    // Subscribe to the stream and emit values as they arrive

    try {
      cubitAuth.stream.distinct().listen((state) {
        // Handle the state change
        if (state is AuthUserBrand) {
          if (events == -1) {
            streamSubscription =
                _eventDataService.getBrandsEventsWeek(state.brand.id!).listen(
              (eventCount) {
                events = eventCount;
                emit(eventCount); // Emit the count from the stream
              },
            );
          }
        } else {
          //_streamBrandSuscription.cancel();
        }
      });
    } catch (e) {
      emit(0);
    }
  }

  // Don't forget to cancel the subscription when the cubit is closed
  @override
  Future<void> close() {
    streamSubscription.cancel();
    return super.close();
  }
}
