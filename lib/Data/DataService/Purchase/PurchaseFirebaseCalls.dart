import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:uuid/uuid.dart';

// Firebase Purchase Service Class. All calls to Firebase are in this class.
class PurchaseFirebaseCalls {

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String users = isProduction ? 'Users' : '7777 Users';
  String events = isProduction ? 'Events' : '7777 Events';
  String nicknames = isProduction ? 'Nicknames' : '7777 Nicknames';
  String brands = isProduction ? 'Brands' : '7777 Brands';
  String conversations = isProduction ? 'Conversations' : '7777 Conversations';
  String purchases = isProduction ? 'Purchases' : '7777 Purchases';
  String library = isProduction ? 'Library' : 'Library';

  // Check Data
  Future<bool> checkIfEventInPurchase(String purchaseId, String eventId) async {
    try {
      DocumentSnapshot event = await _firestore
          .collection(purchases)
          .doc(purchaseId)
          .collection("Events")
          .doc(eventId)
          .get();
      return event.exists;
    } catch (e) {
      return false;
    }
  }

  // Get Data
  Future<Purchase> getPurchaseInfo(String purchaseId) async {
    Purchase purchase;
    // Get Main Purchase Info
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
        .collection(purchases)
        .doc(purchaseId)
        .get();
    purchase = Purchase.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    // Get Brand From Purchase
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot2 = await _firestore.collection(brands).doc(purchase.brandId).get();
    Brand brand =  Brand.fromObjectOnlyCoverData(_documentSnapshot2.id, _documentSnapshot2);
    // Set Purchased Brand Bono
    purchase.setPurchasedBrandBono = brand;
    // Get Bono From Purchase
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot3 = await _firestore.collection(brands).doc(purchase.brandId).collection("Bonos").doc(purchase.bonoId).get();
    Bono bono =  Bono.fromObjectAllData(_documentSnapshot3.id, _documentSnapshot3);
    // Add Conditions of This purchase
    bono.setBrandId = purchase.brandId!;
    bono.setBonoPrice = _documentSnapshot.get("price").toDouble();
    bono.setBonoSessions = _documentSnapshot.get("sessions");
    bono.setConditionsData = Condition(
      expirationTime: _documentSnapshot.get("expirationTime"),
      cancelTime: _documentSnapshot.get("cancelTime"),
      weeklySessions: _documentSnapshot.get("weeklySessions"),
    );
    // Set Purchased Bono
    purchase.setPurchasedBono = bono;
    // Get Purchase Events
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(purchases)
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

  Future<List<Purchase>> getAllUserPurchasesFromBrand(String userId, String brandId) async {
    List<Purchase> purchasesList = [];
    Map<String, Bono> bonoKey =  Map();
    Bono bono = Bono();
    // Get All User Purchases
    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .collection("Purchases")
        .get();

    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot2 = await _firestore.collection(brands).doc(brandId).get();
    Brand brand = Brand.fromObjectOnlyCoverData(_documentSnapshot2.id, _documentSnapshot2);

    // Build Each Purchase
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      // Get Main Purchase Info
      String purchaseId = querySnapshot.docs[i].id;
      DocumentSnapshot _documentSnapshot = querySnapshot.docs[i];
      Purchase purchase = Purchase.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
      purchase.setBasicData = Purchase(
        id: purchase.id,
        userId: userId,
        brandId: brandId,
        bonoId: purchase.bonoId,
        price: purchase.price,
        paymentMethod: purchase.paymentMethod,
        purchasedAt: purchase.purchasedAt,
        isActive: purchase.isActive,
      );
      // Set Purchased Brand Bono
      purchase.setPurchasedBrandBono = brand;

      if(bonoKey.containsKey(purchase.bonoId)) {
        bono = bonoKey[purchase.bonoId!]!;
      }
      else {
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot3 = await _firestore.collection(brands).doc(purchase.brandId).collection("Bonos").doc(purchase.bonoId).get();
        bono =  Bono.fromObjectAllData(_documentSnapshot3.id, _documentSnapshot3);
        bonoKey[purchase.bonoId!] = bono;
      }
      // Get Bono From Purchase

      // Add Conditions of This purchase
      bono.setBonoPrice = _documentSnapshot.get("price").toDouble();
      bono.setBonoSessions = _documentSnapshot.get("sessions");
      bono.setConditionsData = Condition(
        expirationTime: _documentSnapshot.get("expirationTime"),
        cancelTime: _documentSnapshot.get("cancelTime"),
        weeklySessions: _documentSnapshot.get("weeklySessions"),
      );
      // Set Purchased Bono
      purchase.setPurchasedBono = bono;

/*
      // Get Purchase Events
      List<Event> events = [];
      QuerySnapshot querySnapshot2 = await _firestore
          .collection(purchases)
          .doc(purchaseId)
          .collection("Events")
          .get();
      for (int i = 0; i < querySnapshot2.docs.length; i++) {
        events.add(Event.fromObjectOnlyCoverData(querySnapshot2.docs[i].id, querySnapshot2.docs[i]));
      }
      // Set Purchase Events
      purchase.setPurchasedEventsData = events;*/
      // Add To Purchases List
      purchasesList.add(purchase);
    }
    return purchasesList;
  }

