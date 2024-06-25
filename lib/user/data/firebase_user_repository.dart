import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/user/models/users/user.dart';
import 'dart:async';

//Singleton
class FirebaseUserRepository {

  // Collections
  static final _usersCollection = FirebaseFirestore.instance.collection('Users');  

  Stream<Usuario> getUserStream({required String userId}) {
    return _usersCollection.doc(userId).snapshots().map(Usuario.fromDocument);
  }

  Future<bool> hasToCompleteProfile({required String userId}) async {
    final DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    if (doc.exists && doc.data() != null && (doc.data()! as Map).containsKey('isFirst')) {
      return doc['isFirst'] as bool;
    } else {
      return true;
    }
  }

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
