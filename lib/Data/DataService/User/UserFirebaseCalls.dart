import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:uuid/uuid.dart';


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



  // Authentication Services

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = await _auth.currentUser;
    return currentUser;
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
    if (authResult == null)
      return -1;
    if (authResult.user != null && isProduction) {
      if (authResult.user!.emailVerified)
        return 0;
      else
        return -2;
    } else {
      return 0;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<int> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 1;
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
        await this.deleteUserPhoto(user.uid);
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

  Future<void> deleteUserPhoto(String userId) async {
    await _firebaseStorage.ref().child("userPics/" + userId + ".png").delete();
  }

  //Checkers

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

  //Getters

  Future<Usuario> getUserDetails(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
        .collection(users).doc(uid).get();
    return Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
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
    if(querySnapshot.docs.length != 0) return querySnapshot.docs[0].get("bonoId").toString();
    else return '';


  }

  Future<String> getBonoUser(String userId, String brandId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Brands")
        .doc(brandId)
        .collection("Bonos")
        .get();
    if(querySnapshot.docs.length != 0) return querySnapshot.docs[0].get("bonoId").toString();
    else return '';

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
    else return [];
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

  //Add

  Future<int> addUser(String email, String password, String idioma) async {
    bool authError = false;
    bool firestoreError = false;
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    UserCredential? authResult;

    try {
      authResult = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
        if (userCredential != null && userCredential.user != null) {
          await _firestore.collection(users).doc(userCredential.user!.uid).set({
            "name": null,
            "firstName": null,
            "lastName": null,
            "nick": null,
            "notificationToken": null,
            "email": email,
            "imageUrl": null,
            "noImageUrl": "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53",
            "isFirst": true,
            "isTrainer": null,
            "isPrivate": true,
            "gender": null,
            "dateJoined": formatted,
            "dateOfBirth": null,
            "idioma": idioma,
            "brandID": null,
            "isAdmin": false,
          }).catchError((err) {
            print(err);
            firestoreError = true;
          });
          await userCredential.user!.sendEmailVerification();
        }
        return userCredential;
      });
    } catch (e) {
      authError = true;
    }

    /*
    UserCredential? authResult = await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) async {
      if (userCredential != null && userCredential.user != null) {
        await _firestore.collection(users).doc(userCredential.user!.uid).set({
          "name": null,
          "firstName": null,
          "lastName": null,
          "nick": null,
          "notificationToken": null,
          "email": email,
          "imageUrl": null,
          "noImageUrl": "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53",
          "isFirst": true,
          "isTrainer": null,
          "isPrivate": true,
          "gender": null,
          "dateJoined": formatted,
          "dateOfBirth": null,
          "idioma": idioma,
          "brandID": null,
          "isAdmin": false,
        }).catchError((err) {
          print(err);
          firestoreError = true;
        });
        await userCredential.user!.sendEmailVerification();
      }
      return userCredential;
    }).catchError((err) {
      authError = true;
    });
     */

    if (authResult != null && authResult.user != null) {
      if (authError) {
        return -1;
      } else if (firestoreError)
        return -2;
      else
        return 0;
    } else {
      return -1;
    }
  }

  Future<void> addUserNickname(String userId, String nickname) async {
    await _firestore.collection(nicknames).doc(nickname).set({
      "userId": userId,
    });
  }

  Future<void> addLocalNotification(String userId, ReceivedNotification notification) async {
    String id = notification.id!.toString();
    Timestamp now = Timestamp.now();
    // Event Id
    String payloadFeedback = notification.payload!.substring(0,2);
    String payloadSubString = notification.payload!.substring(2);
    bool isFeedback = payloadFeedback == "F-";
    String eventId = isFeedback ? payloadSubString : notification.payload!;
    // Firebase Query
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Local Notifications")
        .doc(id)
        .set({
      "eventId": eventId,
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

  //Update

  Future<void> updateUser(String uid, String name, String firstName,
      String lastName, String nick, String dateOfBirth,
      int gender, File? image, bool isTrainer) async {
    String imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53";
    if (image != null) {
      imageUrl = await updateUserPhoto(uid, image);
    }
    await _firestore.collection(users).doc(uid).update({
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "nick": nick,
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
      await this.markNotificationAsRead(userId, querySnapshot.docs[i].id,);
    }
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

  Future<void> deleteLocalNotification(String userId, String notificationId) async {
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Local Notifications")
        .doc(notificationId)
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
  Stream<QuerySnapshot> getAllBonosFromUser(String userId) {
    return _firestore
        .collection(users)
        .doc(userId)
        .collection("Bonos")
        .snapshots();
  }

}
