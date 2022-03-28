import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/NotificationEvent.dart';
import 'dart:io';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:uuid/uuid.dart';
import '../DataService/BrandDataService.dart';

class ScriptsDatabaseService {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();
  var _brandDataService = BrandDataService();
  var _userDataService = UserDataService();

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
          if (user.brandID != null) {
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
            final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
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
        final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
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
          NotificationEvent notif = NotificationEvent.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
          // Get DateTime
          DateTime notifDate = DateTime(
            int.parse(notif.year!),
            int.parse(notif.month!),
            int.parse(notif.day!),
            int.parse(notif.hour!),
            int.parse(notif.minutes!),
            int.parse(notif.seconds!),
          );
          // DateTime to TimeStamp
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

      String eventsCollection = "7777 Events";
      String userCollection = "7777 Users";
      String brandsCollection = "7777 Brands";
      String locationCollection = "7777 Locations";

      QuerySnapshot querySnapshotEvents = await _firestore.collection(eventsCollection).get();
      for (int i = 0; i < querySnapshotEvents.docs.length; i++) {
        Event event = Event.fromObjectAllData(querySnapshotEvents.docs[i].id, querySnapshotEvents.docs[i]);
        print('=================================================================================');
        print('=================================================================================');
        print('EVENT WITH ID: ' + event.id!);
        print('\n');
        // Get DateTime
        DateTime eventDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        // DateTime to TimeStamp
        Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
        print("Timestamp is "+eventTimeStamp.toString());
        // Save TimeStamp Firebase
        await _firestore
            .collection(eventsCollection)
            .doc(event.id!)
            .update({
              "createdAt": eventTimeStamp,
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
          // Get DateTime
          DateTime eventDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          // DateTime to TimeStamp
          Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
          // Save TimeStamp Firebase
          await _firestore
              .collection(userCollection)
              .doc(userId)
              .collection("Events")
              .doc(event.id!)
              .update({
            "createdAt": eventTimeStamp,
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
          // Get DateTime
          DateTime eventDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          // DateTime to TimeStamp
          Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
          // Save TimeStamp Firebase
          await _firestore
              .collection(brandsCollection)
              .doc(brandId)
              .collection("Events")
              .doc(event.id!)
              .update({
            "createdAt": eventTimeStamp,
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
          // Get DateTime
          DateTime eventDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          // DateTime to TimeStamp
          Timestamp eventTimeStamp = Timestamp.fromDate(eventDate);
          // Save TimeStamp Firebase
          await _firestore
              .collection(locationCollection)
              .doc(locationId)
              .collection("Events")
              .doc(event.id!)
              .update({
            "createdAt": eventTimeStamp,
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


}
