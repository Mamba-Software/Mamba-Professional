import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/ChatUsers.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Models/Message.dart';
import 'package:mamba_castelldefels/Models/Question.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:uuid/uuid.dart';

// Firebase Service Class. All calls to Firebase are in this class.
class FirebaseDatabaseService {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  // Firebase collections
  String users = isProduction ? 'Users' : '7777 Users';
  String nicknames = isProduction ? 'Nicknames' : '7777 Nicknames';
  String brands = isProduction ? 'Brands' : '7777 Brands';
  String events = isProduction ? 'Events' : '7777 Events';
  String locations = isProduction ? 'Locations' : '7777 Locations';
  String groupOfQuestions = isProduction ? 'GroupOfQuestions' : '7777 GroupOfQuestions';
  String questions = isProduction ? 'Questions' : '7777 Questions';
  String answers = isProduction ? 'Answers' : '7777 Answers';
  String conversations = isProduction ? 'Conversations' : '7777 Conversations';
  String messages = isProduction ? 'Messages' : '7777 Messages';
  String errors = isProduction ? 'Errors' : '7777 Errors';
  String requests = isProduction ? 'Requests' : '7777 Requests';


  Map<String, dynamic> toMapisMessageRead(String? id, bool? isMessageRead) {
    return {
      'uid': id,
      'isMessageRead': isMessageRead,
    };
  }

  // Authentication Services
  Future<int> signIn(String email, String password) async {
    bool error = false;
    UserCredential authResult = await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((value) {
      error = true;
    });
    if (error) return -1;
    if (authResult == null)
      return -1;
    if (authResult.user != null && isProduction) {
      if (authResult.user!.emailVerified) return 0;
      else return -2;
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
      if (currentUser.imageUrl != "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53") {
        await this.deleteUserPhoto(user.uid);
      }
      await _firestore.collection(users).doc(user.uid).delete();
      await user.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<Brand?> checkUserIsBrandCreator(String userId) async {
    Brand brand = Brand();
    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .where("adminID", isEqualTo: userId)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brand = Brand.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
    }
    if (brand.id == null) return null;
    else return brand;
  }

  Future<bool> checkCurrentUser() async {
    User currentUser;
    currentUser = await _auth.currentUser!;
    if (currentUser != null)
      return true;
    else
      return false;
  }

  Future<bool> checkIfItsMe(String uid) async {
    User currentUser;
    currentUser = await _auth.currentUser!;
    if (currentUser.uid == uid)
      return true;
    else
      return false;
  }

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = await _auth.currentUser;
    return currentUser;
  }

