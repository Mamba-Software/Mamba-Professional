import 'package:flutter/cupertino.dart';

class ChatUsers{
  String? name;
  String? messageText;
  String? imageURL;
  String? time;
  String? userId;
  bool? isGroup = false;
  ChatUsers({this.name, this.messageText, this.imageURL, this.time, this.userId, this.isGroup});
}