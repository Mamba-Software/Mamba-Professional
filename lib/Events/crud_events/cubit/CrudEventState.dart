part of 'CrudEventCubit.dart';

class CrudEventLoaded extends Equatable {
  final Event oldEvent;
  final Event newEvent;
  final bool isLoaded;
  final bool isNew;
  final List<bool> isValidated;
  final bool isPrivate;
  final bool isBeforeEdit;
  final double isWorking;
  final bool mustUpdateParent;
  final bool errorBonos;
  final bool clientsModified;

  const CrudEventLoaded(
      this.oldEvent,
      this.newEvent,
      this.isLoaded,
      this.isNew,
      this.isValidated,
      this.isPrivate,
      this.isBeforeEdit,
      this.isWorking,
      this.mustUpdateParent,
      this.errorBonos,
      this.clientsModified);

  CrudEventLoaded copyWith({
    Event? oldEvent,
    Event? newEvent,
    bool? isLoaded,
    bool? isNew,
    List<bool>? isValidated,
    bool? isPrivate,
    bool? isBeforeEdit,
    double? isWorking,
    bool? mustUpdateParent,
    bool? errorBonos,
    bool? clientsModified,
  }) {
    return CrudEventLoaded(
      oldEvent ?? this.oldEvent,
      newEvent ?? this.newEvent,
      isLoaded ?? this.isLoaded,
      isNew ?? this.isNew,
      isValidated ?? this.isValidated,
      isPrivate ?? this.isPrivate,
      isBeforeEdit ?? this.isBeforeEdit,
      isWorking ?? this.isWorking,
      mustUpdateParent ?? this.mustUpdateParent,
      errorBonos ?? this.errorBonos,
      clientsModified ?? this.clientsModified,
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
        isBeforeEdit,
        isWorking,
        mustUpdateParent,
        errorBonos,
        clientsModified
      ];
}
