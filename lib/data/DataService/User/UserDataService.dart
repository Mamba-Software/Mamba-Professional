import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/data/DataService/User/UserFirebaseCalls.dart';
import 'package:mamba_castelldefels/data/Models/Bono.dart';
import 'package:mamba_castelldefels/data/Models/Brand.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/data/Models/Purchase.dart';
import 'package:mamba_castelldefels/data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/data/Models/Usuario.dart';

// This class gives access to all of the Firebase Backend of the User Object.
class UserDataService {
  final _firebase = UserFirebaseCalls();

  // Authentication
  Future<User?> getCurrentUser() => _firebase.getCurrentUser();
  Future<String?> getUserUIDWithEmail(String email) =>
      _firebase.getUserUIDWithEmail(email);
  Future<int> signIn(String email, String password) =>
      _firebase.signIn(email, password);
  Future<void> signOut() => _firebase.signOut();
  Future<int> resetPassword(String email) => _firebase.resetPassword(email);
  Future<int> resendEmail(String email) => _firebase.resendEmail(email);
  Future<bool> deleteUser(String password) => _firebase.deleteUser(password);
  Future<bool> deleteUserGoogle() => _firebase.deleteUserGoogle();

  // Check Data
  Future<bool> checkIfUserExists(String uid) =>
      _firebase.checkIfUserExists(uid);
  Future<bool> checkIfEmailExists(String email) =>
      _firebase.checkIfEmailExists(email);
  Future<bool> checkIfNicknameExists(String nickname) =>
      _firebase.checkIfNicknameExists(nickname);
  Future<bool?> checkIfUserIsTrainer(String userId) =>
      _firebase.checkIfUserIsTrainer(userId);
  Future<bool> checkUserBlocked(String currentUser, String userId) =>
      _firebase.checkUserBlocked(currentUser, userId);

  // Get Data
  Future<Usuario> getUserDetails(String userId) =>
      _firebase.getUserDetails(userId);
  Future<Brand?> getUserBrands(String userId) =>
      _firebase.getUserBrands(userId);
  Future<Brand?> getUserBrandsToAdd(String userId, String brandId) =>
      _firebase.getUserBrandsToAdd(userId, brandId);
  Future<Usuario> getUserCoverDetails(String userId) =>
      _firebase.getUserCoverDetails(userId);
  Future<List<RequestToBrand>> getUserRequests(String userId) =>
      _firebase.getUserRequests(userId);
  Future<List<NotificationEvent>> getUserFirstNotificationsLimit10(
          String userId) =>
      _firebase.getUserFirstNotificationsLimit10(userId);
  Future<List<NotificationEvent>> getUserMoreNotificationsLimit10(
          String userId, String notifId) =>
      _firebase.getUserMoreNotificationsLimit10(userId, notifId);
  Future<int> getUnreadNotifications(String userId) =>
      _firebase.getUnreadNotifications(userId);
  Future<int> getUnreadConversations(String userId) =>
      _firebase.getUnreadConversations(userId);
  Future<String> getBonoRequest(String userId, String brandId) =>
      _firebase.getBonoRequest(userId, brandId);
  Future<List<int>> getUserFavourites(String brandId, String userId) =>
      _firebase.getUserFavourites(brandId, userId);
  Future<double> getUserZoomScale(String brandId, String userId) =>
      _firebase.getUserZoomScale(brandId, userId);
  Future<List<ReceivedNotification>> getLocalNotifications(String userId) =>
      _firebase.getLocalNotifications(userId);
  Future<ReceivedNotification?> getIndividualLocalNotification(
          String userId, String notificationId) =>
      _firebase.getIndividualLocalNotification(userId, notificationId);
  Future<List<ReceivedNotification>> findEventLocalNotification(
          String userId, String eventId) =>
      _firebase.findEventLocalNotification(userId, eventId);
  Future<List<ReceivedNotification>> findBonoLocalNotification(
          String userId, String bonoId, String purchaseId) =>
      _firebase.findBonoLocalNotification(userId, bonoId, purchaseId);
  Future<List<Bono>> getUserActiveBonosFromBrand(
          String userId, String brandId) =>
      _firebase.getUserActiveBonosFromBrand(userId, brandId);
  Future<Event> getLastUserEvent(String? userId) =>
      _firebase.getLastUserEvent(userId);
  Future<List<String>> getBlockedByUsers(String userId) =>
      _firebase.getBlockedByUsers(userId);
  Future<List<Bono>> getUserActiveBonos(String userId, String purchaseId) =>
      _firebase.getUserActiveBonos(userId, purchaseId);
  Future<String> getUserActiveSessions(String userId) =>
      _firebase.getUserActiveSessions(userId);

