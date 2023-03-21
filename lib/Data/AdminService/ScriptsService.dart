import 'dart:math';

import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Library/LibraryDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lImage.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'dart:io';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import '../DataService/Brand/BrandDataService.dart';

class ScriptsDatabaseService {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  final _libraryDataService = LibraryDataService();

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
  String library = isProduction ? 'Library' : 'Library';

  Future<bool> migrateUserDataFebruary6th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 6TH FEBRUARY 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying '+users+' collection:\n');
      print('--------------');
      print('\n');

      /* TEST IN PRODUCTION WIHT OUR TEST BRAND - MAMBA TEAM
      List<String> userIds = ["4dFmaUuMkpW6zkQT1pl2KLVBDMB3","SElZHIu009SKTMGmce0BY8cgeym2"];
      for (int i = 0; i < userIds.length; i++) {
        String userId = userIds[i];
        DocumentSnapshot _documentSnapshot = await _firestore.collection(users)
            .doc(userId)
            .get();
        Usuario user = Usuario.fromObjectAllData(
            _documentSnapshot.id, _documentSnapshot);
        print(
            '=================================================================================');
        print(
            '=================================================================================');
        print('USER WITH ID: ' + user.id! + " AND NAME: " + user.name!);
        print('\n');
        if (user.name == "null" || user.name == null) {
          print('User has not finished Onboarding');
        } else {
          print('Updating Document Data ...');
          print('-----------------------------\n');
          List<String> aux = user.name!.split(" ");
          String firstName = aux[0];
          String lastName = "";
          for (var i = 1; i < aux.length; i++) {
            lastName += aux[i] + " ";
          }
          print('firstName = ' + firstName + '; lastName = ' + lastName);
          await _firestore.collection(users).doc(user.id!).update({
            "firstName": firstName,
            "lastName": lastName.trim(),
            "isPrivate": false,
          });
          print('\n');
          print('Adding nickname document to ' + nicknames + ' collection ...');
          print('-----------------------------\n');
          await _firestore.collection(nicknames).doc(user.nick!).set({
            "userId": user.id!,
          });
          print(user.nick!);
          print('\n');
          print('Adding "Notifications" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotNotif = await _firestore.collection(
              notifications).where("userId", isEqualTo: user.id!).get();
          for (var i = 0; i < querySnapshotNotif.docs.length; i++) {
            String notifId = querySnapshotNotif.docs[i].id;
            print('Notification with ID : ' + notifId);
            DocumentSnapshot _documentSnapshot = querySnapshotNotif.docs[i];
            await _firestore.collection(users).doc(user.id!).collection(
                "Notifications").doc(notifId).set({
              "userId": _documentSnapshot.get("userId"),
              "type": _documentSnapshot.get("type"),
              "isRead": _documentSnapshot.get("isRead"),
              "dateSent": _documentSnapshot.get("dateSent"),
              "year": _documentSnapshot.get("year"),
              "month": _documentSnapshot.get("month"),
              "day": _documentSnapshot.get("day"),
              "hour": _documentSnapshot.get("hour"),
              "minutes": _documentSnapshot.get("minutes"),
              "seconds": _documentSnapshot.get("seconds"),
              "parameters": _documentSnapshot.get("parameters"),
            });
          }
          print('All Notifications Added');
          print('\n');
          print('Adding "Errors" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotErrors = await _firestore.collection(
              errors).where("userID", isEqualTo: user.id!).get();
          for (var i = 0; i < querySnapshotErrors.docs.length; i++) {
            String errorId = querySnapshotErrors.docs[i].id;
            print('Error with ID : ' + errorId);
            final CupertinoSelect now = CupertinoSelect.now();
            final DateFormat formatter = DateFormat('dd-MM-yyyy');
            final String formatted = formatter.format(now);
            await _firestore.collection(users).doc(user.id!).collection(
                "Errors").doc(errorId)
                .set({
              "dateSent": formatted,
            });
          }
          print('All Errors Added');
          print('\n');
          print('Adding "Brands" subcollection');
          print('-----------------------------\n');
          if (user.brandID != null) {
            DocumentSnapshot _document = await _firestore.collection(brands)
                .doc(user.brandID)
                .get();
            Brand brand = Brand.fromObjectAllData(_document.id, _document);
            print('Brand with ID : ' + brand.id!);
            final CupertinoSelect now = CupertinoSelect.now();
            final DateFormat formatter = DateFormat('dd-MM-yyyy');
            final String formatted = formatter.format(now);
            await _firestore.collection(users).doc(user.id!).collection(
                "Brands").doc(brand.id)
                .set({
              "name": brand.name,
              "logoUrl": brand.logoUrl,
              "dateJoined": formatted,
              "myMonthlySessions": 0,
              "myTotalSessions": 0,
            });
          } else {
            print('Not in Brand');
          }
          print('All Brands Added');
          print('\n');
          print('Adding "Events" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotEvents;
          if (user.isTrainer!) {
            querySnapshotEvents = await _firestore.collection(events).where(
                "selectedTrainers", arrayContains: user.id!).get();
          } else {
            querySnapshotEvents = await _firestore.collection(events).where(
                "joinedMembers", arrayContains: user.id!).get();
          }
          for (var i = 0; i < querySnapshotEvents.docs.length; i++) {
            String eventId = querySnapshotEvents.docs[i].id;
            DocumentSnapshot _documentSnapshot = querySnapshotEvents.docs[i];
            print('Event with ID : ' + eventId);
            int numClients = _documentSnapshot
                .get("joinedMembers")
                .length;
            int numTrainers = _documentSnapshot
                .get("selectedTrainers")
                .length;
            await _firestore.collection(users).doc(user.id!).collection(
                "Events").doc(eventId).set({
              "title": _documentSnapshot.get("title"),
              "year": _documentSnapshot.get("year"),
              "month": _documentSnapshot.get("month"),
              "day": _documentSnapshot.get("day"),
              "hour": _documentSnapshot.get("hour"),
              "minute": _documentSnapshot.get("minute"),
              "duration": _documentSnapshot.get("duration"),
              "numTrainers": numTrainers,
              "numClients": numClients,
              "maxMembers": _documentSnapshot.get("maxMembers"),
            });
          }
          print('All Events Added');
          print('\n');
          print(
              '=================================================================================');
          print(
              '=================================================================================');
          print('\n');
        }
      }*/



