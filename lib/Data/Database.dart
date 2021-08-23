// Flutter Libs
import 'package:cloud_firestore/cloud_firestore.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Models/Client.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // Collection reference
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  final CollectionReference clientsCollection = FirebaseFirestore.instance.collection('Clients');
  final CollectionReference trainersCollection = FirebaseFirestore.instance.collection('Trainers');

  // UPDATES
  Future<void> updateUsersData(String uid, bool isTrainer, bool isFirst) async {
    return await usersCollection.doc(uid).set({
      'uid': uid,
      'isTrainer': isTrainer,
      'isFirst': isFirst,
    });
  }
  Future<void> updateClientData(String name, String email) async {
    return await clientsCollection.doc(uid).set({
      'name': name,
      'email': email,
    });
  }
  Future<void> updateTrainerData(String name, String email) async {
    return await trainersCollection.doc(uid).set({
      'name': name,
      'email': email,
    });
  }

  // USERS
  // User From Snapshot
  Future<Usuario> _userFromSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docs.length != 0) {
      for (var i = 0; i < snapshot.docs.length; i++) {
        if (snapshot.docs[i].id == userUID) {
          Future<Usuario> future = Future(() =>
              Usuario(
                uid: snapshot.docs[i].get("uid"),
                isTrainer: snapshot.docs[i].get("isTrainer"),
                isFirst: snapshot.docs[i].get("isFirst"),
              )
          );
          return future;
        }
      }
    }
    Future<Usuario> future = Future(() =>
        Usuario(uid: "uid", isTrainer: false, isFirst: true)
    );
    return future;
  }
  // Get User Stream
  Stream<Future<Usuario>> get singleUser {
    return usersCollection.snapshots().map(_userFromSnapshot);
  }

  // CLIENT
  // Client list from snapshot
  List<Client> _clientListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Client(
        name: doc.get("name") ?? '',
        email: doc.get("email") ?? 0,
      );
    }).toList();
  }

  // Get Clients Stream
  Stream<List<Client>> get clients {
    return clientsCollection.snapshots().map(_clientListFromSnapshot);
  }


  // TRAINER
  // Trainer list from snapshot
  List<Trainer> _trainerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Trainer(
        name: doc.get("name") ?? '',
        email: doc.get("email") ?? 0,
      );
    }).toList();
  }

  // Get Trainers Stream
  Stream<List<Trainer>> get trainers {
    return trainersCollection.snapshots().map(_trainerListFromSnapshot);
  }
}