  // Add Data
  Future<int> addUser(
          String email, String password, String idioma, bool isTrainer,
          [bool definePassword = false]) =>
      _firebase.addUser(email, password, idioma, isTrainer, definePassword);
  Future<bool> addUserGoogleOrApple(UserCredential authResult, String idioma) =>
      _firebase.addUserGoogleOrApple(authResult, idioma);
  Future<void> addUserNickname(String userId, String nickname) =>
      _firebase.addUserNickname(userId, nickname);
  Future<void> addLocalNotification(
          String userId, ReceivedNotification notification) =>
      _firebase.addLocalNotification(userId, notification);
  Future<void> sendNotificationToUser(
          String userId, String type, var parameters) =>
      _firebase.sendNotificationToUser(userId, type, parameters);
  Future<void> sendRequestToBrand(
          String brandId, String name, bool isTrainer) =>
      _firebase.sendRequestToBrand(brandId, name, isTrainer);
  Future<void> addBonoRequestToUser(
          String brandId, String userId, String bonoId) =>
      _firebase.addBonoRequestToUser(brandId, userId, bonoId);
  Future<void> addBonoToUser(String brandId, String userId, String bonoId,
          int sessions, Timestamp time) =>
      _firebase.addBonoToUser(brandId, userId, bonoId, sessions, time);
  Future<void> addFavouriteToUser(
          String brandId, String userId, List<int> favourites) =>
      _firebase.addFavouriteToUser(brandId, userId, favourites);
  Future<void> addUserBlocked(String currentUser, String userId) =>
      _firebase.addUserBlocked(currentUser, userId);

  // Update Data
  Future<void> updateUser(
          String uid,
          String name,
          String firstName,
          String lastName,
          String dateOfBirth,
          int gender,
          File? image,
          String? googleImageUrl,
          bool isTrainer) =>
      _firebase.updateUser(uid, name, firstName, lastName, dateOfBirth, gender,
          image, googleImageUrl, isTrainer);
  Future<void> updateUserThemePreferences(String uid, bool? isDark) =>
      _firebase.updateUserThemePreferences(uid, isDark);
  Future<void> updateUserNotificationToken(String uid, String token) =>
      _firebase.updateUserNotificationToken(uid, token);
  Future<void> updateCurrentUserFirstTime() =>
      _firebase.updateCurrentUserFirstTime();
  Future<String> updateUserPhoto(String uid, File image) =>
      _firebase.updateUserPhoto(uid, image);
  Future<void> updateCurrentUserDatosPerifl(String name, String firstName,
          String lastName, int gender, String dateOfBirth) =>
      _firebase.updateCurrentUserDatosPerifl(
          name, firstName, lastName, gender, dateOfBirth);
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma) =>
      _firebase.updateCurrentUserSettingsPerifl(isPrivate, idioma);
  Future<void> markNotificationAsRead(String userId, String notificationId) =>
      _firebase.markNotificationAsRead(userId, notificationId);
  Future<void> markALLNotificationAsRead(String userId) =>
      _firebase.markALLNotificationAsRead(userId);
  Future<void> updateUserPurchase(
          String userId, String brandId, Bono bono, Purchase purchase) =>
      _firebase.updateUserPurchase(userId, brandId, bono, purchase);
  Future<void> updateUserZoomScale(
          String userId, String brandId, double zoomScale) =>
      _firebase.updateUserZoomScale(brandId, userId, zoomScale);
  Future<void> activateUserBono(
          String userId, String brandId, String bonoId, String purchaseId) =>
      _firebase.activateUserBono(userId, brandId, bonoId, purchaseId);

  // Delete Data
  Future<void> deleteRequestToBrand(RequestToBrand request) =>
      _firebase.deleteRequestToBrand(request);
  Future<void> deleteUserNickname(String nickname) =>
      _firebase.deleteUserNickname(nickname);
  Future<void> deleteUserBonoRequest(
          String userId, String brandId, String bonoId) =>
      _firebase.deleteUserBonoRequest(userId, brandId, bonoId);
  Future<void> deleteUserBono(
          String userId, String brandId, String bonoId, String purchaseId) =>
      _firebase.deleteUserBono(userId, brandId, bonoId, purchaseId);
  Future<void> deleteLocalNotification(String userId, String notificationId) =>
      _firebase.deleteLocalNotification(userId, notificationId);
  Future<void> deleteUserBlocked(String currentUser, String userId) =>
      _firebase.deleteUserBlocked(currentUser, userId);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  Stream<QuerySnapshot> getAllNotificationsUserStream(String userId) =>
      _firebase.getAllNotificationsUserStream(userId);

  Stream<QuerySnapshot> getUserActivePurchasesFromBrandStream(
          String userId, String brandId) =>
      _firebase.getUserActivePurchasesFromBrandStream(userId, brandId);

  Stream<DocumentSnapshot> getBonoFromEventUser(String userId, String bonoId) =>
      _firebase.getBonoFromEventUser(userId, bonoId);

  // Purchases
  Stream<QuerySnapshot> getUserBrandPurchasesStream(
          String userId, String brandId) =>
      _firebase.getUserBrandPurchasesStream(userId, brandId);

  //Unread

  Stream<List<int>> getCombinedUnreadStreams(String userId) =>
      _firebase.getCombinedUnreadStreams(userId);
}
