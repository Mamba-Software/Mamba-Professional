// This class represents the Object <Question> that will be showed in the FeedBack Screen.
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestToBrand {
  String? id;
  String? brandId;
  String? userId;
  String? name;
  bool? isTrainer;
  String? dateSent;
  String? year;
  String? month;
  String? day;

  RequestToBrand({
    this.id,
    this.brandId,
    this.userId,
    this.name,
    this.isTrainer,
    this.dateSent,
    this.year,
    this.month,
    this.day,
  });

  RequestToBrand.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    brandId = documentSnapshot.get("brandId").toString();
    userId = documentSnapshot.get("userId").toString();
    name = documentSnapshot.get("name").toString();
    isTrainer = documentSnapshot.get("isTrainer");
    dateSent = documentSnapshot.get("dateSent").toString();
    year = documentSnapshot.get("year").toString();
    month = documentSnapshot.get("month").toString();
    day = documentSnapshot.get("day").toString();
  }
}
