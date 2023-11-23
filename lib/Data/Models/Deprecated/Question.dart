// This class represents the Object <Question> that will be showed in the FeedBack Screen.

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? id;
  String? creatorID;
  String? questionCat;
  String? questionSpn;
  String? type;

  Question({
    this.id,
    this.creatorID,
    this.questionCat,
    this.questionSpn,
    this.type,
  });

  Question.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.creatorID = mapData['creatorID'].toString();
    this.questionCat = mapData['questionCat'].toString();
    this.questionSpn = mapData['questionSpn'].toString();
    this.type = mapData['type'].toString();
  }

  Question.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.creatorID = documentSnapshot.get("creatorID").toString();
    this.questionCat = documentSnapshot.get("questionCat").toString();
    this.questionSpn = documentSnapshot.get("questionSpn").toString();
    this.type = documentSnapshot.get("type").toString();
  }
}
