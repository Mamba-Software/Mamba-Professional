import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:intl/intl.dart';

import 'package:mamba_castelldefels/Data/RoomDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'Chat.dart';
import 'Users.dart';
import 'Util.dart';
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
  var searchController = TextEditingController();
  bool searchClicked = false;
  bool isFiltered = false;

  List<types.Room> allRooms = [];
  List<types.Room> rooms = [];

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
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

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        setState(() {
          _user = user;
        });
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _buildAvatar(types.Room room) {
    var color = Colors.transparent;

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return LoadingView();
    }

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width*0.01,),
              Text(AppLocalizations.of(context)!.chatBottomNav, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
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
          ) :  PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Container(),
          ),
          actions: [
            !searchClicked ?
            IconButton(
                icon: Icon(Icons.search, size: 35, color: Theme.of(context).primaryColor),
                onPressed: () {
                  setState(() {
                    searchClicked = !searchClicked;
                  });
                }
            )
                :
            IconButton(
                icon: Icon(Icons.clear, size: 35, color: Theme.of(context).primaryColor),
                onPressed: () {
                  setState(() {
                    searchClicked = !searchClicked;
                  });
                }
            ),
            SizedBox(width: MediaQuery.of(context).size.width*0.03,),
          ]
      ),
      body
          : StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: true),
        initialData: const [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return LoadingViewPurple();
          }
          else if (snapshot.data!.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height *0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height *0.25,
                        child: Image.asset(Constants.chatImage)
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
                      child: Text(AppLocalizations.of(context)!.noMessages, style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080)), textAlign: TextAlign.center,),
                    ),
                  ),
                ],
              ),
            );
          }
          else {
            allRooms = snapshot.data!;
              if (!isFiltered) {
                print("hola");
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
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.bold),),
                                          SizedBox(height: MediaQuery
                                              .of(context)
                                              .size
                                              .height * 0.005,),
                                          TextField(
                                            enabled: false,
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: Read?FontWeight.normal:FontWeight.bold),
                                              hintText: room.lastMessages !=
                                                  null ? room.type.toString() == "RoomType.group"? room.lastMessages[0].author.id != currentUser.id ? room.lastMessages[0].author.firstName + ' ' + room.lastMessages[0].author.lastName + ': ' + room.lastMessages[0]
                                                  .text : room.lastMessages[0].text : room.lastMessages[0].text : '',
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
                            Text((DateFormat('dd/MM/yyyy, HH:mm').format(dt))
                                .toString(), style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              else {
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
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.bold),),
                                          SizedBox(height: MediaQuery
                                              .of(context)
                                              .size
                                              .height * 0.005,),
                                          TextField(
                                            enabled: false,
                                            decoration: InputDecoration(
                                              // hintStyle: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead?FontWeight.bold:FontWeight.normal),
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
                            Text((DateFormat('dd/MM/yyyy, HH:mm').format(dt))
                                .toString(), style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
          }
/*
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {

              final room_aux = snapshot.data![index];
              var user_aux = room_aux.users.firstWhere(
                    (u) => u.id != _user!.uid,
              );
              final room;
              if(room_aux.type != "group") {
                room =  room_aux.copyWith(imageUrl: room_aux.imageUrl, metadata: room_aux.metadata, name: room_aux.metadata![user_aux.id], type: room_aux.type, updatedAt: room_aux.updatedAt, users: room_aux.users);
              }
              else  room = room_aux;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        room: room,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildAvatar(room),
                      Text(room.name ?? ''),
                    ],
                  ),
                ),
              );
            },
          );

 */
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _user == null
                ? null
                : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const UsersPage(),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _user == null ? null : logout,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Rooms'),
      ),
      body: _user == null
          ? Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(
          bottom: 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Not authenticated'),
            TextButton(
              onPressed: () {

              },
              child: const Text('Login'),
            ),
          ],
        ),
      )
          : StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: true),
        initialData: const [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: const Text('No rooms'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final room_aux = snapshot.data![index];
              var user_aux = room_aux.users.firstWhere(
                    (u) => u.id != _user!.uid,
              );
              final room;
              if(!room_aux.metadata!.containsKey("isGroup")) {
                 room =  room_aux.copyWith(imageUrl: room_aux.imageUrl, metadata: room_aux.metadata, name: room_aux.metadata![user_aux.id], type: room_aux.type, updatedAt: room_aux.updatedAt, users: room_aux.users);
              }
              else  room = room_aux;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        room: room,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildAvatar(room),
                      Text(room.name ?? ''),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
