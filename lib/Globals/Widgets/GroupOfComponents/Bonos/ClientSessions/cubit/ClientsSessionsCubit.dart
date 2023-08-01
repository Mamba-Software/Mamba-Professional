import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';


part 'ClientsSessionsState.dart';

class ClientSessionsCubit extends Cubit<ClientsSessionsState> {
  final List<Usuario> allUsers;
  final _userDataService= UserDataService();
  final _brandDataService = BrandDataService();

  ClientSessionsCubit(this.allUsers) : super(const ClientsSessionsInitial()) {
  }

  void loadList() async {
      List<Usuario> allMembers = [];
      emit(const ClientsSessionsLoading());
      if(allUsers.isEmpty) {
        allMembers = await getAllUsers();
        emit(ClientsSessionsLoaded(allMembers, allMembers, false, 0, allMembers, allMembers));
      }
  }

  void updateClientSessions(List<Usuario> allMembers, int i) async {
    if(i < allMembers.length) {
      allMembers[i].sessions =
      await _userDataService.getUserActiveSessions(allMembers[i].id!);
      emit(ClientsSessionsLoaded(allMembers, allMembers, false, ++i, allMembers, allMembers));
    }
    else {
      emit(ClientsSessionsLoaded(allMembers, allMembers, true, i, allMembers, allMembers));
    }
  }


  void updateUser(int index, List<Usuario> users) async {
    users[index].sessions = null;
    emit(ClientsSessionsLoaded(users, users,false, 0, users, users));
    await Future.delayed(const Duration(milliseconds: 1000));
    users[index].sessions = await _userDataService.getUserActiveSessions(users[index].id!);
    emit(ClientsSessionsLoaded(allUsers, users, false,0, users, users));

  }

  Future<List<Usuario>> getAllUsers() async {
    List<Usuario> brandUsers = await _brandDataService.getBrandClients(currentBrand.id!);
    List<Usuario> allMembers = [];
    for (var i=0; i< brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      allMembers.add(user);
    }
    /*
    for (var i=0; i< 10; i++) {
      Usuario user = brandUsers[0];
      allClients.add(user);
    }
    */
    allMembers.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });

    // Return Future Delayed
    await Future.delayed(const Duration(milliseconds: 1000));

    return allMembers;
  }

  void filterSearchResults(String query, List<Usuario> users, List<Usuario> filteredMembers, List<Usuario> allMembers) {
    List<Usuario> usersFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in filteredMembers) {
        if (item.name!.toLowerCase().startsWith(query)) {
          usersFiltered.add(item);
        }
      }
      emit(ClientsSessionsLoaded(usersFiltered, allMembers, true, 0, filteredMembers, usersFiltered));
    } else {
      emit(ClientsSessionsLoaded(filteredMembers, allMembers, true, 0, filteredMembers, allMembers));
    }
  }

  void filterByActive(List<bool> filterByClients, List<Usuario> usersFiltered, List<Usuario> searchedUsers, List<Usuario> allMembers) {
    List<Usuario> filteredMembers = [];
    usersFiltered.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = List.from(usersFiltered);
    int cnt = 0;
    if (filterByClients[0] == false) {
      filteredMembers.removeWhere((element) {
        DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 31));
        if (element.lastEventAt == null) {
          return false;
        } else {
          return oneMonthAgo.isBefore(element.lastEventAt!.toDate());
        }
      });
    } else {
      cnt += 1;
    }
    if (filterByClients[1] == false) {
      filteredMembers.removeWhere((element) {
        DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 31));
        if (element.lastEventAt == null) {
          return true;
        } else {
          return oneMonthAgo.isAfter(element.lastEventAt!.toDate());
        }
      });
    } else {
      cnt += 1;
    }
    if (cnt == 2) {
      emit(ClientsSessionsLoaded(filteredMembers, allMembers, true, 0, filteredMembers, searchedUsers));
    } else {
      emit(ClientsSessionsLoaded(filteredMembers, allMembers, true, 0, filteredMembers, searchedUsers));
    }

  }

}