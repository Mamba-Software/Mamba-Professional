part of 'ClientsSessionsCubit.dart';

abstract class ClientsSessionsState extends Equatable {
  const ClientsSessionsState();
}

class ClientsSessionsInitial extends ClientsSessionsState {
  const ClientsSessionsInitial();

  @override
  List<Object?> get props => [];
}

class ClientsSessionsLoading extends ClientsSessionsState {
  const ClientsSessionsLoading();

  @override
  List<Object?> get props => [];
}

class ClientsSessionsLoaded extends ClientsSessionsState {
  final List<Usuario> users;

  const ClientsSessionsLoaded(this.users);

  @override
  List<Object?> get props => [users];
}