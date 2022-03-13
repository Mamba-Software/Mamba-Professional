// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';

class Bono {
  String? id;
  String? title;
  String? description;
  double? price;
  int? classes;
  bool? isActive;

  Bono({
    this.id,
    this.title,
    this.description,
    this.price,
    this.classes,
    this.isActive
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Bono.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      this.title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('description')) {
      this.description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('price')) {
      this.price = documentSnapshot.get("price");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('classes')) {
      this.classes = documentSnapshot.get("classes");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isActive')) {
      this.isActive = documentSnapshot.get("isActive");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Bono bono) {
    this.id = bono.id;
    this.title = bono.title;
    this.description = bono.description;
    this.price = bono.price;
    this.classes = bono.classes;
    this.isActive = bono.isActive;
  }
}