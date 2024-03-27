import 'package:cloud_firestore/cloud_firestore.dart';

//Singleton
class FirebaseUserRepository {
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
}