  Future<Usuario> getUserDetails(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(users).doc(uid).get();
    return Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);;
  }

  Future<List<String>> getUserCoverDetails(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(users).doc(uid).get();
      String name = _documentSnapshot.get("name");
      String image = _documentSnapshot.get("imageUrl");
      List<String> result = [name, image];
      return result;
    } catch (e) {
      print(e);
      return ["Error"];
    }
  }

  // User Model Services
  // Register User
  Future<int> addUser(String email, String password, String idioma) async {
    bool authError = false;
    bool firestoreError = false;
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    UserCredential? authResult =
      await _auth
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
      print(err);
      authError = true;
    });

    if (authResult != null && authResult.user != null) {
      if (authError)
        return -1;
      else if (firestoreError)
        return -2;
      else
        return 0;
    } else {
      return -1;
    }
  }

  // Register User
  Future<void> addUserNickname(String userId, String nickname) async {
    await _firestore.collection(nicknames).doc(nickname).set({
      "userId": userId,
    });
  }

  // Check If Alias Exists
  Future<bool> checkIfNicknameExists(String nickname) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection(nicknames).doc(nickname).get();
    if (documentSnapshot.exists) {
      return false;
    } else {
      return true;
    }
  }

  // Add User
  Future<void> updateUser(String uid, String name, String firstName, String lastName, String nick, String dateOfBirth,
      int gender, File? image, bool isTrainer) async {
    String imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53";
    if (image != null) {
      imageUrl = await updateCurrentUserPhoto(image);
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
  // Add User Notification Token
  Future<void> updateUserNotificationToken(String uid, String token) async {
    // Update User Notification Token
    await _firestore.collection(users).doc(uid).update({
      "notificationToken": token,
    });
    // Check If User in Brands too update notificationToken there as well.
    var brandsCollection = await _firestore.collection(users).doc(uid).collection("Brands").get();
    if (brandsCollection.docs.length > 0) {
      for (var i=0; i<brandsCollection.docs.length; i++) {
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

  // Add Error/ Report Bug
  Future<bool> addError(String title, String description, [String? stepsReproduce]) async {
    var uid = Uuid().v1();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    User? currentUser = await getCurrentUser();
    try {
      await _firestore.collection(errors).doc(uid).set({
        "userID": currentUser!.uid,
        "title": title,
        "descripcion": description,
        "stepsReproduce": stepsReproduce,
        "dateSent": formatted,
      });
      await _firestore
        .collection(users)
        .doc(currentUser.uid)
        .collection("Errors")
        .doc(uid)
        .set({
          "dateSent": formatted,
        });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Updates
  Future<void> updateCurrentUserFirstTime() async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection(users).doc(currentUser!.uid).update({
      "isFirst": false,
    });
  }

  Future<int> updateCurrentUserBrand(String brandID) async {
    User? currentUser = await getCurrentUser();
    bool firestoreError = false;
    await _firestore.collection(users).doc(currentUser!.uid).update({
      "brandID": brandID,
    }).catchError((err) {
      print(err);
      firestoreError = true;
    });
    if (firestoreError) {
      return -1;
    } else {
      return 1;
    }
  }

  Future<String> updateCurrentUserPhoto(File image) async {
    User? firebaseUser = await getCurrentUser();
    String imageURL = "";
    var storageRef = await _firebaseStorage
        .ref()
        .child("userPics/" + firebaseUser!.uid + ".png");
    var uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        imageURL = value;
        await _firestore.collection(users).doc(firebaseUser.uid).update({
          "imageUrl": value,
        });
      });
    });
    return imageURL;
  }

  Future<void> deleteUserPhoto(String userId) async {
    await _firebaseStorage.ref().child("userPics/" + userId + ".png").delete();
  }

  Future<void> updateCurrentUserDatosPerifl(String name, String firstName, String lastName, int gender, String? dateOfBirth) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection(users).doc(currentUser!.uid).update({
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
    });
  }

  Future<void> updateCurrentUserSettingsPerifl(
      bool isPrivate, String idioma, String previousIdioma) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection(users).doc(currentUser!.uid).update({
      "isPrivate": isPrivate,
      "idioma": idioma,
      "previousIdioma": previousIdioma,
    });
  }

  Future<void> addUserToBrand(String userId, String brandId, int role) async {
    Usuario user = await this.getUserDetails(userId);
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .set({
          "firstName": user.firstName,
          "lastName": user.lastName,
          "nick": user.nick,
          "imageUrl": user.imageUrl,
          "noImageUrl": user.noImageUrl,
          "isTrainer": user.isTrainer,
          "isPrivate": user.isPrivate,
          "notificationToken": user.notificationToken,
          "role": role,
        }).catchError((err) {
          print(err);
        });
  }

  Future<void> deleteUserFromBrand(String userId, String brandId) async {
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .delete();
  }

  Future<void> deleteBrandUsers(String brandId) async {
    await _firestore
      .collection(brands)
      .doc(brandId)
      .collection("Users")
      .get().then((snapshot) async {
        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
      });
  }

  Future<void> leaveBrandUser(String userId) async {
    await _firestore.collection(users).doc(userId).update({
      "brandID": null,
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> updateConversation(String? uid, var messagesRead, String lastMessage, String year,
      String month, String day, String hour, String minute, String second) async {
    await _firestore.collection(conversations).doc(uid).update({
      "lastMessage": lastMessage,
      "messagesRead": messagesRead,
      "year": year,
      "month": month,
      "day": day,
      "hour": hour,
      "minute": minute,
      "second": second,
    });
  }

  Future<void> updateConversationUsers(String? uid, var users) async {
    await _firestore.collection(conversations).doc(uid).update({
      "users": users,
    });
  }

  Future<void> updateConversationNewUser(String? brandId, String? userId) async {

    QuerySnapshot querySnapshot = await _firestore
        .collection(conversations)
        .where("brandId", isEqualTo: brandId)
        .get();

    Conversation conversation = Conversation.fromObject(
        querySnapshot.docs[0], querySnapshot.docs[0].id);

    DocumentSnapshot<Map<String, dynamic>> _docu =
    await _firestore.collection(users).doc(userId).get();
    Usuario user = Usuario.fromObjectAllData(_docu.id, _docu);
    conversation.users.add({
      'uid': user.id,
    });

    //List<Map> userMessagesRead = [];

    /*for(int i = 0; i < conversation.isMessageRead.length; ++i) {
      userMessagesRead.add(conversation.isMessageRead[i]);
    }*/
    //if(conversation.isMessageRead is Map) userMessagesRead.add(conversation.isMessageRead);
    //else userMessagesRead = conversation.isMessageRead;

    // userMessagesRead.add(toMapisMessageRead(user.id, true));

    await _firestore.collection(conversations).doc(
        conversation.conversationId).update({
      "users": conversation.users,
    });
  }

    Future<void> updateReadMessage(String? uid, var messagesRead) async {
      await _firestore.collection(conversations).doc(uid).update({
        "messagesRead": messagesRead,
      });
    }

  Future<void> deleteUserMemberConversations(Map<String, dynamic> currentUser)async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(conversations)
        .where("users", arrayContains: currentUser)
        .get();

    QuerySnapshot querySnapshotMessages;

    for (var conv in querySnapshot.docs) {
      querySnapshotMessages = await _firestore
          .collection(messages)
          .where("conversationId", isEqualTo: conv.id)
          .get();

      if(Conversation.fromObject(conv, conv.id).brandId == 'null') {
        for (var mess in querySnapshotMessages.docs) {
          await this.deleteMessage(mess.id);
        }
        await this.deleteConversation(conv.id);
      }
      else {
        print(currentUser["uid"]);
        for (var mess in querySnapshotMessages.docs) {
          print(Message.fromObject(
              mess, mess.id).userSent);
          if(currentUser["uid"] == Message.fromObject(
              mess, mess.id).userSent) await this.deleteMessage(mess.id);
        }
      }
    }
  }

  Future<void> deleteBrandConversations(String? brandId) async {
    Conversation conv = await getConversationByBrand(brandId);

    QuerySnapshot querySnapshotMessages = await _firestore
        .collection(messages)
        .where("conversationId", isEqualTo: conv.conversationId)
        .get();

    for (var mess in querySnapshotMessages.docs) {
      await this.deleteMessage(mess.id);
    }
    await this.deleteConversation(conv.conversationId!);
  }

  // Brand Model Services

  // Add Brand
  Future<String> addBrand(String name, File image, String description, List<double> workShift, int maxMembers) async {
    User? firebaseUser = await getCurrentUser();
    bool firestoreError = false;
    var uid = Uuid().v4();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    await _firestore.collection(brands).doc(uid).set({
      "adminID": firebaseUser!.uid,
      "logoUrl": "",
      "name": name,
      "description": description,
      "dateJoined": formatted,
      "groupRoomId": null,
      "baseLocation": null,
      "numberClients": 0,
      "numberTrainers": 1,
      "workShift": workShift,
      "maxMembers": maxMembers,
    }).catchError((err) {
      print(err);
      firestoreError = true;
    });

    if (!firestoreError) {
      await updateCurrentBrandPhoto(uid, image);
      return uid;
    } else {
      return "Error";
    }
  }

  Future<void> deleteBrand(String brandId) async {
    // Delete All Events from Brand
    await this.deleteBrandEvents(brandId);
    // Delete All Locations from Brand
    await this.deleteBrandLocations(brandId);
    // Get All Brand Users
    List<Usuario> brandUsers = await this.getAllClientsFromBrand(brandId);
    brandUsers.addAll(await this.getAllTrainersFromBrand(brandId));
    // All Users Leave Brand
    for (var i = 0; i < brandUsers.length; i++) {
      NotificationService().userLeavesBrand(brandUsers[i].id!, brandId);
      await this.leaveBrandUser(brandUsers[i].id!);
    }
    // Delete Brand Photo
    await this.deleteBrandPhoto(brandId);
    // Delete Brand
    await _firestore.collection(brands).doc(brandId).delete();
  }

  Future<void> updateNumberMembers(String brandID) async {
    List<Usuario> trainers = await this.getAllTrainersFromBrand(brandID);
    List<Usuario> clients = await this.getAllClientsFromBrand(brandID);
    await _firestore.collection(brands).doc(brandID).update({
      "numberClients": clients.length,
      "numberTrainers": trainers.length,
    });
  }

  Future<String> updateCurrentBrandPhoto(String brandID, File image) async {
    var result;
    var storageRef =
        await _firebaseStorage.ref().child("brandPics/" + brandID + ".png");
    var uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        result = value;
        await _firestore.collection(brands).doc(brandID).update({
          "logoUrl": value,
        });
      });
    });
    return result;
  }

  Future<void> deleteBrandPhoto(String brandID) async {
    await _firebaseStorage.ref().child("brandPics/" + brandID + ".png").delete();
  }

  Future<void> updateBrandInfo(String brandID, String name, String description,
      int maxMembers, List<double> workShift) async {
    await _firestore.collection(brands).doc(brandID).update({
      "name": name,
      "description": description,
      "maxMembers": maxMembers,
      "workShift": workShift,
    });
  }

  Future<void> updateBrandBaseLocation(String brandID, String locationID) async {
    await _firestore
        .collection(brands)
        .doc(brandID)
        .update({"baseLocation": locationID});
  }

  Future<List<Brand>> getAllBrands() async {
    List<Brand> brandList = [];
    QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brandList.add(
          Brand.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return brandList;
  }

  Future<List<Brand>> getAllBrandsFromUser(String userId) async {
    List<Brand> brandList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Brands")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brandList.add(Brand.fromObjectOnlyCoverData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return brandList;
  }

  Future<List<RequestToBrand>> getUserRequests(String userId) async {
    List<RequestToBrand> requestList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Requests")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      requestList.add(RequestToBrand.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return requestList;
  }

  Future<Brand> getBrandDetails(String brandID) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection(brands).doc(brandID).get();
    return Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
  }

  Future<Brand> getBrandCoverDetails(String brandID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandID).get();
      return Brand.fromObjectOnlyCoverData(_documentSnapshot.id, _documentSnapshot);
    } catch (e) {
      print(e.toString());
      return Brand();
    }
  }

  Future<List<String>> getBrandCover(String brandID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandID).get();
      String name = _documentSnapshot.get("name");
      String image = _documentSnapshot.get("logoUrl");
      List<String> result = [name, image];
      return result;
    } catch (e) {
      print(e);
      return ["Error"];
    }
  }

  Future<List<Usuario>> getAllTrainersFromBrand(String brandId) async {
    List<Usuario> usersList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .where("brandID", isEqualTo: brandId)
        .where("isTrainer", isEqualTo: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      usersList.add(
          Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return usersList;
  }

  Future<List<Usuario>> getAllClientsFromBrand(String brandId) async {
    List<Usuario> usersList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .where("brandID", isEqualTo: brandId)
        .where("isTrainer", isEqualTo: false)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      usersList.add(
          Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return usersList;
  }

  Future<bool> checkIfBrandExists(String brandID) async {
    var userDocRef = await _firestore.collection(brands).doc(brandID);
    var doc = await userDocRef.get();
    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  // Events Calendar
  // Add Event
  Future<String> addEvent(
      String? brandID,
      String? title,
      String? description,
      String? year,
      String? month,
      String? day,
      String? hour,
      String? minute,
      double? duration,
      String? locationId,
      int? maxMembers,
      var selectedTrainers)
  async {
    var eventID = Uuid().v1();
    User? currentUser = await getCurrentUser();
    try {
      await _firestore.collection(events).doc(eventID).set({
        "brandID": currentBrand.id,
        "creatorID": currentUser!.uid,
        "title": title,
        "description": description,
        "year": year,
        "month": month,
        "day": day,
        "hour": hour,
        "minute": minute,
        "duration": duration,
        "locationId": locationId,
        "maxMembers": maxMembers,
        "joinedMembers": [],
        "selectedTrainers": selectedTrainers,
        "isCompleted": false,
      });
      await _firestore.collection(events).doc(eventID).collection("Brands").doc(currentBrand.id).set({
        "name": currentBrand.name,
        "logoUrl": currentBrand.logoUrl,
      });
      Location location = await this.getSingleLocation(locationId!);
      await _firestore.collection(events).doc(eventID).collection("Locations").doc(locationId).set({
        "description": location.description,
      });
      for (var i=0; i<selectedTrainers.length; i++) {
        Usuario user = await this.getUserDetails(selectedTrainers[i]);
        await _firestore.collection(events).doc(eventID).collection("Users").doc(user.id).set({
          "name": user.name,
          "firstName": user.firstName,
          "lastName": user.lastName,
          "imageUrl": user.imageUrl,
          "noImageUrl": user.noImageUrl,
          "isTrainer": user.isTrainer,
          "isPrivate": user.isPrivate,
          "notificationToken": user.notificationToken,
        });
      }
      return eventID;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  // Get Single Event
  Future<Event> getSingleEvent(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
      await _firestore.collection(events).doc(id).get();
      return Event.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
    } catch (e) {
      print(e);
      return Event();
    }
  }

  // Get All Events for Client
  Future<List<Event>> getAllEventsWithLocationId(String locationId) async {
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .where("locationId", isEqualTo: locationId)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      eventsList.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return eventsList;
  }

  // Get All Events for Client
  Future<List<Event>> getAllEventsFromClient(String clientid) async {
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("joinedMembers", arrayContains: clientid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      eventsList.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return eventsList;
  }

  // Get All Events for Trainer
  Future<List<Event>> getAllEventsFromTrainer(String trainerid) async {
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("selectedTrainers", arrayContains: trainerid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      eventsList.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return eventsList;
  } // Get All Events for Client

  // Get All Events for Client
  Future<List<Event>> getAllClientEventsFromBrand(
      String clientid, String brandId) async {
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("brandID", isEqualTo: brandId)
        .where("joinedMembers", arrayContains: clientid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      eventsList.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return eventsList;
  }

  // Get All Finished Events for Client
  Future<List<int>> getAllClientEventsFinished(String clientid, String brandId) async {
    DateTime today = DateTime.now();
    List<Event> eventsList = [];
    List<Event> eventsMonth = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .where("brandID", isEqualTo: brandId)
        .where("joinedMembers", arrayContains: clientid)
        .get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Event event = Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id);
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      if (today.isAfter(startDate)) {
        eventsList.add(event);
        if (today.year == int.parse(event.year!) && today.month == int.parse(event.month!)) {
          eventsMonth.add(event);
        }
      }
    }
    List<int> result = [eventsList.length, eventsMonth.length];
    return result;
  }

  // Get All Events for Trainer
  Future<List<Event>> getAllTrainerEventsFromBrand(
      String trainerid, String brandId) async {
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("brandID", isEqualTo: brandId)
        .where("selectedTrainers", arrayContains: trainerid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      eventsList.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return eventsList;
  }

  // Get All Finished Events for Trainer
  Future<List<int>> getAllTrainerEventsFinished(String trainerid, String brandId) async {
    DateTime today = DateTime.now();
    List<Event> eventsList = [];
    List<Event> eventsMonth = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .where("brandID", isEqualTo: brandId)
        .where("selectedTrainers", arrayContains: trainerid)
        .get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Event event = Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id);
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      if (today.isAfter(startDate)) {
        eventsList.add(event);
        if (today.year == int.parse(event.year!) && today.month == int.parse(event.month!)) {
          eventsMonth.add(event);
        }
      }
    }
    List<int> result = [eventsList.length, eventsMonth.length];
    return result;
  }

  // Get All Events Finished Brand
  Future<int> getNumberEventsFinishedBrand(String brandId) async {
    DateTime today = DateTime.now();
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .where("brandID", isEqualTo: brandId)
        .get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Event event = Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id);
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      if (today.isAfter(startDate)) {
        eventsList.add(event);
      }
    }
    return eventsList.length;
  }

  // Get All Events Finished Brand
  Future<int> getNumberEventsToDoBrand(String brandId) async {
    DateTime today = DateTime.now();
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .where("brandID", isEqualTo: brandId)
        .get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Event event = Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id);
      var startDate = DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      if (today.isBefore(startDate)) {
        eventsList.add(event);
      }
    }
    return eventsList.length;
  }

  // Get All Events for Today of Brand
  Future<List<Event>> getAllEventsTodayBrand(String brandId) async {
    DateTime today = DateTime.now();
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(events)
        .where("year", isEqualTo: today.year.toString())
        .where("month", isEqualTo: today.month.toString())
        .where("day", isEqualTo: today.day.toString())
        .where("brandID", isEqualTo: brandId)
        .orderBy("hour", descending: false)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      eventsList.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return eventsList;
  }

  // Get All Events for User Today
  Future<List<Event>> getAllEventsTodayUser(
      String userid, bool isTrainer) async {
    DateTime today = DateTime.now();
    List<Event> eventsList = [];
    QuerySnapshot querySnapshot;
    if (isTrainer) {
      querySnapshot = await _firestore
          .collection(events)
          .where("year", isEqualTo: today.year.toString())
          .where("month", isEqualTo: today.month.toString())
          .where("day", isEqualTo: today.day.toString())
          .where("selectedTrainers", arrayContains: userid)
          .orderBy("hour", descending: false)
          .get();
    } else {
      querySnapshot = await _firestore
          .collection(events)
          .where("year", isEqualTo: today.year.toString())
          .where("month", isEqualTo: today.month.toString())
          .where("day", isEqualTo: today.day.toString())
          .where("joinedMembers", arrayContains: userid)
          .orderBy("hour", descending: false)
          .get();
    }
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      eventsList.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return eventsList;
  }

  // Delete Event
  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection(events).doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete All Brand Events
  Future<void> deleteBrandEvents(String brandId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(events)
          .where("brandID", isEqualTo: brandId)
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        await this.deleteEvent(querySnapshot.docs[i].id);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete User from All Existing Events
  Future<void> deleteUserFromAllBrandEvents(String uid, String brandId, bool isTrainer) async {
    List<Event> userEvents = [];
    if (isTrainer) {
      userEvents = await this.getAllTrainerEventsFromBrand(uid, brandId);
      for (var i = 0; i < userEvents.length; i++) {
        Event event = userEvents[i];
        await this.leaveEvent(event.id!, uid, true);
      }
    } else {
      userEvents = await this.getAllClientEventsFromBrand(uid, brandId);
      for (var i = 0; i < userEvents.length; i++) {
        Event event = userEvents[i];
        await this.leaveEvent(event.id!, uid, false);
      }
    }
  }

  // Get a Event Trainers
  Future<List<String>> getEventTrainers(String eid) async {
    List<String> participants = [];
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection(events).doc(eid).get();
    Event event =
        Event.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
    for (int i = 0; i < event.selectedTrainers.length; i++) {
      participants.add(event.selectedTrainers[i]);
    }
    return participants;
  }

  // Get a Event Clients
  Future<List<String>> getEventClients(String eid) async {
    List<String> participants = [];
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection(events).doc(eid).get();
    Event event =
        Event.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
    for (int i = 0; i < event.joinedMembers.length; i++) {
      participants.add(event.joinedMembers[i]);
    }
    return participants;
  }

  // Update Event Trainers
  Future<bool> updateEventTrainers(String eid, var selectedTrainers) async {
    try {
      await _firestore.collection(events).doc(eid).update({
        "selectedTrainers": selectedTrainers,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Update Event Trainers
  Future<bool> updateEventClients(String eid, var joinedMembers) async {
    try {
      await _firestore.collection(events).doc(eid).update({
        "joinedMembers": joinedMembers,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Join an Event
  Future<bool> joinEvent(String eid, String uid) async {
    Event event = await this.getSingleEvent(eid);
    if (event.joinedMembers.length < event.maxMembers) {
      List<String> eventUsers = [];
      eventUsers = await this.getEventClients(eid);
      eventUsers.add(uid);
      await this.updateEventClients(eid, eventUsers);
      return true;
    } else {
      return false;
    }
  }

  // Leave an Event
  Future<bool> leaveEvent(String eid, String uid, bool isTrainer) async {
    bool isFound = false;
    Event event = await this.getSingleEvent(eid);
    DateTime now = DateTime.now();
    var startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    List<String> eventUsers = [];
    if (isTrainer) {
      eventUsers = await this.getEventTrainers(eid);
      for (var i = 0; i < eventUsers.length; i++) {
        String trainerid = eventUsers[i];
        if (trainerid == uid) {
          isFound = true;
          if (startDate.isBefore(now)) {
            eventUsers[i] = "notfound";
          } else {
            eventUsers.removeAt(i);
          }
          break;
        }
      }
      if (isFound) await this.updateEventTrainers(eid, eventUsers);
      return isFound;
    } else {
      eventUsers = await this.getEventClients(eid);
      for (var i = 0; i < eventUsers.length; i++) {
        String trainerid = eventUsers[i];
        if (trainerid == uid) {
          isFound = true;
          if (startDate.isBefore(now)) {
            eventUsers[i] = "notfound";
          } else {
            eventUsers.removeAt(i);
          }
          break;
        }
      }
      if (isFound) await this.updateEventClients(eid, eventUsers);
      return isFound;
    }
  }

  // Update Event
  Future<void> updateEvent(
      String? id,
      String? title,
      String? description,
      String? year,
      String? month,
      String? day,
      String? hour,
      String? minute,
      double? duration,
      String? locationId,
      int? maxMembers,
      var selectedTrainers) async {
    try {
      await _firestore.collection(events).doc(id).update({
        "title": title,
        "description": description,
        "year": year,
        "month": month,
        "day": day,
        "hour": hour,
        "minute": minute,
        "duration": duration,
        "locationId": locationId,
        "maxMembers": maxMembers,
        "selectedTrainers": selectedTrainers,
      });
    } catch (e) {
      print(e.toString());
    }
  }
  // Update Event Location
  Future<void> updateEventLocation(String eventId, String locationId) async {
    try {
      await _firestore.collection(events).doc(eventId).update({
        "locationId": locationId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // Update Event Is Completed
  Future<void> updateEventCompleted(String id) async {
    await _firestore.collection(events).doc(id).update({
      "isCompleted": true,
    });
  }

  // Update Event Participants
  // Update Event Trainers

  // Locations

  // Add Location
  Future<String> addLocation(
      String brandId,
      bool isBaseLocation,
      String placeId,
      String description,
      String street,
      String streetNumber,
      String city,
      String zipCode,
      double latitude,
      double longitude) async {
    var uid = Uuid().v1();
    try {
      await _firestore..collection(locations).doc(uid).set({
        "brandID": brandId,
        "placeId": placeId,
        "isBaseLocation": isBaseLocation,
        "description": description,
        "street": street,
        "streetNumber": streetNumber,
        "city": city,
        "zipCode": zipCode,
        "latitude": latitude,
        "longitude": longitude
      });
      return uid;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  // Update Location
  Future<void> updateLocation(
      String locationID,
      String brandId,
      bool isBaseLocation,
      String placeId,
      String description,
      String street,
      String streetNumber,
      String city,
      String zipCode,
      double latitude,
      double longitude) async {
    var uid = Uuid().v1();
    try {
      await _firestore..collection(locations).doc(locationID).update({
        "brandID": brandId,
        "placeId": placeId,
        "isBaseLocation": isBaseLocation,
        "description": description,
        "street": street,
        "streetNumber": streetNumber,
        "city": city,
        "zipCode": zipCode,
        "latitude": latitude,
        "longitude": longitude
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete Location
  Future<bool> deleteLocation(String locationId, String? baseLocation) async {
    try {
      if (baseLocation != null) {
        List<Event> events = await  this.getAllEventsWithLocationId(locationId);
        for (int i = 0; i < events.length; i++) {
          Event event = events[i];
          await this.updateEventLocation(event.id!, baseLocation);
        }
      }
      await _firestore..collection(locations).doc(locationId).delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Delete Location
  Future<void> deleteBrandLocations(String brandId) async {
    try {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(locations)
            .where("brandID", isEqualTo: brandId)
            .get();
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          await this.deleteLocation(querySnapshot.docs[i].id, null);
        }
      } catch (e) {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get Single Location
  Future<Location> getSingleLocation(String locationId) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection(locations).doc(locationId).get();
    return Location.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  // Requests

  // Send Request
  Future<void> sendRequestToBrand(String brandId, String name, bool isTrainer) async {
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

  // Delete Request
  Future<void> deleteRequestToBrand(RequestToBrand request) async {
    await _firestore
        .collection(users)
        .doc(request.userId)
        .collection("Requests")
        .doc(request.id)
        .delete();
  }

  // Accept Request To Brand
  Future<void> acceptRequestFromUser(RequestToBrand request) async {
    /* Get the Request
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
        .collection(brands)
        .doc(request.brandId)
        .collection("Requests")
        .doc(request.id)
        .get();
    RequestToBrand request = RequestToBrand.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
     */
    // Accept the user to Brand
    int role = 0;
    if (request.isTrainer!) {
      role = 5;
    }
    // New Database
    this.addUserToBrand(request.userId!, request.brandId!, role);
    // Delete the Request
    this.deleteRequestToBrand(request);
    // OLD CHAT
    QuerySnapshot querySnapshot = await _firestore
        .collection(conversations)
        .where("brandId", isEqualTo: request.brandId)
        .get();
    Conversation conversation  = Conversation.fromObject(querySnapshot.docs[0], querySnapshot.docs[0].id);
    DocumentSnapshot<Map<String, dynamic>> _docu =
    await _firestore.collection(users).doc(request.userId).get();
    Usuario user = Usuario.fromObjectAllData(_docu.id, _docu);
    conversation.users.add({
      'uid': user.id,
    });
    await _firestore.collection(conversations).doc(conversation.conversationId).update({
      "users": conversation.users,
    });
  }

  // Has Pending Request To Brand
  Future<RequestToBrand?> hasPendingRequestToBrand(String userId) async {
    RequestToBrand request;
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Requests")
        .get();
    if (querySnapshot.docs.length > 0) {
      request = RequestToBrand.fromObjectAllData(querySnapshot.docs[0].id, querySnapshot.docs[0]);
      return request;
    } else {
      return null;
    }
  }

  // Notifications

  // Get All Notifications
  Future<List<NotificationEvent>> getAllNotificationsUser(String userId) async {
    List<NotificationEvent> notis = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      notis.add(NotificationEvent.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return notis;
  }

  // Send Notification
  Future<void> sendNotificationToUser(String userId, String type, var parameters) async {
    var uid = Uuid().v1();
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yy');
    final String formatted = formatter.format(now);
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
    });
  }

  // Number Unread Notifications
  Future<int> getUnreadNotifications(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .where("isRead", isEqualTo: false)
        .get();
    return querySnapshot.docs.length;
  }

  // Mark as Read Notifications
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    await _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .doc(notificationId)
        .update({
          "isRead": true,
        });
  }

  // Mark ALL as Read Notifications
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

  //Questions

  //Get One Question
  Future<Question> getOneQuestion(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection(questions).doc(id).get();
    return Question.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  // Add Question
  Future<String> addQuestion(
      String? questionCat, String? questionSpn, String? type) async {
    var questionID = Uuid().v1();
    User? currentUser = await getCurrentUser();
    bool firestoreError = false;
    var uid = Uuid().v1();
    try {
      await _firestore.collection(questions).doc(questionID).set({
        "creatorID": currentUser!.uid,
        "questionCat": questionCat,
        "questionSpn": questionSpn,
        "type": type,
      });
      return questionID;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  //Get all questions of a type
  Future<List<Question>> getAllQuestionsByType(String type) async {
    List<Question> questionsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(questions)
        .where("type", isEqualTo: type)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      questionsList.add(
          Question.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return questionsList;
  }

  //Group Of Questions

  // Add Group Of Questions
  Future<String> addGroupOfQuestions(String? questionOne, String? questionTwo,
      String? questionThree, String? questionFour) async {
    var groupOfQuestionsID = Uuid().v1();
    User? currentUser = await getCurrentUser();
    bool firestoreError = false;
    var uid = Uuid().v1();
    try {
      await _firestore
          .collection(groupOfQuestions)
          .doc(groupOfQuestionsID)
          .set({
        "creatorID": currentUser!.uid,
        "questionOne": questionOne,
        "questionTwo": questionTwo,
        "questionThree": questionThree,
        "questionFour": questionFour,
        "isActive": false,
      });
      return groupOfQuestionsID;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  //Get Active Group Of GroupOfQuestions
  Future<GroupOfQuestions?> getActiveGroupOfQuestions() async {
    List<GroupOfQuestions> groupOfQuestionsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(groupOfQuestions)
        .where("isActive", isEqualTo: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      groupOfQuestionsList.add(GroupOfQuestions.fromObject(
          querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    if (querySnapshot.docs.length == 0) {
      return null;
    }
    return groupOfQuestionsList[0];
  }

  //Answers

  // Add Answers
  Future<String> addAnswers(String? groupOfQuestionsID, String? answerOne,
      String? answerTwo, String? answerThree, String? answerFour) async {
    var answerID = Uuid().v1();
    User? currentUser = await getCurrentUser();
    bool firestoreError = false;
    var uid = Uuid().v1();
    try {
      await _firestore.collection(answers).doc(answerID).set({
        "userID": currentUser!.uid,
        "groupOfQuestionsID": groupOfQuestionsID,
        "answerOne": answerOne,
        "answerTwo": answerTwo,
        "answerThree": answerThree,
        "answerFour": answerFour,
      });
      return answerID;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  //Check if answers for user exists
  Future<bool> checkIfAnswersExist(String? groupOfQuestionsId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(answers)
        .where("userID", isEqualTo: currentUser.id.toString())
        .where("groupOfQuestionsID", isEqualTo: groupOfQuestionsId.toString())
        .get();
    if (querySnapshot.docs.length == 0) {
      return false;
    } else
      return true;
  }

  //Conversations

  // Delete Conversation
  Future<void> deleteConversation(String id) async {
    try {
      await _firestore.collection(conversations).doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  // Number Unread Conversations
  Future<int> getUnreadConversations(String userId) async {
    List<Conversation> conv = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(conversations)
        .where("messagesRead", arrayContains: toMapisMessageRead(userId, true))
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      conv.add(Conversation.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return conv.length;
  }

  Future<String> addConversation(
      var users,
      var messagesRead,
      String? brandId,
      String? year,
      String? month,
      String? day,
      String? hour,
      String? minute,
      String? second,
      String? lastMessage) async {
    print(users);
    var uid = Uuid().v1();
    try {
      await _firestore.collection(conversations).doc(uid).set({
        "users": users,
        "messagesRead": messagesRead,
        "brandId": brandId,
        "year": year,
        "month": month,
        "day": day,
        "hour": hour,
        "minute": minute,
        "second": second,
        "lastMessage": lastMessage,
      });
      return uid;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  //Messages

  Future<String> addMessage(
      String? message,
      String? userSent,
      String? year,
      String? month,
      String? day,
      String? hour,
      String? minute,
      String? second,
      String? conversationId) async {
    var uid = Uuid().v1();
    try {
      await _firestore.collection(messages).doc(uid).set({
        "message": message,
        "userSent": userSent,
        "year": year,
        "month": month,
        "day": day,
        "hour": hour,
        "minute": minute,
        "second": second,
        "conversationId": conversationId,
      });
      return uid;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  Future<List<Message>> getConversationMessagesInit(String? conversationId) async {
    List<Message> messagesList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(messages)
        .where("conversationId", isEqualTo: conversationId)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .orderBy("hour", descending: true)
        .orderBy("minute", descending: true)
        .orderBy("second", descending: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      messagesList.add(Message.fromObject(
          querySnapshot.docs[i], querySnapshot.docs[i].id));
    }

    return messagesList;
  }

  Future<String?> getLastUserMessageSent(String? conversationId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(messages)
        .where("conversationId", isEqualTo: conversationId)
        .orderBy("year", descending: false)
        .orderBy("month", descending: false)
        .orderBy("day", descending: false)
        .orderBy("hour", descending: false)
        .orderBy("minute", descending: false)
        .orderBy("second", descending: false)
        .get();

    if(querySnapshot.docs.length == 0) return '';
    else return Message.fromObject(
        querySnapshot.docs[querySnapshot.docs.length-1], querySnapshot.docs[querySnapshot.docs.length-1].id).userSent;
  }


  Future<List<Conversation>> getConversationByUsers(
      Map<String, dynamic> currentUser, Map<String, dynamic> user) async {
    List<Conversation> conversationsList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(conversations)
        .where("users", arrayContains: currentUser)
        .get();
    QuerySnapshot querySnapshot2 = await _firestore
        .collection(conversations)
        .where("users", arrayContains: user)
        .get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      for (int j = 0; j < querySnapshot2.docs.length; j++) {
        if (querySnapshot.docs[i].id == querySnapshot2.docs[j].id) {
          conversationsList.add(Conversation.fromObject(
              querySnapshot.docs[i], querySnapshot.docs[i].id));
         // i = querySnapshot.docs.length;
          //j = querySnapshot2.docs.length;
        }
      }
    }
    return conversationsList;
  }

  Future<Conversation> getConversationByBrand(String? brandId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(conversations)
        .where("brandId", isEqualTo: brandId)
        .get();

    return Conversation.fromObject(
        querySnapshot.docs[0], querySnapshot.docs[0].id);

  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  // Brands
  Stream<QuerySnapshot> getAllBrandsStream() {
    return _firestore.collection(brands).snapshots();
  }

  // Events
  Stream<DocumentSnapshot> getSingleEventStream(String eid) {
    return _firestore.collection(events).doc(eid).snapshots();
  }

  Stream<QuerySnapshot> getAllEventsFromBrand(String brandid) {
    return _firestore
        .collection(events)
        .where("brandID", isEqualTo: brandid)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllEventsTodayBrandStream(String brandId) {
    DateTime today = DateTime.now();
    return _firestore
        .collection(events)
        .where("year", isEqualTo: today.year.toString())
        .where("month", isEqualTo: today.month.toString())
        .where("day", isEqualTo: today.day.toString())
        .where("brandID", isEqualTo: brandId)
        .orderBy("hour", descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllEventsFromUser(String userid, bool isTrainer) {
    if (isTrainer) {
      return _firestore
          .collection(events)
          .where("selectedTrainers", arrayContains: userid)
          .orderBy("year", descending: true)
          .orderBy("month", descending: true)
          .orderBy("day", descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection(events)
          .where("joinedMembers", arrayContains: userid)
          .orderBy("year", descending: false)
          .orderBy("month", descending: false)
          .orderBy("day", descending: false)
          .snapshots();
    }
  }

  // Locations
  Stream<QuerySnapshot> getAllLocationsBrand(String brandId) {
    return _firestore
        .collection(locations)
        .where("brandID", isEqualTo: brandId)
        .snapshots();
  }

  // Requests
  Stream<QuerySnapshot> getBrandRequests(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Requests")
        .snapshots();
  }

  // Notifications
  Stream<QuerySnapshot> getAllNotificationsUserStream(String userId) {
    return _firestore
        .collection(users)
        .doc(userId)
        .collection("Notifications")
        .snapshots();
  }

  //Question
  Stream<QuerySnapshot> getAllQuestions() {
    return _firestore.collection(questions).snapshots();
  }

  //Conversations
  Stream<QuerySnapshot> getUserConversations(Map<String, dynamic> mapUser) {
    return _firestore
        .collection(conversations)
        .where("users", arrayContains: mapUser)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .orderBy("hour", descending: true)
        .orderBy("minute", descending: true)
        .snapshots();
    /**/
  }

  //Messages
  Future<void> deleteMessage(String id) async {
    try {
      await _firestore.collection(messages).doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<QuerySnapshot> getConversationMessages(String? conversationId) {
    print(conversationId);
    return _firestore
        .collection(messages)
        .where("conversationId", isEqualTo: conversationId)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .orderBy("hour", descending: true)
        .orderBy("minute", descending: true)
        .orderBy("second", descending: true)
        .snapshots();

   /* .orderBy("year", descending: false)
        .orderBy("month", descending: false)
        .orderBy("day", descending: false)
        .orderBy("hour", descending: false)
        .orderBy("minute", descending: false)
        .orderBy("second", descending: false)*/
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<Stream<QuerySnapshot>> getAllUsers() async {
    return _firestore.collection(users).snapshots();
  }
}
