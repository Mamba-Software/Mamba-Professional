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
  String? userId;
  String? userName;
  Timestamp? timeRequested;

  BonoRequest({
    this.id,
    this.title,
    this.price,
    this.classes,
    this.bonoId,
    this.userId,
    this.userName,
    this.timeRequested,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  BonoRequest.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      this.title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('price')) {
      this.price = documentSnapshot.get("price");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('classes')) {
      this.classes = documentSnapshot.get("classes");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('bonoId')) {
      this.bonoId = documentSnapshot.get("bonoId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userId')) {
      this.userId = documentSnapshot.get("userId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userName')) {
      this.userName = documentSnapshot.get("userName");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('timeRequested')) {
      this.timeRequested = documentSnapshot.get("timeRequested");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(BonoRequest bonoRequest) {
    this.id = bonoRequest.id;
    this.title = bonoRequest.title;
    this.price = bonoRequest.price;
    this.classes = bonoRequest.classes;
    this.bonoId = bonoRequest.bonoId;
    this.userId = bonoRequest.userId;
    this.userName = bonoRequest.userName;
    this.timeRequested = bonoRequest.timeRequested;
  }
}