part of 'CrudEventCubit.dart';

class CrudEventLoaded extends Equatable {
  final Event oldEvent;
  final Event newEvent;
  final bool isLoaded;
  final bool isNew;
  final List<bool> isValidated;
  final bool isPrivate;
  final bool isRecurrent;
  final bool isBeforeEdit;

  const CrudEventLoaded(this.oldEvent, this.newEvent, this.isLoaded, this.isNew,
      this.isValidated, this.isPrivate, this.isRecurrent, this.isBeforeEdit);

  CrudEventLoaded copyWith({
    Event? oldEvent,
    Event? newEvent,
    bool? isLoaded,
    bool? isNew,
    List<bool>? isValidated,
    bool? isPrivate,
    bool? isRecurrent,
    bool? isBeforeEdit,
  }) {
    return CrudEventLoaded(
      oldEvent ?? this.oldEvent,
      newEvent ?? this.newEvent,
      isLoaded ?? this.isLoaded,
      isNew ?? this.isNew,
      isValidated ?? this.isValidated,
      isPrivate ?? this.isPrivate,
      isRecurrent ?? this.isRecurrent,
      isBeforeEdit ?? this.isBeforeEdit,
    );
  }

  @override
  List<Object?> get props => [
        oldEvent,
        newEvent,
        isLoaded,
        isNew,
        isValidated,
        isPrivate,
        isRecurrent,
        isBeforeEdit
      ];
}
