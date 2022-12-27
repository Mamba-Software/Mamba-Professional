// This class represents the Object <Bono Rquest>
import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';

class Purchase {
  String? id;
  String? userId;
  String? brandId;
  String? bonoId;
  double? price;
  int? paymentMethod;
  Timestamp? purchasedAt;
  // List of Events Done with this purchase
  Bono? bono;
  List<Event> events = [];

  Purchase({
    this.id,
    this.userId,
    this.brandId,
    this.bonoId,
    this.price,
    this.paymentMethod,
    this.purchasedAt,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Purchase.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userId')) {
      userId = documentSnapshot.get("userId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('brandId')) {
      brandId = documentSnapshot.get("brandId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('bonoId')) {
      bonoId = documentSnapshot.get("bonoId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('price')) {
      price = documentSnapshot.get("price").toDouble();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('paymentMethod')) {
      paymentMethod = documentSnapshot.get("paymentMethod");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('purchasedAt')) {
      purchasedAt = documentSnapshot.get("purchasedAt");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Purchase purchase) {
    id = purchase.id;
    userId = purchase.userId;
    brandId = purchase.brandId;    
    bonoId = purchase.bonoId;
    price = purchase.price;
    paymentMethod = purchase.paymentMethod;
    purchasedAt = purchase.purchasedAt;
  }

  // Set Basic Data
  set setPurchasedEventsData(List<Event> events) {
    this.events = events;
  }

  // Set Basic Data
  set setPurchasedBono(Bono bono) {
    this.bono = bono;
  }

}