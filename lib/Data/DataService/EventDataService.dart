import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Message.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Question.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class EventDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfEventExists(String eventId) => _firebase.checkIfEventExists(eventId);

  // Get Data
  Future<Event> getSingleEvent(String eventId) => _firebase.getSingleEvent(eventId);
  Future<List<Event>> getUserEvents(String userId) => _firebase.getUserEvents(userId);
  Future<List<Event>> getUserFirstCompletedEventsLimit(String userId, int limit) => _firebase.getUserFirstCompletedEventsLimit(userId, limit);
  Future<List<Event>> getUserMoreCompletedEventsLimit(String userId, String eventId, int limit) => _firebase.getUserMoreCompletedEventsLimit(userId, eventId, limit);
  Future<List<Event>> getUserEventsUpcoming(String userId) => _firebase.getUserEventsUpcoming(userId);
  Future<List<Event>> getUserEventsToday(String userId) => _firebase.getUserEventsToday(userId);

  Future<List<Event>> getAllEventsTodayBrand(String brandId) => _firebase.getAllEventsTodayBrand(brandId);
  Future<List<Event>> getBrandEventsThisMonth(String brandId) => _firebase.getBrandEventsThisMonth(brandId);
  Future<List<int>> getUserEventsFinished(String userId) => _firebase.getUserEventsFinished(userId);
  Future<int> getBrandsEventsFinished(String brandId) => _firebase.getBrandsEventsFinished(brandId);
  Future<int> getBrandsEventsUpcoming(String brandId) => _firebase.getBrandsEventsUpcoming(brandId);
  Future<List<Usuario>> getEventUsers(String eventId) => _firebase.getEventUsers(eventId);
  Future<Location> getEventLocation(String eventId) => _firebase.getEventLocation(eventId);
  Future<List<Brand>> getEventBrands(String eventId) => _firebase.getEventBrands(eventId);
  Future<double?> getEventUserFeedback(String eventId, String userId) => _firebase.getEventUserFeedback(eventId, userId);

  Future<dynamic> getRecurrentEventGroup(String eventGroupId) => _firebase.getRecurrentEventGroup(eventGroupId);

  // Add Data
  Future<String> addEvent(Event event) => _firebase.addEvent(event);
  Future<void> addRecurrentEventGroup(String eventGroupId, List<String> eventIds) => _firebase.addRecurrentEventGroups(eventGroupId, eventIds);
  Future<void> addUserToEvent(String eid, String uid, [bool invitedDirectly = false]) => _firebase.addUserToEvent(eid, uid, invitedDirectly);
  Future<void> addEventFeedback(String eid, String uid, double intensityScore) => _firebase.addEventFeedback(eid, uid, intensityScore);

  // Update Data
  Future<void> updateEvent(Event event) => _firebase.updateEvent(event);
  Future<void> updateEventNumberMembers(String eventId, int numberClients, int numberTrainers) => _firebase.updateEventNumberMembers(eventId, numberClients, numberTrainers);
  Future<void> updateRecurrentEventGroup(String eventGroupId, var eventIds) => _firebase.updateRecurrentEventGroup(eventGroupId, eventIds);
  Future<void> updateEventLocation(String eid, String locationId, String previousLocation) => _firebase.updateEventLocation(eid, locationId, previousLocation);

  // Delete Data
  Future<void> deleteEvent(String id, [bool isPrivate = false]) => _firebase.deleteEvent(id, isPrivate);
  Future<void> deleteUserFromEvent(String eid, String uid,) => _firebase.deleteUserFromEvent(eid, uid);
  Future<void> deleteUserFromUpcomingEvents(String uid, bool isTrainer) => _firebase.deleteUserFromUpcomingEvents(uid, isTrainer);
  Future<void> deleteRecurrentEventGroup(String eventGroupId) => _firebase.deleteRecurrentEventGroup(eventGroupId);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  Stream<QuerySnapshot> getUserEventsStream(String userId) => _firebase.getUserEventsStream(userId);

  Stream<QuerySnapshot> getBrandEventsStream(String brandId) => _firebase.getBrandEventsStream(brandId);

  Stream<QuerySnapshot> getBrandsEventsTodayStream(String brandId) => _firebase.getBrandsEventsTodayStream(brandId);


}