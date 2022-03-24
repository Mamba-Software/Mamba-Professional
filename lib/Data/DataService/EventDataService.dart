import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Message.dart';
import 'package:mamba_castelldefels/Data/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Question.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class EventDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data

  // Get Data
  Future<Event> getSingleEvent(String eventId) => _firebase.getSingleEvent(eventId);
  Future<List<Event>> getUserEvents(String userId) => _firebase.getUserEvents(userId);
  Future<List<Event>> getUserFirstEventsLimit10(String userId) => _firebase.getUserFirstEventsLimit10(userId);
  Future<List<Event>> getUserMoreEventsLimit10(String userId, String eventId) => _firebase.getUserMoreEventsLimit10(userId, eventId);
  Future<List<Event>> getUserEventsUpcoming(String userId) => _firebase.getUserEventsUpcoming(userId);
  Future<List<Event>> getUserEventsToday(String userId) => _firebase.getUserEventsToday(userId);
  Future<List<Event>> getAllEventsTodayBrand(String brandId) => _firebase.getAllEventsTodayBrand(brandId);
  Future<List<int>> getUserEventsFinished(String userId) => _firebase.getUserEventsFinished(userId);
  Future<int> getBrandsEventsFinished(String brandId) => _firebase.getBrandsEventsFinished(brandId);
  Future<int> getBrandsEventsUpcoming(String brandId) => _firebase.getBrandsEventsUpcoming(brandId);
  Future<List<Usuario>> getEventUsers(String eventId) => _firebase.getEventUsers(eventId);
  Future<Location> getEventLocation(String eventId) => _firebase.getEventLocation(eventId);

  // Add Data
  Future<String> addEvent(String? brandID, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? locationId, int? maxMembers, var selectedTrainers) => _firebase.addEvent(brandID, title, description, year, month, day, hour, minute, duration, locationId, maxMembers, selectedTrainers);
  Future<void> addUserToEvent(String eid, String uid, [bool invitedDirectly = false]) => _firebase.addUserToEvent(eid, uid, invitedDirectly);

  // Update Data
  Future<void> updateEvent(String id, String? title, String? description, String? year, String? month, String? day, String? hour, String? minute, double? duration, String? locationId, int? maxMembers, var selectedTrainers) => _firebase.updateEvent(id, title, description, year, month, day, hour, minute, duration, locationId, maxMembers, selectedTrainers);
  Future<void> updateEventLocation(String eid, String locationId, String previousLocation) => _firebase.updateEventLocation(eid, locationId, previousLocation);

  // Delete Data
  Future<void> deleteEvent(String id) => _firebase.deleteEvent(id);
  Future<void> deleteUserFromEvent(String eid, String uid,) => _firebase.deleteUserFromEvent(eid, uid);
  Future<void> deleteUserFromUpcomingEvents(String uid, bool isTrainer) => _firebase.deleteUserFromUpcomingEvents(uid, isTrainer);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  Stream<QuerySnapshot> getUserEventsStream(String userId) => _firebase.getUserEventsStream(userId);
  Stream<QuerySnapshot> getBrandsEventsTodayStream(String brandId) => _firebase.getBrandsEventsTodayStream(brandId);


}