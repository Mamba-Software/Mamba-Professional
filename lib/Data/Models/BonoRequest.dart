// This class represents the Object <Bono Rquest>
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';

class BonoRequest {
  String? id;
  String? title;
  String? price;
  String? classes;
  String? bonoId;
  String? brandId;
  String? userId;
  String? userName;
  int? paymentMethod;
  Timestamp? timeRequested;

  BonoRequest({
    this.id,
    this.title,
    this.price,
    this.classes,
    this.bonoId,
    this.brandId,
    this.userId,
    this.userName,
    this.paymentMethod,
    this.timeRequested,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  BonoRequest.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('price')) {
      price = documentSnapshot.get("price");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('classes')) {
      classes = documentSnapshot.get("classes");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('bonoId')) {
      bonoId = documentSnapshot.get("bonoId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('brandId')) {
      brandId = documentSnapshot.get("brandId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userId')) {
      userId = documentSnapshot.get("userId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userName')) {
      userName = documentSnapshot.get("userName");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('paymentMethod')) {
      paymentMethod = documentSnapshot.get("paymentMethod");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('timeRequested')) {
      timeRequested = documentSnapshot.get("timeRequested");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(BonoRequest bonoRequest) {
    id = bonoRequest.id;
    title = bonoRequest.title;
    price = bonoRequest.price;
    classes = bonoRequest.classes;
    bonoId = bonoRequest.bonoId;
    userId = bonoRequest.userId;
    userName = bonoRequest.userName;
    paymentMethod = bonoRequest.paymentMethod;
    timeRequested = bonoRequest.timeRequested;
  }
}