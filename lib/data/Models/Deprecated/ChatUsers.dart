import 'package:flutter/cupertino.dart';

class ChatUsers{
  String? name;
  String? messageText;
  String? imageURL;
  String? time;
  bool? isMessageRead = false;
  String? userId;
  bool? isGroup = false;
  IconData? iconData;
  ChatUsers({this.name, this.messageText, this.imageURL, this.time, this.userId, this.isGroup, this.isMessageRead, this.iconData});
}