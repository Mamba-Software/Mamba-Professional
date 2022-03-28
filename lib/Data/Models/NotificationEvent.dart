// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationEvent {
  String? id;
  String? userId;
  String? type;
  bool? isRead;
  String? dateSent;
  Timestamp? createdAt;
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
    this.createdAt,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minutes,
    this.seconds,
    this.parameters,
  });

  NotificationEvent.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userId')) {
      this.userId = documentSnapshot.get("userId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('type')) {
      this.type = documentSnapshot.get("type").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isRead')) {
      this.type = documentSnapshot.get("isRead");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateSent')) {
      this.dateSent = documentSnapshot.get("dateSent").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('createdAt')) {
      this.createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('parameters')) {
      this.parameters = documentSnapshot.get("parameters");
    }
    // Deprecated
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('year')) {
      this.year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('month')) {
      this.month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('day')) {
      this.day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('hour')) {
      this.hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('minutes')) {
      this.minutes = documentSnapshot.get("minutes").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('seconds')) {
      this.seconds = documentSnapshot.get("seconds").toString();
    }
  }
}
