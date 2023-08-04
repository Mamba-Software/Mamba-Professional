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
        emit(ClientsSessionsLoaded(allMembers, allMembers, allMembers, allMembers, false, 0));
      }
  }

    //FES UN DESARROLLO AQUI PER FER QUE AQUEST5A FUNCIO ES VAIG CRIDANT SEGONS LA I
  void updateClientSessions(List<Usuario> usersNow, List<Usuario> allUsers, List<Usuario> filteredUsers, List<Usuario> searchedUsers, int i, bool finished) async {
    int index = -1;
    if(i < allUsers.length) {
      allUsers[i].sessions =
      await _userDataService.getUserActiveSessions(allUsers[i].id!);
      emit(ClientsSessionsLoaded(usersNow, allUsers, filteredUsers, searchedUsers, false, ++i,));
    }
    else {
      for(int j = 0; j < allUsers.length; ++j)  {
         index = usersNow.indexWhere((element) => element.id == allUsers[j].id);
         if(index >= 0) {
           usersNow[index].sessions = allUsers[j].sessions;
         }
         index = filteredUsers.indexWhere((element) => element.id == allUsers[j].id);
         if(index >= 0) {
           filteredUsers[index].sessions = allUsers[j].sessions;
         }
         index = searchedUsers.indexWhere((element) => element.id == allUsers[j].id);
         if(index >= 0) {
           searchedUsers[index].sessions = allUsers[j].sessions;
         }
      }
      emit(ClientsSessionsLoaded(usersNow, allUsers, filteredUsers, searchedUsers, true, i,));
    }
  }


  void updateUser(String userId, List<Usuario> usersNow, List<Usuario> allUsers, List<Usuario> filteredUsers, List<Usuario> searchedUsers, int i, bool finished) async {
    int index = -1;
    int realIndex = -1;
    index = allUsers.indexWhere((element) => element.id == userId);

    if (index >= 0) {
      realIndex = index;
      allUsers[index].sessions =
      await _userDataService.getUserActiveSessions(userId);

      index = usersNow.indexWhere((element) => element.id == userId);
      if (index >= 0) {
        usersNow[index].sessions = allUsers[realIndex].sessions;
      }
      index = filteredUsers.indexWhere((element) => element.id == userId);
      if (index >= 0) {
        filteredUsers[index].sessions = allUsers[realIndex].sessions;
      }
      index = searchedUsers.indexWhere((element) => element.id == userId);
      if (index >= 0) {
        searchedUsers[index].sessions = allUsers[realIndex].sessions;
      }

      emit(ClientsSessionsLoaded(
        usersNow, allUsers, filteredUsers, searchedUsers, true, i,));
    }
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

  void filterSearchResults(String query,List<bool> filterByClients, List<Usuario> usersNow, List<Usuario> allUsers, List<Usuario> filteredUsers, List<Usuario> searchedUsers,  int i, bool finished) {
    List<Usuario> usersFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allUsers) {
        if (item.name!.toLowerCase().startsWith(query)) {
          usersFiltered.add(item);
        }
      }
      filterByActive(filterByClients, usersFiltered, allUsers, filteredUsers, searchedUsers, i, finished);
      //emit(ClientsSessionsLoaded(usersFiltered, allUsers, filteredUsers, usersFiltered, finished, i,));
    } else {
      filterByActive(filterByClients, allUsers, allUsers, filteredUsers, searchedUsers, i, finished);
      //emit(ClientsSessionsLoaded(filteredUsers, allUsers, filteredUsers, allUsers, finished, i));
    }
  }

  void filterByActive(List<bool> filterByClients, List<Usuario> usersNow, List<Usuario> allUsers, List<Usuario> filteredUsers, List<Usuario> searchedUsers,  int i, bool finished) {
    List<Usuario> filteredMembers = [];
    usersNow.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = List.from(usersNow);
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

      emit(ClientsSessionsLoaded(filteredMembers, allUsers, filteredMembers, searchedUsers, finished, i));

  }

}