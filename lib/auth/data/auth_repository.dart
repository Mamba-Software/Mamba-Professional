import 'dart:async';

import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/user/models/users/user.dart';

abstract class AuthRepository {
  Stream<AuthUser> get authUser;

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> logInWithGoogle();

  Future<void> logInWithApple();

  Future<void> logOut();

  Future<void> resetPassword({required String email});

  Future<bool> existEmail({required String email});

  Future<bool> existUsername({required String username});

  Future<bool> checkUserType({required bool checkTrainer});

  Future<void> registerUser({
    required Usuario user,
    required String password,
    required String mainImagePath,
    required List<String> otherImagesPaths,
  });

  Future<void> createUser({required String email, required String password});
}
