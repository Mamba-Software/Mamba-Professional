// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String? id;
  String? creatorID;
  String? brandID;
  String? title;
  String? description;
  String? year;
  String? month;
  String? day;
  String? hour;
  String? minute;
  double? duration;
  String? locationId;
  int? maxMembers;
  var joinedMembers;
  var selectedTrainers;
  bool? isCompleted;

  Event({
    this.id,
    this.creatorID,
    this.brandID,
    this.title,
    this.description,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.duration,
    this.locationId,
    this.maxMembers,
    this.joinedMembers,
    this.selectedTrainers,
    this.isCompleted,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Event.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    this.creatorID = documentSnapshot.get("creatorID").toString();
    this.brandID = documentSnapshot.get("brandID").toString();
    this.title = documentSnapshot.get("title").toString();
    this.description = documentSnapshot.get("description").toString();
    this.year = documentSnapshot.get("year").toString();
    this.month = documentSnapshot.get("month").toString();
    this.day = documentSnapshot.get("day").toString();
    this.hour = documentSnapshot.get("hour").toString();
    this.minute = documentSnapshot.get("minute").toString();
    this.duration = documentSnapshot.get("duration");
    this.locationId = documentSnapshot.get("locationId").toString();
    this.maxMembers = documentSnapshot.get("maxMembers");
    this.joinedMembers = documentSnapshot.get("joinedMembers");
    this.selectedTrainers = documentSnapshot.get("selectedTrainers");
    this.isCompleted = documentSnapshot.get("isCompleted");
  }
}