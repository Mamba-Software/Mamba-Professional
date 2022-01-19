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
class BrandDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfBrandExists(String brandID) => _firebase.checkIfBrandExists(brandID);

  // Get Data
  Future<Brand> getBrandDetails(String brandID) => _firebase.getBrandDetails(brandID);

  // Add Data
  Future<void> joinBrand(String userId, String brandId, int role) => _firebase.joinBrand(userId, brandId, role);

  // Update Data

  // Delete Data
  Future<void> leaveBrand(String userId, String brandId) => _firebase.leaveBrand(userId, brandId);

}