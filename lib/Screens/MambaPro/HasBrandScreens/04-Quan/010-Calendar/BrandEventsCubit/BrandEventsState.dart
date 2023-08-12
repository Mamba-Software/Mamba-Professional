part of 'BrandEventsCubit.dart';

abstract class BrandEventsState extends Equatable {
  const BrandEventsState();
}

class BrandEventsInitial extends BrandEventsState {
  const BrandEventsInitial();

  @override
  List<Object?> get props => [];
}

class BrandEventsLoading extends BrandEventsState {
  const BrandEventsLoading();

  @override
  List<Object?> get props => [];
}

class BrandEventsLoaded extends BrandEventsState {
  final List<Event> brandEventsList;

  const BrandEventsLoaded(this.brandEventsList);

  @override
  List<Object?> get props => [brandEventsList];
}

class BrandEventsError extends BrandEventsState {
  final String message;
  const BrandEventsError(this.message);

  @override
  List<Object?> get props => [message];
}