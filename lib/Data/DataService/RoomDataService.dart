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
class RoomDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data

  // Get Data

  // Add Data

  // Update Data
  Future<void> updateRoom(String? roomId, Map<String, dynamic> metadata) => _firebase.updateRoom(roomId, metadata);
  Future<void> updateRoomLastMessage(String? roomId, var lastMessages) => _firebase.updateRoomLastMessage(roomId, lastMessages);

  // Delete Data
  Future<void> deleteRoom(String roomId) => _firebase.deleteRoom(roomId);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Streams


}