part of 'CrudEventCubit.dart';

abstract class CrudEventState extends Equatable {
  const CrudEventState();
}

class CrudEventInitial extends CrudEventState {
  const CrudEventInitial();

  @override
  List<Object?> get props => [];
}

class CrudEventLoading extends CrudEventState {
  const CrudEventLoading();

  @override
  List<Object?> get props => [];
}

class CrudEventLoaded extends CrudEventState {
  final Event event;
  final bool isFull;
  final List<String> userIsBlockedBy;
  final List<Bono> eventBonos;
  final List<Usuario> eventTrainers;
  final List<Usuario> eventClients;
  final List<double?> eventClientsFeedback;
  final List<String> eventTrainersIds;
  final List<bool> eventTrainersBool;
  final Location location;
  final Location locationDet;
  final GoogleMapController? mapController;
  final bool appBarExpanded;
  final List<Usuario> originalTrainers;
  final List<Usuario> originalClients;
  final List<Usuario> brandTrainersSelected;
  final List<Usuario> brandClientsSelected;
  final List<Bono> allBonos;
  final Event newEvent;

  const CrudEventLoaded(
      this.event,
      this.isFull,
      this.userIsBlockedBy,
      this.eventBonos,
      this.eventTrainers,
      this.eventClients,
      this.eventClientsFeedback,
      this.eventTrainersIds,
      this.eventTrainersBool,
      this.location,
      this.mapController,
      this.appBarExpanded,
      this.originalTrainers,
      this.originalClients,
      this.brandTrainersSelected,
      this.brandClientsSelected,
      this.allBonos,
      this.locationDet,
      this.newEvent);

  @override
  List<Object?> get props => [
        event,
        isFull,
        userIsBlockedBy,
        eventBonos,
        eventTrainers,
        eventClients,
        eventClientsFeedback,
        eventTrainersIds,
        eventTrainersBool,
        location,
        mapController,
        appBarExpanded,
        originalTrainers,
        originalClients,
        brandTrainersSelected,
        brandClientsSelected,
        allBonos,
        locationDet,
        newEvent
      ];
}

class CrudEventError extends CrudEventState {
  final String message;
  const CrudEventError(this.message);

  @override
  List<Object?> get props => [message];
}
