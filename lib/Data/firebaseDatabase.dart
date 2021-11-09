import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
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
    UserCredential authResult = await _auth .signInWithEmailAndPassword(email: email, password: password).catchError((value){
      error = true;
    });
    if (error) return -1;
    if (authResult == null) return -1;
    //if (authResult.user != null) {
      //if (authResult.user!.emailVerified) return 0;
      //else return -2;
    //}
    else return 0;
  }
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  Future<void> resetPassword(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }
  Future<bool> deleteUser(String password) async {
    try {
      bool error = false;
      User user = await _auth.currentUser!;
      await _auth .signInWithEmailAndPassword(email: user.email!, password: password).catchError((value){
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
    if(currentUser != null) return true;
    else return false;
  }
  Future<bool> checkIfItsMe(String uid) async {
    User currentUser;
    currentUser = await _auth.currentUser!;
    if(currentUser.uid == uid) return true;
    else return false;
  }
  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = await _auth.currentUser;
    return currentUser;
  }
  Future<Usuario> getCurrentUserDetails() async {
    User? currentUser = await getCurrentUser();
    DocumentSnapshot<Map<String, dynamic >> _documentSnapshot = await _firestore.collection("Users").doc(currentUser!.uid).get();
    return Usuario.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }
  Future<Usuario> getUserDetails(String uid) async {
    DocumentSnapshot<Map<String, dynamic >> _documentSnapshot = await _firestore.collection("Users").doc(uid).get();
    return Usuario.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }
  // User Model Services
  // Add User
  Future<int> addUser(String email, String password, String name, bool isTrainer, int gender, String idioma) async {
    bool authError = false;
    bool firestoreError = false;
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    UserCredential? authResult = await _auth
        .createUserWithEmailAndPassword(
        email: email,
        password: password)
       .then((userCredential) async {
          if(userCredential != null && userCredential.user != null) {
          await _firestore
              .collection("Users")
              .doc(userCredential.user!.uid)
              .set({
            "name": name,
            "email": email,
            "imageUrl": "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=4d1be54c-ad85-4745-8bc5-62f27571a91b",
            "isFirst": true,
            "isTrainer": isTrainer,
            "isPrivate": true,
            "gender": gender,
            "dateJoined": formatted,
            "dateOfBirth": null,
            "idioma": idioma,
            "previousIdioma": null,
            "brandID": null,
            "isAdmin": false,
          })
          .catchError((err) {
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
      if (authError) return -1;
      else if (firestoreError) return -2;
      else return 0;
    } else {
      return -1;
    }
  }
  // Add Error/ Report Bug
  Future<bool> addError(String title, String description, [String? stepsReproduce]) async {
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
    if(firestoreError){
      return -1;
    } else {
      return 1;
    }
  }
  Future<String> updateCurrentUserPhoto(File image) async {
    User? firebaseUser = await getCurrentUser();
    String imageURL = "";
    var storageRef = await _firebaseStorage.ref().child("userPics/" + firebaseUser!.uid + ".png");
    var uploadTask= storageRef.putFile(image);
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
  Future<void> updateCurrentUserDatosPerifl(String name, int gender, String? dateOfBirth) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection("Users").doc(currentUser!.uid).update({
      "name": name,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
    });
  }
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma, String previousIdioma) async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection("Users").doc(currentUser!.uid).update({
      "isPrivate": isPrivate,
      "idioma": idioma,
      "previousIdioma": previousIdioma,
    });
  }

  Future<void> leaveCurrentUserBrand() async {
    User? currentUser = await getCurrentUser();
    await _firestore.collection("Users").doc(currentUser!.uid).update({
      "brandID": null,
    }).catchError((err) {
      print(err);
    });
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
    await _firestore
        .collection("Brands")
        .doc(uid)
        .set({
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

    if(!firestoreError){
      await updateCurrentBrandPhoto(uid,image);
      return uid;
    } else {
      return "Error";
    }
  }

  Future<String> updateCurrentBrandPhoto(String brandID, File image) async {
    var result;
    var storageRef = await _firebaseStorage.ref().child("brandPics/" + brandID + ".png");
    var uploadTask= storageRef.putFile(image);
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

  Future<void> updateBrandInfo(String brandID, String name, String description, int maxMembers, List<double> workShift) async {
    await _firestore.collection("Brands").doc(brandID).update({
      "name": name,
      "description": description,
      "maxMembers": maxMembers,
      "workShift": workShift,
    });
  }

  Future<void> updateBrandBaseLocation(String brandID, String locationID) async {
    await _firestore.collection("Brands").doc(brandID).update({
      "baseLocation": locationID
    });
  }


  Future<Brand> getBrandDetails(String brandID) async {
    DocumentSnapshot<Map<String, dynamic >> _documentSnapshot = await _firestore.collection("Brands").doc(brandID).get();
    return Brand.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  Future<List<Usuario>> getAllTrainersFromBrand(String brandId) async {
    List<Usuario> users = [];
    QuerySnapshot querySnapshot = await _firestore.collection("Users")
        .where("brandID", isEqualTo: brandId)
        .where("isTrainer", isEqualTo: true)
        .get();
    for(int i = 0; i < querySnapshot.docs.length; i++) {
      users.add(Usuario.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return users;
  }

  Future<List<Usuario>> getAllClientsFromBrand(String brandId) async {
    List<Usuario> users = [];
    QuerySnapshot querySnapshot = await _firestore.collection("Users")
        .where("brandID", isEqualTo: brandId)
        .where("isTrainer", isEqualTo: false)
        .get();
    for(int i = 0; i < querySnapshot.docs.length; i++) {
      users.add(Usuario.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
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
  Future<String> addEvent(String? brandID, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? placeId, int? maxMembers, var selectedTrainers) async {
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
        "placeId": placeId,
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
    DocumentSnapshot<Map<String, dynamic >> _documentSnapshot = await _firestore.collection("Events").doc(id).get();
    return Event.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }
  // Get All Events for Client
  Future<List<Event>> getAllEventsFromClient(String clientid) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("Events")
        //.orderBy("year", descending: true)
        //.orderBy("month", descending: true)
        //.orderBy("day", descending: true)
        .where("joinedMembers", arrayContains: clientid)
        .get();
    for(int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
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
    for(int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
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
    for(int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
    }
    return events;
  }

  // Get All Events for User Today
  Future<List<Event>> getAllEventsTodayUser(String userid, bool isTrainer) async {
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
    for(int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(Event.fromObject(querySnapshot.docs[i], querySnapshot.docs[i].id));
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
  // Update Event
  // Add Event
  Future<void> updateEvent(String? id, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? placeId, int? maxMembers, var selectedTrainers) async {
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
        "placeId": placeId,
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
  Future<String> addLocation(String brandId, bool isBaseLocation, String placeId, String description, String street, String streetNumber, String city, String zipCode, double latitude, double longitude) async {
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
  // Get Single Location
  Future<Location> getSingleLocation(String locationId) async {
    DocumentSnapshot<Map<String, dynamic >> _documentSnapshot = await _firestore.collection("Locations").doc(locationId).get();
    return Location.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  // Brands
  Stream<QuerySnapshot> getAllBrands() {
    return _firestore.collection("Brands").snapshots();
  }

  // Events
  Stream<DocumentSnapshot> getSingleEventStream(String eid) {
  return _firestore.collection("Events")
      .doc(eid)
      .snapshots();
  }
  Stream<QuerySnapshot> getAllEventsFromBrand(String brandid) {
    return _firestore.collection("Events")
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
  // Brands
  Stream<QuerySnapshot> getAllLocationsBrand(String brandId) {
    return _firestore
        .collection("Locations")
        .where("brandID", isEqualTo: brandId)
        .snapshots();
  }


  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<Stream<QuerySnapshot>> getAllUsers() async {
    return _firestore.collection("Users")
        .snapshots();
  }

}