import 'package:mamba_castelldefels/Data/Models/Usuario.dart';

class OrderFilter {

  List<Usuario> orderFilter(List<Usuario> filteredUsers, List<Usuario> allUsers, List<Usuario> activeUsersVar, List<Usuario> inactiveUsersVar, int filterSelection, int orderByClientsNumber, int alphabeticOrder) {
    List<Usuario> users = [];
    List<Usuario> usersToReturn = [];
    List<Usuario> activeUsers = activeUsersVar;
    List<Usuario> inactiveUsers = inactiveUsersVar;

    bool found = false;
/*
    for(int i = 0; i < inactiveUsers.length; ++i)
      {
        print(inactiveUsers[i].name);
        if(inactiveUsers[i].active == true)
          {
            print(inactiveUsers[i].name);
            inactiveUsers.remove(inactiveUsers[i]);
          }

      }
    for(int i = activeUsers.length - 1; i >= 0; --i)
    {
      print(activeUsers[i].name);
      if(activeUsers[i].active == false)
      {
        print(activeUsers[i].name);
        activeUsers.remove(activeUsers[i]);
      }

    }
*/
    //activeUsers.removeWhere((item) => item.active! == false);
    //inactiveUsers.removeWhere((item) => item.active! == true);

    print('y');
    print(filterSelection);
    print(orderByClientsNumber);
    print(alphabeticOrder);

    print('n');






    if (alphabeticOrder == 1) {
      activeUsers.sort((a, b) {
        return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
      });

      inactiveUsers.sort((a, b) {
        return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
      });
     // activeUsers = List.from(activeUsers.reversed);
     // inactiveUsers = List.from(inactiveUsers.reversed);
    }
    else {
      activeUsers.sort((a, b) {
        return b.name.toString().toLowerCase().compareTo(a.name.toString().toLowerCase());
      });

      inactiveUsers.sort((a, b) {
        return b.name.toString().toLowerCase().compareTo(a.name.toString().toLowerCase());
      });
    }
    // Filter By
    if (filterSelection == 0) {
      // Active/Inactive Selected
      if (orderByClientsNumber == 0) {
        users.addAll(activeUsers);
        users.addAll(inactiveUsers);
      } else {
        users.addAll(inactiveUsers);
        users.addAll(activeUsers);
      }
    } else if(filterSelection == 1) {
      // Active Selected
      users.addAll(activeUsers);
    } else if(filterSelection == 2) {
      // Inactive Selected
      users.addAll(inactiveUsers);
    } else {
      // None Selected
    }
/*
    for(int i = 0; i < filteredUsers.length; ++i)
    {
      for(int j = 0; j < users.length; ++j)
        {
          if(filteredUsers[i] == users[i]) {
            found = true;
            break;
          }
        }
      if(found) {
        usersToReturn.add(filteredUsers[i]);
      }
      found = false;
    }
 */
    // Return List of Bonos
    return users;
  }

}
