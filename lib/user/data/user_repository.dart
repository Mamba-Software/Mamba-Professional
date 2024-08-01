import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/user/data/firebase_user_repository.dart';

class UserRepository {
  final FirebaseUserRepository _firebaseService;

  UserRepository({
    FirebaseUserRepository? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseUserRepository();

  Stream<Usuario> getUserStream({required String userId}) {
    return _firebaseService.getUserStream(userId: userId);
  }

  Future<bool> hasToCompleteProfile({required String userId}) async {
    return _firebaseService.hasToCompleteProfile(userId: userId);
  }

  Future<void> updateUserProfile(
      {required String userId, required Usuario user}) async {
    _firebaseService.updateUserProfile(userId: userId, user: user);
  }
}
