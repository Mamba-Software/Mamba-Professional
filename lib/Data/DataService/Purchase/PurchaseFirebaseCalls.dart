import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
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

  Future<String> checkIfUserHasActivePurchase(String userId, String eventId, List<String> selectedBonos, String brandId) async {
    for(int i = 0; i < selectedBonos.length; ++i) {
      QuerySnapshot querySnapshot =  await _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Users")
          .doc(userId)
          .collection("Purchases")
          .where("bonoId", isEqualTo: selectedBonos[i])
          .where("isActive", isEqualTo: true)
          .get();
      for (int j = 0; j < querySnapshot.docs.length; j++) {
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(purchases)
            .doc(querySnapshot.docs[j].id).collection("Events").doc(eventId).get();
        if(_documentSnapshot.exists) {
          return querySnapshot.docs[j].id;
        }
      }
    }
    return "";
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

  Future<List<Purchase>> getBrandPurchases(String brandId, DateTime startDate, DateTime endDate, [bool applyThreshold = false]) async {
    List<Purchase> purchases = [];
    int threshold = 100;
    Query query;
    if (applyThreshold) {
      // Get Collection Size
      int collectionSize = await _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Purchases")
          .get()
          .then((snapshot) => snapshot.size);
      // Hybrid Approach: if size < 100 ? All at once : 100 by 100 based on the date
      if (collectionSize <= threshold) {
        query = _firestore.collection(brands).doc(brandId).collection("Purchases");
      } else {
        query = _firestore.collection(brands).doc(brandId).collection("Purchases")
        .where("purchasedAt", isLessThan: endDate)
        .where("purchasedAt", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
    } else {
      query = _firestore.collection(brands).doc(brandId).collection("Purchases")
      .where("purchasedAt", isLessThan: endDate)
      .where("purchasedAt", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    // Make Query
    QuerySnapshot querySnapshot = await query
    .orderBy("purchasedAt", descending: true)
    .get();
    // Return Query
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      purchases.add(Purchase.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return purchases;
  }

  Future<List<Purchase>> getBrandUserPurchases(String userId, String brandId, DateTime startDate, DateTime endDate, [bool applyThreshold = false]) async {
    List<Purchase> purchases = [];
    int threshold = 100;
    Query query;
    if (applyThreshold) {
      // Get Collection Size
      int collectionSize = await _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Users")
          .doc(userId)
          .collection("Purchases")
          .get()
          .then((snapshot) => snapshot.size);
      // Hybrid Approach: if size < 100 ? All at once : 100 by 100 based on the date
      if (collectionSize <= threshold) {
        query = _firestore.collection(brands).doc(brandId).collection("Users")
            .doc(userId).collection("Purchases");
      } else {
        query = _firestore.collection(brands).doc(brandId).collection("Users")
            .doc(userId).collection("Purchases")
            .where("purchasedAt", isLessThan: endDate)
            .where("purchasedAt", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
    } else {
      query = _firestore.collection(brands).doc(brandId).collection("Users")
          .doc(userId).collection("Purchases")
          .where("purchasedAt", isLessThan: endDate)
          .where("purchasedAt", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    // Make Query
    QuerySnapshot querySnapshot = await query
        .orderBy("purchasedAt", descending: true)
        .get();
    // Return Query
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      purchases.add(Purchase.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return purchases;
  }

  // Get First Purchases Brand
  Future <List<Purchase>> getBrandFirstPurchasesLimit(String brandId, int limit) async {
    Timestamp now = Timestamp.fromDate(DateTime.now());
    List<Purchase> purchases = [];
    QuerySnapshot querySnapshot = await _firestore
    .collection(brands)
    .doc(brandId)
    .collection("Purchases")
    .where("purchasedAt", isLessThan: now)
    .orderBy("purchasedAt", descending: true)
    .limit(limit)
    .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      purchases.add(Purchase.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return purchases;
  }

  // Get More Purchases Brand
  Future <List<Purchase>> getBrandMorePurchasesLimit(String userId, String purchaseId, int limit) async {
    Timestamp now = Timestamp.fromDate(DateTime.now());
    // Get Last Notification document
    DocumentSnapshot docu = await _firestore
        .collection(brands)
        .doc(userId)
        .collection("Purchases")
        .doc(purchaseId)
        .get();
    // Get More Events
    List<Purchase> purchases = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Purchases")
        .where("purchasedAt", isLessThan: now)
        .orderBy("purchasedAt", descending: true)
        .startAfterDocument(docu)
        .limit(limit)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      purchases.add(Purchase.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return purchases;
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

  Future<List<Purchase>> getPurchasesByEventId(String eventId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(purchases)
        .where('Events', arrayContains: {'id': eventId})
        .get();
    List<Purchase> listpurchases = [];
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Purchase purchase = Purchase.fromObjectAllData(documentSnapshot.id, documentSnapshot);
      print(purchase);
      listpurchases.add(purchase);
    }

    return listpurchases;
  }

  Future<List<Usuario>> getUsersByBonosAndActivePurchase(List<String> selectedBonos, String brandId) async {
    List<Usuario> userList = [];
    for(int i = 0; i < selectedBonos.length; ++i) {
      QuerySnapshot querySnapshot =  await _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Purchases")
          .where("bonoId", isEqualTo: selectedBonos[i])
          .where("isActive", isEqualTo: true)
          .get();

      for (int j = 0; j < querySnapshot.docs.length; j++) {
        Purchase purchase = Purchase.fromObjectAllData(querySnapshot.docs[j].id, querySnapshot.docs[j]);
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(users)
            .doc(purchase.userId).get();
        if(_documentSnapshot.exists) {
          Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
          if(!userList.any((element) => element.id == user.id)) {
            user.purchaseId = querySnapshot.docs[j].id;
            userList.add(user);
          }
        }
      }
    }
    return userList;
  }
  Future<List<Bono>> getBonosByBonosString(List<String> selectedBonos, String brandId) async {
    List<Bono> bonoList = [];
    for(int i = 0; i < selectedBonos.length; ++i) {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands)
          .doc(brandId).collection("Bonos").doc(selectedBonos[i]).get();
      bonoList.add(Bono.fromObjectAllData(_documentSnapshot.id, _documentSnapshot));
    }
    return bonoList;
  }

  Future<Purchase> getPurchaseEvents(Purchase purchase) async {
    // Get Purchase Events
    List<Event> eventList = [];
    QuerySnapshot querySnapshot2 = await _firestore
        .collection(purchases)
        .doc(purchase.id)
        .collection("Events")
        .get();

    for (int i = 0; i < querySnapshot2.docs.length; i++) {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(events).doc(querySnapshot2.docs[i].id).get();
      if(_documentSnapshot.exists) {
        Event event = Event.fromObjectAllData(
            _documentSnapshot.id, _documentSnapshot);
        eventList.add(event);
      }
    }
    // Set Purchase Events
    purchase.setPurchasedEventsData = eventList;

    return purchase;
  }

  Future<List<Event>> getPurchaseEventsLast30Days(Purchase purchase, String brandId) async {
    DateTime now = DateTime.now();
    var temp = now.subtract(const Duration(days: 30));
    Timestamp tmstp = Timestamp.fromDate(temp);

    // Get Purchase Events
    List<Event> eventList = [];
    QuerySnapshot querySnapshot2 = await _firestore
        .collection(brands)
        .doc(brandId)
        .collection('Events')
        .where("doneAt", isGreaterThanOrEqualTo: tmstp)
        .get();

    for (int i = 0; i < querySnapshot2.docs.length; i++) {
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
            .collection(events).doc(querySnapshot2.docs[i].id).get();
        Event event = Event.fromObjectAllData(
            _documentSnapshot.id, _documentSnapshot);
        DocumentSnapshot<
            Map<String, dynamic>> _documentSnapshotBonos = await _firestore
            .collection(events).doc(querySnapshot2.docs[i].id).collection(
            'Bonos').doc(purchase.bonoId!).get();
        if (_documentSnapshotBonos.exists) {
          eventList.add(event);
        }
    }
    return eventList;
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
      "directPurchase": false,
      "isActive": true,
    }).catchError((err) {
      print(err);
    });
    return uid;
  }

  Future<void> addEventToPurchase(String purchaseId, String eventId) async {
    if(purchaseId != "") {
      DocumentSnapshot<
          Map<String, dynamic>> _documentSnapshot = await _firestore.collection(
          events).doc(eventId).get();
      Event event = Event.fromObjectAllData(
          _documentSnapshot.id, _documentSnapshot);
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
  }

  //Update Data

  Future<void> updateUserPurchaseSessions(String userId, String brandId, String purchaseId, int sessions, String bonoId) async {
    // Update the Purchase Collection
    await _firestore.collection(purchases).doc(purchaseId).update({
      "sessions": sessions,
    });
    // Update the User/Purchase Collection
    await _firestore.collection(users).doc(userId).collection("Purchases").doc(purchaseId).update({
      "sessions": sessions,
    });
    // Update the Brand/Bonos/Purchase Collection
    await _firestore.collection(brands).doc(brandId).collection("Purchases").doc(purchaseId).update({
      "sessions": sessions
    });
    // Update the Brand/Bonos/Purchase Collection
    await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).collection("Purchases").doc(purchaseId).update({
      "sessions": sessions
    });

    //ENS INTERESSA? TODO
    await _firestore.collection(brands).doc(brandId).collection("Bonos").doc(bonoId).collection("Purchases").doc(purchaseId).update({
      "sessions": sessions
    });
  }

  Future<void> updatePurchaseEvents(String purchaseId, String userId, List<Event> eventsToAdd, List<Event> eventsToDelete) async {
    EventDataService _eventDataService = EventDataService();
    for(int i = 0; i < eventsToDelete.length; ++i)
    {
      print("Delete event: " + eventsToDelete[i].id!);
      deleteEventFromPurchase(purchaseId, eventsToDelete[i].id!);
      _eventDataService.deleteUserFromEvent(eventsToDelete[i].id!,userId);
    }
    print('Ading ev');
    print(eventsToAdd.length);
    for(int j = 0; j < eventsToAdd.length; ++j)
    {
      print("Add event: " + eventsToAdd[j].id!);
      await _firestore
          .collection(purchases)
          .doc(purchaseId)
          .collection("Events")
          .doc(eventsToAdd[j].id)
          .set({
        "isPrivate": eventsToAdd[j].isPrivate,
        "title": eventsToAdd[j].title,
        "imageUrl": eventsToAdd[j].imageUrl,
        "doneAt": eventsToAdd[j].doneAt,
        "year": eventsToAdd[j].year,
        "month": eventsToAdd[j].month,
        "day": eventsToAdd[j].day,
        "hour": eventsToAdd[j].hour,
        "minute": eventsToAdd[j].minute,
        "duration": eventsToAdd[j].duration,
        "numTrainers": eventsToAdd[j].numTrainers,
        "numClients": eventsToAdd[j].numClients,
        "maxMembers": eventsToAdd[j].maxMembers,
      });
      _eventDataService.addUserToEvent(eventsToAdd[j].id!,userId, purchaseId,true);
    }
  }

  Future<void> updatePurchasePaymentStatus(String purchaseId, bool isPaid) async {
      await _firestore
      .collection(purchases)
      .doc(purchaseId)
      .update({
        "directPurchase": isPaid,
      });
  }

  // Delete Data

  Future<void> detelePurchase(String purchaseId, String userId, String brandId) async {
    await deleteEventsFromUserPurchase(purchaseId,userId,brandId);
    await _firestore.collection(purchases).doc(purchaseId).delete();
    /*
    Ho fa CF.
    // Delete the Purchase Collection
    await _firestore.collection(purchases).doc(purchaseId).delete();
    // Delete the Users/Purchases Collection
    await _firestore.collection(users).doc(userId).collection("Purchases").doc(purchaseId).delete();
    // Delete the Brands/Purchases Collection
    await _firestore.collection(brands).doc(brandId).collection("Purchases").doc(purchaseId).delete();
    // Delete the Brands/Users/Purchases Collection
    await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).collection("Purchases").doc(purchaseId).delete();
     */

  }

  Future<void> deleteEventsFromUserPurchase(String purchaseId, String userId, String brandId) async {
    EventDataService _eventDataService = EventDataService();
    await _firestore
        .collection(purchases)
        .doc(purchaseId)
        .collection("Events")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        _eventDataService.deleteUserFromEvent(ds.id,userId);
        ds.reference.delete();
      }
    });

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
  }

  Future<void> deleteEventFromPurchase(String purchaseId, String eventId) async {
    await _firestore
    .collection(purchases)
    .doc(purchaseId)
    .collection("Events")
    .doc(eventId)
    .delete();
  }

  Future<void> deletedPurchaseUserFromEvent(Usuario user, String eventId) async {
    print('NEW FUNCTION DELETE USER FROM EVENT');
    if(user.purchaseId != "") {
      print(user.purchaseId);
      await deleteEventFromPurchase(user.purchaseId!, eventId);
    }
  }



  /////////////////////////////////////////////////////////////// STREAMS

  //Get bonos from brand
  Stream<DocumentSnapshot> getPurchaseInfoStream(String purchaseId) {
    return _firestore
        .collection(purchases)
        .doc(purchaseId)
        .snapshots();
  }

  //Get bonos from brand
  Stream<QuerySnapshot> getPurchaseEventsStream(String purchaseId) {
    return _firestore
        .collection(purchases)
        .doc(purchaseId)
        .collection("Events")
        .snapshots();
  }


}
