import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
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
  Future<Usuario> getUserCoverDetails(String userId) => _firebase.getUserCoverDetails(userId);
  Future<List<RequestToBrand>> getUserRequests(String userId) => _firebase.getUserRequests(userId);
  Future<List<NotificationEvent>> getUserFirstNotificationsLimit10(String userId) => _firebase.getUserFirstNotificationsLimit10(userId);
  Future<List<NotificationEvent>> getUserMoreNotificationsLimit10(String userId, String notifId) => _firebase.getUserMoreNotificationsLimit10(userId, notifId);
  Future<int> getUnreadNotifications(String userId) => _firebase.getUnreadNotifications(userId);
  Future<int> getUnreadConversations(String userId) => _firebase.getUnreadConversations(userId);
  Future<String> getBonoRequest(String userId, String brandId) => _firebase.getBonoRequest(userId, brandId);
  Future<String> getBonoUser(String userId, String brandId) => _firebase.getBonoUser(userId, brandId);
  Future<List<int>> getUserFavourites(String brandId, String userId) => _firebase.getUserFavourites(brandId, userId);
  Future<List<ReceivedNotification>> getLocalNotifications(String userId) => _firebase.getLocalNotifications(userId);
  Future<ReceivedNotification?> getIndividualLocalNotification(String userId, String notificationId) => _firebase.getIndividualLocalNotification(userId, notificationId);
  Future<List<ReceivedNotification>> findEventLocalNotification(String userId, String eventId) => _firebase.findEventLocalNotification(userId, eventId);

  // Add Data
  Future<int> addUser(String email, String password, String idioma) => _firebase.addUser(email, password, idioma);
  Future<void> addUserNickname(String userId, String nickname) => _firebase.addUserNickname(userId, nickname);
  Future<void> addLocalNotification(String userId, ReceivedNotification notification) => _firebase.addLocalNotification(userId, notification);
  Future<void> sendNotificationToUser(String userId, String type, var parameters) => _firebase.sendNotificationToUser(userId, type, parameters);
  Future<void> sendRequestToBrand(String brandId, String name, bool isTrainer) => _firebase.sendRequestToBrand(brandId, name, isTrainer);
  Future<void> addBonoRequestToUser(String brandId, String userId, String bonoId) => _firebase.addBonoRequestToUser(brandId, userId, bonoId);
  Future<void> addBonoToUser(String brandId, String userId, String bonoId, int sessions, Timestamp time) => _firebase.addBonoToUser(brandId, userId, bonoId, sessions, time);
  Future<void> addFavouriteToUser(String brandId, String userId, List<int> favourites) => _firebase.addFavouriteToUser(brandId, userId, favourites);

  // Update Data
  Future<void> updateUser(String uid, String name, String firstName, String lastName, String nick, String dateOfBirth, int gender, File? image, bool isTrainer) => _firebase.updateUser(uid, name, firstName, lastName, nick, dateOfBirth, gender, image, isTrainer);
  Future<void> updateUserThemePreferences(String uid, bool? isDark) => _firebase.updateUserThemePreferences(uid, isDark);
  Future<void> updateUserNotificationToken(String uid, String token) => _firebase.updateUserNotificationToken(uid, token);
  Future<void> updateCurrentUserFirstTime() => _firebase.updateCurrentUserFirstTime();
  Future<String> updateUserPhoto(String uid, File image) => _firebase.updateUserPhoto(uid, image);
  Future<void> updateCurrentUserDatosPerifl(String name, String firstName, String lastName, int gender, String dateOfBirth) => _firebase.updateCurrentUserDatosPerifl(name, firstName, lastName, gender, dateOfBirth);
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma) => _firebase.updateCurrentUserSettingsPerifl(isPrivate, idioma);
  Future<void> markNotificationAsRead(String userId, String notificationId) => _firebase.markNotificationAsRead(userId,notificationId);
  Future<void> markALLNotificationAsRead(String userId) => _firebase.markALLNotificationAsRead(userId);

  // Delete Data
  Future<void> deleteRequestToBrand(RequestToBrand request) => _firebase.deleteRequestToBrand(request);
  Future<void> deleteUserNickname(String nickname) => _firebase.deleteUserNickname(nickname);
  Future<void> deleteUserBonoRequest(String userId, String brandId, String bonoId) => _firebase.deleteUserBonoRequest(userId,brandId ,bonoId);

  Future<void> deleteLocalNotification(String userId, String notificationId) => _firebase.deleteLocalNotification(userId, notificationId);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  Stream<QuerySnapshot> getAllNotificationsUserStream(String userId) => _firebase.getAllNotificationsUserStream(userId);

}