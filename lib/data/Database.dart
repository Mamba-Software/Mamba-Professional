import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/models/Client.dart';
import 'package:mamba_castelldefels/models/Trainer.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // Collection reference
  final CollectionReference clientsCollection = FirebaseFirestore.instance.collection('Clients');
  final CollectionReference trainersCollection = FirebaseFirestore.instance.collection('Trainers');

  Future<void> updateClientData(String name, String email) async {
    return await clientsCollection.doc(uid).set({
      'name': name,
      'email': email
    });
  }

  Future<void> updateTrainerData(String name, String email) async {
    return await trainersCollection.doc(uid).set({
      'name': name,
      'email': email
    });
  }

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