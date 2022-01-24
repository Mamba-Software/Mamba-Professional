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
class DatabaseAccess {

  final _firebase = FirebaseDatabaseService();

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

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  // Events
  Stream<DocumentSnapshot> getSingleEventStream(String id) => _firebase.getSingleEventStream(id);

}