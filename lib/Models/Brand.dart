// Model for a Brand in our App
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

import 'RequestToBrand.dart';

class Brand {

  String? id;
  String? adminID;
  String? logoUrl;
  String? name;
  String? description;
  String? dateJoined;
  String? groupRoomId;
  String? baseLocation;
  int? numberClients;
  int? numberTrainers;
  var workShift;
  int? maxMembers;

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
    this.groupRoomId,
    this.baseLocation,
    this.numberClients,
    this.numberTrainers,
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
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('groupRoomId')) {
      this.groupRoomId = documentSnapshot.get("groupRoomId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('baseLocation')) {
      this.baseLocation = documentSnapshot.get("baseLocation").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numberClients')) {
      this.numberClients = documentSnapshot.get("numberClients");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numberTrainers')) {
      this.numberTrainers = documentSnapshot.get("numberTrainers");
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
    this.groupRoomId = brand.groupRoomId;
    this.baseLocation = brand.baseLocation;
    this.numberClients = brand.numberClients;
    this.numberTrainers = brand.numberTrainers;
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
