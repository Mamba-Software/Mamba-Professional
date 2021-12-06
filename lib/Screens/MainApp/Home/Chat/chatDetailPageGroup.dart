import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  Future<String?> getUser(String? userId) async {
    Usuario user = await this._accessDatabase.getUserDetails(userId!);
    return user.name;
  }

  Future<void> getConversationId() async {
    Conversation conv =
        await this._accessDatabase.getConversationByBrand(widget.brand.id);

    conversationId = conv.conversationId;
    notChatMessages =
        await _accessDatabase.getConversationMessagesInit(conversationId);
    messages = await initMessages(notChatMessages);

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
                  Text(
                    currentBrand.name!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              /*
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
            child: Row(

              children: <Widget>[
                SizedBox(
                  width:  MediaQuery.of(context).size.width*0.1,
                ),
                GestureDetector(
                  child: CircularImage(
                    size: MediaQuery.of(context).size.width*0.11,
                    image: widget.user.imageUrl!,
                    color: Theme.of(context).primaryColor,
                    borderWidth: 1.5,
                  ),
                  onTap: () {
                    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ProfileViewUser(userID: widget.user.id!, viewOnly: true)));
                  },
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
         */
            ),
            body: Stack(
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                    stream:
                        _accessDatabase.getConversationMessages(conversationId),
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
                              String timeHour = messages[index]
                                      .time![messages[index].time!.length - 8] +
                                  messages[index]
                                      .time![messages[index].time!.length - 7] +
                                  messages[index]
                                      .time![messages[index].time!.length - 6] +
                                  messages[index]
                                      .time![messages[index].time!.length - 5] +
                                  messages[index]
                                      .time![messages[index].time!.length - 4];
                              String timeDay = messages[index].time![0] +
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
                              if (timeDay != timeDayGolbal) {
                                timeDayGolbal = timeDay;
                                return Column(
                                  children: [
                                    Text(
                                      timeDay,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                      child: Align(
                                        alignment:
                                            (messages[index].messageType ==
                                                    "receiver"
                                                ? Alignment.topLeft
                                                : Alignment.topRight),
                                        child: Container(
                                          //width: MediaQuery.of(context).size.width*0.50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color:
                                                (messages[index].messageType ==
                                                        "receiver"
                                                    ? Colors.grey.shade200
                                                    : Styles.mainColor),
                                          ),
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.02,
                                                  ),
                                                  Column(children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
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
                              } else {
                                return Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                      child: Align(
                                        alignment:
                                            (messages[index].messageType ==
                                                    "receiver"
                                                ? Alignment.topLeft
                                                : Alignment.topRight),
                                        child: Container(
                                          //width: MediaQuery.of(context).size.width*0.50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color:
                                                (messages[index].messageType ==
                                                        "receiver"
                                                    ? Colors.grey.shade200
                                                    : Styles.mainColor),
                                          ),
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.02,
                                                  ),
                                                  Column(children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
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
                            },
                          ),
                        );
                      } else {
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
                              String timeHour = messages[index]
                                      .time![messages[index].time!.length - 8] +
                                  messages[index]
                                      .time![messages[index].time!.length - 7] +
                                  messages[index]
                                      .time![messages[index].time!.length - 6] +
                                  messages[index]
                                      .time![messages[index].time!.length - 5] +
                                  messages[index]
                                      .time![messages[index].time!.length - 4];
                              String timeDay = messages[index].time![0] +
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
                              if (timeDay != timeDayGolbal) {
                                timeDayGolbal = timeDay;
                                return Column(
                                  children: [
                                    Text(
                                      timeDay,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                      child: Align(
                                        alignment:
                                            (messages[index].messageType ==
                                                    "receiver"
                                                ? Alignment.topLeft
                                                : Alignment.topRight),
                                        child: Container(
                                          //width: MediaQuery.of(context).size.width*0.50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color:
                                                (messages[index].messageType ==
                                                        "receiver"
                                                    ? Colors.grey.shade200
                                                    : Styles.mainColor),
                                          ),
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.02,
                                                  ),
                                                  Column(children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
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
                              } else {
                                if (messages[index].messageType != "sender") {
                                  return FutureBuilder<String?>(
                                    future:
                                        getUser(messages[index].messageType),
                                    // Run check for a single queryRow
                                    builder: (context, snapshot) {
                                      if (snapshot.data != null) {
                                        userSent = snapshot.data;
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
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              userSent!,
                                                              style: TextStyle(
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                        ],
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
                                            if (index == messages.length - 1)
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.08),
                                          ],
                                        );
                                      } else {
                                        return LoadingView();
                                      }
                                    },
                                  );
                                }
                                else return Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.01,
                                          vertical: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.01),
                                      child: Align(
                                        alignment:
                                        (messages[index].messageType ==
                                            "receiver"
                                            ? Alignment.topLeft
                                            : Alignment.topRight),
                                        child: Container(
                                          //width: MediaQuery.of(context).size.width*0.50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            color:
                                            (messages[index].messageType ==
                                                "receiver"
                                                ? Colors.grey.shade200
                                                : Styles.mainColor),
                                          ),
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
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
                                                    width:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        0.02,
                                                  ),
                                                  Column(children: [
                                                    SizedBox(
                                                      height:
                                                      MediaQuery.of(context)
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
                            },
                          ),
                        );
                      }
                    }),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02,
                        vertical: MediaQuery.of(context).size.height * 0.01),
                    height: MediaQuery.of(context).size.height * 0.08,
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
                ),
              ],
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
