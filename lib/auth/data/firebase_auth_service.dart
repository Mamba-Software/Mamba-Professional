import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba/auth/data/auth_repository.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/auth/models/exceptions.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/user/models/users/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthService {
  // Firebase Instances
  static final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();
  final googleSignIn = GoogleSignIn();

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

  Future<void> logInWithEmailAndPassword(
      {required String email, required String password}) async {
    bool emailVerified = true;
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

  Future<void> logInWithApple() async {
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

  Future<void> logInWithGoogle() async {
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

  Future<bool> checkIfUserExists({required String userId}) async {
    var userDocRef = _firestore.collection(users).doc(userId);
    var doc = await userDocRef.get();
    if (!doc.exists) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
      await googleSignIn.signOut();
    } on Exception {
      throw LogOutFailure();
    }
  }

  Stream<AuthUser> get authUser {
    return _firebaseAuth.userChanges().asyncMap((firebaseUser) async {
      try {
        if (firebaseUser == null ||
            (flavor != Flavor.development && !firebaseUser.emailVerified)) {
          return AuthUser.empty;
        } else {
          if (await checkUserType(checkTrainer: true)) {
            if (await checkIfUserExists(userId: firebaseUser.uid)) {
              // Assuming 'isTrainer' is a field in your user document
              return firebaseUser
                  .toAuthUser(); // Continue if the user is a Trainer
            } else {
              return firebaseUser.toAuthUser(
                  error:
                      true); // Treat as 'empty' or handle differently if not a Trainer
            }
          } else {
            return AuthUser
                .empty; // Treat as 'empty' or handle differently if not a Trainer
          }
        }
      } catch (e) {
        return firebaseUser!.toAuthUser(error: true);
      }
    });
  }

  Future<void> resetPassword({required String email}) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'europe-west1')
              .httpsCallable('sendResetPasswordEmail');
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'email': email,
          'isTrainer': true,
        },
      );
      bool success = result.data['isSuccessful'];
    } on Exception {
      throw ResetPasswordFailure();
    }
  }

  Future<void> registerUser(
      {required Usuario user,
      required String password,
      required String mainImagePath,
      required List<String> otherImagesPaths}) {
    // TODO: implement registerUser
    throw UnimplementedError();
  }

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
  AuthUser toAuthUser({bool error = false}) {
    return AuthUser(
        id: uid, // 'uid' is typically available on Firebase auth.User
        email: email ?? '', // Safely handle null with a default empty string
        error: error // Pass the error state as a parameter
        );
  }
}
