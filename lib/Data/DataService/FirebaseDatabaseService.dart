import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/ChatUsers.dart';
import 'package:mamba_castelldefels/Data/Models/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Message.dart';
import 'package:mamba_castelldefels/Data/Models/Question.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:uuid/uuid.dart';

// Firebase Service Class. All calls to Firebase are in this class.
class FirebaseDatabaseService {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

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
  String notifications = isProduction ? 'Notifications' : '7777 Notifications';
  String rooms = isProduction ? 'Rooms' : '7777 Rooms';


  Map<String, dynamic> toMapisMessageRead(String? id, bool? isMessageRead) {
    return {
      'uid': id,
      'isMessageRead': isMessageRead,
    };
  }

  // Authentication Services
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

  Future<Brand?> checkUserIsBrandCreator(String userId) async {
    Brand brand = Brand();
    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .where("adminID", isEqualTo: userId)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brand = Brand.fromObjectAllData(
          querySnapshot.docs[i].id, querySnapshot.docs[i]);
    }
    if (brand.id == null)
      return null;
    else
      return brand;
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

  Future<bool> checkIfMinimumAppVersion(String clientAppVersion) async {
    // Get Minimum Version from Settings Collection
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection("Settings").doc("MinimumAppVersion").get();
    String minimumAppVersion = _documentSnapshot.get("version");
    print(minimumAppVersion);
    print(clientAppVersion);
    if (clientAppVersion == minimumAppVersion) {
      return true;
    } else {
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = await _auth.currentUser;
    return currentUser;
  }

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

  // Register User
  Future<void> deleteUserNickname(String nickname) async {
    await _firestore.collection(nicknames).doc(nickname).delete();
  }

  // Check If Alias Exists
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

  // Add User
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

  // Add User
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

  // Add User Notification Token
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

  // Add Error/ Report Bug
  Future<bool> addError(String title, String description,
      [String? stepsReproduce]) async {
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

  Future<void> deleteUserPhoto(String userId) async {
    await _firebaseStorage.ref().child("userPics/" + userId + ".png").delete();
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

  Future<void> addUserToBrand(String userId, String brandId, int role) async {
    Usuario user = await this.getUserDetails(userId);
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .set({
          "name": user.name,
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



  Future<String> updateBrandPhoto(String brandID, File image) async {
    var result;
    var storageRef = _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + brandID + ".jpeg");
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

  Future<void> deleteUserFromBrand(String userId, String brandId) async {
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .delete();
  }

  Future<void> deleteBrandContentPictures(String brandID, String imageId) async {
    // Delete Image From Storage
    _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + imageId + ".jpeg").delete();
    // Delete Image From Firebase Firestore
    await _firestore
        .collection(brands)
        .doc(brandID)
        .collection("Images")
        .doc(imageId)
        .delete();
  }

  Future<void> deleteBrandUsers(String brandId) async {
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .get().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.docs) {
        NotificationService().userLeavesBrand(doc.id, brandId);
        await doc.reference.delete();
      }
    });
  }

  Future<void> deleteBrandEvents(String brandId) async {
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Events")
        .get()
        .then((snapshot) async {
          for (DocumentSnapshot doc in snapshot.docs) {
            await _firestore
            .collection(events)
            .doc(doc.id)
            .delete();
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

  Future<void> updateConversation(String? uid, var messagesRead,
      String lastMessage, String year,
      String month, String day, String hour, String minute,
      String second) async {
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

  Future<void> updateConversationNewUser(String? brandId,
      String? userId) async {
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

  Future<void> deleteUserMemberConversations(
      Map<String, dynamic> currentUser) async {
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

      if (Conversation
          .fromObject(conv, conv.id)
          .brandId == 'null') {
        for (var mess in querySnapshotMessages.docs) {
          await this.deleteMessage(mess.id);
        }
        await this.deleteConversation(conv.id);
      }
      else {
        print(currentUser["uid"]);
        for (var mess in querySnapshotMessages.docs) {
          print(Message
              .fromObject(
              mess, mess.id)
              .userSent);
          if (currentUser["uid"] == Message
              .fromObject(
              mess, mess.id)
              .userSent) await this.deleteMessage(mess.id);
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
  Future<String> addBrand(String name, File image, String description,
      List<double> workShift, int maxMembers) async {
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
      "baseLocation": null,
      "numClients": 0,
      "numTrainers": 1,
      "workShift": workShift,
      "maxMembers": maxMembers,
    }).catchError((err) {
      print(err);
      firestoreError = true;
    });

    if (!firestoreError) {
      await updateBrandPhoto(uid, image);
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
    // Delete All Users from Brand
    await this.deleteBrandUsers(brandId);
    // Delete Brand Photo
    await this.deleteBrandPhoto(brandId);
    // Delete Brand
    await _firestore.collection(brands).doc(brandId).delete();
  }

  Future<void> addBrandContentPictures(String brandID, List<File> images) async {
    // Add each brand to the .../BrandId/images directory
    for (var i=0; i<images.length; i++) {
      var image = images[i];
      final uid = Uuid().v4();
      // Upload the image to Firebase Storage
      var storageRef = _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + uid + ".jpeg");
      var uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() async {
        await storageRef.getDownloadURL().then((value) async {
          // Add Image to the Brand Images Subcollection
          await _firestore.collection(brands).doc(brandID)
            .collection("Images")
            .doc(uid)
            .set({
              "url": value,
              "timestamp": Timestamp.now(),
            });
        });
      });
    }
  }

  Future<void> deleteBrandContentPicture(String brandID) async {
    await _firebaseStorage.ref()
        .child("brandPics/" + brandID + ".png")
        .delete();
  }

  Future<void> deleteBrandPhoto(String brandID) async {
    await _firebaseStorage.ref()
        .child("brandPics/" + brandID + ".png")
        .delete();
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

  Future<void> updateBrandRoom(String brandID, String roomId) async {
    await _firestore.collection(brands).doc(brandID).update({
      "roomId": roomId,
    });
  }

  Future<void> updateBrandBaseLocation(String brandID, String locationID) async {
    await _firestore
    .collection(brands)
    .doc(brandID)
    .update({
      "baseLocation": locationID
    });
  }

    Future<List<Brand>> getAllBrands() async {
      List<Brand> brandList = [];
      QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        brandList.add(
            Brand.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
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
        brandList.add(Brand.fromObjectOnlyCoverData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return brandList;
    }

    Future<List<ImageObject>> getBrandContentPictures(String brandID) async {
      // Get the Image documents of the Brand
      List<ImageObject> contentImages = [];
      QuerySnapshot querySnapshot = await _firestore.collection(brands).doc(brandID).collection("Images").get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        contentImages.add(ImageObject.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return contentImages;
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

    Future<List<Event>> getUserEvents(String userId) async {
      List<Event> events = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(users)
          .doc(userId)
          .collection("Events")
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        events.add(Event.fromObjectOnlyCoverData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return events;
    }

    // Get All Events Finished Brand
    Future<List<Event>> getUserEventsUpcoming(String userId) async {
      DateTime today = DateTime.now();
      List<Event> eventsList = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(users)
          .doc(userId)
          .collection("Events")
          .get();

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]);
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
      return eventsList;
    }

    Future<List<Usuario>> getEventUsers(String eventId) async {
      List<Usuario> users = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(events)
          .doc(eventId)
          .collection("Users")
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        users.add(Usuario.fromObjectOnlyCoverData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return users;
    }

    Future<Location> getEventLocation(String eventId) async {
      QuerySnapshot querySnapshot = await _firestore
          .collection(events)
          .doc(eventId)
          .collection("Locations")
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        return Location.fromObjectOnlyCoverData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
      }
      return Location();
    }

    Future<List<Event>> getUserEventsToday(String userId) async {
      DateTime today = DateTime.now();
      List<Event> events = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(users)
          .doc(userId)
          .collection("Events")
          .where("year", isEqualTo: today.year.toString())
          .where("month", isEqualTo: today.month.toString())
          .where("day", isEqualTo: today.day.toString())
          .orderBy("hour", descending: false)
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        events.add(Event.fromObjectOnlyCoverData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return events;
    }

    Future<List<int>> getUserEventsFinished(String userId) async {
      List<Event> eventsList = [];
      List<Event> eventsMonth = [];
      DateTime today = DateTime.now();
      QuerySnapshot querySnapshot = await _firestore
          .collection(users)
          .doc(userId)
          .collection("Events")
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]);
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        if (today.isAfter(startDate)) {
          eventsList.add(event);
          if (today.year == int.parse(event.year!) &&
              today.month == int.parse(event.month!)) {
            eventsMonth.add(event);
          }
        }
      }
      List<int> result = [eventsList.length, eventsMonth.length];
      return result;
    }


    Future<Brand> getBrandDetails(String brandID) async {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
      await _firestore.collection(brands).doc(brandID).get();
      return Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    }

    Future<Brand> getBrandCoverDetails(String brandID) async {
      try {
        DocumentSnapshot<
            Map<String, dynamic>> _documentSnapshot = await _firestore
            .collection(brands).doc(brandID).get();
        return Brand.fromObjectOnlyCoverData(
            _documentSnapshot.id, _documentSnapshot);
      } catch (e) {
        print(e.toString());
        return Brand();
      }
    }

    Future<String> getBrandLogoUrl(String brandID) async {
      try {
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandID).get();
        return _documentSnapshot.get("logoUrl");
      } catch (e) {
        print(e.toString());
        return "";
      }
    }

    Future<List<Usuario>> getBrandUsers(String brandId) async {
      List<Usuario> users = [];
      try {
        await _firestore.collection(brands).doc(brandId)
            .collection("Users")
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            users.add(Usuario.fromObjectOnlyCoverData(doc.id, doc));
          }
        });
        return users;
      } catch (e) {
        print(e.toString());
        return users;
      }
    }

    Future<List<Usuario>> getBrandTrainers(String brandId) async {
      List<Usuario> users = [];
      try {
        await _firestore.collection(brands).doc(brandId)
            .collection("Users")
            .get()
            .then((snapshot) {
              for (DocumentSnapshot doc in snapshot.docs) {
                if (doc.get("isTrainer") == true) {
                  users.add(Usuario.fromObjectOnlyCoverData(doc.id, doc));
                }
              }
            });
        return users;
      } catch (e) {
        print(e.toString());
        return users;
      }
    }

    Future<List<Usuario>> getBrandClients(String brandId) async {
      List<Usuario> users = [];
      try {
        await _firestore.collection(brands).doc(brandId)
            .collection("Users")
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            if (doc.get("isTrainer") == false) {
              users.add(Usuario.fromObjectOnlyCoverData(doc.id, doc));
            }
          }
        });
        return users;
      } catch (e) {
        print(e.toString());
        return users;
      }
    }

    Future<List<String>> getBrandCover(String brandID) async {
      try {
        DocumentSnapshot<
            Map<String, dynamic>> _documentSnapshot = await _firestore
            .collection(brands).doc(brandID).get();
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
            Usuario.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
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
            Usuario.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
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
    Future<String> addEvent(String? brandID, String? title, String? description,
        String? year, String? month, String? day, String? hour, String? minute,
        double? duration, String? locationId, int? maxMembers,
        var selectedTrainers) async {
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
          "numClients": 0,
          "numTrainers": selectedTrainers.length,
          "maxMembers": maxMembers,
          "joinedMembers": [],
          "selectedTrainers": selectedTrainers,
        });
        await _firestore.collection(events).doc(eventID)
            .collection("Brands")
            .doc(currentBrand.id)
            .set({
          "name": currentBrand.name,
          "logoUrl": currentBrand.logoUrl,
        });
        Location location = await this.getSingleLocation(locationId!);
        await _firestore.collection(events).doc(eventID)
            .collection("Locations")
            .doc(locationId)
            .set({
          "description": location.description,
          "longitude": location.longitude,
          "latitude": location.latitude,
        });
        for (var i = 0; i < selectedTrainers.length; i++) {
          Usuario user = await this.getUserDetails(selectedTrainers[i]);
          await _firestore.collection(events).doc(eventID)
              .collection("Users")
              .doc(user.id)
              .set({
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
        return Event.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
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
            Event.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
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
            Event.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
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
            Event.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return eventsList;
    } // Get All Events for Client

    // Get All Events for Client
    Future<List<Event>> getAllClientEventsFromBrand(String clientid,
        String brandId) async {
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
            Event.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return eventsList;
    }

    // Get All Finished Events for Client
    Future<List<int>> getAllClientEventsFinished(String clientid,
        String brandId) async {
      DateTime today = DateTime.now();
      List<Event> eventsList = [];
      List<Event> eventsMonth = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(events)
          .where("brandID", isEqualTo: brandId)
          .where("joinedMembers", arrayContains: clientid)
          .get();

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]);
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        if (today.isAfter(startDate)) {
          eventsList.add(event);
          if (today.year == int.parse(event.year!) &&
              today.month == int.parse(event.month!)) {
            eventsMonth.add(event);
          }
        }
      }
      List<int> result = [eventsList.length, eventsMonth.length];
      return result;
    }

    // Get All Events for Trainer
    Future<List<Event>> getAllTrainerEventsFromBrand(String trainerid,
        String brandId) async {
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
            Event.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return eventsList;
    }

    // Get All Finished Events for Trainer
    Future<List<int>> getAllTrainerEventsFinished(String trainerid,
        String brandId) async {
      DateTime today = DateTime.now();
      List<Event> eventsList = [];
      List<Event> eventsMonth = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(events)
          .where("brandID", isEqualTo: brandId)
          .where("selectedTrainers", arrayContains: trainerid)
          .get();

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]);
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        if (today.isAfter(startDate)) {
          eventsList.add(event);
          if (today.year == int.parse(event.year!) &&
              today.month == int.parse(event.month!)) {
            eventsMonth.add(event);
          }
        }
      }
      List<int> result = [eventsList.length, eventsMonth.length];
      return result;
    }

