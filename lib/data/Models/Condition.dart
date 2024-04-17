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
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('expirationTime')) {
      expirationTime = documentSnapshot.get("expirationTime");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('weeklySessions')) {
      weeklySessions = documentSnapshot.get("weeklySessions");
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
      cancelTime = documentSnapshot.get("cancelTime");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Condition condition) {
    id = condition.id;
    expirationTime = condition.expirationTime;
    weeklySessions = condition.weeklySessions;
    //this.monthlySessions = condition.monthlySessions;
    //this.infiniteSessions = condition.infiniteSessions;
    cancelTime = condition.cancelTime;
  }
}