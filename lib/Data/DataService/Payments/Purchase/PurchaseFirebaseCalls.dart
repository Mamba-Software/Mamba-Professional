import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lDegradate.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lImage.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lPaymentMethod.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';

// Firebase Purchase Service Class. All calls to Firebase are in this class.
class PurchaseFirebaseCalls {

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String users = isProduction ? 'Users' : '7777 Users';
  String nicknames = isProduction ? 'Nicknames' : '7777 Nicknames';
  String brands = isProduction ? 'Brands' : '7777 Brands';
  String conversations = isProduction ? 'Conversations' : '7777 Conversations';
  String library = isProduction ? 'Library' : 'Library';
  String payments = isProduction ? 'Payments' : '7777 Payments';

  Future<Purchase> getPurchaseInfo(String purchaseId) async {
    Purchase purchase;
    // Get Main Purchase Info
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
        .collection(payments)
        .doc("Purchases")
        .collection("Purchases")
        .doc(purchaseId)
        .get();
    purchase = Purchase.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    // Get Purchase Events
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(payments)
        .doc(purchaseId)
        .collection("Events")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    // Set Purchase Events
    purchase.setPurchasedEventsData = events;
    return purchase;
  }

  /////////////////////////////////////////////////////////////// STREAMS

  //Get bonos from brand
  Stream<DocumentSnapshot> getPurchaseInfoStream(String purchaseId) {
    return _firestore
        .collection(payments)
        .doc("Purchases")
        .collection("Purchases")
        .doc(purchaseId)
        .snapshots();
  }


}
