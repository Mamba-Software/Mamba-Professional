import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Models/Client.dart';

enum LoaderC {Uninitialized, YES, NO}

class ClientProvider extends ChangeNotifier {
  DatabaseService _databaseService = DatabaseService();
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

  Future<void> getStreamClientFirebase(String uid) async {
    try {
      _client = (_databaseService.singleUser) as Client;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}