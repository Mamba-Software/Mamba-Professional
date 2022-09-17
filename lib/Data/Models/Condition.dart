// This class represents the Object <Condition>

import 'package:cloud_firestore/cloud_firestore.dart';

class Condition {
  String? id;
  int? expirationTime;
  int? weeklySessions;
  //int? monthlySessions;
  //bool? infiniteSessions;
  int? cancelTime;



  Condition({
    this.id,
    this.expirationTime,
    this.weeklySessions,
    //this.monthlySessions,
    //this.infiniteSessions,
    this.cancelTime,
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
    /*
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('monthlySessions')) {
      this.monthlySessions = documentSnapshot.get("monthlySessions");
    }


    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('infiniteSessions')) {
      this.infiniteSessions = documentSnapshot.get("infiniteSessions");
    }

     */
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('cancelTime')) {
      this.cancelTime = documentSnapshot.get("cancelTime");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Condition condition) {
    this.id = condition.id;
    this.expirationTime = condition.expirationTime;
    this.weeklySessions = condition.weeklySessions;
    //this.monthlySessions = condition.monthlySessions;
    //this.infiniteSessions = condition.infiniteSessions;
    this.cancelTime = condition.cancelTime;
  }
}