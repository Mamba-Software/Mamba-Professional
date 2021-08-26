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
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  final clientsCollection = FirebaseFirestore.instance.collection('Clients');
  final trainersCollection = FirebaseFirestore.instance.collection('Trainers');

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
  Future<Usuario> getUser (String uid) async {
    Usuario user = new Usuario(uid: uid);
    var docSnapshot = await usersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      user = Usuario(uid: data?['uid'], isTrainer: data?['isTrainer'], isFirst: data?['isFirst']);
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
      client = Client(uid: data?['uid'], name: data?['name'], email: data?['email']);
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
      trainer = Trainer(uid: data?['uid'], name: data?['name'], email: data?['email']);
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
      );
    }).toList();
  }
  // Get Trainers Stream
  Stream<List<Trainer>> get trainers {
    return trainersCollection.snapshots().map(_trainerListFromSnapshot);
  }
}