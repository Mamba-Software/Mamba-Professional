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
    id = documentId;
    creatorID = mapData['creatorID'].toString();
    questionCat = mapData['questionCat'].toString();
    questionSpn = mapData['questionSpn'].toString();
    type = mapData['type'].toString();
  }

  Question.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    id = documentId;
    creatorID = documentSnapshot.get("creatorID").toString();
    questionCat = documentSnapshot.get("questionCat").toString();
    questionSpn = documentSnapshot.get("questionSpn").toString();
    type = documentSnapshot.get("type").toString();
  }
}
