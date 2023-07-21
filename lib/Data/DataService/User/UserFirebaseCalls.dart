import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:uuid/uuid.dart';

import '../../Models/Purchase.dart';


// Firebase User Service Class. All calls to Firebase are in this class.
class UserFirebaseCalls {
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
  String purchases = isProduction ? 'Purchases' : '7777 Purchases';

  // Authentication Services

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = await _auth.currentUser;
    return currentUser;
  }

  Future<String?> getUserUIDWithEmail(String email) async {
    // Query Firestore for the email
    QuerySnapshot querySnapshot = await _firestore.collection(users).where('email', isEqualTo: email).get();
    // Check if we got any matches
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }

  Future<int> signIn(String email, String password) async {
    bool error = false;
    UserCredential? authResult;
    try {
      authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      error = true;
    }
    if (error) return -1;
    if (authResult == null) {
      return -1;
    }
    if (authResult.user != null && isProduction) {
      if (authResult.user!.emailVerified) {
        return 0;
      } else {
        return -2;
      }
    } else {
      return 0;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<int> resendEmail(String email) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('sendVerificationEmail');
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'email': email,
          'isTrainer': true,
        },
      );
      bool success = result.data['isSuccessful'];
      if (success) return 1;
      return -1;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }

  Future<int> resetPassword(String email) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('sendResetPasswordEmail');
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'email': email,
          'isTrainer': true,
        },
      );
      bool success = result.data['isSuccessful'];
      if (success) return 1;
      return -1;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }

  Future<bool> deleteUser(String password) async {
    try {
      bool error = false;
      User user = await _auth.currentUser!;
      await _auth
          .signInWithEmailAndPassword(email: user.email!, password: password)
          .catchError((value) {
        error = true;
      });
      if (error) return false;
      if (currentUser.imageUrl !=
          "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53") {
        await deleteUserPhoto(user.uid);
      }
      // Delete Notifications
      await _firestore.collection(users).doc(user.uid).collection(
          "Notifications").get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          batch.delete(ds.reference);
        }
      });
      // Delete Users Collection
      await _firestore.collection(users).doc(user.uid).delete();
      // Delete Firebase Auth
      await user.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteUserGoogle() async {
    try {
      User user = _auth.currentUser!;
      if (currentUser.imageUrl != "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53") {
        await deleteUserPhoto(user.uid);
      }
      // Delete Notifications
      await _firestore.collection(users).doc(user.uid).collection("Notifications").get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          batch.delete(ds.reference);
        }
      });
      // Delete Users Collection
      await _firestore.collection(users).doc(user.uid).delete();
      // Delete Firebase Auth
      await user.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> deleteUserPhoto(String userId) async {
    await _firebaseStorage.ref().child("userPics/" + userId + ".png").delete();
  }

  //Checkers


  // Check If User Exists
  Future<bool> checkIfUserExists(String uid) async {
    var userDocRef = _firestore.collection(users).doc(uid);
    var doc = await userDocRef.get();
    if (!doc.exists) {
      return false;
    } else {
      return true;
    }
  }

  // Check If User Exists
  Future<bool> checkIfEmailExists(String email) async {
    // Query Firestore for the email
    QuerySnapshot querySnapshot = await _firestore.collection(users).where('email', isEqualTo: email).get();
    // Check if we got any matches
    if (querySnapshot.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkIfNicknameExists(String nickname) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection(nicknames)
        .doc(nickname)
        .get();
    if (documentSnapshot.exists) {
      return false;
    } else {
      return true;
    }
  }

  // Check If User is Trainer
  Future<bool?> checkIfUserIsTrainer(String userId) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection(users)
        .doc(userId)
        .get();
    return documentSnapshot.get("isTrainer");
  }

  // Check If User is Blocked
  Future<bool> checkUserBlocked(String currentUser, String userId) async {
    try {
      var userDocRef = _firestore.collection(users).doc(currentUser).collection(
          "BlockedUsers").doc(userId);
      var doc = await userDocRef.get();
      if (!doc.exists) {
        return false;
      } else {
        return true;
      }
    }
    catch(e)
    {
      return false;
    }
  }

  //Getters

  Future<Usuario> getUserDetails(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
        .collection(users).doc(uid).get();
      print(uid);
      return Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
  }

  Future<Brand?> getUserBrands(String uid) async {
    QuerySnapshot querySnapshot = await _firestore
    .collection(users)
    .doc(uid)
    .collection("Brands")
    .get();
    if (querySnapshot.docs.isNotEmpty) {
      return Brand.fromObjectOnlyCoverData(querySnapshot.docs[0].id, querySnapshot.docs[0]);
    } else {
      return null;
    }
  }

  Future<Brand?> getUserBrandsToAdd(String uid, String brandId) async {
    DocumentSnapshot<Map<String, dynamic>> brandUser = await _firestore
        .collection(users)
        .doc(uid)
        .collection("Brands").doc(brandId)
        .get();
    if (brandUser.exists) {
      return Brand.fromObjectOnlyCoverData(brandUser.id, brandUser);
    } else {
      return null;
    }
  }

  Future<Usuario> getUserCoverDetails(String uid) async {
    try {
      DocumentSnapshot<
          Map<String, dynamic>> _documentSnapshot = await _firestore.collection(
          users).doc(uid).get();
      return Usuario.fromObjectOnlyCoverData(
          _documentSnapshot.id, _documentSnapshot);
    } catch (e) {
      print(e);
      return Usuario();
    }
  }

  Future<List<RequestToBrand>> getUserRequests(String userId) async {
    List<RequestToBrand> requestList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Requests")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      requestList.add(RequestToBrand.fromObjectAllData(
          querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return requestList;
  }

  Future <List<NotificationEvent>> getUserFirstNotificationsLimit10(String userId) async {
    List<NotificationEvent> notis = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
    /*
      QuerySnapshot querySnapshot = await _firestore
          .collection(users)
          .doc(userId)
          .collection("Notifications")
          .orderBy("year", descending: true)
          .orderBy("month", descending: true)
          .orderBy("day", descending: true)
          .orderBy("hour", descending: true)
          .orderBy("minutes", descending: true)
          .orderBy("seconds", descending: true)
          .limit(10)
          .get();
       */
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      notis.add(NotificationEvent.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return notis;
  }

  Future <List<NotificationEvent>> getUserMoreNotificationsLimit10(String userId, String lastNotifId) async {
    // Get Last Notification document
    DocumentSnapshot docu = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .doc(lastNotifId)
        .get();
    // Get More Notifications
    List<NotificationEvent> notis = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .orderBy("createdAt", descending: true)
        .startAfterDocument(docu)
        .limit(10)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      notis.add(NotificationEvent.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return notis;
  }

  Future<int> getUnreadNotifications(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .where("isRead", isEqualTo: false)
        .get();
    return querySnapshot.docs.length;
  }

  // Number Unread Conversations
  Future<int> getUnreadConversations(String userId) async {
    List<Conversation> conv = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(conversations)
        .where(
        "messagesRead", arrayContains: toMapisMessageRead(userId, true))
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      conv.add(Conversation.fromObject(
          querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return conv.length;
  }

  Map<String, dynamic> toMapisMessageRead(String? id, bool? isMessageRead) {
    return {
      'uid': id,
      'isMessageRead': isMessageRead,
    };
  }


  Future<String> getBonoRequest(String userId, String brandId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Brands")
        .doc(brandId)
        .collection("Bonos Requests")
        .get();
    if(querySnapshot.docs.length != 0) {
      return querySnapshot.docs[0].get("bonoId").toString();
    } else {
      return '';
    }


  }


  Future<List<int>> getUserFavourites(String brandId, String userId) async {
    var favourites;
    List<int> favouritesList = [];
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).get();
    if ((_documentSnapshot.data() as Map<String,dynamic>).containsKey('favourites')) {
      favourites = _documentSnapshot.get("favourites");
      for(int i = 0; i < favourites.length; ++i)
      {
        favouritesList.add(favourites[i]);
      }
      return favouritesList;
    }
    else {
      return [];
    }
  }

  Future<double> getUserZoomScale(String brandId, String userId) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).get();
    if ((_documentSnapshot.data() as Map<String,dynamic>).containsKey('zoomScale')) {
      return _documentSnapshot.get("zoomScale");
    } else {
      return 1.0;
    }
  }

  Future<List<ReceivedNotification>> getLocalNotifications(String userId) async {
    List<ReceivedNotification> notis = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Local Notifications")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      notis.add(
          ReceivedNotification.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i])
      );
    }
    return notis;
  }

  Future<ReceivedNotification?> getIndividualLocalNotification(String userId, String notificationId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
      await _firestore.collection(users)
          .doc(userId)
          .collection("Local Notifications")
          .doc(notificationId)
          .get();
      return ReceivedNotification.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    } catch (e) {
      return null;
    }
  }

  Future<List<ReceivedNotification>> findEventLocalNotification(String userId, String eventId) async {
    List<ReceivedNotification> notis = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Local Notifications")
        .where("eventId", isEqualTo: eventId)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      notis.add(
          ReceivedNotification.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i])
      );
    }
    return notis;
  }

  // Get First Notifications
  Future<List<ReceivedNotification>> findBonoLocalNotification(String userId, String bonoId, String purchaseId) async {
    List<ReceivedNotification> notis = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Local Notifications")
        .where("bonoId", isEqualTo: bonoId)
        .where("purchaseId", isEqualTo: purchaseId)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      notis.add(
          ReceivedNotification.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i])
      );
    }
    return notis;
  }

  Future<List<Bono>> getUserActiveBonosFromBrand(String userId, String brandId) async {
    List<Bono> userBonos = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .collection("Purchases")
        .where("isActive", isEqualTo: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Purchase purchase = Purchase.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
      int index = userBonos.indexWhere((element) => element.id == purchase.id);
      if (index == -1) {
        // Get Bono From Purchase
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot3 = await _firestore.collection(brands).doc(brandId).collection("Bonos").doc(purchase.bonoId).get();
        Bono bono = Bono.fromObjectAllData(_documentSnapshot3.id, _documentSnapshot3);
        // Add Conditions of This purchase
        bono.setBrandId = brandId;
        bono.setBonoPrice = purchase.price!.toDouble();
        bono.setBonoSessions = purchase.sessions!;
        bono.setConditionsData = Condition(
          expirationTime: querySnapshot.docs[i].get("expirationTime"),
          cancelTime: querySnapshot.docs[i].get("cancelTime"),
          weeklySessions: querySnapshot.docs[i].get("weeklySessions"),
        );
        // Bono Object Build
        userBonos.add(bono);
      }
    }
    return userBonos;
  }

  Future<Event> getLastUserEvent(String? userId) async {
    List<Event> events = [];
    List<Event> privateEvents = [];
    QuerySnapshot querySnapshot = await _firestore.collection(users)
        .doc(userId)
        .collection("Events").get();
    QuerySnapshot querySnapshotPrivate = await _firestore.collection(users)
        .doc(userId)
        .collection("Events").doc('Private Events').collection('Private Events').get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != "Private Events") {
        events.add(Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
    }
    for (int i = 0; i < querySnapshotPrivate.docs.length; i++) {
      privateEvents.add(Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }

    print(events.length);
    print(privateEvents.length);

    events.sort((a, b) {
      return b.doneAt!.toDate().compareTo(a.doneAt!.toDate());
    });

    privateEvents.sort((a, b) {
      return b.doneAt!.toDate().compareTo(a.doneAt!.toDate());
    });

    if(privateEvents.isEmpty)
      {
        if(events.isEmpty) {
          return Event();
        }
        else {
          return events[0];
        }

      }

    else {
      if(events.isEmpty) {
        return privateEvents[0];
      }
      else {
        if(events[0].doneAt!.toDate().compareTo(privateEvents[0].doneAt!.toDate()) == 0)
        {
          return events[0];
        }
        else {
          return privateEvents[0];
        }

      }
    }


  }

  //Get blocked by users
  Future<List<String>>  getBlockedByUsers(String userId) async {
    List<String> listUserIds = [];
    QuerySnapshot querySnapshot = await _firestore.collection(users)
        .doc(userId)
        .collection("BlockedByUsers")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      listUserIds.add(querySnapshot.docs[i].id);
    }
    return listUserIds;

  }

  Future<List<Bono>> getUserActiveBonos(String userId, String purchaseId) async {
    List<Bono> userBonos = [];
    if(purchaseId != "") {
      DocumentSnapshot<
          Map<String, dynamic>> _documentSnapshotPurchase = await _firestore
          .collection(purchases).doc(purchaseId).get();
      Purchase purchase = Purchase.fromObjectAllData(
          _documentSnapshotPurchase.id, _documentSnapshotPurchase);
      int index = userBonos.indexWhere((element) =>
      element.id == purchase.id);
      if (index == -1) {
        // Get Bono From Purchase
        DocumentSnapshot<
            Map<String, dynamic>> _documentSnapshot3 = await _firestore
            .collection(brands).doc(purchase.brandId).collection("Bonos").doc(
            purchase.bonoId).get();
        Bono bono = Bono.fromObjectAllData(
            _documentSnapshot3.id, _documentSnapshot3);
        // Add Conditions of This purchase
        bono.setPurchaseId = purchase.id!;
        bono.setBrandId = purchase.brandId!;
        bono.setBonoPrice = purchase.price!.toDouble();
        bono.setBonoSessions = purchase.sessions!;
        bono.setConditionsData = Condition(
          expirationTime: _documentSnapshotPurchase.get("expirationTime"),
          cancelTime: _documentSnapshotPurchase.get("cancelTime"),
          weeklySessions: _documentSnapshotPurchase.get("weeklySessions"),
        );
        // Bono Object Build
        userBonos.add(bono);
      }
    }
    else {
      QuerySnapshot querySnapshot = await _firestore
          .collection(users)
          .doc(userId)
          .collection("Purchases")
          .where("isActive", isEqualTo: true)
          .get();
      print(querySnapshot.docs.length);
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Purchase purchase = Purchase.fromObjectAllData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]);
        int index = userBonos.indexWhere((element) =>
        element.id == purchase.id);
        if (index == -1) {
          // Get Bono From Purchase
          DocumentSnapshot<
              Map<String, dynamic>> _documentSnapshot3 = await _firestore
              .collection(brands).doc(purchase.brandId).collection("Bonos").doc(
              purchase.bonoId).get();
          Bono bono = Bono.fromObjectAllData(
              _documentSnapshot3.id, _documentSnapshot3);
          // Add Conditions of This purchase
          bono.setPurchaseId = purchase.id!;
          bono.setBrandId = purchase.brandId!;
          bono.setBonoPrice = purchase.price!.toDouble();
          bono.setBonoSessions = purchase.sessions!;
          bono.setConditionsData = Condition(
            expirationTime: querySnapshot.docs[i].get("expirationTime"),
            cancelTime: querySnapshot.docs[i].get("cancelTime"),
            weeklySessions: querySnapshot.docs[i].get("weeklySessions"),
          );
          // Bono Object Build
          userBonos.add(bono);
        }
      }
    }
    return userBonos;
  }

  //Add

  Future<int> addUser(String email, String password, String idioma, bool isTrainer, [bool definePassword = false]) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('createAuthUser');
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'email': email,
          'password': password,
          'definePassword': definePassword,
          'isTrainer': isTrainer,
        },
      );
      await _firestore
      .collection(users)
      .doc(result.data['userId'])
      .set({
        "name": null,
        "firstName": null,
        "lastName": null,
        "nick": null,
        "notificationToken": null,
        "email": email,
        "imageUrl": null,
        "noImageUrl": "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53",
        "isFirst": true,
        "isTrainer": isTrainer,
        "isPrivate": true,
        "gender": null,
        "dateJoined": formatted,
        "dateOfBirth": null,
        "idioma": idioma,
        "brandID": null,
        "isAdmin": false,
      });
      print("All Correctly Created");
      return 0;
    } on FirebaseFunctionsException catch (e) {
      print('Error code: ${e.code}\nError message: ${e.message}\nDetails: ${e.details}');
      return -1;
    } catch (e) {
      print('Error: $e');
      bool emailExists = await checkIfEmailExists(email);
      if (emailExists) return -2;
      return -1;
    }
  }

  // Register User
  Future<bool> addUserGoogleOrApple(UserCredential authResult, String idioma) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    // Get First and Last Name
    String? firstName;
    String? lastName;
    if (authResult.user!.displayName != null ) {
      firstName = authResult.user!.displayName!.split(" ")[0];
      int length = authResult.user!.displayName!.split(" ")[0].length;
      lastName = authResult.user!.displayName!.substring(length+1);
    }
    try {
      await _firestore.collection(users).doc(authResult.user!.uid).set({
        "name": authResult.user!.displayName,
        "firstName": firstName,
        "lastName": lastName,
        "nick": null,
        "notificationToken": null,
        "email": authResult.user!.email,
        "imageUrl": authResult.user!.photoURL,
        "noImageUrl": "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53",
        "isFirst": true,
        "isTrainer": true,
        "isPrivate": true,
        "gender": null,
        "dateJoined": formatted,
        "dateOfBirth": null,
        "idioma": idioma,
        "isAdmin": false,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> addUserNickname(String userId, String nickname) async {
    await _firestore.collection(nicknames).doc(nickname).set({
      "userId": userId,
    });
  }

  // Add Local Notification
  Future<void> addLocalNotification(String userId, ReceivedNotification notification) async {
    String id = notification.id!.toString();
    Timestamp now = Timestamp.now();
    // Firebase Query
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Local Notifications")
        .doc(id)
        .set({
      "eventId": notification.eventId,
      "bonoId": notification.bonoId,
      "purchaseId": notification.purchaseId,
      "payload": notification.payload!,
      "createdAt": now,
      "firesAt": notification.firesAt!,
    });
  }

  Future<void> sendNotificationToUser(String userId, String type,
      var parameters) async {
    var uid = Uuid().v1();
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yy');
    final String formatted = formatter.format(now);
    Timestamp notifTimeStamp = Timestamp.fromDate(now);
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .doc(uid)
        .set({
      "userId": userId,
      "type": type,
      "isRead": false,
      "dateSent": formatted,
      "year": now.year.toString(),
      "month": now.month.toString(),
      "day": now.day.toString(),
      "hour": now.hour.toString(),
      "minutes": now.minute.toString(),
      "seconds": now.second.toString(),
      "parameters": parameters,
      "createdAt": notifTimeStamp,
    });
  }

  Future<void> sendRequestToBrand(String brandId, String name,
      bool isTrainer) async {
    User? currentUser = await getCurrentUser();
    var uid = Uuid().v1();
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yy');
    final String formatted = formatter.format(now);
    await _firestore
        .collection(users)
        .doc(currentUser!.uid)
        .collection("Requests")
        .doc(uid).set({
      "brandId": brandId,
      "userId": currentUser.uid,
      "name": name,
      "isTrainer": isTrainer,
      "dateSent": formatted,
      "year": now.year.toString(),
      "month": now.month.toString(),
      "day": now.day.toString(),
    });
  }

  Future<void> addBonoRequestToUser(String brandId, String userId, String bonoId) async {
    var uid = Uuid().v4();
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Brands")
        .doc(brandId)
        .collection("Bonos Requests")
        .doc(uid)
        .set({
      "bonoId": bonoId,
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> addBonoToUser(String brandId, String userId, String bonoId, int sessions, Timestamp time) async {
    var uid = Uuid().v4();
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Brands")
        .doc(brandId)
        .collection("Bonos")
        .doc(uid)
        .set({
      "bonoId": bonoId,
      "time": time,
      "sessions": sessions,
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> addFavouriteToUser(String brandID, String userId, List<int> favourites) async {
    await _firestore.collection(brands).doc(brandID).collection("Users").doc(userId).update({
      "favourites": favourites,
    });
  }

  Future<void> updateUserZoomScale(String userId, String brandId, double zoomScale) async {
    await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).update({
      "zoomScale": zoomScale,
    });
  }

  // Add User blocked
  Future<void> addUserBlocked(String currentUser, String userId) async {
    await _firestore
        .collection(users)
        .doc(currentUser)
        .collection("BlockedUsers")
        .doc(userId)
        .set({
      "userId": userId,
    });
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("BlockedByUsers")
        .doc(currentUser)
        .set({
      "userId": currentUser,
    });
  }

  //Update

// Add User
  Future<void> updateUser(String uid, String name, String firstName, String lastName, String dateOfBirth, int gender, File? image, String? googleImageUrl, bool isTrainer) async {
    String imageUrl = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53";
    if (image != null) {
      imageUrl = await updateUserPhoto(uid, image);
    } else if (googleImageUrl != null) {
      imageUrl = googleImageUrl;
    }
    await _firestore.collection(users).doc(uid).update({
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "imageUrl": imageUrl,
      "isFirst": false,
      "isTrainer": isTrainer,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
    }).catchError((err) {
      print(err);
    });
  }



  Future<void> updateUserThemePreferences(String uid, bool? isDark) async {
    if (isDark == null) {
      await _firestore.collection(users).doc(uid).update({
        "isDark": null,
      }).catchError((err) {
        print(err);
      });
    } else {
      await _firestore.collection(users).doc(uid).update({
        "isDark": isDark,
      }).catchError((err) {
        print(err);
      });
    }
  }

  Future<void> updateUserNotificationToken(String uid, String token) async {
    // Update User Notification Token
    await _firestore.collection(users).doc(uid).update({
      "notificationToken": token,
    });
    // Check If User in Brands too update notificationToken there as well.
    var brandsCollection = await _firestore.collection(users)
        .doc(uid)
        .collection("Brands")
        .get();
    if (brandsCollection.docs.length > 0) {
      for (var i = 0; i < brandsCollection.docs.length; i++) {
        var brandDocument = brandsCollection.docs[i];
        await _firestore
            .collection(brands)
            .doc(brandDocument.id)
            .collection("Users")
            .doc(uid)
            .update({
          "notificationToken": token,
        });
      }
    }
  }

  Future<void> updateCurrentUserFirstTime() async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection(users).doc(currentUser!.uid).update({
      "isFirst": false,
    });
  }

  Future<String> updateUserPhoto(String userId, File image) async {
    String imageURL = "";
    var storageRef = _firebaseStorage.ref().child("users/"+ userId +"/images/" + userId + ".jpeg");
    var uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        imageURL = value;
        await _firestore.collection(users).doc(userId).update({
          "imageUrl": value,
        });
      });
    });
    return imageURL;
  }

  Future<void> updateCurrentUserDatosPerifl(String name, String firstName,
      String lastName, int gender, String? dateOfBirth) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection(users).doc(currentUser!.uid).update({
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
    });
  }

  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate,
      String idioma) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection(users).doc(currentUser!.uid).update({
      "isPrivate": isPrivate,
      "idioma": idioma,
    });
  }

  Future<void> markNotificationAsRead(String userId,
      String notificationId) async {
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .doc(notificationId)
        .update({
      "isRead": true,
    });
  }

  Future<void> markALLNotificationAsRead(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .where("isRead", isEqualTo: false)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      await markNotificationAsRead(userId, querySnapshot.docs[i].id,);
    }
  }

  Future<void> updateUserBono(String userId, String brandId, Bono bono) async {
    // Update User Bono
    await _firestore.collection(users).doc(userId).collection("Bonos").doc(bono.id).update({
      "sessions": bono.sessions,
      "price": bono.price,
      "expirationTime": bono.condition?.expirationTime,
      "cancelTime": bono.condition?.cancelTime,
      "weeklySessions": bono.condition?.weeklySessions,
    });
    // Update the Purchase Collection
    await _firestore.collection(purchases).doc(bono.purchaseId).update({
      "sessions": bono.sessions,
      "price": bono.price,
      "expirationTime": bono.condition?.expirationTime,
      "cancelTime": bono.condition?.cancelTime,
      "weeklySessions": bono.condition?.weeklySessions,
    });
    // Update the User/Purchase Collection
    await _firestore.collection(users).doc(userId).collection("Purchases").doc(bono.purchaseId).update({
      "sessions": bono.sessions,
      "price": bono.price,
      "expirationTime": bono.condition?.expirationTime,
      "cancelTime": bono.condition?.cancelTime,
      "weeklySessions": bono.condition?.weeklySessions,
    });
    // Update the Brand/Bonos/Purchase Collection
    await _firestore.collection(brands).doc(brandId).collection("Purchases").doc(bono.purchaseId).update({
      "sessions": bono.sessions,
      "price": bono.price,
      "expirationTime": bono.condition?.expirationTime,
      "cancelTime": bono.condition?.cancelTime,
      "weeklySessions": bono.condition?.weeklySessions,
    });
    // Update the Brand/Bonos/Purchase Collection
    await _firestore.collection(brands).doc(brandId).collection("Bonos").doc(bono.id).collection("Purchases").doc(bono.purchaseId).update({
      "sessions": bono.sessions,
      "price": bono.price,
      "expirationTime": bono.condition?.expirationTime,
      "cancelTime": bono.condition?.cancelTime,
      "weeklySessions": bono.condition?.weeklySessions,
    });
    // Update the Brand/Bonos/Purchase Collection
    await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).collection("Purchases").doc(bono.purchaseId).update({
      "sessions": bono.sessions,
      "price": bono.price,
      "expirationTime": bono.condition?.expirationTime,
      "cancelTime": bono.condition?.cancelTime,
      "weeklySessions": bono.condition?.weeklySessions,
    });
  }

  //Delete

  Future<void> deleteRequestToBrand(RequestToBrand request) async {
    await _firestore
        .collection(users)
        .doc(request.userId)
        .collection("Requests")
        .doc(request.id)
        .delete();
  }

  Future<void> deleteUserNickname(String nickname) async {
    await _firestore.collection(nicknames).doc(nickname).delete();
  }

  Future<void> deleteUserBonoRequest(String userId, String brandId, String bonoId) async {
    QuerySnapshot querySnapshot = await _firestore.collection(users).doc(userId).collection("Brands").doc(brandId).collection(
        "Bonos Requests").where("bonoId", isEqualTo: bonoId).get();
    await _firestore.collection(users).doc(userId).collection("Brands").doc(brandId).collection(
        "Bonos Requests").doc(querySnapshot.docs[0].id).delete();
  }

  //Get the user bonos
  Future<void> deleteUserBono(String userId, String brandId, String bonoId) async {
    // Borrar a Users
    await _firestore.collection(users)
        .doc(userId)
        .collection("Bonos")
        .doc(bonoId)
        .delete();
    // Borrar a la Brand/Users/Bonos
    await _firestore.collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .collection("Bonos")
        .doc(bonoId)
        .delete();
    // Borrar a la Brand/Bonos/Users
    await _firestore.collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc(bonoId)
        .collection("Users")
        .doc(userId)
        .delete();
  }

  Future<void> deleteLocalNotification(String userId, String notificationId) async {
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Local Notifications")
        .doc(notificationId)
        .delete();
  }

  // Delete User blocked
  Future<void> deleteUserBlocked(String currentUser, String userId) async {
    await _firestore
        .collection(users)
        .doc(currentUser)
        .collection("BlockedUsers")
        .doc(userId)
        .delete();
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("BlockedByUsers")
        .doc(currentUser)
        .delete();
  }

  //STREAMS

  Stream<QuerySnapshot> getAllNotificationsUserStream(String userId) {
    return _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .snapshots();
  }



  //Get bono Requests from brand
  Stream<QuerySnapshot> getUserActivePurchasesFromBrandStream(String userId, String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .collection("Purchases")
        .where("isActive", isEqualTo: true)
        .snapshots();
  }

  //Get bono Requests from brand
  Stream<DocumentSnapshot> getBonoFromEventUser(String userId, String bonoId) {
    return _firestore
        .collection(users)
        .doc(userId)
        .collection("Bonos")
        .doc(bonoId)
        .snapshots();
  }

}