    // Get All Events Finished Brand
    Future<int> getBrandsEventsFinished(String brandId) async {
      DateTime today = DateTime.now();
      List<Event> eventsList = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Events")
          .get();

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]);
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
    Future<int> getBrandsEventsUpcoming(String brandId) async {
      DateTime today = DateTime.now();
      List<Event> eventsList = [];
      QuerySnapshot querySnapshot = await _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Events")
          .get();

      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]);
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
            Event.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return eventsList;
    }

    // Get All Events for User Today
    Future<List<Event>> getAllEventsTodayUser(String userid,
        bool isTrainer) async {
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
            Event.fromObjectAllData(
                querySnapshot.docs[i].id, querySnapshot.docs[i]));
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

    // Delete User from All Existing Events
    Future<void> deleteUserFromAllBrandEvents(String uid, String brandId,
        bool isTrainer) async {
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
      Event.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
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
      Event.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
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

    // User Joins Event
    Future<bool> addUserToEvent(String eid, String uid, [bool invitedDirectly = false]) async {
      try {
        Usuario user = await this.getUserDetails(uid);
        if (invitedDirectly) {
          await _firestore
          .collection(events)
          .doc(eid)
          .collection("Users")
          .doc(uid)
          .set({
            "name": user.name,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "nick": user.nick,
            "imageUrl": user.imageUrl,
            "noImageUrl": user.noImageUrl,
            "isTrainer": user.isTrainer,
            "isPrivate": user.isPrivate,
            "invitedDirectly": invitedDirectly,
            "notificationToken": user.notificationToken,
          }).catchError((err) {
            print(err);
          });
        } else {
          await _firestore
          .collection(events)
          .doc(eid)
          .collection("Users")
          .doc(uid)
          .set({
            "name": user.name,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "nick": user.nick,
            "imageUrl": user.imageUrl,
            "noImageUrl": user.noImageUrl,
            "isTrainer": user.isTrainer,
            "isPrivate": user.isPrivate,
            "notificationToken": user.notificationToken,
          }).catchError((err) {
            print(err);
          });
        }
        return true;
      } catch (e) {
        print(e.toString());
        return false;
      }
    }

    // User Joins Event
    Future<bool> deleteUserFromEvent(String eid, String uid,) async {
      try {
        await _firestore
            .collection(events)
            .doc(eid)
            .collection("Users")
            .doc(uid)
            .delete()
            .catchError((err) {
          print(err);
        });
        return true;
      } catch (e) {
        print(e.toString());
        return false;
      }
    }

    // User Joins Event
    Future<bool> deleteUserFromUpcomingEvents(String uid, bool isTrainer) async {
      try {
        List<Event> upcomingEvents = await this.getUserEventsUpcoming(uid);
        if (isTrainer) {
          for (int i = 0; i < upcomingEvents.length; i++) {
            Event evt = upcomingEvents[i];
            if (evt.numTrainers! > 1) {
              await _firestore
                  .collection(events)
                  .doc(evt.id)
                  .collection("Users")
                  .doc(uid)
                  .delete()
                  .catchError((err) {
                print(err);
              });
            } else {
              this.deleteEvent(evt.id!);
            }
          }
        } else {
          for (int i = 0; i < upcomingEvents.length; i++) {
            Event evt = upcomingEvents[i];
            await _firestore
                .collection(events)
                .doc(evt.id)
                .collection("Users")
                .doc(uid)
                .delete()
                .catchError((err) {
              print(err);
            });
          }
        }
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
    Future<void> updateEvent(String? id,
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
    Future<void> updateEventLocation(String eventId, String locationId, String previousLocation) async {
      try {
        // Delete Previous Location
        await _firestore
            .collection(events)
            .doc(eventId)
            .collection("Locations")
            .doc(previousLocation)
            .delete();
        // Add New Location
        Location location = await this.getSingleLocation(locationId);
        await _firestore
            .collection(events)
            .doc(eventId)
            .collection("Locations")
            .doc(locationId)
            .set({
              "description": location.description,
              "longitude": location.longitude,
              "latitude": location.latitude,
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
    Future<String> addLocation(String brandId,
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
        await _firestore
          .collection(locations).doc(uid).set({
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
    Future<void> updateLocation(String locationID,
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
      try {
        await _firestore
          .collection(locations).doc(locationID).update({
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
        // If Base Location == null it means brand is getting deleted.
        if (baseLocation != null) {
          DateTime now = DateTime.now();
          List<Event> futureEventsList = [];
          // Filter out only the ones that are upcoming
          QuerySnapshot querySnapshot =  await _firestore.collection(locations).doc(locationId).collection("Events").get();
          for (int i = 0; i < querySnapshot.docs.length; i++) {
            Event event = Event.fromObjectOnlyCoverData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
            var startDate = DateTime(
              int.parse(event.year!),
              int.parse(event.month!),
              int.parse(event.day!),
              int.parse(event.hour!),
              int.parse(event.minute!),
            );
            if (startDate.isAfter(now)) {
              futureEventsList.add(event);
            }
          }
          // Update Event Location With Base Location
          for (int i = 0; i < futureEventsList.length; i++) {
            Event event = futureEventsList[i];
            // Update Location Field in the main Doc
            await _firestore
                .collection(events)
                .doc(event.id)
                .update({
              "locationId": baseLocation,
            });
            await this.updateEventLocation(event.id!, baseLocation, locationId);
          }
        }
        // Delete Location
        await _firestore.collection(locations).doc(locationId).delete();
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
              .collection(brands)
              .doc(brandId)
              .collection("Locations")
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
      return Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    }

    //Bonos

  //Get bonos from brand
  Stream<QuerySnapshot>  getAllBonosFromBrand(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .snapshots();
  }

  //Get bono request by user
  Future<String> getBonoRequest(String userId, String brandId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Brands")
        .doc(brandId)
        .collection("Bonos Requests")
        .get();
     return querySnapshot.docs[0].get("bonoId").toString();

  }

  //Add bono to brand
  Future<void> addBonoToBrand(String brandId, String title, String description, String price, String classes, bool isactive) async {
    var uid = Uuid().v4();
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc(uid)
        .set({
      "title": title,
      "description": description,
      "price": double.parse(price),
      "classes": int.parse(classes),
      "isActive": isactive,
    }).catchError((err) {
      print(err);
    });
  }

  //Add bono request to brand
  Future<void> addBonoRequestToBrand(String brandId, String userId, String bonoId, String title, String price, String classes) async {
    var uid = Uuid().v4();
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos Requests")
        .doc(uid)
        .set({
      "userId": userId,
      "title": title,
      "price": price,
      "classes": classes,
      "bonoId": bonoId,
    }).catchError((err) {
      print(err);
    });
  }

  //Add bono to user
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

  //UpdateBono
  Future<void> updateBono(String brandID, String bonoId, bool isActive) async {
    await _firestore.collection(brands).doc(brandID).collection("Bonos").doc(bonoId).update({
      "isActive": isActive,
    });
  }

  // Delete Brand Bono Request
  Future<void> deleteBrandBonoRequest(String brandId, String bonoId) async {
    QuerySnapshot querySnapshot = await _firestore.collection(brands).doc(brandId).collection(
        "Bonos Requests").where("bonoId", isEqualTo: bonoId).get();
    await _firestore.collection(brands).doc(brandId).collection(
        "Bonos Requests").doc(querySnapshot.docs[0].id).delete();
  }

  // Delete User Bono Request
  Future<void> deleteUserBonoRequest(String userId, String brandId, String bonoId) async {
    QuerySnapshot querySnapshot = await _firestore.collection(users).doc(userId).collection("Brands").doc(brandId).collection(
        "Bonos Requests").where("bonoId", isEqualTo: bonoId).get();
    await _firestore.collection(users).doc(userId).collection("Brands").doc(brandId).collection(
        "Bonos Requests").doc(querySnapshot.docs[0].id).delete();
  }


    // Requests

    // Send Request
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
      // Accept the user to Brand
      int role = 0;
      if (request.isTrainer!) {
        role = 5;
      }
      // New Database
      this.addUserToBrand(request.userId!, request.brandId!, role);
      // Delete the Request
      this.deleteRequestToBrand(request);
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
        request = RequestToBrand.fromObjectAllData(
            querySnapshot.docs[0].id, querySnapshot.docs[0]);
        return request;
      } else {
        return null;
      }
    }

    // Notifications

    // Get First Notifications
    Future <List<NotificationEvent>> getUserFirstNotificationsLimit10(String userId) async {
      List<NotificationEvent> notis = [];
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
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        notis.add(NotificationEvent.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return notis;
    }

    // Get More Notifications
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
          .orderBy("year", descending: true)
          .orderBy("month", descending: true)
          .orderBy("day", descending: true)
          .orderBy("hour", descending: true)
          .orderBy("minutes", descending: true)
          .orderBy("seconds", descending: true)
          .startAfterDocument(docu)
          .limit(10)
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        notis.add(NotificationEvent.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
      return notis;
    }

    // Send Notification
    Future<void> sendNotificationToUser(String userId, String type,
        var parameters) async {
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
    Future<String> addQuestion(String? questionCat, String? questionSpn,
        String? type) async {
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
            Question.fromObject(
                querySnapshot.docs[i], querySnapshot.docs[i].id));
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
          .where(
          "messagesRead", arrayContains: toMapisMessageRead(userId, true))
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        conv.add(Conversation.fromObject(
            querySnapshot.docs[i], querySnapshot.docs[i].id));
      }
      return conv.length;
    }

    Future<String> addConversation(var users,
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

    Future<void> updateRoom(String? roomId,
        Map<String, dynamic> metadata) async {
      await _firestore.collection(rooms).doc(roomId).update({
        "metadata": metadata
      });
    }

    Future<void> updateRoomLastMessage(String? roomId, var lastMessages) async {
    print(lastMessages.toString());
      await _firestore.collection(rooms).doc(roomId).update({
        "lastMessages": [lastMessages],
      });
    }

    Future<void> deleteRoom(String roomId) async {
      // Delete Messages
      await _firestore
          .collection(rooms)
          .doc(roomId)
          .collection("messages")
          .get().then((snapshot) {
            for (DocumentSnapshot ds in snapshot.docs) {
              batch.delete(ds.reference);
            }
          });
      // Delete Room
      await _firestore.collection(rooms).doc(roomId).delete();
    }

    //Messages

    Future<String> addMessage(String? message,
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

    Future<List<Message>> getConversationMessagesInit(
        String? conversationId) async {
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

      if (querySnapshot.docs.length == 0)
        return '';
      else
        return Message
            .fromObject(
            querySnapshot.docs[querySnapshot.docs.length - 1],
            querySnapshot.docs[querySnapshot.docs.length - 1].id)
            .userSent;
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

    Stream<QuerySnapshot> getAllEventsFromBrand(String brandId) {
      return _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Events")
          .snapshots();
    }

    Stream<QuerySnapshot> getBrandsEventsTodayStream(String brandId) {
      DateTime today = DateTime.now();
      return _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Events")
          .where("year", isEqualTo: today.year.toString())
          .where("month", isEqualTo: today.month.toString())
          .where("day", isEqualTo: today.day.toString())
          .orderBy("hour", descending: false)
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

    Stream<QuerySnapshot> getUserEventsStream(String userid) {
      return _firestore
          .collection(users)
          .doc(userid)
          .collection("Events")
          .orderBy("year", descending: true)
          .orderBy("month", descending: true)
          .orderBy("day", descending: true)
          .snapshots();
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
