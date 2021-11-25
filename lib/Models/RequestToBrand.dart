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

  RequestToBrand.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.brandId = mapData['brandId'].toString();
    this.userId = mapData['userId'].toString();
    this.name = mapData['name'].toString();
    this.isTrainer = mapData['isTrainer'];
    this.dateSent = mapData['dateSent'].toString();
    this.year = mapData['year'].toString();
    this.month = mapData['month'].toString();
    this.day = mapData['month'].day();
  }


  RequestToBrand.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.brandId = documentSnapshot.get("brandId").toString();
    this.userId = documentSnapshot.get("userId").toString();
    this.name = documentSnapshot.get("name").toString();
    this.isTrainer = documentSnapshot.get("isTrainer");
    this.dateSent = documentSnapshot.get("dateSent").toString();
    this.year = documentSnapshot.get("year").toString();
    this.month = documentSnapshot.get("month").toString();
    this.day = documentSnapshot.get("day").toString();
  }
}
