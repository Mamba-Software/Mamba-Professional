import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
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
    if (authResult.user != null) {
      if (authResult.user!.emailVerified) return 0;
      else return -2;
    }
    else return -1;
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
  Future<void> updateCurrentUserPhoto(File image) async {
    User? firebaseUser = await getCurrentUser();
    var storageRef = await _firebaseStorage.ref().child("userPics/" + firebaseUser!.uid + ".png");
    var uploadTask= storageRef.putFile(image);
    uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        await _firestore.collection("Users").doc(firebaseUser.uid).update({
          "imageUrl": value,
        });
        currentUser.imageUrl = value;
      });
    });
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
  // Brand Model Services
  // Add Brand
  Future<String> addBrand(String name, File image, String description, String placeId, double latitude, double longitude) async {
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
      "placeId": placeId,
      "latitude": latitude,
      "longitude": longitude,
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

  Future<void> updateCurrentBrandPhoto(String brandID, File image) async {
    var storageRef = await _firebaseStorage.ref().child("brandPics/" + brandID + ".png");
    var uploadTask= storageRef.putFile(image);
    uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        await _firestore.collection("Brands").doc(brandID).update({
          "logoUrl": value,
        });
      });
    });
  }

  Future<Brand> getCurrentBrandDetails(String brandID) async {
    DocumentSnapshot<Map<String, dynamic >> _documentSnapshot = await _firestore.collection("Brands").doc(brandID).get();
    return Brand.fromMap(_documentSnapshot.data()!, _documentSnapshot.id);
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

  //admin
  // get brews stream
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection("Users")
        .snapshots();
  }

}