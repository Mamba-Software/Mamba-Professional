import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/firebaseDatabase.dart';
import 'package:mamba_castelldefels/Models/Client.dart';

enum LoaderC {Uninitialized, YES, NO}

class ClientProvider extends ChangeNotifier {
  FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Client _client = new Client(uid: "uid");
  LoaderC _loader = LoaderC.Uninitialized;

  // Getters
  Client get client => _client;
  LoaderC get loader => _loader;

  // UPDATE DEL VALOR DE USUARI AMB FIREBASE
  Future<void> getClientFirebase(String uid) async {
    try {
      _client = await _databaseService.getClient(uid);
      _loader = LoaderC.NO;
      notifyListeners();
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  Future<void> updateClientFirebase(Client client) async {
    try {
      _databaseService.updateClientData(client.uid, client.name!, client.email!, client.gender!, client.isPrivate!, client.dateOfBirth, client.imageURL!);
      this.getClientFirebase(client.uid);
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> uploadFileClientProfile(File file) async {
    var storageRef = _firebaseStorage.ref().child("profileImages/client/${_client.uid}");
    var uploadTask = storageRef.putFile(file);
    uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) {
        client.imageURL = value;
        print(client.imageURL);
        updateClientFirebase(client);
      });
    });
  }

}