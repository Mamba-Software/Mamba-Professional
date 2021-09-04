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

}