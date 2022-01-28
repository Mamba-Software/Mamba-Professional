import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/BrandDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/chatDetailPage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Chat/ChatCore/Chat.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class TodosMiembrosClient extends StatefulWidget {
  String brandID;
  String brandAdmin;
  bool viewOnly;
  TodosMiembrosClient({Key? key, required this.brandID,  required this.brandAdmin, required this.viewOnly}) : super(key: key);

  @override
  _TodosMiembrosClientState createState() => _TodosMiembrosClientState();
}

class _TodosMiembrosClientState extends State<TodosMiembrosClient> {

  // Brand Data Service
  var _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = true;
  // Boolean isUpdated
  bool isUpdated = false;
  // Search Controller
  var searchClientsController = TextEditingController();
  var searchTrainersController = TextEditingController();

  // Members Page
  List<Usuario> allClients = [];
  List<Usuario> filteredClients = [];
  List<Usuario> allTrainers = [];
  List<Usuario> filteredTrainers = [];

  Future<void> getAllUsers() async {
    List<Usuario> brandUsers = await _brandDataService.getBrandUsers(widget.brandID);
    for (var i=0; i< brandUsers.length; i++) {
      Usuario user = brandUsers[i];
      if (user.isTrainer! == false) {
        if (user.id == currentUser.id) {
          filteredClients.insert(0, user);
        } else {
          filteredClients.add(user);
        }
        allClients.add(user);
      } else {
        filteredTrainers.add(user);
        allTrainers.add(user);
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

  void filterSearchResults(String query, bool isTrainer) {
    List<Usuario> usersFiltered = [];
    if (isTrainer) {
      if (query.isNotEmpty || query != "") {
        for (var item in allTrainers) {
          if (item.name!.toLowerCase().startsWith(query)) {
            usersFiltered.add(item);
          }
        }
        setState(() {
          filteredTrainers = usersFiltered;
        });
      } else {
        setState(() {
          filteredTrainers = allTrainers;
        });
      }
    } else {
      if (query.isNotEmpty || query != "") {
        for (var item in allClients) {
          if (item.name!.toLowerCase().startsWith(query)) {
            usersFiltered.add(item);
          }
        }
        setState(() {
          filteredClients = orderClientsPrivateLast(usersFiltered);
        });
      } else {
        setState(() {
          filteredClients =  orderClientsPrivateLast(allClients);
        });
      }
    }
  }

  List<Usuario> orderClientsPrivateLast(List<Usuario> clients) {
    List<Usuario> orderedUsers = [];
    List<Usuario> privateUsers = [];
    for (var i=0; i< clients.length; i++) {
      Usuario client = clients[i];
      if (client.id == currentUser.id) {
        orderedUsers.insert(0, client);
      } else {
        if (client.isPrivate!) {
          privateUsers.add(client);
        } else {
          orderedUsers.add(client);
        }
      }
    }
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
            title: Text(AppLocalizations.of(context)!.members, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
            centerTitle: true,
            bottom: TabBar(
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
                        Icon(Icons.record_voice_over, color: Theme.of(context).accentColor,),
                        SizedBox(width: 10,),
                        Text(AppLocalizations.of(context)!.trainers, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),),
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
                        Icon(Icons.directions_run, color: Theme.of(context).accentColor,),
                        SizedBox(width: 10,),
                        Text(AppLocalizations.of(context)!.clients, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          body: TabBarView(
              children: [
                Column(
                  children: [
                    allTrainers.length > 1 ?
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04, right: MediaQuery.of(context).size.width*0.04, top: MediaQuery.of(context).size.width*0.04),
                      child: TextField(
                          controller: searchTrainersController,
                          onChanged: (value) {
                            // Filter trainers
                            filterSearchResults(value.toLowerCase(), true);
                          },
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
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
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                searchTrainersController.clear();
                                filterSearchResults("", true);
                              },
                              icon: Icon(Icons.clear, color: Colors.grey,),
                            ),
                            contentPadding: EdgeInsets.all(0),
                          ),
                        )
                    ) : SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: filteredTrainers.length,
                          itemBuilder: (context, index) {
                            Usuario user = filteredTrainers[index];
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
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "@${user.nick!}",
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    user.id == widget.brandAdmin ? Text(
                                      "(${AppLocalizations.of(context)!.owner})",
                                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontStyle: FontStyle.italic),
                                    ) : Container(),
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

                                    Navigator.push(context, CupertinoPageRoute<Null>(
                                        builder: (context) => ChatPage(room: room)),).whenComplete(() {
                                      if(room.lastMessages!.length == 0) _accessDatabase.deleteRoom(room.id);
                                    });
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
                    allClients.length > 1 ?
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04, right: MediaQuery.of(context).size.width*0.04, top: MediaQuery.of(context).size.width*0.04),
                      child: TextField(
                        controller: searchClientsController,
                        onChanged: (value) {
                          // Filter trainers
                          filterSearchResults(value.toLowerCase(), false);
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
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
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              searchClientsController.clear();
                              filterSearchResults("", false);
                            },
                            icon: Icon(Icons.clear, color: Colors.grey,),
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                      )
                    ) : SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    filteredClients.length != 0 ?
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 0),
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: filteredClients.length,
                              itemBuilder: (context, index) {
                                Usuario user = filteredClients[index];
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor.withOpacity(0.3)),
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
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "@${user.nick!}",
                                            style: TextStyle(color: Colors.grey, fontSize: 14),
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
                                        onPressed: () {
                                          Navigator.push(context, CupertinoPageRoute<Null>(
                                            builder: (context) => ChatDetailPage(user)),);
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
                            Text(AppLocalizations.of(context)!.noMembersFound, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center,),
                            SizedBox(height: MediaQuery.of(context).size.height*0.12),
                          ],
                        ),
                      ),
                  ],
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