// Flutter Libs
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/FirebaseUser.dart';
// Internal App Tools
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'Database.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Create User Object based on FireBase User.
  FirebaseUser? _usuarioFromFirebaseUser(User? user) {
    if (user != null) {
      return FirebaseUser(uid: user.uid);
    } else {
      return null;
    }
  }

  // Stream of Users based on our User model.
  Stream<FirebaseUser?> get usuarioFirebase {
    return _firebaseAuth.authStateChanges().map(_usuarioFromFirebaseUser);
  }

  // Signin method using Firebase
  Future signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _usuarioFromFirebaseUser(user!);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Signup method using Firebase
  Future signUp({required String email, required String password, required String name, required bool isTrainer, }) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (isTrainer) {
        await DatabaseService().updateUsersData(user!.uid,true,true);
        await DatabaseService().updateTrainerData(user.uid,name,email);
      } else {
        await DatabaseService().updateUsersData(user!.uid,false,true);
        await DatabaseService().updateClientData(user.uid,name,email);
      }
      return _usuarioFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Signout method using Firebase
  Future signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}