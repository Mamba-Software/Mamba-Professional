import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Conversation.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Message.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Deprecated/Question.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import '../FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class EventDataService {
  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfEventExists(String eventId) =>
      _firebase.checkIfEventExists(eventId);

  // Get Data
  Future<Event> getSingleEvent(String eventId) =>
      _firebase.getSingleEvent(eventId);
  Future<List<Event>> getUserEvents(String userId) =>
      _firebase.getUserEvents(userId);
  Future<List<Event>> getUserFirstCompletedEventsLimit(
          String userId, int limit) =>
      _firebase.getUserFirstCompletedEventsLimit(userId, limit);
  Future<List<Event>> getUserMoreCompletedEventsLimit(
          String userId, String eventId, int limit) =>
      _firebase.getUserMoreCompletedEventsLimit(userId, eventId, limit);
  Future<List<Event>> getUserEventsUpcoming(String userId) =>
      _firebase.getUserEventsUpcoming(userId);
  Future<List<Event>> getUserEventsToday(String userId) =>
      _firebase.getUserEventsToday(userId);

  Future<List<Event>> getAllEventsTodayBrand(String brandId) =>
      _firebase.getAllEventsTodayBrand(brandId);
  Future<List<Event>> getBrandEventsThisMonth(String brandId) =>
      _firebase.getBrandEventsThisMonth(brandId);
  Future<List> getUserEventsStats(String userId) =>
      _firebase.getUserEventsStats(userId);
  Future<List<int>> getUserEventsFinished(String userId) =>
      _firebase.getUserEventsFinished(userId);
  Future<List<Event>> getBrandsEventsFinished(String brandId) =>
      _firebase.getBrandsEventsFinished(brandId);
  Future<int> getBrandsEventsUpcoming(String brandId) =>
      _firebase.getBrandsEventsUpcoming(brandId);
  Future<List<Usuario>> getEventUsers(String eventId) =>
      _firebase.getEventUsers(eventId);
  Future<Location> getEventLocation(String eventId) =>
      _firebase.getEventLocation(eventId);
  Future<List<Event>> getBrandFirstCompletedEventsLimit(
          String brandId, int limit) =>
      _firebase.getBrandFirstCompletedEventsLimit(brandId, limit);
  Future<List<Event>> getBrandMoreCompletedEventsLimit(
          String brandId, String eventId, int limit) =>
      _firebase.getBrandMoreCompletedEventsLimit(brandId, eventId, limit);
  Future<List<Brand>> getEventBrands(String eventId) =>
      _firebase.getEventBrands(eventId);
  Future<double?> getEventUserFeedback(String eventId, String userId) =>
      _firebase.getEventUserFeedback(eventId, userId);
  Future<double?> getEventAverageUserFeedback(String eventId) =>
      _firebase.getEventAverageUserFeedback(eventId);
  Future<dynamic> getRecurrentEventGroup(String eventGroupId) =>
      _firebase.getRecurrentEventGroup(eventGroupId);
  Future<List<Bono>> getEventBonos(String eventId, String brandId) =>
      _firebase.getEventBonos(eventId, brandId);

  // Add Data
  Future<String> addEvent(Event event) => _firebase.addEvent(event);
  Future<void> addRecurrentEventGroup(
          String eventGroupId, List<String> eventIds) =>
      _firebase.addRecurrentEventGroups(eventGroupId, eventIds);
  Future<void> addUserToEvent(String eid, String uid, String purchaseId,
          [bool invitedDirectly = false]) =>
      _firebase.addUserToEvent(eid, uid, purchaseId, invitedDirectly);
  Future<void> addEventFeedback(
          String eid, String uid, double intensityScore) =>
      _firebase.addEventFeedback(eid, uid, intensityScore);
  Future<void> addEventToPurchase(String purchaseId, Event event) =>
      _firebase.addEventToPurchase(purchaseId, event);
  Future<void> addEventBonos(String eventId, List<String> bonoIds) =>
      _firebase.addEventBonos(eventId, bonoIds);
  Future<void> addEventBonosObject(String eventId, List<Bono> bonos) =>
      _firebase.addEventBonosObject(eventId, bonos);
  Future<int> addEventRecurrent(
          Event _event, List<String> bonos, List<String> trainers) =>
      _firebase.addEventRecurrent(_event, bonos, trainers);

  // Update Data
  Future<void> updateEvent(Event event) => _firebase.updateEvent(event);
  Future<void> updateEventNumberMembers(
          String eventId, int numberClients, int numberTrainers) =>
      _firebase.updateEventNumberMembers(
          eventId, numberClients, numberTrainers);
  Future<void> updateRecurrentEventGroup(String eventGroupId, var eventIds) =>
      _firebase.updateRecurrentEventGroup(eventGroupId, eventIds);
  Future<void> updateEventLocation(
          String eid, String locationId, String previousLocation) =>
      _firebase.updateEventLocation(eid, locationId, previousLocation);
  Future<void> updateEventBonos(String eventId, List<String> bonoIds) =>
      _firebase.updateEventBonos(eventId, bonoIds);
  Future<void> updateEventBonosObject(String eventId, List<Bono> bonos) =>
      _firebase.updateEventBonosObject(eventId, bonos);
  Future<void> updateEventUserPurchase(
          String eventId, String userId, String purchaseId) =>
      _firebase.updateEventUserPurchase(eventId, userId, purchaseId);

  // Delete Data
  Future<void> deleteEvent(String id, [bool isPrivate = false]) =>
      _firebase.deleteEvent(id, isPrivate);
  Future<void> deleteUserFromEvent(
    String eid,
    String uid,
  ) =>
      _firebase.deleteUserFromEvent(eid, uid);
  Future<void> deleteUserFromUpcomingEvents(String uid, bool isTrainer) =>
      _firebase.deleteUserFromUpcomingEvents(uid, isTrainer);
  Future<void> deleteRecurrentEventGroup(String eventGroupId) =>
      _firebase.deleteRecurrentEventGroup(eventGroupId);
  Future<void> deleteEventBonos(String eventId) =>
      _firebase.deleteEventBonos(eventId);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  Stream<QuerySnapshot> getUserEventsStream(String userId) =>
      _firebase.getUserEventsStream(userId);

  Stream<QuerySnapshot> getUserEventsTodayStream(String userId) =>
      _firebase.getUserEventsTodayStream(userId);

  Stream<QuerySnapshot> getBrandEventsStream(String brandId) =>
      _firebase.getBrandEventsStream(brandId);

  Stream<QuerySnapshot> getBrandUpcomingEventsStream(String brandId) =>
      _firebase.getBrandUpcomingEventsStream(brandId);

  Stream<QuerySnapshot> getBrandsEventsTodayStream(String brandId) =>
      _firebase.getBrandsEventsTodayStream(brandId);
}
