// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'dart:ffi';

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
      { this.message, this.userSent, required this.year, required this.month, required this.day, required this.hour, required this.minute,required this.second, required this.conversationId});


  Message.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.messageId = documentId;
    this.message = mapData['message'];
    this.year = mapData['year'].toString();
    this.month = mapData['month'].toString();
    this.day = mapData['day'].toString();
    this.hour = mapData['hour'].toString();
    this.minute = mapData['minute'].toString();
    this.second = mapData['second'].toString();
    this.conversationId = mapData['conversationId'].toString();
    this.userSent = mapData['userSent'].toString();
  }

  Message.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.conversationId = documentId;
    this.message = documentSnapshot.get("message");
    this.year = documentSnapshot.get("year").toString();
    this.month = documentSnapshot.get("month").toString();
    this.day = documentSnapshot.get("day").toString();
    this.hour = documentSnapshot.get("hour").toString();
    this.minute = documentSnapshot.get("minute").toString();
    this.second = documentSnapshot.get("second").toString();
    this.conversationId = documentSnapshot.get("conversationId").toString();
    this.userSent = documentSnapshot.get("userSent").toString();
  }


}
