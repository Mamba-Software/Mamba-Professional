import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

enum Type {Uninitialized, Trainer, Client}
enum First {Uninitialized, YES, NO}

class UserProvider extends ChangeNotifier {
  DatabaseService _databaseService = DatabaseService();
  Usuario _usuario = new Usuario(uid: "uid");
  Type _type = Type.Uninitialized;
  First _firstTime = First.Uninitialized;

  // Getters
  Usuario get usuario => _usuario;
  Type get type => _type;
  First get first => _firstTime;

  void resetUser()  {
    _usuario = new Usuario(uid: "uid");
    _type = Type.Uninitialized;
    _firstTime = First.Uninitialized;
  }

  // UPDATE DEL VALOR DE USUARI AMB FIREBASE
  Future<void> getUsuarioFirebase(String uid) async {
    try {
      _usuario = await _databaseService.getUser(uid);
      _usuario.isFirst! ? _firstTime = First.YES : _firstTime = First.NO;
      _usuario.isTrainer! ? _type = Type.Trainer : _type = Type.Client;
      notifyListeners();
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }
}