import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/ChatUsers.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/Question.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:uuid/uuid.dart';

// Firebase Service Class. All calls to Firebase are in this class.
class FirebaseDatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

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
    //if (authResult.user != null) {
    //if (authResult.user!.emailVerified) return 0;
    //else return -2;
    //}
    else
      return 0;
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
      await _firestore.collection("Users").doc(user.uid).delete();
      await user.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
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

  Future<Usuario> getCurrentUserDetails() async {
    User? currentUser = await getCurrentUser();
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection("Users").doc(currentUser!.uid).get();
    return Usuario.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  Future<Usuario> getUserDetails(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection("Users").doc(uid).get();
    return Usuario.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  // User Model Services
  // Register User
  Future<int> registerUser(String email, String password, String idioma) async {
    bool authError = false;
    bool firestoreError = false;
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    UserCredential? authResult = await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) async {
      if (userCredential != null && userCredential.user != null) {
        await _firestore.collection("Users").doc(userCredential.user!.uid).set({
          "name": null,
          "nick": null,
          "email": email,
          "imageUrl": null,
          "noImageUrl":
              "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53",
          "isFirst": true,
          "isTrainer": null,
          "isPrivate": true,
          "gender": null,
          "dateJoined": formatted,
          "dateOfBirth": null,
          "idioma": idioma,
          "previousIdioma": null,
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

  // Check If Alias Exists
  Future<bool> checkIfAliasExists(String nickname) async {
    bool result = true;
    QuerySnapshot querySnapshot = await _firestore.collection("Users").get();
    for (var doc in querySnapshot.docs) {
      if (doc.get('nick') == nickname) {
        result = false;
        break;
      }
    }
    return result;
  }

  // Add User
  Future<void> addUser(String uid, String name, String nick, String dateOfBirth,
      int gender, File? image, bool isTrainer) async {
    String imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53";
    if (image != null) {
      imageUrl = await updateCurrentUserPhoto(image);
    }
    await _firestore.collection("Users").doc(uid).update({
      "name": name,
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

  // Add Error/ Report Bug
  Future<bool> addError(String title, String description,
      [String? stepsReproduce]) async {
    var uid = Uuid().v1();
    User? currentUser = await getCurrentUser();
    try {
      await _firestore.collection("Errors").doc(uid).set({
        "userID": currentUser!.uid,
        "title": title,
        "descripcion": description,
        "stepsReproduce": stepsReproduce
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
    await _firestore.collection("Users").doc(currentUser!.uid).update({
      "isFirst": false,
    });
  }

  Future<int> updateCurrentUserBrand(String brandID) async {
    User? currentUser = await getCurrentUser();
    bool firestoreError = false;
    await _firestore.collection("Users").doc(currentUser!.uid).update({
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
        await _firestore.collection("Users").doc(firebaseUser.uid).update({
          "imageUrl": value,
        });
      });
    });
    return imageURL;
  }

  Future<void> updateCurrentUserDatosPerifl(
      String name, int gender, String? dateOfBirth) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection("Users").doc(currentUser!.uid).update({
      "name": name,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
    });
  }

  Future<void> updateCurrentUserSettingsPerifl(
      bool isPrivate, String idioma, String previousIdioma) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection("Users").doc(currentUser!.uid).update({
      "isPrivate": isPrivate,
      "idioma": idioma,
      "previousIdioma": previousIdioma,
    });
  }

  Future<void> leaveBrand(String uid) async {
    await _firestore.collection("Users").doc(uid).update({
      "brandID": null,
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> updateConversation(String? uid, String lastMessage, String year,
      String month, String day, String hour, String minute, String second) async {
    await _firestore.collection("Conversations").doc(uid).update({
      "lastMessage": lastMessage,
      "year": year,
      "month": month,
      "day": day,
      "hour": hour,
      "minute": minute,
      "second": second,
    });
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
    await _firestore.collection("Brands").doc(uid).set({
      "adminID": firebaseUser!.uid,
      "logoUrl": "",
      "name": name,
      "description": description,
      "dateJoined": formatted,
      "baseLocation": null,
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
      await this.leaveBrand(brandUsers[i].id!);
    }
    // Delete Brand
    await _firestore.collection("Brands").doc(brandId).delete();
  }

  Future<String> updateCurrentBrandPhoto(String brandID, File image) async {
    var result;
    var storageRef =
        await _firebaseStorage.ref().child("brandPics/" + brandID + ".png");
    var uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        result = value;
        await _firestore.collection("Brands").doc(brandID).update({
          "logoUrl": value,
        });
      });
    });
    return result;
  }

  Future<void> updateBrandInfo(String brandID, String name, String description,
      int maxMembers, List<double> workShift) async {
    await _firestore.collection("Brands").doc(brandID).update({
      "name": name,
      "description": description,
      "maxMembers": maxMembers,
      "workShift": workShift,
    });
  }

  Future<void> updateBrandBaseLocation(
      String brandID, String locationID) async {
    await _firestore
        .collection("Brands")
        .doc(brandID)
        .update({"baseLocation": locationID});
  }

  Future<List<Brand>> getAllBrands() async {
    List<Brand> brands = [];
    QuerySnapshot querySnapshot = await _firestore.collection("Brands").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brands.add(
          Brand.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return brands;
  }

  Future<Brand> getBrandDetails(String brandID) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection("Brands").doc(brandID).get();
    return Brand.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  Future<List<Usuario>> getAllTrainersFromBrand(String brandId) async {
    List<Usuario> users = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Users")
        .where("brandID", isEqualTo: brandId)
        .where("isTrainer", isEqualTo: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      users.add(
          Usuario.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return users;
  }

  Future<List<Usuario>> getAllClientsFromBrand(String brandId) async {
    List<Usuario> users = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Users")
        .where("brandID", isEqualTo: brandId)
        .where("isTrainer", isEqualTo: false)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      users.add(
          Usuario.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return users;
  }

  Future<bool> checkIfBrandExists(String brandID) async {
    var userDocRef = await _firestore.collection('Brands').doc(brandID);
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
      var selectedTrainers) async {
    var eventID = Uuid().v1();
    User? currentUser = await getCurrentUser();
    try {
      await _firestore.collection("Events").doc(eventID).set({
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
      return eventID;
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }

  // Get Single Event
  Future<Event> getSingleEvent(String id) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection("Events").doc(id).get();
    return Event.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  // Get All Events for Client
  Future<List<Event>> getAllEventsFromClient(String clientid) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Events")
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("joinedMembers", arrayContains: clientid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return events;
  }

  // Get All Events for Trainer
  Future<List<Event>> getAllEventsFromTrainer(String trainerid) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Events")
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("selectedTrainers", arrayContains: trainerid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return events;
  } // Get All Events for Client

  // Get All Events for Client
  Future<List<Event>> getAllClientEventsFromBrand(
      String clientid, String brandId) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Events")
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("brandID", isEqualTo: brandId)
        .where("joinedMembers", arrayContains: clientid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return events;
  }

  // Get All Events for Trainer
  Future<List<Event>> getAllTrainerEventsFromBrand(
      String trainerid, String brandId) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Events")
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .where("brandID", isEqualTo: brandId)
        .where("selectedTrainers", arrayContains: trainerid)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return events;
  }

  // Get All Events for Today of Brand
  Future<List<Event>> getAllEventsTodayBrand(String brandId) async {
    DateTime today = DateTime.now();
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Events")
        .where("year", isEqualTo: today.year.toString())
        .where("month", isEqualTo: today.month.toString())
        .where("day", isEqualTo: today.day.toString())
        .where("brandID", isEqualTo: brandId)
        .orderBy("hour", descending: false)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return events;
  }

  // Get All Events for User Today
  Future<List<Event>> getAllEventsTodayUser(
      String userid, bool isTrainer) async {
    DateTime today = DateTime.now();
    List<Event> events = [];
    QuerySnapshot querySnapshot;
    if (isTrainer) {
      querySnapshot = await _firestore
          .collection("Events")
          .where("year", isEqualTo: today.year.toString())
          .where("month", isEqualTo: today.month.toString())
          .where("day", isEqualTo: today.day.toString())
          .where("selectedTrainers", arrayContains: userid)
          .orderBy("hour", descending: false)
          .get();
    } else {
      querySnapshot = await _firestore
          .collection("Events")
          .where("year", isEqualTo: today.year.toString())
          .where("month", isEqualTo: today.month.toString())
          .where("day", isEqualTo: today.day.toString())
          .where("joinedMembers", arrayContains: userid)
          .orderBy("hour", descending: false)
          .get();
    }
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(
          Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return events;
  }

  // Delete Event
  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection("Events").doc(id).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete All Brand Events
  Future<void> deleteBrandEvents(String brandId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("Events")
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
  Future<void> deleteUserFromAllBrandEvents(
      String uid, String brandId, bool isTrainer) async {
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
        await this.leaveEvent(event.id!, uid, true);
      }
    }
  }

  // Get a Event Trainers
  Future<List<String>> getEventTrainers(String eid) async {
    List<String> participants = [];
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection("Events").doc(eid).get();
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
        await _firestore.collection("Events").doc(eid).get();
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
      await _firestore.collection("Events").doc(eid).update({
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
      await _firestore.collection("Events").doc(eid).update({
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
    List<String> eventUsers = [];
    if (isTrainer) {
      eventUsers = await this.getEventTrainers(eid);
      for (var i = 0; i < eventUsers.length; i++) {
        String trainerid = eventUsers[i];
        if (trainerid == uid) {
          isFound = true;
          eventUsers.removeAt(i);
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
          eventUsers.removeAt(i);
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
      await _firestore.collection("Events").doc(id).update({
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

  // Update Event Is Completed
  Future<void> updateEventCompleted(String id) async {
    await _firestore.collection("Events").doc(id).update({
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
      await _firestore.collection("Locations").doc(uid).set({
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
      await _firestore.collection("Locations").doc(locationID).update({
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
  Future<bool> deleteLocation(String locationId) async {
    try {
      await _firestore.collection("Locations").doc(locationId).delete();
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
            .collection("Locations")
            .where("brandID", isEqualTo: brandId)
            .get();
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          await this.deleteLocation(querySnapshot.docs[i].id);
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
        await _firestore.collection("Locations").doc(locationId).get();
    return Location.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  // Brand Requests

  // Send Request
  Future<void> sendRequest(String brandId, String name, bool isTrainer) async {
    User? currentUser = await getCurrentUser();
    var uid = Uuid().v1();
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yy');
    final String formatted = formatter.format(now);
    await _firestore.collection("Requests").doc(uid).set({
      "brandId": brandId,
      "userId": currentUser!.uid,
      "name": name,
      "isTrainer": isTrainer,
      "dateSent": formatted,
      "year": now.year.toString(),
      "month": now.month.toString(),
      "day": now.day.toString(),
    });
  }

  // Accept Request
  Future<void> acceptRequest(String requestId) async {
    // Get the Request
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection("Requests").doc(requestId).get();
    RequestToBrand request =
        RequestToBrand.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
    // Accept the user to Brand
    await _firestore.collection("Users").doc(request.userId).update({
      "brandID": request.brandId,
    });
    // Delete the Request
    await _firestore.collection("Requests").doc(requestId).delete();
  }

  // Delete Request
  Future<void> deleteRequest(String requestId) async {
    // Delete the Request
    await _firestore.collection("Requests").doc(requestId).delete();
  }

  // Has Pending Request
  Future<RequestToBrand?> hasPendingRequest(String userId) async {
    RequestToBrand request;
    QuerySnapshot querySnapshot = await _firestore
        .collection("Requests")
        .where("userId", isEqualTo: userId)
        .get();
    if (querySnapshot.docs.length > 0) {
      request = RequestToBrand.fromObject(
          querySnapshot.docs[0], querySnapshot.docs[0].id);
      return request;
    } else {
      return null;
    }
  }

  // Notifications

  // Send Notification
  Future<void> sendNotification(String userId, String type, bool isImportant, String title, String subtitle, var parameters) async {
    var uid = Uuid().v1();
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yy');
    final String formatted = formatter.format(now);
    await _firestore.collection("Notifications").doc(uid).set({
      "userId": userId,
      "type": type,
      "isImportant": isImportant,
      "isRead": false,
      "title": title,
      "subtitle": subtitle,
      "dateSent": formatted,
      "year": now.year.toString(),
      "month": now.month.toString(),
      "day": now.day.toString(),
      "parameters": parameters,
    });
  }

  //Questions

  //Get One Question
  Future<Question> getOneQuestion(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
        await _firestore.collection("Questions").doc(id).get();
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
      await _firestore.collection("Questions").doc(questionID).set({
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
    List<Question> questions = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Questions")
        .where("type", isEqualTo: type)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      questions.add(
          Question.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return questions;
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
          .collection("GroupOfQuestions")
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

  Future<GroupOfQuestions> getActiveGroupOfQuestions() async {
    List<GroupOfQuestions> groupOfQuestions = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("GroupOfQuestions")
        .where("isActive", isEqualTo: true)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      groupOfQuestions.add(GroupOfQuestions.fromObject(
          querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return groupOfQuestions[0];
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
      await _firestore.collection("Answers").doc(answerID).set({
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
        .collection("Answers")
        .where("userID", isEqualTo: currentUser.id.toString())
        .where("groupOfQuestionsID", isEqualTo: groupOfQuestionsId.toString())
        .get();

    print(currentUser.id.toString());
    print(querySnapshot.docs.length);
    if (querySnapshot.docs.length == 0) {
      print("false");
      return false;
    } else
      return true;
  }

  //Conversations

  Future<String> addConversation(
      var users,
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
      await _firestore.collection("Conversations").doc(uid).set({
        "users": users,
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
      await _firestore.collection("Messages").doc(uid).set({
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

  Future<List<Conversation>> getConversationByUsers(
      Map<String, dynamic> currentUser, Map<String, dynamic> user) async {
    List<Conversation> conversations = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Conversations")
        .where("users", arrayContains: currentUser)
        .get();
    QuerySnapshot querySnapshot2 = await _firestore
        .collection("Conversations")
        .where("users", arrayContains: user)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      for (int j = 0; j < querySnapshot2.docs.length; j++) {
        if (querySnapshot.docs[i].id == querySnapshot2.docs[j].id) {
          conversations.add(Conversation.fromObject(
              querySnapshot.docs[i], querySnapshot.docs[i].id));
          i = querySnapshot.docs.length;
          j = querySnapshot2.docs.length;
        }
      }
    }
    return conversations;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  // Brands
  Stream<QuerySnapshot> getAllBrandsStream() {
    return _firestore.collection("Brands").snapshots();
  }

  // Events
  Stream<DocumentSnapshot> getSingleEventStream(String eid) {
    return _firestore.collection("Events").doc(eid).snapshots();
  }

  Stream<QuerySnapshot> getAllEventsFromBrand(String brandid) {
    return _firestore
        .collection("Events")
        .where("brandID", isEqualTo: brandid)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllEventsTodayBrandStream(String brandId) {
    DateTime today = DateTime.now();
    return _firestore
        .collection("Events")
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
          .collection("Events")
          .where("selectedTrainers", arrayContains: userid)
          .orderBy("year", descending: true)
          .orderBy("month", descending: true)
          .orderBy("day", descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection("Events")
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
        .collection("Locations")
        .where("brandID", isEqualTo: brandId)
        .snapshots();
  }

  // Requests
  Stream<QuerySnapshot> getAllRequestsBrand(String brandId) {
    return _firestore
        .collection("Requests")
        .where("brandId", isEqualTo: brandId)
        .snapshots();
  }

  // Notifications
  Stream<QuerySnapshot> getAllNotificationsUser(String userId) {
    return _firestore
        .collection("Notifications")
        .where("userId", isEqualTo: userId)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .orderBy("day", descending: true)
        .snapshots();
  }

  //Question
  Stream<QuerySnapshot> getAllQuestions() {
    return _firestore.collection("Questions").snapshots();
  }

  //Conversations
  Stream<QuerySnapshot> getUserConversations(Map<String, dynamic> mapUser) {
    return _firestore
        .collection("Conversations")
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
  Stream<QuerySnapshot> getConversationMessages(String? conversationId) {
    print(conversationId);
    return _firestore
        .collection("Messages")
        .where("conversationId", isEqualTo: conversationId)
        .orderBy("year", descending: false)
        .orderBy("month", descending: false)
        .orderBy("day", descending: false)
        .orderBy("hour", descending: false)
        .orderBy("minute", descending: false)
        .orderBy("second", descending: false)
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
    return _firestore.collection("Users").snapshots();
  }
}
