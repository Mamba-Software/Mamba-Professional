// This class represents the Object <Question> that will be showed in the FeedBack Screen.

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? messageId;
  String? message;
  String? userSent;
  String? year;
  String? month;
  String? day;
  String? hour;
  String? minute;
  String? second;
  String? conversationId;

  Message(
      {this.message,
      this.userSent,
      required this.year,
      required this.month,
      required this.day,
      required this.hour,
      required this.minute,
      required this.second,
      required this.conversationId});

  Message.fromMap(Map<String, dynamic> mapData, String documentId) {
    messageId = documentId;
    message = mapData['message'];
    year = mapData['year'].toString();
    month = mapData['month'].toString();
    day = mapData['day'].toString();
    hour = mapData['hour'].toString();
    minute = mapData['minute'].toString();
    second = mapData['second'].toString();
    conversationId = mapData['conversationId'].toString();
    userSent = mapData['userSent'].toString();
  }

  Message.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    conversationId = documentId;
    message = documentSnapshot.get("message");
    year = documentSnapshot.get("year").toString();
    month = documentSnapshot.get("month").toString();
    day = documentSnapshot.get("day").toString();
    hour = documentSnapshot.get("hour").toString();
    minute = documentSnapshot.get("minute").toString();
    second = documentSnapshot.get("second").toString();
    conversationId = documentSnapshot.get("conversationId").toString();
    userSent = documentSnapshot.get("userSent").toString();
  }
}
