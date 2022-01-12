// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEvent {
  String? id;
  String? userId;
  String? type;
  bool? isRead;
  String? dateSent;
  String? year;
  String? month;
  String? day;
  String? hour;
  String? minutes;
  String? seconds;
  var parameters;

  NotificationEvent({
    this.id,
    this.userId,
    this.type,
    this.isRead,
    this.dateSent,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minutes,
    this.seconds,
    this.parameters,
  });

  NotificationEvent.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.userId = mapData['userId'].toString();
    this.type = mapData['type'].toString();
    this.isRead = mapData['isRead'];
    this.dateSent = mapData['dateSent'].toString();
    this.year = mapData['year'].toString();
    this.month = mapData['month'].toString();
    this.day = mapData['day'].toString();
    this.hour = mapData['hour'].toString();
    this.minutes = mapData['minutes'].toString();
    this.seconds = mapData['seconds'].toString();
    this.parameters = mapData['parameters'];
  }

  NotificationEvent.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    //this.userId = documentSnapshot.get("userId").toString();
    this.type = documentSnapshot.get("type").toString();
    this.isRead = documentSnapshot.get("isRead");
    this.dateSent = documentSnapshot.get("dateSent").toString();
    this.year = documentSnapshot.get("year").toString();
    this.month = documentSnapshot.get("month").toString();
    this.day = documentSnapshot.get("day").toString();
    this.hour = documentSnapshot.get("hour").toString();
    this.minutes = documentSnapshot.get("minutes").toString();
    this.seconds = documentSnapshot.get("seconds").toString();
    this.parameters = documentSnapshot.get("parameters");
  }
}
