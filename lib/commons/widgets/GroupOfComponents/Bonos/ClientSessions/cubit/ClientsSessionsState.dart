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
  final List<Usuario> usersNow;
  final List<Usuario> allUsers;
  final List<Usuario> filteredUsers;
  final List<Usuario> searchedUsers;
  final bool finished;
  final int i;

  const ClientsSessionsLoaded(this.usersNow, this.allUsers, this.filteredUsers, this.searchedUsers, this.finished, this.i);

  @override
  List<Object?> get props => [usersNow, allUsers, finished, i, filteredUsers, searchedUsers];
}