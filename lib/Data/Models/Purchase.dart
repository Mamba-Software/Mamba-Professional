// This class represents the Object <Bono Rquest>
import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';

class Purchase {
  String? id;
  String? userId;
  String? brandId;
  String? bonoId;
  double? price;
  int? paymentMethod;
  int? sessions;
  Timestamp? purchasedAt;
  bool? isActive;
  bool? directPurchase;
  Condition? condition = Condition(
    expirationTime: 0,
    cancelTime: 0,
    weeklySessions: 0,
  );

  // List of Events Done with this purchase
  Bono? bono;
  Brand? brand;
  List<Event> events = [];
  List<Event> initalEvents = [];
  int numberOfEvents = 0;

  Purchase({
    this.id,
    this.userId,
    this.brandId,
    this.bonoId,
    this.price,
    this.paymentMethod,
    this.sessions,
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
      sessions = documentSnapshot.get("sessions");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('purchasedAt')) {
      purchasedAt = documentSnapshot.get("purchasedAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isActive')) {
      isActive = documentSnapshot.get("isActive");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('directPurchase')) {
      directPurchase = documentSnapshot.get("directPurchase");
    }
    // Conditions
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('expirationTime')) {
      condition!.expirationTime = documentSnapshot.get("expirationTime");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('cancelTime')) {
      condition!.cancelTime = documentSnapshot.get("cancelTime");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('weeklySessions')) {
      condition!.weeklySessions = documentSnapshot.get("weeklySessions");
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
    sessions = purchase.sessions;
    purchasedAt = purchase.purchasedAt;
    isActive = purchase.isActive;
  }

  // Set Basic Data
  set setPurchasedEventsData(List<Event> events) {
    this.events = events;
    numberOfEvents = events.length;
  }
  set setInitialEventsData(List<Event> events) {
    initalEvents = events;
  }

  // Set Basic Data
  set setPurchasedBono(Bono bono) {
    this.bono = bono;
  }

  // Set Basic Data
  set setPurchasedBrandBono(Brand brand) {
    this.brand = brand;
  }

  Purchase.copy(Purchase other)
      : id = other.id,
        userId = other.userId,
        brandId = other.brandId,
        bonoId = other.bonoId,
        price = other.price,
        paymentMethod = other.paymentMethod,
        sessions = other.sessions,
        purchasedAt = other.purchasedAt,
        isActive = other.isActive,
        directPurchase = other.directPurchase,
        condition = other.condition != null ? Condition(
          expirationTime: other.condition!.expirationTime,
          cancelTime: other.condition!.cancelTime,
          weeklySessions: other.condition!.weeklySessions,
        ) : null,
        events = List.from(other.events), // Assuming Event has a copy constructor
        initalEvents = List.from(other.events),
        numberOfEvents = other.numberOfEvents;


}