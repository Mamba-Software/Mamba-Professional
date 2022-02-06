import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

// Firebase collections
String users = isProduction ? 'Users' : '7777 Users';
String nicknames = isProduction ? 'Nicknames' : '7777 Nicknames';
String brands = isProduction ? 'Brands' : '7777 Brands';
String events = isProduction ? 'Events' : '7777 Events';
String locations = isProduction ? 'Locations' : '7777 Locations';
String groupOfQuestions = isProduction ? 'GroupOfQuestions' : '7777 GroupOfQuestions';
String questions = isProduction ? 'Questions' : '7777 Questions';
String answers = isProduction ? 'Answers' : '7777 Answers';
String conversations = isProduction ? 'Conversations' : '7777 Conversations';
String messages = isProduction ? 'Messages' : '7777 Messages';
String errors = isProduction ? 'Errors' : '7777 Errors';
String requests = isProduction ? 'Requests' : '7777 Requests';
String notifications = isProduction ? 'Notifications' : '7777 Notifications';
String rooms = isProduction ? 'Rooms' : '7777 Rooms';

Future<void> main() async {
  await Firebase.initializeApp();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  print('\n-----------------------------');
  print('DATA MIGRATION 6TH FEBRUARY 2022');
  print('-----------------------------\n');

  print('Modifying '+users+' collection:\n');

  print('Updating "firstName" and "lastName" ...');
  QuerySnapshot querySnapshot = await _firestore.collection(users).get();
  for (int i = 0; i < querySnapshot.docs.length; i++) {
    Usuario user = Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
    print(user.name!);
  }




}