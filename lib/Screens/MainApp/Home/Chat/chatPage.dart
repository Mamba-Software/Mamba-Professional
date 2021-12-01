import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Models/ChatUsers.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

import 'conversationList.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();

  List<ChatUsers> chatUsers = [];


  List<Conversation> conversations = [];

  Map<String, dynamic> toMap(String? id,String? name, String? imageURL) {
    return {
      'uid': id,
      'name': name,
      'image': imageURL,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: _accessDatabase.getUserConversations(toMap(currentUser.id,currentUser.name,currentUser.imageUrl)),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return LoadingView();
                  } else {
                    chatUsers = documentsToConversations(
                        snapshot.data!.docs, chatUsers);
                    return ListView.builder(
                      itemCount: chatUsers.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 16),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ConversationList(
                          name: chatUsers[index].name!,
                          messageText: chatUsers[index].messageText!,
                          imageUrl: chatUsers[index].imageURL!,
                          time: chatUsers[index].time!,
                          isMessageRead:
                              (index == 0 || index == 3) ? true : false,
                          userId: chatUsers[index].userId!,
                        );
                      },
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  List<ChatUsers> documentsToConversations(
      List<DocumentSnapshot> documents, List<ChatUsers> _chatUsers) {
    List<ChatUsers> chatUsers = [];
    Conversation conv;
    Usuario user;
    String time;
    for (int i = 0; i < documents.length; i++) {
      conv = Conversation.fromObject(documents[i], documents[i].id);
      time = conv.hour! + ':' + conv.minute! + ':' + conv.second!;
      if (conv.brandId != null) {
        if (conv.users[0]['uid'] == currentUser.id) {
          chatUsers.add(ChatUsers(
              name: conv.users[1]['name'],
              messageText: conv.lastMessage,
              imageURL: conv.users[1]['image'],
              time: time,
              userId: conv.users[1]['uid']));
        } else {
          chatUsers.add(ChatUsers(
              name: conv.users[0]['name'],
              messageText: conv.lastMessage,
              imageURL: conv.users[0]['image'],
              time: time,
              userId: conv.users[0]['uid']));
        }
      }

      else {

      }
    }
    return chatUsers;
  }
}
