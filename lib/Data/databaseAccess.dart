import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'firebaseDatabase.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class DatabaseAccess {

  final _firebase = FirebaseDatabaseService();

  // Users
  Future<int> signIn(String email, String password) => _firebase.signIn(email, password);
  Future<void> signOut() => _firebase.signOut();
  Future<void> resetPassword(String email) => _firebase.resetPassword(email);
  Future<bool> deleteUser(String password) => _firebase.deleteUser(password);

  Future<bool> checkCurrentUser() => _firebase.checkCurrentUser();
  Future<bool> checkIfItsMe(String uid) => _firebase.checkIfItsMe(uid);
  Future<User?> getCurrentUser() => _firebase.getCurrentUser();
  Future<Usuario> getCurrentUserDetails() => _firebase.getCurrentUserDetails();

  Future<int> addUser(String email, String password, String name, bool isTrainer, int gender, String idioma) => _firebase.addUser(email, password, name, isTrainer, gender, idioma);

  Future<void> updateCurrentUserFirstTime() => _firebase.updateCurrentUserFirstTime();
  Future<int> updateCurrentUserBrand(String brandID) => _firebase.updateCurrentUserBrand(brandID);
  Future<void> updateCurrentUserPhoto(File image) => _firebase.updateCurrentUserPhoto(image);
  Future<void> updateCurrentUserDatosPerifl(String name, int gender, String dateOfBirth) => _firebase.updateCurrentUserDatosPerifl(name, gender, dateOfBirth);
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma, String previousIdioma) => _firebase.updateCurrentUserSettingsPerifl(isPrivate, idioma, previousIdioma);

  // Brands
  Future<String> addBrand(String name, File image, String description, String placeId, String address, double latitude, double longitude, List<double> workShift) => _firebase.addBrand(name, image, description, placeId, address, latitude, longitude, workShift);

  Future<bool> checkIfBrandExists(String brandID) => _firebase.checkIfBrandExists(brandID);
  Future<Brand> getCurrentBrandDetails(String brandID) => _firebase.getCurrentBrandDetails(brandID);

  Future<void> updateCurrentBrandPhoto(String brandID,File image) => _firebase.updateCurrentBrandPhoto(brandID, image);

  // Errors
  Future<bool> addError(String title, String description, String stepsReproduce) => _firebase.addError(title, description, stepsReproduce);

  // Events
  Future<String> addEvent(String? brandID, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? placeId, int? maxMembers) => _firebase.addEvent(brandID, title, description, year, month, day, hour, minute, duration, placeId, maxMembers);

  Future<Event> getSingleEvent(String id) => _firebase.getSingleEvent(id);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  // Brands
  Stream<QuerySnapshot> getAllBrands() => _firebase.getAllBrands();

  // Events
  Stream<QuerySnapshot> getAllEventsFromBrand() => _firebase.getAllEventsFromBrand();

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Admin
  Future<Stream<QuerySnapshot>> getAllUsers() async => await _firebase.getAllUsers();
}