  Future<Purchase> getPurchaseEvents(Purchase purchase) async {
      // Get Purchase Events
      List<Event> events = [];
      QuerySnapshot querySnapshot2 = await _firestore
          .collection(purchases)
          .doc(purchase.id)
          .collection("Events")
          .get();
      for (int i = 0; i < querySnapshot2.docs.length; i++) {
        events.add(Event.fromObjectOnlyCoverData(querySnapshot2.docs[i].id, querySnapshot2.docs[i]));
      }
      // Set Purchase Events
      purchase.setPurchasedEventsData = events;


    return purchase;
  }

  // Add Data

  Future<String> addPurchase(Purchase purchase, Bono bonoSelected) async {
    var uid = const Uuid().v4();
    await _firestore
        .collection(purchases)
        .doc(uid)
        .set({
      "purchasedAt": purchase.purchasedAt!,
      "userId": purchase.userId,
      "brandId": purchase.brandId!,
      "bonoId": purchase.bonoId,
      "price": purchase.price, //bonoSelected.price
      "sessions": bonoSelected.sessions,
      "weeklySessions": bonoSelected.condition?.weeklySessions,
      "cancelTime": bonoSelected.condition?.cancelTime,
      "expirationTime": bonoSelected.condition?.expirationTime,
      "paymentMethod": purchase.paymentMethod,
    }).catchError((err) {
      print(err);
    });
    return uid;
  }

  Future<void> addEventToPurchase(String purchaseId, String eventId) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(events).doc(eventId).get();
    Event event = Event.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    // Add This to Payments
    await _firestore
      .collection(purchases)
      .doc(purchaseId)
      .collection("Events")
      .doc(eventId)
      .set({
        "isPrivate": event.isPrivate,
        "title": event.title,
        "imageUrl": event.imageUrl,
        "doneAt": event.doneAt,
        "year": event.year,
        "month": event.month,
        "day": event.day,
        "hour": event.hour,
        "minute": event.minute,
        "duration": event.duration,
        "numTrainers": event.numTrainers,
        "numClients": event.numClients,
        "maxMembers": event.maxMembers,
    });
  }

  // Delete Data

  Future<void> detelePurchase(String purchaseId, String userId, String brandId) async {

    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .collection("Purchases")
        .doc(purchaseId)
        .collection("Events")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .collection("Purchases")
        .doc(purchaseId).delete();

  }

  Future<void> deleteEventFromPurchase(String purchaseId, String eventId) async {
    await _firestore
    .collection(purchases)
    .doc(purchaseId)
    .collection("Events")
    .doc(eventId)
    .delete();
  }


  /////////////////////////////////////////////////////////////// STREAMS

  //Get bonos from brand
  Stream<DocumentSnapshot> getPurchaseInfoStream(String purchaseId) {
    return _firestore
        .collection(purchases)
        .doc(purchaseId)
        .snapshots();
  }


}
