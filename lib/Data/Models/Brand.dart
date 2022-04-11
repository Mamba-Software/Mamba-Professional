// Model for a Brand in our App
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';

import 'ImageObject.dart';
import 'RequestToBrand.dart';

class Brand {

  String? id;
  String? adminID;
  String? logoUrl;
  String? name;
  String? description;
  String? dateJoined;
  String? roomId;
  String? baseLocation;
  int? numClients;
  int? numTrainers;
  var workShift;
  int? maxMembers;

  List<ImageObject> imagesList = [];
  List<RequestToBrand> requestsList = [];
  List<Usuario> usersList = [];
  List<Event> eventsList = [];

  Brand({
    this.id,
    this.adminID,
    this.logoUrl,
    this.name,
    this.description,
    this.dateJoined,
    this.roomId,
    this.baseLocation,
    this.numClients,
    this.numTrainers,
    this.workShift,
    this.maxMembers,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Brand.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('adminID')) {
      this.adminID = documentSnapshot.get("adminID").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('logoUrl')) {
      this.logoUrl = documentSnapshot.get("logoUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      this.name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('description')) {
      this.description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateJoined')) {
      this.dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('roomId')) {
      this.roomId = documentSnapshot.get("roomId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('baseLocation')) {
      this.baseLocation = documentSnapshot.get("baseLocation").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numClients')) {
      this.numClients = documentSnapshot.get("numClients");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numTrainers')) {
      this.numTrainers = documentSnapshot.get("numTrainers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('workShift')) {
      this.workShift = documentSnapshot.get("workShift");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('maxMembers')) {
      this.maxMembers = documentSnapshot.get("maxMembers");
    }
  }

  Brand.fromObjectOnlyCoverData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      this.name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('logoUrl')) {
      this.logoUrl = documentSnapshot.get("logoUrl").toString();
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Brand brand) {
    this.name = brand.name;
    this.logoUrl = brand.logoUrl;
    this.adminID = brand.adminID;
    this.description = brand.description;
    this.dateJoined = brand.dateJoined;
    this.roomId = brand.roomId;
    this.baseLocation = brand.baseLocation;
    this.numClients = brand.numClients;
    this.numTrainers = brand.numTrainers;
    this.workShift = brand.workShift;
    this.maxMembers = brand.maxMembers;
  }

  // Requests
  set setRequestList(List<RequestToBrand> requestList) {
    this.requestsList = requestList;
  }

  // Users
  set setUserList(List<Usuario> userList) {
    this.usersList = userList;
  }

  // Events
  set setEventsList(List<Event> eventsList) {
    this.eventsList = eventsList;
  }
}
