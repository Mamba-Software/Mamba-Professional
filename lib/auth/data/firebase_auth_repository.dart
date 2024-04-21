import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba/auth/data/auth_repository.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/auth/models/exceptions.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/user/models/users/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthRepository implements AuthRepository {
  // Firebase Instances
  static final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String users = 'Users';
  String nicknames = 'Nicknames';
  String brands = 'Brands';
  String conversations = 'Conversations';
  String purchases = 'Purchases';

  @override
  Future<void> createUser({required String email, required String password}) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<bool> existEmail({required String email}) {
    // TODO: implement existEmail
    throw UnimplementedError();
  }

  @override
  Future<bool> existUsername({required String username}) {
    // TODO: implement existUsername
    throw UnimplementedError();
  }

  @override
  Future<void> logInWithEmailAndPassword(
      {required String email, required String password}) async {
    bool emailVerified = true;
    UserCredential? authResult;
    auth.UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on auth.FirebaseAuthException catch (firebaseException) {
      switch (firebaseException.code) {
        case 'invalid-email':
          throw EmailNotValid();
        case 'user-disabled':
          throw WrongCredentials();
        case 'user-not-found':
          throw WrongCredentials();
        case 'wrong-password':
          throw WrongCredentials();
        default:
          throw WrongCredentials();
      }
    }

    if (flavor != Flavor.development) {
      emailVerified = userCredential.user?.emailVerified ?? false;
    }

    if (!emailVerified) throw EmailNotVerified();
  }

  @override
  Future<void> logInWithApple() async {
    return;
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oAuthProvider = OAuthProvider('apple.com');
      final oAuthCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      String? fullName;
      if (credential.givenName != null && credential.familyName != null) {
        fullName = '${credential.givenName} ${credential.familyName}';
      }
      if (fullName != null) {
        await authResult.user!.updateDisplayName(fullName);
        await authResult.user!.reload();
      }
    } catch (e) {
      print(e.toString());
      throw RegisterError();
    }
  }

  @override
  Future<void> logInWithGoogle() async {
    return;
    final googleSignIn = GoogleSignIn();
    try {
      final user = await googleSignIn.signIn();
      if (user == null) {
        throw WrongCredentials();
      } else {
        final googleAuth = await user.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      throw RegisterError();
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } on Exception {
      throw LogOutFailure();
    }
  }

  @override
  Stream<AuthUser> get authUser {
    return _firebaseAuth.userChanges().asyncMap((firebaseUser) async {
      try {
        if (firebaseUser == null ||
            (flavor != Flavor.development && !firebaseUser.emailVerified)) {
          return AuthUser.empty;
        } else {
          if (await checkUserType(checkTrainer: true)) {
            // Assuming 'isTrainer' is a field in your user document
            return firebaseUser.toAuthUser; // Continue if the user is a Trainer
          } else {
            return AuthUser
                .empty; // Treat as 'empty' or handle differently if not a Trainer
          }
        }
      } catch (e) {
        return AuthUser.empty;
      }
    });
  }

  @override
  Future<void> resetPassword({required String email}) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<void> registerUser(
      {required Usuario user,
      required String password,
      required String mainImagePath,
      required List<String> otherImagesPaths}) {
    // TODO: implement registerUser
    throw UnimplementedError();
  }

  @override
  Future<bool> checkUserType({required bool checkTrainer}) async {
    bool isTrainer = false;

    DocumentSnapshot documentSnapshot = await _firestore
        .collection(users)
        .doc(_firebaseAuth.currentUser!.uid)
        .get();

    isTrainer = documentSnapshot.get("isTrainer");
    if (checkTrainer) {
      if (isTrainer) return true;
    } else {
      if (!isTrainer) return true;
    }
    throw WrongAppUser();
  }
}

extension on auth.User {
  AuthUser get toAuthUser {
    return AuthUser(id: uid, email: email ?? '');
  }
}
