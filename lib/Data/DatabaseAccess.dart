import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
class DatabaseAccess {

  final _firebase = FirebaseDatabaseService();

  Future<void> leaveBrandUser(String userId) => _firebase.leaveBrandUser(userId);

  Future<void> deleteUserFromBrand(String userId, String brandId) => _firebase.deleteUserFromBrand(userId, brandId);

  // Brands
  Future<bool> checkIfBrandExists(String brandID) => _firebase.checkIfBrandExists(brandID);
  Future<Brand?> checkUserIsBrandCreator(String userId) => _firebase.checkUserIsBrandCreator(userId);
  Future<Brand> getBrandDetails(String brandID) => _firebase.getBrandDetails(brandID);
  Future<List<String>> getBrandCover(String brandID) => _firebase.getBrandCover(brandID);
  Future<List<Usuario>> getAllTrainersFromBrand(String brandID) => _firebase.getAllTrainersFromBrand(brandID);
  Future<List<Usuario>> getAllClientsFromBrand(String brandID) => _firebase.getAllClientsFromBrand(brandID);

  Future<void> deleteBrand(String brandId) => _firebase.deleteBrand(brandId);

  Future<String> updateCurrentBrandPhoto(String brandID, File image) => _firebase.updateCurrentBrandPhoto(brandID, image);
  Future<void> updateBrandInfo(String brandID, String name,String description, int maxMembers, List<double> workShift) => _firebase.updateBrandInfo(brandID, name, description, maxMembers, workShift);


  Future<List<Brand>> getAllBrands() => _firebase.getAllBrands();

  // Errors
  Future<bool> addError(String title, String description, String stepsReproduce) => _firebase.addError(title, description, stepsReproduce);

  // Events
  Future<String> addEvent(String? brandID, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? locationId, int? maxMembers, var selectedTrainers) => _firebase.addEvent(brandID, title, description, year, month, day, hour, minute, duration, locationId, maxMembers, selectedTrainers);

  Future<void> updateEvent(String id, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? locationId, int? maxMembers, var selectedTrainers) => _firebase.updateEvent(id, title, description, year, month, day, hour, minute, duration, locationId, maxMembers, selectedTrainers);
  Future<void> updateEventTrainers(String eid, var selectedTrainers) => _firebase.updateEventTrainers(eid, selectedTrainers);
  Future<void> updateEventClients(String eid, var joinedMembers) => _firebase.updateEventClients(eid, joinedMembers);
  Future<void> updateEventLocation(String eventId, String locationId) => _firebase.updateEventLocation(eventId, locationId);
  Future<void> updateEventCompleted(String id) => _firebase.updateEventCompleted(id);

  Future<void> deleteEvent(String id) => _firebase.deleteEvent(id);
  Future<void> deleteBrandEvents(String brandId) => _firebase.deleteBrandEvents(brandId);
  Future<void> deleteUserFromAllBrandEvents(String uid, String brandId, bool isTrainer) => _firebase.deleteUserFromAllBrandEvents(uid, brandId, isTrainer);

  Future<bool> joinEvent(String eid, String uid) => _firebase.joinEvent(eid, uid);
  Future<bool> leaveEvent(String eid, String uid, bool isTrainer) => _firebase.leaveEvent(eid, uid, isTrainer);

  Future<Event> getSingleEvent(String eventId) => _firebase.getSingleEvent(eventId);
  Future<List<Event>> getAllEventsWithLocationId(String locationId) => _firebase.getAllEventsWithLocationId(locationId);

  Future<List<Event>> getAllEventsFromClient(String clientid) => _firebase.getAllEventsFromClient(clientid);
  Future<List<Event>> getAllEventsFromTrainer(String trainerid) => _firebase.getAllEventsFromTrainer(trainerid);

  Future<List<Event>> getAllClientEventsFromBrand(String clientid, String brandId) => _firebase.getAllClientEventsFromBrand(clientid, brandId);
  Future<List<int>> getAllClientEventsFinished(String clientid, String brandId) => _firebase.getAllClientEventsFinished(clientid, brandId);

  Future<List<Event>> getAllTrainerEventsFromBrand(String trainerid, String brandId) => _firebase.getAllTrainerEventsFromBrand(trainerid, brandId);
  Future<List<int>> getAllTrainerEventsFinished(String trainerid, String brandId) => _firebase.getAllTrainerEventsFinished(trainerid, brandId);

  Future<int> getNumberEventsFinishedBrand(String brandId) => _firebase.getNumberEventsFinishedBrand(brandId);
  Future<int> getNumberEventsToDoBrand(String brandId) => _firebase.getNumberEventsToDoBrand(brandId);

