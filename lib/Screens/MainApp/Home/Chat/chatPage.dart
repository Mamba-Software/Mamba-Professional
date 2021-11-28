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

  List<ChatUsers> chatUsers = [
    ChatUsers(
        name: "Test 2",
        messageText: "Awesome Setup",
        imageURL: "images/userImage1.jpeg",
        time: "Now"),
    ChatUsers(
        name: "Test 3",
        messageText: "Awesome Setup",
        imageURL: "images/userImage1.jpeg",
        time: "Now"),
  ];

  List<Conversation> conversations = [];

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
                stream: _accessDatabase.getUserConversations(currentUser),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return LoadingView();
                  } else {
                    chatUsers = documentsToConversations(
                        snapshot.data!.docs, chatUsers);
                    chatUsers = [
                      ChatUsers(
                          name: "Test 2",
                          messageText: "Awesome Setup",
                          imageURL: "images/userImage1.jpeg",
                          time: "Now"),
                      ChatUsers(
                          name: "Test 3",
                          messageText: "Awesome Setup",
                          imageURL: "images/userImage1.jpeg",
                          time: "Now"),
                    ];
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
    List<ChatUsers> chatUsers = _chatUsers;
    Conversation conv;
    Usuario user;

    for (int i = documents.length - 1; i >= chatUsers.length; i--) {
      conv = Conversation.fromObject(documents[i], documents[i].id);
      if (conv.brandId != null) {
        if (conv.users[0].id == currentUser.id) {
          chatUsers.add(ChatUsers(
              name: conv.users[1].name!,
              messageText: "Awesome Setup",
              imageURL: conv.users[1].imageUrl!,
              time: conv.minute!));
        } else {
          chatUsers.add(ChatUsers(
              name: conv.users[0].name!,
              messageText: "Awesome Setup",
              imageURL: conv.users[0].name!,
              time: conv.minute!));
        }
      }
    }
    return chatUsers;
  }
}
