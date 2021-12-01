import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/ChatMessage.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Message.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

class ChatDetailPage extends StatefulWidget {
  final Usuario user;

  ChatDetailPage(this.user);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  var _accessDatabase = new DatabaseAccess();

  String? conversationId;

  var editingController = TextEditingController();

  bool isLoading = true;

  String? messageNow;

  List<ChatMessage> messages = [];

  List<Conversation> conversations = [];

  Map<String, dynamic> toMap(String? id, String? name, String? imageURL) {
    return {
      'uid': id,
      'name': name,
      'image': imageURL,
    };
  }

  void initState() {
    super.initState();
    getConversationId();
  }

  Future<void> getConversationId() async {
    conversations = await this._accessDatabase.getConversationByUsers(
        toMap(currentUser.id, currentUser.name, currentUser.imageUrl),
        toMap(widget.user.id, widget.user.name, widget.user.imageUrl));
    if(conversations.length == 0) {
      conversationId = '';
    }
    else conversationId = conversations[0].conversationId;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Scaffold(
      body: LoadingViewPurple(),
    )
    :
    Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.imageUrl!),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.user.name!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: _accessDatabase.getConversationMessages(conversationId),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  messages = documentsToMessages(snapshot.data!.docs);
                  return SingleChildScrollView(
                    child: ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: 14, right: 14, top: 10, bottom: 10),
                              child: Align(
                                alignment: (messages[index].messageType == "receiver"
                                    ? Alignment.topLeft
                                    : Alignment.topRight),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: (messages[index].messageType == "receiver"
                                        ? Colors.grey.shade200
                                        : Styles.mainColor),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    messages[index].messageContent!,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                            if (index == messages.length-1) SizedBox(height: MediaQuery.of(context).size.height*0.08),
                          ],
                        );
                      },
                    ),
                  );
                }
                else return LoadingView();
              }
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: MediaQuery.of(context).size.height*0.08,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: editingController,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      DateTime today = DateTime.now();
                      if (editingController.text != '') {
                        if (messages.length == 0) {
                          List<Map> chatUsers = [];
                          chatUsers.add(toMap(currentUser.id, currentUser.name,
                              currentUser.imageUrl));
                          chatUsers.add(toMap(widget.user.id, widget.user.name,
                              widget.user.imageUrl));
                          conversationId =
                          await _accessDatabase.addConversation(
                              chatUsers,
                              null,
                              today.year.toString(),
                              today.month.toString(),
                              today.day.toString(),
                              today.hour.toString(),
                              today.minute.toString(),
                              today.second.toString(),
                              editingController.text);
                        }
                        else {
                          await _accessDatabase.updateConversation(
                            conversationId,
                            editingController.text,
                            today.year.toString(),
                            today.month.toString(),
                            today.day.toString(),
                            today.hour.toString(),
                            today.minute.toString(),
                            today.second.toString(),
                          );
                        }
                        _accessDatabase.addMessage(
                            editingController.text,
                            currentUser.id,
                            today.year.toString(),
                            today.month.toString(),
                            today.day.toString(),
                            today.hour.toString(),
                            today.minute.toString(),
                            today.second.toString(),
                            conversationId);

                        editingController.text = '';

                        setState(() {

                        });

                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Styles.mainColor,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<ChatMessage> documentsToMessages(
    List<DocumentSnapshot> documents) {
  List<ChatMessage> chatMessages = [];
  Message message;
  String time;
  for (int i = 0; i < documents.length; i++) {
    message = Message.fromObject(documents[i], documents[i].id);
    time = message.hour! + ':' + message.minute! + ':' + message.second!;
    if (message.userSent == currentUser.id) {
      chatMessages.add(ChatMessage(
          messageContent: message.message,
          messageType: "sender",
          time: time));
    } else {
      chatMessages.add(ChatMessage(
          messageContent: message.message,
          messageType: "receiver",
          time: time));
    }
  }
  return chatMessages;
}
