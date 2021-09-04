// Flutter Libs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Models/Client.dart';
import 'package:mamba_castelldefels/Models/Error.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
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
            "imageUrl": null,
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

  // EL QUE TENIA JO
  // Collection reference
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  final clientsCollection = FirebaseFirestore.instance.collection('Clients');
  final trainersCollection = FirebaseFirestore.instance.collection('Trainers');
  final errorsCollection = FirebaseFirestore.instance.collection('Errors');

  // UPDATES
  Future<void> updateUsersData(String uid, bool isTrainer, bool isFirst, String? idioma, String? previousIdioma) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    return await usersCollection.doc(uid).set({
      'uid': uid,
      'isTrainer': isTrainer,
      'isFirst': isFirst,
      'dateJoined': formatted,
      'idioma': idioma,
      'previousIdioma': previousIdioma,
    });
  }
  Future<void> updateClientData(String uid, String name, String email, int gender, bool isPrivate, [String? dateOfBirth, String? imageURL]) async {
    return await clientsCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
      'isPrivate': isPrivate,
      'dateOfBirth': dateOfBirth,
      'imageURL': imageURL,
    });
  }
  Future<void> updateTrainerData(String uid, String name, String email, int gender, bool isPrivate, [String? dateOfBirth, String? imageURL]) async {
    return await trainersCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
      'isPrivate': isPrivate,
      'dateOfBirth': dateOfBirth,
      'imageURL': imageURL,
    });
  }
  Future<void> updateErrorData(Error error) async {
    var uid = error.createUID();
    return await errorsCollection.doc(uid).set({
      "uid": uid,
      "title": error.title,
      "descripcion": error.descripcion,
      "stepsReproduce": error.stepsReproduce
    });
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // USERS
  // User From Snapshot
  Future<Usuario> getUser (String uid) async {
    Usuario user = new Usuario(uid: uid);
    var docSnapshot = await usersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      user = Usuario(
          uid: data?['uid'],
          isTrainer: data?['isTrainer'],
          isFirst: data?['isFirst'],
          dateJoined: data?['dateJoined'],
          idioma: data?['idioma'],
          previousIdioma: data?['previousIdioma'],
      );
    }
    return user;
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // CLIENT
  // Client From Snapshot
  Future<Client> getClient (String uid) async {
    Client client = new Client(uid: uid);
    var docSnapshot = await clientsCollection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      client = Client(
          uid: data?['uid'],
          name: data?['name'],
          email: data?['email'],
          gender: data?['gender'],
          isPrivate: data?['isPrivate'],
          dateOfBirth: data?['dateOfBirth'],
          imageURL: data?['imageURL']
      );
    }
    return client;
  }
  // Client List from snapshot
  List<Client> _clientListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Client(
        uid: doc.get("uid") ?? '',
        name: doc.get("name") ?? '',
        email: doc.get("email") ?? '',
        gender: doc.get("gender") ?? '',
      );
    }).toList();
  }
  // Get Clients Stream
  Stream<List<Client>> get clients {
    return clientsCollection.snapshots().map(_clientListFromSnapshot);
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // TRAINER
  // Trainer From Snapshot
  Future<Trainer> getTrainer (String uid) async {
    Trainer trainer = new Trainer(uid: uid);
    var docSnapshot = await trainersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      trainer = Trainer(
        uid: data?['uid'],
        name: data?['name'],
        email: data?['email'],
        gender: data?['gender'],
        isPrivate: data?['isPrivate'],
        dateOfBirth: data?['dateOfBirth'],
        imageURL: data?['imageURL'],
      );
    }
    return trainer;
  }
  // Trainer List from snapshot
  List<Trainer> _trainerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Trainer(
        uid: doc.get("uid") ?? '',
        name: doc.get("name") ?? '',
        email: doc.get("email") ?? '',
        gender: doc.get("gender") ?? '',
      );
    }).toList();
  }
  // Get Trainers Stream
  Stream<List<Trainer>> get trainers {
    return trainersCollection.snapshots().map(_trainerListFromSnapshot);
  }
}