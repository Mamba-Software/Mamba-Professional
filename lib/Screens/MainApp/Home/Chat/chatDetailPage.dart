import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/ChatMessage.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Message.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:page_transition/page_transition.dart';

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
  var scrollController = ScrollController();

 // ItemScrollController _scrollController = ItemScrollController();

  bool isLoading = true;

  String? messageNow;

  String timeDayGolbal = '';

  List<ChatMessage> messages = [];
  List<Message> notChatMessages = [];

  List<Conversation> conversations = [];

  Map<String, dynamic> toMap(String? id, String? name, String? imageURL) {
    return {
      'uid': id,
      'name': name,
      'image': imageURL,
    };
  }

  Column messageTextNotNewData(var index, String timeHour) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal:
                MediaQuery.of(context)
                    .size
                    .width *
                    0.01,
                vertical:
                MediaQuery.of(context)
                    .size
                    .height *
                    0.01),
            child: Align(
              alignment: (messages[index]
                  .messageType ==
                  "sender"
                  ? Alignment.topRight
                  : Alignment.topLeft),
              child: Container(
                //width: MediaQuery.of(context).size.width*0.50,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                      20),
                  color: (messages[index]
                      .messageType ==
                      "sender"
                      ? Styles.mainColor
                      : Colors.grey.shade200),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .end,
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            messages[index]
                                .messageContent!,
                            style: TextStyle(
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(
                              context)
                              .size
                              .width *
                              0.02,
                        ),
                        Column(children: [
                          SizedBox(
                            height: MediaQuery.of(
                                context)
                                .size
                                .height *
                                0.01,
                          ),
                          Text(
                            timeHour,
                            style: TextStyle(
                                fontSize: 12),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (index == messages.length - 1)
            SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height *
                    0.08),
        ],
      );
  }

  Column messageTextNewData(var index, String timeHour, String timeDay) {
      return Column(
        children: [
          Text(
            timeDay,
            style: TextStyle(fontSize: 15),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal:
                MediaQuery.of(context)
                    .size
                    .width *
                    0.01,
                vertical:
                MediaQuery.of(context)
                    .size
                    .height *
                    0.01),
            child: Align(
              alignment: (messages[index]
                  .messageType ==
                  "sender"
                  ? Alignment.topRight
                  : Alignment.topLeft),
              child: Container(
                //width: MediaQuery.of(context).size.width*0.50,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                      20),
                  color: (messages[index]
                      .messageType ==
                      "sender"
                      ? Styles.mainColor
                      : Colors.grey.shade200),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .end,
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            messages[index]
                                .messageContent!,
                            style: TextStyle(
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(
                              context)
                              .size
                              .width *
                              0.02,
                        ),
                        Column(children: [
                          SizedBox(
                            height: MediaQuery.of(
                                context)
                                .size
                                .height *
                                0.01,
                          ),
                          Text(
                            timeHour,
                            style: TextStyle(
                                fontSize: 12),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (index == messages.length - 1)
            SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height *
                    0.08),
        ],
      );
  }

  String getTimeHour(var index) {
    return messages[index]
        .time![messages[index].time!.length - 8] +
        messages[index]
            .time![messages[index].time!.length - 7] +
        messages[index]
            .time![messages[index].time!.length - 6] +
        messages[index]
            .time![messages[index].time!.length - 5] +
        messages[index]
            .time![messages[index].time!.length - 4];
  }

  String getTimeDay(var index) {
    return messages[index].time![0] +
        messages[index].time![1] +
        messages[index].time![2] +
        messages[index].time![3] +
        messages[index].time![4] +
        messages[index].time![5] +
        messages[index].time![6] +
        messages[index].time![7] +
        messages[index].time![8] +
        messages[index].time![9] +
        messages[index].time![10];
  }

  void initState() {
    timeDayGolbal = '';
    super.initState();
    getConversationId();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }));
  }

  Future<void> getConversationId() async {
    conversations = await this._accessDatabase.getConversationByUsers(
        toMap(currentUser.id, currentUser.name, currentUser.imageUrl),
        toMap(widget.user.id, widget.user.name, widget.user.imageUrl));
    if(conversations.length == 0) {
      conversationId = '';
    }
    else {
      conversationId = conversations[0].conversationId;
      notChatMessages = await _accessDatabase.getConversationMessagesInit(conversationId);
      messages = await initMessages(notChatMessages);

    }
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
        elevation: 4,
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).accentColor,
        leadingWidth: MediaQuery.of(context).size.width*0.07,
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        title: Row(
          children: [
            GestureDetector(
              child: CircularImage(
                size: MediaQuery.of(context).size.width*0.1,
                image: widget.user.imageUrl!,
                color: Theme.of(context).accentColor,
                borderWidth: 0.1,
              ),
              onTap: () {
                Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ProfileViewUser(userID: widget.user.id!, viewOnly: true)));
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width*0.03,),
            Text(
              widget.user.name!,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
              stream: _accessDatabase.getConversationMessages(conversationId),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  timeDayGolbal = '';
                  messages = documentsToMessages(snapshot.data!.docs);
                  return SingleChildScrollView(
                    dragStartBehavior: DragStartBehavior.down,
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: messages.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                          horizontal:
                          MediaQuery.of(context).size.width * 0.03,
                          vertical:
                          MediaQuery.of(context).size.height * 0.03),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        String timeHour = getTimeHour(index);
                        String timeDay = getTimeDay(index);
                        if (timeDay != timeDayGolbal) {
                          timeDayGolbal = timeDay;
                          return messageTextNewData(index, timeHour, timeDay);
                        } else {
                          return messageTextNotNewData(index, timeHour);
                        }
                        }
                    ),
                  );
                }
                else {
                  timeDayGolbal = '';
                  return SingleChildScrollView(
                    dragStartBehavior: DragStartBehavior.down,
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: messages.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            MediaQuery.of(context).size.width * 0.03,
                            vertical:
                            MediaQuery.of(context).size.height * 0.03),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          String timeHour = getTimeHour(index);
                          String timeDay = getTimeDay(index);
                          if (timeDay != timeDayGolbal) {
                            timeDayGolbal = timeDay;
                            return messageTextNewData(index, timeHour, timeDay);
                          } else {
                            return messageTextNotNewData(index, timeHour);
                          }
                        }
                    ),
                  );
                }
              }),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery
                  .of(context)
                  .size
                  .width * 0.02,
                  vertical: MediaQuery
                      .of(context)
                      .size
                      .height * 0.01),
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
                      String minute, hour, second;
                      if(today.minute.toString().length == 1) minute = '0' + today.minute.toString();
                      else minute = today.minute.toString();

                      if(today.hour.toString().length == 1) hour = '0' + today.hour.toString();
                      else hour = today.hour.toString();

                      if(today.second.toString().length == 1) second = '0' + today.second.toString();
                      else second = today.second.toString();

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
                              hour,
                              minute,
                              second,
                              editingController.text);
                        }
                        else {
                          await _accessDatabase.updateConversation(
                            conversationId,
                            editingController.text,
                            today.year.toString(),
                            today.month.toString(),
                            today.day.toString(),
                            hour,
                            minute,
                            second,
                          );
                        }
                        _accessDatabase.addMessage(
                            editingController.text,
                            currentUser.id,
                            today.year.toString(),
                            today.month.toString(),
                            today.day.toString(),
                            hour,
                            minute,
                            second,
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
    time = message.day! + '/' + message.month! + '/' + message.year! + '   ' + message.hour! + ':' + message.minute! + ':' + message.second!;
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

Future<List<ChatMessage>> initMessages (
    List<Message> notChatMessages) async {
  List<ChatMessage> chatMessages = [];
  Message message;
  String time;
  for (int i = 0; i < notChatMessages.length; i++) {
    message = notChatMessages[i];
    time = message.day! + '/' + message.month! + '/' + message.year! + '   ' + message.hour! + ':' + message.minute! + ':' + message.second!;
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
