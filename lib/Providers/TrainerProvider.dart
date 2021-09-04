import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/firebaseDatabase.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';

enum LoaderT {Uninitialized, YES, NO}

class TrainerProvider extends ChangeNotifier {
  FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  Trainer _trainer = new Trainer(uid: "uid");
  LoaderT _loader = LoaderT.Uninitialized;

  // Getters
  Trainer get trainer => _trainer;
  LoaderT get loader => _loader;

  // UPDATE DEL VALOR DE USUARI AMB FIREBASE
  Future<void> getTrainerFirebase(String uid) async {
    try {
      _trainer = await _databaseService.getTrainer(uid);
      _loader = LoaderT.NO;
      notifyListeners();
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  Future<void> updateTrainerFirebase(Trainer trainer) async {
    try {
      _databaseService.updateTrainerData(trainer.uid, trainer.name!, trainer.email!, trainer.gender!, trainer.isPrivate!, trainer.dateOfBirth!);
      this.getTrainerFirebase(trainer.uid);
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}