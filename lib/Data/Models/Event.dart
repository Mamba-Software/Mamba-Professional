// This class represents the Object <Event> that will be showed in the Sesions Widget.
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';

import 'Usuario.dart';

class Event {
  String? id;
  String? eventGroupId;
  String? creatorID;
  String? brandID;
  bool? isPrivate;
  String? title;
  String? description;
  Timestamp? doneAt;
  Timestamp? createdAt;
  String? year;
  String? month;
  String? day;
  String? hour;
  String? minute;
  double? duration;
  String? locationId;
  int? numClients;
  int? numTrainers;
  int? maxMembers;
  var joinedMembers;
  var selectedTrainers;

  List<Usuario> usersList = [];
  List<Brand> brandsList = [];
  Location location = Location();

  Event({
    this.id,
    this.eventGroupId,
    this.creatorID,
    this.brandID,
    this.isPrivate,
    this.title,
    this.description,
    this.doneAt,
    this.createdAt,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.duration,
    this.locationId,
    this.numClients,
    this.numTrainers,
    this.maxMembers,
    this.joinedMembers,
    this.selectedTrainers,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Event.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('eventGroupId')) {
      this.eventGroupId = documentSnapshot.get("eventGroupId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('creatorID')) {
      this.creatorID = documentSnapshot.get("creatorID").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('brandID')) {
      this.brandID = documentSnapshot.get("brandID").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      this.isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      this.title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('description')) {
      this.description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('doneAt')) {
      this.doneAt = documentSnapshot.get("doneAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('createdAt')) {
      this.createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('year')) {
      this.year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('month')) {
      this.month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('day')) {
      this.day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('hour')) {
      this.hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('minute')) {
      this.minute = documentSnapshot.get("minute").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('duration')) {
      this.duration = double.parse(documentSnapshot.get("duration").toString());
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('locationId')) {
      this.locationId = documentSnapshot.get("locationId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numClients')) {
      this.numClients = documentSnapshot.get("numClients");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numTrainers')) {
      this.numTrainers = documentSnapshot.get("numTrainers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('maxMembers')) {
      this.maxMembers = documentSnapshot.get("maxMembers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('joinedMembers')) {
      this.joinedMembers = documentSnapshot.get("joinedMembers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('selectedTrainers')) {
      this.selectedTrainers = documentSnapshot.get("selectedTrainers");
    }
  }

  Event.fromObjectOnlyCoverData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      this.isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      this.title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('doneAt')) {
      this.doneAt = documentSnapshot.get("doneAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('createdAt')) {
      this.createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('year')) {
      this.year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('month')) {
      this.month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('day')) {
      this.day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('hour')) {
      this.hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('minute')) {
      this.minute = documentSnapshot.get("minute").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('duration')) {
      this.duration = double.parse(documentSnapshot.get("duration").toString());
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numClients')) {
      this.numClients = documentSnapshot.get("numClients");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numTrainers')) {
      this.numTrainers = documentSnapshot.get("numTrainers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('maxMembers')) {
      this.maxMembers = documentSnapshot.get("maxMembers");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Event event) {
    this.creatorID = event.creatorID;
    this.brandID = event.brandID;
    this.title = event.title;
    this.description = event.description;
    this.year = event.year;
    this.month = event.month;
    this.day = event.day;
    this.hour = event.hour;
    this.minute = event.minute;
    this.duration = event.duration;
    this.locationId = event.locationId;
    this.numClients = event.numClients;
    this.numTrainers = event.numTrainers;
    this.maxMembers = event.maxMembers;
    this.joinedMembers = event.joinedMembers;
    this.selectedTrainers = event.selectedTrainers;
  }

  // Users
  set setUserList(List<Usuario> userList) {
    this.usersList = userList;
  }

  // Brands
  set setBrandList(List<Brand> brandList) {
    this.brandsList = brandList;
  }

  // Locations
  set setLocation(Location location) {
    this.location = location;
  }
}