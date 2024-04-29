import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/user/models/users/user.dart';

import 'dart:async';
import 'dart:io';

//Singleton
class FirebaseUserRepository implements UserRepository {
  static final FirebaseUserRepository _instance =
      FirebaseUserRepository._internal();

  factory FirebaseUserRepository() => _instance;
  FirebaseUserRepository._internal();

  // Collections
  static final _usersCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<void> updateCurrentUserSettingsPerifl(
    String userId,
    bool isPrivate,
    String idioma,
  ) async {
    await _usersCollection.doc(userId).update({
      "isPrivate": isPrivate,
      "idioma": idioma,
    });
  }

  @override
  Stream<Usuario> getUserStream({required String uid}) {
    return _usersCollection.doc(uid).snapshots().map(Usuario.fromDocument);
  }

  @override
  Future<void> blockUser(
      {required String currentUserId, required String blockedUserId}) {
    // TODO: implement blockUser
    throw UnimplementedError();
  }

  @override
  Future<void> checkAndUpdatePushToken(
      {required String uid, required String token}) {
    // TODO: implement checkAndUpdatePushToken
    throw UnimplementedError();
  }

  @override
  Future<void> completeRegister(
      {required String userId,
      required String name,
      required String username,
      required DateTime birthday,
      required String gender,
      required String mainImagePath,
      required List<String> otherImagesPath}) {
    // TODO: implement completeRegister
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount({required String userId}) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<void> emptyPendingNotifications({required String userId}) {
    // TODO: implement emptyPendingNotifications
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getBlockedUsersIds({required String userId}) {
    // TODO: implement getBlockedUsersIds
    throw UnimplementedError();
  }

  @override
  Future<Usuario> getUser({required String uid}) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<List<Usuario>> getUsersByUsernameOrName({required String text}) {
    // TODO: implement getUsersByUsernameOrName
    throw UnimplementedError();
  }

  @override
  Future<bool> hasToCompleteProfile({required String uid}) async {
    final DocumentSnapshot doc = await _usersCollection.doc(uid).get();
    if (doc.exists &&
        doc.data() != null &&
        (doc.data()! as Map).containsKey('isFirst')) {
      return doc['isFirst'] as bool;
    } else {
      return true;
    }
  }

  @override
  Future<void> markCompleteProfileAsDone({required String uid}) {
    // TODO: implement markCompleteProfileAsDone
    throw UnimplementedError();
  }

  @override
  Future<void> markCompleteProfileAsPending({required String uid}) {
    // TODO: implement markCompleteProfileAsPending
    throw UnimplementedError();
  }

  @override
  Future<void> reportError({required String userId, required String error}) {
    // TODO: implement reportError
    throw UnimplementedError();
  }

  @override
  Future<void> reportUser(
      {required String currentUserId, required String reportedUserId}) {
    // TODO: implement reportUser
    throw UnimplementedError();
  }

  @override
  Future<void> unblockUser(
      {required String currentUserId, required String blockedUserId}) {
    // TODO: implement unblockUser
    throw UnimplementedError();
  }

  @override
  Future<void> updateBiography(
      {required String uid, required String biography}) {
    // TODO: implement updateBiography
    throw UnimplementedError();
  }

  @override
  Future<void> updateBirthday(
      {required String uid, required DateTime birthday}) {
    // TODO: implement updateBirthday
    throw UnimplementedError();
  }

  @override
  Future<void> updateGender({required String userId, required String gender}) {
    // TODO: implement updateGender
    throw UnimplementedError();
  }

  @override
  Future<void> updateMainImage(
      {required String uid, required String mainImagePath}) {
    // TODO: implement updateMainImage
    throw UnimplementedError();
  }

  @override
  Future<void> updateName(
      {required String uid,
      required String name,
      required List<String> searchNames}) {
    // TODO: implement updateName
    throw UnimplementedError();
  }

  @override
  Future<void> updateOtherImages(
      {required String uid,
      required Map<int, String> otherImagesPaths,
      required Map<int, String> otherImagesUrls}) {
    // TODO: implement updateOtherImages
    throw UnimplementedError();
  }

  @override
  Future<void> updatePushToken({required String uid, required String token}) {
    // TODO: implement updatePushToken
    throw UnimplementedError();
  }
}
