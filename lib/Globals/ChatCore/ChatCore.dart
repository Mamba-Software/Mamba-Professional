import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:shimmer/shimmer.dart';
import 'Chat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatCore extends StatefulWidget {
  const ChatCore({Key? key}) : super(key: key);

  @override
  _ChatCoreState createState() => _ChatCoreState();
}

class _ChatCoreState extends State<ChatCore> {

  bool _error = false;
  bool _initialized = false;
  User? _user;

  var _roomDataService = new RoomDataService();
  final _userDataService = UserDataService();
  var searchController = TextEditingController();
  bool searchClicked = false;
  bool isFiltered = false;

  List<types.Room> allRooms = [];
  List<types.Room> rooms = [];
  List<String> userIsBlockedBy = [];

  @override
  void initState() {
    if(!brandIsActive)
    {
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute<void>(
          builder: (context) =>  PayWall(brandId: currentBrand.id!, comesFromInitPage: true,),
        ),
            (_) => false,
      );
    }
    super.initState();
    mixpanel!.track('user_chats_view');
    initializeFlutterFire();
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        setState(() {
          _user = user;
        });
      });
      userIsBlockedBy = await _userDataService.getBlockedByUsers(currentUser.id!);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _initialized = true;
        });
      });
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _error = true;
        });
      });
    }
  }

  void filterSearchResults(String query) {
    List<types.Room> roomsFiltered = [];
    if (query.isNotEmpty || query != "") {
      for (var item in allRooms) {
        if (item.name!.toLowerCase().startsWith(query)) {;
        roomsFiltered.add(item);
        }
      }
      setState(() {
        isFiltered = true;
        rooms = roomsFiltered;
      });
    } else {
      setState(() {
        isFiltered = false;
        rooms = allRooms;
      });
    }
  }

  String returnChatHintMessage(var room) {
    if (room.lastMessages != null) {
      if (room.type.toString() == "RoomType.group") {
        if (room.lastMessages[0].author.id != currentUser.id) {
          if (room.lastMessages[0].author.firstName != null) {
            return room.lastMessages[0].author.firstName + ': ' + room.lastMessages[0].text;
          } else {
            return AppLocalizations.of(context)!.user + ': ' + room.lastMessages[0].text;
          }
        } else {
          return room.lastMessages[0].text;
        }
      } else {
        return room.lastMessages[0].text;
      }
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                Text(AppLocalizations.of(context)!.chatBottomNav, style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
              ],
            ),
            centerTitle: false,
            bottom: searchClicked ? PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.10,),
                child: Container(
                  height: MediaQuery.of(context).size.height*0.10,
                  child: Padding(
                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.04,left: MediaQuery.of(context).size.width*0.04, top: MediaQuery.of(context).size.width*0.03, bottom: MediaQuery.of(context).size.width*0.02),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          // Filter chats
                          filterSearchResults(value.toLowerCase());
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
                            icon: Icon(Icons.delete_outline, color: Colors.grey, size: MediaQuery.of(context).size.width*0.06,),
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                      )
                  ),
                )
            ) :  PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: Container(),
            ),
            actions: [
              !searchClicked ?
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
              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
            ]
        ),
        body: Container(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: 8,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                  child: ListTile(
                    dense: true,
                    leading: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.08,
                        width: MediaQuery.of(context).size.height*0.08,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.025,
                            width: MediaQuery.of(context).size.width*0.3,
                            decoration: BoxDecoration(
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.02,
                            width: MediaQuery.of(context).size.width*0.5,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.04,
                        width: MediaQuery.of(context).size.width*0.10,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    onTap: null,
                  ),
                );
              }
          ),
        ),
      );
    }

    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                Text(AppLocalizations.of(context)!.chatBottomNav, style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
              ],
            ),
            centerTitle: false,
            bottom: searchClicked ? PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.10,),
                child: Container(
                  height: MediaQuery.of(context).size.height*0.10,
                  child: Padding(
                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.04,left: MediaQuery.of(context).size.width*0.04, top: MediaQuery.of(context).size.width*0.03, bottom: MediaQuery.of(context).size.width*0.02),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          // Filter chats
                          filterSearchResults(value.toLowerCase());
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
                            icon: Icon(Icons.delete_outline, color: Colors.grey, size: MediaQuery.of(context).size.width*0.06,),
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                      )
                  ),
                )
            ) :  PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: Container(),
            ),
            actions: [
              !searchClicked ?
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
              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
            ]
        ),
        body: Container(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: 8,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                  child: ListTile(
                    dense: true,
                    leading: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.08,
                        width: MediaQuery.of(context).size.height*0.08,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.025,
                            width: MediaQuery.of(context).size.width*0.3,
                            decoration: BoxDecoration(
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.02,
                            width: MediaQuery.of(context).size.width*0.5,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.04,
                        width: MediaQuery.of(context).size.width*0.10,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    onTap: null,
                  ),
                );
              }
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width*0.01,),
              Text(AppLocalizations.of(context)!.chatBottomNav, style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
            ],
          ),
          centerTitle: false,
          bottom: searchClicked ? PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.10,),
              child: Container(
                height: MediaQuery.of(context).size.height*0.10,
                child: Padding(
                    padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.04,left: MediaQuery.of(context).size.width*0.04, top: MediaQuery.of(context).size.width*0.03, bottom: MediaQuery.of(context).size.width*0.02),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        // Filter chats
                        filterSearchResults(value.toLowerCase());
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
                          icon: Icon(Icons.delete_outline, color: Colors.grey, size: MediaQuery.of(context).size.width*0.06,),
                        ),
                        contentPadding: EdgeInsets.all(0),
                      ),
                    )
                ),
              )
          ) :  PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Container(),
          ),
          actions: [
            !searchClicked ?
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
            SizedBox(width: MediaQuery.of(context).size.width*0.03,),
          ]
      ),
      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: true),
        //initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            print("1");
            return Container(
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                      child: ListTile(
                        dense: true,
                        leading: Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.08,
                            width: MediaQuery.of(context).size.height*0.08,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: Container(
                                height: MediaQuery.of(context).size.height*0.025,
                                width: MediaQuery.of(context).size.width*0.3,
                                decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: Container(
                                height: MediaQuery.of(context).size.height*0.02,
                                width: MediaQuery.of(context).size.width*0.5,
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: new BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.04,
                            width: MediaQuery.of(context).size.width*0.1,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: new BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        onTap: null,
                      ),
                    );
                  }
              ),
            );
          } else if (snapshot.data!.isEmpty && snapshot.connectionState == ConnectionState.active ) {
            print("2");
            return Container(
              height: MediaQuery.of(context).size.height *0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                        height: MediaQuery.of(context).size.width*0.3,
                        child: Image.asset(Constants.chatImage)
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
                      child: Text(AppLocalizations.of(context)!.noMessages, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                    ),
                  ),
                ],
              ),
            );
          } else {
            print("3");
            allRooms = snapshot.data!;
            if (!isFiltered) {
              return ListView.builder(
                itemCount: allRooms.length,
                itemBuilder: (context, index) {
                  final room;
                  room = allRooms[index];

                  var userAux;
                  if (room.type.toString() != "RoomType.group") {
                     userAux = room.users.firstWhere(
                          (u) => u.id != _user!.uid,
                    );
                     if(userIsBlockedBy.contains(userAux.id))
                     {
                       return Container();
                     }
                  }

                  bool Read = true;
                  if(room.lastMessages != null && room.lastMessages[0].metadata[currentUser.id] == "delivered") {
                    Read = false;
                  }

                  var dt = DateTime.fromMillisecondsSinceEpoch(
                      room.updatedAt);

                  return GestureDetector(
                    onTap: ()  {
                       Navigator.push(
                          context,
                          CupertinoPageRoute<bool>(
                            builder: (context) => ChatPage(
                              room: room,
                            ),
                          )
                      ).whenComplete(() async{
                        room.metadata!["active" + currentUser.id!] = false;
                        _roomDataService.updateRoom(room.id, room.metadata!);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                          MediaQuery
                              .of(context)
                              .size
                              .width *
                              0.04,
                          vertical:
                          MediaQuery
                              .of(context)
                              .size
                              .height *
                              0.01),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                CircularImage(
                                  size: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.15,
                                  image: room.imageUrl,
                                  color: Theme
                                      .of(context)
                                      .primaryColor,
                                  borderWidth: 1,
                                ),
                                SizedBox(width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.03,),
                                Expanded(
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Text(room.name ?? '',
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * 0.005,),
                                        TextField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.grey.shade600, fontWeight: Read?FontWeight.normal:FontWeight.bold),
                                            hintText: returnChatHintMessage(room),
                                            contentPadding: EdgeInsets.all(0),
                                            isDense: true,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),

                                        // Text(widget.messageText,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.04,),
                          Icon(
                            room.type.toString() == "RoomType.group" ? Icons
                                .groups : room.metadata!["trainer" + userAux.id] == true
                                ? Icons.record_voice_over
                                : Icons.directions_run,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            size: room.type.toString() == "RoomType.group"
                                ? 25
                                : 20,
                          ),
                          SizedBox(width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.04,),
                          Text(
                            (DateFormat('dd/MM/yy').format(dt)).toString(),
                            style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room;
                  room = rooms[index];

                  var userAux;
                  if (room.type.toString() != "RoomType.group") {
                    userAux = room.users.firstWhere(
                          (u) => u.id != _user!.uid,
                    );
                    if(userIsBlockedBy.contains(userAux.id))
                    {
                      return Container();
                    }
                  }


                  bool Read = true;
                  if(room.lastMessages != null && room.lastMessages[0].metadata[currentUser.id] == "delivered") {
                    Read = false;
                  }

                  var dt = DateTime.fromMillisecondsSinceEpoch(
                      room.updatedAt);

                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute<Null>(
                              builder: (context) => ChatPage(
                                room: room,
                              ),
                            )
                        ).whenComplete(() {
                          room.metadata!["active" + currentUser.id!] = false;
                          _roomDataService.updateRoom(room.id, room.metadata!);
                        });
                      },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                          MediaQuery
                              .of(context)
                              .size
                              .width *
                              0.04,
                          vertical:
                          MediaQuery
                              .of(context)
                              .size
                              .height *
                              0.01),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                CircularImage(
                                  size: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.15,
                                  image: room.imageUrl,
                                  color: Theme
                                      .of(context)
                                      .primaryColor,
                                  borderWidth: 1,
                                ),
                                SizedBox(width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.03,),
                                Expanded(
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Text(room.name ?? '',
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * 0.005,),
                                        TextField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.grey.shade600, fontWeight: Read?FontWeight.normal:FontWeight.bold),
                                            hintText: room.lastMessages !=
                                                null ? room.lastMessages[0]
                                                .text : 'test',
                                            contentPadding: EdgeInsets.all(0),
                                            isDense: true,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),

                                        // Text(widget.messageText,style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.04,),
                          Icon(
                            room.type.toString() == "RoomType.group" ? Icons
                                .groups : room.metadata!["trainer" + userAux.id] == true
                                ? Icons.record_voice_over
                                : Icons.directions_run,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            size: room.type.toString() == "RoomType.group"
                                ? 25
                                : 20,
                          ),
                          SizedBox(width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.04,),
                          Text((DateFormat('dd/MM/yy').format(dt))
                              .toString(), style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
