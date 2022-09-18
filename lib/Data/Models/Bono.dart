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
  int? compras;
  String? color;
  String? imageUrl;
  bool? isDegradate;
  double? opacity;



  Bono({
    this.id,
    this.title,
    this.description,
    this.price,
    this.classes,
    this.isActive,
    this.compras,
    this.color,
    this.imageUrl,
    this.isDegradate,
    this.opacity,
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
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('sessions')) {
      this.classes = documentSnapshot.get("sessions");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isActive')) {
      this.isActive = documentSnapshot.get("isActive");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('compras')) {
      this.compras = documentSnapshot.get("compras");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('color')) {
      this.color = documentSnapshot.get("color");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('imageUrl')) {
      this.imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isDegradate')) {
      this.isDegradate = documentSnapshot.get("isDegradate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('opacity')) {
      this.opacity = documentSnapshot.get("opacity");
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
    this.compras = bono.compras;
    this.color = bono.color;
    this.imageUrl = bono.imageUrl;
    this.isDegradate = bono.isDegradate;
    this.opacity = bono.opacity;
  }
}