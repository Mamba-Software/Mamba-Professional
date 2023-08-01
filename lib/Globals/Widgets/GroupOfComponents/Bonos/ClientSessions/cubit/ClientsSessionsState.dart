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
  final List<Usuario> allUsers;
  final List<Usuario> filteredUsers;
  final List<Usuario> searchedUsers;
  final bool finished;
  final int i;

  const ClientsSessionsLoaded(this.users, this.allUsers, this.finished, this.i, this.filteredUsers, this.searchedUsers);

  @override
  List<Object?> get props => [users, allUsers, finished, i, filteredUsers, searchedUsers];
}