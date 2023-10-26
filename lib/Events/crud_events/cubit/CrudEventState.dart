part of 'CrudEventCubit.dart';

class CrudEventLoaded extends Equatable {
  final Event oldEvent;
  final Event newEvent;
  final bool isLoaded;
  final bool isNew;
  final bool isBeforeEdit;

  const CrudEventLoaded(this.oldEvent, this.newEvent, this.isLoaded, this.isNew,
      this.isBeforeEdit);

  CrudEventLoaded copyWith({
    Event? oldEvent,
    Event? newEvent,
    bool? isLoaded,
    bool? isNew,
    bool? isBeforeEdit,
  }) {
    return CrudEventLoaded(
      oldEvent ?? this.oldEvent,
      newEvent ?? this.newEvent,
      isLoaded ?? this.isLoaded,
      isNew ?? this.isNew,
      isBeforeEdit ?? this.isBeforeEdit,
    );
  }

  @override
  List<Object?> get props => [oldEvent, newEvent, isLoaded, isBeforeEdit];
}
