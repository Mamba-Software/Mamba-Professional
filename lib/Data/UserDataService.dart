import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/Message.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Models/Question.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class UserDataService {

  final _firebase = FirebaseDatabaseService();

  // Users
  Future<int> signIn(String email, String password) => _firebase.signIn(email, password);
  Future<void> signOut() => _firebase.signOut();
  Future<int> resetPassword(String email) => _firebase.resetPassword(email);
  Future<bool> deleteUser(String password) => _firebase.deleteUser(password);

  Future<User?> getCurrentUser() => _firebase.getCurrentUser();
  Future<Usuario> getUserDetails(String uid) => _firebase.getUserDetails(uid);
  Future<List<String>> getUserCover(String uid) => _firebase.getUserCover(uid);

  Future<int> registerUser(String email, String password, String idioma) => _firebase.registerUser(email, password, idioma);
  Future<void> addUser(String uid, String name, String firstName, String lastName, String nick, String dateOfBirth, int gender, File? image, bool isTrainer) => _firebase.addUser(uid, name, firstName, lastName, nick, dateOfBirth, gender, image, isTrainer);
  Future<void> addUserNotificationToken(String uid, String token) => _firebase.addUserNotificationToken(uid, token);
  Future<bool> checkIfAliasExists(String alias) => _firebase.checkIfAliasExists(alias);

  Future<void> updateCurrentUserFirstTime() => _firebase.updateCurrentUserFirstTime();
  Future<String> updateCurrentUserPhoto(File image) => _firebase.updateCurrentUserPhoto(image);
  Future<void> updateCurrentUserDatosPerifl(String name, String firstName, String lastName, int gender, String dateOfBirth) => _firebase.updateCurrentUserDatosPerifl(name, firstName, lastName, gender, dateOfBirth);
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma, String previousIdioma) => _firebase.updateCurrentUserSettingsPerifl(isPrivate, idioma, previousIdioma);

  Future<int> updateCurrentUserBrand(String brandID) => _firebase.updateCurrentUserBrand(brandID);
  Future<void> leaveBrandUser(String userId) => _firebase.leaveBrandUser(userId);

  Future<void> joinBrand(String userId, String brandId, int role) => _firebase.joinBrand(userId, brandId, role);
  Future<void> leaveBrand(String userId, String brandId) => _firebase.leaveBrand(userId, brandId);
}