part of 'BonoEventsCubit.dart';

abstract class BonoEventsState extends Equatable {
  const BonoEventsState();
}

class BonoEventsInitial extends BonoEventsState {
  const BonoEventsInitial();

  @override
  List<Object?> get props => [];
}

class BonoEventsLoading extends BonoEventsState {
  const BonoEventsLoading();

  @override
  List<Object?> get props => [];
}

class BonoEventsLoaded extends BonoEventsState {
  final List<Event> allEvents;
  final List<Event> selectedEvents;
  final List<Event> filteredEvents;

  const BonoEventsLoaded(this.allEvents, this.selectedEvents, this.filteredEvents);

  @override
  List<Object?> get props => [allEvents, selectedEvents, filteredEvents];
}