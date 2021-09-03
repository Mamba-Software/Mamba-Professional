import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';

// USER STATUS
enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthenticationProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Status _status = Status.Uninitialized;

  AuthenticationProvider.instance() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User? get user => _user;

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      errorAuthLogin = true;
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name, int gender, String idioma, bool isTrainer) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (isTrainer) {
        await DatabaseService().updateUsersData(_user!.uid,true,true,idioma,null);
        await DatabaseService().updateTrainerData(_user!.uid,name,email,gender,true);
      } else {
        await DatabaseService().updateUsersData(_user!.uid,false,true,idioma,null);
        await DatabaseService().updateClientData(_user!.uid,name,email,gender,true);
      }
      return true;
    } catch (e) {
      print(e.toString());
      errorAuthRegister = true;
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      userUID = firebaseUser.uid;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}