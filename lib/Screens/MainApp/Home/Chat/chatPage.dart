import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/ChatUsers.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'conversationList.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();

  var searchController = TextEditingController();

  List<ChatUsers> chatUsers = [];
  List<ChatUsers> allChatUsers = [];

  List<Conversation> conversations = [];

  bool isFiltered = false;


  Map<String, dynamic> toMap(String? id) {
    return {
      'uid': id,
    };
  }

  Map<String, dynamic> toMapReadMesage(String? id, bool? isMessageRead) {
    return {
      'uid': id,
      'isMessageRead': isMessageRead,
    };
  }

  void filterSearchResults(String query) {
    List<ChatUsers> chatUsersFiltered = [];
      if (query.isNotEmpty || query != "") {
        for (var item in allChatUsers) {
          if (item.name!.toLowerCase().startsWith(query)) {
            chatUsersFiltered.add(item);
          }
        }
        setState(() {
          isFiltered = true;
          chatUsers = chatUsersFiltered;
        });
      } else {
        setState(() {
          isFiltered = false;
          chatUsers = allChatUsers;
        });
    }
  }

  bool searchClicked = false;

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _accessDatabase.getUserConversations(toMap(currentUser.id)),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                        height: MediaQuery.of(context).size.height*0.65,
                        child: Center(
                            child: LoadingViewPurple()
                        )
                    );
                  } else {
                    return FutureBuilder<List<ChatUsers>>(
                        future: documentsToConversations(
                            snapshot.data!.docs, chatUsers),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            if (!isFiltered) {
                              chatUsers = snapshot.data!;
                              return ListView.builder(
                                itemCount: chatUsers.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ConversationList(
                                      name: chatUsers[index].name!,
                                      messageText: chatUsers[index]
                                          .messageText!,
                                      imageUrl: chatUsers[index].imageURL!,
                                      time: chatUsers[index].time!,
                                      isMessageRead: chatUsers[index]
                                          .isMessageRead!,
                                      userId: chatUsers[index].userId!,
                                      isGroup: chatUsers[index].isGroup!,
                                      iconData: chatUsers[index].iconData!);
                                },
                              );
                            } else {
                              return ListView.builder(
                                itemCount: chatUsers.length,
                                shrinkWrap: true,
                                //padding: EdgeInsets.only(top: 16),
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ConversationList(
                                      name: chatUsers[index].name!,
                                      messageText: chatUsers[index]
                                          .messageText!,
                                      imageUrl: chatUsers[index].imageURL!,
                                      time: chatUsers[index].time!,
                                      isMessageRead: chatUsers[index]
                                          .isMessageRead!,
                                      userId: chatUsers[index].userId!,
                                      isGroup: chatUsers[index].isGroup!,
                                      iconData: chatUsers[index].iconData!);
                                },
                              );
                            }
                          } else {
                            return Container(
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.65,
                                child: Center(
                                    child: LoadingViewPurple()
                                )
                            );
                          }
                        }
                      );
                   }
                }),
          ],
        ),
      ),
    );
  }

  Future<List<ChatUsers>> documentsToConversations (
      List<DocumentSnapshot> documents, List<ChatUsers> _chatUsers) async {
    List<ChatUsers> chatUsers = [];
    Conversation conv;
    Usuario user;
    String time;
    bool isMessageRead = false;
    IconData iconData;

    for (int i = 0; i < documents.length; i++) {
      conv = Conversation.fromObject(documents[i], documents[i].id);
      time =
          conv.hour! +
          ':' +
          conv.minute! +
          '\n' +
          conv.day! +
          '/' +
          conv.month! +
          '/' +
          conv.year![2] +
          conv.year![3];

      if (conv.brandId == 'null') {
        if(conv.isMessageRead[0]['uid'] == currentUser.id) isMessageRead = conv.isMessageRead[0]['isMessageRead'];
        else isMessageRead = conv.isMessageRead[1]['isMessageRead'];
        if (conv.users[0]['uid'] == currentUser.id) {
          user = await _accessDatabase.getUserDetails(conv.users[1]['uid']);
          if(user.isTrainer!) iconData = Icons.record_voice_over;
          else iconData = Icons.directions_run;
          chatUsers.add(ChatUsers(
              name: user.name,
              messageText: conv.lastMessage,
              imageURL: user.imageUrl,
              time: time,
              isMessageRead: isMessageRead,
              userId: user.id,
              isGroup: false,
              iconData: iconData));
        } else {
          user = await _accessDatabase.getUserDetails(conv.users[0]['uid']);
          if(user.isTrainer!) iconData = Icons.record_voice_over;
          else iconData = Icons.directions_run;
          chatUsers.add(ChatUsers(
              name: user.name,
              messageText: conv.lastMessage,
              imageURL: user.imageUrl,
              time: time,
              isMessageRead: isMessageRead,
              userId: user.id,
              isGroup: false,
              iconData: iconData));
        }
      } else {
        iconData = Icons.groups;
        for(int j = 0; j < conv.isMessageRead.length; ++j) {
          if(conv.isMessageRead[j]['uid'] == currentUser.id) isMessageRead = conv.isMessageRead[j]['isMessageRead'];
        }
        String? userId = await _accessDatabase.getLastUserMessageSent(conv.conversationId);
        if(userId != '' && userId != currentUser.id) {
          user = await _accessDatabase.getUserDetails(userId!);
          chatUsers.add(ChatUsers(
              name: currentBrand.name!,
              messageText: user.name! + ': ' + conv.lastMessage!,
              imageURL: currentBrand.logoUrl,
              time: time,
              isMessageRead: isMessageRead,
              userId: currentBrand.id,
              isGroup: true,
              iconData: iconData));
        }
        else {
          chatUsers.add(ChatUsers(
              name: currentBrand.name,
              messageText: conv.lastMessage,
              imageURL: currentBrand.logoUrl,
              time: time,
              isMessageRead: isMessageRead,
              userId: currentBrand.id,
              isGroup: true,
              iconData: iconData));
        }
      }
    }
    allChatUsers = chatUsers;
    return chatUsers;
  }
}
