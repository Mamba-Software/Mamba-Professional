import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'firebaseDatabase.dart';

class DatabaseAccess {

  final _firebase = FirebaseDatabaseService();

  Future<int> signIn(String email, String password) => _firebase.signIn(email, password);
  Future<void> signOut() => _firebase.signOut();
  Future<void> resetPassword(String email) => _firebase.resetPassword(email);

  Future<bool> checkCurrentUser() => _firebase.checkCurrentUser();
  Future<bool> checkIfItsMe(String uid) => _firebase.checkIfItsMe(uid);
  Future<User?> getCurrentUser() => _firebase.getCurrentUser();
  Future<Usuario> getCurrentUserDetails() => _firebase.getCurrentUserDetails();

  Future<int> addUser(String email, String password, String name, bool isTrainer, int gender, String idioma) => _firebase.addUser(email, password, name, isTrainer, gender, idioma);


}