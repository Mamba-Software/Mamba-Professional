import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend of the User Object.
class UserDataService {

  final _firebase = FirebaseDatabaseService();

  // Authentication
  Future<User?> getCurrentUser() => _firebase.getCurrentUser();
  Future<int> signIn(String email, String password) => _firebase.signIn(email, password);
  Future<void> signOut() => _firebase.signOut();
  Future<int> resetPassword(String email) => _firebase.resetPassword(email);
  Future<bool> deleteUser(String password) => _firebase.deleteUser(password);

  // Get Data
  Future<Usuario> getUserDetails(String uid) => _firebase.getUserDetails(uid);
  Future<List<String>> getUserCoverDetails(String uid) => _firebase.getUserCover(uid);
  Future<List<Brand>> getUserBrands(String uid) => _firebase.getAllBrandsFromUser(uid);

  Future<int> registerUser(String email, String password, String idioma) => _firebase.registerUser(email, password, idioma);
  Future<void> addUser(String uid, String name, String firstName, String lastName, String nick, String dateOfBirth, int gender, File? image, bool isTrainer) => _firebase.addUser(uid, name, firstName, lastName, nick, dateOfBirth, gender, image, isTrainer);
  Future<void> updateUserNotificationToken(String uid, String token) => _firebase.updateUserNotificationToken(uid, token);
  Future<bool> checkIfAliasExists(String alias) => _firebase.checkIfAliasExists(alias);

  Future<void> updateCurrentUserFirstTime() => _firebase.updateCurrentUserFirstTime();
  Future<String> updateCurrentUserPhoto(File image) => _firebase.updateCurrentUserPhoto(image);
  Future<void> updateCurrentUserDatosPerifl(String name, String firstName, String lastName, int gender, String dateOfBirth) => _firebase.updateCurrentUserDatosPerifl(name, firstName, lastName, gender, dateOfBirth);
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma, String previousIdioma) => _firebase.updateCurrentUserSettingsPerifl(isPrivate, idioma, previousIdioma);

  // Notifications
  Future<int> numberUnreadNotificationsFromUser(String userId) => _firebase.numberUnreadNotifications(userId);
  // Chats
  Future<int> numberUnreadConversationsFromUser(String userId) => _firebase.numberUnreadConversations(userId);
}