import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/ChatUsers.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/GroupOfQuestions.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Models/Message.dart';
import 'package:mamba_castelldefels/Models/Question.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:uuid/uuid.dart';

class ScriptsDatabaseService {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

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

  Future<bool> migrateUserDataFebruary6th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 6TH FEBRUARY 2022');
      print('-----------------------------\n');
      print('\n');

      print('Modifying '+users+' collection:\n');
      print('-----------------------------\n');
      print('\n');

      print('Updating Document Data ...');
      print('-----------------------------\n');
      QuerySnapshot querySnapshot = await _firestore.collection(users).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Usuario user = Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('USER WITH ID: '+user.id!+" AND NAME: "+user.name!);
        List<String> aux = user.name!.split(" ");
        String firstName = aux[0];
        String lastName = "";
        for (var i=1; i<aux.length;i++) {
          lastName += aux[i]+" ";
        }
        print('firstName = '+firstName+'; lastName = '+lastName);
        await _firestore.collection(users).doc(user.id!).update({
          "firstName": firstName,
          "lastName":  lastName.trim(),
        });
        print('Adding Nickname document to '+nicknames+' collection ...');
        await _firestore.collection(nicknames).doc(user.nick!).set({
          "userId": user.id!,
        });
        print(user.nick!);
        print('-----------------------------\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateBrandDataFebruary6th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 6TH FEBRUARY 2022');
      print('-----------------------------\n');
      print('\n');

      print('Modifying '+brands+' collection:\n');
      print('-----------------------------\n');
      print('\n');

      print('Updating Document Data ...');
      print('-----------------------------\n');

      // TEST IN PRODUCTION WIHT OUR TEST BRAND - MAMBA TEAM
      String brandId = "9d978520-be41-4d90-94df-f49db3be5eac";
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).get();
      Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
      print('BRAND WITH ID: '+brand.id!+" AND NAME: "+brand.name!);
      print('Updating numTrainers and numClients document of Brand');
      await _firestore.collection(brands).doc(brandId).update({
        "numClients":  _documentSnapshot.get("numberClients"),
        "numTrainers":  _documentSnapshot.get("numberTrainers"),
      });
      // TODO: Adapt the actual brands with new Group Id
      print('Create Group Room For Brand');
      print('Assign the new group room id to field "roomId" of Brand Document');
      print('Add all members of Brand to this Group Room');
      print('-----------------------------\n');


      /* PRODUCTION FOR ALL REAL BRANDS
      QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Brand brand = Brand.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('BRAND WITH ID: '+brand.id!+" AND NAME: "+brand.name!);
        print('Updating numTrainers and numClients document of Brand');
        await _firestore.collection(brands).doc(querySnapshot.docs[i].id).update({
          "numClients":  querySnapshot.docs[i].get("numberClients"),
          "numTrainers":  querySnapshot.docs[i].get("numberTrainers"),
        });
        // TODO: Adapt the actual brands with new Group Id
        print('Create Group Room For Brand');
        print('Assign the new group room id to field "roomId" of Brand Document');
        print('Add all members of Brand to this Group Room');
        print('-----------------------------\n');
      }
       */
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateEventDataFebruary6th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 6TH FEBRUARY 2022');
      print('-----------------------------\n');
      print('\n');

      print('Modifying '+events+' collection:\n');
      print('-----------------------------\n');
      print('\n');

      print('Updating Document Data ...');
      print('-----------------------------\n');

      // TEST IN PRODUCTION WIHT OUR TEST BRAND - MAMBA TEAM
      String brandId = "9d978520-be41-4d90-94df-f49db3be5eac";
      QuerySnapshot querySnapshot = await _firestore.collection(events).where("brandID", isEqualTo: brandId).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('EVENT WITH ID: '+event.id!+" OF BRAND WITH ID: "+brandId);
        var selectedTrainers =  querySnapshot.docs[i].get("selectedTrainers");
        var joinedMembers =  querySnapshot.docs[i].get("joinedMembers");
        print('Updating numTrainers and numClients document of Event');
        await _firestore.collection(events).doc(event.id!).update({
          "numClients":  joinedMembers != null ? joinedMembers.length : 0,
          "numTrainers":  selectedTrainers != null ? selectedTrainers.length : 0,
        });
        print('\n');
      }
      /* PRODUCTION FOR ALL REAL BRANDS
      QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Brand brand = Brand.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('BRAND WITH ID: '+brand.id!+" AND NAME: "+brand.name!);
        print('Updating numTrainers and numClients document of Brand');
        await _firestore.collection(brands).doc(querySnapshot.docs[i].id).update({
          "numClients":  querySnapshot.docs[i].get("numberClients"),
          "numTrainers":  querySnapshot.docs[i].get("numberTrainers"),
        });
        // TODO: Adapt the actual brands with new Group Id
        print('Create Group Room For Brand');
        print('Assign the new group room id to field "roomId" of Brand Document');
        print('Add all members of Brand to this Group Room');
        print('-----------------------------\n');
      }
       */
      return true;
    } catch (e) {
      return false;
    }
  }


}
