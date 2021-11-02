// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? id;
  String? creatorID;
  String? question;
  String? type;
  var options;

  Question({
    this.id,
    this.creatorID,
    this.question,
    this.type,
    this.options,
  });

  Question.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.creatorID = mapData['creatorID'].toString();
    this.question = mapData['question'].toString();
    this.type = mapData['type'].toString();
    this.options = mapData['options'];
  }


  Question.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.creatorID = documentSnapshot.get("creatorID").toString();
    this.question = documentSnapshot.get("question").toString();
    this.type = documentSnapshot.get("type").toString();
    this.options = documentSnapshot.get("options");
  }
}