  Future<List<Event>> getAllEventsTodayBrand(String brandId) => _firebase.getAllEventsTodayBrand(brandId);
  Future<List<Event>> getAllEventsTodayUser(String userid, bool isTrainer) => _firebase.getAllEventsTodayUser(userid, isTrainer);

  // Locations
  Future<String> addLocation(String brandId, bool isBaseLocation, String placeId, String description, String street, String streetNumber, String city, String zipCode, double latitude, double longitude) => _firebase.addLocation(brandId, isBaseLocation, placeId, description, street, streetNumber, city, zipCode, latitude, longitude);
  Future<void> updateLocation(String locationId, String brandId, bool isBaseLocation, String placeId, String description, String street, String streetNumber, String city, String zipCode, double latitude, double longitude) => _firebase.updateLocation(locationId, brandId, isBaseLocation, placeId, description, street, streetNumber, city, zipCode, latitude, longitude);
  Future<bool> deleteLocation(String locationId, String baseLocation) => _firebase.deleteLocation(locationId, baseLocation);
  Future<void> deleteBrandLocations(String brandId) => _firebase.deleteBrandLocations(brandId);
  Future<Location> getSingleLocation(String locationId) => _firebase.getSingleLocation(locationId);

  //Questions
  Future<Question> getOneQuestion(String? id) => _firebase.getOneQuestion(id);
  Future<String> addQuestion(String? questionCat, String? questionSpn, String? type) => _firebase.addQuestion(questionCat, questionSpn, type);
  //Future<List<Question>> getAllQuestionsByType(String type) => _firebase.getAllQuestionsByType(type);

  //GroupOfQuestions
  Future<String> addGroupOfQuestions(String? questionOne, String? questionTwo, String? questionThree, String? questionFour) => _firebase.addGroupOfQuestions(questionOne, questionTwo, questionThree, questionFour);
  Future<GroupOfQuestions?> getActiveGroupOfQuestions() => _firebase.getActiveGroupOfQuestions();

  //Answers
  Future<String> addAnswers(String? groupOfQuestionsID, String? answerOne, String? answerTwo, String? answerThree, String? answerFour) => _firebase.addAnswers(groupOfQuestionsID, answerOne, answerTwo, answerThree, answerFour);
  Future<bool> checkIfAnswersExist(String? groupOfQuestionsID) => _firebase.checkIfAnswersExist(groupOfQuestionsID);

  //Conversations
  Future<int> getUnreadConversations(String userId) => _firebase.getUnreadConversations(userId);
  Future<String> addConversation( var users, var messagesRead, String? brandId, String? year, String? month, String? day, String? hour, String? minute, String? second, String? lastMessage) => _firebase.addConversation(users!, messagesRead, brandId, year, month, day, hour, minute, second, lastMessage);
  Future<void> updateConversation(String? uid, var messagesRead, String lastMessage, String year, String month, String day, String hour, String minute, String second) => _firebase.updateConversation(uid, messagesRead, lastMessage, year, month, day, hour, minute, second);
  Future<void> updateConversationUsers(String? uid, var users) => _firebase.updateConversationUsers(uid, users);
  Future<void> updateConversationNewUser(String? brandId, String? userId) => _firebase.updateConversationNewUser(brandId, userId);
  Future<void> updateReadMessage(String? uid, var messagesRead) => _firebase.updateReadMessage(uid, messagesRead);
  Future<void> deleteUserMemberConversations(Map<String, dynamic> currentUser) => _firebase.deleteUserMemberConversations(currentUser);
  Future<void> deleteBrandConversations(String? brandId) => _firebase.deleteBrandConversations(brandId);
  //Messages
  Future<String> addMessage(String? message, String? userSent, String? year, String? month, String? day, String? hour, String? minute,String? second, String? conversationId) => _firebase.addMessage(message, userSent, year, month, day, hour, minute, second, conversationId);
  Future<List<Message>> getConversationMessagesInit(String? conversationId) => _firebase.getConversationMessagesInit(conversationId);
  Future<String?> getLastUserMessageSent(String? conversationId) => _firebase.getLastUserMessageSent(conversationId);

  Future<List<Conversation>> getConversationByUsers(Map<String, dynamic> currentUser, Map<String, dynamic> user) => _firebase.getConversationByUsers(currentUser, user);

  Future<Conversation> getConversationByBrand(String? brandId) => _firebase.getConversationByBrand(brandId);
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  //Conversations
  Stream<QuerySnapshot> getUserConversations(Map<String, dynamic> mapUser) => _firebase.getUserConversations(mapUser);

  //Messages
  Stream<QuerySnapshot> getConversationMessages(String? conversationId) => _firebase.getConversationMessages(conversationId);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Admin
  Future<Stream<QuerySnapshot>> getAllUsers() async => await _firebase.getAllUsers();

}