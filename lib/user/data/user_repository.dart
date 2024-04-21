import 'package:mamba/user/data/firebase_user_repository.dart';
import 'package:mamba/user/models/users/user.dart';

abstract class UserRepository {
  final FirebaseUserRepository _firebaseRepo;
  Future<Usuario> getUser({required String uid});
  Stream<Usuario> getUserStream({required String uid});

  UserRepository(this._firebaseRepo);

  Future<List<Usuario>> getUsersByUsernameOrName({required String text});

  Future<void> updateName({
    required String uid,
    required String name,
    required List<String> searchNames,
  });
  Future<void> updateBiography({
    required String uid,
    required String biography,
  });
  Future<void> updateBirthday({
    required String uid,
    required DateTime birthday,
  });
  Future<void> updateGender({
    required String userId,
    required String gender,
  });
  Future<void> updateMainImage({
    required String uid,
    required String mainImagePath,
  });
  Future<void> updateOtherImages({
    required String uid,
    required Map<int, String> otherImagesPaths,
    required Map<int, String> otherImagesUrls,
  });

  Future<void> updatePushToken({required String uid, required String token});
  Future<void> checkAndUpdatePushToken({
    required String uid,
    required String token,
  });

  Future<void> completeRegister({
    required String userId,
    required String name,
    required String username,
    required DateTime birthday,
    required String gender,
    required String mainImagePath,
    required List<String> otherImagesPath,
  });
  Future<bool> hasToCompleteProfile({required String uid});
  Future<void> markCompleteProfileAsDone({required String uid});
  Future<void> markCompleteProfileAsPending({required String uid});

  Future<void> reportUser({
    required String currentUserId,
    required String reportedUserId,
  });

  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  });
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  });
  Future<List<String>> getBlockedUsersIds({
    required String userId,
  });

  Future<void> emptyPendingNotifications({
    required String userId,
  });
  Future<void> deleteAccount({required String userId});
  Future<void> reportError({required String userId, required String error});
}
