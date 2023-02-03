// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Condition.dart';

class Subscription {
  String? id;
  String? title;
  String? descriptionEsp;
  String? descriptionCat;
  Timestamp? startDate;
  Timestamp? endDate;
  bool? isActive;
  int? duration;
  String? promotion;

  Subscription({
    this.id,
    this.title,
    this.descriptionEsp,
    this.descriptionCat,
    this.startDate,
    this.endDate,
    this.isActive,
    this.duration,
    this.promotion,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Subscription.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
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
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('duration')) {
      duration = documentSnapshot.get("duration");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('startDate')) {
      startDate = documentSnapshot.get("startDate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('endDate')) {
      endDate = documentSnapshot.get("endDate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isActive')) {
      isActive = documentSnapshot.get("isActive");
    } else {
      isActive = false;
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('promotion')) {
      promotion = documentSnapshot.get("promotion");
    }
  }
}