// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEvent {
  String? id;
  String? userId;
  String? type;
  bool? isImportant;
  bool? isRead;
  String? title;
  String? subtitle;
  String? dateSent;
  String? year;
  String? month;
  String? day;
  var parameters;

  NotificationEvent({
    this.id,
    this.userId,
    this.type,
    this.isImportant,
    this.isRead,
    this.title,
    this.subtitle,
    this.dateSent,
    this.year,
    this.month,
    this.day,
    this.parameters,
  });

  NotificationEvent.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.userId = mapData['userId'].toString();
    this.type = mapData['type'].toString();
    this.isImportant = mapData['isImportant'];
    this.isRead = mapData['isRead'];
    this.title = mapData['title'].toString();
    this.subtitle = mapData['subtitle'].toString();
    this.dateSent = mapData['dateSent'].toString();
    this.year = mapData['year'].toString();
    this.month = mapData['month'].toString();
    this.day = mapData['day'].toString();
    this.parameters = mapData['parameters'];
  }

  NotificationEvent.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.userId = documentSnapshot.get("userId").toString();
    this.type = documentSnapshot.get("type").toString();
    this.isImportant = documentSnapshot.get("isImportant");
    this.isRead = documentSnapshot.get("isRead");
    this.title = documentSnapshot.get("title").toString();
    this.subtitle = documentSnapshot.get("subtitle").toString();
    this.dateSent = documentSnapshot.get("dateSent").toString();
    this.year = documentSnapshot.get("year").toString();
    this.month = documentSnapshot.get("month").toString();
    this.day = documentSnapshot.get("day").toString();
    this.parameters = documentSnapshot.get("parameters");
  }
}
