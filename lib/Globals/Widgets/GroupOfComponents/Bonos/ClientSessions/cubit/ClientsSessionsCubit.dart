import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';


part 'ClientsSessionsState.dart';

class ClientSessionsCubit extends Cubit<ClientsSessionsState> {
  final List<Usuario> allUsers;
  final _userDataService= UserDataService();

  ClientSessionsCubit(this.allUsers) : super(const ClientsSessionsInitial()) {
    loadList();
  }

  void loadList() async {
      emit(const ClientsSessionsLoading());
      for(int i = 0; i < allUsers.length; ++i) {
        allUsers[i].sessions = await _userDataService.getUserActiveSessions(allUsers[i].id!);
        emit(ClientsSessionsLoaded(allUsers));
      }
      //emit(ClientsSessionsLoaded(allUsers));
  }

  void updateUser(int index, List<Usuario> users) async {
    users[index].sessions = null;
    emit(ClientsSessionsLoaded(users));
    await Future.delayed(const Duration(milliseconds: 1000));
    users[index].sessions = await _userDataService.getUserActiveSessions(users[index].id!);
    emit(ClientsSessionsLoaded(allUsers));

  }

}