import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/ChatUsers.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/Question.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'firebaseDatabase.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class DatabaseAccess {

  final _firebase = FirebaseDatabaseService();

  // Users
  Future<int> signIn(String email, String password) => _firebase.signIn(email, password);
  Future<void> signOut() => _firebase.signOut();
  Future<int> resetPassword(String email) => _firebase.resetPassword(email);
  Future<bool> deleteUser(String password) => _firebase.deleteUser(password);

  Future<bool> checkCurrentUser() => _firebase.checkCurrentUser();
  Future<bool> checkIfItsMe(String uid) => _firebase.checkIfItsMe(uid);
  Future<User?> getCurrentUser() => _firebase.getCurrentUser();
  Future<Usuario> getCurrentUserDetails() => _firebase.getCurrentUserDetails();
  Future<Usuario> getUserDetails(String uid) => _firebase.getUserDetails(uid);

  Future<int> registerUser(String email, String password, String idioma) => _firebase.registerUser(email, password, idioma);
  Future<void> addUser(String uid, String name, String nick, String dateOfBirth, int gender, File? image, bool isTrainer) => _firebase.addUser(uid, name, nick, dateOfBirth, gender, image, isTrainer);
  Future<bool> checkIfAliasExists(String alias) => _firebase.checkIfAliasExists(alias);

  Future<void> updateCurrentUserFirstTime() => _firebase.updateCurrentUserFirstTime();
  Future<int> updateCurrentUserBrand(String brandID) => _firebase.updateCurrentUserBrand(brandID);
  Future<String> updateCurrentUserPhoto(File image) => _firebase.updateCurrentUserPhoto(image);
  Future<void> updateCurrentUserDatosPerifl(String name, int gender, String dateOfBirth) => _firebase.updateCurrentUserDatosPerifl(name, gender, dateOfBirth);
  Future<void> updateCurrentUserSettingsPerifl(bool isPrivate, String idioma, String previousIdioma) => _firebase.updateCurrentUserSettingsPerifl(isPrivate, idioma, previousIdioma);

  Future<void> leaveBrand(String uid) => _firebase.leaveBrand(uid);

  // Brands
  Future<String> addBrand(String name, File image, String description, List<double> workShift, int maxMembers) => _firebase.addBrand(name, image, description, workShift, maxMembers);

  Future<bool> checkIfBrandExists(String brandID) => _firebase.checkIfBrandExists(brandID);
  Future<Brand> getBrandDetails(String brandID) => _firebase.getBrandDetails(brandID);
  Future<List<Usuario>> getAllTrainersFromBrand(String brandID) => _firebase.getAllTrainersFromBrand(brandID);
  Future<List<Usuario>> getAllClientsFromBrand(String brandID) => _firebase.getAllClientsFromBrand(brandID);

  Future<void> deleteBrand(String brandId) => _firebase.deleteBrand(brandId);

  Future<String> updateCurrentBrandPhoto(String brandID, File image) => _firebase.updateCurrentBrandPhoto(brandID, image);
  Future<void> updateBrandInfo(String brandID, String name,String description, int maxMembers, List<double> workShift) => _firebase.updateBrandInfo(brandID, name, description, maxMembers, workShift);
  Future<void> updateBrandBaseLocation(String brandID, String locationID) => _firebase.updateBrandBaseLocation(brandID, locationID);

  Future<List<Brand>> getAllBrands() => _firebase.getAllBrands();

  // Errors
  Future<bool> addError(String title, String description, String stepsReproduce) => _firebase.addError(title, description, stepsReproduce);

  // Events
  Future<String> addEvent(String? brandID, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? locationId, int? maxMembers, var selectedTrainers) => _firebase.addEvent(brandID, title, description, year, month, day, hour, minute, duration, locationId, maxMembers, selectedTrainers);

  Future<void> updateEvent(String id, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? locationId, int? maxMembers, var selectedTrainers) => _firebase.updateEvent(id, title, description, year, month, day, hour, minute, duration, locationId, maxMembers, selectedTrainers);
  Future<void> updateEventCompleted(String id) => _firebase.updateEventCompleted(id);

  Future<void> deleteEvent(String id) => _firebase.deleteEvent(id);
  Future<void> deleteBrandEvents(String brandId) => _firebase.deleteBrandEvents(brandId);
  Future<void> deleteUserFromAllBrandEvents(String uid, String brandId, bool isTrainer) => _firebase.deleteUserFromAllBrandEvents(uid, brandId, isTrainer);

  Future<bool> joinEvent(String eid, String uid) => _firebase.joinEvent(eid, uid);
  Future<bool> leaveEvent(String eid, String uid, bool isTrainer) => _firebase.leaveEvent(eid, uid, isTrainer);

  Future<Event> getSingleEvent(String eventId) => _firebase.getSingleEvent(eventId);

  Future<List<Event>> getAllEventsFromClient(String clientid) => _firebase.getAllEventsFromClient(clientid);
  Future<List<Event>> getAllEventsFromTrainer(String trainerid) => _firebase.getAllEventsFromTrainer(trainerid);

  Future<List<Event>> getAllClientEventsFromBrand(String clientid, String brandId) => _firebase.getAllClientEventsFromBrand(clientid, brandId);
  Future<List<Event>> getAllTrainerEventsFromBrand(String trainerid, String brandId) => _firebase.getAllTrainerEventsFromBrand(trainerid, brandId);

  Future<List<Event>> getAllEventsTodayBrand(String brandId) => _firebase.getAllEventsTodayBrand(brandId);
  Future<List<Event>> getAllEventsTodayUser(String userid, bool isTrainer) => _firebase.getAllEventsTodayUser(userid, isTrainer);

  // Locations
  Future<String> addLocation(String brandId, bool isBaseLocation, String placeId, String description, String street, String streetNumber, String city, String zipCode, double latitude, double longitude) => _firebase.addLocation(brandId, isBaseLocation, placeId, description, street, streetNumber, city, zipCode, latitude, longitude);
  Future<void> updateLocation(String locationId, String brandId, bool isBaseLocation, String placeId, String description, String street, String streetNumber, String city, String zipCode, double latitude, double longitude) => _firebase.updateLocation(locationId, brandId, isBaseLocation, placeId, description, street, streetNumber, city, zipCode, latitude, longitude);
  Future<bool> deleteLocation(String locationId) => _firebase.deleteLocation(locationId);
  Future<void> deleteBrandLocations(String brandId) => _firebase.deleteBrandLocations(brandId);
  Future<Location> getSingleLocation(String locationId) => _firebase.getSingleLocation(locationId);

  // Locations
  Future<void> sendRequest(String brandId, String name, bool isTrainer) => _firebase.sendRequest(brandId, name, isTrainer);
  Future<void> acceptRequest(String requestId) => _firebase.acceptRequest(requestId);
  Future<void> deleteRequest(String requestId) => _firebase.deleteRequest(requestId);
  Future<RequestToBrand?> hasPendingRequest(String userId) => _firebase.hasPendingRequest(userId);

  //Questions
  Future<Question> getOneQuestion(String? id) => _firebase.getOneQuestion(id);
  Future<String> addQuestion(String? questionCat, String? questionSpn, String? type) => _firebase.addQuestion(questionCat, questionSpn, type);
  //Future<List<Question>> getAllQuestionsByType(String type) => _firebase.getAllQuestionsByType(type);

  //GroupOfQuestions
  Future<String> addGroupOfQuestions(String? questionOne, String? questionTwo, String? questionThree, String? questionFour) => _firebase.addGroupOfQuestions(questionOne, questionTwo, questionThree, questionFour);
  Future<GroupOfQuestions> getActiveGroupOfQuestions() => _firebase.getActiveGroupOfQuestions();

  //Answers
  Future<String> addAnswers(String? groupOfQuestionsID, String? answerOne, String? answerTwo, String? answerThree, String? answerFour) => _firebase.addAnswers(groupOfQuestionsID, answerOne, answerTwo, answerThree, answerFour);
  Future<bool> checkIfAnswersExist(String? groupOfQuestionsID) => _firebase.checkIfAnswersExist(groupOfQuestionsID);

  //Conversations
  Future<String> addConversation( var users, String? brandId, String? year, String? month, String? day, String? hour, String? minute, String? second, String? lastMessage) => _firebase.addConversation(users!, brandId, year, month, day, hour, minute, second, lastMessage);
  Future<void> updateConversation(String? uid, String lastMessage, String year, String month, String day, String hour, String minute, String second) => _firebase.updateConversation(uid, lastMessage, year, month, day, hour, minute, second);

  //Messages
  Future<String> addMessage(String? message, String? userSent, String? year, String? month, String? day, String? hour, String? minute,String? second, String? conversationId) => _firebase.addMessage(message, userSent, year, month, day, hour, minute, second, conversationId);

  Future<List<Conversation>> getConversationByUsers(Map<String, dynamic> currentUser, Map<String, dynamic> user) => _firebase.getConversationByUsers(currentUser, user);
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  // Users
  Stream<QuerySnapshot> getAllEventsFromUser(String userid, bool isTrainer) => _firebase.getAllEventsFromUser(userid, isTrainer);
  Stream<QuerySnapshot> getAllEventsFromBrand(String brandId) => _firebase.getAllEventsFromBrand(brandId);
  Stream<QuerySnapshot> getAllEventsTodayBrandStream(String brandId) => _firebase.getAllEventsTodayBrandStream(brandId);

  // Brands
  Stream<QuerySnapshot> getAllBrandsStream() => _firebase.getAllBrandsStream();

  // Events
  Stream<DocumentSnapshot> getSingleEventStream(String id) => _firebase.getSingleEventStream(id);

  // Locations
  Stream<QuerySnapshot> getAllLocationsBrand(String brandId) => _firebase.getAllLocationsBrand(brandId);// Locations

  // Request
  Stream<QuerySnapshot> getAllRequestsBrand(String brandId) => _firebase.getAllRequestsBrand(brandId);

  //Questions
  Stream<QuerySnapshot> getAllQuestions() => _firebase.getAllQuestions();

  //Conversations
  Stream<QuerySnapshot> getUserConversations(Map<String, dynamic> mapUser) => _firebase.getUserConversations(mapUser);

  //Messages
  Stream<QuerySnapshot> getConversationMessages(String? conversationId) => _firebase.getConversationMessages(conversationId);


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Admin
  Future<Stream<QuerySnapshot>> getAllUsers() async => await _firebase.getAllUsers();

}