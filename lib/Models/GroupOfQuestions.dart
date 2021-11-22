// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupOfQuestions {
  String? id;
  String? creatorID;
  String? questionOne;
  String? questionTwo;
  String? questionThree;
  String? questionFour;
  bool? isActive;

  GroupOfQuestions({
    this.id,
    this.creatorID,
    this.questionOne,
    this.questionTwo,
    this.questionThree,
    this.questionFour,
    this.isActive = false,
  });

  GroupOfQuestions.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.creatorID = mapData['creatorID'].toString();
    this.questionOne = mapData['questionOne'].toString();
    this.questionTwo = mapData['questionTwo'].toString();
    this.questionThree = mapData['questionThree'].toString();
    this.questionFour = mapData['questionFour'].toString();
  }


  GroupOfQuestions.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.creatorID = documentSnapshot.get("creatorID").toString();
    this.questionOne = documentSnapshot.get("questionOne").toString();
    this.questionTwo = documentSnapshot.get("questionTwo").toString();
    this.questionThree = documentSnapshot.get("questionThree").toString();
    this.questionFour = documentSnapshot.get("questionFour").toString();
  }
}
