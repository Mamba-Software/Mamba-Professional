import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/models/Usuario.dart';

import 'Database.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Create User Object based on FireBase User.
  Usuario? _usuarioFromFirebaseUser(User user) {
    return user != null ? Usuario(uid: user.uid) : null;
  }

  // Stream of Users based on our User model.
  Stream<Usuario?> get usuario {
    return _firebaseAuth.authStateChanges().map(_usuarioFromFirebaseUser);
  }

  Future signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _usuarioFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signUp({required String email, required String password, required String name, required bool isTrainer, }) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      if (isTrainer) {
        await DatabaseService(uid: user.uid).updateTrainerData(name,email);
      } else {
        await DatabaseService(uid: user.uid).updateClientData(name,email);
      }
      return _usuarioFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}