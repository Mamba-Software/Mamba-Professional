// Flutter Libs
import 'package:cloud_firestore/cloud_firestore.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Models/Client.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';

class DatabaseService {

  DatabaseService();

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
  Future<void> updateClientData(String uid, String name, String email) async {
    return await clientsCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
    });
  }
  Future<void> updateTrainerData(String uid, String name, String email) async {
    return await trainersCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
    });
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // USERS
  // User From Snapshot
  Future<Usuario?> userFromSnapshot(QuerySnapshot snapshot) {
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
    return Future(() => null);
  }
  // Get User Stream
  Stream<Future<Usuario?>> get singleUser {
    return usersCollection.snapshots().map(userFromSnapshot);
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // CLIENT
  // Get Single Client
  // Client From Snapshot
  Client clientFromSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docs.length != 0) {
      for (var i = 0; i < snapshot.docs.length; i++) {
        if (snapshot.docs[i].id == userUID) {
          print("clientFromSnapshot");
          print(snapshot.docs[i].data().toString());
          return Client(
            uid: snapshot.docs[i].get("uid"),
            name: snapshot.docs[i].get("name"),
            email: snapshot.docs[i].get("email"),
          );
        }
      }
    }
    return currentClient;
  }
  // Get Client Stream
  Stream<Client> get singleClient {
    return clientsCollection.snapshots().map(clientFromSnapshot);
  }


  // Client list from snapshot
  List<Client> _clientListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Client(
        uid: doc.get("uid") ?? '',
        name: doc.get("name") ?? '',
        email: doc.get("email") ?? '',
      );
    }).toList();
  }
  // Get Clients Stream
  Stream<List<Client>> get clients {
    return clientsCollection.snapshots().map(_clientListFromSnapshot);
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // TRAINER
  // Get Single Client
  // User From Snapshot
  Trainer trainerFromSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docs.length != 0) {
      for (var i = 0; i < snapshot.docs.length; i++) {
        if (snapshot.docs[i].id == userUID) {
          print("trainerFromSnapshot");
          print(snapshot.docs[i].data().toString());
          return Trainer(
            uid: snapshot.docs[i].get("uid"),
            name: snapshot.docs[i].get("name"),
            email: snapshot.docs[i].get("email"),
          );
        }
      }
    }
    return currentTrainer;
  }
  // Get Trainer Stream
  Stream<Trainer> get singleTrainer {
    return trainersCollection.snapshots().map(trainerFromSnapshot);
  }


  // Trainer list from snapshot
  List<Trainer> _trainerListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Trainer(
        uid: doc.get("uid") ?? '',
        name: doc.get("name") ?? '',
        email: doc.get("email") ?? '',
      );
    }).toList();
  }
  // Get Trainers Stream
  Stream<List<Trainer>> get trainers {
    return trainersCollection.snapshots().map(_trainerListFromSnapshot);
  }
}