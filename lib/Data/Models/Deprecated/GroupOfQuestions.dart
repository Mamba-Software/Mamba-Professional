// This class represents the Object <Question> that will be showed in the FeedBack Screen.
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
    id = documentId;
    creatorID = mapData['creatorID'].toString();
    questionOne = mapData['questionOne'].toString();
    questionTwo = mapData['questionTwo'].toString();
    questionThree = mapData['questionThree'].toString();
    questionFour = mapData['questionFour'].toString();
  }


  GroupOfQuestions.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    id = documentId;
    creatorID = documentSnapshot.get("creatorID").toString();
    questionOne = documentSnapshot.get("questionOne").toString();
    questionTwo = documentSnapshot.get("questionTwo").toString();
    questionThree = documentSnapshot.get("questionThree").toString();
    questionFour = documentSnapshot.get("questionFour").toString();
  }
}
