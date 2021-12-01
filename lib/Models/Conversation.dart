// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'dart:ffi';

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

  Conversation(
      { this.users, required this.year, required this.month, required this.day, required this.hour, required this.minute, required this.second});


  Conversation.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.conversationId = documentId;
    this.users = mapData['users'];
    this.year = mapData['year'].toString();
    this.month = mapData['month'].toString();
    this.day = mapData['day'].toString();
    this.hour = mapData['hour'].toString();
    this.minute = mapData['minute'].toString();
    this.lastMessage = mapData['lastMessage'].toString();
    this.brandId = mapData['brandId'].toString();
    this.second = mapData['second'].toString();
  }

  Conversation.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.conversationId = documentId;
    this.users = documentSnapshot.get("users");
    this.year = documentSnapshot.get("year").toString();
    this.month = documentSnapshot.get("month").toString();
    this.day = documentSnapshot.get("day").toString();
    this.hour = documentSnapshot.get("hour").toString();
    this.minute = documentSnapshot.get("minute").toString();
    this.lastMessage = documentSnapshot.get("lastMessage").toString();
    this.brandId = documentSnapshot.get("brandId").toString();
    this.second = documentSnapshot.get("second").toString();
  }


}
