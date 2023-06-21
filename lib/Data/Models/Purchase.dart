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
  int? sesions;
  Timestamp? purchasedAt;
  bool? isActive;
  // List of Events Done with this purchase
  Bono? bono;
  Brand? brand;
  List<Event> events = [];
  int numberOfEvents = 0;

  Purchase({
    this.id,
    this.userId,
    this.brandId,
    this.bonoId,
    this.price,
    this.paymentMethod,
    this.sesions,
    this.purchasedAt,
    this.isActive,
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
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('sessions')) {
      sesions = documentSnapshot.get("sessions");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('purchasedAt')) {
      purchasedAt = documentSnapshot.get("purchasedAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isActive')) {
      isActive = documentSnapshot.get("isActive");
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
    sesions = purchase.sesions;
    purchasedAt = purchase.purchasedAt;
    isActive = purchase.isActive;
  }

  // Set Basic Data
  set setPurchasedEventsData(List<Event> events) {
    this.events = events;
    numberOfEvents = events.length;
  }

  // Set Basic Data
  set setPurchasedBono(Bono bono) {
    this.bono = bono;
  }

  // Set Basic Data
  set setPurchasedBrandBono(Brand brand) {
    this.brand = brand;
  }

}