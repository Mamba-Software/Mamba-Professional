// This class represents the Object <Question> that will be showed in the FeedBack Screen.

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
    id = documentId;
    userID = mapData['userID'].toString();
    groupOfQuestionsID = mapData['groupOfQuestionsID'].toString();
    answerOne = mapData['answerOne'].toString();
    answerTwo = mapData['answerTwo'].toString();
    answerThree = mapData['answerThree'].toString();
    answerFour = mapData['answerFour'].toString();
  }

  Answers.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    id = documentId;
    userID = documentSnapshot.get("userID").toString();
    groupOfQuestionsID = documentSnapshot.get("groupOfQuestionsID").toString();
    answerOne = documentSnapshot.get("answerOne").toString();
    answerTwo = documentSnapshot.get("answerTwo").toString();
    answerThree = documentSnapshot.get("answerThree").toString();
    answerFour = documentSnapshot.get("answerFour").toString();
  }
}
