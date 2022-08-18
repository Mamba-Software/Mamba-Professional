// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';

class Purchase {
  String? id;
  Timestamp? purchasedAt;
  String? userId;
  String? brandId;
  String? bonoId;
  double? price;
  int? paymentMethod;


  Purchase({
    this.id,
    this.purchasedAt,
    this.userId,
    this.brandId,
    this.bonoId,
    this.price,
    this.paymentMethod,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Purchase.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('purchasedAt')) {
      this.purchasedAt = documentSnapshot.get("purchasedAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('userId')) {
      this.userId = documentSnapshot.get("userId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('brandId')) {
      this.brandId = documentSnapshot.get("brandId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('bonoId')) {
      this.bonoId = documentSnapshot.get("bonoId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('price')) {
      this.price = documentSnapshot.get("price");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('paymentMethod')) {
      this.paymentMethod = documentSnapshot.get("paymentMethod");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Purchase purchase) {
    this.id = purchase.id;
    this.purchasedAt = purchase.purchasedAt;
    this.userId = purchase.userId;
    this.brandId = purchase.brandId;
    this.bonoId = purchase.bonoId;
    this.price = purchase.price;
    this.paymentMethod = purchase.paymentMethod;
  }
}