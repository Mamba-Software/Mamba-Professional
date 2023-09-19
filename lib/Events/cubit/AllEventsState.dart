part of 'AllEventsCubit.dart';

abstract class AllEventsState extends Equatable {
  const AllEventsState();
}

class AllEventsInitial extends AllEventsState {
  const AllEventsInitial();

  @override
  List<Object?> get props => [];
}

class AllEventsLoading extends AllEventsState {
  const AllEventsLoading();

  @override
  List<Object?> get props => [];
}

class AllEventsLoaded extends AllEventsState {
  final List<Event> eventList;

  const AllEventsLoaded(this.eventList);

  @override
  List<Object?> get props => [eventList];
}

class AllEventsError extends AllEventsState {
  final String message;
  const AllEventsError(this.message);

  @override
  List<Object?> get props => [message];
}