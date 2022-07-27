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
class LocationDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data

  // Get Data
  Future<Location> getSingleLocation(String locationId) => _firebase.getSingleLocation(locationId);
  Future<List<Location>> getAllBrandLocations(String locationId) => _firebase.getAllBrandLocations(locationId);

  // Add Data
  Future<String> addLocation(String brandId, bool isBaseLocation, String placeId, String description, String street, String streetNumber, String city, String zipCode, double latitude, double longitude) => _firebase.addLocation(brandId, isBaseLocation, placeId, description, street, streetNumber, city, zipCode, latitude, longitude);

  // Update Data
  Future<void> updateLocation(String locationId, String brandId, bool isBaseLocation, String placeId, String description, String street, String streetNumber, String city, String zipCode, double latitude, double longitude) => _firebase.updateLocation(locationId, brandId, isBaseLocation, placeId, description, street, streetNumber, city, zipCode, latitude, longitude);
  Future<void> updateBrandBaseLocation(String brandID, String locationID) => _firebase.updateBrandBaseLocation(brandID, locationID);

  // Delete Data
  Future<bool> deleteLocation(String locationId, String baseLocation) => _firebase.deleteLocation(locationId, baseLocation);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams

  Stream<QuerySnapshot> getAllLocationsBrand(String brandId) => _firebase.getAllLocationsBrand(brandId);


}