// This class represents the Object <Bono Rquest>

import 'package:cloud_firestore/cloud_firestore.dart';

class BonoRequest {
  String? id;
  String? brandId;
  String? userId;
  String? bonoId;
  String? title;
  String? price;
  String? sessions;
  int? paymentMethod;
  Timestamp? timeRequested;

  BonoRequest({
    this.id,
    this.brandId,
    this.userId,
    this.bonoId,
    this.title,
    this.price,
    this.sessions,
    this.paymentMethod,
    this.timeRequested,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  BonoRequest.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('brandId')) {
      brandId = documentSnapshot.get("brandId");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('userId')) {
      userId = documentSnapshot.get("userId");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('bonoId')) {
      bonoId = documentSnapshot.get("bonoId");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('price')) {
      price = documentSnapshot.get("price");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('sessions')) {
      sessions = documentSnapshot.get("sessions");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('paymentMethod')) {
      paymentMethod = documentSnapshot.get("paymentMethod");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('timeRequested')) {
      timeRequested = documentSnapshot.get("timeRequested");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(BonoRequest bonoRequest) {
    id = bonoRequest.id;
    brandId = bonoRequest.brandId;
    userId = bonoRequest.userId;
    bonoId = bonoRequest.bonoId;
    title = bonoRequest.title;
    price = bonoRequest.price;
    sessions = bonoRequest.sessions;
    paymentMethod = bonoRequest.paymentMethod;
    timeRequested = bonoRequest.timeRequested;
  }
}
