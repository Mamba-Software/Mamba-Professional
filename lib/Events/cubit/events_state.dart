part of 'events_bloc.dart';

abstract class EventsState extends Equatable {
  const EventsState();
}

class EventsInitial extends EventsState {
  const EventsInitial();

  @override
  List<Object?> get props => [];
}

class EventsLoading extends EventsState {
  const EventsLoading();

  @override
  List<Object?> get props => [];
}

class EventsLoaded extends EventsState {
  final List<Event> brandEventsList;

  const EventsLoaded(this.brandEventsList);

  @override
  List<Object?> get props => [brandEventsList];
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}