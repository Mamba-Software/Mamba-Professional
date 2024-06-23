import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Room/RoomDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:shimmer/shimmer.dart';
import 'Chat.dart';
import 'package:mamba/commons/extensions/context.dart';

class ChatCore extends StatefulWidget {
  const ChatCore({super.key});

  @override
  _ChatCoreState createState() => _ChatCoreState();
}

class _ChatCoreState extends State<ChatCore> {
  bool _error = false;
  bool _initialized = false;
  User? _user;

  final _roomDataService = RoomDataService();
  final _userDataService = UserDataService();
  var searchController = TextEditingController();
  bool searchClicked = false;
  bool isFiltered = false;

  List<types.Room> allRooms = [];
  List<types.Room> rooms = [];
  List<String> userIsBlockedBy = [];

  @override
  void initState() {
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
      userIsBlockedBy =
          await _userDataService.getBlockedByUsers(currentUser.id!);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _initialized = true;
        });
      });
    } catch (e) {
      print(e.toString());
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
        if (item.name!.toLowerCase().startsWith(query)) {
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
            return room.lastMessages[0].author.firstName +
                ': ' +
                room.lastMessages[0].text;
          } else {
            return '${context.l10n.user}: ' + room.lastMessages[0].text;
          }
        } else {
          return room.lastMessages[0].text;
        }
      } else {
        return room.lastMessages[0].text;
      }
    } else {
      return context.l10n.noMessages;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: Text(
              context.l10n.chatBottomNav,
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: searchClicked
                ? PreferredSize(
                    preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height * 0.10,
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.10,
                      child: Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.04,
                              left: MediaQuery.of(context).size.width * 0.04,
                              top: MediaQuery.of(context).size.width * 0.03,
                              bottom: MediaQuery.of(context).size.width * 0.02),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              // Filter chats
                              filterSearchResults(value.toLowerCase());
                            },
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                              hintText: context.l10n.search,
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  filterSearchResults("");
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          )),
                    ))
                : PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Container(),
                  ),
            actions: [
              !searchClicked
                  ? IconButton(
                      icon: Icon(Icons.search,
                          size: MediaQuery.of(context).size.width * 0.07,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        setState(() {
                          searchClicked = !searchClicked;
                        });
                      })
                  : IconButton(
                      icon: Icon(Icons.clear,
                          size: MediaQuery.of(context).size.width * 0.07,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        setState(() {
                          searchClicked = !searchClicked;
                        });
                      }),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
            ]),
        body: Container(
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: 8,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01),
                  child: ListTile(
                    dense: true,
                    leading: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.height * 0.08,
                        decoration: const BoxDecoration(
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
                            height: MediaQuery.of(context).size.height * 0.025,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005),
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.02,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: const BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
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
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.10,
                        decoration: const BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    onTap: null,
                  ),
                );
              }),
        ),
      );
    }

    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: Text(
              context.l10n.chatBottomNav,
            ),
            centerTitle: true,
            bottom: searchClicked
                ? PreferredSize(
                    preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height * 0.10,
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.10,
                      child: Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.04,
                              left: MediaQuery.of(context).size.width * 0.04,
                              top: MediaQuery.of(context).size.width * 0.03,
                              bottom: MediaQuery.of(context).size.width * 0.02),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              // Filter chats
                              filterSearchResults(value.toLowerCase());
                            },
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                              hintText: context.l10n.search,
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  filterSearchResults("");
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          )),
                    ))
                : PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Container(),
                  ),
            actions: [
              !searchClicked
                  ? IconButton(
                      icon: Icon(Icons.search,
                          size: MediaQuery.of(context).size.width * 0.07,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        setState(() {
                          searchClicked = !searchClicked;
                        });
                      })
                  : IconButton(
                      icon: Icon(Icons.clear,
                          size: MediaQuery.of(context).size.width * 0.07,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        setState(() {
                          searchClicked = !searchClicked;
                        });
                      }),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
            ]),
        body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: 8,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01),
                child: ListTile(
                  dense: true,
                  leading: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.height * 0.08,
                      decoration: const BoxDecoration(
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
                          height: MediaQuery.of(context).size.height * 0.025,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                      Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.02,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: const BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
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
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.10,
                      decoration: const BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  onTap: null,
                ),
              );
            }),
      );
    }

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Text(
            context.l10n.chatBottomNav,
          ),
          centerTitle: true,
          bottom: searchClicked
              ? PreferredSize(
                  preferredSize: Size.fromHeight(
                    MediaQuery.of(context).size.height * 0.10,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: Padding(
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.04,
                            left: MediaQuery.of(context).size.width * 0.04,
                            top: MediaQuery.of(context).size.width * 0.03,
                            bottom: MediaQuery.of(context).size.width * 0.02),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            // Filter chats
                            filterSearchResults(value.toLowerCase());
                          },
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            hintText: context.l10n.search,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: MediaQuery.of(context).size.width * 0.06,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                searchController.clear();
                                filterSearchResults("");
                              },
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(0),
                          ),
                        )),
                  ))
              : PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(),
                ),
          actions: [
            !searchClicked
                ? IconButton(
                    icon: Icon(Icons.search,
                        size: MediaQuery.of(context).size.width * 0.07,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        searchClicked = !searchClicked;
                      });
                    })
                : IconButton(
                    icon: Icon(Icons.clear,
                        size: MediaQuery.of(context).size.width * 0.07,
                        color: Theme.of(context).primaryColor),
                    onPressed: () {
                      setState(() {
                        searchClicked = !searchClicked;
                      });
                    }),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
            ),
          ]),
      body: StreamBuilder<List<types.Room>>(
        stream: FirebaseChatCore.instance.rooms(orderByUpdatedAt: true),
        //initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.01),
                    child: ListTile(
                      dense: true,
                      leading: Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.height * 0.08,
                          decoration: const BoxDecoration(
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
                              height:
                                  MediaQuery.of(context).size.height * 0.025,
                              width: MediaQuery.of(context).size.width * 0.3,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
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
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005),
                          Shimmer.fromColors(
                            baseColor: AppColors.grey,
                            highlightColor: AppColors.grey.withOpacity(0.5),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.02,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: const BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
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
                          height: MediaQuery.of(context).size.height * 0.04,
                          width: MediaQuery.of(context).size.width * 0.1,
                          decoration: const BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      onTap: null,
                    ),
                  );
                });
          } else if (snapshot.data!.isEmpty &&
              snapshot.connectionState == ConnectionState.active) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.3,
                        child: Image.asset(Assets.chatImage)),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.1),
                      child: Text(
                        context.l10n.noMessages,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            allRooms = snapshot.data!;
            if (!isFiltered) {
              return ListView.builder(
                itemCount: allRooms.length,
                itemBuilder: (context, index) {
                  final types.Room room;
                  room = allRooms[index];

                  types.User? userAux;
                  if (room.type.toString() != "RoomType.group") {
                    userAux = room.users.firstWhere(
                      (u) => u.id != _user!.uid,
                    );
                    if (userIsBlockedBy.contains(userAux.id)) {
                      return Container();
                    }
                  }

                  bool Read = true;
                  if (room.lastMessages != null &&
                      room.lastMessages![0].metadata![currentUser.id] ==
                          "delivered") {
                    Read = false;
                  }

                  var dt = DateTime.fromMillisecondsSinceEpoch(room.updatedAt!);

                  return GestureDetector(
                    onTap: () async {
                      if (!brandIsActive) {
                        await navigateToPayWall(context);
                      } else {
                        Navigator.push(
                            context,
                            CupertinoPageRoute<bool>(
                              builder: (context) => ChatPage(
                                room: room,
                              ),
                            )).whenComplete(() async {
                          room.metadata!["active${currentUser.id!}"] = false;
                          _roomDataService.updateRoom(room.id, room.metadata!);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                CircularImage(
                                  size:
                                      MediaQuery.of(context).size.width * 0.15,
                                  image: room.imageUrl,
                                  color: Theme.of(context).primaryColor,
                                  borderWidth: 1,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        room.name ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.005,
                                      ),
                                      TextField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: context
                                              .theme.scaffoldBackgroundColor,
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: Read
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                          hintText: returnChatHintMessage(room),
                                          contentPadding:
                                              const EdgeInsets.all(0),
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
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.04,
                          ),
                          Icon(
                            room.type.toString() == "RoomType.group"
                                ? Icons.groups
                                : room.metadata!["trainer${userAux!.id}"] ==
                                        true
                                    ? Icons.record_voice_over
                                    : Icons.directions_run,
                            color: Theme.of(context).primaryColor,
                            size: room.type.toString() == "RoomType.group"
                                ? 25
                                : 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.04,
                          ),
                          Text(
                            (DateFormat('dd/MM/yy').format(dt)).toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 10),
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
                  final types.Room room;
                  room = rooms[index];

                  types.User? userAux;
                  if (room.type.toString() != "RoomType.group") {
                    userAux = room.users.firstWhere(
                      (u) => u.id != _user!.uid,
                    );
                    if (userIsBlockedBy.contains(userAux.id)) {
                      return Container();
                    }
                  }

                  bool Read = true;
                  if (room.lastMessages != null &&
                      room.lastMessages![0].metadata![currentUser.id] ==
                          "delivered") {
                    Read = false;
                  }

                  var dt = DateTime.fromMillisecondsSinceEpoch(room.updatedAt!);

                  return GestureDetector(
                    onTap: () async {
                      if (!brandIsActive) {
                        await navigateToPayWall(context);
                      } else {
                        Navigator.push(
                            context,
                            CupertinoPageRoute<Null>(
                              builder: (context) => ChatPage(
                                room: room,
                              ),
                            )).whenComplete(() {
                          room.metadata!["active${currentUser.id!}"] = false;
                          _roomDataService.updateRoom(room.id, room.metadata!);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                CircularImage(
                                  size:
                                      MediaQuery.of(context).size.width * 0.15,
                                  image: room.imageUrl,
                                  color: Theme.of(context).primaryColor,
                                  borderWidth: 1,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        room.name ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.005,
                                      ),
                                      TextField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: context
                                              .theme.scaffoldBackgroundColor,
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: Read
                                                      ? FontWeight.normal
                                                      : FontWeight.bold),
                                          hintText: returnChatHintMessage(room),
                                          contentPadding:
                                              const EdgeInsets.all(0),
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
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.04,
                          ),
                          Icon(
                            room.type.toString() == "RoomType.group"
                                ? Icons.groups
                                : room.metadata!["trainer${userAux!.id}"] ==
                                        true
                                    ? Icons.record_voice_over
                                    : Icons.directions_run,
                            color: Theme.of(context).primaryColor,
                            size: room.type.toString() == "RoomType.group"
                                ? 25
                                : 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.04,
                          ),
                          Text(
                            (DateFormat('dd/MM/yy').format(dt)).toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 10),
                          ),
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
