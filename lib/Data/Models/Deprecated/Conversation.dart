// This class represents the Object <Question> that will be showed in the FeedBack Screen.

import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  String? conversationId;
  var users;
  String? brandId;
  String? year;
  String? month;
  String? day;
  String? hour;
  String? minute;
  String? second;
  String? lastMessage;
  var isMessageRead;

  Conversation(
      {this.users,
      required this.year,
      required this.month,
      required this.day,
      required this.hour,
      required this.minute,
      required this.second,
      this.isMessageRead});

  Conversation.fromMap(Map<String, dynamic> mapData, String documentId) {
    conversationId = documentId;
    users = mapData['users'];
    year = mapData['year'].toString();
    month = mapData['month'].toString();
    day = mapData['day'].toString();
    hour = mapData['hour'].toString();
    minute = mapData['minute'].toString();
    lastMessage = mapData['lastMessage'].toString();
    brandId = mapData['brandId'].toString();
    second = mapData['second'].toString();
    isMessageRead = mapData['messagesRead'];
  }

  Conversation.fromObject(
      DocumentSnapshot documentSnapshot, String documentId) {
    conversationId = documentId;
    users = documentSnapshot.get("users");
    year = documentSnapshot.get("year").toString();
    month = documentSnapshot.get("month").toString();
    day = documentSnapshot.get("day").toString();
    hour = documentSnapshot.get("hour").toString();
    minute = documentSnapshot.get("minute").toString();
    lastMessage = documentSnapshot.get("lastMessage").toString();
    brandId = documentSnapshot.get("brandId").toString();
    second = documentSnapshot.get("second").toString();
    isMessageRead = documentSnapshot.get("messagesRead");
  }
}