      // REAL MIGRATION FOR REAL DATA OF USERS
      QuerySnapshot querySnapshot = await _firestore.collection(users).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        DocumentSnapshot _documentSnapshot = querySnapshot.docs[i];
        Usuario user = Usuario.fromObjectAllData(
            _documentSnapshot.id, _documentSnapshot);
        print(
            '=================================================================================');
        print(
            '=================================================================================');
        print('USER WITH ID: ' + user.id! + " AND NAME: " + user.name!);
        if (user.name == "null" || user.name == null) {
          print('User has not finished Onboarding');
        } else {
          print('\n');
          print('Updating Document Data ...');
          print('-----------------------------\n');
          List<String> aux = user.name!.split(" ");
          String firstName = aux[0];
          String lastName = "";
          for (var i = 1; i < aux.length; i++) {
            lastName += aux[i] + " ";
          }
          print('firstName = ' + firstName + '; lastName = ' + lastName);
          await _firestore.collection(users).doc(user.id!).update({
            "firstName": firstName,
            "lastName": lastName.trim(),
            "isPrivate": false,
          });
          print('\n');
          print('Adding nickname document to ' + nicknames + ' collection ...');
          print('-----------------------------\n');
          await _firestore.collection(nicknames).doc(user.nick!).set({
            "userId": user.id!,
          });
          print(user.nick!);
          print('\n');
          print('Adding "Notifications" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotNotif = await _firestore.collection(
              notifications).where("userId", isEqualTo: user.id!).get();
          for (var i = 0; i < querySnapshotNotif.docs.length; i++) {
            String notifId = querySnapshotNotif.docs[i].id;
            print('Notification with ID : ' + notifId);
            DocumentSnapshot _documentSnapshot = querySnapshotNotif.docs[i];
            await _firestore.collection(users).doc(user.id!).collection(
                "Notifications").doc(notifId).set({
              "userId": _documentSnapshot.get("userId"),
              "type": _documentSnapshot.get("type"),
              "isRead": _documentSnapshot.get("isRead"),
              "dateSent": _documentSnapshot.get("dateSent"),
              "year": _documentSnapshot.get("year"),
              "month": _documentSnapshot.get("month"),
              "day": _documentSnapshot.get("day"),
              "hour": _documentSnapshot.get("hour"),
              "minutes": _documentSnapshot.get("minutes"),
              "seconds": _documentSnapshot.get("seconds"),
              "parameters": _documentSnapshot.get("parameters"),
            });
          }
          print('All Notifications Added');
          print('\n');
          print('Adding "Errors" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotErrors = await _firestore.collection(
              errors).where("userID", isEqualTo: user.id!).get();
          for (var i = 0; i < querySnapshotErrors.docs.length; i++) {
            String errorId = querySnapshotErrors.docs[i].id;
            print('Error with ID : ' + errorId);
            final DateTime now = DateTime.now();
            final DateFormat formatter = DateFormat('dd-MM-yyyy');
            final String formatted = formatter.format(now);
            await _firestore.collection(users).doc(user.id!).collection(
                "Errors").doc(errorId)
                .set({
              "dateSent": formatted,
            });
          }
          print('All Errors Added');
          print('\n');
          print('Adding "Brands" subcollection');
          print('-----------------------------\n');
          if (user.brandID != "null") {
            DocumentSnapshot _document = await _firestore.collection(brands)
                .doc(user.brandID)
                .get();
            Brand brand = Brand.fromObjectAllData(_document.id, _document);
            print('Brand with ID : ' + brand.id!);
            final DateTime now = DateTime.now();
            final DateFormat formatter = DateFormat('dd-MM-yyyy');
            final String formatted = formatter.format(now);
            await _firestore.collection(users).doc(user.id!).collection(
                "Brands").doc(brand.id)
                .set({
              "name": brand.name,
              "logoUrl": brand.logoUrl,
              "dateJoined": formatted,
              "myMonthlySessions": 0,
              "myTotalSessions": 0,
            });
          } else {
            print('Not in Brand');
          }
          print('All Brands Added');
          print('\n');
          print('Adding "Events" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotEvents;
          if (user.isTrainer!) {
            querySnapshotEvents = await _firestore.collection(events).where(
                "selectedTrainers", arrayContains: user.id!).get();
          } else {
            querySnapshotEvents = await _firestore.collection(events).where(
                "joinedMembers", arrayContains: user.id!).get();
          }
          for (var i = 0; i < querySnapshotEvents.docs.length; i++) {
            String eventId = querySnapshotEvents.docs[i].id;
            DocumentSnapshot _documentSnapshot = querySnapshotEvents.docs[i];
            print('Event with ID : ' + eventId);
            int numClients = _documentSnapshot
                .get("joinedMembers")
                .length;
            int numTrainers = _documentSnapshot
                .get("selectedTrainers")
                .length;
            await _firestore.collection(users).doc(user.id!).collection(
                "Events").doc(eventId).set({
              "title": _documentSnapshot.get("title"),
              "year": _documentSnapshot.get("year"),
              "month": _documentSnapshot.get("month"),
              "day": _documentSnapshot.get("day"),
              "hour": _documentSnapshot.get("hour"),
              "minute": _documentSnapshot.get("minute"),
              "duration": _documentSnapshot.get("duration"),
              "numTrainers": numTrainers,
              "numClients": numClients,
              "maxMembers": _documentSnapshot.get("maxMembers"),
            });
          }
          print('All Events Added');
          print('\n');
          print(
              '=================================================================================');
          print(
              '=================================================================================');
          print('\n');
        }
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
      print('-----------------------------');
      print('\n');

      print('Modifying '+brands+' collection:\n');
      print('--------------');
      print('\n');

      /* TEST IN PRODUCTION WIHT OUR TEST BRAND - MAMBA TEAM
      String brandId = "9d978520-be41-4d90-94df-f49db3be5eac";
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).get();
      Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
      print('=================================================================================');
      print('=================================================================================');
      print('BRAND WITH ID: '+brand.id!+" AND NAME: "+brand.name!);
      print('\n');
      print('Updating Document Data ...');
      print('-----------------------------');
      print('Updating numTrainers and numClients document of Brand');
      await _firestore.collection(brands).doc(brandId).update({
        "numClients":  _documentSnapshot.get("numberClients"),
        "numTrainers":  _documentSnapshot.get("numberTrainers"),
      });
      print('Create Room for Brand ...');
      print('-----------------------------');
      final room = await FirebaseChatCore.instance.createGroupRoom(imageUrl: brand.logoUrl, metadata: {
        "trainer" + currentUser.id!: currentUser.isTrainer,
        "active" + currentUser.id!: false,
      }, name: brand.name!, users: []);
      print('Assign the new group room id to field "roomId" of Brand Document');
      await _firestore.collection(brands).doc(brandId).update({
        "roomId":  room.id,
      });
      print('Add all members of Brand to this Group Room');
      var metadataRoom = {};
      List<String> userIds = [];
      List<Usuario> brandUsers = await _brandDataService.getBrandUsers(brand.id!);
      for (var i=0; i< brandUsers.length; i++) {
        userIds.add(brandUsers[i].id!);
        metadataRoom["trainer" + brandUsers[i].id!] = brandUsers[i].isTrainer;
        metadataRoom["active" + brandUsers[i].id!] = false;
      }
      await _firestore.collection(rooms).doc(room.id).update({
        "metadata": metadataRoom,
        "userIds": userIds,
      });
      print('\n');
      print('Adding "Users" subcollection');
      print('-----------------------------\n');
      QuerySnapshot querySnapshotUsers = await _firestore.collection(users).where("brandID", isEqualTo: brandId).get();
      for (var i=0; i<querySnapshotUsers.docs.length;i++) {
        String userId = querySnapshotUsers.docs[i].id;
        DocumentSnapshot _documentSnapshot = querySnapshotUsers.docs[i];
        Usuario user = Usuario.fromObjectAllData(userId, _documentSnapshot);
        print('User with ID : '+userId);
        int role = 0;
        if (_documentSnapshot.get("isTrainer")) {
          if (userId == brand.adminID) {
            role = 1;
          } else {
            role = 5;
          }
        }
        await _firestore
            .collection(brands)
            .doc(brandId)
            .collection("Users")
            .doc(userId)
                .set({
              "name": user.name,
              "firstName": user.firstName,
              "lastName": user.lastName,
              "nick": user.nick,
              "imageUrl": user.imageUrl,
              "noImageUrl": user.noImageUrl,
              "isTrainer": user.isTrainer,
              "isPrivate": user.isPrivate,
              "notificationToken": user.notificationToken,
              "role": role,
            });
      }
      print('All Users Added');
      print('\n');
      print('Adding "Locations" subcollection');
      print('-----------------------------\n');
      QuerySnapshot querySnapshotLocations = await _firestore.collection(locations).where("brandID", isEqualTo: brandId).get();
      for (var i=0; i<querySnapshotLocations.docs.length;i++) {
        String locationId = querySnapshotLocations.docs[i].id;
        DocumentSnapshot _documentSnapshot = querySnapshotLocations.docs[i];
        Location location = Location.fromObjectAllData(locationId, _documentSnapshot);
        print('Location with ID : '+locationId);
        await _firestore
            .collection(brands)
            .doc(brandId)
            .collection("Locations")
            .doc(locationId)
            .set({
              "isBaseLocation": location.isBaseLocation,
              "description": location.description,
              "latitude": location.latitude,
              "longitude": location.longitude,
            });
      }
      print('All Locations Added');
      print('\n');
      print('Adding "Events" subcollection');
      print('-----------------------------\n');
      QuerySnapshot querySnapshotEvents = await _firestore.collection(events).where("brandID", isEqualTo: brandId).get();
      for (var i=0; i<querySnapshotEvents.docs.length;i++) {
        String eventId = querySnapshotEvents.docs[i].id;
        DocumentSnapshot _documentSnapshot = querySnapshotEvents.docs[i];
        print('Event with ID : '+eventId);
        int numClients = _documentSnapshot.get("joinedMembers").length;
        int numTrainers = _documentSnapshot.get("selectedTrainers").length;
        await _firestore.collection(brands).doc(brandId).collection("Events").doc(eventId).set({
          "title": _documentSnapshot.get("title"),
          "year": _documentSnapshot.get("year"),
          "month": _documentSnapshot.get("month"),
          "day": _documentSnapshot.get("day"),
          "hour": _documentSnapshot.get("hour"),
          "minute": _documentSnapshot.get("minute"),
          "duration": _documentSnapshot.get("duration"),
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": _documentSnapshot.get("maxMembers"),
        });
      }
      print('All Events Added');
      print('\n');
      print('=================================================================================');
      print('=================================================================================');
      print('\n');
      */

      // PRODUCTION FOR ALL REAL BRANDS
      QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String brandId = querySnapshot.docs[i].id;
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).get();
        Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('BRAND WITH ID: '+brand.id!+" AND NAME: "+brand.name!);
        print('\n');
        print('Updating Document Data ...');
        print('-----------------------------');
        print('Updating numTrainers and numClients document of Brand');
        await _firestore.collection(brands).doc(brandId).update({
          "numClients":  _documentSnapshot.get("numberClients"),
          "numTrainers":  _documentSnapshot.get("numberTrainers"),
        });
        print('Create Room for Brand ...');
        print('-----------------------------');
        final room = await FirebaseChatCore.instance.createGroupRoom(imageUrl: brand.logoUrl, metadata: {
          "trainer" + currentUser.id!: currentUser.isTrainer,
          "active" + currentUser.id!: false,
        }, name: brand.name!, users: []);
        print('Assign the new group room id to field "roomId" of Brand Document');
        await _firestore.collection(brands).doc(brandId).update({
          "roomId":  room.id,
        });
        print('Add all members of Brand to this Group Room');
        var metadataRoom = {};
        List<String> userIds = [];
        List<Usuario> brandUsers = await _brandDataService.getBrandUsers(brand.id!);
        for (var i=0; i< brandUsers.length; i++) {
          userIds.add(brandUsers[i].id!);
          metadataRoom["trainer" + brandUsers[i].id!] = brandUsers[i].isTrainer;
          metadataRoom["active" + brandUsers[i].id!] = false;
        }
        await _firestore.collection(rooms).doc(room.id).update({
          "metadata": metadataRoom,
          "userIds": userIds,
        });
        print('\n');
        print('Adding "Users" subcollection');
        print('-----------------------------\n');
        QuerySnapshot querySnapshotUsers = await _firestore.collection(users).where("brandID", isEqualTo: brandId).get();
        for (var i=0; i<querySnapshotUsers.docs.length;i++) {
          String userId = querySnapshotUsers.docs[i].id;
          DocumentSnapshot _documentSnapshot = querySnapshotUsers.docs[i];
          Usuario user = Usuario.fromObjectAllData(userId, _documentSnapshot);
          print('User with ID : '+userId);
          int role = 0;
          if (_documentSnapshot.get("isTrainer")) {
            if (userId == brand.adminID) {
              role = 1;
            } else {
              role = 5;
            }
          }
          await _firestore
              .collection(brands)
              .doc(brandId)
              .collection("Users")
              .doc(userId)
              .set({
            "name": user.name,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "nick": user.nick,
            "imageUrl": user.imageUrl,
            "noImageUrl": user.noImageUrl,
            "isTrainer": user.isTrainer,
            "isPrivate": user.isPrivate,
            "notificationToken": user.notificationToken,
            "role": role,
          });
        }
        print('All Users Added');
        print('\n');
        print('Adding "Locations" subcollection');
        print('-----------------------------\n');
        QuerySnapshot querySnapshotLocations = await _firestore.collection(locations).where("brandID", isEqualTo: brandId).get();
        for (var i=0; i<querySnapshotLocations.docs.length;i++) {
          String locationId = querySnapshotLocations.docs[i].id;
          DocumentSnapshot _documentSnapshot = querySnapshotLocations.docs[i];
          Location location = Location.fromObjectAllData(locationId, _documentSnapshot);
          print('Location with ID : '+locationId);
          await _firestore
              .collection(brands)
              .doc(brandId)
              .collection("Locations")
              .doc(locationId)
              .set({
            "isBaseLocation": location.isBaseLocation,
            "description": location.description,
            "latitude": location.latitude,
            "longitude": location.longitude,
          });
        }
        print('All Locations Added');
        print('\n');
        print('Adding "Events" subcollection');
        print('-----------------------------\n');
        QuerySnapshot querySnapshotEvents = await _firestore.collection(events).where("brandID", isEqualTo: brandId).get();
        for (var i=0; i<querySnapshotEvents.docs.length;i++) {
          String eventId = querySnapshotEvents.docs[i].id;
          DocumentSnapshot _documentSnapshot = querySnapshotEvents.docs[i];
          print('Event with ID : '+eventId);
          int numClients = _documentSnapshot.get("joinedMembers").length;
          int numTrainers = _documentSnapshot.get("selectedTrainers").length;
          await _firestore.collection(brands).doc(brandId).collection("Events").doc(eventId).set({
            "title": _documentSnapshot.get("title"),
            "year": _documentSnapshot.get("year"),
            "month": _documentSnapshot.get("month"),
            "day": _documentSnapshot.get("day"),
            "hour": _documentSnapshot.get("hour"),
            "minute": _documentSnapshot.get("minute"),
            "duration": _documentSnapshot.get("duration"),
            "numTrainers": numTrainers,
            "numClients": numClients,
            "maxMembers": _documentSnapshot.get("maxMembers"),
          });
        }
        print('All Events Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
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

      /* TEST IN PRODUCTION WIHT OUR TEST BRAND - MAMBA TEAM
      String brandId = "9d978520-be41-4d90-94df-f49db3be5eac";
      QuerySnapshot querySnapshot = await _firestore.collection(events).where("brandID", isEqualTo: brandId).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('EVENT WITH ID: '+event.id!+" OF BRAND WITH ID: "+brandId);
        print('\n');
        print('Updating Document Data ...');
        print('-----------------------------');
        var selectedTrainers =  querySnapshot.docs[i].get("selectedTrainers");
        var joinedMembers =  querySnapshot.docs[i].get("joinedMembers");
        print('Updating numTrainers and numClients document of Event');
        await _firestore.collection(events).doc(event.id!).update({
          "numClients":  joinedMembers != null ? joinedMembers.length : 0,
          "numTrainers":  selectedTrainers != null ? selectedTrainers.length : 0,
        });
        print('\n');
        print('Adding "Users" subcollection');
        print('-----------------------------\n');
        var usersIds = selectedTrainers + joinedMembers;
        for (var i=0; i<usersIds.length;i++) {
          String userId = usersIds[i];
          print('User with ID : ' + userId);
          DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(users).doc(userId).get();
          Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
          await _firestore
            .collection(events)
            .doc(event.id!)
            .collection("Users")
            .doc(user.id!)
            .set({
              "name": user.name,
              "firstName": user.firstName,
              "lastName": user.lastName,
              "nick": user.nick,
              "imageUrl": user.imageUrl,
              "noImageUrl": user.noImageUrl,
              "isTrainer": user.isTrainer,
              "isPrivate": user.isPrivate,
              "notificationToken": user.notificationToken,
            });
        }
        print('All Users Added');
        print('\n');
        print('Adding "Brands" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentBrand = await _firestore.collection(brands).doc(event.brandID).get();
        Brand brand = Brand.fromObjectAllData(_documentBrand.id, _documentBrand);
        print('Brand with ID : '+brand.id!);
        await _firestore.collection(events).doc(event.id!).collection("Brands").doc(brand.id)
            .set({
              "name": brand.name,
              "logoUrl": brand.logoUrl,
            });
        print('All Brands Added');
        print('\n');
        print('Adding "Locations" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentSnapshot = await _firestore.collection(locations).doc(event.locationId).get();
        Location location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('Location with ID : '+location.id!);
        await _firestore
            .collection(events)
            .doc(event.id!)
            .collection("Locations")
            .doc(location.id!)
            .set({
              "description": location.description,
              "latitude": location.latitude,
              "longitude": location.longitude,
            });
        print('All Locations Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }*/


      // PRODUCTION FOR ALL REAL EVENTS
      QuerySnapshot querySnapshot = await _firestore.collection(events).where("brandID", isEqualTo: "ef80f103-824c-4f4b-9764-8fe4863c8c4f").where("month", isEqualTo: "2").get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('EVENT WITH ID: '+event.id!+" OF BRAND WITH ID: "+event.brandID!);
        print('\n');
        print('Updating Document Data ...');
        print('-----------------------------');
        var selectedTrainers =  querySnapshot.docs[i].get("selectedTrainers");
        var joinedMembers =  querySnapshot.docs[i].get("joinedMembers");
        print('Updating numTrainers and numClients document of Event');
        await _firestore.collection(events).doc(event.id!).update({
          "numClients":  joinedMembers != null ? joinedMembers.length : 0,
          "numTrainers":  selectedTrainers != null ? selectedTrainers.length : 0,
        });
        print('\n');
        print('Adding "Users" subcollection');
        print('-----------------------------\n');
        var usersIds = selectedTrainers + joinedMembers;
        for (var i=0; i<usersIds.length;i++) {
          String userId = usersIds[i];
          print('User with ID : ' + userId);
          DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(users).doc(userId).get();
          Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
          await _firestore
              .collection(events)
              .doc(event.id!)
              .collection("Users")
              .doc(user.id!)
              .set({
            "name": user.name,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "nick": user.nick,
            "imageUrl": user.imageUrl,
            "noImageUrl": user.noImageUrl,
            "isTrainer": user.isTrainer,
            "isPrivate": user.isPrivate,
            "notificationToken": user.notificationToken,
          });
        }
        print('All Users Added');
        print('\n');
        print('Adding "Brands" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentBrand = await _firestore.collection(brands).doc(event.brandID).get();
        Brand brand = Brand.fromObjectAllData(_documentBrand.id, _documentBrand);
        print('Brand with ID : '+brand.id!);
        await _firestore.collection(events).doc(event.id!).collection("Brands").doc(brand.id)
            .set({
          "name": brand.name,
          "logoUrl": brand.logoUrl,
        });
        print('All Brands Added');
        print('\n');
        print('Adding "Locations" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentSnapshot = await _firestore.collection(locations).doc(event.locationId).get();
        Location location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('Location with ID : '+location.id!);
        await _firestore
            .collection(events)
            .doc(event.id!)
            .collection("Locations")
            .doc(location.id!)
            .set({
          "description": location.description,
          "latitude": location.latitude,
          "longitude": location.longitude,
        });
        print('All Locations Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateLocationDataFebruary6th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 6TH FEBRUARY 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying '+locations+' collection:\n');
      print('--------------');
      print('\n');

      /* TEST IN PRODUCTION WITH OUR TEST BRAND - MAMBA TEAM
      List<String> locationIds = ["8c7d6ed0-8912-11ec-a318-490746e85be9","e192ef20-6ff0-11ec-9e9d-af27aa8de287"];
      for (int i = 0; i < locationIds.length; i++) {
        String locationId = locationIds[i];
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(locations).doc(locationId).get();
        Location location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('LOCATION WITH ID: ' + location.id! + " AND DESCRIPTION: " + location.description!);
        print('\n');

        print('Adding "Events" subcollection');
        print('-----------------------------\n');
        QuerySnapshot querySnapshotEvents = await _firestore.collection(events).where("brandID", isEqualTo: location.brandID).where("locationId", isEqualTo: location.id).get();
        for (var i=0; i<querySnapshotEvents.docs.length;i++) {
          String eventId = querySnapshotEvents.docs[i].id;
          DocumentSnapshot _documentSnapshot = querySnapshotEvents.docs[i];
          print('Event with ID : '+eventId);
          int numClients = _documentSnapshot.get("joinedMembers").length;
          int numTrainers = _documentSnapshot.get("selectedTrainers").length;
          await _firestore.collection(locations).doc(location.id).collection("Events").doc(eventId).set({
            "title": _documentSnapshot.get("title"),
            "year": _documentSnapshot.get("year"),
            "month": _documentSnapshot.get("month"),
            "day": _documentSnapshot.get("day"),
            "hour": _documentSnapshot.get("hour"),
            "minute": _documentSnapshot.get("minute"),
            "duration": _documentSnapshot.get("duration"),
            "numTrainers": numTrainers,
            "numClients": numClients,
            "maxMembers": _documentSnapshot.get("maxMembers"),
          });
        }
        print('All Events Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      } */


      // PRODUCTION FOR ALL REAL BRANDS
      QuerySnapshot querySnapshot = await _firestore.collection(locations).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String locationId = querySnapshot.docs[i].id;
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(locations).doc(locationId).get();
        Location location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('LOCATION WITH ID: ' + location.id! + " AND DESCRIPTION: " + location.description!);
        print('\n');

        print('Adding "Events" subcollection');
        print('-----------------------------\n');
        QuerySnapshot querySnapshotEvents = await _firestore.collection(events).where("brandID", isEqualTo: location.brandID).where("locationId", isEqualTo: location.id).get();
        for (var i=0; i<querySnapshotEvents.docs.length;i++) {
          String eventId = querySnapshotEvents.docs[i].id;
          DocumentSnapshot _documentSnapshot = querySnapshotEvents.docs[i];
          print('Event with ID : '+eventId);
          int numClients = _documentSnapshot.get("joinedMembers").length;
          int numTrainers = _documentSnapshot.get("selectedTrainers").length;
          await _firestore.collection(locations).doc(location.id).collection("Events").doc(eventId).set({
            "title": _documentSnapshot.get("title"),
            "year": _documentSnapshot.get("year"),
            "month": _documentSnapshot.get("month"),
            "day": _documentSnapshot.get("day"),
            "hour": _documentSnapshot.get("hour"),
            "minute": _documentSnapshot.get("minute"),
            "duration": _documentSnapshot.get("duration"),
            "numTrainers": numTrainers,
            "numClients": numClients,
            "maxMembers": _documentSnapshot.get("maxMembers"),
          });
        }
        print('All Events Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changeNicknameToLowercaseFebruary6th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('NICKNAME TO LOWERCASE 6TH FEBRUARY 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying '+nicknames+' collection:\n');
      print('--------------');
      print('\n');

      // CHANGES ON REAL DATA OF USERS
      QuerySnapshot querySnapshot = await _firestore.collection(users).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        DocumentSnapshot _documentSnapshot = querySnapshot.docs[i];
        Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: ' + user.id! + " AND NAME: " + user.name!);
        if (user.name == "null" || user.name == null) {
          print('User has not finished Onboarding');
        } else {
          print('\n');
          print('Updating Nickname Data ...');
          print('-----------------------------\n');
          String? replaceWhitespacesUsingRegex(String s, String replace) {
            // This pattern means "at least one space, or more"
            // \\s : space
            // +   : one or more
            final pattern = RegExp('\\s+');
            return s.replaceAll(pattern, replace);
          }
          print('Previous Nickname ...');
          print(user.nick!);
          await _firestore.collection(nicknames).doc(user.nick!).delete();
          String lowerCaseNick = user.nick!.toLowerCase();
          var nickname = replaceWhitespacesUsingRegex(lowerCaseNick, '');
          print('After Nickname ...');
          print(nickname);
          await _firestore.collection(users).doc(user.id!).update({
            "nick": nickname,
          });
          print('\n');
          print('Adding nickname document to ' + nicknames + ' collection ...');
          print('-----------------------------\n');
          await _firestore.collection(nicknames).doc(nickname).set({
            "userId": user.id!,
          });
          print('\n');
          print('=================================================================================');
          print('=================================================================================');
          print('\n');
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> correctingRooms() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 18TH FEBRUARY 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying '+rooms+' collection:\n');
      print('--------------');
      print('\n');

      // PRODUCTION FOR ALL REAL BRANDS
      QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String brandId = querySnapshot.docs[i].id;
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).get();
        Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('BRAND WITH ID: '+brand.id!+" AND NAME: "+brand.name!);
        print('\n');
        print('Edit Room for Brand ...');
        print('-----------------------------');
        print('Add all members of Brand to this Group Room');
        String roomId = brand.roomId!;
        var metadataRoom = {};
        List<String> userIds = [];
        // New Version Users
        List<Usuario> brandUsers = await _brandDataService.getBrandUsers(brand.id!);
        // Old Version Users
        List<Usuario> oldBrandUsers = [];
        QuerySnapshot query = await _firestore.collection(users).where("brandID", isEqualTo: brandId).get();
        for (DocumentSnapshot doc in query.docs) {
          oldBrandUsers.add(Usuario.fromObjectOnlyCoverData(doc.id, doc));
        }
        print('New Version Users');
        print('\n');
        for (var i=0; i< brandUsers.length; i++) {
          Usuario user = brandUsers[i];
          print('USER WITH ID: ' + user.id! + " AND NAME: " + user.name!);
          userIds.add(brandUsers[i].id!);
          metadataRoom["trainer" + brandUsers[i].id!] = brandUsers[i].isTrainer;
          metadataRoom["active" + brandUsers[i].id!] = false;
        }
        print('Old Version Users');
        for (var i=0; i< oldBrandUsers.length; i++) {
          Usuario user = oldBrandUsers[i];
          if (userIds.contains(user.id) == false) {
            print('USER WITH ID: ' + user.id! + " AND NAME: " + user.name!);
            userIds.add(user.id!);
            metadataRoom["trainer" + user.id!] = user.isTrainer;
            metadataRoom["active" + user.id!] = false;
          }
        }
        await _firestore.collection(rooms).doc(roomId).update({
          "metadata": metadataRoom,
          "userIds": userIds,
        });
        print('\n');
        print('All Users Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateResizeCompressUserImages() async {
    try {
      print('\n');
      print('-----------------------------');
      print('IMAGE MIGRATION 6Th MARCH 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying '+users+' storage collection:\n');
      print('--------------');
      print('\n');

      String noImageUrl = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/emptyProfileImage.png?alt=media&token=a1b2a183-fc5e-4225-a839-3330ba60bd53";

      // TEST IN DEVELOPMENT
      QuerySnapshot querySnapshot = await _firestore.collection("7777 Users").get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        DocumentSnapshot _documentSnapshot = querySnapshot.docs[i];
        Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: ' + user.id! + " AND NAME: " + user.name!);
        print('\n');
        if (user.name == "null" || user.name == null) {
          print('User has not finished Onboarding');
        } else {
          if (noImageUrl == user.imageUrl) {
            print("THIS USER HAS CURRENTLY NO IMAGE SET");
          } else {
            File fileImage = await ImageUtils().urlToFile(user.imageUrl!);
            var size = await ImageUtils().getImageFileSize(fileImage, 2);
            print("Current Image Size: "+size);
            print('\n');
            print("Compressing Image...");
            print('\n');
            final filePath = fileImage.absolute.path;
            final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
            final splitted = filePath.substring(0, (lastIndex));
            final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
            var compressedFileImage = await FlutterImageCompress.compressAndGetFile(
              fileImage.absolute.path,
              outPath,
              quality: 75,
              rotate: 0,
            );
            var compressedSize = await ImageUtils().getImageFileSize(compressedFileImage!, 2);
            print("Compressed Image Size: "+compressedSize);
            // Upload Photo de Firebase and Update
            print("Uploading image ...");
            var result = await _userDataService.updateUserPhoto(user.id!, compressedFileImage);
            print("Image succesfully uploaded!");
            print("\n");
            List<Brand> brandsList = await _brandDataService.getAllBrandsFromUser(user.id!);
            for (int i = 0; i < brandsList.length; i++) {
              print("Updating Brand - Users");
              Brand brand = brandsList[i];
              print("Brand: "+brand.name!);
              await _firestore.collection(brands).doc(brand.id!).collection("Users").doc(user.id).update({
                "imageUrl": result,
              });
              print("Image succesfully updated!");
            }
          }
        }

        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateResizeCompressBrandImages() async {
    try {
      print('\n');
      print('-----------------------------');
      print('IMAGE MIGRATION 6Th MARCH 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying '+brands+' storage collection:\n');
      print('--------------');
      print('\n');

      // TEST IN DEVELOPMENT
      QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        DocumentSnapshot _documentSnapshot = querySnapshot.docs[i];
        Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('BRAND WITH ID: ' + brand.id! + " AND NAME: " + brand.name!);
        print('\n');
        File fileImage = await ImageUtils().urlToFile(brand.logoUrl!);
        var size = await ImageUtils().getImageFileSize(fileImage, 2);
        print("Current Image Size: "+size);
        print('\n');
        print("Compressing Image...");
        print('\n');
        final filePath = fileImage.absolute.path;
        final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
        final splitted = filePath.substring(0, (lastIndex));
        final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
        var compressedFileImage = await FlutterImageCompress.compressAndGetFile(
          fileImage.absolute.path,
          outPath,
          quality: 75,
          rotate: 0,
        );
        var compressedSize = await ImageUtils().getImageFileSize(compressedFileImage!, 2);
        print("Compressed Image Size: "+compressedSize);
        // Upload Photo de Firebase and Update
        print("Uploading image ...");
        await _brandDataService.updateBrandPhoto(brand.id!, compressedFileImage);
        print("Image succesfully uploaded!");
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateNotificationsDataMarch17th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 17TH FEBRUARY 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying User Notifications collection:\n');
      print('--------------');
      print('\n');


      QuerySnapshot querySnapshotUsers = await _firestore.collection("Users").get();
      for (int i = 0; i < querySnapshotUsers.docs.length; i++) {
        var userId = querySnapshotUsers.docs[i].id;
        QuerySnapshot querySnapshot = await _firestore.collection("Users").doc(userId).collection("Notifications").get();

        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: ' + userId + " AND TOTAL NOTIFICATIONS: " + querySnapshot.docs.length.toString());
        print('\n');

        for (int i = 0; i < querySnapshot.docs.length; i++) {
          DocumentSnapshot doc = querySnapshot.docs[i];
          if ((doc.data() as Map<String,dynamic>).containsKey('createdAt') == false) {
            NotificationEvent notif = NotificationEvent.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
            // Get CupertinoSelect
            DateTime notifDate = DateTime(
              int.parse(notif.year!),
              int.parse(notif.month!),
              int.parse(notif.day!),
              int.parse(notif.hour!),
              int.parse(notif.minutes!),
              int.parse(notif.seconds!),
            );
            // CupertinoSelect to TimeStamp
            Timestamp notifTimeStamp = Timestamp.fromDate(notifDate);
            // Save TimeStamp Firebase
            await _firestore
                .collection("Users")
                .doc(userId)
                .collection("Notifications")
                .doc(notif.id)
                .update({
              "createdAt": notifTimeStamp,
            });
            print('OLD NOTIF');
          }

        }

        print('=================================================================================');
        print('=================================================================================');
        print('\n');

      }



      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateEventsDataMarch24th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 28TH March 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying Events collection:\n');
      print('--------------');
      print('\n');

      String eventsCollection = "Events";
      String userCollection = "Users";
      String brandsCollection = "Brands";
      String locationCollection = "Locations";

      QuerySnapshot querySnapshotEvents = await _firestore.collection(eventsCollection).get();
      for (int i = 0; i < querySnapshotEvents.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshotEvents.docs[i].id, querySnapshotEvents.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('EVENT WITH ID: ' + event.id!);
        print('\n');
        // Get CupertinoSelect
        DateTime eventDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        // CupertinoSelect to TimeStamp
        Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
        print("Timestamp is "+eventTimeStamp.toString());
        // Save TimeStamp Firebase
        await _firestore
            .collection(eventsCollection)
            .doc(event.id!)
            .update({
              "createdAt": eventTimeStamp,
              "doneAt": eventTimeStamp,
            });
        print("Timestamp added");
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      print('Modifying User Events collection:\n');
      print('--------------');
      print('\n');

      QuerySnapshot querySnapshotUsers = await _firestore.collection(userCollection).get();
      for (int i = 0; i < querySnapshotUsers.docs.length; i++) {
        String userId = querySnapshotUsers.docs[i].id;
        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: ' + userId);
        print('\n');

        QuerySnapshot querySnapshotUsersEvents = await _firestore.collection(userCollection).doc(userId).collection("Events").get();
        for (int i = 0; i < querySnapshotUsersEvents.docs.length; i++) {
          Event event = Event.fromObjectAllData(querySnapshotUsersEvents.docs[i].id, querySnapshotUsersEvents.docs[i]);
          // Get CupertinoSelect
          DateTime eventDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          // CupertinoSelect to TimeStamp
          Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
          // Save TimeStamp Firebase
          await _firestore
              .collection(userCollection)
              .doc(userId)
              .collection("Events")
              .doc(event.id!)
              .update({
            "createdAt": eventTimeStamp,
            "doneAt": eventTimeStamp,
          });
        }
        print("All Events Modified");
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      print('Modifying Brand Events collection:\n');
      print('--------------');
      print('\n');

      QuerySnapshot querySnapshotBrands = await _firestore.collection(brandsCollection).get();
      for (int i = 0; i < querySnapshotBrands.docs.length; i++) {
        String brandId = querySnapshotBrands.docs[i].id;
        print('=================================================================================');
        print('=================================================================================');
        print('BRAND WITH ID: ' + brandId);
        print('\n');

        QuerySnapshot querySnapshotBrandEvents = await _firestore.collection(brandsCollection).doc(brandId).collection("Events").get();
        for (int i = 0; i < querySnapshotBrandEvents.docs.length; i++) {
          Event event = Event.fromObjectAllData(querySnapshotBrandEvents.docs[i].id, querySnapshotBrandEvents.docs[i]);
          // Get CupertinoSelect
          DateTime eventDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          // CupertinoSelect to TimeStamp
          Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
          // Save TimeStamp Firebase
          await _firestore
              .collection(brandsCollection)
              .doc(brandId)
              .collection("Events")
              .doc(event.id!)
              .update({
            "createdAt": eventTimeStamp,
            "doneAt": eventTimeStamp,
          });
        }
        print("All Events Modified");
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      print('Modifying Location Events collection:\n');
      print('--------------');
      print('\n');

      QuerySnapshot querySnapshotLocations = await _firestore.collection(locationCollection).get();
      for (int i = 0; i < querySnapshotLocations.docs.length; i++) {
        String locationId = querySnapshotLocations.docs[i].id;
        print('=================================================================================');
        print('=================================================================================');
        print('LOCATION WITH ID: ' + locationId);
        print('\n');

        QuerySnapshot querySnapshotLocationEvents = await _firestore.collection(locationCollection).doc(locationId).collection("Events").get();
        for (int i = 0; i < querySnapshotLocationEvents.docs.length; i++) {
          Event event = Event.fromObjectAllData(querySnapshotLocationEvents.docs[i].id, querySnapshotLocationEvents.docs[i]);
          // Get CupertinoSelect
          DateTime eventDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          // CupertinoSelect to TimeStamp
          Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
          // Save TimeStamp Firebase
          await _firestore
              .collection(locationCollection)
              .doc(locationId)
              .collection("Events")
              .doc(event.id!)
              .update({
            "createdAt": eventTimeStamp,
            "doneAt": eventTimeStamp,
          });
        }
        print("All Events Modified");
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateUserDataApril8th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 8TH FEBRUARY 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying '+users+' collection:\n');
      print('--------------');
      print('\n');


      // REAL MIGRATION FOR REAL DATA OF USERS
      QuerySnapshot querySnapshot = await _firestore.collection("Users").get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        DocumentSnapshot _documentSnapshot = querySnapshot.docs[i];
        Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: ' + user.id! + " AND NAME: " + user.name!);
        if (i.isEven) {
          await _firestore.collection("Users").doc(user.id!).update({
            "testGroup": "A",
          });
        } else {
          await _firestore.collection("Users").doc(user.id!).update({
            "testGroup": "B",
          });
        }
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> putUserInBrand() async {
    String userId = "xpdj9FYZMBfQ16AXS34UppWuyBo2";
    String brandId = "67650734-4c76-42ce-b7c3-ec92c0013bc8";
    int role = 0;
    try {
      await _brandDataService.addUserToBrand(userId, brandId, role);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> getStatistics() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("Users").get();
      var totalUsers = querySnapshot.docs.length;
      print('Users: '+ querySnapshot.docs.length.toString());

      // Gender
      var femaleUsers = 0;
      var maleUsers = 0;
      var noGenderUsers = 0;
      // Private
      var isPrivate = 0;
      var isPublic = 0;
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Usuario user = Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        // Gender
        if (user.gender == 0) {
          maleUsers += 1;
        } else if (user.gender == 1) {
          femaleUsers += 1;
        } else {
          noGenderUsers += 1;
        }
        // Private
        if (user.isPrivate!) {
          isPrivate += 1;
        } else {
          isPublic += 1;
        }
      }
      print('femaleUsers: '+ femaleUsers.toString());
      print('maleUsers: '+ maleUsers.toString());
      print('noGenderUsers: '+ noGenderUsers.toString());
      print('isPrivate: '+ isPrivate.toString());
      print('isPublic: '+ isPublic.toString());

      querySnapshot = await _firestore.collection("Users").where("isTrainer", isEqualTo:false).get();
      var clientUsers = querySnapshot.docs.length;
      print('Users Clients: '+ querySnapshot.docs.length.toString());

      querySnapshot = await _firestore.collection("Users").where("isTrainer", isEqualTo:true).get();
      var trainerUsers = querySnapshot.docs.length;
      print('Users Trainers: '+ querySnapshot.docs.length.toString());

      print('Users Not Onboarded: '+ (totalUsers-clientUsers-trainerUsers).toString());

      querySnapshot = await _firestore.collection("Brands").get();
      print('Brands: '+ querySnapshot.docs.length.toString());

      querySnapshot = await _firestore.collection("Events").get();
      print('Events: '+ querySnapshot.docs.length.toString());

      querySnapshot = await _firestore.collection("Events").where("numClients", isGreaterThan:0).get();
      print('Events With Clients: '+ querySnapshot.docs.length.toString());

      for (int i = 1; i < 13; i++) {
        querySnapshot = await _firestore.collection("Events")
            .where("year", isEqualTo: 2022.toString())
            .where("month", isEqualTo: i.toString())
            .get();
        print("Events Month "+i.toString()+": "+ querySnapshot.docs.length.toString());

        querySnapshot = await _firestore.collection("Events")
            .where("numClients", isGreaterThan:0)
            .where("year", isEqualTo: 2022.toString())
            .where("month", isEqualTo: i.toString())
            .get();
        print("Events with Clients Month "+i.toString()+": "+ querySnapshot.docs.length.toString());
      }

      querySnapshot = await _firestore.collection("Locations").get();
      print('Locations: '+ querySnapshot.docs.length.toString());

      querySnapshot = await _firestore.collection("Rooms").get();
      print('Rooms: '+ querySnapshot.docs.length.toString());

      querySnapshot = await _firestore.collection("Errors").get();
      print('Errors: '+ querySnapshot.docs.length.toString());

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> getStatisticsSpecific() async {
    try {

      QuerySnapshot querySnapshot = await _firestore.collection("Brands").get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String brandId = querySnapshot.docs[i].id;
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection("Brands").doc(brandId).get();
        Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print("BRAND "+brand.name!);

        QuerySnapshot querySnapshotBrand = await _firestore.collection("Brands").doc(brandId).collection("Users").get();
        print("Users: "+ querySnapshotBrand.docs.length.toString());

        querySnapshotBrand = await _firestore.collection("Brands").doc(brandId).collection("Users").where("isTrainer", isEqualTo:false).get();
        print("Clients: "+ querySnapshotBrand.docs.length.toString());

        querySnapshotBrand = await _firestore.collection("Brands").doc(brandId).collection("Users").where("isTrainer", isEqualTo:true).get();
        print("Trainers: "+ querySnapshotBrand.docs.length.toString());

        querySnapshotBrand = await _firestore.collection("Brands").doc(brandId).collection("Events").get();
        print("Events: "+ querySnapshotBrand.docs.length.toString());

        for (int i = 1; i < 13; i++) {
          querySnapshotBrand = await _firestore.collection("Brands").doc(brandId)
              .collection("Events")
              .where("year", isEqualTo: 2022.toString())
              .where("month", isEqualTo: i.toString())
              .get();
          print("Events Month "+i.toString()+": "+ querySnapshotBrand.docs.length.toString());
        }

        querySnapshotBrand = await _firestore.collection("Brands").doc(brandId).collection("Events").where("numClients", isGreaterThan:0).get();
        print("Events with Clients: "+ querySnapshotBrand.docs.length.toString());

        for (int i = 1; i < 13; i++) {
          querySnapshotBrand = await _firestore.collection("Brands").doc(brandId)
              .collection("Events")
              .where("numClients", isGreaterThan:0)
              .where("year", isEqualTo: 2022.toString())
              .where("month", isEqualTo: i.toString())
              .get();
          print("Events with Clients Month "+i.toString()+": "+ querySnapshotBrand.docs.length.toString());
        }
      }

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> migrateEventDataJuly24th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 6TH FEBRUARY 2022');
      print('-----------------------------\n');
      print('\n');

      print('Modifying '+events+' collection:\n');
      print('-----------------------------\n');
      print('\n');

      /* TEST IN PRODUCTION WIHT OUR TEST BRAND - MAMBA TEAM
      String brandId = "9d978520-be41-4d90-94df-f49db3be5eac";
      QuerySnapshot querySnapshot = await _firestore.collection(events).where("brandID", isEqualTo: brandId).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('EVENT WITH ID: '+event.id!+" OF BRAND WITH ID: "+brandId);
        print('\n');
        print('Updating Document Data ...');
        print('-----------------------------');
        var selectedTrainers =  querySnapshot.docs[i].get("selectedTrainers");
        var joinedMembers =  querySnapshot.docs[i].get("joinedMembers");
        print('Updating numTrainers and numClients document of Event');
        await _firestore.collection(events).doc(event.id!).update({
          "numClients":  joinedMembers != null ? joinedMembers.length : 0,
          "numTrainers":  selectedTrainers != null ? selectedTrainers.length : 0,
        });
        print('\n');
        print('Adding "Users" subcollection');
        print('-----------------------------\n');
        var usersIds = selectedTrainers + joinedMembers;
        for (var i=0; i<usersIds.length;i++) {
          String userId = usersIds[i];
          print('User with ID : ' + userId);
          DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(users).doc(userId).get();
          Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
          await _firestore
            .collection(events)
            .doc(event.id!)
            .collection("Users")
            .doc(user.id!)
            .set({
              "name": user.name,
              "firstName": user.firstName,
              "lastName": user.lastName,
              "nick": user.nick,
              "imageUrl": user.imageUrl,
              "noImageUrl": user.noImageUrl,
              "isTrainer": user.isTrainer,
              "isPrivate": user.isPrivate,
              "notificationToken": user.notificationToken,
            });
        }
        print('All Users Added');
        print('\n');
        print('Adding "Brands" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentBrand = await _firestore.collection(brands).doc(event.brandID).get();
        Brand brand = Brand.fromObjectAllData(_documentBrand.id, _documentBrand);
        print('Brand with ID : '+brand.id!);
        await _firestore.collection(events).doc(event.id!).collection("Brands").doc(brand.id)
            .set({
              "name": brand.name,
              "logoUrl": brand.logoUrl,
            });
        print('All Brands Added');
        print('\n');
        print('Adding "Locations" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentSnapshot = await _firestore.collection(locations).doc(event.locationId).get();
        Location location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('Location with ID : '+location.id!);
        await _firestore
            .collection(events)
            .doc(event.id!)
            .collection("Locations")
            .doc(location.id!)
            .set({
              "description": location.description,
              "latitude": location.latitude,
              "longitude": location.longitude,
            });
        print('All Locations Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }*/


      // PRODUCTION FOR ALL REAL EVENTS
      QuerySnapshot querySnapshot = await _firestore.collection(events).where("brandID", isEqualTo: "ef80f103-824c-4f4b-9764-8fe4863c8c4f").where("month", isEqualTo: "2").get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('EVENT WITH ID: '+event.id!+" OF BRAND WITH ID: "+event.brandID!);
        print('\n');
        print('Updating Document Data ...');
        print('-----------------------------');
        var selectedTrainers =  querySnapshot.docs[i].get("selectedTrainers");
        var joinedMembers =  querySnapshot.docs[i].get("joinedMembers");
        print('Updating numTrainers and numClients document of Event');
        await _firestore.collection(events).doc(event.id!).update({
          "numClients":  joinedMembers != null ? joinedMembers.length : 0,
          "numTrainers":  selectedTrainers != null ? selectedTrainers.length : 0,
        });
        print('\n');
        print('Adding "Users" subcollection');
        print('-----------------------------\n');
        var usersIds = selectedTrainers + joinedMembers;
        for (var i=0; i<usersIds.length;i++) {
          String userId = usersIds[i];
          print('User with ID : ' + userId);
          DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(users).doc(userId).get();
          Usuario user = Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
          await _firestore
              .collection(events)
              .doc(event.id!)
              .collection("Users")
              .doc(user.id!)
              .set({
            "name": user.name,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "nick": user.nick,
            "imageUrl": user.imageUrl,
            "noImageUrl": user.noImageUrl,
            "isTrainer": user.isTrainer,
            "isPrivate": user.isPrivate,
            "notificationToken": user.notificationToken,
          });
        }
        print('All Users Added');
        print('\n');
        print('Adding "Brands" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentBrand = await _firestore.collection(brands).doc(event.brandID).get();
        Brand brand = Brand.fromObjectAllData(_documentBrand.id, _documentBrand);
        print('Brand with ID : '+brand.id!);
        await _firestore.collection(events).doc(event.id!).collection("Brands").doc(brand.id)
            .set({
          "name": brand.name,
          "logoUrl": brand.logoUrl,
        });
        print('All Brands Added');
        print('\n');
        print('Adding "Locations" subcollection');
        print('-----------------------------\n');
        DocumentSnapshot _documentSnapshot = await _firestore.collection(locations).doc(event.locationId).get();
        Location location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('Location with ID : '+location.id!);
        await _firestore
            .collection(events)
            .doc(event.id!)
            .collection("Locations")
            .doc(location.id!)
            .set({
          "description": location.description,
          "latitude": location.latitude,
          "longitude": location.longitude,
        });
        print('All Locations Added');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addPhotosToLibrary() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 01 SEPTEMBER 2022');
      print('-----------------------------\n');
      print('\n');

      print('Adding Event Photos to Library ... \n');
      print('-----------------------------\n');
      print('\n');

      QuerySnapshot querySnapshot = await _firestore.collection(library).doc("Images").collection("Events").get();
      for (int i = 0; i < querySnapshot.size; i++) {
        lImage image = lImage.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        // Asset Image to File
        File fileImage = await ImageUtils().urlToFile(image.url!);
        // Compress Image
        var size = await ImageUtils().getImageFileSize(fileImage, 2);
        print("Current Image Size: "+size);
        print('\n');
        print("Compressing Image...");
        print('\n');
        final filePath = fileImage.absolute.path;
        final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
        final splitted = filePath.substring(0, (lastIndex));
        final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
        var compressedFileImage = await FlutterImageCompress.compressAndGetFile(
          fileImage.absolute.path,
          outPath,
          quality: 75,
          rotate: 0,
        );
        var compressedSize = await ImageUtils().getImageFileSize(compressedFileImage!, 2);
        print("Compressed Image Size: "+compressedSize);
        // Upload Image
        var storageRef = _firebaseStorage.ref().child("library/images/event/" + querySnapshot.docs[i].id.toString() + ".jpeg");
        var uploadTask = storageRef.putFile(compressedFileImage);
        await uploadTask.whenComplete(() async {
          await storageRef.getDownloadURL().then((value) async {
            await _firestore.collection(library).doc("Images").collection("Events").doc(querySnapshot.docs[i].id.toString()).update({
              "url": value,
            });
          });
        });
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');

      }


      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> migrateEventDataSeptember9th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 01 SEPTEMBER 2022');
      print('-----------------------------\n');
      print('\n');

      print('Modifying '+this.events+' collection:\n');
      print('-----------------------------\n');
      print('\n');

      int usersErrorCnt = 0;
      int brandErrorCnt = 0;
      int locationErrorCnt = 0;

      String events = "Events";
      String users = "Users";
      String brands = "Brands";
      String locations = "Locations";

      // PRODUCTION FOR ALL REAL EVENTS
      QuerySnapshot querySnapshot = await _firestore.collection(events).where("month", isEqualTo: 10.toString()).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=======================s==========================================================');
        print('=================================================================================');
        print('EVENT WITH ID: '+event.id!+" OF BRAND WITH ID: "+event.brandID!);
        print('\n');

        print('Getting Random Image from Library ...');
        String imageUrl = await _libraryDataService.getRandomEventPhoto();
        print('\n');
        print('Updating Event Image Url ...');
        await _firestore.collection(events).doc(event.id!).update({
          "imageUrl": imageUrl,
        });
        print('\n');

        try {
          print('Updating "Users" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotUsers = await _firestore.collection(events).doc(event.id!).collection("Users").get();
          for (var i=0; i<querySnapshotUsers.size;i++) {
            Usuario user = Usuario.fromObjectOnlyCoverData(querySnapshotUsers.docs[i].id, querySnapshotUsers.docs[i]);
            await _firestore.collection(users).doc(user.id!).collection("Events").doc(event.id!).update({
              "imageUrl": imageUrl,
            });
          }
          print('All Users Updated');
          print('\n');
        } catch (e) {
          print('No document to update: projects/mamba-style/databases/(default)/documents/Users/{userId}/Events/[eventId}');
          usersErrorCnt += 1;
        }

        try {
          print('Updating "Brands" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotBrands = await _firestore.collection(events).doc(event.id!).collection("Brands").get();
          for (var i=0; i<querySnapshotBrands.size;i++) {
            Brand brand = Brand.fromObjectOnlyCoverData(querySnapshotBrands.docs[i].id, querySnapshotBrands.docs[i]);
            await _firestore.collection(brands).doc(brand.id!).collection("Events").doc(event.id!).update({
              "imageUrl": imageUrl,
            });
          }
          print('All Brands Updated');
          print('\n');
        } catch (e) {
          print('No document to update: projects/mamba-style/databases/(default)/documents/Brands/{brandId}/Events/[eventId}');
          brandErrorCnt += 1;
        }

        try {
          print('Updating "Locations" subcollection');
          print('-----------------------------\n');
          QuerySnapshot querySnapshotLocations = await _firestore.collection(events).doc(event.id!).collection("Locations").get();
          for (var i=0; i<querySnapshotLocations.size;i++) {
            Location location = Location.fromObjectOnlyCoverData(querySnapshotLocations.docs[i].id, querySnapshotLocations.docs[i]);
            await _firestore.collection(locations).doc(location.id!).collection("Events").doc(event.id!).update({
              "imageUrl": imageUrl,
            });
          }
          print('All Locations Updated');
          print('\n');
        } catch (e) {
          print('No document to update: projects/mamba-style/databases/(default)/documents/Locations/{locationId}/Events/[eventId}');
          locationErrorCnt += 1;
        }

        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      print("usersErrorCnt:");
      print(usersErrorCnt);
      print("brandErrorCnt:");
      print(brandErrorCnt);
      print("locationErrorCnt:");
      print(locationErrorCnt);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateEventDataOctober3th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 01 SEPTEMBER 2022');
      print('-----------------------------\n');
      print('\n');

      print('Modifying '+this.events+' collection:\n');
      print('-----------------------------\n');
      print('\n');

      int usersErrorCnt = 0;
      int brandErrorCnt = 0;
      int locationErrorCnt = 0;

      String events = "Events";
      String users = "Users";
      String brands = "Brands";
      String locations = "Locations";

      // PRODUCTION FOR ALL REAL EVENTS
      QuerySnapshot querySnapshot = await _firestore.collection(events).where("month", isEqualTo: 10.toString()).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('EVENT WITH ID: '+event.id!+" OF BRAND WITH ID: "+event.brandID!);
        print('\n');

        // Get Event Users
        List<Usuario> eventUsers = [];
        int numClients = 0;
        int numTrainers = 0;
        QuerySnapshot querySnapshot2 = await _firestore
            .collection(events)
            .doc(event.id!)
            .collection("Users")
            .get();
        for (int i = 0; i < querySnapshot2.docs.length; i++) {
          Usuario usuario = Usuario.fromObjectOnlyCoverData(querySnapshot2.docs[i].id, querySnapshot2.docs[i]);
          eventUsers.add(usuario);
          if (usuario.isTrainer!) {
            numTrainers += 1;
          } else {
            numClients += 1;
          }
        }
        print("NumClients: "+numClients.toString());
        print("NumTrainers: "+numTrainers.toString());

        // Update Users Events
        for (Usuario user in eventUsers) {
          print("Solving User "+user.name!.toUpperCase());
          await _firestore
          .collection(users)
          .doc(user.id!)
          .collection("Events")
          .doc(event.id!)
          .set({
            "isPrivate": event.isPrivate,
            "title": event.title,
            "imageUrl": event.imageUrl ?? "",
            "doneAt": event.doneAt,
            "year": event.year,
            "month": event.month,
            "day": event.day,
            "hour": event.hour,
            "minute": event.minute,
            "duration": event.duration,
            "numTrainers": numTrainers,
            "numClients": numClients,
            "maxMembers": event.maxMembers,
          });
        }
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');

      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateUserDataOctober27th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 8TH FEBRUARY 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying Brands/Users collection:\n');
      print('--------------');
      print('\n');

      String users = "Users";
      String brands = "Brands";

      // REAL MIGRATION FOR REAL DATA OF USERS
      QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String brandId = querySnapshot.docs[i].id;
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).get();
        Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        print('=================================================================================');
        print('=================================================================================');
        print('BRAND WITH ID: '+brand.id!+" AND NAME: "+brand.name!);
        print('\n');
        print('Updating "Users" subcollection');
        print('-----------------------------\n');
        QuerySnapshot querySnapshotUsers = await _firestore.collection(brands).doc(brandId).collection("Users").get();
        for (var i=0; i<querySnapshotUsers.docs.length;i++) {
          String userId = querySnapshotUsers.docs[i].id;
          DocumentSnapshot _documentSnapshot = await _firestore.collection(users).doc(userId).get();
          // Get User Data
          Usuario user = Usuario.fromObjectAllData(userId, _documentSnapshot);
          print('User with ID : '+userId+" and Name: "+user.name!);
          // Get Date Joined Brand
          DocumentSnapshot<Map<String, dynamic>> _documentSnapshot2 = await _firestore.collection(users).doc(userId).collection("Brands").doc(brandId).get();
          String dateJoined = _documentSnapshot2.get("dateJoined");
          // Get Last Event of User
          QuerySnapshot querySnapshotUserEvents = await _firestore.collection(users).doc(userId).collection("Events").get();
          List<Event> events = [];
          for (int i = 0; i < querySnapshotUserEvents.docs.length; i++) {
            events.add(Event.fromObjectOnlyCoverData(querySnapshotUserEvents.docs[i].id, querySnapshotUserEvents.docs[i]));
          }
          events.sort((a, b) {
            return b.doneAt!.toDate().compareTo(a.doneAt!.toDate());
          });
          if (events.isNotEmpty) {
            Event lastEvent = events[0];
            // Update Brand / Users
            await _firestore
            .collection(brands)
            .doc(brandId)
            .collection("Users")
            .doc(userId)
            .update({
              "lastEventAt": lastEvent.doneAt,
              "dateJoined": dateJoined,
              "gender": user.gender,
              "dateOfBirth": user.dateOfBirth,
            });
            // Updates
            print("lastEventAt: "+lastEvent.doneAt.toString());
            print("dateJoined: "+dateJoined);
            print("gender: "+user.gender.toString());
            print("dateOfBirth: "+user.dateOfBirth!);
          } else {
            // Update Brand / Users
            await _firestore
            .collection(brands)
            .doc(brandId)
            .collection("Users")
            .doc(userId)
            .update({
              "dateJoined": dateJoined,
              "gender": user.gender,
              "dateOfBirth": user.dateOfBirth,
            });
            // Updates
            print("lastEventAt: "+"No Events Done");
            print("dateJoined: "+dateJoined);
            print("gender: "+user.gender.toString());
            print("dateJoined: "+user.dateOfBirth!);
          }
        }
        print('All Users Updated');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migrateUserDataNovember11th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 11TH NOVEMBER 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying Users/Notifications collection:\n');
      print('--------------');
      print('\n');

      String users = "7777 Users";

      // Get all the Trainers
      QuerySnapshot querySnapshot = await _firestore.collection(users).where("isTrainer", isEqualTo: true).get();
      // Per Trainer Get their Brand
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String userId = querySnapshot.docs[i].id;
        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: '+userId);
        print('\n');
        // Get their Brand Id
        QuerySnapshot querySnapshot2 = await _firestore.collection(users).doc(userId).collection("Brands").get();
        if (querySnapshot2.docs.isNotEmpty) {
          String brandId = querySnapshot2.docs[0].id;
          // Filter type of notification UserBuysBono_Trainer
          QuerySnapshot querySnapshot3 = await _firestore.collection(users).doc(userId).collection("Notifications").where("type", isEqualTo: "UserBuysBono_Trainer").get();
          for (int i = 0; i < querySnapshot3.docs.length; i++) {
            NotificationEvent notif = NotificationEvent.fromObjectAllData(querySnapshot3.docs[i].id, querySnapshot3.docs[i]);
            print('NOTIF WITH ID: '+ notif.id!);
            // Add Brand Id
            var parameters = [notif.parameters[0], brandId, notif.parameters[2], notif.parameters[3], notif.parameters[4]];
            // Update Parameters on Notification
            await _firestore
            .collection(users)
            .doc(userId)
            .collection("Notifications")
            .doc(notif.id!)
            .update({
              "parameters": parameters,
            });
          }
        }
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> migratePurchaseDataDecember16th() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 16th DECEMBER 2022');
      print('-----------------------------');
      print('\n');

      print('Modifying Purchases/Events collection:\n');
      print('--------------');
      print('\n');

      /// 7777 Brands/Bonos/Purchases/Events
      /// 7777 Brands/Users/Purchases/Events
      /// 7777 Users/Purchases/Events

      String users = "Users";
      String brands = "Brands";
      String payments = "Payments";

      // Get All Purchases
      QuerySnapshot querySnapshot = await _firestore.collection(payments).doc("Purchases").collection("Purchases").get();
      // For each Purchase
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String purchaseId = querySnapshot.docs[i].id;
        Purchase purchase = Purchase.fromObjectAllData(purchaseId, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('Purchase WITH ID: '+purchaseId);
        print('\n');
        // Check if it has Events
        // Get Purchase Events
        QuerySnapshot querySnapshot2 = await _firestore
            .collection(payments)
            .doc("Purchases")
            .collection("Purchases")
            .doc(purchaseId)
            .collection("Events")
            .get();
        // For each Event
        for (int i = 0; i < querySnapshot2.docs.length; i++) {
          Event event = Event.fromObjectOnlyCoverData(querySnapshot2.docs[i].id, querySnapshot2.docs[i]);
          // Get the Image Url
          String imageUrl = event.imageUrl!;
          // Update Brands/Bonos/Purchases/Events
          try {
            await _firestore
            .collection(brands)
            .doc(purchase.brandId)
            .collection("Bonos")
            .doc(purchase.bonoId)
            .collection("Purchases")
            .doc(purchase.id)
            .collection("Events")
            .doc(event.id!)
            .update({
              "imageUrl": imageUrl,
            });
          } catch (e) {
            print(e.toString());
          }
          // Update Brands/Users/Purchases/Events
          try {
            await _firestore
            .collection(brands)
            .doc(purchase.brandId)
            .collection("Users")
            .doc(purchase.userId)
            .collection("Purchases")
            .doc(purchase.id)
            .collection("Events")
            .doc(event.id!)
            .update({
              "imageUrl": imageUrl,
            });
          } catch (e) {
            print(e.toString());
          }
          // Update Users/Purchases/Events
          try {
            await _firestore
            .collection(users)
            .doc(purchase.userId)
            .collection("Purchases")
            .doc(purchase.id)
            .collection("Events")
            .doc(event.id!)
            .update({
              "imageUrl": imageUrl,
            });
          } catch (e) {
            print(e.toString());
          }
        }
        print('All Events Purchased Updated');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> JMFmigrateUserDataJenuary31() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 31th JANUARY 2023');
      print('-----------------------------');
      print('\n');

      print('Modifying Users/Notifications collection:\n');
      print('--------------');
      print('\n');

      String users = "7777 Users";
      Usuario user = new Usuario();
      QuerySnapshot querySnapshot3;
      QuerySnapshot querySnapshot4;

      // Get all the Trainers
      QuerySnapshot querySnapshot = await _firestore.collection(users).where("isTrainer", isEqualTo: true).get();
      // Per Trainer Get their Brand
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String userId = querySnapshot.docs[i].id;
        print(userId);
        user = Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: '+userId);
        print('\n');
        // Get their Brand Id
        QuerySnapshot querySnapshot2 = await _firestore.collection(users).doc(userId).collection("Brands").get();
        if (querySnapshot2.docs.isNotEmpty) {
          String brandId = querySnapshot2.docs[0].id;
          // Filter type of notification UserBuysBono_Trainer
          if(user.isTrainer!) {
             querySnapshot3 = await _firestore.collection(users)
                .doc(userId).collection("Notifications").where(
                "type", isEqualTo: "UserSendBonoRequest_Trainer")
                .get();
             querySnapshot4 = await _firestore.collection(users)
                 .doc(userId).collection("Notifications").where(
                 "type", isEqualTo: "UserCancelBonoRequest_Trainer")
                 .get();
          }
          else
            {
               querySnapshot3 = await _firestore.collection(users)
                  .doc(userId).collection("Notifications").where(
                  "type", isEqualTo: "UserSendBonoRequest_User")
                  .get();
               querySnapshot4 = await _firestore.collection(users)
                   .doc(userId).collection("Notifications").where(
                   "type", isEqualTo: "UserCancelBonoRequest_User")
                   .get();
            }
          for (int i = 0; i < querySnapshot3.docs.length; i++) {
            NotificationEvent notif = NotificationEvent.fromObjectAllData(querySnapshot3.docs[i].id, querySnapshot3.docs[i]);
            print('NOTIF WITH ID: '+ notif.id!);
            // Add Brand Id
            var parameters = [notif.parameters[0], brandId, notif.parameters[2], notif.parameters[3], notif.parameters[4]];
            // Update Parameters on Notification
            await _firestore
                .collection(users)
                .doc(userId)
                .collection("Notifications")
                .doc(notif.id!)
                .update({
              "parameters": parameters,
            });
          }
          for (int i = 0; i < querySnapshot4.docs.length; i++) {
            NotificationEvent notif = NotificationEvent.fromObjectAllData(querySnapshot4.docs[i].id, querySnapshot4.docs[i]);
            print('NOTIF WITH ID: '+ notif.id!);
            // Add Brand Id
            var parameters = [notif.parameters[0], brandId, notif.parameters[2], notif.parameters[3], notif.parameters[4]];
            // Update Parameters on Notification
            await _firestore
                .collection(users)
                .doc(userId)
                .collection("Notifications")
                .doc(notif.id!)
                .update({
              "parameters": parameters,
            });
          }
        }
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> JMFsolveUsersBlockedMarch08() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 08th MARCH 2023');
      print('-----------------------------');
      print('\n');

      print('Modifying Users/BlockedByUsers collection:\n');
      print('--------------');
      print('\n');

      String users = "7777 Users";
      Usuario user = new Usuario();
      QuerySnapshot querySnapshot3;
      QuerySnapshot querySnapshot4;

      // Get all the Trainers
      QuerySnapshot querySnapshot = await _firestore.collection(users).where("isTrainer", isEqualTo: true).get();
      // Per Trainer Get their Brand
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        String userId = querySnapshot.docs[i].id;
        print(userId);
        //user = Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);

        await _firestore
            .collection(users)
            .doc(userId)
            .collection("BlockedByUsers")
            .doc('test')
            .set({
          "userId": 'test',
        });
        print('=================================================================================');
        print('=================================================================================');
        print('USER WITH ID: '+userId);
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  //TODO EXECUTE IN PROD
  Future<bool> JMFassignZipCodeAndLocation13AndBaseImage() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 13th MARCH 2023');
      print('-----------------------------');
      print('\n');

      print('Modifying Brand and UserBrand collection:\n');
      print('--------------');
      print('\n');

      String brands = "7777 Brands";
      String locations = "7777 Locations";
      Usuario user = new Usuario();
      QuerySnapshot querySnapshot4;
      String baseImage = "";

      QuerySnapshot querySnapshotBrands = await _firestore.collection(brands).get();

      for (int i = 0; i < querySnapshotBrands.docs.length; i++) {

        String brandId = querySnapshotBrands.docs[i].id;
        print(brandId);
        QuerySnapshot querySnapshot2 = await _firestore.collection(brands).doc(brandId).collection("Images").get();
        // Images
        if (querySnapshot2.size > 0) {
            baseImage = ImageObject.fromObjectAllData(querySnapshot2.docs[0].id, querySnapshot2.docs[0]).url!;
            await _firestore
                .collection(brands)
                .doc(brandId).collection("Images").doc(querySnapshot2.docs[0].id)
                .update({
              "isBaseImage": true,
            });
        } else {
          QuerySnapshot querySnapshot3 = await _firestore.collection(library).doc('Images').collection("Events").get();
          Random rnd = Random();
          int index = rnd.nextInt(querySnapshot3.size);
          baseImage = ImageObject.fromObjectAllData(querySnapshot3.docs[index].id, querySnapshot3.docs[index]).url!;
        }
        QuerySnapshot querySnapshotLocations = await _firestore.collection(brands).doc(brandId).collection("Locations").where("isBaseLocation", isEqualTo: true).get();
        print(querySnapshotLocations.docs[0].id!);
        DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
            .collection(locations)
            .doc(querySnapshotLocations.docs[0].id!).get();
        print(querySnapshotLocations.docs[0].id!);
        var location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
        //user = Usuario.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);

        await _firestore
            .collection(brands)
            .doc(brandId)
            .update({
          "zipCode": location.zipCode,
          "city": location.city,
          "baseImage": baseImage,
          "latitude": location.latitude,
          "longitude": location.longitude,
        });
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  //TODO DOING RIGHT NOW
  Future<bool> JMFassignBrandIdToUserEvents() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 13th MARCH 2023');
      print('-----------------------------');
      print('\n');

      print('Modifying Event and UserBrand collection:\n');
      print('--------------');
      print('\n');

      String events = "7777 Events";
      String users = "7777 Users";

      QuerySnapshot querySnapshotUsers= await _firestore.collection(users).get();

      for (int i = 0; i < querySnapshotUsers.docs.length; i++) {
        String userId = querySnapshotUsers.docs[i].id;
        QuerySnapshot querySnapshotEventsUser = await _firestore.collection(users).doc(userId).collection("Events").get();

        for (int j = 0; j < querySnapshotEventsUser.docs.length; j++)
          {
            String eventId = querySnapshotEventsUser.docs[j].id;
            DocumentSnapshot<Map<String, dynamic>> _documentSnapshotEvent = await _firestore
                .collection(events)
                .doc(querySnapshotEventsUser.docs[j].id!).get();
            Event event = Event.fromObjectAllData(_documentSnapshotEvent.id, _documentSnapshotEvent);
            await _firestore
                .collection(users)
                .doc(userId).collection("Events").doc(eventId)
                .update({
              "brandID": event.brandID,
            });
          }
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> JMFassignBrandIdToLocationEvents() async {
    try {
      print('\n');
      print('-----------------------------');
      print('DATA MIGRATION 13th MARCH 2023');
      print('-----------------------------');
      print('\n');

      print('Modifying Event and UserBrand collection:\n');
      print('--------------');
      print('\n');

      String events = "7777 Events";
      String locations = "7777 Locations";

      QuerySnapshot querySnapshotLocations = await _firestore.collection(locations).get();

      for (int i = 0; i < querySnapshotLocations.docs.length; i++) {
        String locationId = querySnapshotLocations.docs[i].id;
        QuerySnapshot querySnapshotEventsLocation = await _firestore.collection(locations).doc(locationId).collection("Events").get();

        for (int j = 0; j < querySnapshotEventsLocation.docs.length; j++)
        {
          String eventId = querySnapshotEventsLocation.docs[j].id;
          DocumentSnapshot<Map<String, dynamic>> _documentSnapshotEvent = await _firestore
              .collection(events)
              .doc(querySnapshotEventsLocation.docs[j].id!).get();
          Event event = Event.fromObjectAllData(_documentSnapshotEvent.id, _documentSnapshotEvent);
          await _firestore
              .collection(locations)
              .doc(locationId).collection("Events").doc(eventId)
              .update({
            "brandID": event.brandID,
          });
        }
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
        print('=================================================================================');
        print('=================================================================================');
        print('\n');
      }
      return true;
    } catch (e) {
      return false;
    }
  }

}
