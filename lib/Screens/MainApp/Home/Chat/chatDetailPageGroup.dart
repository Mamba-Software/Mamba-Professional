import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/ChatMessage.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Message.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatDetailPageGroup extends StatefulWidget {
  final Brand brand;

  ChatDetailPageGroup(this.brand);

  @override
  _ChatDetailPageGroupState createState() => _ChatDetailPageGroupState();
}

class _ChatDetailPageGroupState extends State<ChatDetailPageGroup> {
  var _accessDatabase = new DatabaseAccess();

  String? conversationId;

  var editingController = TextEditingController();

  var scrollController = ScrollController();

  bool isLoading = true;

  String? messageNow;

  String? userSent;

  String timeDayGolbal = '';

  List<ChatMessage> messages = [];

  List<Message> notChatMessages = [];

  List<Conversation> conversations = [];

  List<MaterialColor> userColors = [Colors.red, Colors.blue, Colors.orange,Colors.green, Colors.brown, Colors.deepOrange, Colors.pink, Colors.yellow, Colors.cyan, Colors.lightGreen, Colors.blueGrey];

  int itColors = 0;

  Map<String, MaterialColor> mapUserColors = new Map();

  Map<String, dynamic> toMap(String? id) {
    return {
      'uid': id,
    };
  }

  Map<String, dynamic> toMapisMessageRead(String? id, bool? isMessageRead) {
    return {
      'uid': id,
      'isMessageRead': isMessageRead,
    };
  }

  void initState() {
    super.initState();
    getConversationId();
  }

  Future<String?> getUser(String? userId) async {
    if(userId == "sender") return userId;
    Usuario user = await this._accessDatabase.getUserDetails(userId!);
    return user.name;
  }

