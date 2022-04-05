import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/RoomDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';

import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/ChatCore/Chat.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class BrandMembersClient extends StatefulWidget {
  String brandID;
  String brandAdmin;
  bool viewOnly;
  BrandMembersClient({Key? key, required this.brandID,  required this.brandAdmin, required this.viewOnly}) : super(key: key);

  @override
  _BrandMembersClientState createState() => _BrandMembersClientState();
}

class _BrandMembersClientState extends State<BrandMembersClient> {

  // Data Service
  var _brandDataService = BrandDataService();
  var _roomDataService = new RoomDataService();
  // Boolean Loading
  bool isLoading = true;
  // Boolean isUpdated
  bool isUpdated = false;
  // Search Controller
  bool searchClicked = false;
  var searchController = TextEditingController();

  // Members Page
  List<Usuario> allMembers = [];
  List<Usuario> filteredMembers = [];
  List<Usuario> allClients = [];
  List<Usuario> allTrainers = [];

  Future<void> getAllUsers() async {
    List<Usuario> brandUsers = await _brandDataService.getBrandUsers(widget.brandID);
    allClients = [];
    allTrainers = [];
    for (var i=0; i< brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      if (user.isTrainer! == false) {
        allClients.add(user);
      } else {
        allTrainers.add(user);
      }
    }
    // Sort Clients
    allClients.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    allClients = orderClientsPrivateLast(allClients);
    // Sort Trainers
    allTrainers.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    // Add All Members
    allMembers.addAll(allClients);
    allMembers.addAll(allTrainers);
    allMembers.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    filteredMembers = allMembers;
    filteredMembers = orderClientsPrivateLast(filteredMembers);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  void filterSearchResults(String query) {
    List<Usuario> usersFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allMembers) {
        if (item.name!.toLowerCase().startsWith(query)) {
          usersFiltered.add(item);
        }
      }
      setState(() {
        filteredMembers = usersFiltered;
      });
    } else {
      setState(() {
        filteredMembers = allMembers;
      });
    }
  }

  List<Usuario> orderClientsPrivateLast(List<Usuario> clients) {
    List<Usuario> orderedUsers = [];
    List<Usuario> privateUsers = [];
    for (var i=0; i< clients.length; i++) {
      Usuario client = clients[i];
      if (client.isPrivate!) {
        privateUsers.add(client);
      } else {
        orderedUsers.add(client);
      }
    }
    privateUsers.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });
    orderedUsers.addAll(privateUsers);
    return orderedUsers;
  }

  String getUsersFullName(Usuario user) {
    return "${user.firstName} ${user.lastName}";
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }

  @override
  initState() {
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body:  isLoading ?
      Center(child: LoadingViewPurple())
          :
      DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            //elevation: 0,
            title: Text(AppLocalizations.of(context)!.members, style: Theme.of(context).appBarTheme.titleTextStyle,),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: !searchClicked ?
                IconButton(
                    icon: Icon(Icons.search, size: MediaQuery.of(context).size.width*0.07, color: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        searchClicked = !searchClicked;
                      });
                    }
                )
                    :
                IconButton(
                    icon: Icon(Icons.clear, size: MediaQuery.of(context).size.width*0.07, color: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        searchClicked = !searchClicked;
                      });
                    }
                ),
              )
            ],
            bottom: searchClicked ? PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.07,),
                child: Container(
                  height: MediaQuery.of(context).size.height*0.07,
                  child: Padding(
                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.03,left: MediaQuery.of(context).size.width*0.03, top: MediaQuery.of(context).size.width*0.0,),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          filterSearchResults(value);
                        },
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: AppLocalizations.of(context)!.search,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.width*0.06,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              searchController.clear();
                              filterSearchResults("");
                            },
                            icon: Icon(Icons.delete_outline, color: Colors.grey,),
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                      )
                  ),
                )
            ) : PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.07,),
              child: TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color:Theme.of(context).accentColor, ),
                ),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.trainers, style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.clients, style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            )
          ),
          backgroundColor: Colors.transparent,
          body: !searchClicked ? TabBarView(
            children: [
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: allTrainers.length,
                          itemBuilder: (context, index) {
                            Usuario user = allTrainers[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 0),
                              child: ListTile(
                                leading: CircularImage(
                                  size: MediaQuery.of(context).size.width*0.15,
                                  image: user.imageUrl,
                                  color: Theme.of(context).primaryColor,
                                  borderWidth: 1.0,
                                ),
                                title: Text(
                                  getUsersFullName(user),
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "@${user.nick!}",
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                                trailing: widget.viewOnly || user.id! == currentUser.id ? IconButton(
                                  icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.all(0),
                                  onPressed: false ? () {
                                  } : null,
                                ) : IconButton(
                                  icon: Icon(Icons.chat_outlined, color: Theme.of(context).primaryColor,size: MediaQuery.of(context).size.height*0.03,),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    types.User otherUser = types.User(
                                      firstName: user.firstName,
                                      lastName: user.lastName,
                                      id: user.id!, // UID from Firebase Authentication
                                      imageUrl: user.imageUrl,
                                    );
                                    final room = await FirebaseChatCore.instance.createRoom(otherUser,metadata: {
                                      "trainer" + user.id!: user.isTrainer,
                                      "trainer" + currentUser.id!: currentUser.isTrainer,
                                      "active" + user.id!: false,
                                      "active" + currentUser.id!: true,
                                    });

                                    bool? deleteRoom = await Navigator.push(
                                      context,
                                      CupertinoPageRoute<bool>(
                                          builder: (context) => ChatPage(room: room)),).whenComplete(() async {
                                      room.metadata!["active" + currentUser.id!] = false;
                                      _roomDataService.updateRoom(room.id, room.metadata!);
                                    });
                                    if (!deleteRoom!) {
                                      _roomDataService.deleteRoom(room.id);
                                    }
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute<Null>(
                                          builder: (context) => ProfileViewUser(
                                            userID: user.id!,
                                            viewOnly: widget.viewOnly,
                                          )
                                      )
                                  );
                                },
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  allClients.length != 0 ?
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 0),
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: allClients.length,
                          itemBuilder: (context, index) {
                            Usuario user = allClients[index];
                            if (user.isPrivate! && user.id != currentUser.id) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                                child: ListTile(
                                  leading: CircularImage(
                                    size: MediaQuery.of(context).size.width*0.15,
                                    image: user.noImageUrl,
                                    color: Theme.of(context).primaryColor,
                                    borderWidth: 1.0,
                                  ),
                                  title: Text(
                                    user.firstName!,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                                    textAlign: TextAlign.left,
                                  ),
                                  trailing: Icon(Icons.visibility_off_outlined, color: Theme.of(context).primaryColor.withOpacity(0.3), size: MediaQuery.of(context).size.height*0.03,),
                                  onTap: () {

                                  },
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                                child: ListTile(
                                  leading: CircularImage(
                                    size: MediaQuery.of(context).size.width*0.15,
                                    image: user.imageUrl,
                                    color: Theme.of(context).primaryColor,
                                    borderWidth: 1.0,
                                  ),
                                  title: Text(
                                    getUsersFullName(user),
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "@${user.nick!}",
                                        style: Theme.of(context).textTheme.caption,
                                      ),
                                    ],
                                  ),
                                  trailing: widget.viewOnly || user.id! == currentUser.id ? IconButton(
                                    icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.all(0),
                                    onPressed: false ? () {
                                    } : null,
                                  ) : IconButton(
                                    icon: Icon(Icons.chat_outlined, color: Theme.of(context).primaryColor,size: MediaQuery.of(context).size.height*0.03,),
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.all(0),
                                    onPressed: () async {
                                      types.User otherUser = types.User(
                                        firstName: user.firstName,
                                        lastName: user.lastName,
                                        id: user.id!, // UID from Firebase Authentication
                                        imageUrl: user.imageUrl,
                                      );
                                      final room = await FirebaseChatCore.instance.createRoom(otherUser,metadata: {
                                        "trainer" + user.id!: user.isTrainer,
                                        "trainer" + currentUser.id!: currentUser.isTrainer,
                                        "active" + user.id!: false,
                                        "active" + currentUser.id!: true,
                                      });

                                      bool? deleteRoom = await Navigator.push(
                                        context,
                                        CupertinoPageRoute<bool>(
                                            builder: (context) => ChatPage(room: room)),).whenComplete(() async {
                                        room.metadata!["active" + currentUser.id!] = false;
                                        _roomDataService.updateRoom(room.id, room.metadata!);
                                      });
                                      if (!deleteRoom!) {
                                        _roomDataService.deleteRoom(room.id);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute<Null>(
                                            builder: (context) => ProfileViewUser(
                                              userID: user.id!,
                                              viewOnly: widget.viewOnly,
                                            )
                                        )
                                    );
                                  },
                                ),
                              );
                            }
                          }
                      ),
                    ),
                  ) :
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width*0.30,
                            child: Image.asset(Constants.emptyCalendar)
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Text(AppLocalizations.of(context)!.noMembersFound, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                        SizedBox(height: MediaQuery.of(context).size.height*0.12),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ) : Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01,),
              Expanded(
                child: Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        Usuario user = filteredMembers[index];
                        if (user.isPrivate! && user.id != currentUser.id) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                            child: ListTile(
                              leading: CircularImage(
                                size: MediaQuery.of(context).size.width*0.15,
                                image: user.noImageUrl,
                                color: Theme.of(context).primaryColor,
                                borderWidth: 1.0,
                              ),
                              title: Text(
                                user.firstName!,
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                                textAlign: TextAlign.left,
                              ),
                              trailing: Icon(Icons.visibility_off_outlined, color: Theme.of(context).primaryColor.withOpacity(0.3), size: MediaQuery.of(context).size.height*0.03,),
                              onTap: () {

                              },
                            ),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                            child: ListTile(
                              leading: CircularImage(
                                size: MediaQuery.of(context).size.width*0.15,
                                image: user.imageUrl,
                                color: Theme.of(context).primaryColor,
                                borderWidth: 1.0,
                              ),
                              title: Text(
                                getUsersFullName(user),
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "@${user.nick!}",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                              trailing: widget.viewOnly || user.id! == currentUser.id ? IconButton(
                                icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(0),
                                onPressed: false ? () {
                                } : null,
                              ) : IconButton(
                                icon: Icon(Icons.chat_outlined, color: Theme.of(context).primaryColor,size: MediaQuery.of(context).size.height*0.03,),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(0),
                                onPressed: () async {
                                  types.User otherUser = types.User(
                                    firstName: user.firstName,
                                    lastName: user.lastName,
                                    id: user.id!, // UID from Firebase Authentication
                                    imageUrl: user.imageUrl,
                                  );
                                  final room = await FirebaseChatCore.instance.createRoom(otherUser,metadata: {
                                    "trainer" + user.id!: user.isTrainer,
                                    "trainer" + currentUser.id!: currentUser.isTrainer,
                                    "active" + user.id!: false,
                                    "active" + currentUser.id!: true,
                                  });

                                  bool? deleteRoom = await Navigator.push(
                                    context,
                                    CupertinoPageRoute<bool>(
                                        builder: (context) => ChatPage(room: room)),).whenComplete(() async {
                                    room.metadata!["active" + currentUser.id!] = false;
                                    _roomDataService.updateRoom(room.id, room.metadata!);
                                  });
                                  if (!deleteRoom!) {
                                    _roomDataService.deleteRoom(room.id);
                                  }
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute<Null>(
                                        builder: (context) => ProfileViewUser(
                                          userID: user.id!,
                                          viewOnly: widget.viewOnly,
                                        )
                                    )
                                );
                              },
                            ),
                          );
                        }
                      }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}