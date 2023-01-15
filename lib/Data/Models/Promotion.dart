// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Condition.dart';

class Promotion {
  String? id;
  String? title;
  String? descriptionEsp;
  String? descriptionCat;
  String? startDate;
  String? endDate;
  bool? isActive;
  int? time;

  Promotion({
    this.id,
    this.title,
    this.descriptionEsp,
    this.descriptionCat,
    this.startDate,
    this.endDate,
    this.isActive,
    this.time,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Promotion.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('descriptionEsp')) {
      descriptionEsp = documentSnapshot.get("descriptionEsp").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('descriptionCat')) {
      descriptionCat = documentSnapshot.get("descriptionCat").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('time')) {
      time = documentSnapshot.get("time");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('startDate')) {
      startDate = documentSnapshot.get("startDate").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('endDate')) {
      endDate = documentSnapshot.get("endDate").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isActive')) {
      isActive = documentSnapshot.get("isActive");
    } else {
      isActive = false;
    }
  }
}