  Column messageTextNotNewData(var index, String timeHour) {
    MaterialColor matCol;
    if(userSent == "sender") {
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
                padding: EdgeInsets.symmetric(
                    horizontal:
                    MediaQuery.of(context)
                        .size
                        .width *
                        0.03,
                    vertical:
                    MediaQuery.of(context)
                        .size
                        .height *
                        0.02),
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
        ],
      );
    }
    if(!mapUserColors.containsKey(userSent)) {
      mapUserColors.addAll({userSent! : userColors[itColors]});
      userColors.add(userColors[itColors]);
      ++itColors;
    }
    matCol = mapUserColors[userSent]!;
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
              padding: EdgeInsets.symmetric(
                  horizontal:
                  MediaQuery.of(context)
                      .size
                      .width *
                      0.03,
                  vertical:
                  MediaQuery.of(context)
                      .size
                      .height *
                      0.02),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    userSent!,
                    style: TextStyle(
                        fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: matCol.shade200,
                      ),
                  ),
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
      ],
    );
  }

  Column messageTextNewData(var index, String timeHour, String timeDay) {
    MaterialColor matCol;

    if(userSent == "sender") {
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
                padding: EdgeInsets.symmetric(
                    horizontal:
                    MediaQuery.of(context)
                        .size
                        .width *
                        0.03,
                    vertical:
                    MediaQuery.of(context)
                        .size
                        .height *
                        0.02),
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
        ],
      );
    }

    if(!mapUserColors.containsKey(userSent)) {
      mapUserColors.addAll({userSent! : userColors[itColors]});
      userColors.add(userColors[itColors]);
      ++itColors;
    }
    matCol = mapUserColors[userSent]!;

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
              padding: EdgeInsets.symmetric(
                  horizontal:
                  MediaQuery.of(context)
                      .size
                      .width *
                      0.03,
                  vertical:
                  MediaQuery.of(context)
                      .size
                      .height *
                      0.02),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    userSent!,
                    style: TextStyle(
                        fontSize: 15,
                    fontWeight: FontWeight.bold,
                      color: matCol.shade200,
                      ),
                  ),
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

  Future<void> getConversationId() async {
    Conversation conv =
        await this._accessDatabase.getConversationByBrand(widget.brand.id);

    conversationId = conv.conversationId;
    notChatMessages =
        await _accessDatabase.getConversationMessagesInit(conversationId);
    messages = await initMessages(notChatMessages);

    for(int i = 0; i < conv.isMessageRead.length; ++i) {
      if(conv.isMessageRead[i]['uid'] == currentUser.id) {
        conv.isMessageRead[i]['isMessageRead'] = false;
        await _accessDatabase.updateReadMessage(conversationId, conv.isMessageRead);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: LoadingViewPurple(),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 4,
              automaticallyImplyLeading: true,
              backgroundColor: Theme.of(context).accentColor,
              leadingWidth: MediaQuery.of(context).size.width * 0.07,
              toolbarHeight: MediaQuery.of(context).size.height * 0.08,
              title: Row(
                children: [
                  GestureDetector(
                    child: CircularImage(
                      size: MediaQuery.of(context).size.width * 0.1,
                      image: currentBrand.logoUrl,
                      color: Theme.of(context).accentColor,
                      borderWidth: 0.1,
                    ),
                    onTap: () {},
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentBrand.name!,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005,
                      ),
                      Text(
                        AppLocalizations.of(context)!.membersOfBrand,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.79,
                    child: StreamBuilder<QuerySnapshot>(
                        stream:
                        _accessDatabase.getConversationMessages(conversationId),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            timeDayGolbal = '';
                            messages = documentsToMessages(snapshot.data!.docs);
                            return ListView.builder(
                              controller: scrollController,
                              reverse: true,
                              scrollDirection: Axis.vertical,
                              itemCount: messages.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width * 0.03,
                                  vertical:
                                  MediaQuery.of(context).size.height * 0.03),
                              //physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                String timeHour = getTimeHour(index);
                                String timeDay = getTimeDay(index);
                                if(index + 1 == messages.length) timeDayGolbal = '';
                                else {
                                  timeDayGolbal = getTimeDay(index + 1);
                                }
                                if (timeDay != timeDayGolbal) {
                                  timeDayGolbal = timeDay;
                                  return FutureBuilder<String?>(
                                      future: getUser(messages[index].messageType),
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          userSent = snapshot.data;
                                          return messageTextNewData(index, timeHour, timeDay);
                                        } else {
                                          return Container();
                                        }
                                      }
                                  );
                                } else {
                                  return FutureBuilder<String?>(
                                      future: getUser(messages[index].messageType),
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          userSent = snapshot.data;
                                          return messageTextNotNewData(index, timeHour);
                                        } else {
                                          return Container();
                                        }
                                      }
                                  );
                                }
                              },
                            );
                          }
                          else {
                            return ListView.builder(
                              controller: scrollController,
                              reverse: true,
                              scrollDirection: Axis.vertical,
                              itemCount: messages.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                  MediaQuery.of(context).size.width * 0.03,
                                  vertical:
                                  MediaQuery.of(context).size.height * 0.03),
                              //physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                String timeHour = getTimeHour(index);
                                String timeDay = getTimeDay(index);
                                if(index + 1 == messages.length) timeDayGolbal = '';
                                else {
                                  timeDayGolbal = getTimeDay(index + 1);
                                }
                                if (timeDay != timeDayGolbal) {
                                  timeDayGolbal = timeDay;
                                  return FutureBuilder<String?>(
                                      future: getUser(messages[index].messageType),
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          userSent = snapshot.data;
                                          return messageTextNewData(index, timeHour, timeDay);
                                        } else {
                                          return Container();
                                        }
                                      }
                                  );
                                } else {
                                  return FutureBuilder<String?>(
                                      future: getUser(messages[index].messageType),
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          userSent = snapshot.data;
                                          return messageTextNotNewData(index, timeHour);
                                        } else {
                                          return Container();
                                        }
                                      }
                                  );
                                }
                              },
                            );
                          }
                        }),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02,
                        vertical: MediaQuery.of(context).size.height * 0.01),
                    height: MediaQuery.of(context).size.height * 0.10,
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        Expanded(
                          child: TextField(
                            minLines: 1,
                            maxLines: 10,
                            controller: editingController,
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.writeMessage,
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                        FloatingActionButton(
                          onPressed: () async {
                            DateTime today = DateTime.now();
                            String minute, hour, second;
                            if (today.minute.toString().length == 1)
                              minute = '0' + today.minute.toString();
                            else
                              minute = today.minute.toString();

                            if (today.hour.toString().length == 1)
                              hour = '0' + today.hour.toString();
                            else
                              hour = today.hour.toString();

                            if (today.second.toString().length == 1)
                              second = '0' + today.second.toString();
                            else
                              second = today.second.toString();

                            if (editingController.text != '') {

                              List<Map> userMessagesRead = [];
                              //userMessagesRead.add(toMapisMessageRead(currentUser.id, false));

                              List<Usuario> users = await _accessDatabase.getAllTrainersFromBrand(widget.brand.id!);

                              for(int i = 0; i < users.length; ++i) {
                                if(users[i].id == currentUser.id) {
                                  userMessagesRead.add(toMapisMessageRead(
                                      users[i].id, false));
                                }
                                else {
                                  userMessagesRead.add(toMapisMessageRead(
                                      users[i].id, true));
                                }
                              }

                              users = await _accessDatabase.getAllClientsFromBrand(widget.brand.id!);
                              for(int i = 0; i < users.length; ++i) {
                                if(users[i].id == currentUser.id) {
                                  userMessagesRead.add(toMapisMessageRead(
                                      users[i].id, false));
                                }
                                else {
                                  userMessagesRead.add(toMapisMessageRead(
                                      users[i].id, true));
                                }
                              }

                              await _accessDatabase.updateConversation(
                                conversationId,
                                userMessagesRead,
                                editingController.text,
                                today.year.toString(),
                                today.month.toString(),
                                today.day.toString(),
                                hour,
                                minute,
                                second,
                              );
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


                              setState(() {});
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

                ],
              ),
            ),
          );
  }
}

List<ChatMessage> documentsToMessages(List<DocumentSnapshot> documents) {
  List<ChatMessage> chatMessages = [];
  Message message;
  String time;
  for (int i = 0; i < documents.length; i++) {
    message = Message.fromObject(documents[i], documents[i].id);
    time = message.day! +
        '/' +
        message.month! +
        '/' +
        message.year! +
        '   ' +
        message.hour! +
        ':' +
        message.minute! +
        ':' +
        message.second!;
    if (message.userSent == currentUser.id) {
      chatMessages.add(ChatMessage(
          messageContent: message.message, messageType: "sender", time: time));
    } else {
      chatMessages.add(ChatMessage(
          messageContent: message.message,
          messageType: message.userSent,
          time: time));
    }
  }
  return chatMessages;
}

Future<List<ChatMessage>> initMessages(List<Message> notChatMessages) async {
  List<ChatMessage> chatMessages = [];
  Message message;
  String time;
  for (int i = 0; i < notChatMessages.length; i++) {
    message = notChatMessages[i];
    time = message.day! +
        '/' +
        message.month! +
        '/' +
        message.year! +
        '   ' +
        message.hour! +
        ':' +
        message.minute! +
        ':' +
        message.second!;
    if (message.userSent == currentUser.id) {
      chatMessages.add(ChatMessage(
          messageContent: message.message, messageType: "sender", time: time));
    } else {
      chatMessages.add(ChatMessage(
          messageContent: message.message,
          messageType: message.userSent,
          time: time));
    }
  }
  return chatMessages;
}
