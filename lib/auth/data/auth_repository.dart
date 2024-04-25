import 'dart:async';

import 'package:mamba/auth/data/firebase_auth_service.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/user/models/users/user.dart';

class AuthRepository {
  final FirebaseAuthService _firebaseService;

  AuthRepository({
    FirebaseAuthService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseAuthService();

  Stream<AuthUser> get authUser {
    return _firebaseService.authUser;
    // TODO: implement authUser
    throw UnimplementedError();
  }

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseService.logInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logInWithGoogle() {
    return _firebaseService.logInWithGoogle();
  }

  Future<void> logInWithApple() {
    return _firebaseService.logInWithApple();
  }

  Future<void> logOut() {
    return _firebaseService.logOut();
  }

  Future<void> resetPassword({required String email}) {
// TODO: implement authUser
    throw UnimplementedError();
  }

  Future<bool> existEmail({required String email}) {
// TODO: implement authUser
    throw UnimplementedError();
  }

  Future<bool> existUsername({required String username}) {
// TODO: implement authUser
    throw UnimplementedError();
  }

  Future<bool> checkUserType({required bool checkTrainer}) {
    // TODO: implement authUser
    throw UnimplementedError();
  }

  Future<void> registerUser({
    required Usuario user,
    required String password,
    required String mainImagePath,
    required List<String> otherImagesPaths,
  }) {
// TODO: implement authUser
    throw UnimplementedError();
  }

  Future<void> createUser({required String email, required String password}) {
// TODO: implement authUser
    throw UnimplementedError();
  }
}
