import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/Room/RoomDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba/commons/extensions/context.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.room,
  });

  final types.Room room;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _roomDataService = RoomDataService();
  final _userDataService = UserDataService();
  bool _isAttachmentUploading = false;
  bool isLoading = true;
  var userId;
  String imageUrlRoom = '';
  String nameRoom = '';
  bool hasSentMessage = false;
  bool noMessages = false;
  bool blockedUser = false;
  TopSnackBarDef topSnackBarComp = TopSnackBarDef();
  var roomActual;
  String rooms = 'Rooms';

  @override
  void initState() {
    super.initState();
    if (widget.room.type.toString() != "RoomType.group") {
      userId = widget.room.users.firstWhere(
        (u) => u.id != currentUser.id,
      );
    }
    if (widget.room.lastMessages != null) {
      hasSentMessage = true;
    } else {
      if (widget.room.type.toString() != "RoomType.group") {
        // _userDataService.getUserDetails(userId);
        noMessages = true;
        imageUrlRoom = userId.imageUrl;
        nameRoom = userId.firstName + ' ' + userId.lastName;
      }
    }
    checkUserBlocked();
    getOtherUser();
  }

  Future<void> checkUserBlocked() async {
    if (widget.room.type.toString() != "RoomType.group") {
      blockedUser =
          await _userDataService.checkUserBlocked(currentUser.id!, userId.id);
    }
  }

  void getOtherUser() async {
    String messageStatus = "seen";
    Map<String, dynamic> metadata = {};
    Map<String, dynamic> metadataMessage = {};
    widget.room.metadata!["active${currentUser.id!}"] = true;
    //widget.room.metadata!["alreadyChanged"] = false;
    await _roomDataService.updateRoom(widget.room.id, widget.room.metadata!);

    if (widget.room.lastMessages != null &&
        widget.room.lastMessages![0].status.toString() != "Status.seen") {
      widget.room.lastMessages![0].metadata![currentUser.id!] = "seen";
      var querySnapshots = FirebaseFirestore.instance
          .collection(rooms)
          .doc(widget.room.id)
          .collection("messages")
          .doc(widget.room.lastMessages![0].remoteId)
          .update({
        'metadata': widget.room.lastMessages![0].metadata,
      });

      //Comprovo si algun usuari del last message té el estat a delivered
      for (int i = 0; i < widget.room.users.length; ++i) {
        if (widget.room.lastMessages![0].metadata![widget.room.users[i].id] ==
            "delivered") {
          messageStatus = "delivered";
          break;
        }
      }

      if (messageStatus == "seen") {
        //await _accessDatabase.updateRoomLastMessage(widget.room.id, widget.room.lastMessages);
        var querySnapshot = await FirebaseFirestore.instance
            .collection(rooms)
            .doc(widget.room.id)
            .collection("messages")
            .get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({
            'status': messageStatus,
            'metadata': widget.room.lastMessages![0].metadata!,
          });
        }
        //Que tinguin status delivered i seleccionats en ordre
      }
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);

        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  /*
  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }

      await OpenFile.open(localPath);
    }

    else {
      Navigator.push(
          context,
          CupertinoPageRoute<Null>(
              builder: (context) => ProfileViewUser(
                  userID: userId.id!, viewOnly: true)));
    }
  }
   */

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  String _customDateHeaderText(DateTime dt) {
    if (dt.year == DateTime.now().year &&
        dt.month == DateTime.now().month &&
        dt.day == DateTime.now().day)
      return (DateFormat('HH:mm').format(dt)).toString();
    return (DateFormat('dd/MM/yy, HH:mm').format(dt)).toString();
  }

  Widget _customMessageBuilder(types.CustomMessage customMessage,
      {required int messageWidth}) {
    return Column(
      children: [
        Container(
          padding: (customMessage.author.id == currentUser.id
              ? EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.01,
                  top: MediaQuery.of(context).size.height * 0.01,
                  bottom: MediaQuery.of(context).size.height * 0.01)
              : EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.01,
                  right: MediaQuery.of(context).size.width * 0.2,
                  top: MediaQuery.of(context).size.height * 0.01,
                  bottom: MediaQuery.of(context).size.height * 0.01)),
          child: Align(
            alignment: (customMessage.author.id == currentUser.id
                ? Alignment.topRight
                : Alignment.topLeft),
            child: Container(
              //width: MediaQuery.of(context).size.width*0.50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (customMessage.author.id == currentUser.id
                    ? context.colorScheme.secondary.withOpacity(0.5)
                    : Theme.of(context).colorScheme.background),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                  vertical: MediaQuery.of(context).size.height * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          customMessage.id,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Column(children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        Text(
                          customMessage.id,
                          style: Theme.of(context).textTheme.bodyMedium,
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

  void _handleSendPressed(types.PartialText message) {
    if (!blockedUser) {
      print(hasSentMessage);
      hasSentMessage = true;
      FirebaseChatCore.instance.sendMessage(
        message,
        widget.room.id,
      );
    } else {
      topSnackBarComp.showSnackBarTop(
          context, context.l10n.unBlockUserToSend, Colors.red);
    }
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: LoadingView(),
          )
        : Scaffold(
            appBar: AppBar(
              elevation: 4,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: MediaQuery.of(context).size.width * 0.06,
                ),
                onPressed: () {
                  Navigator.pop(context, hasSentMessage);
                },
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leadingWidth: MediaQuery.of(context).size.width * 0.07,
              toolbarHeight: MediaQuery.of(context).size.height * 0.08,
              title: Row(
                children: [
                  GestureDetector(
                    child: CircularImage(
                      size: MediaQuery.of(context).size.width * 0.1,
                      image: noMessages ? imageUrlRoom : widget.room.imageUrl,
                      color: Theme.of(context).colorScheme.secondary,
                      borderWidth: 0.1,
                    ),
                    onTap: () {
                      widget.room.type.toString() != "RoomType.group"
                          ? Navigator.push(
                              context,
                              CupertinoPageRoute<void>(
                                  builder: (context) => ProfileViewUser(
                                        userID: userId.id!,
                                        viewOnly: false,
                                        comesFromChat: true,
                                        blockedChanged: (boolean) {
                                          blockedUser = !blockedUser;
                                          setState(() {});
                                        },
                                      )))
                          : null;
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintStyle:
                                  Theme.of(context).appBarTheme.titleTextStyle,
                              hintText:
                                  noMessages ? nameRoom : widget.room.name,
                              contentPadding: const EdgeInsets.all(0),
                              isDense: true,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: StreamBuilder<types.Room>(
              initialData: widget.room,
              stream: FirebaseChatCore.instance.room(widget.room.id),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  roomActual = snapshot.data;
                }
                return StreamBuilder<List<types.Message>>(
                  //initialData: const [],
                  stream: FirebaseChatCore.instance.messages(snapshot.data!),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return LoadingView();
                    } else {
                      return SafeArea(
                        bottom: false,
                        child: Chat(
                          theme: DefaultChatTheme(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            inputBackgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            inputTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            inputTextColor: Theme.of(context).primaryColor,
                            inputTextCursorColor:
                                Theme.of(context).colorScheme.secondary,
                            inputBorderRadius: BorderRadius.circular(0),
                            primaryColor:
                                context.colorScheme.secondary.withOpacity(0.5),
                            secondaryColor:
                                Theme.of(context).colorScheme.background,
                            emptyChatPlaceholderTextStyle:
                                Theme.of(context).textTheme.bodySmall!,
                            sentMessageBodyTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            sentEmojiMessageTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            sentMessageCaptionTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            sentMessageDocumentIconColor:
                                Theme.of(context).primaryColor,
                            sentMessageLinkDescriptionTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            sentMessageLinkTitleTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            receivedMessageBodyTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            receivedEmojiMessageTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            receivedMessageCaptionTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            receivedMessageDocumentIconColor:
                                Theme.of(context).primaryColor,
                            receivedMessageLinkDescriptionTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            receivedMessageLinkTitleTextStyle:
                                Theme.of(context).textTheme.bodyMedium!,
                            userNameTextStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                            userAvatarNameColors: const [
                              Color(0xffff6767),
                              Color(0xff66e0da),
                              Color(0xfff5a2d9),
                              Color(0xfff0c722),
                              Color(0xff6a85e5),
                              Color(0xfffd9a6f),
                              Color(0xff92db6e),
                              Color(0xff73b8e5),
                              Color(0xfffd7590),
                              Color(0xffc78ae5),
                            ],
                            deliveredIcon: Icon(
                              Icons.done_all,
                              color: Theme.of(context).primaryColor,
                            ),
                            seenIcon: Icon(
                              Icons.done_all,
                              color: context.colorScheme.secondary,
                            ),
                            dateDividerTextStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontSize: 10),
                          ),
                          //sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                          customDateHeaderText: _customDateHeaderText,
                          dateHeaderThreshold: 60000,
                          groupMessagesThreshold: 300000,
                          isAttachmentUploading: _isAttachmentUploading,
                          messages: snapshot.data ?? [],
                          scrollPhysics: const BouncingScrollPhysics(),
                          emptyState: Container(),
                          onSendPressed: _handleSendPressed,
                          showUserNames:
                              widget.room.type.toString() == "RoomType.group"
                                  ? true
                                  : false,
                          user: types.User(
                            id: FirebaseChatCore.instance.firebaseUser?.uid ??
                                '',
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
  }
}
