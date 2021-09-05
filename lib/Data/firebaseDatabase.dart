// Flutter Libs
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Models/Usuario.dart';

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
            "imageUrl": "https://firebasestorage.googleapis.com/v0/b/mamba-24-8.appspot.com/o/emptyProfileImage.png?alt=media&token=59103e64-82a3-42bf-b3a0-342beb1919a6",
            "isFirst": true,
            "isTrainer": isTrainer,
            "isPrivate": true,
            "gender": gender,
            "dateJoined": formatted,
            "idioma": idioma,
            "previousIdioma": null,
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
    var uuid = Uuid();
    var uid = uuid.v1();
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
  Future<void> updateCurrentUserPhoto(File image) async {
    User? currentUser = await getCurrentUser();
    var storageRef = await _firebaseStorage.ref().child("userPics/" + currentUser!.uid + ".png");
    var uploadTask= storageRef.putFile(image);
    uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        await _firestore.collection("Users").doc(currentUser.uid).update({
          "imageUrl": value,
        });
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
}