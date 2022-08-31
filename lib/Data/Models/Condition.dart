// This class represents the Object <Condition>

import 'package:cloud_firestore/cloud_firestore.dart';

class Condition {
  String? id;
  int? expirationTime;
  int? weeklySessions;
  int? monthlySessions;


  Condition({
    this.id,
    this.expirationTime,
    this.weeklySessions,
    this.monthlySessions,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Condition.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('expirationTime')) {
      this.expirationTime = documentSnapshot.get("expirationTime");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('weeklySessions')) {
      this.weeklySessions = documentSnapshot.get("weeklySessions");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('monthlySessions')) {
      this.monthlySessions = documentSnapshot.get("monthlySessions");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Condition condition) {
    this.id = condition.id;
    this.expirationTime = condition.expirationTime;
    this.weeklySessions = condition.weeklySessions;
    this.monthlySessions = condition.monthlySessions;
  }
}