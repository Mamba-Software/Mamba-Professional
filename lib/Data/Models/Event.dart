// This class represents the Object <Event> that will be showed in the Sesions Widget.
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
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
  String? imageUrl;
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
  List<Bono> bonosList = [];
  Location location = Location();

  Event({
    this.id,
    this.eventGroupId,
    this.creatorID,
    this.brandID,
    this.isPrivate,
    this.title,
    this.imageUrl,
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
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('eventGroupId')) {
      eventGroupId = documentSnapshot.get("eventGroupId");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('creatorID')) {
      creatorID = documentSnapshot.get("creatorID").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('brandID')) {
      brandID = documentSnapshot.get("brandID").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    } else {
      isPrivate = false;
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('description')) {
      description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('doneAt')) {
      doneAt = documentSnapshot.get("doneAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('createdAt')) {
      createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('year')) {
      year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('month')) {
      month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('day')) {
      day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('hour')) {
      hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('minute')) {
      minute = documentSnapshot.get("minute").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('duration')) {
      duration = double.parse(documentSnapshot.get("duration").toString());
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('locationId')) {
      locationId = documentSnapshot.get("locationId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numClients')) {
      numClients = documentSnapshot.get("numClients");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numTrainers')) {
      numTrainers = documentSnapshot.get("numTrainers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('maxMembers')) {
      maxMembers = documentSnapshot.get("maxMembers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('joinedMembers')) {
      joinedMembers = documentSnapshot.get("joinedMembers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('selectedTrainers')) {
      selectedTrainers = documentSnapshot.get("selectedTrainers");
    }
  }

  Event.fromObjectOnlyCoverData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    } else {
      isPrivate = false;
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('doneAt')) {
      doneAt = documentSnapshot.get("doneAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('createdAt')) {
      createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('year')) {
      year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('month')) {
      month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('day')) {
      day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('hour')) {
      hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('minute')) {
      minute = documentSnapshot.get("minute").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('duration')) {
      duration = double.parse(documentSnapshot.get("duration").toString());
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numClients')) {
      numClients = documentSnapshot.get("numClients");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numTrainers')) {
      numTrainers = documentSnapshot.get("numTrainers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('maxMembers')) {
      maxMembers = documentSnapshot.get("maxMembers");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Event event) {
    creatorID = event.creatorID;
    brandID = event.brandID;
    title = event.title;
    imageUrl = event.imageUrl;
    description = event.description;
    year = event.year;
    month = event.month;
    day = event.day;
    hour = event.hour;
    minute = event.minute;
    duration = event.duration;
    locationId = event.locationId;
    numClients = event.numClients;
    numTrainers = event.numTrainers;
    maxMembers = event.maxMembers;
    joinedMembers = event.joinedMembers;
    selectedTrainers = event.selectedTrainers;
  }

  // Users
  set setUserList(List<Usuario> userList) {
    usersList = userList;
  }

  // Brands
  set setBrandList(List<Brand> brandList) {
    brandsList = brandList;
  }

  // Bonos
  set setBonosList(List<Bono> bonosList) {
    this.bonosList = bonosList;
  }

  // Locations
  set setLocation(Location location) {
    this.location = location;
  }
}