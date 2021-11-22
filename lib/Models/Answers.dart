// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Answers {
  String? id;
  String? userID;
  String? groupOfQuestionsID;
  String? answerOne;
  String? answerTwo;
  String? answerThree;
  String? answerFour;

  Answers({
    this.id,
    this.userID,
    this.groupOfQuestionsID,
    this.answerOne,
    this.answerTwo,
    this.answerThree,
    this.answerFour,
  });

  Answers.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.userID = mapData['userID'].toString();
    this.groupOfQuestionsID = mapData['groupOfQuestionsID'].toString();
    this.answerOne = mapData['answerOne'].toString();
    this.answerTwo = mapData['answerTwo'].toString();
    this.answerThree = mapData['answerThree'].toString();
    this.answerFour = mapData['answerFour'].toString();
  }

  Answers.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.userID = documentSnapshot.get("userID").toString();
    this.groupOfQuestionsID = documentSnapshot.get("groupOfQuestionsID").toString();
    this.answerOne = documentSnapshot.get("answerOne").toString();
    this.answerTwo = documentSnapshot.get("answerTwo").toString();
    this.answerThree = documentSnapshot.get("answerThree").toString();
    this.answerFour = documentSnapshot.get("answerFour").toString();
  }
}
