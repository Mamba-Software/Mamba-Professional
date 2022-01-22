import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
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

  // Check Data
  Future<bool> checkIfNicknameExists(String nickname) => _firebase.checkIfNicknameExists(nickname);

  // Get Data
  Future<Usuario> getUserDetails(String userId) => _firebase.getUserDetails(userId);
  Future<List<String>> getUserCoverDetails(String userId) => _firebase.getUserCoverDetails(userId);
  Future<List<Brand>> getUserBrands(String userId) => _firebase.getAllBrandsFromUser(userId);
  Future<List<RequestToBrand>> getUserRequests(String userId) => _firebase.getUserRequests(userId);
  Future<int> getUnreadNotifications(String userId) => _firebase.getUnreadNotifications(userId);
  Future<int> getUnreadConversations(String userId) => _firebase.getUnreadConversations(userId);

  // Add Data
  Future<int> addUser(String email, String password, String idioma) => _firebase.addUser(email, password, idioma);
  Future<void> addUserNickname(String userId, String nickname) => _firebase.addUserNickname(userId, nickname);
  Future<void> sendRequestToBrand(String brandId, String name, bool isTrainer) => _firebase.sendRequestToBrand(brandId, name, isTrainer);

  // Update Data
  Future<void> updateUser(String uid, String name, String firstName, String lastName, String nick, String dateOfBirth, int gender, File? image, bool isTrainer) => _firebase.updateUser(uid, name, firstName, lastName, nick, dateOfBirth, gender, image, isTrainer);
  Future<void> updateUserNotificationToken(String uid, String token) => _firebase.updateUserNotificationToken(uid, token);
  Future<void> updateCurrentUserFirstTime() => _firebase.updateCurrentUserFirstTime();
  Future<String> updateCurrentUserPhoto(File image) => _firebase.updateCurrentUserPhoto(image);
  Future<void> updateCurrentUserDatosPerifl(String name, String firstName, String lastName, int gender, String dateOfBirth) => _firebase.updateCurrentUserDatosPerifl(name, firstName, lastName, gender, dateOfBirth);
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma, String previousIdioma) => _firebase.updateCurrentUserSettingsPerifl(isPrivate, idioma, previousIdioma);

  // Delete Data
  Future<void> deleteRequestToBrand(RequestToBrand request) => _firebase.deleteRequestToBrand(request);
  Future<void> deleteUserNickname(String nickname) => _firebase.deleteUserNickname(nickname);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  Stream<QuerySnapshot> getAllNotificationsUserStream(String userId) => _firebase.getAllNotificationsUserStream(userId);



}