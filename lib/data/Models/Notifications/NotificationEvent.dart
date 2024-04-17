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
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userId')) {
      userId = documentSnapshot.get("userId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('type')) {
      type = documentSnapshot.get("type").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isRead')) {
      isRead = documentSnapshot.get("isRead");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateSent')) {
      dateSent = documentSnapshot.get("dateSent").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('createdAt')) {
      createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('parameters')) {
      parameters = documentSnapshot.get("parameters");
    }
    // Deprecated
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('year')) {
      year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('month')) {
      month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('day')) {
      day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('hour')) {
      hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('minutes')) {
      minutes = documentSnapshot.get("minutes").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('seconds')) {
      seconds = documentSnapshot.get("seconds").toString();
    }
  }
}
