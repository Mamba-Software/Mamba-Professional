import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/data/Models/Usuario.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';

part 'ClientsSessionsState.dart';

class ClientSessionsCubit extends Cubit<ClientsSessionsState> {
  final List<Usuario> allUsers;
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();

  ClientSessionsCubit(this.allUsers) : super(const ClientsSessionsInitial());

  void loadList() async {
    List<Usuario> allMembers = [];
    emit(const ClientsSessionsLoading());
    if (allUsers.isEmpty) {
      allMembers = await getAllUsers();
      emit(ClientsSessionsLoaded(
          allMembers, allMembers, allMembers, allMembers, false, 0));
    }
  }

  void updateClientSessions(
      String query,
      List<bool> filterByClients,
      List<bool> orderBySessions,
      List<Usuario> usersNow,
      List<Usuario> allUsers,
      List<Usuario> filteredUsers,
      List<Usuario> searchedUsers,
      int i,
      bool finished) async {
    int index = -1;
    if (i < allUsers.length) {
      allUsers[i].sessions =
          await _userDataService.getUserActiveSessions(allUsers[i].id!);
      filterSearchResults(query, filterByClients, orderBySessions, usersNow,
          allUsers, filteredUsers, searchedUsers, ++i, false);
      //emit(ClientsSessionsLoaded(usersNow, allUsers, filteredUsers, searchedUsers, false, ++i,));
    } else {
      for (int j = 0; j < allUsers.length; ++j) {
        index = usersNow.indexWhere((element) => element.id == allUsers[j].id);
        if (index >= 0) {
          usersNow[index].sessions = allUsers[j].sessions;
        }
        index =
            filteredUsers.indexWhere((element) => element.id == allUsers[j].id);
        if (index >= 0) {
          filteredUsers[index].sessions = allUsers[j].sessions;
        }
        index =
            searchedUsers.indexWhere((element) => element.id == allUsers[j].id);
        if (index >= 0) {
          searchedUsers[index].sessions = allUsers[j].sessions;
        }
      }
      filterSearchResults(query, filterByClients, orderBySessions, usersNow,
          allUsers, filteredUsers, searchedUsers, i, true);
      //emit(ClientsSessionsLoaded(usersNow, allUsers, filteredUsers, searchedUsers, true, i,));
    }
  }

  void updateUser(
      String userId,
      List<Usuario> usersNow,
      List<Usuario> allUsers,
      List<Usuario> filteredUsers,
      List<Usuario> searchedUsers,
      int i,
      bool finished) async {
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
        usersNow,
        allUsers,
        filteredUsers,
        searchedUsers,
        true,
        i,
      ));
    }
  }

  Future<List<Usuario>> getAllUsers() async {
    List<Usuario> brandUsers =
        await _brandDataService.getBrandClients(currentBrand.id!);
    List<Usuario> allMembers = [];
    for (var i = 0; i < brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      allMembers.add(user);
    }

    allMembers.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase());
    });

    // Return Future Delayed
    await Future.delayed(const Duration(milliseconds: 1000));

    return allMembers;
  }

  void filterSearchResults(
      String query,
      List<bool> filterByClients,
      List<bool> orderBySessions,
      List<Usuario> usersNow,
      List<Usuario> allUsers,
      List<Usuario> filteredUsers,
      List<Usuario> searchedUsers,
      int i,
      bool finished) {
    List<Usuario> usersFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allUsers) {
        if (item.name!.toLowerCase().startsWith(query)) {
          usersFiltered.add(item);
        }
      }
      filterByActive(filterByClients, orderBySessions, usersFiltered, allUsers,
          filteredUsers, searchedUsers, i, finished);
      //emit(ClientsSessionsLoaded(usersFiltered, allUsers, filteredUsers, usersFiltered, finished, i,));
    } else {
      filterByActive(filterByClients, orderBySessions, allUsers, allUsers,
          filteredUsers, searchedUsers, i, finished);
      //emit(ClientsSessionsLoaded(filteredUsers, allUsers, filteredUsers, allUsers, finished, i));
    }
  }

  void filterByActive(
      List<bool> filterByClients,
      List<bool> orderBySessions,
      List<Usuario> usersNow,
      List<Usuario> allUsers,
      List<Usuario> filteredUsers,
      List<Usuario> searchedUsers,
      int i,
      bool finished) {
    List<Usuario> filteredMembers = [];
    usersNow.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = List.from(usersNow);
    int cnt = 0;
    if (filterByClients[0] == false) {
      filteredMembers.removeWhere((element) {
        DateTime oneMonthAgo =
            DateTime.now().subtract(const Duration(days: 31));
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
        DateTime oneMonthAgo =
            DateTime.now().subtract(const Duration(days: 31));
        if (element.lastEventAt == null) {
          return true;
        } else {
          return oneMonthAgo.isAfter(element.lastEventAt!.toDate());
        }
      });
    } else {
      cnt += 1;
    }

    orderBySessionsFunc(orderBySessions, filteredMembers, allUsers,
        filteredMembers, searchedUsers, i, finished);
  }

  void orderBySessionsFunc(
      List<bool> orderBySessions,
      List<Usuario> usersNow,
      List<Usuario> allUsers,
      List<Usuario> filteredUsers,
      List<Usuario> searchedUsers,
      int i,
      bool finished) {
    // Filter By
    if (orderBySessions[0]) {
      usersNow.sort((a, b) {
        // Handling null cases
        if (a.sessions == null && b.sessions == null) {
          return 0; // Both are null, so they are equal
        } else if (a.sessions == null) {
          return 1; // a.sessions is null, so a should come after b
        } else if (b.sessions == null) {
          return -1; // b.sessions is null, so b should come after a
        }

        // Compare sessions as integers
        int aSessions = int.parse(a.sessions!);
        int bSessions = int.parse(b.sessions!);
        return bSessions.compareTo(aSessions);
      });
    } else if (orderBySessions[1]) {
      usersNow.sort((a, b) {
        // Handling null cases
        if (a.sessions == null && b.sessions == null) {
          return 0; // Both are null, so they are equal
        } else if (b.sessions == null) {
          return 1; // a.sessions is null, so a should come after b
        } else if (a.sessions == null) {
          return -1; // b.sessions is null, so b should come after a
        }

        // Compare sessions as integers
        int aSessions = int.parse(a.sessions!);
        int bSessions = int.parse(b.sessions!);
        return aSessions.compareTo(bSessions);
      });
    }

    emit(ClientsSessionsLoaded(
        usersNow, allUsers, filteredUsers, searchedUsers, finished, i));
  }
}
